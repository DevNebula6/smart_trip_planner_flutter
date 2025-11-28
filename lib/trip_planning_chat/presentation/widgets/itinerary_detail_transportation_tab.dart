import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../trip_planning_chat/data/models/itinerary_models.dart';
import '../../../trip_planning_chat/data/models/booking_models.dart';
import '../../../core/constants/app_styles.dart';

/// **Transportation Tab - Flight, Train & Local Transport**
/// 
/// Shows all transportation options with booking integrations
/// Displays outbound/return flights, inter-city transport, and local transport
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
    final transport = itinerary.transport;
    
    // Check if transport data is available
    if (transport == null) {
      return _buildEmptyState();
    }

    return Container(
      color: AppColors.backgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Outbound Flight Section
            if (transport.outbound != null) ...[
              _buildSectionHeader(
                icon: Icons.flight_takeoff_rounded,
                title: 'Outbound Journey',
                color: AppColors.primary,
              ),
              const SizedBox(height: AppDimensions.paddingS),
              _buildTransportSegmentCard(transport.outbound!, isOutbound: true),
              const SizedBox(height: AppDimensions.paddingL),
            ],

            // Return Flight Section
            if (transport.returnTrip != null) ...[
              _buildSectionHeader(
                icon: Icons.flight_land_rounded,
                title: 'Return Journey',
                color: AppColors.tertiary,
              ),
              const SizedBox(height: AppDimensions.paddingS),
              _buildTransportSegmentCard(transport.returnTrip!, isOutbound: false),
              const SizedBox(height: AppDimensions.paddingL),
            ],

            // Inter-City Transport Section
            if (transport.interCity.isNotEmpty) ...[
              _buildSectionHeader(
                icon: Icons.train_rounded,
                title: 'Inter-City Transport',
                color: AppColors.info,
              ),
              const SizedBox(height: AppDimensions.paddingS),
              ...transport.interCity.map((segment) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.paddingS),
                child: _buildInterCityCard(segment),
              )),
              const SizedBox(height: AppDimensions.paddingL),
            ],

            // Local Transport Section
            if (transport.localTransport != null) ...[
              _buildSectionHeader(
                icon: Icons.directions_bus_rounded,
                title: 'Local Transportation',
                color: AppColors.accent,
              ),
              const SizedBox(height: AppDimensions.paddingS),
              _buildLocalTransportCard(transport.localTransport!),
            ],

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
                Icons.flight_takeoff_rounded,
                size: 80,
                color: AppColors.primary.withOpacity(0.3),
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
                'No transport data available',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              Text(
                'Generate a new itinerary to see\nflight and transport options',
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

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: AppDimensions.paddingS),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildTransportSegmentCard(TransportSegment segment, {required bool isOutbound}) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
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
          // Route Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      segment.originCode.isNotEmpty ? segment.originCode : segment.origin,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                    Text(
                      segment.origin,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    if (segment.formattedDepartureTime.isNotEmpty)
                      Text(
                        segment.formattedDepartureTime,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.accent,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                children: [
                  Icon(
                    isOutbound ? Icons.arrow_forward : Icons.arrow_back,
                    color: AppColors.primary,
                  ),
                  if (segment.duration != null)
                    Text(
                      segment.duration!,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.grey,
                      ),
                    ),
                  if (segment.stops != null)
                    Text(
                      segment.stops == 0 ? 'Direct' : '${segment.stops} stop(s)',
                      style: TextStyle(
                        fontSize: 10,
                        color: segment.stops == 0 ? AppColors.success : AppColors.tertiary,
                      ),
                    ),
                ],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      segment.destinationCode.isNotEmpty ? segment.destinationCode : segment.destination,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                    Text(
                      segment.destination,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    if (segment.formattedArrivalTime.isNotEmpty)
                      Text(
                        segment.formattedArrivalTime,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.accent,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingM),
          // Carrier and Details
          if (segment.carrier != null) ...[
            Row(
              children: [
                Icon(
                  _getTransportIcon(segment.type),
                  size: 16,
                  color: AppColors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  segment.carrier!,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryText,
                  ),
                ),
                if (segment.flightNumber != null) ...[
                  Text(
                    ' • ${segment.flightNumber}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.grey,
                    ),
                  ),
                ],
                if (segment.cabinClass != null) ...[
                  Text(
                    ' • ${segment.cabinClass}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppDimensions.paddingS),
          ],
          // Price and Booking
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (segment.price != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Text(
                    segment.formattedPrice,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
              if (segment.bookingUrl != null)
                TextButton.icon(
                  onPressed: () => _launchUrl(segment.bookingUrl!),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('Book Now'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInterCityCard(TransportSegment segment) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getTransportIcon(segment.type),
                color: AppColors.info,
                size: 24,
              ),
              const SizedBox(width: AppDimensions.paddingS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${segment.origin} → ${segment.destination}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                    Row(
                      children: [
                        if (segment.carrier != null)
                          Text(
                            segment.carrier!,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        if (segment.duration != null)
                          Text(
                            ' • ${segment.duration}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.grey,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (segment.price != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Text(
                    segment.formattedPrice,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.info,
                    ),
                  ),
                ),
            ],
          ),
          if (segment.bookingUrl != null) ...[
            const SizedBox(height: AppDimensions.paddingS),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _launchUrl(segment.bookingUrl!),
                icon: const Icon(Icons.open_in_new, size: 14),
                label: const Text('Book'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.info,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 32),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocalTransportCard(LocalTransportInfo info) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.accent.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (info.recommendation != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.tertiary,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.paddingS),
                Expanded(
                  child: Text(
                    info.recommendation!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingM),
          ],
          // Cost info
          Wrap(
            spacing: AppDimensions.paddingS,
            runSpacing: AppDimensions.paddingS,
            children: [
              if (info.estimatedDailyCost != null)
                _buildCostChip(
                  'Daily: ${_formatCurrency(info.estimatedDailyCost!, info.currency)}',
                  Icons.today,
                ),
              if (info.estimatedTotalCost != null)
                _buildCostChip(
                  'Total: ${_formatCurrency(info.estimatedTotalCost!, info.currency)}',
                  Icons.attach_money,
                ),
              if (info.passName != null)
                _buildCostChip(info.passName!, Icons.confirmation_num),
            ],
          ),
          // Tips
          if (info.tips != null && info.tips!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.paddingM),
            ...info.tips!.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: AppColors.accent)),
                  Expanded(
                    child: Text(
                      tip,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
          // Pass purchase link
          if (info.passUrl != null) ...[
            const SizedBox(height: AppDimensions.paddingS),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _launchUrl(info.passUrl!),
                icon: const Icon(Icons.shopping_cart, size: 14),
                label: const Text('Buy Pass'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.accent,
                ),
              ),
            ),
          ],
          // Transport Booking Apps Section
          const SizedBox(height: AppDimensions.paddingM),
          _buildTransportAppsSection(),
        ],
      ),
    );
  }
  
  /// Build transport booking apps quick access section
  Widget _buildTransportAppsSection() {
    final transportApps = [
      {'name': 'Uber', 'icon': Icons.local_taxi, 'url': 'https://www.uber.com/', 'color': Colors.black},
      {'name': 'Ola', 'icon': Icons.local_taxi, 'url': 'https://www.olacabs.com/', 'color': Colors.green},
      {'name': 'Rapido', 'icon': Icons.two_wheeler, 'url': 'https://www.rapido.bike/', 'color': Colors.amber},
      {'name': 'Metro', 'icon': Icons.subway, 'url': null, 'color': Colors.blue},
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: AppDimensions.paddingS),
        Text(
          'Quick Booking',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingS),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: transportApps.map((app) {
              return Padding(
                padding: const EdgeInsets.only(right: AppDimensions.paddingS),
                child: _buildQuickBookingChip(
                  name: app['name'] as String,
                  icon: app['icon'] as IconData,
                  url: app['url'] as String?,
                  color: app['color'] as Color,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuickBookingChip({
    required String name,
    required IconData icon,
    String? url,
    required Color color,
  }) {
    return InkWell(
      onTap: url != null ? () => _launchUrl(url) : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            if (url != null) ...[
              const SizedBox(width: 4),
              Icon(Icons.open_in_new, size: 10, color: color),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCostChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryPale,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.accent),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount, String currency) {
    final symbol = currency == 'INR' ? '₹' : currency == 'USD' ? '\$' : currency;
    return '$symbol${amount.toStringAsFixed(0)}';
  }

  IconData _getTransportIcon(TransportType type) {
    switch (type) {
      case TransportType.flight:
        return Icons.flight;
      case TransportType.train:
        return Icons.train;
      case TransportType.bus:
        return Icons.directions_bus;
      case TransportType.ferry:
        return Icons.directions_boat;
      case TransportType.car:
        return Icons.directions_car;
      case TransportType.taxi:
        return Icons.local_taxi;
      case TransportType.metro:
        return Icons.subway;
      case TransportType.other:
        return Icons.commute;
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
