import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:smart_trip_planner_flutter/ai_agent/services/ai_agent_service.dart';
import 'package:smart_trip_planner_flutter/core/errors/failures.dart';
import 'package:smart_trip_planner_flutter/core/storage/hive_storage_service.dart';
import 'package:smart_trip_planner_flutter/core/storage/hive_models.dart';
import 'package:smart_trip_planner_flutter/ai_agent/models/trip_session_model.dart';
import 'package:smart_trip_planner_flutter/trip_planning_chat/data/models/itinerary_models.dart';
import 'dart:async';
import 'dart:convert';
import '../../core/utils/helpers.dart';


/// **Gemini Service**
class GeminiAIService implements AIAgentService {
  final GenerativeModel _baseModel;
  final TokenUsageStats _tokenUsage = TokenUsageStats();
  final HiveStorageService _storage = HiveStorageService.instance;
  
  // Session management (AI Companion patterns)
  final Map<String, ChatSession> _geminiSessions = {};
  final Map<String, DateTime> _sessionLastUsed = {};
  
  // Debounced saving (AI Companion pattern) - enhanced with Hive
  Timer? _saveDebounceTimer;
  final Set<String> _pendingSaves = {};
  static const Duration _saveDebounceDelay = Duration(milliseconds: 300); // Faster debounce with Hive

  GeminiAIService({required String apiKey})
      : _baseModel = GenerativeModel(
          model: 'gemini-2.0-flash-exp',
          apiKey: apiKey,
          generationConfig: GenerationConfig(
            temperature: 0.7,
            topK: 40,
            topP: 0.95,
            maxOutputTokens: 2048,
          ),
        ) {
    _initStorage();
  }

  Future<void> _initStorage() async {
    try {
      await _storage.initialize();
      Logger.d('Hive storage initialized for AI service', tag: 'HiveGeminiAI');
    } catch (e) {
      Logger.e('Failed to initialize Hive storage: $e', tag: 'HiveGeminiAI');
      throw AIAgentException('Storage initialization failed: $e');
    }
  }

  @override
  Future<ItineraryModel> generateItinerary({
    required String userPrompt,
    String? userId,
    String? sessionId,
  }) async {
    Logger.d('Generating itinerary with Hive session persistence', tag: 'HiveGeminiAI');
    
    try {
      final activeSessionId = sessionId ?? await getOrCreateSession(userId: userId ?? 'anonymous');
      final sessionState = await getSession(activeSessionId);
      
      if (sessionState == null) {
        throw AIAgentException('Could not create or retrieve session');
      }

      // Convert SessionState to HiveSessionState for storage
      final hiveSession = await _getOrCreateHiveSession(sessionState, activeSessionId);

      // Extract context
      hiveSession.extractUserPreferences(userPrompt);
      hiveSession.extractTripContext(userPrompt);
      
      // Build prompt with context
      final systemPrompt = _buildSystemPrompt();
      final contextPrompt = hiveSession.buildRefinementContext();
      final fullPrompt = '''
$systemPrompt

$contextPrompt

User Request: $userPrompt

IMPORTANT: Create a complete trip plan based on the user's request and preferences above.
''';

      // Get Gemini chat session
      final chatSession = await _getOrCreateGeminiSession(hiveSession);
      final response = await chatSession.sendMessage(Content.text(fullPrompt))
          .timeout(const Duration(seconds: 15), onTimeout: () {
        throw TimeoutException('AI response timed out');
      });

      // Parse response
      final itineraryJson = _extractItineraryFromResponse(response.text ?? '');
      if (!validateItinerarySchema(itineraryJson)) {
        throw Exception('Generated itinerary does not match required schema');
      }

      final itinerary = ItineraryModel.fromJson(itineraryJson);

      // Update session
      final tokensUsed = _estimateTokens(fullPrompt) + _estimateTokens(response.text ?? '');
      hiveSession.updateConversation(
        userMessage: Content.text(userPrompt),
        aiResponse: Content.model([TextPart(response.text ?? '')]),
        tokensUsed: tokensUsed,
        tokensSavedFromReuse: 0,
      );

      // Track usage
      _tokenUsage.addUsage(
        promptTokens: _estimateTokens(fullPrompt),
        completionTokens: _estimateTokens(response.text ?? ''),
      );

      // Save session to Hive (debounced)
      _debouncedSaveSession(hiveSession);

      // Save itinerary to Hive
      final hiveItinerary = _convertToHiveItinerary(itinerary);
      await _storage.saveItinerary(hiveItinerary);

      return itinerary;
      
    } catch (e) {
      Logger.e('Failed to generate itinerary: $e', tag: 'HiveGeminiAI');
      throw AIAgentException('Failed to generate itinerary: $e');
    }
  }

