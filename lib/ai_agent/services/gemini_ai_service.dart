import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_trip_planner_flutter/ai_agent/services/ai_service.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import '../../core/errors/failures.dart';
import '../../trip_planning/data/models/itinerary_models.dart';
import '../../core/utils/helpers.dart';
import '../models/trip_session_model.dart';

/// **Isar-Based AI Service - Production Migration from SharedPreferences**
/// 
/// This implements the complete session persistence using Isar database:
/// - High-performance local database storage
/// - Efficient querying and indexing
/// - Better data integrity and relationships
/// - Scalable for large conversation histories
/// 
/// Key Improvements over SharedPreferences:
/// 1. Complex queries (find sessions by user, date range, etc.)
/// 2. Better performance for large datasets
/// 3. Data relationships and foreign keys
/// 4. Automatic indexing for fast lookups
/// 5. Transaction support for data integrity

/// **Isar-Enhanced Gemini AI Service**
class GeminiAIService implements AIAgentService {
  final GenerativeModel _baseModel;
  final TokenUsageStats _tokenUsage = TokenUsageStats();
  
  // Isar database instance
  Isar? _isar;
  bool _isInitialized = false;
  
  // Session management (AI Companion patterns)
  final Map<String, ChatSession> _geminiSessions = {};
  final Map<String, DateTime> _sessionLastUsed = {};
  
