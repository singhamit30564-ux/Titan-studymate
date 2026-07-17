import streamlit as st
import google.generativeai as genai

# Page Setup
st.set_page_config(page_title="Titan StudyMate AI", page_icon="🎓", layout="wide")
st.title("🎓 Titan StudyMate: AI Doubt Solver")
st.markdown("Class 1-12 ke liye tera personal AI Teacher! 🚀")

# API Key Load (Secrets se)
# Note: Streamlit Cloud mein Secrets mein 'GOOGLE_API_KEY' add karna mat bhoolna!
try:
    api_key = st.secrets["GOOGLE_API_KEY"]
    genai.configure(api_key=api_key)
except KeyError:
    st.error("⚠️ API Key missing! Please add GOOGLE_API_KEY in Streamlit Secrets.")
    st.stop()

# Sidebar Settings
st.sidebar.header("⚙️ Student Settings")
grade = st.sidebar.selectbox("Select Class:", [f"Class {i}" for i in range(1, 13)])
subject = st.sidebar.selectbox("Select Subject:", ["Maths", "Science", "Physics", "Chemistry", "Biology", "General"])

# Main Chat Area
st.subheader("🤔 Apna Doubt Poocho!")
user_input = st.text_area("Yahan apna question likho:", height=150, 
                          placeholder="e.g., Newton's third law kya hai? ya 2x + 5 = 15 solve karo.")

if st.button("Solve Doubt 🚀", use_container_width=True):
    if user_input.strip():
        with st.spinner("AI soch raha hai... thoda wait karo..."):
            try:
                # Gemini Model Setup
                model = genai.GenerativeModel('gemini-pro')
                
                # Smart Prompt (Hinglish mein simple explanation ke liye)
                prompt = f"""You are a friendly, encouraging, and expert teacher for a {grade} student. 
                The subject is {subject}. 
                Explain the following doubt clearly, simply, and step-by-step in Hinglish (Hindi + English mix) 
                so a young student can easily understand. Use real-life examples. Keep it under 300 words.
                
                Student's Doubt: {user_input}"""
                
                response = model.generate_content(prompt)
                
                st.success("✅ Here is your answer:")
                st.markdown(response.text)
                
            except Exception as e:
                st.error(f"Oops! Kuch gadbad ho gayi: {e}")
    else:
        st.warning("⚠️ Pehle question toh likho bhai!")

# Footer
st.markdown("---")
st.markdown("© 2026 Titan StudyMate | Powered by Gemini AI 🧠 | Founded by Shivay Singh")