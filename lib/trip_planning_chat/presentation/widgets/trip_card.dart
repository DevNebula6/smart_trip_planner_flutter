import 'package:flutter/material.dart';
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.lightGrey.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Minimalist green dot indicator
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Compact trip details
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryText,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                // Compact delete button
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.hintText,
                    ),
                  ),
                ),
              ],
            ),
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
    // Debug logging to understand what data we have
    print('TripCard Debug - tripContext keys: ${context.keys}');
    print('TripCard Debug - tripContext: $context');
    
    // First try to get the itinerary title (most recent itinerary for this session)
    if (context.containsKey('itinerary_title')) {
      final title = context['itinerary_title'] as String?;
      print('TripCard Debug - Found itinerary_title: $title');
      if (title != null && title.isNotEmpty) {
        return title;
      }
    }
    
    // Try to extract title from destination context
    if (context.containsKey('destination')) {
      final destination = context['destination'] as String?;
      final duration = context['duration'] as String?;
      print('TripCard Debug - Found destination: $destination, duration: $duration');
      
      if (destination != null) {
        return duration != null 
            ? '$duration in $destination'
            : destination;
      }
    }
    
    // Fallback to session ID or a generic title
    final fallbackTitle = 'Trip ${tripSession.sessionId.split('_').last}';
    print('TripCard Debug - Using fallback title: $fallbackTitle');
    return fallbackTitle;
  }
}
