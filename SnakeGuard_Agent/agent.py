import os
import json
from pathlib import Path  # FIXED: Missing import added
from google import genai
from google.genai import types  # FIXED: Added for strictly typed parts and configs
from typing import Dict, Any
from dotenv import load_dotenv

from logger import agent_logger
from tools import search_hospital

BASE_DIR = Path(__file__).resolve().parent.parent
load_dotenv(dotenv_path=BASE_DIR / ".env")

# FIXED: Correct way to initialize the new Gemini Client
api_key = os.getenv("GEMINI_API_KEY")
if api_key:
    client = genai.Client(api_key=api_key)
else:
    agent_logger.warning("GEMINI_API_KEY not found in environment variables.")
    client = None

class SnakeGuardAgent:
    def __init__(self):
        # FIXED: Store client and model name
        self.client = client
        self.model_name = 'gemini-3-flash-preview' # Ensure this model name is active in your project
        agent_logger.info(f"Initialized SnakeGuardAgent with {self.model_name}.")

    def run_loop(self, image_bytes: bytes, mime_type: str) -> Dict[str, Any]:
        """Runs the Plan -> Act -> Observe loop."""
        logs = []
        
        def add_log(step: str, message: str, data: Any = None):
            log_entry = {"step": step, "message": message}
            if data:
                log_entry["data"] = data
            logs.append(log_entry)
            agent_logger.info(f"[{step}] {message}")
            if data:
                agent_logger.debug(f"Data: {data}")

        if not self.client:
            add_log("ERROR", "Gemini Client is not initialized due to missing API key.")
            return {"status": "error", "message": "API key missing", "logs": logs}

        # ----- PLAN -----
        add_log("PLAN", "Analyzing image to identify snake and assess danger level.")
        
        prompt = """
        You are an expert herpetologist and emergency responder AI.
        Analyze the provided image.
        Identify the snake species (if visible) and determine the danger level.
        The danger level must be exactly one of: None, Low, Moderate, High, Critical.
        Determine if emergency intervention is needed (tool_needed).
        Respond ONLY with a JSON object in the following format:
        {
            "species": "Name of the species or 'Unknown'",
            "danger_level": "Danger level string",
            "reasoning": "Brief explanation of your assessment",
            "tool_needed": true
        }
        """

        try:
            # FIXED: Updated generation call using the new SDK syntax
            response = self.client.models.generate_content(
                model=self.model_name,
                contents=[
                    prompt,
                    types.Part.from_bytes(data=image_bytes, mime_type=mime_type)
                ],
                config=types.GenerateContentConfig(
                    response_mime_type="application/json", # Forces strictly JSON output
                    temperature=0.2 # Lower temperature for analytical consistency
                )
            )
            
            # FIXED: Removed manual string stripping since output is guaranteed JSON
            plan_result = json.loads(response.text)
            add_log("PLAN_RESULT", "Successfully generated plan.", data=plan_result)
            
        except json.JSONDecodeError as e:
            add_log("ERROR", f"Failed to parse JSON response: {str(e)}")
            return {"status": "error", "message": "Invalid JSON from LLM", "logs": logs}
        except Exception as e:
            add_log("ERROR", f"Failed to analyze image: {str(e)}")
            return {"status": "error", "message": "Failed to analyze image", "logs": logs}

        # ----- ACT -----
        tool_results = None
        # Safely checking if tool is needed and danger is critical
        if plan_result.get("tool_needed") and plan_result.get("danger_level") == "Critical":
            add_log("ACT", "Danger level is Critical. Triggering emergency hospital search tool.")
            try:
                tool_results = search_hospital(lat=31.5204, lon=74.3587)
                add_log("ACT_RESULT", "Tool execution successful.", data=tool_results)
            except Exception as e:
                add_log("ERROR", f"Tool execution failed: {str(e)}")
                tool_results = {"error": str(e)}
        else:
            add_log("ACT", "No tool execution required based on assessment.")

        # ----- OBSERVE -----
        add_log("OBSERVE", "Compiling final assessment based on plan and tool results.")
        
        final_assessment = {
            "analysis": plan_result,
            "emergency_info": tool_results if tool_results else "None required."
        }
        
        add_log("DONE", "Agent loop complete.")

        return {
            "status": "success",
            "assessment": final_assessment,
            "logs": logs
        }