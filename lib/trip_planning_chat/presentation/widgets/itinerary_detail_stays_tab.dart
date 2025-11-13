import 'package:flutter/material.dart';
import '../../../trip_planning_chat/data/models/itinerary_models.dart';
import '../../../core/constants/app_styles.dart';

/// **Stays Tab - Hotels & Accommodation**
/// 
/// Shows hotel recommendations with booking integrations
/// Phase 1: Skeleton structure  
/// Phase 2: Will integrate Booking.com API
class ItineraryDetailStaysTab extends StatelessWidget {
  final ItineraryModel itinerary;
  final String sessionId;

  const ItineraryDetailStaysTab({
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
                Icons.hotel_rounded,
                size: 80,
                color: AppColors.primaryGreen.withOpacity(0.3),
              ),
              const SizedBox(height: AppDimensions.paddingL),
              const Text(
                'Accommodation Hub',
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
                'Find and book hotels near your activities\nwith the best prices',
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
                      Icons.hotel,
                      'Hotels & Resorts',
                      'Compare prices via Booking.com',
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    _buildFeatureItem(
                      Icons.home,
                      'Vacation Rentals',
                      'Airbnb & alternative stays',
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    _buildFeatureItem(
                      Icons.location_on,
                      'Smart Recommendations',
                      'Hotels near your planned activities',
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
