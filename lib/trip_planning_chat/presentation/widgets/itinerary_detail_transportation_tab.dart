import 'package:flutter/material.dart';
import '../../../trip_planning_chat/data/models/itinerary_models.dart';
import '../../../core/constants/app_styles.dart';

/// **Transportation Tab - Flight, Train & Local Transport**
/// 
/// Shows all transportation options with booking integrations
/// Phase 1: Skeleton structure
/// Phase 2: Will integrate Skyscanner API for flights
class ItineraryDetailTransportationTab extends StatelessWidget {
  final ItineraryModel itinerary;
  final String sessionId;

  const ItineraryDetailTransportationTab({
    super.key,
    required this.itinerary,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.flight_takeoff_rounded,
                size: 80,
                color: AppColors.primaryGreen.withOpacity(0.3),
              ),
              const SizedBox(height: AppDimensions.paddingL),
              const Text(
                'Transportation Hub',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingS),
              Text(
                'Coming Soon',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              Text(
                'Book flights, trains, and local transport\nwith affiliate integrations',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.grey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingXL),
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFeatureItem(
                      Icons.flight,
                      'Outbound & Return Flights',
                      'Compare prices via Skyscanner',
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    _buildFeatureItem(
                      Icons.train,
                      'Inter-City Transport',
                      'Trains, buses between destinations',
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    _buildFeatureItem(
                      Icons.directions_bus,
                      'Local Transportation',
                      'Metro passes, taxi estimates',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(
          icon,
          size: 24,
          color: AppColors.primaryGreen,
        ),
        const SizedBox(width: AppDimensions.paddingS),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
