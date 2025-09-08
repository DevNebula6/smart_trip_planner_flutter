import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import '../../../ai_agent/services/ai_agent_service.dart';
import '../../../ai_agent/models/trip_session_model.dart';
import '../../../core/storage/hive_storage_service.dart';
import '../../../core/storage/hive_models.dart';
import '../../../trip_planning_chat/data/models/itinerary_models.dart';
import '../../../core/utils/helpers.dart';

// ===== CHAT EVENTS =====
abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize chat with new prompt
class InitializeChatWithPrompt extends ChatEvent {
  final String userId;
  final String initialPrompt;
  
  const InitializeChatWithPrompt({
    required this.userId,
    required this.initialPrompt,
  });
  
  @override
  List<Object?> get props => [userId, initialPrompt];
}

/// Initialize chat with existing session
class InitializeChatWithSession extends ChatEvent {
  final String sessionId;
  
  const InitializeChatWithSession({required this.sessionId});
  
  @override
  List<Object?> get props => [sessionId];
}

/// Send user message
class SendMessage extends ChatEvent {
  final String message;
  final bool isRefinement;
  
  const SendMessage({
    required this.message,
    this.isRefinement = false,
  });
  
  @override
  List<Object?> get props => [message, isRefinement];
}

/// Regenerate itinerary
class RegenerateItinerary extends ChatEvent {
  final String? refinementPrompt;
  
  const RegenerateItinerary({this.refinementPrompt});
  
  @override
  List<Object?> get props => [refinementPrompt];
}

/// Save current session
class SaveSession extends ChatEvent {
  const SaveSession();
}

/// Clear current session
class ClearSession extends ChatEvent {
  const ClearSession();
}

/// Load conversation history
class LoadConversationHistory extends ChatEvent {
  const LoadConversationHistory();
}

// ===== CHAT STATES =====
abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatInitialized extends ChatState {
  final SessionState session;
  final List<ChatMessageModel> messages;
  final ItineraryModel? currentItinerary;
  
  const ChatInitialized({
    required this.session,
    required this.messages,
    this.currentItinerary,
  });
  
  @override
  List<Object?> get props => [session, messages, currentItinerary];
}

class ChatMessageSending extends ChatState {
  final SessionState session;
  final List<ChatMessageModel> messages;
  final ItineraryModel? currentItinerary;
  final String pendingMessage;
  
  const ChatMessageSending({
    required this.session,
    required this.messages,
    required this.pendingMessage,
    this.currentItinerary,
  });
  
  @override
  List<Object?> get props => [session, messages, currentItinerary, pendingMessage];
}

class ChatMessageReceived extends ChatState {
  final SessionState session;
  final List<ChatMessageModel> messages;
  final ItineraryModel? currentItinerary;
  final String? newItineraryGenerated;
  
  const ChatMessageReceived({
    required this.session,
    required this.messages,
    this.currentItinerary,
    this.newItineraryGenerated,
  });
  
  @override
  List<Object?> get props => [session, messages, currentItinerary, newItineraryGenerated];
}

class ChatGeneratingItinerary extends ChatState {
  final SessionState session;
  final List<ChatMessageModel> messages;
  final ItineraryModel? currentItinerary;
  
  const ChatGeneratingItinerary({
    required this.session,
    required this.messages,
    this.currentItinerary,
  });
  
  @override
  List<Object?> get props => [session, messages, currentItinerary];
}

class ChatItineraryGenerated extends ChatState {
  final SessionState session;
  final List<ChatMessageModel> messages;
  final ItineraryModel currentItinerary;
  final bool isRefinement;
  
  const ChatItineraryGenerated({
    required this.session,
    required this.messages,
    required this.currentItinerary,
    this.isRefinement = false,
  });
  
  @override
  List<Object?> get props => [session, messages, currentItinerary, isRefinement];
}

