import asyncio
import os
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.responses import FileResponse
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
from agent import SnakeGuardAgent
from logger import agent_logger

app = FastAPI(
    title="SnakeGuard Agentic API",
    description="Agentic backend for analyzing snakes and determining danger levels.",
    version="1.0.0"
)

# CORS configuration to allow all origins (required for Flutter Web)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

agent = SnakeGuardAgent()

@app.get("/")
def read_root():
    return {"message": "Welcome to SnakeGuard API"}

# Legacy endpoint
@app.post("/analyze")
async def analyze_image(file: UploadFile = File(...)):
    """Legacy endpoint kept for backward compatibility."""
    return await _process_image(file)

# Primary endpoint expected by Flutter frontend
@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    """Primary endpoint for image analysis."""
    return await _process_image(file)

async def _process_image(file: UploadFile):
    # Validate that the uploaded file is an image
    if file.content_type is None or not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Uploaded file is not an image")

    agent_logger.info(f"Received request to analyze image: {file.filename}")

    try:
        content = await file.read()
        mime_type = file.content_type
        result = await asyncio.to_thread(
            agent.run_loop,
            image_bytes=content,
            mime_type=mime_type
        )
        # FastAPI will automatically convert to JSON
        return result
    except Exception as e:
        agent_logger.error(f"Error processing image: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")

@app.get("/download-pdf")
def download_pdf(pdf_path: str):
    if not os.path.exists(pdf_path):
        raise HTTPException(status_code=404, detail="PDF not found.")
    return FileResponse(
        path=pdf_path,
        media_type="application/pdf",
        filename="SnakeGuard_Emergency_Plan.pdf"
    )

from fastapi import Query
from tools import search_hospital, fetch_treatment_instructions

@app.get("/gemini_info")
async def gemini_info(snake_name: str = Query(...)):
    """Fetches Gemini instructions and info for a specific snake."""
    agent_logger.info(f"Received request for gemini_info: {snake_name}")
    try:
        is_venomous = True
        res = fetch_treatment_instructions(snake_name, agent.client, is_venomous)
        
        prompt = f"""
        Provide a brief description (2-3 sentences) of the snake species: {snake_name} and its danger level.
        Return ONLY a JSON with:
        {{
            "danger_level": "None, Low, Moderate, High, or Critical",
            "description": "2-3 sentences about the snake"
        }}
        """
        desc = f"The {snake_name} is a snake species that requires immediate attention if a bite is suspected."
        danger_level = "High"
        
        if agent.client:
            try:
                response = agent.client.models.generate_content(
                    model='gemini-3-flash-preview',
                    contents=prompt,
                    config=types.GenerateContentConfig(response_mime_type="application/json")
                )
                import json as pyjson
                data = pyjson.loads(response.text)
                danger_level = data.get("danger_level", "High")
                desc = data.get("description", desc)
            except Exception as e:
                agent_logger.error(f"Failed to generate description from LLM: {e}")
                
        return {
            "species": snake_name,
            "danger_level": danger_level,
            "description": desc,
            "instructions": res.get("instructions", [])
        }
    except Exception as e:
        agent_logger.error(f"Error in /gemini_info: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/nearby_hospitals")
async def nearby_hospitals(latitude: float = Query(...), longitude: float = Query(...)):
    """Fetches nearby hospitals for given coordinates."""
    agent_logger.info(f"Received request for nearby_hospitals: {latitude}, {longitude}")
    try:
        res = search_hospital(lat=latitude, lon=longitude)
        hospitals = res.get("hospitals", [])
        formatted_hospitals = []
        for i, h in enumerate(hospitals):
            formatted_hospitals.append({
                "name": h.get("name", f"Hospital {i+1}"),
                "address": h.get("address", f"Emergency Road near {latitude}, {longitude}"),
                "maps_link": h.get("maps_link", "https://maps.google.com"),
                "distance_km": 1.2 + i * 0.4
            })
        return formatted_hospitals
    except Exception as e:
        agent_logger.error(f"Error in /nearby_hospitals: {e}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True
    )