  @override
  Future<ItineraryModel> refineItinerary({
    required String userPrompt,
    required String sessionId,
    String? userId,
  }) async {
    Logger.d('Refining itinerary using Hive session: $sessionId', tag: 'HiveGeminiAI');
    
    try {
      final sessionState = await getSession(sessionId);
      if (sessionState == null) {
        throw AIAgentException('Session not found: $sessionId');
      }

      final hiveSession = await _storage.getSession(sessionId);
      if (hiveSession == null || !hiveSession.isValid) {
        throw AIAgentException('Session has expired, please start a new trip');
      }

      hiveSession.extractUserPreferences(userPrompt);
      hiveSession.markRefinement();

      // Use existing Gemini session for efficiency
      final chatSession = await _getOrCreateGeminiSession(hiveSession);
      final response = await chatSession.sendMessage(Content.text(userPrompt))
          .timeout(const Duration(seconds: 15), onTimeout: () {
        throw TimeoutException('AI response timed out');
      });

      // Calculate savings
      final tokensUsed = _estimateTokens(userPrompt) + _estimateTokens(response.text ?? '');
      final tokensSaved = _calculateTokensSaved(hiveSession);

      // Parse refined itinerary
      final refinedJson = _extractItineraryFromResponse(response.text ?? '');
      final refinedItinerary = ItineraryModel.fromJson(refinedJson);

      // Update session
      hiveSession.updateConversation(
        userMessage: Content.text(userPrompt),
        aiResponse: Content.model([TextPart(response.text ?? '')]),
        tokensUsed: tokensUsed,
        tokensSavedFromReuse: tokensSaved,
      );

      // Track usage with savings
      _tokenUsage.addUsage(
        promptTokens: _estimateTokens(userPrompt),
        completionTokens: _estimateTokens(response.text ?? ''),
        tokensSaved: tokensSaved,
      );

      // Save session to Hive
      _debouncedSaveSession(hiveSession);

      Logger.d('Successfully refined itinerary, saved $tokensSaved tokens', tag: 'HiveGeminiAI');
      return refinedItinerary;
      
    } catch (e) {
      Logger.e('Failed to refine itinerary: $e', tag: 'HiveGeminiAI');
      throw AIAgentException('Failed to refine itinerary: $e');
    }
  }

  @override
  Stream<String> streamItineraryGeneration({
    required String userPrompt,
    String? userId,
    String? sessionId,
  }) async* {
    try {
      final activeSessionId = sessionId ?? await getOrCreateSession(userId: userId ?? 'anonymous');
      final hiveSession = await _storage.getSession(activeSessionId);
      
      if (hiveSession == null) {
        yield 'Error: Could not create session';
        return;
      }

      final systemPrompt = _buildSystemPrompt();
      final contextPrompt = hiveSession.buildRefinementContext();
      final fullPrompt = '''
$systemPrompt

$contextPrompt

User Request: $userPrompt
''';
      
      final chatSession = await _getOrCreateGeminiSession(hiveSession);
      final response = chatSession.sendMessageStream(Content.text(fullPrompt));

      await for (final chunk in response) {
        final text = chunk.text;
        if (text != null) {
          yield text;
        }
      }
    } catch (e) {
      Logger.e('Streaming error: $e', tag: 'HiveGeminiAI');
      yield 'Error: Failed to stream - $e';
    }
  }

  @override
  Future<String> getOrCreateSession({
    required String userId,
    String? existingSessionId,
  }) async {
    // Try to reuse existing session
    if (existingSessionId != null) {
      final existingSession = await _storage.getSession(existingSessionId);
      if (existingSession != null && existingSession.isValid) {
        return existingSessionId;
      }
    }

    // Look for reusable sessions
    final reusableSession = await _findReusableSession(userId);
    if (reusableSession != null) {
      return reusableSession.sessionId;
    }

    // Create new session
    final newSession = HiveSessionState.create(userId);
    await _storage.saveSession(newSession);
    
    Logger.d('Created new Hive session: ${newSession.sessionId}', tag: 'HiveGeminiAI');
    return newSession.sessionId;
  }

