import os
import json
import google.generativeai as genai
from typing import Dict, Any
from dotenv import load_dotenv

from logger import agent_logger
from tools import search_hospital

# Load environment variables from parent dir since .env is at d:\AI Heckathone\.env
load_dotenv(dotenv_path="../.env")

# Configure Gemini
api_key = os.getenv("GEMINI_API_KEY")
if api_key:
    genai.configure(api_key=api_key)
else:
    agent_logger.warning("GEMINI_API_KEY not found in environment variables.")

class SnakeGuardAgent:
    def __init__(self):
        # Initialize Gemini 1.5 Flash model
        self.model = genai.GenerativeModel('gemini-3-flash-preview')
        agent_logger.info("Initialized SnakeGuardAgent with Gemini 3 Flash.")

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

        # ----- PLAN -----
        add_log("PLAN", "Analyzing image to identify snake and assess danger level.")
        
        prompt = """
        You are an expert herpetologist and emergency responder AI.
        Analyze the provided image.
        Identify the snake species (if visible) and determine the danger level.
        The danger level must be exactly one of: None, Low, Moderate, High, Critical.
        Determine if emergency intervention is needed (tool_needed).
        Respond ONLY with a JSON object in the following format, with no markdown formatting around it:
        {
            "species": "Name of the species or 'Unknown'",
            "danger_level": "Danger level string",
            "reasoning": "Brief explanation of your assessment",
            "tool_needed": boolean
        }
        """
        
        image_part = {
            "mime_type": mime_type,
            "data": image_bytes
        }

        try:
            response = self.model.generate_content([prompt, image_part])
            response_text = response.text.strip()
            # remove potential markdown code block format like ```json ... ```
            if response_text.startswith("```json"):
                response_text = response_text[7:]
            if response_text.startswith("```"):
                response_text = response_text[3:]
            if response_text.endswith("```"):
                response_text = response_text[:-3]
            response_text = response_text.strip()
            
            plan_result = json.loads(response_text)
            add_log("PLAN_RESULT", "Successfully generated plan.", data=plan_result)
        except Exception as e:
            add_log("ERROR", f"Failed to analyze image: {str(e)}")
            return {"status": "error", "message": "Failed to analyze image", "logs": logs}

        # ----- ACT -----
        tool_results = None
        if plan_result.get("tool_needed") and plan_result.get("danger_level") == "Critical":
            add_log("ACT", "Danger level is Critical. Triggering emergency hospital search tool.")
            try:
                tool_results = search_hospital()
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
