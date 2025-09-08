import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_styles.dart';
import '../../../trip_planning_chat/data/models/itinerary_models.dart';

/// **Itinerary Card**
/// 
/// Displays the generated itinerary with                        speed: const Duration(milliseconds: 15),days and activities
class ItineraryCard extends StatefulWidget {
  final ItineraryModel itinerary;
  final VoidCallback? onOpenInMaps;
  final bool enableStreaming;

  const ItineraryCard({
    super.key,
    required this.itinerary,
    this.onOpenInMaps,
    this.enableStreaming = false,
  });

  @override
  State<ItineraryCard> createState() => _ItineraryCardState();
}

class _ItineraryCardState extends State<ItineraryCard> {
  int _currentAnimationStep = 0;
  
  // Animation steps:
  // 0 - Title
  // 1 - Day 1 title
  // 2-N - Day 1 activities
  // N+1 - Day 2 title  
  // N+2-M - Day 2 activities
  // ... and so on
  // Final - Actions
  
  List<String> _animationChunks = [];
  
  @override
  void initState() {
    super.initState();
    if (widget.enableStreaming) {
      _prepareAnimationChunks();
    }
  }
  
  void _prepareAnimationChunks() {
    _animationChunks.clear();
    
    // Add title
    _animationChunks.add(widget.itinerary.title);
    
    // Add each day and its activities
    for (int i = 0; i < widget.itinerary.days.length; i++) {
      final day = widget.itinerary.days[i];
      
      // Add day title
      _animationChunks.add('Day ${i + 1}: ${day.summary}');
      
      // Add each activity for this day
      for (final item in day.items) {
        final activityText = item.time.isNotEmpty 
            ? '• ${item.formattedTime}: ${item.activity}'
            : '• ${item.activity}';
        _animationChunks.add(activityText);
      }
    }
    
    // Add actions
    _animationChunks.add('actions');
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enableStreaming) {
      // Non-streaming version (for refinements)
      return _buildStaticCard(context);
    }
    
