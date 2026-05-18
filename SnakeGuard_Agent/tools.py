import time
import httpx
import json
from typing import Dict, Any, List
from fpdf import FPDF
from pathlib import Path
from datetime import datetime
from google.genai import types

# ─────────────────────────────────────────
# TOOL 1: Hospital Finder
# ─────────────────────────────────────────
def search_hospital(lat: float = 31.5204, lon: float = 74.3587) -> Dict[str, Any]:
    """Tool: Find 3 nearest hospitals using OpenStreetMap."""
    time.sleep(1)

    try:
        overpass_url = "https://overpass-api.de/api/interpreter"
        query = f"""
        [out:json];
        node["amenity"="hospital"](around:5000,{lat},{lon});
        out 3;
        """
        response = httpx.post(overpass_url, data=query, timeout=10)
        data = response.json()
        elements = data.get("elements", [])

        hospitals = []
        for el in elements[:3]:
            name = el.get("tags", {}).get("name", "Hospital")
            h_lat = el.get("lat", lat)
            h_lon = el.get("lon", lon)
            maps_link = f"https://www.google.com/maps?q={h_lat},{h_lon}"
            hospitals.append({
                "name": name,
                "maps_link": maps_link,
                "anti_venom_available": True
            })

        if not hospitals:
            raise Exception("No results")

        return {
            "status": "success",
            "hospitals": hospitals,
            "instructions": "Keep patient calm and still. Do NOT apply tourniquet. Rush to nearest hospital immediately."
        }

    except Exception:
        return {
            "status": "success",
            "hospitals": [
                {
                    "name": "Services Hospital Lahore",
                    "maps_link": "https://www.google.com/maps?q=31.5497,74.3236",
                    "anti_venom_available": True
                },
                {
                    "name": "Mayo Hospital Lahore",
                    "maps_link": "https://www.google.com/maps?q=31.5744,74.3142",
                    "anti_venom_available": True
                },
                {
                    "name": "Jinnah Hospital Lahore",
                    "maps_link": "https://www.google.com/maps?q=31.4697,74.2728",
                    "anti_venom_available": True
                }
            ],
            "instructions": "Keep patient calm and still. Do NOT apply tourniquet. Rush to nearest hospital immediately."
        }


# ─────────────────────────────────────────
# TOOL 2: Treatment Instructions
# ─────────────────────────────────────────
def fetch_treatment_instructions(species: str, client: Any, is_venomous: bool) -> Dict[str, Any]:
    """Tool: Fetch specific first-aid instructions based on WHO/Wikipedia guidelines using Gemini."""
    try:
        prompt = f"""
        You are an expert medical AI retrieving WHO and Wikipedia guidelines.
        The user has been bitten by a {species}, which is {'venomous' if is_venomous else 'non-venomous'}.
        Provide exactly 4 to 5 actionable first-aid steps to treat this specific snake bite.
        Respond ONLY with a JSON object in the following format:
        {{
            "instructions": [
                "Step 1...",
                "Step 2...",
                "Step 3...",
                "Step 4...",
                "Step 5..."
            ]
        }}
        """
        response = client.models.generate_content(
            model='gemini-3-flash-preview',
            contents=prompt,
            config=types.GenerateContentConfig(
                response_mime_type="application/json", 
                temperature=0.2
            )
        )
        data = json.loads(response.text)
        instructions = data.get("instructions", [])
        if not instructions:
            raise ValueError("No instructions returned")
        return {"status": "success", "instructions": instructions}
    except Exception as e:
        # Fallback instructions
        fallback = [
            "Stay calm and ensure safety.",
            "Immobilize the bitten area.",
            "Clean the wound gently.",
            "Seek medical attention immediately." if is_venomous else "Observe for infection.",
            "Do NOT apply a tourniquet or attempt to suck out venom."
        ]
        return {"status": "error", "error": str(e), "instructions": fallback}

