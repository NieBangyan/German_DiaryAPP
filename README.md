# 📓 German Diary App

A daily diary app for German learners. Write your diary in German, get AI-powered grammar corrections, and review your mistakes.

## Features

- 📅 Calendar with check-in tracking
- ✍️ Write and save diary entries
- 🤖 AI-powered grammar correction (DeepSeek API)
- 📝 Markdown support for correction results
- 🔒 Secure API key management with .env

## Tech Stack

- Flutter
- Dart
- DeepSeek API
- Hive (local storage)

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── diary_entry.dart      # Diary data model
├── screens/
│   └── home_page.dart        # Main calendar screen
├── widgets/
│   └── diary_editor.dart     # Diary writing editor
└── services/
    ├── storage_service.dart  # Hive local storage
    └── ai_service.dart       # DeepSeek API integration

```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (^3.11.5)
- Dart SDK (^3.11.5)
- A DeepSeek API key (for AI correction feature)

### Installation

1. **Clone the repository**
   ```
   git clone https://github.com/NieBangyan/German_DiaryAPP.git
   cd German_DiaryAPP
   ```

### nstall dependencies

```
flutter pub get
```

### Configure API Key

Create a .env file in the project root:
```
DEEPSEEK_API_KEY=your_deepseek_api_key_here
```
⚠️ Never commit your .env file to version control.

### Run the app
```
flutter run -d chrome
```
