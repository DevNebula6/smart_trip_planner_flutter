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
import 'package:smart_trip_planner_flutter/ai_agent/services/ai_response_parser.dart';
import 'package:smart_trip_planner_flutter/core/services/token_tracking_service.dart';
import 'package:smart_trip_planner_flutter/core/constants/app_constants.dart';
import 'package:smart_trip_planner_flutter/ai_agent/services/ai_tools_manager.dart';
import '../../core/utils/helpers.dart';



/// **Gemini Service**
class GeminiAIService implements AIAgentService {
  final GenerativeModel _baseModel;
  final TokenUsageStats _tokenUsage = TokenUsageStats();
  final HiveStorageService _storage = HiveStorageService.instance;
  
  // Unified tools manager for all AI tools (web search, places, flights, hotels, etc.)
  final AIToolsManager _toolsManager;
  
  // Session management (AI Companion patterns)
  final Map<String, ChatSession> _geminiSessions = {};
  final Map<String, DateTime> _sessionLastUsed = {};
  
  // Debounced saving (AI Companion pattern) - enhanced with Hive
  Timer? _saveDebounceTimer;
  final Set<String> _pendingSaves = {};
  static const Duration _saveDebounceDelay = Duration(milliseconds: AppConstants.sessionSaveDebounceMs);

  // Static helper to create tools for the model
  static List<Tool>? _createToolsForModel(AIToolsManager manager) {
    if (!manager.hasTools) {
      Logger.w('No AI tools available - check API keys in .env', tag: 'GeminiAI');
      return null;
    }
    final tools = manager.createToolDeclarations();
    Logger.d('✓ Initialized ${manager.availableTools.length} AI tools: ${manager.availableTools.join(", ")}', tag: 'GeminiAI');
    return tools.isNotEmpty ? tools : null;
  }

  // Private constructor for factory use
  GeminiAIService._internal({
    required GenerativeModel baseModel,
    required AIToolsManager toolsManager,
  })  : _baseModel = baseModel,
        _toolsManager = toolsManager {
    _initStorage();
    
    // Log detailed tool availability
    if (_toolsManager.hasTools) {
      Logger.d('✓ AI Tools ready: ${_toolsManager.availableTools.join(", ")}', tag: 'GeminiAI');
    } else {
      Logger.w('⚠ No AI tools available - limited functionality', tag: 'GeminiAI');
    }
  }

  /// Factory constructor - creates AIToolsManager only ONCE
  factory GeminiAIService({
    required String apiKey,
    String? googleSearchApiKey,
    String? googleSearchEngineId,
    String? googlePlacesApiKey,
    String? rapidApiKey,
  }) {
    // Log API key availability for debugging
    Logger.d('Initializing GeminiAIService with tools:', tag: 'GeminiAI');
    Logger.d('  - Google Search: ${googleSearchApiKey != null && googleSearchEngineId != null ? "✓" : "✗"}', tag: 'GeminiAI');
    Logger.d('  - Google Places: ${googlePlacesApiKey != null ? "✓" : "✗"}', tag: 'GeminiAI');
    Logger.d('  - RapidAPI (Flights/Hotels): ${rapidApiKey != null ? "✓" : "✗"}', tag: 'GeminiAI');
    
    // Create tools manager ONCE - it handles all tools internally
    final toolsManager = AIToolsManager.withKeys(
      googleSearchApiKey: googleSearchApiKey,
      googleSearchEngineId: googleSearchEngineId,
      googlePlacesApiKey: googlePlacesApiKey,
      rapidApiKey: rapidApiKey,
    );

    // Create model with tools from the single manager instance
    final baseModel = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.text(buildEnhancedSystemPrompt()),
      tools: _createToolsForModel(toolsManager),
      generationConfig: GenerationConfig(
        temperature: AppConstants.aiTemperature,
        topK: AppConstants.aiTopK,
        topP: AppConstants.aiTopP,
        maxOutputTokens: AppConstants.aiMaxOutputTokens,
      ),
    );

    return GeminiAIService._internal(
      baseModel: baseModel,
      toolsManager: toolsManager,
    );
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

