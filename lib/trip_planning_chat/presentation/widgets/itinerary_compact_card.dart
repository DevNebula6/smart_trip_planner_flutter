import 'package:flutter/material.dart';
import '../../../core/constants/app_styles.dart';
import '../../data/models/itinerary_models.dart';

/// **Compact Itinerary Card**
/// 
/// A smaller version of the itinerary card for display within chat messages
class ItineraryCompactCard extends StatelessWidget {
  final ItineraryModel itinerary;
  final VoidCallback? onTap;

  const ItineraryCompactCard({
    super.key,
    required this.itinerary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
            color: AppColors.primaryAccent.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.map_outlined,
                    size: 16,
                    color: AppColors.primaryAccent,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itinerary.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${itinerary.startDate} - ${itinerary.endDate}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingS,
                    vertical: AppDimensions.paddingXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Text(
                    '${itinerary.days.length} days',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.primaryAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppDimensions.paddingM),
            
            // Preview of first few days
            Column(
              children: itinerary.days.asMap().entries.take(2).map((entry) => 
                _buildDayPreview(context, entry.value, entry.key + 1)
              ).toList(),
            ),
            
            // Show more indicator if there are more days
            if (itinerary.days.length > 2) ...[
              const SizedBox(height: AppDimensions.paddingS),
              Center(
                child: Text(
                  '+ ${itinerary.days.length - 2} more days',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.hintText,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
            
            // Tap to view details
            if (onTap != null) ...[
              const SizedBox(height: AppDimensions.paddingM),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingS),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  border: Border.all(
                    color: AppColors.primaryAccent.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.visibility_outlined,
                      size: 16,
                      color: AppColors.primaryAccent,
                    ),
                    const SizedBox(width: AppDimensions.paddingXS),
                    Text(
                      'Tap to view full itinerary',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryAccent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDayPreview(BuildContext context, DayPlanModel day, int dayNumber) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryAccent.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                '$dayNumber',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primaryAccent,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: AppDimensions.paddingS),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day.summary.isNotEmpty ? day.summary : 'Day $dayNumber',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${day.items.length} activities • ${day.date}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
