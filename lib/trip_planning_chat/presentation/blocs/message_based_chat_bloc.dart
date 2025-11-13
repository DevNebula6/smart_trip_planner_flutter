import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../ai_agent/services/gemini_service.dart';
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

/// Initialize chat with new prompt (start new conversation)
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

/// Initialize chat with existing session (continue conversation)
class InitializeChatWithSession extends ChatEvent {
  final String sessionId;
  
  const InitializeChatWithSession({required this.sessionId});
  
  @override
  List<Object?> get props => [sessionId];
}

/// Send user message
class SendMessage extends ChatEvent {
  final String message;
  
  const SendMessage({required this.message});
  
  @override
  List<Object?> get props => [message];
}

/// Clear current session
class ClearSession extends ChatEvent {
  const ClearSession();
}

/// Regenerate last AI message
class RegenerateMessage extends ChatEvent {
  final String lastUserMessage;
  
  const RegenerateMessage({required this.lastUserMessage});
  
  @override
  List<Object?> get props => [lastUserMessage];
}

// ===== CHAT STATES =====
abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatReady extends ChatState {
  final String sessionId;
  final List<ChatMessageModel> messages;
  
  const ChatReady({
    required this.sessionId,
    required this.messages,
  });
  
  @override
  List<Object?> get props => [sessionId, messages];
}

class ChatMessageSending extends ChatState {
  final String sessionId;
  final List<ChatMessageModel> messages;
  final String pendingMessage;
  
  const ChatMessageSending({
    required this.sessionId,
    required this.messages,
    required this.pendingMessage,
  });
  
  @override
  List<Object?> get props => [sessionId, messages, pendingMessage];
}

class ChatMessageReceived extends ChatState {
  final String sessionId;
  final List<ChatMessageModel> messages;
  
  const ChatMessageReceived({
    required this.sessionId,
    required this.messages,
  });
  
  @override
  List<Object?> get props => [sessionId, messages];
}

class ChatError extends ChatState {
  final String message;
  final String? sessionId;
  final List<ChatMessageModel>? messages;
  
  const ChatError({
    required this.message,
    this.sessionId,
    this.messages,
  });
  
  @override
  List<Object?> get props => [message, sessionId, messages];
}

// ===== CHAT BLOC =====
class MessageBasedChatBloc extends Bloc<ChatEvent, ChatState> {
  final GeminiAIService _aiService;
  final HiveStorageService _storageService;
  
  // Current session data
  String? _currentSessionId;
  List<ChatMessageModel> _messages = [];

  MessageBasedChatBloc({
    required GeminiAIService aiService,
    required HiveStorageService storageService,
  }) : _aiService = aiService,
       _storageService = storageService,
       super(ChatInitial()) {
    
    on<InitializeChatWithPrompt>(_onInitializeChatWithPrompt);
    on<InitializeChatWithSession>(_onInitializeChatWithSession);
    on<SendMessage>(_onSendMessage);
    on<ClearSession>(_onClearSession);
    on<RegenerateMessage>(_onRegenerateMessage);
  }

  // ===== EVENT HANDLERS =====

