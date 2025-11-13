import 'package:flutter/material.dart';
import '../../../trip_planning_chat/data/models/itinerary_models.dart';
import '../../../core/constants/app_styles.dart';
import '../widgets/itinerary_card.dart';

/// **Overview Tab - Enhanced Itinerary View**
/// 
/// Displays day-by-day itinerary in a visual, interactive format
/// Reuses existing ItineraryCard with enhancements
class ItineraryDetailOverviewTab extends StatelessWidget {
  final ItineraryModel itinerary;
  final String sessionId;

  const ItineraryDetailOverviewTab({
    super.key,
    required this.itinerary,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip summary card
            _buildTripSummaryCard(),
            
            const SizedBox(height: AppDimensions.paddingL),
            
            // Map placeholder (future enhancement)
            _buildMapPlaceholder(),
            
            const SizedBox(height: AppDimensions.paddingL),
            
            // Day-by-day itinerary
            ItineraryCard(
              itinerary: itinerary,
              enableStreaming: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripSummaryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: AppColors.primaryGreen,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.paddingS),
                Expanded(
                  child: Text(
                    '${itinerary.durationDays} Day Trip',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingS,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Text(
                    'Draft',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingS),
            Text(
              '${itinerary.startDate} - ${itinerary.endDate}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            const Divider(),
            const SizedBox(height: AppDimensions.paddingS),
            Row(
              children: [
                _buildStatItem(
                  Icons.place_outlined,
                  '${itinerary.days.length} Days',
                ),
                const SizedBox(width: AppDimensions.paddingL),
                _buildStatItem(
                  Icons.event_outlined,
                  '${_getTotalActivities()} Activities',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.secondaryText,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildMapPlaceholder() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.map_outlined,
                size: 48,
                color: AppColors.grey,
              ),
              SizedBox(height: AppDimensions.paddingS),
              Text(
                'Interactive Map',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryText,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Coming soon',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getTotalActivities() {
    return itinerary.days.fold(0, (sum, day) => sum + day.items.length);
  }
}
