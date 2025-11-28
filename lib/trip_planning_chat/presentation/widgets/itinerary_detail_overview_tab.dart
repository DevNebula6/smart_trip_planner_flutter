import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../trip_planning_chat/data/models/itinerary_models.dart';
import '../../../core/constants/app_styles.dart';
import '../widgets/itinerary_card.dart';

/// **Overview Tab - Enhanced Itinerary View with Interactive Map**
/// 
/// Displays day-by-day itinerary in a visual, interactive format
/// Features an interactive map showing all activity locations
class ItineraryDetailOverviewTab extends StatefulWidget {
  final ItineraryModel itinerary;
  final String sessionId;

  const ItineraryDetailOverviewTab({
    super.key,
    required this.itinerary,
    required this.sessionId,
  });

  @override
  State<ItineraryDetailOverviewTab> createState() => _ItineraryDetailOverviewTabState();
}

class _ItineraryDetailOverviewTabState extends State<ItineraryDetailOverviewTab> {
  final MapController _mapController = MapController();
  int? _selectedDayIndex;
  int? _selectedActivityIndex;
  bool _isMapExpanded = false;

  /// Extract all valid locations from the itinerary
  List<MapLocation> get _allLocations {
    final locations = <MapLocation>[];
    
    for (int dayIndex = 0; dayIndex < widget.itinerary.days.length; dayIndex++) {
      final day = widget.itinerary.days[dayIndex];
      for (int actIndex = 0; actIndex < day.items.length; actIndex++) {
        final item = day.items[actIndex];
        final lat = item.latitude;
        final lng = item.longitude;
        
        if (lat != null && lng != null && lat != 0 && lng != 0) {
          locations.add(MapLocation(
            latLng: LatLng(lat, lng),
            dayIndex: dayIndex,
            activityIndex: actIndex,
            activity: item.activity,
            time: item.formattedTime,
            date: day.date,
          ));
        }
      }
    }
    
    return locations;
  }

  /// Get the center point for the map
  LatLng get _mapCenter {
    final locations = _allLocations;
    if (locations.isEmpty) {
      return const LatLng(20.0, 0.0); // Default world center
    }
    
    double sumLat = 0, sumLng = 0;
    for (final loc in locations) {
      sumLat += loc.latLng.latitude;
      sumLng += loc.latLng.longitude;
    }
    
    return LatLng(sumLat / locations.length, sumLng / locations.length);
  }

  /// Calculate appropriate zoom level based on locations spread
  double get _initialZoom {
    final locations = _allLocations;
    if (locations.isEmpty) return 2.0;
    if (locations.length == 1) return 14.0;
    
    double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;
    for (final loc in locations) {
      if (loc.latLng.latitude < minLat) minLat = loc.latLng.latitude;
      if (loc.latLng.latitude > maxLat) maxLat = loc.latLng.latitude;
      if (loc.latLng.longitude < minLng) minLng = loc.latLng.longitude;
      if (loc.latLng.longitude > maxLng) maxLng = loc.latLng.longitude;
    }
    
    final latDiff = maxLat - minLat;
    final lngDiff = maxLng - minLng;
    final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;
    
    if (maxDiff > 50) return 3.0;
    if (maxDiff > 20) return 4.0;
    if (maxDiff > 10) return 5.0;
    if (maxDiff > 5) return 6.0;
    if (maxDiff > 2) return 8.0;
    if (maxDiff > 1) return 10.0;
    if (maxDiff > 0.5) return 11.0;
    return 12.0;
  }

  void _onMarkerTap(MapLocation location) {
    setState(() {
      _selectedDayIndex = location.dayIndex;
      _selectedActivityIndex = location.activityIndex;
    });
    
    // Animate to the selected location
    _mapController.move(location.latLng, 14.0);
  }

  void _toggleMapExpanded() {
    setState(() {
      _isMapExpanded = !_isMapExpanded;
    });
  }

