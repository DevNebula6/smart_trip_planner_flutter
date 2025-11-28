import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../trip_planning_chat/data/models/itinerary_models.dart';
import '../../../trip_planning_chat/data/models/booking_models.dart';
import '../../../core/constants/app_styles.dart';

/// **Stays Tab - Hotels & Accommodation**
/// 
/// Shows hotel recommendations with booking integrations
/// Displays hotels by city with ratings, prices, and booking links
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
    final staysPlan = itinerary.stays;
    
    // Check if stays data is available
    if (staysPlan == null || staysPlan.stays.isEmpty) {
      return _buildEmptyState();
    }

    // Group stays by city
    final staysByCity = <String, List<Stay>>{};
    for (final stay in staysPlan.stays) {
      final city = stay.city ?? 'Other';
      staysByCity.putIfAbsent(city, () => []).add(stay);
    }

    return Container(
      color: AppColors.backgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            _buildSummaryCard(staysPlan),
            const SizedBox(height: AppDimensions.paddingL),
            
            // AI Recommendation
            if (staysPlan.aiRecommendation != null) ...[
              _buildRecommendationCard(staysPlan.aiRecommendation!),
              const SizedBox(height: AppDimensions.paddingL),
            ],
            
            // Hotels by City
            ...staysByCity.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCityHeader(entry.key, entry.value.length),
                  const SizedBox(height: AppDimensions.paddingS),
                  ...entry.value.map((stay) => Padding(
                    padding: const EdgeInsets.only(bottom: AppDimensions.paddingS),
                    child: _buildStayCard(stay),
                  )),
                ],
              ),
            )),
            
            // Bottom spacing
            const SizedBox(height: AppDimensions.paddingXL),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
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
                color: AppColors.primary.withOpacity(0.3),
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
                'No hotel data available',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              Text(
                'Generate a new itinerary to see\nhotel recommendations',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.grey,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(StaysPlan staysPlan) {
    final totalCost = staysPlan.totalCost;
    final totalNights = staysPlan.totalNights;
    
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hotel_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Accommodation',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${staysPlan.stays.length} places • $totalNights nights',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          if (totalCost > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Column(
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    '₹${totalCost.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(String recommendation) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.tertiaryPale,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.tertiary.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_rounded,
            color: AppColors.tertiary,
            size: 24,
          ),
          const SizedBox(width: AppDimensions.paddingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Recommendation',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  recommendation,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityHeader(String city, int count) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.tertiary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          child: Icon(
            Icons.location_city_rounded,
            color: AppColors.tertiary,
            size: 20,
          ),
        ),
        const SizedBox(width: AppDimensions.paddingS),
        Expanded(
          child: Text(
            city,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          child: Text(
            '$count ${count == 1 ? 'option' : 'options'}',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.secondaryText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStayCard(Stay stay) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hotel Image
          if (stay.thumbnailUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppDimensions.radiusM),
              ),
              child: Image.network(
                stay.thumbnailUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150,
                  color: AppColors.lightGrey,
                  child: Icon(
                    Icons.hotel,
                    size: 50,
                    color: AppColors.grey,
                  ),
                ),
              ),
            ),
          
          // Hotel Details
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name, Type Badge and Rating
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stay.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryPale,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  stay.type.displayName,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ),
                              if (stay.freeCancellation)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Free cancellation',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (stay.rating != null)
                      _buildRatingBadge(stay.rating!),
                  ],
                ),
                
                // Address
                if (stay.address.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          stay.address,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryText,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                
                // Nearby Attraction
                if (stay.nearbyAttraction != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.place,
                        size: 14,
                        color: AppColors.info,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          stay.nearbyAttraction!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.info,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                
                // Dates
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: AppColors.grey),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${stay.checkIn} → ${stay.checkOut}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      ' (${stay.nights} nights)',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
                
                // Amenities
                if (stay.amenities != null && stay.amenities!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: stay.amenities!.take(4).map((amenity) => 
                      _buildAmenityChip(amenity)
                    ).toList(),
                  ),
                ],
                
                const SizedBox(height: 12),
                
                // Price and Booking
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (stay.pricePerNight != null)
                          Text(
                            stay.formattedPricePerNight,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        if (stay.totalPrice != null)
                          Text(
                            'Total: ${stay.formattedTotalPrice}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.grey,
                            ),
                          ),
                      ],
                    ),
                    if (stay.bookingUrl != null)
                      TextButton.icon(
                        onPressed: () => _launchUrl(stay.bookingUrl!),
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: const Text('Book Now'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBadge(double rating) {
    Color ratingColor;
    // Assuming rating is out of 10, normalize to 5
    final displayRating = rating > 5 ? rating / 2 : rating;
    
    if (displayRating >= 4.5) {
      ratingColor = AppColors.success;
    } else if (displayRating >= 4.0) {
      ratingColor = AppColors.successLight;
    } else if (displayRating >= 3.5) {
      ratingColor = AppColors.tertiary;
    } else {
      ratingColor = AppColors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ratingColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            displayRating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityChip(String amenity) {
    IconData icon;
    final lowerAmenity = amenity.toLowerCase();
    
    if (lowerAmenity.contains('wifi') || lowerAmenity.contains('internet')) {
      icon = Icons.wifi;
    } else if (lowerAmenity.contains('pool')) {
      icon = Icons.pool;
    } else if (lowerAmenity.contains('parking')) {
      icon = Icons.local_parking;
    } else if (lowerAmenity.contains('breakfast')) {
      icon = Icons.free_breakfast;
    } else if (lowerAmenity.contains('gym') || lowerAmenity.contains('fitness')) {
      icon = Icons.fitness_center;
    } else if (lowerAmenity.contains('spa')) {
      icon = Icons.spa;
    } else if (lowerAmenity.contains('restaurant')) {
      icon = Icons.restaurant;
    } else if (lowerAmenity.contains('bar')) {
      icon = Icons.local_bar;
    } else if (lowerAmenity.contains('ac') || lowerAmenity.contains('air')) {
      icon = Icons.ac_unit;
    } else if (lowerAmenity.contains('pet')) {
      icon = Icons.pets;
    } else {
      icon = Icons.check_circle_outline;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            amenity,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