    // Streaming version (for initial generation)
    return _buildStreamingCard(context);
  }
  
  Widget _buildStaticCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: AppColors.lightGrey.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: const [AppShadows.card],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trip title header
          _buildTitleHeader(context, widget.itinerary.title, false),
          
          // All days content
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display all days
                ...widget.itinerary.days.asMap().entries.map((entry) {
                  final dayIndex = entry.key;
                  final day = entry.value;
                  return _buildDaySection(context, day, dayIndex + 1, false, dayIndex, 0);
                }).toList(),
                
                const SizedBox(height: AppDimensions.paddingL),
                
                // Actions row
                _buildActions(context, false),
                
                const SizedBox(height: AppDimensions.paddingM),
                
                // Trip details
                _buildTripDetails(context),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStreamingCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: AppColors.lightGrey.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: const [AppShadows.card],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trip title header - animate if we're at step 0
          if (_currentAnimationStep >= 0)
            _buildTitleHeader(context, _animationChunks.isNotEmpty ? _animationChunks[0] : '', _currentAnimationStep == 0),
          
          // Days content
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Build days progressively
                ..._buildStreamingDays(context),
                
                // Actions - show if we've reached the last step
                if (_currentAnimationStep >= _animationChunks.length - 1) ...[
                  const SizedBox(height: AppDimensions.paddingL),
                  _buildActions(context, _currentAnimationStep == _animationChunks.length - 1),
                  const SizedBox(height: AppDimensions.paddingM),
                  _buildTripDetails(context),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  List<Widget> _buildStreamingDays(context) {
    List<Widget> dayWidgets = [];
    int chunkIndex = 1; // Start after title
    
    for (int dayIndex = 0; dayIndex < widget.itinerary.days.length; dayIndex++) {
      final day = widget.itinerary.days[dayIndex];
      
      // Add day title if we've reached this chunk
      if (_currentAnimationStep >= chunkIndex) {
        dayWidgets.add(
          _buildDaySection(context, day, dayIndex + 1, _currentAnimationStep == chunkIndex, dayIndex, chunkIndex)
        );
      }
      
      chunkIndex += 1 + day.items.length; // Day title + activities
    }
    
    return dayWidgets;
  }

  Widget _buildTitleHeader(BuildContext context, String title, bool animate) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.radiusL),
          topRight: Radius.circular(AppDimensions.radiusL),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: animate
                ? AnimatedTextKit(
                    animatedTexts: [
                      TyperAnimatedText(
                        title,
                        textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryText,
                        ),
                        speed: const Duration(milliseconds: 25),
                      ),
                    ],
                    totalRepeatCount: 1,
                    onFinished: _onAnimationComplete,
                  )
                : Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                  ),
          ),
          GestureDetector(
            onTap: () => _copyItinerary(context),
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.paddingXS),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Icon(
                Icons.copy_outlined,
                size: 18,
                color: AppColors.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySection(BuildContext context, DayPlanModel day, int dayNumber, bool animate, int dayIndex, int chunkIndex) {
    // Calculate what activities to show based on current animation step
    List<Widget> activityWidgets = [];
    
    if (animate) {
      // Streaming mode - show activities based on animation progress
      for (int i = 0; i < day.items.length; i++) {
        final activityChunkIndex = chunkIndex + 1 + i; // Day title + activity index
        
        if (_currentAnimationStep >= activityChunkIndex) {
          final isAnimating = _currentAnimationStep == activityChunkIndex;
          activityWidgets.add(
            _buildActivityItem(context, day.items[i], isAnimating)
          );
        }
      }
    } else {
      // Static mode - show all activities at once
      for (int i = 0; i < day.items.length; i++) {
        activityWidgets.add(
          _buildActivityItem(context, day.items[i], false)
        );
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day header with map button
        Padding(
          padding: const EdgeInsets.only(
            top: AppDimensions.paddingL,
            bottom: AppDimensions.paddingM,
          ),
          child: Row(
            children: [
              // Day title
              Expanded(
                child: animate
                    ? AnimatedTextKit(
                        animatedTexts: [
                          TyperAnimatedText(
                            'Day $dayNumber: ${day.summary}',
                            textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGreen,
                            ),
                            speed: const Duration(milliseconds: 25),
                          ),
                        ],
                        totalRepeatCount: 1,
                        onFinished: _onAnimationComplete,
                      )
                    : Text(
                        'Day $dayNumber: ${day.summary}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
              ),
              
              // Map button - only show if not animating or animation is complete for this section
              if (!animate || _currentAnimationStep > chunkIndex) ...[
                const SizedBox(width: AppDimensions.paddingS),
                _buildMapButton(day, dayNumber),
              ],
            ],
          ),
        ),
        
        // Activities for this day
        ...activityWidgets,
      ],
    );
  }

  Widget _buildActivityItem(BuildContext context, ActivityItemModel item, bool animate) {
    final activityText = item.time.isNotEmpty 
        ? '${item.formattedTime}: ${item.activity}'
        : item.activity;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingXS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time or bullet
          SizedBox(
            width: 8,
            height: 8,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          const SizedBox(width: AppDimensions.paddingM),
          
          // Activity content
          Expanded(
            child: animate
                ? AnimatedTextKit(
                    animatedTexts: [
                      TyperAnimatedText(
                        activityText,
                        textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primaryText,
                          height: 1.4,
                        ),
                        speed: const Duration(milliseconds: 10),
                      ),
                    ],
                    totalRepeatCount: 1,
                    onFinished: _onAnimationComplete,
                  )
                : Text(
                    activityText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primaryText,
                      height: 1.4,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActions(BuildContext context, bool animate) {
    return animate
        ? AnimatedTextKit(
            animatedTexts: [
              TyperAnimatedText(
                '📍 Open in maps',
                textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
                speed: const Duration(milliseconds: 25),
              ),
            ],
            totalRepeatCount: 1,
            onFinished: () {
              // Animation complete - no more steps
            },
          )
        : GestureDetector(
            onTap: widget.onOpenInMaps,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('📍', style: TextStyle(fontSize: 16)),
                const SizedBox(width: AppDimensions.paddingXS),
                Text(
                  'Open in maps',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingXS),
                Icon(
                  Icons.open_in_new,
                  size: 14,
                  color: AppColors.primaryGreen,
                ),
              ],
            ),
          );
  }
  
  Widget _buildTripDetails(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 16,
            color: AppColors.hintText,
          ),
          const SizedBox(width: AppDimensions.paddingXS),
          Expanded(
            child: Text(
              _getLocationDetails(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.hintText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getLocationDetails() {
    if (widget.itinerary.days.isEmpty) return 'Unknown location';
    
    return '${widget.itinerary.title} • ${widget.itinerary.durationDays} days';
  }

  void _copyItinerary(BuildContext context) {
    final buffer = StringBuffer();
    buffer.writeln(widget.itinerary.title);
    buffer.writeln('${widget.itinerary.startDate} to ${widget.itinerary.endDate}');
    buffer.writeln();
    
    for (int i = 0; i < widget.itinerary.days.length; i++) {
      final day = widget.itinerary.days[i];
      buffer.writeln('Day ${i + 1}: ${day.summary}');
      
      for (final item in day.items) {
        if (item.time.isNotEmpty) {
          buffer.writeln('• ${item.formattedTime}: ${item.activity}');
        } else {
          buffer.writeln('• ${item.activity}');
        }
      }
      buffer.writeln();
    }
    
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Itinerary copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  /// Build map button for a day
  Widget _buildMapButton(DayPlanModel day, int dayNumber) {
    final locations = _extractValidLocations(day);
    final locationCount = locations.length;
    
    return GestureDetector(
      onTap: locationCount > 0 ? () => _openDayInGoogleMaps(day, dayNumber) : null,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: locationCount > 0 
              ? AppColors.primaryGreen.withOpacity(0.1)
              : AppColors.lightGrey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: locationCount > 0 
                ? AppColors.primaryGreen.withOpacity(0.3)
                : AppColors.lightGrey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              locationCount > 0 ? Icons.map_outlined : Icons.location_off_outlined,
              size: 16,
              color: locationCount > 0 
                  ? AppColors.primaryGreen
                  : AppColors.hintText,
            ),
            const SizedBox(width: 4),
            Text(
              locationCount > 0 ? 'Maps ($locationCount)' : 'No locations',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: locationCount > 0 
                    ? AppColors.primaryGreen
                    : AppColors.hintText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Open Google Maps for a specific day's activities
  Future<void> _openDayInGoogleMaps(DayPlanModel day, int dayNumber) async {
    try {
      final locations = _extractValidLocations(day);
      
      if (locations.isEmpty) {
        _showLocationError('No valid locations found for Day $dayNumber');
        return;
      }
      
      String mapsUrl;
      List<String> fallbackUrls = [];
      
      if (locations.length == 1) {
        // Single location - try different URL schemes
        final location = locations.first;
        mapsUrl = 'https://www.google.com/maps/search/?api=1&query=${location.lat},${location.lng}';
        
        // Add fallback URLs
        fallbackUrls = [
          'geo:${location.lat},${location.lng}?q=${location.lat},${location.lng}(${Uri.encodeComponent(location.activity)})',
          'https://maps.google.com/?q=${location.lat},${location.lng}',
          'https://www.google.com/maps/@${location.lat},${location.lng},15z',
        ];
      } else {
        // Multiple locations - create a route or show all locations
        final destination = locations.first;
        final waypoints = locations.skip(1).map((loc) => '${loc.lat},${loc.lng}').join('|');
        
        if (waypoints.isNotEmpty) {
          mapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=${destination.lat},${destination.lng}&waypoints=$waypoints&travelmode=walking';
          
          // Add fallback URLs for multiple locations
          fallbackUrls = [
            'geo:${destination.lat},${destination.lng}?q=${destination.lat},${destination.lng}',
            'https://maps.google.com/maps/dir/${locations.map((loc) => '${loc.lat},${loc.lng}').join('/')}',
            'https://www.google.com/maps/@${destination.lat},${destination.lng},12z',
          ];
        } else {
          mapsUrl = 'https://www.google.com/maps/search/?api=1&query=${destination.lat},${destination.lng}';
          fallbackUrls = [
            'geo:${destination.lat},${destination.lng}',
            'https://maps.google.com/?q=${destination.lat},${destination.lng}',
          ];
        }
      }
      
      // Try launching the primary URL first, then fallbacks
      bool launched = await _tryLaunchUrls([mapsUrl, ...fallbackUrls]);
      
      if (!launched) {
        _showLocationError('Could not open Google Maps - no compatible apps found');
      }
      
    } catch (e) {
      _showLocationError('Error opening maps: ${e.toString()}');
    }
  }
  
  /// Try to launch a list of URLs, returning true if any succeeds
  Future<bool> _tryLaunchUrls(List<String> urls) async {
    for (final url in urls) {
      try {
        final uri = Uri.parse(url);
        
        if (await canLaunchUrl(uri)) {
          // Try different launch modes
          final modes = [
            LaunchMode.externalApplication,
            LaunchMode.platformDefault,
            LaunchMode.inAppWebView,
          ];
          
          for (final mode in modes) {
            try {
              final launched = await launchUrl(uri, mode: mode);
              if (launched) {
                return true;
              }
            } catch (e) {
              continue;
            }
          }
        }
      } catch (e) {
        continue;
      }
    }
    
    return false;
  }
  
  /// Extract valid locations from a day's activities
  List<LocationData> _extractValidLocations(DayPlanModel day) {
    final locations = <LocationData>[];
    
    for (final item in day.items) {
      if (item.location.isNotEmpty && item.location != 'N/A') {
        try {
          final parts = item.location.split(',');
          if (parts.length == 2) {
            final lat = double.parse(parts[0].trim());
            final lng = double.parse(parts[1].trim());
            
            // Basic validation for coordinates
            if (lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
              locations.add(LocationData(
                lat: lat,
                lng: lng,
                activity: item.activity,
                time: item.time,
              ));
            }
          }
        } catch (e) {
          // Skip invalid coordinates
          continue;
        }
      }
    }
    
    return locations;
  }
  
  /// Show error message when location operations fail
  void _showLocationError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }
  
  void _onAnimationComplete() {
    if (mounted && _currentAnimationStep < _animationChunks.length - 1) {
      setState(() {
        _currentAnimationStep++;
      });
    }
  }
}

/// Helper class to store location data for Google Maps integration
class LocationData {
  final double lat;
  final double lng;
  final String activity;
  final String time;
  
  LocationData({
    required this.lat,
    required this.lng,
    required this.activity,
    required this.time,
  });
}
