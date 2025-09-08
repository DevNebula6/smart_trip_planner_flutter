import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_styles.dart';
import '../../../trip_planning_chat/data/models/itinerary_models.dart';
import 'itinerary_compact_card.dart';

/// **Chat Message Bubble**
/// 
/// Displays individual chat messages with user/AI styling
class ChatMessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isUser;
  final ItineraryModel? itinerary;
  final VoidCallback? onItineraryTap;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.itinerary,
    this.onItineraryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppDimensions.paddingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            // AI Avatar
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
          ],
          
          // Message content
          Expanded(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Message bubble
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  decoration: BoxDecoration(
                    color: isUser 
                        ? AppColors.primaryGreen
                        : AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(AppDimensions.radiusL),
                      topRight: const Radius.circular(AppDimensions.radiusL),
                      bottomLeft: isUser 
                          ? const Radius.circular(AppDimensions.radiusL)
                          : const Radius.circular(4),
                      bottomRight: isUser
                          ? const Radius.circular(4)
                          : const Radius.circular(AppDimensions.radiusL),
                    ),
                    boxShadow: const [AppShadows.card],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Message text
                      if (message.content.isNotEmpty)
                        isUser?
                        Text(
                          message.content,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isUser ? AppColors.white : AppColors.primaryText,
                            height: 1.4,
                          ),
                        ) 
                        :
                        AnimatedTextKit(animatedTexts: [
                          TyperAnimatedText(
                            message.content,
                            speed: const Duration(milliseconds: 10),
                          )
                        ]),
                      
                      // Itinerary card if present
                      if (itinerary != null) ...[
                        if (message.content.isNotEmpty)
                          const SizedBox(height: AppDimensions.paddingM),
                        _buildItineraryPreview(context, itinerary!),
                      ],
                    ],
                  ),
                ),
                
                // Timestamp and actions
                const SizedBox(height: AppDimensions.paddingXS),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isUser) ...[
                      GestureDetector(
                        onTap: () => _copyToClipboard(context, message.content),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingS,
                            vertical: AppDimensions.paddingXS,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.copy_outlined,
                                size: 14,
                                color: AppColors.hintText,
                              ),
                              const SizedBox(width: AppDimensions.paddingXS),
                              Text(
                                'Copy',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.hintText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    Text(
                      _formatTime(message.timestamp),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.hintText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          if (isUser) ...[
            const SizedBox(width: AppDimensions.paddingM),
            // User Avatar
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'You',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItineraryPreview(BuildContext context, ItineraryModel itinerary) {
    return ItineraryCompactCard(
      itinerary: itinerary,
      onTap: onItineraryTap,
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Message copied to clipboard'),
        backgroundColor: AppColors.primaryGreen,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
      ),
    );
  }
}