  @override
  Future<SessionState?> getSession(String sessionId) async {
    try {
      final hiveSession = await _storage.getSession(sessionId);
      if (hiveSession != null) {
        return _convertToSessionState(hiveSession);
      }
    } catch (e) {
      Logger.e('Failed to load session: $e', tag: 'HiveGeminiAI');
    }
    return null;
  }

  @override
  Future<void> clearSession(String sessionId) async {
    await _storage.deleteSession(sessionId);
    _geminiSessions.remove(sessionId);
    _sessionLastUsed.remove(sessionId);
    
    Logger.d('Cleared Hive session: $sessionId', tag: 'HiveGeminiAI');
  }

  @override
  Future<Map<String, dynamic>> getSessionMetrics(String userId) async {
    try {
      final sessions = await _storage.getUserSessions(userId);
      
      final activeSessions = sessions.where((s) => s.isValid).length;
      final totalTokensSaved = sessions.fold<int>(0, (sum, s) => sum + s.tokensSaved);
      final totalCostSavings = sessions.fold<double>(0.0, (sum, s) => sum + s.estimatedCostSavings);
      
      return {
        'total_sessions': sessions.length,
        'active_sessions': activeSessions,
        'total_tokens_saved': totalTokensSaved,
        'total_cost_savings': totalCostSavings,
        'session_reuse_rate': _calculateReuseRate(sessions),
        'storage_stats': await _storage.getStorageStats(),
      };
    } catch (e) {
      return {'error': 'Failed to load metrics: $e'};
    }
  }

  @override
  TokenUsageStats get tokenUsage => _tokenUsage;