  /// **NEW: Generate Message Response**
  /// 
  /// Generates AI response as a structured message that can contain:
  /// - Text response (follow-up questions, descriptions, etc.)
  /// - Optional itinerary data
  /// - Both text and itinerary combined
  Future<ChatMessageModel> generateMessageResponse({
    required String sessionId,
    required String userMessage,
    String? userId,
  }) async {
    try {
      Logger.d('Generating message response for session: $sessionId', tag: 'GeminiAI');
      
      // Get session state first
      final sessionState = await getSession(sessionId);
      if (sessionState == null) {
        throw AIAgentException('Could not retrieve session: $sessionId');
      }
      
      // Get or create Hive session
      final hiveSession = await _getOrCreateHiveSession(sessionState, sessionId);
      
      // Build context prompt with user preferences and trip context
      final contextPrompt = hiveSession.buildRefinementContext();
      final fullPrompt = '''
$contextPrompt

User Request: $userMessage

IMPORTANT: Create a response based on the user's request and preferences above.
''';

      // Get Gemini chat session
      final chatSession = await _getOrCreateGeminiSession(hiveSession);
      
      // Send message
      var response = await chatSession.sendMessage(Content.text(fullPrompt)).timeout(
        const Duration(seconds: 45),
        onTimeout: () {
          throw TimeoutException('AI response timed out');
        },
      );

      // Handle function calls in a loop (Gemini may request multiple rounds)
      const maxFunctionCallRounds = 10; // Prevent infinite loops
      var functionCallRound = 0;
      
      while (response.functionCalls.isNotEmpty && functionCallRound < maxFunctionCallRounds) {
        functionCallRound++;
        Logger.d('Gemini requested ${response.functionCalls.length} function call(s) (round $functionCallRound)', tag: 'AITools');
        final functionResponses = <FunctionResponse>[];
        
        for (final call in response.functionCalls) {
          Logger.d('Processing ${call.name} function call', tag: 'AITools');
          try {
            final result = await _toolsManager.handleFunctionCall(call.name, call.args);
            functionResponses.add(FunctionResponse(call.name, result));
            Logger.d('${call.name} completed successfully', tag: 'AITools');
          } catch (e) {
            Logger.e('${call.name} failed: $e', tag: 'AITools');
            functionResponses.add(FunctionResponse(
              call.name,
              {'error': 'Function call failed: $e', 'results': []},
            ));
          }
        }
        
        response = await chatSession.sendMessage(Content.functionResponses(functionResponses)).timeout(
          const Duration(seconds: 45),
          onTimeout: () {
            throw TimeoutException('AI response timed out after function call');
          },
        );
      }
      
      if (functionCallRound >= maxFunctionCallRounds) {
        Logger.w('Max function call rounds reached ($maxFunctionCallRounds)', tag: 'AITools');
      }

      // Debug response structure
      Logger.d('Response candidates count: ${response.candidates.length}', tag: 'GeminiAI');
      if (response.candidates.isNotEmpty) {
        final firstCandidate = response.candidates.first;
        Logger.d('First candidate parts count: ${firstCandidate.content.parts.length}', tag: 'GeminiAI');
        Logger.d('Finish reason: ${firstCandidate.finishReason}', tag: 'GeminiAI');
        for (var i = 0; i < firstCandidate.content.parts.length; i++) {
          final part = firstCandidate.content.parts[i];
          if (part is TextPart) {
            Logger.d('Part $i (TextPart) length: ${part.text.length}', tag: 'GeminiAI');
          } else {
            Logger.d('Part $i type: ${part.runtimeType}', tag: 'GeminiAI');
          }
        }
      }
      
      // Get response text
      final responseText = response.text ?? '';
      Logger.d('AI response length: ${responseText.length}', tag: 'GeminiAI');

      // Track token usage
      final inputTokens = response.usageMetadata?.promptTokenCount ?? 0;
      final outputTokens = response.usageMetadata?.candidatesTokenCount ?? 0;
      final totalTokens = inputTokens + outputTokens;
      
      // Calculate cost and track tokens
      const inputCost = 0.30 / 1000000; // Gemini 2.5 Flash: $0.30 per 1M input tokens
      const outputCost = 2.50 / 1000000; // Gemini 2.5 Flash: $2.50 per 1M output tokens
      final cost = (inputTokens * inputCost) + (outputTokens * outputCost);
      
      TokenTrackingService().addUsage(
        promptTokens: inputTokens,
        completionTokens: outputTokens,
        cost: cost,
      );

      // Update session conversation history
      hiveSession.updateConversation(
        userMessage: Content.text(userMessage),
        aiResponse: Content.text(responseText),
        tokensUsed: totalTokens,
      );

      // Save session with debounced approach
      _debouncedSaveSession(hiveSession);

      // Parse response into structured message
      final message = AIResponseParser.parseResponse(
        sessionId: sessionId,
        aiResponse: responseText,
        tokenCount: totalTokens,
      );

      Logger.d('Generated message type: ${message.type}', tag: 'GeminiAI');
      Logger.d('Message has itinerary: ${message.hasItinerary}', tag: 'GeminiAI');

      // If message contains an itinerary, update the session's tripContext
      if (message.hasItinerary && message.itinerary != null) {
        hiveSession.tripContext['itinerary_title'] = message.itinerary!.title;
        hiveSession.tripContext['duration_days'] = message.itinerary!.durationDays;
        hiveSession.tripContext['start_date'] = message.itinerary!.startDate;
        hiveSession.tripContext['end_date'] = message.itinerary!.endDate;
        
        Logger.d('Updated session tripContext with itinerary_title: ${message.itinerary!.title}', tag: 'GeminiAI');
        Logger.d('Full tripContext: ${hiveSession.tripContext}', tag: 'GeminiAI');
        
        // Save the session again with updated tripContext
        _debouncedSaveSession(hiveSession);
      }

      return message;
      
    } on SocketException catch (e) {
      Logger.e('Network connection error: $e', tag: 'GeminiAI');
      throw AIAgentException('Network connection failed. Please check your internet connection and try again.');
    } on TimeoutException catch (e) {
      Logger.e('Request timeout error: $e', tag: 'GeminiAI');
      throw AIAgentException('Request timed out. Please try again with a simpler request.');
    } catch (e) {
      Logger.e('Error generating message response: $e', tag: 'GeminiAI');
      
      // Handle HandshakeException and certificate errors
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('handshakeexception') ||
          errorString.contains('certificate_verify_failed') ||
          errorString.contains('certificate')) {
        throw AIAgentException('Network security error. Please check your internet connection and try again.');
      }
      
      // Handle other network-related errors
      if (errorString.contains('failed host lookup') || 
          errorString.contains('socketexception') || 
          errorString.contains('network') ||
          errorString.contains('connection')) {
        throw AIAgentException('Network connection failed. Please check your internet connection and try again.');
      }
      
      // Generic error
      throw AIAgentException('Oops! The LLM failed to generate answer. Please regenerate.');
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
      
      // Send message and handle potential function calls
      var response = await chatSession.sendMessage(Content.text(fullPrompt))
          .timeout(const Duration(seconds: 45), onTimeout: () {
        throw TimeoutException('AI response timed out');
      });

      // Handle function calls in a loop (Gemini may request multiple rounds)
      const maxFunctionCallRounds = 10;
      var functionCallRound = 0;
      
      while (response.functionCalls.isNotEmpty && functionCallRound < maxFunctionCallRounds) {
        functionCallRound++;
        Logger.d('Gemini requested ${response.functionCalls.length} function call(s) (round $functionCallRound)', tag: 'AITools');
        
        final functionResponses = <FunctionResponse>[];
        
        for (final functionCall in response.functionCalls) {
          Logger.d('Processing ${functionCall.name} function call', tag: 'AITools');
          
          try {
            final result = await _toolsManager.handleFunctionCall(
              functionCall.name,
              functionCall.args,
            );
            functionResponses.add(FunctionResponse(functionCall.name, result));
            Logger.d('${functionCall.name} completed successfully', tag: 'AITools');
          } catch (e) {
            Logger.e('${functionCall.name} failed: $e', tag: 'AITools');
            functionResponses.add(FunctionResponse(
              functionCall.name, 
              {'error': 'Function call failed: $e', 'results': <Map<String, dynamic>>[]}
            ));
          }
        }
        
        response = await chatSession.sendMessage(Content.functionResponses(functionResponses))
            .timeout(const Duration(seconds: 45), onTimeout: () {
          throw TimeoutException('Function response timed out');
        });
      }
      
      if (functionCallRound >= maxFunctionCallRounds) {
        Logger.w('Max function call rounds reached in generateItinerary', tag: 'AITools');
      }

      // Debug the actual response with detailed inspection
      Logger.d('Response candidates count: ${response.candidates.length}', tag: 'HiveGeminiAI');
      if (response.candidates.isNotEmpty) {
        final firstCandidate = response.candidates.first;
        Logger.d('First candidate parts count: ${firstCandidate.content.parts.length}', tag: 'HiveGeminiAI');
        for (var i = 0; i < firstCandidate.content.parts.length; i++) {
          final part = firstCandidate.content.parts[i];
          if (part is TextPart) {
            Logger.d('Part $i (TextPart) length: ${part.text.length}', tag: 'HiveGeminiAI');
          } else {
            Logger.d('Part $i type: ${part.runtimeType}', tag: 'HiveGeminiAI');
          }
        }
      }
      
      final responseText = response.text ?? '';
      Logger.d('Full AI response length: ${responseText.length}', tag: 'HiveGeminiAI');
      Logger.d('Response complete: ${!responseText.contains('...') && responseText.contains('}')}', tag: 'HiveGeminiAI');
      