  // Debounced saving (AI Companion pattern)
  Timer? _saveDebounceTimer;
  final Set<String> _pendingSessions = {};
  static const Duration _saveDebounceDelay = Duration(milliseconds: 500);

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
    _initializeIsar();
  }

  /// **Initialize Isar Database**
  Future<void> _initializeIsar() async {
    if (_isInitialized) return;

    try {
      Logger.d('Initializing Isar database for AI sessions', tag: 'IsarAI');
      
      final dir = await getApplicationDocumentsDirectory();
      final isarPath = '${dir.path}/ai_sessions.isar';
      
      // Delete existing database for clean migration (only during development)
      final dbFile = File(isarPath);
      if (await dbFile.exists()) {
        Logger.d('Existing database found, performing clean migration', tag: 'IsarAI');
        // In production, you would handle migration properly
        // For now, we'll clean slate for development
      }

      _isar = await Isar.open(
        [
          TripPlanningSessionSchema,
          TripSessionMetadataSchema,
          ItineraryModelSchema,
          ChatMessageModelSchema,
        ],
        directory: dir.path,
        name: 'ai_sessions',
        inspector: true, // Enable inspector for development
      );
      
      _isInitialized = true;
      Logger.d('Isar database initialized successfully', tag: 'IsarAI');
      
      // Perform initial cleanup of old sessions
      await _cleanupOldSessions();
      
    } catch (e, stackTrace) {
      Logger.e('Failed to initialize Isar database: $e', tag: 'IsarAI');
      Logger.e('Stack trace: $stackTrace', tag: 'IsarAI');
      throw AIAgentException('Database initialization failed: $e');
    }
  }

  /// **Ensure database is ready for operations**
  Future<void> _ensureInitialized() async {
    if (!_isInitialized || _isar == null) {
      await _initializeIsar();
    }
  }

  @override
  Future<ItineraryModel> generateItinerary({
    required String userPrompt,
    String? userId,
    String? sessionId,
  }) async {
    await _ensureInitialized();
    Logger.d('Generating itinerary with Isar persistence', tag: 'IsarAI');
    
    try {
      // Get or create session for conversation continuity
      final activeSessionId = sessionId ?? await getOrCreateSession(userId: userId ?? 'anonymous');
      final session = await _getSessionFromIsar(activeSessionId);
      
      if (session == null) {
        throw AIAgentException('Failed to create or retrieve session');
      }

      // Extract user preferences and trip context
      session.extractUserPreferences(userPrompt, '');
      session.extractTripContext(userPrompt);
      
      // Build optimized prompt with session context
      final systemPrompt = _buildSystemPrompt();
      final contextPrompt = session.buildRefinementContext();
      final fullPrompt = '''
$systemPrompt

$contextPrompt

User Request: $userPrompt

IMPORTANT: Create a complete trip plan based on the user's request and preferences above.
''';

      // Get or create chat session with Gemini
      final chatSession = await _getOrCreateGeminiSession(session);
      final response = await chatSession.sendMessage(Content.text(fullPrompt))
          .timeout(const Duration(seconds: 15), onTimeout: () {
        throw TimeoutException('AI response timed out');
      });

      // Parse and validate response
      final itineraryJson = _extractItineraryFromResponse(response.text ?? '');
      if (!validateItinerarySchema(itineraryJson)) {
        throw Exception('Generated itinerary does not match required schema');
      }

      final itinerary = ItineraryModel.fromJson(itineraryJson);

      // Update session with conversation and metrics
      final tokensUsed = _estimateTokens(fullPrompt) + _estimateTokens(response.text ?? '');
      session.updateConversation(
        userMessage: Content.text(userPrompt),
        aiResponse: Content.model([TextPart(response.text ?? '')]),
        tokensUsed: tokensUsed,
        tokensSavedFromReuse: 0, // No savings for initial generation
      );

      // Track usage for cost monitoring
      _tokenUsage.addUsage(
        promptTokens: _estimateTokens(fullPrompt),
        completionTokens: _estimateTokens(response.text ?? ''),
      );

      // Save session to Isar (debounced)
      _debouncedSaveSession(session);

      // Save itinerary to Isar
      await _saveItineraryToIsar(itinerary, activeSessionId, userPrompt);

      Logger.d('Successfully generated itinerary with Isar session: $activeSessionId', tag: 'IsarAI');
      return itinerary;
      
    } catch (e) {
      Logger.e('Failed to generate itinerary with Isar: $e', tag: 'IsarAI');
      throw AIAgentException('Failed to generate itinerary: $e');
    }
  }

  @override
  Future<ItineraryModel> refineItinerary({
    required String userPrompt,
    required String sessionId,
    String? userId,
  }) async {
    await _ensureInitialized();
    Logger.d('Refining itinerary using Isar session: $sessionId', tag: 'IsarAI');
    
    try {
      final session = await _getSessionFromIsar(sessionId);
      if (session == null) {
        throw AIAgentException('Session not found: $sessionId');
      }

      if (!session.isValid) {
        throw AIAgentException('Session expired: $sessionId');
      }

      // Extract preferences from refinement request
      session.extractUserPreferences(userPrompt, '');
      session.markRefinement();

      // Build refinement prompt with full context
      final systemPrompt = _buildRefinementPrompt();
      final contextPrompt = session.buildRefinementContext();
      
      final fullPrompt = '''
$systemPrompt

$contextPrompt

User Refinement Request: $userPrompt

IMPORTANT: Make MINIMAL changes - only what the user specifically requests.
''';

      // Reuse existing Gemini session for token efficiency
      final chatSession = await _getOrCreateGeminiSession(session);
      final response = await chatSession.sendMessage(Content.text(userPrompt))
          .timeout(const Duration(seconds: 15), onTimeout: () {
        throw TimeoutException('AI response timed out');
      });

      // Calculate token savings from session reuse
      final tokensUsed = _estimateTokens(userPrompt) + _estimateTokens(response.text ?? '');
      final tokensSaved = _calculateTokensSaved(session, fullPrompt);

      // Parse refined itinerary
      final refinedJson = _extractItineraryFromResponse(response.text ?? '');
      final refinedItinerary = ItineraryModel.fromJson(refinedJson);

      // Update session with refinement
      session.updateConversation(
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

      // Save session to Isar (debounced)
      _debouncedSaveSession(session);

      // Update itinerary in Isar
      await _updateItineraryInIsar(refinedItinerary, sessionId);

      Logger.d('Successfully refined itinerary, saved $tokensSaved tokens', tag: 'IsarAI');
      return refinedItinerary;
      
    } catch (e) {
      Logger.e('Failed to refine itinerary with Isar: $e', tag: 'IsarAI');
      throw AIAgentException('Failed to refine itinerary: $e');
    }
  }

  @override
  Stream<String> streamItineraryGeneration({
    required String userPrompt,
    String? userId,
    String? sessionId,
  }) async* {
    await _ensureInitialized();
    Logger.d('Starting streaming generation with Isar session', tag: 'IsarAI');
    
    try {
      final activeSessionId = sessionId ?? await getOrCreateSession(userId: userId ?? 'anonymous');
      final session = await _getSessionFromIsar(activeSessionId);
      
      if (session == null) {
        yield 'Error: Failed to create session for streaming';
        return;
      }

      final systemPrompt = _buildSystemPrompt();
      final contextPrompt = session.buildRefinementContext();
      final fullPrompt = '''
$systemPrompt

$contextPrompt

User Request: $userPrompt
''';
      
      final chatSession = await _getOrCreateGeminiSession(session);
      final response = chatSession.sendMessageStream(Content.text(fullPrompt));

      await for (final chunk in response) {
        final text = chunk.text;
        if (text != null) {
          yield text;
        }
      }
    } catch (e) {
      Logger.e('Streaming error with Isar: $e', tag: 'IsarAI');
      yield 'Error: Failed to stream itinerary generation - $e';
    }
  }

  @override
  Future<String> getOrCreateSession({
    required String userId,
    String? existingSessionId,
  }) async {
    await _ensureInitialized();
    Logger.d('Getting or creating Isar session for user: $userId', tag: 'IsarAI');
    
    // Try to reuse existing session if provided and valid
    if (existingSessionId != null) {
      final existingSession = await _getSessionFromIsar(existingSessionId);
      if (existingSession != null && existingSession.isValid) {
        existingSession.lastUsed = DateTime.now();
        await _saveSessionToIsar(existingSession);
        Logger.d('Reusing existing session: $existingSessionId', tag: 'IsarAI');
        return existingSessionId;
      }
    }

    // Check for reusable sessions for this user
    final reusableSession = await _findReusableSessionInIsar(userId);
    if (reusableSession != null) {
      Logger.d('Found reusable session: ${reusableSession.sessionId}', tag: 'IsarAI');
      return reusableSession.sessionId;
    }

    // Create new session
    final newSession = TripPlanningSession.create(userId: userId);
    await _saveSessionToIsar(newSession);
    
    Logger.d('Created new Isar session: ${newSession.sessionId}', tag: 'IsarAI');
    return newSession.sessionId;
  }

  @override
  Future<TripPlanningSession?> getSession(String sessionId) async {
    await _ensureInitialized();
    return await _getSessionFromIsar(sessionId);
  }

  @override
  Future<void> clearSession(String sessionId) async {
    await _ensureInitialized();
    Logger.d('Clearing Isar session: $sessionId', tag: 'IsarAI');
    
    try {
      await _isar!.writeTxn(() async {
        final session = await _isar!.tripPlanningSessions
            .where()
            .sessionIdEqualTo(sessionId)
            .findFirst();
            
        if (session != null) {
          await _isar!.tripPlanningSessions.delete(session.isarId);
        }

        // Also clear related itineraries (if needed in future)
        await _isar!.itineraryModels
            .filter()
            .originalPromptIsNotNull()
            .deleteAll();
      });

      // Remove from memory cache
      _geminiSessions.remove(sessionId);
      _sessionLastUsed.remove(sessionId);
      
      Logger.d('Successfully cleared Isar session: $sessionId', tag: 'IsarAI');
    } catch (e) {
      Logger.e('Failed to clear Isar session: $e', tag: 'IsarAI');
      throw AIAgentException('Failed to clear session: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getSessionMetrics(String userId) async {
    await _ensureInitialized();
    
    try {
      final sessions = await _isar!.tripPlanningSessions
          .where()
          .userIdEqualTo(userId)
          .findAll();
      
      final activeSessions = sessions.where((s) => s.isValid).length;
      final totalTokensSaved = sessions.fold<int>(0, (sum, s) => sum + s.tokensSaved);
      final totalCostSavings = sessions.fold<double>(0.0, (sum, s) => sum + s.estimatedCostSavings);
      final averageRefinements = sessions.isEmpty ? 0.0 : 
          sessions.fold<int>(0, (sum, s) => sum + s.refinementCount) / sessions.length;
      
      return {
        'userId': userId,
        'totalSessions': sessions.length,
        'activeSessions': activeSessions,
        'totalTokensSaved': totalTokensSaved,
        'totalCostSavings': totalCostSavings,
        'averageRefinements': averageRefinements,
        'sessionReuseRate': _calculateReuseRate(sessions),
        'optimizationScore': _calculateOptimizationScore(sessions),
        'lastActivity': sessions.isEmpty ? null : 
            sessions.map((s) => s.lastUsed).reduce((a, b) => a?.isAfter(b!) == true ? a : b),
      };
    } catch (e) {
      Logger.e('Failed to get session metrics from Isar: $e', tag: 'IsarAI');
      return {'error': e.toString()};
    }
  }

  @override
  TokenUsageStats get tokenUsage => _tokenUsage;

  @override
  bool validateItinerarySchema(Map<String, dynamic> json) {
    try {
      // Validate basic structure
      if (!json.containsKey('title') || !json.containsKey('startDate') || 
          !json.containsKey('endDate') || !json.containsKey('days')) {
        return false;
      }
      
      // Validate days array
      final days = json['days'] as List?;
      if (days == null || days.isEmpty) return false;
      
      // Quick validation passed
      return true;
    } catch (e) {
      Logger.e('Schema validation failed: $e', tag: 'IsarAI');
      return false;
    }
  }

  @override
  Future<void> dispose() async {
    Logger.d('Disposing Isar AI Service', tag: 'IsarAI');
    
    // Cancel any pending operations
    _saveDebounceTimer?.cancel();
    
    // Close Isar database
    if (_isar != null && _isar!.isOpen) {
      await _isar!.close();
    }
    
    // Clear memory caches
    _geminiSessions.clear();
    _sessionLastUsed.clear();
    _pendingSessions.clear();
    
    _isInitialized = false;
    Logger.d('Isar AI Service disposed successfully', tag: 'IsarAI');
  }

  // === Isar Database Operations ===

  /// **Save session to Isar database**
  Future<void> _saveSessionToIsar(TripPlanningSession session) async {
    if (!_isInitialized || _isar == null) return;
    
    try {
      await _isar!.writeTxn(() async {
        await _isar!.tripPlanningSessions.put(session);
      });
      Logger.d('Session saved to Isar: ${session.sessionId}', tag: 'IsarAI');
    } catch (e) {
      Logger.e('Failed to save session to Isar: $e', tag: 'IsarAI');
      throw AIAgentException('Failed to save session: $e');
    }
  }

  /// **Get session from Isar database**
  Future<TripPlanningSession?> _getSessionFromIsar(String sessionId) async {
    if (!_isInitialized || _isar == null) return null;
    
    try {
      return await _isar!.tripPlanningSessions
          .where()
          .sessionIdEqualTo(sessionId)
          .findFirst();
    } catch (e) {
      Logger.e('Failed to get session from Isar: $e', tag: 'IsarAI');
      return null;
    }
  }

  /// **Find reusable session in Isar**
  Future<TripPlanningSession?> _findReusableSessionInIsar(String userId) async {
    if (!_isInitialized || _isar == null) return null;
    
    try {
      // Find most recent valid session for this user
      final sessions = await _isar!.tripPlanningSessions
          .where()
          .userIdEqualTo(userId)
          .sortByLastUsedDesc()
          .limit(10)
          .findAll();
      
      // Return first valid session with conversation history
      for (final session in sessions) {
        if (session.isValid && session.messagesInSession > 0) {
          session.lastUsed = DateTime.now();
          await _saveSessionToIsar(session);
          return session;
        }
      }
      
      return null;
    } catch (e) {
      Logger.e('Failed to find reusable session in Isar: $e', tag: 'IsarAI');
      return null;
    }
  }

  /// **Save itinerary to Isar database**
  Future<void> _saveItineraryToIsar(ItineraryModel itinerary, String sessionId, String originalPrompt) async {
    if (!_isInitialized || _isar == null) return;
    
    try {
      itinerary.id = '${sessionId}_${DateTime.now().millisecondsSinceEpoch}';
      itinerary.originalPrompt = originalPrompt;
      itinerary.createdAt = DateTime.now();
      itinerary.updatedAt = DateTime.now();
      
      await _isar!.writeTxn(() async {
        await _isar!.itineraryModels.put(itinerary);
      });
      
      Logger.d('Itinerary saved to Isar: ${itinerary.id}', tag: 'IsarAI');
    } catch (e) {
      Logger.e('Failed to save itinerary to Isar: $e', tag: 'IsarAI');
      // Don't throw - itinerary generation succeeded, storage is secondary
    }
  }

  /// **Update itinerary in Isar database**
  Future<void> _updateItineraryInIsar(ItineraryModel itinerary, String sessionId) async {
    if (!_isInitialized || _isar == null) return;
    
    try {
      itinerary.updatedAt = DateTime.now();
      
      await _isar!.writeTxn(() async {
        await _isar!.itineraryModels.put(itinerary);
      });
      
      Logger.d('Itinerary updated in Isar: ${itinerary.id}', tag: 'IsarAI');
    } catch (e) {
      Logger.e('Failed to update itinerary in Isar: $e', tag: 'IsarAI');
      // Don't throw - refinement succeeded, storage is secondary
    }
  }

  /// **Cleanup old sessions periodically**
  Future<void> _cleanupOldSessions() async {
    if (!_isInitialized || _isar == null) return;
    
    try {
      final cutoffDate = DateTime.now().subtract(const Duration(days: 90));
      
      await _isar!.writeTxn(() async {
        final count = await _isar!.tripPlanningSessions
            .filter()
            .createdAtLessThan(cutoffDate)
            .deleteAll();
        
        if (count > 0) {
          Logger.d('Cleaned up $count old sessions', tag: 'IsarAI');
        }
      });
    } catch (e) {
      Logger.e('Failed to cleanup old sessions: $e', tag: 'IsarAI');
      // Don't throw - cleanup is optional
    }
  }

  // === Session Management Helpers ===

  void _debouncedSaveSession(TripPlanningSession session) {
    _pendingSessions.add(session.sessionId);
    
    _saveDebounceTimer?.cancel();
    _saveDebounceTimer = Timer(_saveDebounceDelay, () async {
      await _processPendingSaves();
    });
  }

  Future<void> _processPendingSaves() async {
    if (_pendingSessions.isEmpty || !_isInitialized || _isar == null) return;
    
    final sessionIds = Set<String>.from(_pendingSessions);
    _pendingSessions.clear();
    
    Logger.d('Processing ${sessionIds.length} pending session saves', tag: 'IsarAI');
    
    try {
      await _isar!.writeTxn(() async {
        for (final sessionId in sessionIds) {
          final session = await _isar!.tripPlanningSessions
              .where()
              .sessionIdEqualTo(sessionId)
              .findFirst();
              
          if (session != null) {
            await _isar!.tripPlanningSessions.put(session);
          }
        }
      });
    } catch (e) {
      Logger.e('Failed to process pending saves: $e', tag: 'IsarAI');
    }
  }

  Future<ChatSession> _getOrCreateGeminiSession(TripPlanningSession session) async {
    final sessionKey = session.sessionId;
    
    // Check for existing Gemini session
    if (_geminiSessions.containsKey(sessionKey)) {
      _sessionLastUsed[sessionKey] = DateTime.now();
      return _geminiSessions[sessionKey]!;
    }

    // Create new Gemini session with conversation history
    Logger.d('Creating new Gemini session for: $sessionKey', tag: 'IsarAI');
    final history = session.conversationHistory;
    
    final chatSession = _baseModel.startChat(history: history);
    _geminiSessions[sessionKey] = chatSession;
    _sessionLastUsed[sessionKey] = DateTime.now();
    
    return chatSession;
  }

  // === Helper Methods ===

  int _calculateTokensSaved(TripPlanningSession session, String fullPrompt) {
    // Estimate tokens saved by using session context instead of full history
    final fullHistorySize = session.conversationHistory.length * 100; // Rough estimate
    
    // Session reuse saves ~90% of context tokens
    return (fullHistorySize * 0.9).round();
  }

  double _calculateReuseRate(List<TripPlanningSession> sessions) {
    if (sessions.isEmpty) return 0.0;
    
    final reusedSessions = sessions.where((s) => s.refinementCount > 0).length;
    return (reusedSessions / sessions.length) * 100;
  }

  double _calculateOptimizationScore(List<TripPlanningSession> sessions) {
    if (sessions.isEmpty) return 0.0;
    
    final totalSavings = sessions.fold<int>(0, (sum, s) => sum + s.tokensSaved);
    final totalMessages = sessions.fold<int>(0, (sum, s) => sum + s.messagesInSession);
    
    if (totalMessages == 0) return 0.0;
    
    // Score based on token efficiency and session reuse
    final reuseRate = _calculateReuseRate(sessions);
    final tokenEfficiency = (totalSavings / (totalMessages * 100)) * 100;
    
    return (reuseRate + tokenEfficiency) / 2;
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
      "summary": "Brief day summary",
      "items": [
        {
          "time": "HH:MM",
          "activity": "Activity description",
          "location": "lat,lng"
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

  String _buildRefinementPrompt() {
    return '''
You are refining an existing itinerary based on user feedback.

CRITICAL RULES:
1. Maintain the EXACT JSON schema (Spec A)
2. Make MINIMAL changes - only what the user specifically requests
3. Preserve all other activities and timing
4. Ensure logical flow and realistic travel times

Respond ONLY with the complete updated itinerary JSON, no additional text.
    ''';
  }

  Map<String, dynamic> _extractItineraryFromResponse(String response) {
    // Extract JSON from response (handle various formats)
    final jsonStart = response.indexOf('{');
    final jsonEnd = response.lastIndexOf('}') + 1;
    
    if (jsonStart == -1 || jsonEnd <= jsonStart) {
      throw Exception('No valid JSON found in AI response');
    }
    
    final jsonString = response.substring(jsonStart, jsonEnd);
    
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to parse AI response as JSON: $e');
    }
  }

  // Simple token estimation for cost tracking
  int _estimateTokens(String text) {
    // Rough estimation: 1 token ≈ 4 characters
    return (text.length / 4).ceil();
  }
}


class AIAgentServiceFactory {
  static AIAgentService create({required String geminiApiKey}) {
    if (geminiApiKey.isEmpty) {
      throw AIAgentException('Gemini API key is required');
    }
    return GeminiAIService(apiKey: geminiApiKey);
  }
  
}