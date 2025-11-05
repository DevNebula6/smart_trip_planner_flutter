import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_styles.dart';
import '../blocs/message_based_chat_bloc.dart';
import '../widgets/enhanced_chat_message_bubble.dart';
import '../widgets/itinerary_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../trip_planning_chat/data/models/itinerary_models.dart';

/// ** Chat Page - Message Based**
/// 
/// Uses the new message-based approach where each message can contain:
/// - Text only (follow-up questions, responses)
/// - Itinerary only 
/// - Both text and itinerary combined
class ChatPage extends StatefulWidget {
  final String? initialPrompt;
  final String? sessionId;

  const ChatPage({
    super.key,
    this.initialPrompt,
    this.sessionId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late MessageBasedChatBloc _chatBloc;

  @override
  void initState() {
    super.initState();
    _chatBloc = context.read<MessageBasedChatBloc>();
    _initializeChat();
  }

  void _initializeChat() {
    if (widget.sessionId != null) {
      // Continue existing session
      _chatBloc.add(InitializeChatWithSession(sessionId: widget.sessionId!));
    } else if (widget.initialPrompt != null) {
      // Start new session - get current user ID from AuthBloc
      final authState = context.read<AuthBloc>().state;
      String userId = 'anonymous'; // fallback
      
      if (authState is AuthStateLoggedIn) {
        userId = authState.user.id;
      }
      
      _chatBloc.add(InitializeChatWithPrompt(
        userId: userId,
        initialPrompt: widget.initialPrompt!,
      ));
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      _chatBloc.add(SendMessage(message: message));
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _regenerateMessage(ChatMessageModel errorMessage) {
    // Find the last user message before this error message
    final messages = _chatBloc.messages;
    final errorIndex = messages.indexWhere((msg) => msg.id == errorMessage.id);
    
    // Look backwards for the most recent user message
    String? lastUserMessage;
    for (int i = errorIndex - 1; i >= 0; i--) {
      if (messages[i].isUser) {
        lastUserMessage = messages[i].content;
        break;
      }
    }
    
    if (lastUserMessage != null) {
      _chatBloc.add(RegenerateMessage(lastUserMessage: lastUserMessage));
      _scrollToBottom();
    }
  }

  String _getTripTitle(ChatState state) {
    List<ChatMessageModel> messages = [];
    
    if (state is ChatReady) {
      messages = state.messages;
    } else if (state is ChatMessageSending) {
      messages = state.messages;
    } else if (state is ChatMessageReceived) {
      messages = state.messages;
    } else if (state is ChatError && state.messages != null) {
      messages = state.messages!;
    }
    
    // Look for the most recent itinerary title (from the latest message with itinerary)
    for (int i = messages.length - 1; i >= 0; i--) {
      final message = messages[i];
      if (message.hasItinerary && message.itinerary != null) {
        return message.itinerary!.title;
      }
    }
    
    // If no itinerary found, return default title
    return 'Trip Planning';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MessageBasedChatBloc, ChatState>(
      listener: (context, state) {
        if (state is ChatMessageReceived) {
          _scrollToBottom();
        }
        
        if (state is ChatError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          appBar: AppBar(
            title: Text(_getTripTitle(state)),
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.primaryText,
            elevation: 0,
          ),
          body: Column(
            children: [
              Expanded(child: _buildChatArea(state)),
              _buildInputArea(state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChatArea(ChatState state) {
    if (state is ChatLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: AppDimensions.paddingM),
            Text('Starting conversation...'),
          ],
        ),
      );
    }

    // Get messages from current state
    List<dynamic> messages = [];
    
    if (state is ChatReady) {
      messages = state.messages;
    } else if (state is ChatMessageSending) {
      messages = state.messages;
    } else if (state is ChatMessageReceived) {
      messages = state.messages;
    } else if (state is ChatError && state.messages != null) {
      messages = state.messages!;
    }

    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: AppColors.grey,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Text(
              'Start a conversation',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppDimensions.paddingS),
      itemCount: messages.length + (state is ChatMessageSending ? 1 : 0),
      itemBuilder: (context, index) {
        // Show loading indicator for pending message
        if (state is ChatMessageSending && index == messages.length) {
          return _buildLoadingIndicator();
        }

        final message = messages[index];
        return EnhancedChatMessageBubble(
          message: message,
          onItineraryTap: message.hasItinerary 
              ? () => _showItineraryDetails(message.itinerary!)
              : null,
          onRegenerateTap: message.isError
              ? () => _regenerateMessage(message)
              : null,
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingM,
              vertical: AppDimensions.paddingS,
            ),
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingS),
                const Text('AI is thinking...'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(ChatState state) {
    final isLoading = state is ChatLoading || state is ChatMessageSending;
    
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 4,
            color: AppColors.grey.withOpacity(0.1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                enabled: !isLoading,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: AppColors.grey.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: AppColors.grey.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.primaryGreen),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingM,
                    vertical: AppDimensions.paddingS,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: isLoading ? null : (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingS),
            FloatingActionButton(
              onPressed: isLoading ? null : _sendMessage,
              mini: true,
              backgroundColor: isLoading 
                  ? AppColors.grey 
                  : AppColors.primaryGreen,
              child: Icon(
                Icons.send,
                color: AppColors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showItineraryDetails(dynamic itinerary) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: AppDimensions.paddingS),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Header with close button
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Trip Details',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.lightGrey.withOpacity(0.5),
                          shape: const CircleBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Itinerary content using ItineraryCard
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
                    child: ItineraryCard(
                      itinerary: itinerary,
                      enableStreaming: false, // Don't animate in modal
                      onOpenInMaps: () {
                        // Handle opening in maps - you can implement this later
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Opening in maps...'),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                // Bottom safe area
                const SizedBox(height: AppDimensions.paddingM),
              ],
            ),
          );
        },
      ),
    );
  }
}
