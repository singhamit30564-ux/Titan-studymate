# Titan-studymate
# 🎓 Titan StudyMate: AI Doubt Solver

![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)
![Streamlit](https://img.shields.io/badge/Streamlit-1.20+-red.svg)
![Gemini AI](https://img.shields.io/badge/AI-Google_Gemini_Pro-green.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

> **"Empowering the next generation of 'Type C' minds with accessible, personalized AI education."**

## 📖 About The Project
**Titan StudyMate** is a lightweight, AI-powered personal tutor designed specifically for students from Class 1 to 12. Built with the vision of making advanced learning accessible, it breaks down complex doubts into simple, step-by-step explanations in **Hinglish** (Hindi + English mix), making learning natural and engaging for Indian students.

No heavy installations, no complex setups. Just pure, focused learning.

## ✨ Features
- 🎯 **Grade & Subject Specific:** Tailored explanations based on the student's exact class (1-12) and subject.
- 🗣️ **Hinglish Support:** Explains concepts in a friendly, conversational Hinglish style, just like a real tutor.
- 🛡️ **Secure by Design:** API keys are managed securely via Streamlit Secrets, ensuring zero exposure.
- 📱 **Device Agnostic:** Optimized to run smoothly even on low-end devices and tablets (tested on mobile code editors!).
- ⚡ **Lightning Fast:** Powered by Google's Gemini Pro model for quick, accurate, and context-aware responses.

## 🛠️ Tech Stack
- **Frontend:** Streamlit
- **Backend:** Python
- **AI Engine:** Google Generative AI (Gemini Pro)

## 🚀 Getting Started

### Prerequisites
- Python 3.8 or higher
- A Google Gemini API Key (Get it free from [Google AI Studio](https://makersuite.google.com/app/apikey))

### Installation
1. Clone the repository:
```bash
   git clone https://github.com/your-username/titan-studymate.git
   cd titan-studymate
```
2. Install the required dependencies:
```bash
   pip install -r requirements.txt
```
3. Set up your API Key:
   - If running locally, create a file named `.streamlit/secrets.toml` and add:
```toml
     GOOGLE_API_KEY = "your_actual_api_key_here"
```
   - If deploying on **Streamlit Cloud**, go to *Settings > Secrets* and paste the same TOML format.

### Running the App
```bash
streamlit run app.py
```

## 💡 How to Use
1. Select your **Class** and **Subject** from the sidebar.
2. Type your doubt in the text area (e.g., *"Bhai, photosynthesis kaise hota hai?"* or *"Solve 2x + 5 = 15"*).
3. Click **"Solve Doubt 🚀"** and get an instant, easy-to-understand explanation!

## 🌍 The Vision
This project is part of a larger mission: to build an ecosystem where young learners naturally develop logical, analytical, and "Type C" thinking from an early age, without the friction of traditional, boring educational tools. 

## 🤝 Contributing
Contributions are what make the open-source community such an amazing place to learn and build. Any contributions you make are **greatly appreciated**.

## 📜 License
Distributed under the MIT License. See `LICENSE` for more information.

---
**Built with ❤️ and ☕ by Shivay Singh**  
*Founder, Titan Ecosystem*