      if (responseText.length < 500) {
        Logger.d('Full short response: $responseText', tag: 'HiveGeminiAI');
      } else {
        Logger.d('Response start (500 chars): ${responseText.substring(0, 500)}...', tag: 'HiveGeminiAI');
        Logger.d('Response end (200 chars): ...${responseText.substring(responseText.length - 200)}', tag: 'HiveGeminiAI');
      }

      // Parse response - check for follow-up questions first
      try {
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
        final promptTokens = _estimateTokens(fullPrompt);
        final completionTokens = _estimateTokens(response.text ?? '');
        
        _tokenUsage.addUsage(
          promptTokens: promptTokens,
          completionTokens: completionTokens,
        );

        // Track globally for cost awareness (Gemini 2.5 Flash pricing)
        const inputCostPer1M = 0.30;
        const outputCostPer1M = 2.50;
        final cost = (promptTokens / 1000000) * inputCostPer1M + 
                     (completionTokens / 1000000) * outputCostPer1M;
        
        TokenTrackingService().addUsage(
          promptTokens: promptTokens,
          completionTokens: completionTokens,
          cost: cost,
        );

        // Save session to Hive (immediately for important updates)
        await _storage.saveSession(hiveSession);
        Logger.d('Session saved immediately for itinerary generation', tag: 'HiveGeminiAI');

        // Save itinerary to Hive with session reference
        final hiveItinerary = _convertToHiveItinerary(itinerary, sessionId: activeSessionId);
        await _storage.saveItinerary(hiveItinerary);

        return itinerary;
        
      } on FollowUpQuestionException catch (e) {
        // AI asked a follow-up question instead of generating itinerary
        Logger.d('AI asked follow-up question: ${e.question}', tag: 'HiveGeminiAI');
        
        // Still track token usage for the follow-up question
        final promptTokens = _estimateTokens(fullPrompt);
        final completionTokens = _estimateTokens(response.text ?? '');
        
        _tokenUsage.addUsage(
          promptTokens: promptTokens,
          completionTokens: completionTokens,
        );

        // Track globally for cost awareness
        const inputCostPer1M = 0.30;
        const outputCostPer1M = 2.50;
        final cost = (promptTokens / 1000000) * inputCostPer1M + 
                     (completionTokens / 1000000) * outputCostPer1M;
        
        TokenTrackingService().addUsage(
          promptTokens: promptTokens,
          completionTokens: completionTokens,
          cost: cost,
        );

        // Update session with the follow-up question
        hiveSession.updateConversation(
          userMessage: Content.text(userPrompt),
          aiResponse: Content.model([TextPart(response.text ?? '')]),
          tokensUsed: promptTokens + completionTokens,
          tokensSavedFromReuse: 0,
        );

        // Save session to preserve the conversation
        await _storage.saveSession(hiveSession);
        Logger.d('Session saved with follow-up question', tag: 'HiveGeminiAI');

        // Re-throw the exception so MessageBasedChatBloc can handle it
        rethrow;
      }
      
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
      