class ChatSessionSaved extends ChatState {
  final SessionState session;
  final List<ChatMessageModel> messages;
  final ItineraryModel? currentItinerary;
  
  const ChatSessionSaved({
    required this.session,
    required this.messages,
    this.currentItinerary,
  });
  
  @override
  List<Object?> get props => [session, messages, currentItinerary];
}

class ChatError extends ChatState {
  final String message;
  final SessionState? session;
  final List<ChatMessageModel>? messages;
  final ItineraryModel? currentItinerary;
  
  const ChatError({
    required this.message,
    this.session,
    this.messages,
    this.currentItinerary,
  });
  
  @override
  List<Object?> get props => [message, session, messages, currentItinerary];
}

// ===== CHAT BLOC =====
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final AIAgentService _aiService;
  final HiveStorageService _storageService;
  
  // Current session data
  SessionState? _currentSession;
  List<ChatMessageModel> _messages = [];
  ItineraryModel? _currentItinerary;

  ChatBloc({
    required AIAgentService aiService,
    required HiveStorageService storageService,
  }) : _aiService = aiService,
       _storageService = storageService,
       super(ChatInitial()) {
    
    on<InitializeChatWithPrompt>(_onInitializeChatWithPrompt);
    on<InitializeChatWithSession>(_onInitializeChatWithSession);
    on<SendMessage>(_onSendMessage);
    on<RegenerateItinerary>(_onRegenerateItinerary);
    on<SaveSession>(_onSaveSession);
    on<ClearSession>(_onClearSession);
    on<LoadConversationHistory>(_onLoadConversationHistory);
  }

  // ===== EVENT HANDLERS =====

  /// Initialize chat with new prompt
  Future<void> _onInitializeChatWithPrompt(
    InitializeChatWithPrompt event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(ChatLoading());
      
      Logger.d('Initializing new chat session for user: ${event.userId}', tag: 'ChatBloc');
      
      // Create new session using AI service
      final sessionId = await _aiService.getOrCreateSession(userId: event.userId);
      final session = await _aiService.getSession(sessionId);
      
      if (session == null) {
        throw Exception('Failed to create session');
      }
      
      _currentSession = session;
      _messages = [];
      _currentItinerary = null;
      
      Logger.d('New session created: ${session.sessionId}', tag: 'ChatBloc');
      
      emit(ChatInitialized(
        session: session,
        messages: _messages,
        currentItinerary: _currentItinerary,
      ));
      
      // Automatically send the initial prompt
      add(SendMessage(message: event.initialPrompt));
      
    } catch (error) {
      Logger.e('Failed to initialize chat with prompt: $error', tag: 'ChatBloc');
      emit(ChatError(message: 'Failed to start new chat: $error'));
    }
  }

  /// Initialize chat with existing session
  Future<void> _onInitializeChatWithSession(
    InitializeChatWithSession event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(ChatLoading());
      
      Logger.d('Loading existing session: ${event.sessionId}', tag: 'ChatBloc');
      
      // Load session from storage
      final hiveSession = await _storageService.getSession(event.sessionId);
      if (hiveSession == null) {
        throw Exception('Session not found: ${event.sessionId}');
      }
      
      // Convert to SessionState
      _currentSession = _convertHiveSessionToSessionState(hiveSession);
      
      // Try to extract current itinerary from storage first (more reliable)
      _currentItinerary = await _extractItineraryFromSession(_currentSession!);
      
      // Load conversation history as chat messages
      _messages = await _loadChatMessages(_currentSession!);
      
      // If we found an itinerary but conversation history is minimal or generic,
      // reconstruct it to show meaningful content
      if (_currentItinerary != null && _messages.length <= 2) {
        Logger.d('Reconstructing chat messages for better session restoration', tag: 'ChatBloc');
        
        // Find the user's original prompt from tripContext or messages
        String originalPrompt = 'Create an itinerary';
        if (_messages.isNotEmpty && _messages.first.role == 'user') {
          originalPrompt = _messages.first.content;
        }
        
        // Create meaningful messages that show the itinerary was created
        _messages = [
          ChatMessageModel(
            id: '${_currentSession!.sessionId}_user',
            itineraryId: _currentSession!.sessionId,
            content: originalPrompt,
            role: 'user',
            timestamp: _currentSession!.createdAt,
          ),
          ChatMessageModel(
            id: '${_currentSession!.sessionId}_assistant',
            itineraryId: _currentSession!.sessionId,
            content: "I've created your personalized itinerary: \"${_currentItinerary!.title}\". It's a ${_currentItinerary!.days.length}-day trip from ${_currentItinerary!.startDate} to ${_currentItinerary!.endDate}. You can ask me to modify any part of it!",
            role: 'assistant',
            timestamp: _currentSession!.createdAt.add(const Duration(minutes: 1)),
          ),
        ];
      }
      
      Logger.d('Session loaded with ${_messages.length} messages and itinerary: ${_currentItinerary?.title ?? 'none'}', tag: 'ChatBloc');
      
      // Always emit ChatItineraryGenerated if we have an itinerary to show it properly
      if (_currentItinerary != null) {
        emit(ChatItineraryGenerated(
          session: _currentSession!,
          messages: List.from(_messages),
          currentItinerary: _currentItinerary!,
          isRefinement: false,
        ));
      } else {
        emit(ChatInitialized(
          session: _currentSession!,
          messages: List.from(_messages),
          currentItinerary: _currentItinerary,
        ));
      }
      
    } catch (error) {
      Logger.e('Failed to initialize chat with session: $error', tag: 'ChatBloc');
      emit(ChatError(message: 'Failed to load chat session: $error'));
    }
  }

  /// Send user message
  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentSession == null) {
      emit(const ChatError(message: 'No active session'));
      return;
    }

    try {
      // Add user message to UI
      final userMessage = ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        itineraryId: _currentSession!.sessionId,
        content: event.message,
        role: 'user',
        timestamp: DateTime.now(),
      );
      
      _messages.add(userMessage);
      
      emit(ChatMessageSending(
        session: _currentSession!,
        messages: List.from(_messages),
        pendingMessage: event.message,
        currentItinerary: _currentItinerary,
      ));
      
      Logger.d('Sending message to AI: ${event.message}', tag: 'ChatBloc');
      
      // Use AI service to generate or refine itinerary based on message context
      ItineraryModel aiResponse;
      String responseContent;
      
      if (event.isRefinement && _currentItinerary != null) {
        // This is a refinement request
        aiResponse = await _aiService.refineItinerary(
          userPrompt: event.message,
          sessionId: _currentSession!.sessionId,
          userId: _currentSession!.userId,
        );
        responseContent = "I've updated your itinerary based on your refinements:";
      } else {
        // This is a new itinerary generation request
        aiResponse = await _aiService.generateItinerary(
          userPrompt: event.message,
          userId: _currentSession!.userId,
          sessionId: _currentSession!.sessionId,
        );
        responseContent = "Here's your personalized itinerary:";
      }
      
      // Add AI response to messages
      final aiMessage = ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        itineraryId: _currentSession!.sessionId,
        content: responseContent,
        role: 'assistant',
        timestamp: DateTime.now(),
      );
      
      _messages.add(aiMessage);
      _currentItinerary = aiResponse;
      
      Logger.d('New itinerary generated: ${aiResponse.title}', tag: 'ChatBloc');
      
      emit(ChatItineraryGenerated(
        session: _currentSession!,
        messages: List.from(_messages),
        currentItinerary: aiResponse,
        isRefinement: event.isRefinement,
      ));
      
      // Save session immediately after generating itinerary to preserve the conversation
      Logger.d('Auto-saving session after itinerary generation', tag: 'ChatBloc');
      await _updateSessionInStorage();
      
    } catch (error) {
      Logger.e('Failed to send message: $error', tag: 'ChatBloc');
      
      // Remove the failed user message
      if (_messages.isNotEmpty && _messages.last.role == 'user') {
        _messages.removeLast();
      }
      
      emit(ChatError(
        message: 'Failed to send message: $error',
        session: _currentSession,
        messages: _messages,
        currentItinerary: _currentItinerary,
      ));
    }
  }

  /// Regenerate itinerary
  Future<void> _onRegenerateItinerary(
    RegenerateItinerary event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentSession == null) {
      emit(const ChatError(message: 'No active session'));
      return;
    }

    try {
      emit(ChatGeneratingItinerary(
        session: _currentSession!,
        messages: List.from(_messages),
        currentItinerary: _currentItinerary,
      ));
      
      Logger.d('Regenerating itinerary', tag: 'ChatBloc');
      
      String regeneratePrompt = 'Please regenerate the itinerary';
      if (event.refinementPrompt != null && event.refinementPrompt!.isNotEmpty) {
        regeneratePrompt += ' with these changes: ${event.refinementPrompt}';
      }
      
      // Send regeneration request
      add(SendMessage(message: regeneratePrompt, isRefinement: true));
      
    } catch (error) {
      Logger.e('Failed to regenerate itinerary: $error', tag: 'ChatBloc');
      emit(ChatError(
        message: 'Failed to regenerate itinerary: $error',
        session: _currentSession,
        messages: _messages,
        currentItinerary: _currentItinerary,
      ));
    }
  }

  /// Save current session
  Future<void> _onSaveSession(
    SaveSession event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentSession == null) return;

    try {
      Logger.d('Saving session: ${_currentSession!.sessionId}', tag: 'ChatBloc');
      
      // Update session with current conversation
      await _updateSessionInStorage();
      
      // Don't emit a new state for auto-saves to avoid UI disruption
      // Only emit if current state is not already showing content
      if (state is! ChatMessageReceived && 
          state is! ChatItineraryGenerated && 
          state is! ChatInitialized) {
        emit(ChatSessionSaved(
          session: _currentSession!,
          messages: List.from(_messages),
          currentItinerary: _currentItinerary,
        ));
      }
      
    } catch (error) {
      Logger.e('Failed to save session: $error', tag: 'ChatBloc');
      // Don't emit error for save failures to avoid disrupting user experience
    }
  }

  /// Clear current session
  Future<void> _onClearSession(
    ClearSession event,
    Emitter<ChatState> emit,
  ) async {
    try {
      if (_currentSession != null) {
        Logger.d('Clearing session: ${_currentSession!.sessionId}', tag: 'ChatBloc');
        await _aiService.clearSession(_currentSession!.sessionId);
      }
      
      _currentSession = null;
      _messages.clear();
      _currentItinerary = null;
      
      emit(ChatInitial());
      
    } catch (error) {
      Logger.e('Failed to clear session: $error', tag: 'ChatBloc');
      emit(ChatError(message: 'Failed to clear session: $error'));
    }
  }

  /// Load conversation history
  Future<void> _onLoadConversationHistory(
    LoadConversationHistory event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentSession == null) return;

    try {
      Logger.d('Loading conversation history', tag: 'ChatBloc');
      
      _messages = await _loadChatMessages(_currentSession!);
      
      emit(ChatInitialized(
        session: _currentSession!,
        messages: List.from(_messages),
        currentItinerary: _currentItinerary,
      ));
      
    } catch (error) {
      Logger.e('Failed to load conversation history: $error', tag: 'ChatBloc');
      emit(ChatError(
        message: 'Failed to load conversation: $error',
        session: _currentSession,
        messages: _messages,
        currentItinerary: _currentItinerary,
      ));
    }
  }

  // ===== HELPER METHODS =====

  /// Convert HiveSessionState to SessionState
  SessionState _convertHiveSessionToSessionState(HiveSessionState hiveSession) {
    return SessionState(
      sessionId: hiveSession.sessionId,
      userId: hiveSession.userId,
      createdAt: hiveSession.createdAt,
      lastUsed: hiveSession.lastUsed,
      conversationHistory: hiveSession.conversationHistory
          .map((hiveContent) => hiveContent.toContent())
          .toList(),
      userPreferences: Map<String, dynamic>.from(hiveSession.userPreferences),
      tripContext: Map<String, dynamic>.from(hiveSession.tripContext),
      tokensSaved: hiveSession.tokensSaved,
      messagesInSession: hiveSession.messagesInSession,
      estimatedCostSavings: hiveSession.estimatedCostSavings,
      refinementCount: hiveSession.refinementCount,
      isActive: hiveSession.isActive,
    );
  }

  /// Load chat messages from session history
  Future<List<ChatMessageModel>> _loadChatMessages(SessionState session) async {
    final messages = <ChatMessageModel>[];
    
    Logger.d('Loading chat messages from session with ${session.conversationHistory.length} history items', tag: 'ChatBloc');
    
    for (int i = 0; i < session.conversationHistory.length; i++) {
      final content = session.conversationHistory[i];
      final role = content.role;
      
      // Extract text from parts - handle different part types
      String text = '';
      if (content.parts.isNotEmpty) {
        final part = content.parts.first;
        if (part is TextPart) {
          text = part.text;
        } else {
          text = part.toString(); // Fallback
        }
      }
      
      Logger.d('Loading message $i: role=$role, content=${text.length > 100 ? text.substring(0, 100) + '...' : text}', tag: 'ChatBloc');
      
      final message = ChatMessageModel(
        id: '${session.sessionId}_$i',
        itineraryId: session.sessionId,
        content: text,
        role: role ?? 'user',
        timestamp: session.createdAt.add(Duration(minutes: i)),
      );
      
      messages.add(message);
    }
    
    Logger.d('Loaded ${messages.length} chat messages from session history', tag: 'ChatBloc');
    return messages;
  }

  /// Extract itinerary from session (if exists)
  Future<ItineraryModel?> _extractItineraryFromSession(SessionState session) async {
    Logger.d('Extracting itinerary from session ${session.sessionId} with ${session.conversationHistory.length} messages', tag: 'ChatBloc');
    
    // First try to find stored itineraries for this specific session
    try {
      final allItineraries = await _storageService.getAllItineraries();
      
      Logger.d('Found ${allItineraries.length} total stored itineraries', tag: 'ChatBloc');
      
      // Look for itineraries that match this session based on timing and session ID
      final sessionItineraries = allItineraries.where((itinerary) {
        // Check if the itinerary was created around the same time as this session
        final sessionTime = session.createdAt;
        final itineraryTime = itinerary.createdAt ?? DateTime.now();
        final timeDifference = (sessionTime.difference(itineraryTime)).abs();
        
        // Consider it a match if created within 5 minutes of each other
        final isTimeMatch = timeDifference.inMinutes <= 5;
        
        // Also check if session ID parts match with itinerary ID
        final sessionTimestamp = session.sessionId.split('_').last;
        final isIdMatch = itinerary.id.contains(sessionTimestamp);
        
        Logger.d('Checking itinerary ${itinerary.title}: timeMatch=$isTimeMatch, idMatch=$isIdMatch', tag: 'ChatBloc');
        
        return isTimeMatch || isIdMatch;
      }).toList();
      
      if (sessionItineraries.isNotEmpty) {
        // Sort by creation date and get the most recent
        sessionItineraries.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
        final mostRecentItinerary = sessionItineraries.first;
        
        Logger.d('Found matching stored itinerary: ${mostRecentItinerary.title}', tag: 'ChatBloc');
        
        // Convert HiveItineraryModel to ItineraryModel
        final itinerary = ItineraryModel(
          id: session.sessionId,
          title: mostRecentItinerary.title,
          startDate: mostRecentItinerary.startDate,
          endDate: mostRecentItinerary.endDate,
          days: mostRecentItinerary.days.map((hiveDay) => DayPlanModel(
            date: hiveDay.date,
            summary: hiveDay.summary,
            items: hiveDay.items.map((hiveItem) => ActivityItemModel(
              time: hiveItem.time,
              activity: hiveItem.activity,
              location: hiveItem.location,
            )).toList(),
          )).toList(),
          originalPrompt: mostRecentItinerary.originalPrompt,
          createdAt: mostRecentItinerary.createdAt,
          updatedAt: mostRecentItinerary.updatedAt,
        );
        
        Logger.d('Successfully converted itinerary: ${itinerary.title} (${itinerary.days.length} days)', tag: 'ChatBloc');
        return itinerary;
      } else {
        Logger.w('No matching itineraries found for session ${session.sessionId}', tag: 'ChatBloc');
      }
    } catch (e) {
      Logger.w('Failed to load stored itineraries: $e', tag: 'ChatBloc');
    }
    
    // Fallback: Look for itinerary in the conversation history
    Logger.d('Falling back to extracting itinerary from conversation history', tag: 'ChatBloc');
    for (final content in session.conversationHistory.reversed) { // Start from most recent
      if (content.role == 'model' && content.parts.isNotEmpty) {
        final part = content.parts.first;
        String text = '';
        if (part is TextPart) {
          text = part.text;
        } else {
          text = part.toString();
        }
        
        // Try to parse JSON itinerary from the AI response
        try {
          final itinerary = await _parseItineraryFromText(text);
          if (itinerary != null) {
            Logger.d('Successfully extracted itinerary from conversation history: ${itinerary.title}', tag: 'ChatBloc');
            return itinerary;
          }
        } catch (e) {
          Logger.w('Failed to parse itinerary from conversation: $e', tag: 'ChatBloc');
          // Continue searching if parsing fails
        }
      }
    }
    
    Logger.d('No itinerary found in session ${session.sessionId}', tag: 'ChatBloc');
    return null;
  }

  /// Parse itinerary from AI response text
  Future<ItineraryModel?> _parseItineraryFromText(String text) async {
    try {
      Logger.d('Attempting to parse itinerary from text: ${text.substring(0, text.length > 100 ? 100 : text.length)}...', tag: 'ChatBloc');
      
      // Try to find JSON block with triple backticks first
      final codeBlockMatch = RegExp(r'```json\s*(.*?)\s*```', dotAll: true).firstMatch(text);
      if (codeBlockMatch != null) {
        final jsonString = codeBlockMatch.group(1)!.trim();
        try {
          final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
          if (jsonData.containsKey('title') && 
              jsonData.containsKey('days') && 
              jsonData.containsKey('startDate')) {
            return ItineraryModel.fromJson(jsonData);
          }
        } catch (e) {
          Logger.w('Failed to parse JSON from code block: $e', tag: 'ChatBloc');
        }
      }
      
      // Look for JSON blocks in the text with better bracket matching
      final jsonStart = text.indexOf('{');
      int jsonEnd = -1;
      
      if (jsonStart != -1) {
        int braceCount = 0;
        for (int i = jsonStart; i < text.length; i++) {
          if (text[i] == '{') {
            braceCount++;
          } else if (text[i] == '}') {
            braceCount--;
            if (braceCount == 0) {
              jsonEnd = i + 1;
              break;
            }
          }
        }
      }
      
      if (jsonStart != -1 && jsonEnd > jsonStart) {
        final jsonString = text.substring(jsonStart, jsonEnd);
        Logger.d('Extracted JSON string: ${jsonString.substring(0, jsonString.length > 100 ? 100 : jsonString.length)}...', tag: 'ChatBloc');
        
        final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
        
        // Check if it looks like an itinerary
        if (jsonData.containsKey('title') && 
            jsonData.containsKey('days') && 
            jsonData.containsKey('startDate')) {
          return ItineraryModel.fromJson(jsonData);
        }
      }
    } catch (e) {
      Logger.d('Failed to parse itinerary from text: $e', tag: 'ChatBloc');
    }
    
    return null;
  }

  /// Update session in storage with current state
  Future<void> _updateSessionInStorage() async {
    if (_currentSession == null) return;
    
    try {
      Logger.d('Updating session ${_currentSession!.sessionId} with ${_messages.length} messages', tag: 'ChatBloc');
      
      // First, get the latest session from storage to preserve any updates made by other services (like GeminiService)
      final latestHiveSession = await _storageService.getSession(_currentSession!.sessionId);
      final latestTripContext = latestHiveSession?.tripContext ?? _currentSession!.tripContext;
      final latestUserPreferences = latestHiveSession?.userPreferences ?? _currentSession!.userPreferences;
      
      Logger.d('Preserving tripContext from storage: $latestTripContext', tag: 'ChatBloc');
      
      // Convert messages back to Content objects
      final updatedHistory = <Content>[];
      
      for (final message in _messages) {
        // Create proper Content objects based on role
        if (message.role == 'assistant' || message.role == 'model') {
          // AI messages should have 'model' role for Gemini
          updatedHistory.add(Content('model', [TextPart(message.content)]));
        } else {
          // User messages should have 'user' role
          updatedHistory.add(Content('user', [TextPart(message.content)]));
        }
      }
      
      Logger.d('Converted ${_messages.length} messages to ${updatedHistory.length} Content objects', tag: 'ChatBloc');
      
      // Update session with new conversation history and preserved context data
      final updatedSession = SessionState(
        sessionId: _currentSession!.sessionId,
        userId: _currentSession!.userId,
        createdAt: _currentSession!.createdAt,
        lastUsed: DateTime.now(), // Update last used time
        conversationHistory: updatedHistory,
        userPreferences: latestUserPreferences, // Use latest from storage
        tripContext: latestTripContext, // Use latest from storage
        tokensSaved: _currentSession!.tokensSaved,
        messagesInSession: _messages.length,
        estimatedCostSavings: _currentSession!.estimatedCostSavings,
        refinementCount: _currentSession!.refinementCount,
        isActive: true,
      );
      
      _currentSession = updatedSession;
      
      // Convert to Hive format and save
      final hiveSession = _convertSessionStateToHiveSession(updatedSession);
      await _storageService.saveSession(hiveSession);
      
      Logger.d('Session saved successfully with ${hiveSession.conversationHistory.length} history items', tag: 'ChatBloc');
      
    } catch (error) {
      Logger.e('Failed to update session in storage: $error', tag: 'ChatBloc');
      throw error; // Re-throw to handle in calling method
    }
  }

  /// Convert SessionState to HiveSessionState
  HiveSessionState _convertSessionStateToHiveSession(SessionState session) {
    return HiveSessionState(
      sessionId: session.sessionId,
      userId: session.userId,
      createdAt: session.createdAt,
      lastUsed: session.lastUsed,
      conversationHistory: session.conversationHistory
          .map((content) => HiveContentModel.fromContent(content))
          .toList(),
      userPreferences: session.userPreferences,
      tripContext: session.tripContext,
      tokensSaved: session.tokensSaved,
      messagesInSession: session.messagesInSession,
      estimatedCostSavings: session.estimatedCostSavings,
      refinementCount: session.refinementCount,
      isActive: session.isActive,
    );
  }

  // ===== GETTERS =====
  SessionState? get currentSession => _currentSession;
  List<ChatMessageModel> get messages => List.from(_messages);
  ItineraryModel? get currentItinerary => _currentItinerary;

  @override
  Future<void> close() {
    // Auto-save before closing
    if (_currentSession != null) {
      _updateSessionInStorage();
    }
    return super.close();
  }
}
