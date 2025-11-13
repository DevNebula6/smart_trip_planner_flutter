import 'package:flutter/material.dart';
import '../../../trip_planning_chat/data/models/itinerary_models.dart';
import '../../../core/constants/app_styles.dart';

/// **Budget Tab - Cost Breakdown & Tracking**
/// 
/// Shows comprehensive budget with AI-powered estimates
/// Phase 1: Skeleton structure
/// Phase 2: Will add AI-based cost estimation
class ItineraryDetailBudgetTab extends StatelessWidget {
  final ItineraryModel itinerary;
  final String sessionId;

  const ItineraryDetailBudgetTab({
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
                Icons.account_balance_wallet_rounded,
                size: 80,
                color: AppColors.primaryGreen.withOpacity(0.3),
              ),
              const SizedBox(height: AppDimensions.paddingL),
              const Text(
                'Budget Tracker',
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
                'Track your trip costs with AI-powered\nestimates and real-time pricing',
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
                      Icons.attach_money,
                      'Cost Breakdown',
                      'Flights, hotels, food, activities',
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    _buildFeatureItem(
                      Icons.pie_chart,
                      'Visual Analytics',
                      'See spending by category',
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    _buildFeatureItem(
                      Icons.lightbulb_outline,
                      'AI Optimization',
                      'Get cost-saving suggestions',
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