      // Send message and handle potential function calls
      var response = await chatSession.sendMessage(Content.text(userPrompt))
          .timeout(const Duration(seconds: 60), onTimeout: () {
        throw TimeoutException('AI response timed out');
      });

      // Handle function calls in a loop (Gemini may request multiple rounds)
      const maxFunctionCallRounds = 10;
      var functionCallRound = 0;
      
      while (response.functionCalls.isNotEmpty && functionCallRound < maxFunctionCallRounds) {
        functionCallRound++;
        Logger.d('Gemini requested ${response.functionCalls.length} function call(s) during refinement (round $functionCallRound)', tag: 'AITools');
        
        final functionResponses = <FunctionResponse>[];
        
        for (final functionCall in response.functionCalls) {
          Logger.d('Processing ${functionCall.name} function call', tag: 'AITools');
          
          try {
            // Use the unified tools manager for all function calls
            final result = await _toolsManager.handleFunctionCall(
              functionCall.name,
              functionCall.args,
            );
            functionResponses.add(FunctionResponse(functionCall.name, result));
            Logger.d('${functionCall.name} completed successfully', tag: 'AITools');
          } catch (e) {
            Logger.e('${functionCall.name} failed: $e', tag: 'AITools');
            functionResponses.add(FunctionResponse(
              functionCall.name, 
              {'error': 'Function call failed: $e', 'results': <Map<String, dynamic>>[]}
            ));
          }
        }
        
        response = await chatSession.sendMessage(Content.functionResponses(functionResponses))
            .timeout(const Duration(seconds: 45), onTimeout: () {
          throw TimeoutException('Function response timed out');
        });
      }
      
