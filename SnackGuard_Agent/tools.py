import time
from typing import Dict, Any

def search_hospital() -> Dict[str, Any]:
    """Mock tool to search for nearby hospitals equipped with anti-venom."""
    # Simulating a delay for the tool call
    time.sleep(1)
    
    return {
        "status": "success",
        "nearest_hospital": {
            "name": "City General Hospital - Venom Treatment Center",
            "distance": "5 miles",
            "contact": "555-0198",
            "anti_venom_available": True,
            "estimated_arrival_time": "10 minutes by ambulance"
        },
        "instructions": "Keep the patient calm and still. Do NOT apply a tourniquet or attempt to suck the venom out. Wait for emergency services."
    }
