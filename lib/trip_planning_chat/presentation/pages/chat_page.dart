import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_styles.dart';
import '../blocs/message_based_chat_bloc.dart';
import '../widgets/enhanced_chat_message_bubble.dart';
import '../widgets/itinerary_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../trip_planning_chat/data/models/itinerary_models.dart';
import '../../../shared/navigation/app_router.dart';

/// ** Chat Page - Message Based**
/// 
/// Modern chat interface with enhanced UI:
/// - Glassmorphic input area with gradient accents
/// - Animated "View Details" button positioned above input
/// - Smooth typing indicator with animated dots
/// - Adaptive message bubbles with subtle animations
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

class _ChatPageState extends State<ChatPage> with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();
  late MessageBasedChatBloc _chatBloc;
  late AnimationController _typingAnimationController;
  bool _isInputFocused = false;

  @override
  void initState() {
    super.initState();
    _chatBloc = context.read<MessageBasedChatBloc>();
    _typingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    
    _inputFocusNode.addListener(() {
      setState(() {
        _isInputFocused = _inputFocusNode.hasFocus;
      });
    });
    
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
    _inputFocusNode.dispose();
    _typingAnimationController.dispose();
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
          
          // Auto-navigate to detail view when AI generates new itinerary
          final messages = state.messages;
          if (messages.isNotEmpty) {
            final lastMessage = messages.last;
            if (!lastMessage.isUser && lastMessage.hasItinerary) {
              // AI just generated an itinerary - auto navigate
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _navigateToDetailView(state);
              });
            }
          }
        }
        
        if (state is ChatError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(AppDimensions.paddingM),
            ),
          );
        }
      },
      builder: (context, state) {
        // Check if we have an itinerary to show detail button
        final hasItinerary = _hasItineraryInMessages(state);
        
        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          appBar: _buildModernAppBar(state, hasItinerary),
          body: Column(
            children: [
              Expanded(child: _buildChatArea(state)),
              // View Details button positioned above input area when itinerary exists
              if (hasItinerary) _buildViewDetailsButton(state),
              _buildEnhancedInputArea(state),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildModernAppBar(ChatState state, bool hasItinerary) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getTripTitle(state),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (state is ChatMessageSending)
            const Text(
              'AI is typing...',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: AppColors.secondaryText,
              ),
            ),
        ],
      ),
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.primaryText,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: AppColors.grey.withOpacity(0.1),
      scrolledUnderElevation: 1,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    );
  }

  /// View Details button positioned above input area - prevents overlap
  Widget _buildViewDetailsButton(ChatState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToDetailView(state),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingM,
              vertical: AppDimensions.paddingS + 4,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryAccent.withOpacity(0.15),
                  AppColors.primaryAccent.withOpacity(0.05),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryAccent.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.map_outlined,
                    size: 18,
                    color: AppColors.primaryAccent,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingS),
                Text(
                  'View Full Itinerary Details',
                  style: TextStyle(
                    color: AppColors.primaryAccent,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingXS),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.primaryAccent,
                ),
              ],
            ),
          ),
        ),
      ),
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
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated AI icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryAccent.withOpacity(0.2),
                      AppColors.primaryAccent.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryAccent,
                          AppColors.primaryAccent.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryAccent.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.auto_awesome,
                        size: 28,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingL),
              Text(
                'Hi! I\'m your AI Travel Assistant',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingS),
              Text(
                'Tell me about your dream destination and I\'ll help you plan the perfect trip!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryText,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingXL),
              // Suggestion chips
              Wrap(
                alignment: WrapAlignment.center,
                spacing: AppDimensions.paddingS,
                runSpacing: AppDimensions.paddingS,
                children: [
                  _buildSuggestionChip('Weekend in Paris 🗼'),
                  _buildSuggestionChip('Beach vacation 🏖️'),
                  _buildSuggestionChip('Adventure trip 🏔️'),
                ],
              ),
            ],
          ),
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
          // AI Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryAccent,
                  AppColors.primaryAccent.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryAccent.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.auto_awesome,
                color: AppColors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.paddingS),
          // Typing indicator bubble
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingM,
              vertical: AppDimensions.paddingS + 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.grey.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAnimatedDot(0),
                const SizedBox(width: 4),
                _buildAnimatedDot(1),
                const SizedBox(width: 4),
                _buildAnimatedDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedDot(int index) {
    return AnimatedBuilder(
      animation: _typingAnimationController,
      builder: (context, child) {
        final double offset = (index * 0.2);
        final double value = (_typingAnimationController.value + offset) % 1.0;
        final double bounce = (value < 0.5)
            ? Curves.easeOut.transform(value * 2)
            : Curves.easeIn.transform((1 - value) * 2);
        
        return Transform.translate(
          offset: Offset(0, -4 * bounce),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withOpacity(0.6 + (0.4 * bounce)),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedInputArea(ChatState state) {
    final isLoading = state is ChatLoading || state is ChatMessageSending;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingM,
        AppDimensions.paddingS,
        AppDimensions.paddingM,
        AppDimensions.paddingM,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -4),
            blurRadius: 12,
            color: AppColors.grey.withOpacity(0.08),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _isInputFocused 
                ? AppColors.primaryAccent.withOpacity(0.05)
                : AppColors.lightGrey.withOpacity(0.5),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: _isInputFocused
                  ? AppColors.primaryAccent.withOpacity(0.3)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              
              // Text input
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 120),
                  child: TextField(
                    controller: _messageController,
                    focusNode: _inputFocusNode,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: isLoading 
                          ? 'Waiting for AI response...'
                          : 'Ask me anything about your trip...',
                      hintStyle: TextStyle(
                        color: AppColors.grey.withOpacity(0.7),
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingS,
                        vertical: AppDimensions.paddingS,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.primaryText,
                    ),
                    onSubmitted: isLoading ? null : (_) => _sendMessage(),
                  ),
                ),
              ),
              // Send button
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                child: Material(
                  color: isLoading 
                      ? AppColors.grey.withOpacity(0.3)
                      : AppColors.primaryAccent,
                  borderRadius: BorderRadius.circular(22),
                  child: InkWell(
                    onTap: isLoading ? null : _sendMessage,
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: isLoading ? null : [
                          BoxShadow(
                            color: AppColors.primaryAccent.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: isLoading
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.white.withOpacity(0.7),
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.keyboard_arrow_right_rounded,
                                color: AppColors.white,
                                size: 22,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Suggestion chip for empty chat state
  Widget _buildSuggestionChip(String text) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _messageController.text = text;
          _inputFocusNode.requestFocus();
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.paddingS,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.grey.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.grey.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 13,
            ),
          ),
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

  /// Check if any message contains an itinerary
  bool _hasItineraryInMessages(ChatState state) {
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

    return messages.any((msg) => 
      msg is ChatMessageModel && msg.hasItinerary
    );
  }

  /// Navigate to ItineraryDetailPage with the latest itinerary found
  void _navigateToDetailView(ChatState state) {
    List<dynamic> messages = [];
    String? sessionId;
    
    if (state is ChatReady) {
      messages = state.messages;
      sessionId = state.sessionId;
    } else if (state is ChatMessageSending) {
      messages = state.messages;
      sessionId = state.sessionId;
    } else if (state is ChatMessageReceived) {
      messages = state.messages;
      sessionId = state.sessionId;
    } else if (state is ChatError && state.messages != null) {
      messages = state.messages!;
      sessionId = state.sessionId;
    }

    // Find the LATEST message with an itinerary (not the first one)
    // This ensures we get the most up-to-date itinerary with all modifications
    ChatMessageModel? messageWithItinerary;
    for (int i = messages.length - 1; i >= 0; i--) {
      final msg = messages[i];
      if (msg is ChatMessageModel && msg.hasItinerary) {
        messageWithItinerary = msg;
        break;
      }
    }

    if (messageWithItinerary != null && sessionId != null) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.itineraryDetail,
        arguments: {
          'itinerary': messageWithItinerary.itinerary!,
          'sessionId': sessionId,
        },
      );
    }
  }
}
