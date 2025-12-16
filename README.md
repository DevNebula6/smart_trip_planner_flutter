# ✈️ Smart Trip Planner
### *Your AI-Powered Personal Travel Concierge*

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Gemini AI](https://img.shields.io/badge/Google%20Gemini-8E75B2?style=for-the-badge&logo=google%20bard&logoColor=white)
![Hive](https://img.shields.io/badge/Hive-FF6F00?style=for-the-badge&logo=hive&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green)

---

## 🚀 Download & Test

Experience the future of travel planning. Download the latest Android APK below:

[![Download APK](https://img.shields.io/badge/Download_APK-Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://drive.google.com/file/d/1AL3J5VGhaqHf7FwC6L5K4C6qHNb6rwop/view?usp=sharing)

---

## 📸 App Gallery

| **🏠 Home & Discovery** | **💬 Chat & Planning** | **📅 Itinerary Overview** |
|:---:|:---:|:---:|
| <img src="assets/screenshorts/home%20page.png" width="300" /> | <img src="assets/screenshorts/destination%20page.png" width="300" /> | <img src="assets/screenshorts/itinerary%20tab.png" width="300" /> |

| **✈️ Transport Options** | **🏨 Stays & Hotels** | **💰 Budget Analysis** |
|:---:|:---:|:---:|
| <img src="assets/screenshorts/transport%20tabpng.png" width="300" /> | <img src="assets/screenshorts/stays%20tab.png" width="300" /> | <img src="assets/screenshorts/budget%20tab.png" width="300" /> |

---

## ✨ Key Features

### 🤖 Advanced AI Agent
- **ReAct Pattern**: Uses "Reason + Act" logic to break down complex travel requests into actionable steps.
- **Context Awareness**: Remembers previous messages, user preferences, and trip details for a seamless conversation.
- **Zero Hallucination Strategy**: Uses **RAG (Retrieval Augmented Generation)** via function calling to ground responses in real-world data.

### 🛠️ Real-Time Tool Execution
The AI actively calls external APIs to fetch live data, ensuring accuracy:
- **✈️ Flights**: Real-time prices and booking links via Sky-Scrapper API.
- **🏨 Hotels**: Live availability and ratings via Booking.com API.
- **📍 Place Verification**: Validates attractions using Google Places API.
- **🌐 Web Search**: Fetches latest events, news, and local tips via Google/Bing Search.

### 📱 User Experience
- **Natural Language Chat**: No complex forms; just chat like you would with a human agent.
- **Interactive Maps**: Visualizes daily routes, hotels, and activities on OpenStreetMap.
- **Smart Budgeting**: Automatically estimates and categorizes costs (Travel vs. Stay vs. Food).
- **Offline-First**: Full functionality without internet once the trip is saved (using Hive).

---

## 🏗️ Architecture Overview

This project implements a **Hybrid Clean Architecture** designed for scalability and testability.

### Layered Structure
```
┌─────────────────────────────────────────────┐
│              PRESENTATION LAYER             │
│   (BLoC, Pages, Widgets, UI States)         │
│   • Handles user input & UI rendering       │
│   • Manages state (Loading, Success, Error) │
└──────────────────────┬──────────────────────┘
                       │
┌──────────────────────▼──────────────────────┐
│                 DOMAIN LAYER                │
│   (Entities, Use Cases, Repositories)       │
│   • Pure Dart business logic                │
│   • Defines abstract contracts (Interfaces) │
└──────────────────────┬──────────────────────┘
                       │
┌──────────────────────▼──────────────────────┐
│                  DATA LAYER                 │
│   (Data Sources, Models, Hive, APIs)        │
│   • Implements repositories                 │
│   • Handles API calls & Local DB            │
└─────────────────────────────────────────────┘
```

### Tech Stack & Libraries
- **Framework**: Flutter 3.x & Dart 3.7+
- **State Management**: `flutter_bloc` (Predictable state management)
- **AI Integration**: `google_generative_ai` (Gemini 2.5 Flash)
- **Local Storage**: `hive` & `hive_flutter` (Fast NoSQL DB)
- **Maps**: `flutter_map` & `latlong2` (OpenStreetMap integration)
- **Networking**: `http` & `dio` (API requests)
- **Dependency Injection**: `get_it` (Service locator)

---

## 🧠 How the AI Agent Works

The app uses a sophisticated **Agent Chain** to generate itineraries:

1.  **User Intent**: The user asks, "Plan a trip to Paris for 5 days."
2.  **Reasoning**: The AI analyzes the request and determines missing info (dates, budget) or required data (flights, hotels).
3.  **Tool Execution (Function Calling)**:
    - Calls `searchFlights(origin, dest, date)`
    - Calls `searchHotels(dest, date)`
    - Calls `searchPlaces(query)` to verify attractions.
4.  **Synthesis**: The AI combines API results into a structured JSON itinerary.
5.  **Rendering**: The app parses the JSON and renders interactive widgets (Itinerary Card, Map, Budget).

### Specializations
- **Token Optimization**: Efficiently manages context window to reduce API costs.
- **Error Recovery**: Automatically retries malformed JSON responses from the AI.
- **Session Persistence**: Saves chat history and state to Hive, allowing users to resume planning days later.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK
- API Keys: Google Gemini, RapidAPI (Sky-Scrapper, Booking.com), Google Places (Optional).

### Installation

1.  **Clone the repository**
    ```bash
    git clone https://github.com/DevNebula6/smart_trip_planner_flutter.git
    ```

2.  **Install dependencies**
    ```bash
    flutter pub get
    ```

3.  **Configure Environment**
    Create a `.env` file in the root:
    ```env
    GEMINI_API_KEY=your_gemini_key
    RAPID_API_KEY=your_rapid_api_key
    GOOGLE_PLACES_API_KEY=your_places_key
    ```

4.  **Run the app**
    ```bash
    flutter run
    ```

---

## 📚 Documentation

For detailed technical information, refer to the documentation files:

- **[Feature Documentation](FEATURE_DOCUMENTATION.md)**: Detailed breakdown of features.
- **[AI Agent Architecture](AI_AGENT_ARCHITECTURE.md)**: Deep dive into the AI logic and tools.
- **[API Integration](API_INTEGRATION_DOCUMENTATION.md)**: Details on external APIs used.
- **[Project Diagrams](PROJECT_DIAGRAMS.md)**: UML and Architecture diagrams.

---

## 🧪 Testing

The project maintains high code quality with comprehensive tests:

```bash
flutter test
```

---

**Developed by [Your Name]**