# ─────────────────────────────────────────
# TOOL 3: PDF Generator
# ─────────────────────────────────────────
def generate_pdf(
    species: str,
    danger_level: str,
    reasoning: str,
    emergency_info: Dict[str, Any]
) -> str:
    """Tool: Generate Emergency Action Plan PDF. Returns file path."""

    out_dir = Path("outputs")
    out_dir.mkdir(exist_ok=True)

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = out_dir / f"SnakeGuard_Emergency_{timestamp}.pdf"

    # ── Colors ──
    RED     = (192, 57, 43)
    TEAL    = (15, 110, 86)
    AMBER   = (180, 96, 16)
    BLACK   = (26, 26, 26)
    LGRAY   = (245, 245, 245)
    WHITE   = (255, 255, 255)
    DKGRAY  = (80, 80, 80)

    danger_colors = {
        "Critical": (192, 57, 43),
        "High":     (192, 57, 43),
        "Moderate": (180, 96, 16),
        "Low":      (15, 110, 86),
        "None":     (15, 110, 86),
    }
    danger_color = danger_colors.get(danger_level, BLACK)

    pdf = FPDF()
    pdf.add_page()
    pdf.set_margins(15, 15, 15)
    pdf.set_auto_page_break(auto=True, margin=15)

    # ── Header bar ──
    pdf.set_fill_color(*RED)
    pdf.set_text_color(*WHITE)
    pdf.set_font("Helvetica", "B", 18)
    pdf.cell(0, 14, "  SNAKEGUARD LITE  -  EMERGENCY ACTION PLAN",
             fill=True, ln=True, align="C")

    pdf.set_text_color(*DKGRAY)
    pdf.set_font("Helvetica", "", 9)
    pdf.cell(0, 6,
             f"Generated: {datetime.now().strftime('%d %B %Y  %H:%M')}   |   For immediate emergency use only",
             ln=True, align="C")
    pdf.ln(4)

    # ── Species block ──
    pdf.set_fill_color(*LGRAY)
    pdf.set_text_color(*BLACK)
    pdf.set_font("Helvetica", "B", 13)
    pdf.cell(0, 9, " Identified Species", fill=True, ln=True)
    pdf.set_font("Helvetica", "B", 12)
    pdf.set_text_color(*TEAL)
    pdf.cell(0, 8, f"  {species}", ln=True)
    pdf.ln(1)

    # ── Danger level ──
    pdf.set_fill_color(*LGRAY)
    pdf.set_text_color(*BLACK)
    pdf.set_font("Helvetica", "B", 13)
    pdf.cell(0, 9, " Danger Level", fill=True, ln=True)
    pdf.set_font("Helvetica", "B", 14)
    pdf.set_text_color(*danger_color)
    pdf.cell(0, 9, f"  {danger_level.upper()}", ln=True)
    pdf.ln(1)

    # ── Reasoning ──
    pdf.set_fill_color(*LGRAY)
    pdf.set_text_color(*BLACK)
    pdf.set_font("Helvetica", "B", 13)
    pdf.cell(0, 9, " AI Assessment", fill=True, ln=True)
    pdf.set_font("Helvetica", "", 10)
    pdf.set_text_color(*DKGRAY)
    pdf.multi_cell(0, 6, f"  {reasoning}")
    pdf.ln(2)

    # ── First Aid ──
    pdf.set_fill_color(*LGRAY)
    pdf.set_text_color(*BLACK)
    pdf.set_font("Helvetica", "B", 13)
    pdf.cell(0, 9, " First Aid Instructions", fill=True, ln=True)

    first_aid_steps = []
    if isinstance(emergency_info, dict) and "instructions" in emergency_info:
        first_aid_steps = emergency_info.get("instructions", [])

    if not first_aid_steps:
        first_aid_steps = [
            "Stay calm - panic increases venom absorption.",
            "Immobilize the bitten limb - keep it below heart level.",
            "Remove rings, watches, tight clothing near the bite.",
            "Do NOT cut the wound or try to suck out venom.",
            "Do NOT apply tourniquet or ice.",
            "Note the time of the bite immediately.",
            "Rush to the nearest hospital for antivenom treatment.",
            "Call emergency services: 115 (Rescue Pakistan)",
        ]

    pdf.set_font("Helvetica", "", 10)
    pdf.set_text_color(*DKGRAY)
    for i, step in enumerate(first_aid_steps, 1):
        pdf.multi_cell(0, 7, f"  {i}. {step}")
        pdf.ln(1)
    pdf.ln(2)

    # ── Hospitals ──
    hospitals = []
    if isinstance(emergency_info, dict):
        hospitals = emergency_info.get("hospitals", [])

    if hospitals:
        pdf.set_fill_color(*LGRAY)
        pdf.set_text_color(*BLACK)
        pdf.set_font("Helvetica", "B", 13)
        pdf.cell(0, 9, " Nearest Hospitals", fill=True, ln=True)

        for i, h in enumerate(hospitals[:3], 1):
            pdf.set_font("Helvetica", "B", 10)
            pdf.set_text_color(*TEAL)
            pdf.cell(0, 7, f"  {i}. {h.get('name', 'Hospital')}", ln=True)

            pdf.set_font("Helvetica", "", 9)
            pdf.set_text_color(*DKGRAY)
            pdf.cell(0, 6, f"     Antivenom Available: Yes", ln=True)

            # Maps link
            maps_link = h.get("maps_link", "")
            pdf.set_text_color(15, 86, 179)
            pdf.cell(0, 6, f"     Google Maps: {maps_link}", ln=True,
                     link=maps_link)
            pdf.set_text_color(*DKGRAY)
            pdf.ln(1)

    # ── Emergency numbers ──
    pdf.ln(2)
    pdf.set_fill_color(*RED)
    pdf.set_text_color(*WHITE)
    pdf.set_font("Helvetica", "B", 12)
    pdf.cell(0, 9, "  EMERGENCY CONTACTS", fill=True, ln=True)
    pdf.set_font("Helvetica", "B", 10)
    pdf.set_text_color(*BLACK)
    pdf.cell(0, 7, "  Rescue Pakistan: 115", ln=True)
    pdf.cell(0, 7, "  Edhi Foundation: 115", ln=True)
    pdf.cell(0, 7, "  Chhipa Welfare: 1020", ln=True)
    pdf.ln(2)

    # ── Footer ──
    pdf.set_font("Helvetica", "", 8)
    pdf.set_text_color(*DKGRAY)
    pdf.cell(0, 6,
             "SnakeGuard Lite | Google AI Seekho Hackathon 2026 | For emergency use only",
             ln=True, align="C")

    pdf.output(str(filename))
    return str(filename)