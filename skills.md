# 🤖 Flutter ChatBot — Skills & Architecture Documentation

> A Flutter-based AI chatbot powered by **Google Gemini 2.5 Flash Lite**, built using **GetX** for state management and **Feature-First** clean architecture.

---

## 📋 Table of Contents

1. [Project Overview](#-project-overview)
2. [Tech Stack](#-tech-stack)
3. [Architecture Pattern](#-architecture-pattern)
4. [Project Folder Structure](#-project-folder-structure)
5. [Layer-by-Layer Breakdown](#-layer-by-layer-breakdown)
6. [Data Flow](#-data-flow)
7. [Key Concepts Used](#-key-concepts-used)
8. [Dependencies](#-dependencies)
9. [Environment & Security Setup](#-environment--security-setup)
10. [How to Run](#-how-to-run)

---

## 🌟 Project Overview

| Property        | Value                              |
|-----------------|------------------------------------|
| **App Name**    | Flutter ChatBot                    |
| **Platform**    | Android, iOS, Web, Windows, Linux, macOS |
| **Language**    | Dart                               |
| **Framework**   | Flutter                            |
| **AI Model**    | Google Gemini 2.5 Flash Lite       |
| **API**         | Google Generative Language API (REST) |
| **Version**     | 1.0.0+1                            |
| **Dart SDK**    | ^3.7.2                             |

---

## 🛠 Tech Stack

| Category              | Technology                   |
|-----------------------|------------------------------|
| **UI Framework**      | Flutter (Material Design)    |
| **Language**          | Dart                         |
| **State Management**  | GetX (`get: ^4.7.2`)         |
| **HTTP Client**       | Dio (`dio: ^5.9.0`)          |
| **AI Backend**        | Google Gemini REST API       |
| **Local Storage**     | Hive (`hive: ^2.2.3`)        |
| **Markdown Rendering**| flutter_markdown             |
| **Environment Vars**  | flutter_dotenv               |
| **Linting**           | flutter_lints                |

---

## 🏗 Architecture Pattern

This project follows **Feature-First Clean Architecture**, which organizes code by **features** rather than by type. Each feature is self-contained with its own layers.

```
Feature-First Clean Architecture
│
├── core/              ← Shared constants, utilities (cross-feature)
└── features/
    └── chat/          ← One self-contained feature module
        ├── controllers/   ← Business logic (GetX Controller)
        ├── models/        ← Data models / entities
        ├── services/      ← API calls and processing logic
        ├── views/         ← UI screens (pages)
        └── widgets/       ← Reusable UI components
```

### Why Feature-First?
- ✅ Easy to scale — add new features without touching existing ones
- ✅ Each feature is independently maintainable
- ✅ Clear ownership and separation of concerns
- ✅ Works great with GetX dependency injection

---

## 📁 Project Folder Structure

```
flutter_chat_bot/
│
├── lib/
│   ├── main.dart                        # App entry point
│   │
│   ├── core/
│   │   └── constant/
│   │       └── api_constant.dart        # API key loader from .env
│   │
│   └── features/
│       └── chat/
│           ├── controllers/
│           │   └── chat_controller.dart # GetX controller (business logic)
│           │
│           ├── models/
│           │   ├── chat_message.dart        # Message data model
│           │   ├── structured_response.dart # Gemini AI response model
│           │   └── prompt_evulation.dart    # Response scoring model
│           │
│           ├── services/
│           │   ├── ai_service.dart          # Dio HTTP → Gemini API call
│           │   └── bot_engine.dart          # Prompt engineering + JSON parsing
│           │
│           ├── views/
│           │   └── chat_screen.dart         # Main chat UI screen
│           │
│           └── widgets/
│               └── stuctured_response_card.dart  # AI response UI card
│
├── .env                    # 🔒 Secret — API key (NOT committed to git)
├── .env.example            # ✅ Safe template for .env
├── .gitignore              # Excludes .env, build/, dart_tool/, etc.
├── pubspec.yaml            # Flutter dependencies
└── skills.md               # 📘 This file — architecture documentation
```

---

## 🔍 Layer-by-Layer Breakdown

### 1. 🚀 Entry Point — `main.dart`

- Initializes Flutter bindings
- Loads `.env` file using `flutter_dotenv`
- Runs `MyApp` → `MaterialApp` → `ChatScreen`

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}
```

---

### 2. 🔑 Core — `api_constant.dart`

Reads the API key **safely from the `.env` file** using `flutter_dotenv`.
The key is never hardcoded in source code.

```dart
class ApiConstants {
  static String get apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
}
```

---

### 3. 🧠 Service Layer

#### `ai_service.dart` — HTTP Client
- Uses **Dio** to make a `POST` request to Google Gemini REST API
- Sends user prompt as JSON body
- Returns the raw text response from Gemini
- Handles `DioException` with detailed error info

**Gemini Endpoint used:**
```
POST https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=API_KEY
```

#### `bot_engine.dart` — Prompt Engineering + Parsing
- Wraps the user input in a **structured system prompt** that forces Gemini to return **valid JSON only**
- Parses the JSON response into a `StructuredResponse` object
- Strips any markdown code blocks Gemini might add (`` ```json ``)
- Also has an `evaluateResponse()` method that **scores** the quality of the AI response (0–10 points)

**JSON format requested from Gemini:**
```json
{
  "title": "",
  "summary": "",
  "category": "",
  "keywords": []
}
```

---

### 4. 📦 Model Layer

| Model | Purpose |
|---|---|
| `ChatMessage` | Stores one message (text, sender, timestamp, optional structured response) |
| `StructuredResponse` | Parsed AI response with title, summary, category, and keywords |
| `PromptEvaluation` | Quality score (0–10) and feedback text for each AI response |

---

### 5. 🎮 Controller Layer — `chat_controller.dart`

Uses **GetX `GetxController`** for reactive state management.

| Observable | Type | Purpose |
|---|---|---|
| `messages` | `RxList<ChatMessage>` | All chat messages (user + bot) |
| `isLoading` | `RxBool` | Shows loading indicator while waiting for AI |
| `lastEvaluation` | `RxString` | Stores the quality score of the last AI response |

**`sendMessage()` flow:**
1. Reads text from `TextEditingController`
2. Adds user message to `messages` list
3. Calls `BotEngine.generateStructuredResponse()`
4. Evaluates the response with `BotEngine.evaluateResponse()`
5. Adds bot message (with `StructuredResponse`) to `messages`
6. Handles errors gracefully

---

### 6. 🖼 View Layer — `chat_screen.dart`

- A `StatelessWidget` (state managed entirely by GetX)
- Registers `ChatController` using `Get.put()`
- Uses `Obx()` to **reactively rebuild** the message list
- Messages are aligned:
  - User messages → **right** (blue bubble)
  - Bot messages → **left** (grey or structured card)

---

### 7. 🃏 Widget — `StructuredResponseCard`

A custom card widget that displays the AI's structured response:

| Field | Display |
|---|---|
| `title` | Bold heading (fontSize 18) |
| `category` | Blue colored text label |
| `summary` | Body text paragraph |
| `keywords` | Flutter `Chip` widgets in a `Wrap` layout |

---

## 🔄 Data Flow

```
User types message
        │
        ▼
ChatController.sendMessage()
        │
        ▼
BotEngine.generateStructuredResponse(input)
        │
        ▼
AiService.askGemini(systemPrompt)
        │       HTTP POST via Dio
        ▼
Google Gemini API
(gemini-2.5-flash-lite)
        │
        ▼
Raw JSON text response
        │
        ▼
BotEngine parses JSON → StructuredResponse
        │
        ▼
BotEngine.evaluateResponse() → PromptEvaluation (score 0–10)
        │
        ▼
ChatController adds ChatMessage to messages list
        │
        ▼
Obx() rebuilds UI → StructuredResponseCard shown
```

---

## 💡 Key Concepts Used

| Concept | Implementation |
|---|---|
| **Reactive State Management** | GetX `Rx` observables + `Obx()` widgets |
| **Dependency Injection** | `Get.put()` to register & access controllers |
| **REST API Integration** | Dio HTTP client with POST requests |
| **Prompt Engineering** | System prompts that force structured JSON output from Gemini |
| **JSON Parsing** | `dart:convert` `jsonDecode()` with null-safety |
| **Environment Variables** | `flutter_dotenv` loads `.env` at runtime |
| **Error Handling** | try/catch on both `AiService` and `BotEngine` layers |
| **Response Scoring** | Custom `PromptEvaluation` logic scores AI quality 0–10 |
| **Feature-First Architecture** | Code organized by feature, not by type |
| **Clean Separation** | Views know nothing about API; services know nothing about UI |

---

## 📦 Dependencies

### Production Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter` | SDK | Core framework |
| `get` | ^4.7.2 | State management + DI + navigation |
| `dio` | ^5.9.0 | HTTP client for Gemini API calls |
| `hive` | ^2.2.3 | Local NoSQL database (future chat history) |
| `hive_flutter` | ^1.1.0 | Hive Flutter integration |
| `flutter_markdown` | ^0.7.7+1 | Render markdown text in chat |
| `flutter_dotenv` | ^5.2.1 | Load `.env` variables securely |
| `cupertino_icons` | ^1.0.8 | iOS-style icons |

### Dev Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter_test` | SDK | Unit & widget testing |
| `flutter_lints` | ^5.0.0 | Code quality linting rules |

---

## 🔒 Environment & Security Setup

### Problem Solved
GitHub's **Secret Scanning** blocked pushes because the API key was:
- Hardcoded in `api_constant.dart` (old commit)
- Committed inside `.env` file (not gitignored)

### Solution Applied
1. **`.env` added to `.gitignore`** — never committed again
2. **API key loaded via `flutter_dotenv`** — not hardcoded
3. **Clean git history** — orphan branch with no secrets in any commit
4. **`.env.example`** provided as a safe template

### Setup for New Developers
```bash
# 1. Clone the repo
git clone https://github.com/i53Excelsior/flutter_chat_bot.git

# 2. Copy the example env file
cp .env.example .env

# 3. Add your Gemini API key to .env
# GEMINI_API_KEY=your_actual_key_here

# 4. Install dependencies
flutter pub get

# 5. Run the app
flutter run
```

---

## ▶️ How to Run

```bash
# Install dependencies
flutter pub get

# Run on connected device / emulator
flutter run

# Run on specific platform
flutter run -d android
flutter run -d ios
flutter run -d windows
flutter run -d chrome
```

> **Note:** Make sure your `.env` file exists with a valid `GEMINI_API_KEY` before running.

---

## 📊 Platforms Supported

| Platform | Status |
|---|---|
| Android | ✅ Supported |
| iOS | ✅ Supported |
| Web | ✅ Supported |
| Windows | ✅ Supported |
| macOS | ✅ Supported |
| Linux | ✅ Supported |

---

*Generated for `flutter_chat_bot` — June 2026*
