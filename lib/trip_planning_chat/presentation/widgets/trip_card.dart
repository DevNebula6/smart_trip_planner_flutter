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
    
    // Build a descriptive title from available context
    final List<String> titleParts = [];
    
    // Add duration if available
    if (context.containsKey('duration')) {
      titleParts.add(context['duration'] as String);
    } else if (context.containsKey('duration_number') && context.containsKey('duration_unit')) {
      final number = context['duration_number'];
      final unit = context['duration_unit'] as String;
      final pluralUnit = number > 1 ? '${unit}s' : unit;
      titleParts.add('$number $pluralUnit');
    }
    
    // Add travel style first for better readability
    if (context.containsKey('travel_style')) {
      final style = context['travel_style'] as String;
      titleParts.add(style);
    }
    
    // Add destination with "to"
    if (context.containsKey('destination')) {
      final destination = context['destination'] as String;
      if (titleParts.isNotEmpty) {
        titleParts.add('trip to $destination');
      } else {
        titleParts.add('Trip to $destination');
      }
    } else {
      titleParts.add('trip');
    }
    
    // Add budget type if available and no destination to keep it concise
    if (context.containsKey('budget_type') && !context.containsKey('destination')) {
      final budget = context['budget_type'] as String;
      titleParts.add('($budget)');
    }
    
    // Create title
    if (titleParts.isNotEmpty) {
      String title = titleParts.join(' ');
      // Capitalize first letter
      title = title[0].toUpperCase() + title.substring(1);
      print('TripCard Debug - Built descriptive title: $title');
      return title;
    }
    
    // Fallback to session ID or a generic title
    final fallbackTitle = 'Trip ${tripSession.sessionId.split('_').last}';
    print('TripCard Debug - Using fallback title: $fallbackTitle');
    return fallbackTitle;
  }
}
