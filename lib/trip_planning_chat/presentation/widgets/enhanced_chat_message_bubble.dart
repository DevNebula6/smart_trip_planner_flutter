import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_styles.dart';
import '../../../trip_planning_chat/data/models/itinerary_models.dart';
import 'itinerary_compact_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

/// **Enhanced Chat Message Bubble Widget**
/// 
/// Displays messages with optional embedded itinerary and error handling
class EnhancedChatMessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  final VoidCallback? onItineraryTap;
  final VoidCallback? onRegenerateTap;
  
  const EnhancedChatMessageBubble({
    super.key,
    required this.message,
    this.onItineraryTap,
    this.onRegenerateTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: AppDimensions.paddingS,
        horizontal: AppDimensions.paddingM,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Avatar (left side for AI messages)
          if (message.isAI) ...[
            _buildAIAvatar(),
            const SizedBox(width: AppDimensions.paddingS),
          ] else ...[
            // Spacer for user messages to push content right
            const SizedBox(width: 48), // Avatar size + padding
          ],
          
          // Message content
          Expanded(
            child: Column(
              crossAxisAlignment: message.isUser 
                  ? CrossAxisAlignment.end 
                  : CrossAxisAlignment.start,
              children: [
                // Message text bubble (handle error messages specially)
                if (message.content.isNotEmpty) 
                  message.isError ? _buildErrorBubble() : _buildTextBubble(theme),
                
                // Itinerary card (if present)
                if (message.hasItinerary) ...[
                  const SizedBox(height: AppDimensions.paddingS),
                  _buildItineraryCard(context),
                ],
                
                // Timestamp and token info (hide for error messages as they have their own footer)
                if (!message.isError) ...[
                  const SizedBox(height: AppDimensions.paddingXS),
                  _buildMessageInfo(theme),
                ],
              ],
            ),
          ),
          
          // User Avatar (right side for user messages)
          if (message.isUser) ...[
            const SizedBox(width: AppDimensions.paddingS),
            _buildUserAvatar(),
          ] else ...[
            // Spacer for AI messages
            const SizedBox(width: 48),
          ],
        ],
      ),
    );
  }

  Widget _buildTextBubble(ThemeData theme) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      decoration: BoxDecoration(
        color: message.isUser ? AppColors.primaryAccent : AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: message.isUser 
              ? const Radius.circular(16) 
              : const Radius.circular(4),
          bottomRight: message.isUser 
              ? const Radius.circular(4) 
              : const Radius.circular(16),
        ),
        border: message.isUser 
            ? null 
            : Border.all(color: AppColors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: message.isUser 
                ? AppColors.primaryAccent.withOpacity(0.3)
                : AppColors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        message.content,
        style: message.isUser 
            ? theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              )
            : theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w400,
              ),
      ),
    );
  }

  Widget _buildErrorBubble() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Error message container
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.error.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.error.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Error icon and title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.warning_rounded,
                        color: AppColors.error,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingS),
                    Expanded(
                      child: Text(
                        'Error',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppDimensions.paddingS),
                
                // Error message
                Text(
                  message.content,
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppDimensions.paddingS),
          
          // Regenerate button
          Row(
            children: [
              const Spacer(),
              TextButton.icon(
                onPressed: onRegenerateTap,
                icon: Icon(
                  Icons.refresh_rounded,
                  size: 16,
                  color: AppColors.primaryAccent,
                ),
                label: Text(
                  'Regenerate',
                  style: TextStyle(
                    color: AppColors.primaryAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingM,
                    vertical: AppDimensions.paddingS,
                  ),
                  backgroundColor: AppColors.primaryAccent.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItineraryCard(BuildContext context) {
    if (message.itinerary == null) return const SizedBox.shrink();
    
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      child: ItineraryCompactCard(
        itinerary: message.itinerary!,
        onTap: onItineraryTap,
      ),
    );
  }

  Widget _buildMessageInfo(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingS),
      child: Row(
        mainAxisAlignment: message.isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        children: [
          Text(
            _formatTimestamp(message.timestamp),
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.grey,
              fontSize: 11,
            ),
          ),
          
          // Show token count for AI messages
          if (message.isAI && message.tokenCount != null) ...[
            const SizedBox(width: AppDimensions.paddingS),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${message.tokenCount} tokens',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.grey,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAIAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Colors.orange.withOpacity(0.2),
          Colors.amber.withOpacity(0.5),
        ]),
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(
          'assets/material-symbols-light_travel-rounded.png',
          width: 40,
          height: 40,
          color: AppColors.orange,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildUserAvatar() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String initial = 'U'; // Default initial
        if (state is AuthStateLoggedIn) {
          final userName = state.user.displayName;
          initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
        }
        
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryAccent,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryAccent.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}