  @override
  bool validateItinerarySchema(Map<String, dynamic> json) {
    try {
      final requiredFields = ['title', 'startDate', 'endDate', 'days'];
      for (final field in requiredFields) {
        if (!json.containsKey(field)) return false;
      }

      final days = json['days'] as List?;
      if (days == null) return false;

      for (final day in days) {
        final dayFields = ['date', 'summary', 'items'];
        for (final field in dayFields) {
          if (!day.containsKey(field)) return false;
        }

        final items = day['items'] as List?;
        if (items == null) return false;

        for (final item in items) {
          final itemFields = ['time', 'activity', 'location'];
          for (final field in itemFields) {
            if (!item.containsKey(field)) return false;
          }
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // ===== Helper Methods =====

  Future<HiveSessionState?> _findReusableSession(String userId) async {
    final sessions = await _storage.getUserSessions(userId);
    
    for (final session in sessions) {
      if (session.isValid && session.messagesInSession < 100) {
        return session;
      }
    }
    
    return null;
  }

  Future<HiveSessionState> _getOrCreateHiveSession(SessionState sessionState, String sessionId) async {
    final existing = await _storage.getSession(sessionId);
    if (existing != null) {
      return existing;
    }

    // Convert SessionState to HiveSessionState
    final hiveSession = HiveSessionState(
      sessionId: sessionState.sessionId,
      userId: sessionState.userId,
      createdAt: sessionState.createdAt,
      lastUsed: sessionState.lastUsed,
      conversationHistory: sessionState.conversationHistory
          .map((content) => HiveContentModel.fromContent(content))
          .toList(),
      userPreferences: Map<String, dynamic>.from(sessionState.userPreferences),
      tripContext: Map<String, dynamic>.from(sessionState.tripContext),
      tokensSaved: sessionState.tokensSaved,
      messagesInSession: sessionState.messagesInSession,
      estimatedCostSavings: sessionState.estimatedCostSavings,
      refinementCount: sessionState.refinementCount,
      isActive: sessionState.isActive,
    );

    await _storage.saveSession(hiveSession);
    return hiveSession;
  }

  Future<ChatSession> _getOrCreateGeminiSession(HiveSessionState session) async {
    final sessionKey = session.sessionId;
    
    if (_geminiSessions.containsKey(sessionKey)) {
      final lastUsed = _sessionLastUsed[sessionKey];
      if (lastUsed != null && DateTime.now().difference(lastUsed) < const Duration(hours: 1)) {
        return _geminiSessions[sessionKey]!;
      }
    }

    final chatSession = _baseModel.startChat(history: session.geminiConversationHistory);
    _geminiSessions[sessionKey] = chatSession;
    _sessionLastUsed[sessionKey] = DateTime.now();
    
    return chatSession;
  }

  void _debouncedSaveSession(HiveSessionState session) {
    _pendingSaves.add(session.sessionId);
    
    _saveDebounceTimer?.cancel();
    _saveDebounceTimer = Timer(_saveDebounceDelay, () async {
      await _processPendingSaves();
    });
  }

  Future<void> _processPendingSaves() async {
    if (_pendingSaves.isEmpty) return;
    
    final sessionIdsToSave = Set<String>.from(_pendingSaves);
    _pendingSaves.clear();
    
    for (final sessionId in sessionIdsToSave) {
      try {
        final session = await _storage.getSession(sessionId);
        if (session != null) {
          await _storage.saveSession(session);
        }
      } catch (e) {
        Logger.e('Failed to save session $sessionId: $e', tag: 'HiveGeminiAI');
      }
    }
  }

  int _calculateTokensSaved(HiveSessionState session) {
    // Rough estimate: session reuse saves ~90% of context tokens
    final averageContextTokens = 1000;
    return (averageContextTokens * 0.9).round();
  }

  double _calculateReuseRate(List<HiveSessionState> sessions) {
    if (sessions.isEmpty) return 0.0;
    final reusedSessions = sessions.where((s) => s.refinementCount > 0).length;
    return (reusedSessions / sessions.length) * 100;
  }

  SessionState _convertToSessionState(HiveSessionState hiveSession) {
    return SessionState(
      sessionId: hiveSession.sessionId,
      userId: hiveSession.userId,
      createdAt: hiveSession.createdAt,
      lastUsed: hiveSession.lastUsed,
      conversationHistory: hiveSession.geminiConversationHistory,
      userPreferences: Map<String, dynamic>.from(hiveSession.userPreferences),
      tripContext: Map<String, dynamic>.from(hiveSession.tripContext),
      tokensSaved: hiveSession.tokensSaved,
      messagesInSession: hiveSession.messagesInSession,
      estimatedCostSavings: hiveSession.estimatedCostSavings,
      refinementCount: hiveSession.refinementCount,
      isActive: hiveSession.isActive,
    );
  }

  HiveItineraryModel _convertToHiveItinerary(ItineraryModel itinerary) {
    return HiveItineraryModel(
      id: itinerary.id,
      title: itinerary.title,
      startDate: itinerary.startDate,
      endDate: itinerary.endDate,
      days: itinerary.days.map((day) => HiveDayPlanModel(
        date: day.date,
        summary: day.summary,
        items: day.items.map((item) => HiveActivityItemModel(
          time: item.time,
          activity: item.activity,
          location: item.location,
        )).toList(),
      )).toList(),
      originalPrompt: itinerary.originalPrompt,
      createdAt: itinerary.createdAt,
      updatedAt: itinerary.updatedAt,
    );
  }

  String _buildSystemPrompt() {
    return '''
You are an expert travel planner AI. Generate detailed day-by-day itineraries in JSON format.

CRITICAL: Your response MUST follow this EXACT JSON schema (Spec A):
{
  "title": "Trip Title",
  "startDate": "YYYY-MM-DD", 
  "endDate": "YYYY-MM-DD",
  "days": [
    {
      "date": "YYYY-MM-DD",
      "summary": "Day summary",
      "items": [
        {
          "time": "HH:MM",
          "activity": "Activity description", 
          "location": "latitude,longitude"
        }
      ]
    }
  ]
}

Guidelines:
- Use 24-hour time format for "time" field
- Location must be "lat,lng" coordinates (use real coordinates)
- Include realistic travel times between activities
- Balance sightseeing, dining, and rest
- Consider local business hours and seasonal factors
- Respond ONLY with valid JSON, no additional text
    ''';
  }

  Map<String, dynamic> _extractItineraryFromResponse(String response) {
    final jsonStart = response.indexOf('{');
    final jsonEnd = response.lastIndexOf('}') + 1;
    
    if (jsonStart == -1 || jsonEnd <= jsonStart) {
      throw Exception('No valid JSON found in response');
    }
    
    final jsonString = response.substring(jsonStart, jsonEnd);
    
    try {
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Invalid JSON in response: $e');
    }
  }

  int _estimateTokens(String text) {
    return (text.length / 4).ceil();
  }
}

/// **Enhanced Token Usage Stats**
class TokenUsageStats {
  int _totalPromptTokens = 0;
  int _totalCompletionTokens = 0;
  int _requestCount = 0;
  int _tokensSaved = 0;

  void addUsage({
    required int promptTokens, 
    required int completionTokens,
    int tokensSaved = 0,
  }) {
    _totalPromptTokens += promptTokens;
    _totalCompletionTokens += completionTokens;
    _tokensSaved += tokensSaved;
    _requestCount++;
  }

  int get totalTokens => _totalPromptTokens + _totalCompletionTokens;
  int get promptTokens => _totalPromptTokens;
  int get completionTokens => _totalCompletionTokens;
  int get requestCount => _requestCount;
  int get tokensSaved => _tokensSaved;
  
  double get estimatedCostUSD {
    const costPer1kTokens = 0.03;
    return (totalTokens / 1000 * costPer1kTokens);
  }

  double get estimatedSavingsUSD {
    const costPer1kTokens = 0.03;
    return (_tokensSaved / 1000 * costPer1kTokens);
  }

  void reset() {
    _totalPromptTokens = 0;
    _totalCompletionTokens = 0;
    _requestCount = 0;
    _tokensSaved = 0;
  }

  @override
  String toString() {
    return 'TokenUsage(requests: $_requestCount, total: $totalTokens, saved: $_tokensSaved, cost: \$${estimatedCostUSD.toStringAsFixed(4)})';
  }
}

/// **Service Factory**
class AIAgentServiceFactory {
  static AIAgentService create({required String geminiApiKey}) {
    if (geminiApiKey.isEmpty) {
      return HiveMockAIAgentService();
    }
    return GeminiAIService(apiKey: geminiApiKey);
  }
}

/// **Mock Service**
class HiveMockAIAgentService implements AIAgentService {
  final TokenUsageStats _tokenUsage = TokenUsageStats();
  final HiveStorageService _storage = HiveStorageService.instance;

  @override
  Future<ItineraryModel> generateItinerary({
    required String userPrompt,
    String? userId,
    String? sessionId,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    
    final sampleItinerary = ItineraryModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Mock Trip - ${userPrompt.split(' ').take(3).join(' ')}',
      startDate: '2025-04-10',
      endDate: '2025-04-12',
      days: [
        DayPlanModel(
          date: '2025-04-10',
          summary: 'Arrival and City Exploration',
          items: [
            ActivityItemModel(
              time: '09:00',
              activity: 'Arrive at destination',
              location: '35.6762,139.6503',
            ),
          ],
        ),
      ],
      createdAt: DateTime.now(),
    );
    
    return sampleItinerary;
  }

  @override
  Future<ItineraryModel> refineItinerary({
    required String userPrompt,
    required String sessionId,
    String? userId,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return await generateItinerary(userPrompt: userPrompt, userId: userId, sessionId: sessionId);
  }

  @override
  Stream<String> streamItineraryGeneration({
    required String userPrompt,
    String? userId,
    String? sessionId,
  }) async* {
    final message = 'Generating your itinerary for: $userPrompt\n\nPlease wait...';
    for (int i = 0; i < message.length; i++) {
      yield message[i];
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  @override
  Future<String> getOrCreateSession({
    required String userId,
    String? existingSessionId,
  }) async {
    if (existingSessionId != null) {
      final session = await _storage.getSession(existingSessionId);
      if (session != null) return existingSessionId;
    }
    
    final session = HiveSessionState.create(userId);
    await _storage.saveSession(session);
    return session.sessionId;
  }

  @override
  Future<SessionState?> getSession(String sessionId) async {
    final hiveSession = await _storage.getSession(sessionId);
    if (hiveSession != null) {
      return SessionState(
        sessionId: hiveSession.sessionId,
        userId: hiveSession.userId,
        createdAt: hiveSession.createdAt,
        lastUsed: hiveSession.lastUsed,
        conversationHistory: hiveSession.geminiConversationHistory,
        userPreferences: Map<String, dynamic>.from(hiveSession.userPreferences),
        tripContext: Map<String, dynamic>.from(hiveSession.tripContext),
        tokensSaved: hiveSession.tokensSaved,
        messagesInSession: hiveSession.messagesInSession,
        estimatedCostSavings: hiveSession.estimatedCostSavings,
        refinementCount: hiveSession.refinementCount,
        isActive: hiveSession.isActive,
      );
    }
    return null;
  }

  @override
  Future<void> clearSession(String sessionId) async {
    await _storage.deleteSession(sessionId);
  }

  @override
  Future<Map<String, dynamic>> getSessionMetrics(String userId) async {
    final sessions = await _storage.getUserSessions(userId);
    return {
      'total_sessions': sessions.length,
      'active_sessions': sessions.length,
      'total_tokens_saved': 0,
      'total_cost_savings': 0.0,
      'session_reuse_rate': 0.0,
    };
  }

  @override
  TokenUsageStats get tokenUsage => _tokenUsage;

  @override
  bool validateItinerarySchema(Map<String, dynamic> json) => true;
}
