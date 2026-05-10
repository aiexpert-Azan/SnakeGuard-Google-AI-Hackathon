import asyncio
from fastapi import FastAPI, UploadFile, File, HTTPException
import uvicorn

# FIXED: Import directly as local modules since we run uvicorn inside SnakeGuard_Agent folder
from agent import SnakeGuardAgent
from logger import agent_logger

app = FastAPI(
    title="SnakeGuard Agentic API",
    description="Agentic backend for analyzing snakes and determining danger levels.",
    version="1.0.0"
)

# Initialize the agent
agent = SnakeGuardAgent()

@app.get("/")
def read_root():
    return {"message": "Welcome to SnakeGuard API"}

@app.post("/analyze")
async def analyze_image(file: UploadFile = File(...)):
    # Validate file type
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File must be an image.")
    
    agent_logger.info(f"Received request to analyze image: {file.filename}")
    
    try:
        content = await file.read()
        mime_type = file.content_type
        
        # FIXED: Run the synchronous agent loop in a separate thread 
        # to prevent blocking the asynchronous FastAPI event loop
        result = await asyncio.to_thread(agent.run_loop, image_bytes=content, mime_type=mime_type)
        
        return result
    
    except Exception as e:
        agent_logger.error(f"Error processing image: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal server error during analysis.")

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)