  void _fitAllMarkers() {
    final locations = _allLocations;
    if (locations.isEmpty) return;
    
    if (locations.length == 1) {
      _mapController.move(locations.first.latLng, 14.0);
      return;
    }
    
    double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;
    for (final loc in locations) {
      if (loc.latLng.latitude < minLat) minLat = loc.latLng.latitude;
      if (loc.latLng.latitude > maxLat) maxLat = loc.latLng.latitude;
      if (loc.latLng.longitude < minLng) minLng = loc.latLng.longitude;
      if (loc.latLng.longitude > maxLng) maxLng = loc.latLng.longitude;
    }
    
    final bounds = LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );
    
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50),
      ),
    );
  }

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
            
            // Interactive Map
            _buildInteractiveMap(),
            
            const SizedBox(height: AppDimensions.paddingL),
            
            // Day-by-day itinerary
            ItineraryCard(
              itinerary: widget.itinerary,
              enableStreaming: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripSummaryCard() {
    return Card(
      shadowColor: AppColors.shadowAccent,
      color: AppColors.backgroundColor,
      elevation: 10,
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
                  color: AppColors.primaryAccent,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.paddingS),
                Expanded(
                  child: Text(
                    '${widget.itinerary.durationDays} Day Trip',
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
                      color: AppColors.primaryAccent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingS),
            Text(
              '${widget.itinerary.startDate} - ${widget.itinerary.endDate}',
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
                  '${widget.itinerary.days.length} Days',
                ),
                const SizedBox(width: AppDimensions.paddingL),
                _buildStatItem(
                  Icons.event_outlined,
                  '${_getTotalActivities()} Activities',
                ),
                const SizedBox(width: AppDimensions.paddingL),
                _buildStatItem(
                  Icons.location_on_outlined,
                  '${_allLocations.length} Locations',
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

  Widget _buildInteractiveMap() {
    final locations = _allLocations;
    final hasLocations = locations.isNotEmpty;
    
    return Card(
      elevation: 10,
      shadowColor: AppColors.shadowAccent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Map Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingM,
              vertical: AppDimensions.paddingS,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withOpacity(0.1),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.map_rounded,
                  color: AppColors.primaryAccent,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.paddingS),
                const Expanded(
                  child: Text(
                    'Trip Route Map',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                ),
                if (hasLocations) ...[
                  IconButton(
                    icon: const Icon(Icons.fit_screen, size: 20),
                    onPressed: _fitAllMarkers,
                    tooltip: 'Fit all markers',
                    color: AppColors.primaryAccent,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: AppDimensions.paddingS),
                ],
                IconButton(
                  icon: Icon(
                    _isMapExpanded ? Icons.fullscreen_exit : Icons.fullscreen,
                    size: 20,
                  ),
                  onPressed: _toggleMapExpanded,
                  tooltip: _isMapExpanded ? 'Collapse map' : 'Expand map',
                  color: AppColors.primaryAccent,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          
          // Map Content
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isMapExpanded ? 400 : 180,
            child: hasLocations
                ? _buildFlutterMap(locations)
                : _buildNoLocationsPlaceholder(),
          ),
          
          // Selected Location Info
          if (_selectedDayIndex != null && _selectedActivityIndex != null)
            _buildSelectedLocationInfo(),
          
          // Day Filter Chips
          if (hasLocations)
            _buildDayFilterChips(),
        ],
      ),
    );
  }

  Widget _buildFlutterMap(List<MapLocation> locations) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _mapCenter,
        initialZoom: _initialZoom,
        minZoom: 2,
        maxZoom: 18,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
        onTap: (_, __) {
          setState(() {
            _selectedDayIndex = null;
            _selectedActivityIndex = null;
          });
        },
      ),
      children: [
        // OpenStreetMap Tile Layer
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.smarttripplanner.app',
          maxZoom: 19,
        ),
        
        // Route Polyline (connects markers in order)
        if (locations.length > 1)
          PolylineLayer(
            polylines: [
              Polyline(
                points: locations.map((loc) => loc.latLng).toList(),
                strokeWidth: 3,
                color: AppColors.primaryAccent.withOpacity(0.6),
                pattern: const StrokePattern.dotted(),
              ),
            ],
          ),
        
        // Activity Markers
        MarkerLayer(
          markers: locations.asMap().entries.map((entry) {
            final index = entry.key;
            final location = entry.value;
            final isSelected = _selectedDayIndex == location.dayIndex &&
                _selectedActivityIndex == location.activityIndex;
            
            return Marker(
              point: location.latLng,
              width: isSelected ? 50 : 40,
              height: isSelected ? 50 : 40,
              child: GestureDetector(
                onTap: () => _onMarkerTap(location),
                child: _buildMarker(
                  dayNumber: location.dayIndex + 1,
                  isSelected: isSelected,
                  markerIndex: index + 1,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMarker({
    required int dayNumber,
    required bool isSelected,
    required int markerIndex,
  }) {
    final color = _getDayColor(dayNumber - 1);
    
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? color : color.withOpacity(0.9),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: isSelected ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: isSelected ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$markerIndex',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isSelected ? 14 : 12,
          ),
        ),
      ),
    );
  }

  Widget _buildNoLocationsPlaceholder() {
    return Container(
      color: AppColors.lightGrey,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 48,
              color: AppColors.grey,
            ),
            const SizedBox(height: AppDimensions.paddingS),
            const Text(
              'No location data available',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Location coordinates will appear here\nwhen activities have valid coordinates',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedLocationInfo() {
    final day = widget.itinerary.days[_selectedDayIndex!];
    final activity = day.items[_selectedActivityIndex!];
    
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.primaryAccent.withOpacity(0.05),
        border: Border(
          top: BorderSide(
            color: AppColors.primaryAccent.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _getDayColor(_selectedDayIndex!),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'D${_selectedDayIndex! + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.activity,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${day.date} • ${activity.formattedTime}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () {
              setState(() {
                _selectedDayIndex = null;
                _selectedActivityIndex = null;
              });
            },
            color: AppColors.grey,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildDayFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // "All Days" chip
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: const Text('All Days'),
                selected: _selectedDayIndex == null,
                onSelected: (_) {
                  setState(() {
                    _selectedDayIndex = null;
                    _selectedActivityIndex = null;
                  });
                  _fitAllMarkers();
                },
                backgroundColor: Colors.white,
                selectedColor: AppColors.primaryAccent.withOpacity(0.2),
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: _selectedDayIndex == null 
                      ? AppColors.primaryAccent 
                      : AppColors.secondaryText,
                  fontWeight: _selectedDayIndex == null 
                      ? FontWeight.bold 
                      : FontWeight.normal,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            
            // Individual day chips
            ...List.generate(widget.itinerary.days.length, (index) {
              final dayLocations = _allLocations
                  .where((loc) => loc.dayIndex == index)
                  .toList();
              
              if (dayLocations.isEmpty) return const SizedBox.shrink();
              
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  avatar: CircleAvatar(
                    backgroundColor: _getDayColor(index),
                    radius: 10,
                    child: Text(
                      '${dayLocations.length}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  label: Text('Day ${index + 1}'),
                  selected: _selectedDayIndex == index,
                  onSelected: (_) {
                    setState(() {
                      if (_selectedDayIndex == index) {
                        _selectedDayIndex = null;
                        _selectedActivityIndex = null;
                        _fitAllMarkers();
                      } else {
                        _selectedDayIndex = index;
                        _selectedActivityIndex = null;
                        // Zoom to first location of the day
                        if (dayLocations.isNotEmpty) {
                          _mapController.move(dayLocations.first.latLng, 13.0);
                        }
                      }
                    });
                  },
                  backgroundColor: Colors.white,
                  selectedColor: _getDayColor(index).withOpacity(0.2),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: _selectedDayIndex == index 
                        ? _getDayColor(index) 
                        : AppColors.secondaryText,
                    fontWeight: _selectedDayIndex == index 
                        ? FontWeight.bold 
                        : FontWeight.normal,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _getDayColor(int dayIndex) {
    final colors = [
      AppColors.primaryAccent,
      AppColors.tertiary,
      AppColors.info,
      AppColors.success,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.brown,
    ];
    return colors[dayIndex % colors.length];
  }

  int _getTotalActivities() {
    return widget.itinerary.days.fold(0, (sum, day) => sum + day.items.length);
  }
}

/// Helper class for map locations
class MapLocation {
  final LatLng latLng;
  final int dayIndex;
  final int activityIndex;
  final String activity;
  final String time;
  final String date;

  MapLocation({
    required this.latLng,
    required this.dayIndex,
    required this.activityIndex,
    required this.activity,
    required this.time,
    required this.date,
  });
}