      if (functionCallRound >= maxFunctionCallRounds) {
        Logger.w('Max function call rounds reached in refineItinerary', tag: 'AITools');
      }

      final responseText = response.text ?? '';
      
      // Calculate savings
      final tokensUsed = _estimateTokens(userPrompt) + _estimateTokens(responseText);
      final tokensSaved = _calculateTokensSaved(hiveSession);

      // Calculate token usage (for both success and follow-up question cases)
      final promptTokens = _estimateTokens(userPrompt);
      final completionTokens = _estimateTokens(responseText);

      // Parse refined itinerary - check for follow-up questions first
      try {
        final refinedJson = _extractItineraryFromResponse(responseText);
        final refinedItinerary = ItineraryModel.fromJson(refinedJson);

        // Update session
        hiveSession.updateConversation(
          userMessage: Content.text(userPrompt),
          aiResponse: Content.model([TextPart(responseText)]),
          tokensUsed: tokensUsed,
          tokensSavedFromReuse: tokensSaved,
        );

        // Track usage with savings
        _tokenUsage.addUsage(
          promptTokens: promptTokens,
          completionTokens: completionTokens,
          tokensSaved: tokensSaved,
        );

        // Track globally for cost awareness (Gemini 2.5 Flash pricing)
        const inputCostPer1M = 0.30;
        const outputCostPer1M = 2.50;
        final cost = (promptTokens / 1000000) * inputCostPer1M + 
                     (completionTokens / 1000000) * outputCostPer1M;
        
        TokenTrackingService().addUsage(
          promptTokens: promptTokens,
          completionTokens: completionTokens,
          cost: cost,
        );

        // Save session
        _debouncedSaveSession(hiveSession);

        // Save refined itinerary with session reference
        final hiveItinerary = _convertToHiveItinerary(refinedItinerary, sessionId: sessionId);
        await _storage.saveItinerary(hiveItinerary);

        return refinedItinerary;
        
      } on FollowUpQuestionException catch (e) {
        // AI asked a follow-up question during refinement
        Logger.d('AI asked follow-up question during refinement: ${e.question}', tag: 'HiveGeminiAI');
        
        // Still track token usage and update conversation
        hiveSession.updateConversation(
          userMessage: Content.text(userPrompt),
          aiResponse: Content.model([TextPart(responseText)]),
          tokensUsed: tokensUsed,
          tokensSavedFromReuse: tokensSaved,
        );
        
        // Track usage with savings
        _tokenUsage.addUsage(
          promptTokens: promptTokens,
          completionTokens: completionTokens,
          tokensSaved: tokensSaved,
        );

        // Track globally for cost awareness
        const inputCostPer1M = 0.30;
        const outputCostPer1M = 2.50;
        final cost = (promptTokens / 1000000) * inputCostPer1M + 
                     (completionTokens / 1000000) * outputCostPer1M;
        
        TokenTrackingService().addUsage(
          promptTokens: promptTokens,
          completionTokens: completionTokens,
          cost: cost,
        );
        
        // Save session
        _debouncedSaveSession(hiveSession);
        
        // Re-throw the exception so MessageBasedChatBloc can handle it
        rethrow;
      }
      
    } catch (e) {
      if (e is FollowUpQuestionException) {
        rethrow; // Let the chat system handle this
      }
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

  HiveItineraryModel _convertToHiveItinerary(ItineraryModel itinerary, {String? sessionId}) {
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
      sessionId: sessionId, // Link itinerary to session
    );
  }

  Map<String, dynamic> _extractItineraryFromResponse(String response) {
    try {
      _logResponseEndingDetails(response);

      
      // Clean the response - remove any leading/trailing whitespace
      final cleanedResponse = response.trim();
      Logger.d('Raw AI response start: ${cleanedResponse.substring(0, min(500, cleanedResponse.length))}', tag: 'HiveGeminiAI');

      // CHECK FOR FOLLOW-UP QUESTIONS FIRST
      if (cleanedResponse.toUpperCase().startsWith('FOLLOWUP:')) {
        final question = cleanedResponse.substring(9).trim(); // Remove "FOLLOWUP:" prefix
        Logger.d('Detected follow-up question: $question', tag: 'HiveGeminiAI');
        throw FollowUpQuestionException(question);
      }

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
      
    } on FollowUpQuestionException {
      // Re-throw follow-up questions - don't create fallback itinerary
      rethrow;
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
  
  /// Dispose of resources to prevent memory leaks
  void dispose() {
    Logger.d('Disposing GeminiAIService resources', tag: 'GeminiAI');
    
    // Cancel debounce timer
    _saveDebounceTimer?.cancel();
    _saveDebounceTimer = null;
    
    // Clear pending saves
    _pendingSaves.clear();
    
    // Clear session caches
    _geminiSessions.clear();
    _sessionLastUsed.clear();
    
    // Dispose web search tool if present (via tools manager)
    _toolsManager.webSearchTool?.dispose();
    
    Logger.d('GeminiAIService disposed successfully', tag: 'GeminiAI');
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
    // Gemini 2.5 Flash pricing: $0.30/1M input tokens, $2.50/1M output tokens
    const inputCostPer1MTokens = 0.30;
    const outputCostPer1MTokens = 2.50;
    
    final inputCost = (_totalPromptTokens / 1000000) * inputCostPer1MTokens;
    final outputCost = (_totalCompletionTokens / 1000000) * outputCostPer1MTokens;
    
    return inputCost + outputCost;
  }

  double get estimatedSavingsUSD {
    // Use average token cost for savings calculation
    const avgCostPer1MTokens = 1.40; // Average of input and output costs
    return (_tokensSaved / 1000000 * avgCostPer1MTokens);
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
  static AIAgentService create({
    required String geminiApiKey,
    String? googleSearchApiKey,
    String? googleSearchEngineId,
    String? bingSearchApiKey,
    String? googlePlacesApiKey,
    String? rapidApiKey,
  }) {
    return GeminiAIService(
      apiKey: geminiApiKey,
      googleSearchApiKey: googleSearchApiKey,
      googleSearchEngineId: googleSearchEngineId,
      googlePlacesApiKey: googlePlacesApiKey,
      rapidApiKey: rapidApiKey,
    );
  }
  
  /// Dispose of AI service resources (timers, http clients, etc.)
  static void dispose(AIAgentService service) {
    if (service is GeminiAIService) {
      service.dispose();
    }
  }
}
