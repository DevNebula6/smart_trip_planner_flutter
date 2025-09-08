import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:smart_trip_planner_flutter/ai_agent/services/ai_agent_service.dart';
import 'package:smart_trip_planner_flutter/core/errors/failures.dart';
import 'package:smart_trip_planner_flutter/core/storage/hive_storage_service.dart';
import 'package:smart_trip_planner_flutter/core/storage/hive_models.dart';
import 'package:smart_trip_planner_flutter/ai_agent/models/trip_session_model.dart';
import 'package:smart_trip_planner_flutter/trip_planning_chat/data/models/itinerary_models.dart';
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
          model: 'gemini-2.5-flash',
          apiKey: apiKey,
          systemInstruction: Content.text(_buildSystemPromptStatic()),
          generationConfig: GenerationConfig(
            temperature: 0.7,
            topK: 40,
            topP: 0.95,
            maxOutputTokens: 4096,
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
      final contextPrompt = hiveSession.buildRefinementContext();
      final fullPrompt = '''

$contextPrompt

User Request: $userPrompt

IMPORTANT: Create a complete trip plan based on the user's request and preferences above.
''';

      // Get Gemini chat session
      final chatSession = await _getOrCreateGeminiSession(hiveSession);
      final response = await chatSession.sendMessage(Content.text(fullPrompt))
          .timeout(const Duration(seconds: 45), onTimeout: () { // Increased timeout
        throw TimeoutException('AI response timed out');
      });

      // Debug the actual response
      final responseText = response.text ?? '';
      Logger.d('Full AI response length: ${responseText.length}', tag: 'HiveGeminiAI');
      Logger.d('Response complete: ${!responseText.contains('...') && responseText.contains('}')}', tag: 'HiveGeminiAI');
      
      if (responseText.length < 500) {
        Logger.d('Full short response: $responseText', tag: 'HiveGeminiAI');
      } else {
        Logger.d('Response start (500 chars): ${responseText.substring(0, 500)}...', tag: 'HiveGeminiAI');
        Logger.d('Response end (200 chars): ...${responseText.substring(responseText.length - 200)}', tag: 'HiveGeminiAI');
      }

      // Parse response
      final itineraryJson = _extractItineraryFromResponse(responseText);
      Logger.d('Parsed itinerary JSON: ${itineraryJson.keys}', tag: 'HiveGeminiAI');
      
      if (!validateItinerarySchema(itineraryJson)) {
        Logger.e('Schema validation failed for itinerary', tag: 'HiveGeminiAI');
        throw Exception('Generated itinerary does not match required schema');
      }
      
      Logger.d('Schema validation passed, creating ItineraryModel', tag: 'HiveGeminiAI');

      final itinerary = ItineraryModel.fromJson(itineraryJson);

      // Update session
      final tokensUsed = _estimateTokens(fullPrompt) + _estimateTokens(response.text ?? '');
      
      // Extract trip context for better home page display
      hiveSession.extractTripContext(userPrompt);
      hiveSession.tripContext['itinerary_title'] = itinerary.title;
      hiveSession.tripContext['duration_days'] = itinerary.durationDays;
      hiveSession.tripContext['start_date'] = itinerary.startDate;
      hiveSession.tripContext['end_date'] = itinerary.endDate;
      
      Logger.d('Updated session tripContext with itinerary_title: ${itinerary.title}', tag: 'HiveGeminiAI');
      Logger.d('Full tripContext: ${hiveSession.tripContext}', tag: 'HiveGeminiAI');
      
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

      // Save session to Hive (immediately for important updates)
      await _storage.saveSession(hiveSession);
      Logger.d('Session saved immediately for itinerary generation', tag: 'HiveGeminiAI');

      // Save itinerary to Hive
      final hiveItinerary = _convertToHiveItinerary(itinerary);
      await _storage.saveItinerary(hiveItinerary);

      return itinerary;
      
    } on SocketException catch (e) {
      Logger.e('Network error - Failed to generate itinerary: $e', tag: 'HiveGeminiAI');
      throw AIAgentException('Network connection failed. Please check your internet connection and try again.');
    } on TimeoutException catch (e) {
      Logger.e('Timeout error - Failed to generate itinerary: $e', tag: 'HiveGeminiAI');
      throw AIAgentException('Request timed out. Please try again with a simpler request.');
    } catch (e) {
      Logger.e('Failed to generate itinerary: $e', tag: 'HiveGeminiAI');
      
      // Check if it's a network-related error
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('failed host lookup') || 
          errorString.contains('socketexception') || 
          errorString.contains('network') ||
          errorString.contains('connection')) {
        throw AIAgentException('Network connection failed. Please check your internet connection and try again.');
      }
      
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
          .timeout(const Duration(seconds: 60), onTimeout: () {
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

      final contextPrompt = hiveSession.buildRefinementContext();
      final fullPrompt = '''

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
      Logger.d('Validating itinerary schema for JSON: ${json.keys}', tag: 'HiveGeminiAI');
      
      final requiredFields = ['title', 'startDate', 'endDate', 'days'];
      for (final field in requiredFields) {
        if (!json.containsKey(field)) {
          Logger.w('Missing required field: $field', tag: 'HiveGeminiAI');
          return false;
        }
      }

      final days = json['days'] as List?;
      if (days == null || days.isEmpty) {
        Logger.w('Days field is null or empty', tag: 'HiveGeminiAI');
        return false;
      }

      for (int dayIndex = 0; dayIndex < days.length; dayIndex++) {
        final day = days[dayIndex];
        if (day is! Map<String, dynamic>) {
          Logger.w('Day $dayIndex is not a map', tag: 'HiveGeminiAI');
          return false;
        }

        // Check for either 'date' or 'summary' - be more flexible
        final dayFields = ['summary'];
        for (final field in dayFields) {
          if (!day.containsKey(field)) {
            Logger.w('Day $dayIndex missing field: $field', tag: 'HiveGeminiAI');
            return false;
          }
        }

        final items = day['items'] as List?;
        if (items == null) {
          Logger.w('Day $dayIndex missing items field', tag: 'HiveGeminiAI');
          return false;
        }

        for (int itemIndex = 0; itemIndex < items.length; itemIndex++) {
          final item = items[itemIndex];
          if (item is! Map<String, dynamic>) {
            Logger.w('Day $dayIndex item $itemIndex is not a map', tag: 'HiveGeminiAI');
            return false;
          }

          // Be more flexible - only require activity, make time and location optional
          if (!item.containsKey('activity')) {
            Logger.w('Day $dayIndex item $itemIndex missing activity field', tag: 'HiveGeminiAI');
            return false;
          }

          // Provide default values for missing optional fields
          item.putIfAbsent('time', () => '');
          item.putIfAbsent('location', () => '0,0');
        }

        // Provide default date if missing
        day.putIfAbsent('date', () => DateTime.now().toIso8601String().split('T')[0]);
      }

      Logger.d('Schema validation passed', tag: 'HiveGeminiAI');
      return true;
    } catch (e) {
      Logger.e('Schema validation error: $e', tag: 'HiveGeminiAI');
      return false;
    }
  }

  // ===== Helper Methods =====

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

    try {
      Logger.d('Creating ChatSession for session: $sessionKey', tag: 'HiveGeminiAI');
      
      // Validate conversation history before creating ChatSession
      final history = session.geminiConversationHistory;
      final cleanHistory = <Content>[];

      for (int i = 0; i < history.length; i++) {
        final content = history[i];
        try {
          // Validate content structure
          final parts = content.parts;
          
          // Skip content with empty or invalid parts
          if (parts.isEmpty) {
            Logger.w('Skipping content at index $i: empty parts', tag: 'HiveGeminiAI');
            continue;
          }
          
          // Validate each part
          bool hasValidParts = false;
          for (final part in parts) {
            if (part is TextPart && part.text.trim().isNotEmpty) {
              hasValidParts = true;
              break;
            }
          }
          
          if (hasValidParts) {
            cleanHistory.add(content);
          } else {
            Logger.w('Skipping content at index $i: no valid parts', tag: 'HiveGeminiAI');
          }
          
        } catch (e) {
          Logger.w('Skipping invalid content at index $i: $e', tag: 'HiveGeminiAI');
          continue;
        }
      }
      
      Logger.d('Using ${cleanHistory.length} valid history items out of ${history.length}', tag: 'HiveGeminiAI');
      
      final chatSession = _baseModel.startChat(history: cleanHistory);
      _geminiSessions[sessionKey] = chatSession;
      _sessionLastUsed[sessionKey] = DateTime.now();
      
      return chatSession;
      
    } catch (e) {
      Logger.e('Error creating ChatSession with history: $e', tag: 'HiveGeminiAI');
      Logger.d('Creating new ChatSession without history for session: $sessionKey', tag: 'HiveGeminiAI');
      
      final chatSession = _baseModel.startChat();
      _geminiSessions[sessionKey] = chatSession;
      _sessionLastUsed[sessionKey] = DateTime.now();
      return chatSession;
    }
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

  static String _buildSystemPromptStatic() {
    return '''
You are an expert travel planner AI. Generate detailed day-by-day itineraries in JSON format.

CRITICAL CONSTRAINTS:
- Keep response under 3600 tokens (roughly 2800 words)
- Limit to maximum 5-10 days for longer trips
- Maximum 4-5 activities per day
- Keep activity descriptions brief 
- Use short, precise summaries

EXACT JSON schema required:
{
  "title": "Trip Title",
  "startDate": "YYYY-MM-DD", 
  "endDate": "YYYY-MM-DD",
  "days": [
    {
      "date": "YYYY-MM-DD",
      "summary": "Brief day summary (max 8 words)",
      "items": [
        {
          "time": "HH:MM",
          "activity": "Brief activity description (max 15 words)", 
          "location": "lat,lng"
        }
      ]
    }
  ]
}

ESSENTIAL RULES:
- 24-hour time format only
- Real coordinates for location (lat,lng format)
- NO additional text, prose, or code blocks
- Ensure JSON is complete and properly closed

Respond with ONLY the JSON object, ensuring it's complete and valid.
''';
  }

  Map<String, dynamic> _extractItineraryFromResponse(String response) {
    try {
      _logResponseEndingDetails(response);

      
      // Clean the response - remove any leading/trailing whitespace
      final cleanedResponse = response.trim();
      Logger.d('Raw AI response start: ${cleanedResponse.substring(0, min(500, cleanedResponse.length))}', tag: 'HiveGeminiAI');

      // First try to find JSON block with triple backticks (most common case)
      final codeBlockMatch = RegExp(r'```(?:json)?\s*(.*?)\s*```', dotAll: true).firstMatch(response);
      if (codeBlockMatch != null) {
        final jsonString = codeBlockMatch.group(1)!.trim();
        Logger.d('Found JSON in code block, length: ${jsonString.length}', tag: 'HiveGeminiAI');
        try {
          final parsedJson = json.decode(jsonString) as Map<String, dynamic>;
          Logger.d('Successfully parsed JSON from code block with keys: ${parsedJson.keys}', tag: 'HiveGeminiAI');
          return parsedJson;
        } catch (e) {
          Logger.w('Failed to parse JSON from code block: $e', tag: 'HiveGeminiAI');
        }
      }
      
      // Check if response looks like pure JSON (starts with { and has reasonable structure)
      if (cleanedResponse.startsWith('{')) {
        Logger.d('Response appears to be pure JSON', tag: 'HiveGeminiAI');
        
        // Check if JSON is complete (ends with })
        if (cleanedResponse.endsWith('}')) {
          Logger.d('JSON appears complete, attempting direct parse', tag: 'HiveGeminiAI');
          try {
            final parsedJson = json.decode(cleanedResponse) as Map<String, dynamic>;
            Logger.d('Successfully parsed complete JSON with keys: ${parsedJson.keys}', tag: 'HiveGeminiAI');
            return parsedJson;
          } catch (e) {
            Logger.w('Failed to parse complete JSON: $e', tag: 'HiveGeminiAI');
          }
        } else {
          Logger.w('JSON appears truncated (does not end with })', tag: 'HiveGeminiAI');
          // Try to repair truncated JSON by finding the last complete object/array
          final repairedJson = _attemptJsonRepair(cleanedResponse);
          if (repairedJson != null) {
            Logger.d('Successfully repaired truncated JSON', tag: 'HiveGeminiAI');
            return repairedJson;
          }
        }
      }
      
      // Try to find JSON object boundaries more robustly
      final jsonStart = response.indexOf('{');
      int jsonEnd = -1;
      
      if (jsonStart != -1) {
        int braceCount = 0;
        for (int i = jsonStart; i < response.length; i++) {
          if (response[i] == '{') {
            braceCount++;
          } else if (response[i] == '}') {
            braceCount--;
            if (braceCount == 0) {
              jsonEnd = i + 1;
              break;
            }
          }
        }
      }
      
      if (jsonStart != -1 && jsonEnd > jsonStart) {
        final jsonString = response.substring(jsonStart, jsonEnd);
        Logger.d('Extracted JSON by braces: ${jsonString.length > 300 ? jsonString.substring(0, 300) : jsonString}...', tag: 'HiveGeminiAI');
        
        try {
          final parsedJson = json.decode(jsonString) as Map<String, dynamic>;
          Logger.d('Successfully parsed JSON by braces', tag: 'HiveGeminiAI');
          return parsedJson;
        } catch (e) {
          Logger.w('Failed to parse JSON by braces: $e', tag: 'HiveGeminiAI');
        }
      }
      
      // If all parsing attempts fail, create fallback
      Logger.w('No valid JSON found in response after all attempts, creating fallback', tag: 'HiveGeminiAI');
      Logger.w('Response type: ${response.runtimeType}, length: ${response.length}', tag: 'HiveGeminiAI');
      Logger.w('Response contains json: ${response.toLowerCase().contains('json')}', tag: 'HiveGeminiAI');
      Logger.w('Response contains backticks: ${response.contains('```')}', tag: 'HiveGeminiAI');
      
      return _createFallbackItinerary(response);
      
    } catch (e) {
      Logger.e('JSON parsing failed completely: $e', tag: 'HiveGeminiAI');
      return _createFallbackItinerary(response);
    }
  }

  void _logResponseEndingDetails(String response, {int tailChars = 800, int tailLines = 8}) {
    final len = response.length;
    final tailStart = max(0, len - tailChars);
    final tail = response.substring(tailStart);

    Logger.d('--- AI response tail (last $tailChars chars; total $len) ---', tag: 'HiveGeminiAI');
    Logger.d(tail, tag: 'HiveGeminiAI');

    final lines = tail.split(RegExp(r'\r?\n'));
    final lastLines = lines.length <= tailLines ? lines : lines.sublist(lines.length - tailLines);
    Logger.d('--- Last $tailLines lines of AI response ---', tag: 'HiveGeminiAI');
    for (final l in lastLines) {
      Logger.d(l, tag: 'HiveGeminiAI');
    }
  }

  Map<String, dynamic>? _attemptJsonRepair(String truncatedJson) {
    try {
      Logger.d('Attempting to repair truncated JSON', tag: 'HiveGeminiAI');
      
      // Try to find the last complete day object
      final dayMatches = RegExp(r'\{[^{}]*"date":[^{}]*"summary":[^{}]*"items":\s*\[[^\]]*\]\s*\}', dotAll: true)
          .allMatches(truncatedJson).toList();
      
      if (dayMatches.isEmpty) {
        Logger.w('No complete day objects found in truncated JSON', tag: 'HiveGeminiAI');
        return null;
      }
      
      // Build a repaired JSON with complete structure
      final jsonStart = truncatedJson.indexOf('{');
      if (jsonStart == -1) return null;
      
      // Extract the header part (title, dates, etc.)
      final headerMatch = RegExp(r'\{[^{]*"days":\s*\[', dotAll: true).firstMatch(truncatedJson);
      if (headerMatch == null) return null;
      
      final headerPart = truncatedJson.substring(jsonStart, headerMatch.end);
      
      // Extract complete days
      final completeDays = dayMatches.map((match) => match.group(0)!).join(',\n');
      
      // Reconstruct the JSON
      final repairedJson = '$headerPart\n$completeDays\n]\n}';
      
      Logger.d('Attempting to parse repaired JSON (${repairedJson.length} chars)', tag: 'HiveGeminiAI');
      
      final parsed = json.decode(repairedJson) as Map<String, dynamic>;
      Logger.d('Successfully repaired JSON with ${(parsed['days'] as List).length} days', tag: 'HiveGeminiAI');
      
      return parsed;
      
    } catch (e) {
      Logger.w('Failed to repair truncated JSON: $e', tag: 'HiveGeminiAI');
      return null;
    }
  }

  Map<String, dynamic> _createFallbackItinerary(String response) {
    // Try to extract some useful information from the response
    String title = 'Custom Trip';
    String startDate = DateTime.now().toIso8601String().split('T')[0];
    String endDate = DateTime.now().add(const Duration(days: 3)).toIso8601String().split('T')[0];
    
    // Try to extract title if available
    final titleMatch = RegExp(r'"title":\s*"([^"]*)"').firstMatch(response);
    if (titleMatch != null) {
      title = titleMatch.group(1) ?? title;
    }
    
    // Try to extract dates if available
    final startDateMatch = RegExp(r'"startDate":\s*"([^"]*)"').firstMatch(response);
    if (startDateMatch != null) {
      startDate = startDateMatch.group(1) ?? startDate;
    }
    
    final endDateMatch = RegExp(r'"endDate":\s*"([^"]*)"').firstMatch(response);
    if (endDateMatch != null) {
      endDate = endDateMatch.group(1) ?? endDate;
    }
    
    // Create a meaningful fallback based on extracted info
    return {
      'title': title,
      'startDate': startDate,
      'endDate': endDate,
      'days': [
        {
          'date': startDate,
          'summary': 'Exploring your destination',
          'items': [
            {
              'time': '09:00',
              'activity': 'Start your adventure - visit popular attractions',
              'location': '28.6139,77.2090'
            },
            {
              'time': '14:00',
              'activity': 'Enjoy local cuisine for lunch',
              'location': '28.6139,77.2090'
            },
            {
              'time': '18:00',
              'activity': 'Evening exploration and shopping',
              'location': '28.6139,77.2090'
            }
          ]
        }
      ]
    };
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
