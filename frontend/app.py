import streamlit as st
import requests
import os

st.set_page_config(page_title="SnakeGuard AI", layout="wide")

st.title("🐍 SnakeGuard AI Emergency System")

# -----------------------
# CITY SELECT (FIXED)
# -----------------------
city = st.selectbox("Select City", ["Karachi", "Lahore", "Islamabad"])

# -----------------------
# FILE UPLOAD
# -----------------------
file = st.file_uploader("Upload Snake Image", type=["jpg", "jpeg", "png"])

if st.button("Analyze Snake"):

    if file:

        # send file to backend
        files = {
            "file": (file.name, file.getvalue(), file.type)
        }

        response = requests.post(
            "http://127.0.0.1:8000/analyze",
            files=files,
            data={"city": city}
        )

        st.write("### Result Status:", response.status_code)

        if response.status_code == 200:

            data = response.json()

            st.success("Analysis Complete ✅")

            # -----------------------
            # ANALYSIS SECTION
            # -----------------------
            st.subheader("🐍 Snake Analysis")

            analysis = data["assessment"]["analysis"]

            st.write("**Species:**", analysis["species"])
            st.write("**Danger Level:**", analysis["danger_level"])
            st.write("**Reason:**", analysis["reasoning"])

            # -----------------------
            # HOSPITAL CARDS
            # -----------------------
            st.subheader("🏥 Nearby Hospitals")

            hospitals = data["assessment"]["emergency_info"]["hospitals"]

            cols = st.columns(3)

            for i, h in enumerate(hospitals):
                with cols[i % 3]:
                    st.markdown(f"""
                    ### 🏥 {h['name']}
                    """)
                    st.write("🩺 Anti-venom:", "Available" if h["anti_venom_available"] else "Not Available")

                    st.link_button("📍 Open in Maps", h["maps_link"])

            # -----------------------
            # EMERGENCY INSTRUCTIONS
            # -----------------------
            st.subheader("🚨 Emergency Instructions")

            st.warning(data["assessment"]["emergency_info"]["instructions"])

            # -----------------------
            # PDF DOWNLOAD FIX
            # -----------------------
            st.subheader("📄 Emergency PDF")

            try:
                pdf_path = data["logs"][-2]["data"]["pdf_path"]
                full_path = os.path.join("..", "SnakeGuard_Agent", pdf_path)

                if os.path.exists(full_path):
                    with open(full_path, "rb") as f:
                        st.download_button(
                            label="📄 Download Emergency PDF",
                            data=f,
                            file_name="SnakeGuard_Emergency.pdf",
                            mime="application/pdf"
                        )
                else:
                    st.error("PDF file not found")

            except:
                st.error("PDF path error")

            # -----------------------
            # TRACE LOGS
            # -----------------------
            st.subheader("📊 Agent Trace Logs")

            for log in data["logs"]:
                st.write(f"**{log['step']}** → {log['message']}")

        else:
            st.error("Backend Error")
            st.write(response.text)

    else:
        st.warning("Please upload an image first")