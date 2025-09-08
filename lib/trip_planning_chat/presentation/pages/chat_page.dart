import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_styles.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../blocs/chat_bloc.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/itinerary_card.dart';
import '../widgets/chat_input_field.dart';
import '../../data/models/itinerary_models.dart';

/// **Chat Page - Complete Implementation**
/// 
/// Handles both initialization modes:
/// 1. New chat with initial prompt
/// 2. Existing chat session continuation
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
  late ChatBloc _chatBloc;
  bool _showInputForInitialItinerary = false;

  @override
  void initState() {
    super.initState();
    _initializeChatBloc();
  }

  void _initializeChatBloc() {
    _chatBloc = context.read<ChatBloc>();
    
    if (widget.sessionId != null) {
      // Initialize with existing session
      _chatBloc.add(InitializeChatWithSession(sessionId: widget.sessionId!));
    } else if (widget.initialPrompt != null) {
      // Initialize with new prompt
      final authState = context.read<AuthBloc>().state;
      String userId = 'anonymous';
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
      // Check if this is a refinement (we're in chat mode with existing itinerary)
      final currentState = _chatBloc.state;
      final hasItinerary = currentState is ChatItineraryGenerated;
      final isRefinement = hasItinerary || _showInputForInitialItinerary;
      
      _chatBloc.add(SendMessage(
        message: message, 
        isRefinement: isRefinement,
      ));
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatItineraryGenerated || 
              state is ChatMessageReceived) {
            _scrollToBottom();
          }
          
          if (state is ChatError) {
            _showErrorSnackBar(state.message);
          }
        },
        builder: (context, state) {
          return _buildBody(state);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.primaryText,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatInitialized || 
              state is ChatMessageSending ||
              state is ChatMessageReceived ||
              state is ChatItineraryGenerated) {
            final session = (state as dynamic).session;
            final tripContext = session?.tripContext ?? {};
            
            if (tripContext.containsKey('destination')) {
              final destination = tripContext['destination'].toString().toUpperCase();
              final duration = tripContext['duration'];
              return Text(
                duration != null ? '$duration in $destination' : 'Trip to $destination',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              );
            }
          }
          
          return const Text('Trip Planning Chat');
        },
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: AppDimensions.paddingM),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryGreen,
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                String initial = 'S';
                if (state is AuthStateLoggedIn) {
                  initial = state.user.displayName.substring(0, 1).toUpperCase();
                }
                
                return Text(
                  initial,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(ChatState state) {
    if (state is ChatLoading) {
      return _buildLoadingState();
    }
    
    if (state is ChatError && state.session == null) {
      return _buildInitialErrorState(state.message);
    }
    
    return Column(
      children: [
        // Chat messages area
        Expanded(
          child: _buildChatArea(state),
        ),
        
        // Action buttons area - Only show for initial itinerary, not refinements
        if (state is ChatItineraryGenerated && 
            (state.session.conversationHistory.length <= 2) &&
            !_showInputForInitialItinerary) 
          _buildInitialActions(state),
        
        // Input area
        _buildInputArea(state),
        
        SafeArea(
          bottom: false,
          child: const SizedBox(height: AppDimensions.paddingS),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Creating Itinerary...',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
                fontSize: 24,
              ),
            ),
            
            const SizedBox(height: AppDimensions.paddingXXL),
            
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryGreen,
                  strokeWidth: 3,
                ),
              ),
            ),
            
            const SizedBox(height: AppDimensions.paddingXL),
            
            Text(
              'Curating a perfect plan for you...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.secondaryText,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialErrorState(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            
            const SizedBox(height: AppDimensions.paddingL),
            
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
            
            const SizedBox(height: AppDimensions.paddingM),
            
            Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppDimensions.paddingXL),
            
            ElevatedButton(
              onPressed: _initializeChatBloc,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingXL,
                  vertical: AppDimensions.paddingM,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatArea(ChatState state) {
    // For restored sessions with itineraries, show the itinerary view if we have minimal chat messages
    if (state is ChatItineraryGenerated) {
      // Check if this is a restored session or a newly created one
      // If we have 2 or fewer messages, show the itinerary prominently
      final messages = (state as dynamic).messages ?? [];
      if (messages.length <= 2) {
        return _buildItineraryCreatedView(state);
      }
    }
    
    // Show chat messages interface for sessions with more conversation
    return _buildChatMessages(state);
  }

  Widget _buildItineraryCreatedView(ChatItineraryGenerated state) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success header
          Row(
            children: [
              Text(
                'Itinerary Created ',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                  fontSize: 24,
                ),
              ),
              const Text('🌴', style: TextStyle(fontSize: 24)),
            ],
          ),
          
          const SizedBox(height: AppDimensions.paddingL),
          
          // Itinerary card
          ItineraryCard(
            itinerary: state.currentItinerary,
            enableStreaming: true, // Enable streaming for initial generation
            onOpenInMaps: () {
              // TODO: Implement maps integration
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessages(ChatState state) {
    List<dynamic> messages = [];
    ItineraryModel? currentItinerary;
    
    if (state is ChatInitialized ||
        state is ChatMessageSending ||
        state is ChatMessageReceived ||
        state is ChatItineraryGenerated ||
        state is ChatError) {
      messages = (state as dynamic).messages ?? [];
      currentItinerary = (state as dynamic).currentItinerary;
    }
    
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      itemCount: messages.length + _getExtraItems(state),
      itemBuilder: (context, index) {
        // Handle loading state
        if (state is ChatMessageSending && index == messages.length) {
          return _buildThinkingIndicator();
        }
        
        // Handle error state
        if (state is ChatError && index == messages.length) {
          return _buildErrorMessage(state.message);
        }
        
        // Regular message
        final message = messages[index];
        final isUser = message.role == 'user';
        
        // Show itinerary with ALL AI messages in chat refinement mode (messages > 2)
        // This ensures every AI response shows the current/updated itinerary in compact form
        // Also show during message sending state to keep previous itineraries visible
        final shouldShowItinerary = !isUser && 
                                  currentItinerary != null && 
                                  (state is ChatItineraryGenerated || state is ChatMessageSending) &&
                                  messages.length > 2; // Only in chat refinement mode
        
        // Debug logging
        if (!isUser) {
          print('DEBUG: AI message $index - shouldShowItinerary: $shouldShowItinerary');
          print('DEBUG: currentItinerary != null: ${currentItinerary != null}');
          print('DEBUG: state is ChatItineraryGenerated: ${state is ChatItineraryGenerated}');
          print('DEBUG: state is ChatMessageSending: ${state is ChatMessageSending}');
          print('DEBUG: messages.length > 2: ${messages.length > 2}');
          print('DEBUG: currentItinerary title: ${currentItinerary?.title}');
        }
        
        return ChatMessageBubble(
          message: message,
          isUser: isUser,
          itinerary: shouldShowItinerary ? currentItinerary : null,
          onItineraryTap: shouldShowItinerary ? () {
            _showItineraryDetails(currentItinerary!);
          } : null,
        );
      },
    );
  }

  int _getExtraItems(ChatState state) {
    if (state is ChatMessageSending || state is ChatError) return 1;
    return 0;
  }

  Widget _buildThinkingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'AI',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: AppDimensions.paddingM),
          
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: AppDimensions.paddingM,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                boxShadow: const [AppShadows.card],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingS),
                      Text(
                        'AI is thinking...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppDimensions.paddingS),
                  
                  Text(
                    'Crafting your perfect itinerary',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryText,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String errorMessage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'AI',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: AppDimensions.paddingM),
          
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                border: Border.all(
                  color: AppColors.error.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 16,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: AppDimensions.paddingXS),
                      Expanded(
                        child: Text(
                          'Oops! The LLM failed to generate answer. Please regenerate.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppDimensions.paddingS),
                  
                  TextButton(
                    onPressed: () {
                      _chatBloc.add(const RegenerateItinerary());
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Regenerate',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialActions(ChatItineraryGenerated state) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.paddingM,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        children: [
          // Follow up to refine button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Enable chat input by showing it
                setState(() {
                  _showInputForInitialItinerary = true;
                });
                _scrollToBottom();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.paddingM,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                ),
              ),
              icon: const Icon(Icons.chat_bubble_outline, size: 20),
              label: const Text(
                'Follow up to refine',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: AppDimensions.paddingM),
          
          // Save offline button
          TextButton.icon(
            onPressed: () {
              _chatBloc.add(const SaveSession());
              _showSavedSnackBar();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.black,
            ),
            icon: const Icon(Icons.download_outlined, size: 20),
            label: const Text('Save Offline'),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(ChatState state) {
    // Don't show input during initial loading
    if (state is ChatLoading) {
      return const SizedBox.shrink();
    }
    
    // Show input for conversations with more than 2 messages (chat mode)
    // OR after user taps "Continue conversation"
    bool shouldShowInput = false;
    
    if (state is ChatItineraryGenerated) {
      final messages = (state as dynamic).messages ?? [];
      shouldShowInput = messages.length > 2 || _showInputForInitialItinerary;
    } else {
      shouldShowInput = true;
    }
    
    if (!shouldShowInput) {
      return const SizedBox.shrink();
    }
    
    final isLoading = state is ChatMessageSending || state is ChatGeneratingItinerary;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.paddingM,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: const [AppShadows.medium],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Suggestion chips for quick actions
          if (state is ChatItineraryGenerated && 
              (state as dynamic).messages?.length <= 2 &&
              _showInputForInitialItinerary) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
              child: Wrap(
                spacing: AppDimensions.paddingS,
                runSpacing: AppDimensions.paddingS,
                children: [
                  _buildSuggestionChip('Add more activities'),
                  _buildSuggestionChip('Change dates'),
                  _buildSuggestionChip('Different budget'),
                  _buildSuggestionChip('Make it shorter'),
                ],
              ),
            ),
          ],
          
          // Input row
          Row(
            children: [
              Expanded(
                child: ChatInputField(
                  controller: _messageController,
                  hint: state is ChatItineraryGenerated 
                      ? 'How would you like to refine this itinerary?'
                      : 'Type your message...',
                  enabled: !isLoading,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              
              const SizedBox(width: AppDimensions.paddingM),
              
              // Mic button
              IconButton(
                onPressed: isLoading ? null : () {
                  // TODO: Implement voice input
                },
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.lightGrey.withOpacity(0.2),
                  foregroundColor: isLoading ? AppColors.lightGrey : AppColors.hintText,
                ),
                icon: const Icon(Icons.mic_outlined, size: 24),
              ),
              
              const SizedBox(width: AppDimensions.paddingS),
              
              // Send button
              IconButton(
                onPressed: isLoading ? null : _sendMessage,
                style: IconButton.styleFrom(
                  backgroundColor: isLoading 
                      ? AppColors.lightGrey 
                      : AppColors.primaryGreen,
                  foregroundColor: AppColors.white,
                ),
                icon: isLoading 
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return GestureDetector(
      onTap: () {
        _messageController.text = text;
        
        // Mark as refinement since these are quick refinement options
        final currentState = _chatBloc.state;
        final hasItinerary = currentState is ChatItineraryGenerated;
        
        _chatBloc.add(SendMessage(
          message: text,
          isRefinement: hasItinerary,
        ));
        _messageController.clear();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: Border.all(
            color: AppColors.primaryGreen.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
      ),
    );
  }

  void _showSavedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Trip saved offline successfully!'),
        backgroundColor: AppColors.primaryGreen,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
      ),
    );
  }

  void _showItineraryDetails(ItineraryModel itinerary) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppDimensions.radiusXL),
              topRight: Radius.circular(AppDimensions.radiusXL),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: AppDimensions.paddingM),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Itinerary Details',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.lightGrey.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
                  child: ItineraryCard(
                    itinerary: itinerary,
                    enableStreaming: false, // Explicitly disable streaming for modal
                    onOpenInMaps: () {
                      // TODO: Implement maps integration
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
