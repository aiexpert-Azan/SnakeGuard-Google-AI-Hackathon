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

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True
    )