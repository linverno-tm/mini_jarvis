# 🎙️ Jarvis - Voice Assistant Mini

**AI-powered voice assistant with Gemini integration for Android & iOS**

## ✨ Features

- 🗣️ **Voice Interaction** - Speech-to-Text & Text-to-Speech
- 🤖 **AI Chat** - Powered by Google Gemini 1.5 Flash
- 🌦️ **Weather** - Real-time weather information with location
- ⏰ **Reminders** - Set, view, and manage reminders with notifications
- 🧮 **Calculator** - Voice-activated calculations
- 🌓 **Dark/Light Mode** - Adaptive theme
- 📱 **Responsive UI** - Works on all screen sizes

## 🛠️ Tech Stack

- **Framework:** Flutter 3.x
- **State Management:** Provider
- **AI:** Google Gemini API
- **Voice:** speech_to_text, flutter_tts
- **Storage:** Hive (NoSQL)
- **Notifications:** flutter_local_notifications
- **Weather:** OpenWeatherMap API
- **Location:** Geolocator

## 📦 Installation
```bash
# Clone repository
git clone https://github.com/linverno-tm/mini_jarvis.git
cd mini_jarvis

# Install dependencies
flutter pub get

# Run code generation for Hive
flutter pub run build_runner build --delete-conflicting-outputs

# Run app
flutter run
