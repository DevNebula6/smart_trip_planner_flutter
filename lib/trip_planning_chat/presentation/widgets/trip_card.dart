import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../ai_agent/models/trip_session_model.dart';
import '../../../core/constants/app_styles.dart';

class TripCard extends StatelessWidget {
  final SessionState tripSession;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TripCard({
    super.key,
    required this.tripSession,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Extract trip context to get trip details
    final tripContext = _getTripContext();
    final title = _getTripTitle(tripContext);
    final description = _getTripDescription(tripContext);
    final lastUsed = tripSession.lastUsed;

    return Card(
      elevation: 2,
      shadowColor: AppColors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Row(
            children: [
              // Trip icon
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
              ),
              
              const SizedBox(width: AppDimensions.paddingM),
              
              // Trip details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.paddingXS),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.paddingXS),
                    Text(
                      _formatDate(lastUsed),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.hintText,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Refinement count indicator (if any)
                  if (tripSession.refinementCount > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingS,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                      ),
                      child: Text(
                        '${tripSession.refinementCount}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingS),
                  ],
                  
                  // Delete button
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingXS),
                      child: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: AppColors.hintText,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getTripContext() {
    try {
      // tripContext is already a Map in SessionState
      return tripSession.tripContext;
    } catch (e) {
      return {};
    }
  }

  String _getTripTitle(Map<String, dynamic> context) {
    // Try to extract title from context
    if (context.containsKey('destination')) {
      final destination = context['destination'] as String?;
      final duration = context['duration'] as String?;
      
      if (destination != null) {
        return duration != null 
            ? '$duration in $destination'
            : destination;
      }
    }
    
    // Fallback to session ID or a generic title
    return 'Trip ${tripSession.sessionId.split('_').last}';
  }

  String _getTripDescription(Map<String, dynamic> context) {
    // Try to extract meaningful description from context
    List<String> parts = [];
    
    if (context.containsKey('travelers')) {
      parts.add('${context['travelers']} people');
    }
    
    if (context.containsKey('budget')) {
      parts.add('${context['budget']} budget');
    }
    
    if (context.containsKey('style') || context.containsKey('interests')) {
      final style = context['style'] ?? context['interests'];
      if (style != null) {
        parts.add(style.toString());
      }
    }
    
    if (parts.isEmpty) {
      return '${tripSession.messagesInSession} messages • ${tripSession.refinementCount} refinements';
    }
    
    return parts.join(', ');
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }
}