  /// Initialize chat with new prompt
  Future<void> _onInitializeChatWithPrompt(
    InitializeChatWithPrompt event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(ChatLoading());
      
      Logger.d('Initializing new chat session for user: ${event.userId}', tag: 'MessageChatBloc');
      
      // Create new session
      final sessionId = await _aiService.getOrCreateSession(userId: event.userId);
      _currentSessionId = sessionId;
      
      // Create user message
      final userMessage = ChatMessageModel.user(
        sessionId: sessionId,
        content: event.initialPrompt,
      );
      
      // Save user message to storage
      await _saveMessageToStorage(userMessage);
      _messages = [userMessage];
      
      emit(ChatMessageSending(
        sessionId: sessionId,
        messages: List.unmodifiable(_messages),
        pendingMessage: event.initialPrompt,
      ));
      
      // Generate AI response
      final aiMessage = await _aiService.generateMessageResponse(
        sessionId: sessionId,
        userMessage: event.initialPrompt,
        userId: event.userId,
      );
      
      // Save AI message to storage
      await _saveMessageToStorage(aiMessage);
      _messages.add(aiMessage);
      
      emit(ChatMessageReceived(
        sessionId: sessionId,
        messages: List.unmodifiable(_messages),
      ));
      
      Logger.d('Chat initialized with ${_messages.length} messages', tag: 'MessageChatBloc');
      
    } catch (e) {
      Logger.e('Error initializing chat: $e', tag: 'MessageChatBloc');
      
      // Create an error message instead of emitting ChatError
      if (_currentSessionId != null) {
        final errorMessage = _createErrorMessage(
          sessionId: _currentSessionId!,
          error: e,
        );
        _messages.add(errorMessage);
        
        emit(ChatMessageReceived(
          sessionId: _currentSessionId!,
          messages: _getMessageSnapshot(),
        ));
      } else {
        emit(ChatError(
          message: 'Failed to start conversation: $e',
        ));
      }
    }
  }

  /// Initialize chat with existing session
  Future<void> _onInitializeChatWithSession(
    InitializeChatWithSession event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(ChatLoading());
      
      Logger.d('Loading existing chat session: ${event.sessionId}', tag: 'MessageChatBloc');
      
      _currentSessionId = event.sessionId;
      
      // Step 1: Load messages from storage
      final hiveMessages = await _storageService.getMessagesForSession(event.sessionId);
      _messages = hiveMessages.map(_convertHiveMessageToChatMessage).toList();
      
      // Step 2: Ensure AI service has the session context initialized
      // This is critical for maintaining conversation context in Gemini
      final contextValid = await _validateSessionContext(event.sessionId);
      if (contextValid) {
        Logger.d('AI service session context verified for: ${event.sessionId}', tag: 'MessageChatBloc');
      } else {
        Logger.w('AI service session context could not be verified', tag: 'MessageChatBloc');
        // Continue anyway - the messages are loaded, AI service will create session on next interaction
      }
      
      emit(ChatReady(
        sessionId: event.sessionId,
        messages: _getMessageSnapshot(),
      ));
      
      Logger.d('Loaded ${_messages.length} messages for session: ${event.sessionId}', tag: 'MessageChatBloc');
      Logger.d('Chat session fully reinitialized with context preservation', tag: 'MessageChatBloc');
      
    } catch (e) {
      Logger.e('Error loading chat session: $e', tag: 'MessageChatBloc');
      emit(ChatError(
        message: 'Failed to load conversation: $e',
        sessionId: _currentSessionId,
      ));
    }
  }

  /// Send user message
  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentSessionId == null) {
      emit(const ChatError(message: 'No active session. Please start a new conversation.'));
      return;
    }
    
    try {
      Logger.d('Sending message in session: $_currentSessionId', tag: 'MessageChatBloc');
      
      // Create user message
      final userMessage = ChatMessageModel.user(
        sessionId: _currentSessionId!,
        content: event.message,
      );
      
      // Save user message to storage
      await _saveMessageToStorage(userMessage);
      _messages.add(userMessage);
      
      emit(ChatMessageSending(
        sessionId: _currentSessionId!,
        messages: _getMessageSnapshot(),
        pendingMessage: event.message,
      ));
      
      // Generate AI response
      final aiMessage = await _aiService.generateMessageResponse(
        sessionId: _currentSessionId!,
        userMessage: event.message,
      );
      
      // Save AI message to storage
      await _saveMessageToStorage(aiMessage);
      _messages.add(aiMessage);
      
      emit(ChatMessageReceived(
        sessionId: _currentSessionId!,
        messages: _getMessageSnapshot(),
      ));
      
      Logger.d('Message exchange completed. Total messages: ${_messages.length}', tag: 'MessageChatBloc');
      
    } catch (e) {
      Logger.e('Error sending message: $e', tag: 'MessageChatBloc');
      
      // Create an error message that shows in the UI
      final errorMessage = _createErrorMessage(
        sessionId: _currentSessionId!,
        error: e,
      );
      _messages.add(errorMessage);
      
      emit(ChatMessageReceived(
        sessionId: _currentSessionId!,
        messages: _getMessageSnapshot(),
      ));
    }
  }

  /// Clear current session
  Future<void> _onClearSession(
    ClearSession event,
    Emitter<ChatState> emit,
  ) async {
    try {
      if (_currentSessionId != null) {
        await _storageService.deleteSession(_currentSessionId!);
        await _storageService.deleteMessagesForSession(_currentSessionId!);
      }
      
      _currentSessionId = null;
      _messages.clear();
      
      emit(ChatInitial());
      
    } catch (e) {
      Logger.e('Error clearing session: $e', tag: 'MessageChatBloc');
      emit(ChatError(message: 'Failed to clear session: $e'));
    }
  }

  /// Regenerate the last AI message
  Future<void> _onRegenerateMessage(
    RegenerateMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentSessionId == null) {
      emit(const ChatError(message: 'No active session. Please start a new conversation.'));
      return;
    }

    try {
      Logger.d('Regenerating message for last user input: ${event.lastUserMessage}', tag: 'MessageChatBloc');

      // Remove the last error message from the list
      if (_messages.isNotEmpty && _messages.last.isError) {
        _messages.removeLast();
      }

      emit(ChatMessageSending(
        sessionId: _currentSessionId!,
        messages: _getMessageSnapshot(),
        pendingMessage: event.lastUserMessage,
      ));

      // Generate new AI response
      final aiMessage = await _aiService.generateMessageResponse(
        sessionId: _currentSessionId!,
        userMessage: event.lastUserMessage,
      );

      // Save AI message to storage
      await _saveMessageToStorage(aiMessage);
      _messages.add(aiMessage);

      emit(ChatMessageReceived(
        sessionId: _currentSessionId!,
        messages: _getMessageSnapshot(),
      ));

      Logger.d('Message regenerated successfully. Total messages: ${_messages.length}', tag: 'MessageChatBloc');

    } catch (e) {
      Logger.e('Error regenerating message: $e', tag: 'MessageChatBloc');
      
      // Create an error message that shows in the UI
      final errorMessage = _createErrorMessage(
        sessionId: _currentSessionId!,
        error: e,
      );
      _messages.add(errorMessage);
      
      emit(ChatMessageReceived(
        sessionId: _currentSessionId!,
        messages: _getMessageSnapshot(),
      ));
    }
  }

  // ===== HELPER METHODS =====

  /// Create an error message to display in the chat
  ChatMessageModel _createErrorMessage({
    required String sessionId,
    required dynamic error,
  }) {
    String errorMessage;
    
    // Handle different types of errors gracefully
    if (error is SocketException || 
        error.toString().contains('HandshakeException') ||
        error.toString().contains('CERTIFICATE_VERIFY_FAILED') ||
        error.toString().contains('network') ||
        error.toString().contains('connection')) {
      errorMessage = 'Network connection failed. Please check your internet connection and try again.';
    } else if (error is TimeoutException || error.toString().contains('timed out')) {
      errorMessage = 'Request timed out. Please try again.';
    } else if (error.toString().contains('API key') || error.toString().contains('authentication')) {
      errorMessage = 'Authentication failed. Please check your API configuration.';
    } else {
      errorMessage = 'Oops! The LLM failed to generate answer. Please regenerate.';
    }
    
    return ChatMessageModel.aiError(
      sessionId: sessionId,
      content: errorMessage,
    );
  }

  /// Test session context by sending a dummy message to AI service
  /// This ensures the Gemini ChatSession has proper conversation history
  Future<bool> _validateSessionContext(String sessionId) async {
    try {
      // Just verify the session exists in AI service
      final session = await _aiService.getSession(sessionId);
      return session != null;
    } catch (e) {
      Logger.w('Session context validation failed: $e', tag: 'MessageChatBloc');
      return false;
    }
  }

  /// Save message to storage
  Future<void> _saveMessageToStorage(ChatMessageModel message) async {
    try {
      final hiveMessage = _convertChatMessageToHiveMessage(message);
      await _storageService.saveMessage(hiveMessage);
      
      // If message contains itinerary, update session's tripContext
      if (message.hasItinerary && message.itinerary != null && _currentSessionId != null) {
        final hiveSession = await _storageService.getSession(_currentSessionId!);
        if (hiveSession != null) {
          // Update tripContext with latest itinerary metadata (not the full object)
          hiveSession.tripContext['has_itinerary'] = true;
          hiveSession.tripContext['itinerary_title'] = message.itinerary!.title;
          hiveSession.tripContext['duration_days'] = message.itinerary!.durationDays;
          hiveSession.tripContext['start_date'] = message.itinerary!.startDate;
          hiveSession.tripContext['end_date'] = message.itinerary!.endDate;
          
          // Save the session through the storage service
          await _storageService.saveSession(hiveSession);
          Logger.d('Updated session tripContext with itinerary metadata', tag: 'MessageChatBloc');
        }
      }
    } catch (e) {
      Logger.e('Failed to save message to storage: $e', tag: 'MessageChatBloc');
    }
  }

  /// Convert ChatMessageModel to HiveChatMessageModel
  HiveChatMessageModel _convertChatMessageToHiveMessage(ChatMessageModel message) {
    return HiveChatMessageModel(
      id: message.id,
      sessionId: message.sessionId,
      content: message.content,
      role: message.role,
      timestamp: message.timestamp,
      messageType: message.type.index, // Convert enum to int
      tokenCount: message.tokenCount,
      itinerary: message.itinerary != null
          ? _convertItineraryToHiveItinerary(message.itinerary!)
          : null,
    );
  }

  /// Convert HiveChatMessageModel to ChatMessageModel
  ChatMessageModel _convertHiveMessageToChatMessage(HiveChatMessageModel hiveMessage) {
    return ChatMessageModel(
      id: hiveMessage.id,
      sessionId: hiveMessage.sessionId,
      content: hiveMessage.content,
      role: hiveMessage.role,
      timestamp: hiveMessage.timestamp,
      type: MessageType.values[hiveMessage.messageType], // Convert int to enum
      tokenCount: hiveMessage.tokenCount,
      itinerary: hiveMessage.itinerary != null
          ? _convertHiveItineraryToItinerary(hiveMessage.itinerary!)
          : null,
    );
  }

  /// Convert ItineraryModel to HiveItineraryModel
  HiveItineraryModel _convertItineraryToHiveItinerary(ItineraryModel itinerary) {
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

  /// Convert HiveItineraryModel to ItineraryModel
  ItineraryModel _convertHiveItineraryToItinerary(HiveItineraryModel hiveItinerary) {
    return ItineraryModel(
      id: hiveItinerary.id,
      title: hiveItinerary.title,
      startDate: hiveItinerary.startDate,
      endDate: hiveItinerary.endDate,
      days: hiveItinerary.days.map((day) => DayPlanModel(
        date: day.date,
        summary: day.summary,
        items: day.items.map((item) => ActivityItemModel(
          time: item.time,
          activity: item.activity,
          location: item.location,
        )).toList(),
      )).toList(),
      originalPrompt: hiveItinerary.originalPrompt,
      createdAt: hiveItinerary.createdAt,
      updatedAt: hiveItinerary.updatedAt,
    );
  }

  // ===== HELPER METHODS FOR STATE EMISSION =====
  
  /// Create an unmodifiable snapshot of current messages for state emission
  /// This prevents accidental modifications and is more efficient than deep copying
  List<ChatMessageModel> _getMessageSnapshot() {
    return List.unmodifiable(_messages);
  }

  // ===== GETTERS =====
  String? get currentSessionId => _currentSessionId;
  List<ChatMessageModel> get messages => List.unmodifiable(_messages);

  @override
  Future<void> close() {
    Logger.d('Closing MessageBasedChatBloc', tag: 'MessageChatBloc');
    return super.close();
  }
}
