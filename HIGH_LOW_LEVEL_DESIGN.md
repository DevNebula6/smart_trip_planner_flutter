# Smart Trip Planner - High Level & Low Level Design Document

## 📋 Table of Contents
1. [High-Level Design (HLD)](#high-level-design-hld)
2. [Low-Level Design (LLD)](#low-level-design-lld)
3. [System Architecture Diagrams](#system-architecture-diagrams)
4. [Database Design](#database-design)
5. [API Design](#api-design)
6. [Security Architecture](#security-architecture)
7. [Performance Architecture](#performance-architecture)

---

# 📊 High-Level Design (HLD)

## 1. System Overview

The Smart Trip Planner is a mobile-first AI-powered travel application built using Flutter with Clean Architecture principles. It provides intelligent trip planning through natural language processing and maintains offline-first functionality.

### 1.1 System Goals
- **Primary Goal**: Generate personalized travel itineraries using AI
- **Secondary Goals**: Offline access, real-time chat, cost optimization
- **Non-Functional Goals**: 60%+ test coverage, <2s response time, 90-day data retention

### 1.2 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      PRESENTATION TIER                         │
├─────────────────────────────────────────────────────────────────┤
│  Flutter UI │ BLoC State Management │ Navigation │ Widgets     │
└─────────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────────┐
│                       BUSINESS TIER                            │
├─────────────────────────────────────────────────────────────────┤
│  Use Cases │ Domain Entities │ Repository Interfaces │ Rules   │
└─────────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────────┐
│                        DATA TIER                               │
├─────────────────────────────────────────────────────────────────┤
│  Hive Storage │ AI Services │ Web APIs │ Models │ Data Sources │
└─────────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────────┐
│                    EXTERNAL SERVICES                           │
├─────────────────────────────────────────────────────────────────┤
│  Google Gemini AI │ Google Search │ Bing Search │ Google Maps  │
└─────────────────────────────────────────────────────────────────┘
```

## 2. Component Architecture

### 2.1 Feature-Based Modules

```
smart_trip_planner_flutter/
├── auth/                    # Authentication & User Management
├── trip_planning_chat/      # Core Trip Planning & Chat
├── ai_agent/               # AI Integration Services
├── core/                   # Shared Core Components
├── shared/                 # Cross-Feature Shared Components
└── utilities/              # Helper Functions & Widgets
```

### 2.2 System Context Diagram

```
    [User Mobile Device]
           │
    ┌─────────────────┐
    │  Flutter App    │
    │                 │
    │  ┌─────────────┐│
    │  │ Presentation││
    │  │   Layer     ││
    │  └─────────────┘│
    │  ┌─────────────┐│
    │  │ Business    ││
    │  │   Layer     ││
    │  └─────────────┘│
    │  ┌─────────────┐│
    │  │ Data Layer  ││
    │  └─────────────┘│
    └─────────────────┘
           │
    ┌─────────────────┐
    │ External APIs   │
    │ • Gemini AI     │
    │ • Google Search │
    │ • Bing Search   │
    │ • Google Maps   │
    └─────────────────┘
```

## 3. Data Flow Architecture

### 3.1 Trip Planning Flow

```
User Input → ChatBloc → AIAgentService → GeminiService
                                              │
                                        Web Search APIs
                                              │
Hive Storage ← ItineraryModel ← JSON Parsing ←┘
     │
UI Update ← ChatBloc State Change
```

### 3.2 Session Management Flow

```
App Launch → AuthBloc → Session Check → Hive Storage
                                             │
                                    Restore Sessions
                                             │
HomePage Display ← SessionState ← Session Conversion
```

---

# 🔧 Low-Level Design (LLD)

## 1. Detailed Component Design

### 1.1 BLoC State Management Pattern

#### **ChatBloc Implementation**

```dart
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final AIAgentService _aiService;
  final HiveStorageService _storageService;
  
  // Internal State
  SessionState? _currentSession;
  List<ChatMessageModel> _messages = [];
  ItineraryModel? _currentItinerary;

  // Event Handlers
  Future<void> _onInitializeChatWithPrompt(
    InitializeChatWithPrompt event,
    Emitter<ChatState> emit,
  ) async {
    // 1. Create new session
    // 2. Initialize conversation context
    // 3. Call AI service for initial response
    // 4. Parse and validate itinerary
    // 5. Save to storage
    // 6. Emit updated state
  }
}
```

**State Transitions:**
```
ChatInitial → ChatLoading → ChatInitialized
                   ↓
ChatMessageSending → ChatMessageReceived → ChatItineraryGenerated
                   ↓
              ChatSessionSaved
```

### 1.2 Storage Layer Design

#### **Hive Storage Service Architecture**

```dart
class HiveStorageService {
  // Singleton Pattern
  static HiveStorageService? _instance;
  
  // Storage Boxes
  Box<HiveSessionState>? _sessionsBox;
  Box<HiveItineraryModel>? _itinerariesBox;
  Box<HiveChatMessageModel>? _messagesBox;
  Box<Map>? _metadataBox;

  // Core Operations
  Future<void> saveSession(SessionState session);
  Future<SessionState?> getSession(String sessionId);
  Future<List<SessionState>> getUserSessions(String userId);
  Future<void> deleteSession(String sessionId);
}
```

**Storage Strategy:**
- **Sessions Box**: Primary session data with 90-day TTL
- **Itineraries Box**: Structured itinerary data for fast retrieval
- **Messages Box**: Individual chat messages for conversation history
- **Metadata Box**: App configuration and user preferences

### 1.3 AI Service Layer Design

#### **Service Interface & Implementation**

```dart
abstract class AIAgentService {
  Future<ItineraryModel> generateItinerary({
    required String userPrompt,
    String? userId,
    String? sessionId,
  });

  Stream<String> streamItineraryGeneration({
    required String userPrompt,
    String? userId,
    String? sessionId,
  });
}

class GeminiService implements AIAgentService {
  final GenerativeModel _model;
  final WebSearchService _webSearch;
  final TokenTrackingService _tokenTracking;

  @override
  Future<ItineraryModel> generateItinerary({
    required String userPrompt,
    String? userId,
    String? sessionId,
  }) async {
    // 1. Prepare conversation context
    // 2. Enhance with web search data
    // 3. Call Gemini API with function calling
    // 4. Parse structured JSON response
    // 5. Validate against schema
    // 6. Track token usage
    // 7. Return ItineraryModel
  }
}
```

## 2. Database Schema Design

### 2.1 Hive Data Models

#### **HiveSessionState Model**
```dart
@HiveType(typeId: 0)
class HiveSessionState extends HiveObject {
  @HiveField(0) String sessionId;
  @HiveField(1) String userId;
  @HiveField(2) DateTime createdAt;
  @HiveField(3) DateTime lastUsed;
  @HiveField(4) List<HiveContent> conversationHistory;
  @HiveField(5) Map<String, dynamic> userPreferences;
  @HiveField(6) Map<String, dynamic> tripContext;
  @HiveField(7) int tokensSaved;
  @HiveField(8) int messagesInSession;
  @HiveField(9) double estimatedCostSavings;
  @HiveField(10) int refinementCount;
  @HiveField(11) bool isActive;
}
```

#### **Data Relationships**
```
HiveSessionState (1) ←→ (N) HiveChatMessageModel
      │
      └── Contains: conversationHistory, tripContext, userPreferences
      
HiveItineraryModel (1) ←→ (1) HiveSessionState
      │
      └── Contains: title, startDate, endDate, days[]
```

## 3. API Design

### 3.1 Gemini AI Integration

#### **Function Calling Schema**
```json
{
  "name": "search_web_for_travel_info",
  "description": "Search for real-time travel information",
  "parameters": {
    "type": "object",
    "properties": {
      "query": {
        "type": "string",
        "description": "Search query for travel information"
      },
      "location": {
        "type": "string",
        "description": "Location context for search"
      }
    },
    "required": ["query"]
  }
}
```

#### **Response Schema Validation**
```dart
class ItineraryValidator {
  static bool validateSchema(Map<String, dynamic> json) {
    return json.containsKey('title') &&
           json.containsKey('startDate') &&
           json.containsKey('endDate') &&
           json.containsKey('days') &&
           json['days'] is List;
  }
}
```

### 3.2 Web Search Integration

#### **Multi-Provider Search Strategy**
```dart
class WebSearchService {
  final GoogleSearchService _googleSearch;
  final BingSearchService _bingSearch;

  Future<List<SearchResult>> enhancedSearch({
    required String query,
    String? location,
  }) async {
    // 1. Try Google Search first
    // 2. Fallback to Bing if Google fails
    // 3. Combine and deduplicate results
    // 4. Return formatted search data
  }
}
```

## 4. Security Architecture

### 4.1 API Key Management

```dart
// Environment-based configuration
class ApiConfig {
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static String get googleSearchApiKey => dotenv.env['GOOGLE_SEARCH_API_KEY'] ?? '';
  static String get bingSearchApiKey => dotenv.env['BING_SEARCH_API_KEY'] ?? '';
}
```

### 4.2 Data Security Measures

- **Local Encryption**: Hive storage with optional encryption
- **API Key Protection**: Environment variables, not committed to repository
- **Session Security**: UUID-based session identifiers
- **Data Sanitization**: Input validation and output sanitization

## 5. Error Handling Architecture

### 5.1 Exception Hierarchy

```dart
abstract class AppException implements Exception {
  final String message;
  final String? code;
  const AppException(this.message, [this.code]);
}

class NetworkException extends AppException {
  const NetworkException(String message, [String? code]) : super(message, code);
}

class AIServiceException extends AppException {
  const AIServiceException(String message, [String? code]) : super(message, code);
}

class StorageException extends AppException {
  const StorageException(String message, [String? code]) : super(message, code);
}
```

### 5.2 Error Recovery Strategies

```dart
class ErrorRecoveryService {
  static Future<T> withRetry<T>({
    required Future<T> Function() operation,
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    // Exponential backoff retry logic
    // Network error detection
    // Graceful degradation
  }
}
```

## 6. Performance Architecture

### 6.1 Memory Management

```dart
class MemoryOptimizationService {
  // Lazy loading for Hive boxes
  // Pagination for chat history
  // Efficient widget rebuilds
  // Garbage collection optimization
}
```

### 6.2 Caching Strategy

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Memory Cache  │───►│   Hive Storage  │───►│  External APIs  │
│   (Runtime)     │    │   (Persistent)  │    │   (Network)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
     Fast Access          Offline Access        Real-time Data
```

## 7. Testing Architecture

### 7.1 Test Strategy Pyramid

```
                  ┌──────────────┐
                  │ Integration  │ ← End-to-end user flows
                  │    Tests     │
                  └──────────────┘
              ┌──────────────────────┐
              │    Widget Tests      │ ← UI component testing
              └──────────────────────┘
          ┌──────────────────────────────┐
          │        Unit Tests           │ ← Business logic testing
          └──────────────────────────────┘
```

### 7.2 Mock Strategy

```dart
class MockAIAgentService extends Mock implements AIAgentService {
  @override
  Future<ItineraryModel> generateItinerary({
    required String userPrompt,
    String? userId,
    String? sessionId,
  }) async {
    return ItineraryModel.fromJson(mockItineraryJson);
  }
}
```

## 8. Deployment Architecture

### 8.1 Build Configuration

```yaml
# pubspec.yaml - Production Configuration
environment:
  sdk: ^3.7.2

# Development vs Production builds
flutter build apk --release --dart-define=ENVIRONMENT=production
flutter build ios --release --dart-define=ENVIRONMENT=production
```

### 8.2 CI/CD Pipeline Design

```
Code Push → GitHub Actions → 
Test Suite → Build Artifacts → 
Play Store/App Store → Release
```

---

# 📈 System Scalability & Maintenance

## Scalability Considerations

1. **Horizontal Scaling**: Feature-based architecture supports independent module scaling
2. **Data Scaling**: Hive's efficient binary format handles large datasets
3. **AI Cost Scaling**: Token optimization and caching reduce API costs
4. **Storage Scaling**: Automatic cleanup and retention policies manage data growth

## Maintenance Strategy

1. **Code Quality**: Comprehensive test coverage and static analysis
2. **Performance Monitoring**: Token usage tracking and performance metrics
3. **Error Tracking**: Comprehensive logging and error reporting
4. **Update Strategy**: Modular architecture enables incremental updates

---

This HLD/LLD document provides comprehensive architectural details for the Smart Trip Planner application, covering all aspects from high-level system design to low-level implementation details. The architecture ensures scalability, maintainability, and performance while meeting all assignment requirements.
