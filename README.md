🐍 SnakeGuard Agent
📁 Project Structure
SnakeGuard_Agent/
frontend/
main.py
agent.py
tools.py
logger.py
⚙️ How to Run
1️⃣ Install Requirements
pip install -r requirements.txt
2️⃣ Run Backend
cd SnakeGuard_Agent
uvicorn main:app --reload
3️⃣ Run Frontend
cd frontend
streamlit run app.py
🔑 Environment Variables

Create a .env file:

GEMINI_API_KEY=your_api_key_here
📸 System Flow
Upload snake image
AI identifies snake species
System checks danger level
If critical → hospitals + emergency instructions
Generates PDF report
🏥 Emergency Features
Real-time hospital suggestions
Google Maps links
Anti-venom availability info
👨‍💻 Developer

Built by AI Hackathon Team
