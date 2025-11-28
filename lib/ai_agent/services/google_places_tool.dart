/// **Google Places Tool for Gemini AI**
/// 
/// Provides verified location data to the AI:
/// - Place search and verification
/// - Photos and ratings
/// - Opening hours
/// - Contact information
/// 
/// This tool is called by Gemini to get accurate place data
/// instead of hallucinating locations.
library;

import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../../core/utils/helpers.dart';
import '../../trip_planning_chat/data/models/booking_models.dart';

/// Google Places Tool for AI function calling
class GooglePlacesTool {
  static const String _placesBaseUrl = 'https://maps.googleapis.com/maps/api/place';
  static const Duration _requestTimeout = Duration(seconds: 10);
  
  final String apiKey;
  final http.Client _httpClient;

  GooglePlacesTool({
    required this.apiKey,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// Handle function call from Gemini
  /// 
  /// Expected args: {query, location?, radius?, type?}
  Future<Map<String, dynamic>> handleFunctionCall(Map<String, dynamic> args) async {
    try {
      final query = args['query'] as String?;
      final location = args['location'] as String?; // "lat,lng"
      final radius = args['radius'] as int? ?? 5000; // Default 5km
      final type = args['type'] as String?;
      
      if (query == null || query.isEmpty) {
        return {
          'error': 'Query is required',
          'results': <Map<String, dynamic>>[],
        };
      }
      
      Logger.d('GooglePlacesTool: Searching for "$query"', tag: 'PlacesTool');
      
      List<PlaceDetails> results;
      
      if (location != null && location.isNotEmpty) {
        // Nearby search with location
        results = await searchNearby(
          query: query,
          location: location,
          radius: radius,
          type: type,
        );
      } else {
        // Text search without location
        results = await textSearch(query: query, type: type);
      }
      
      Logger.d('GooglePlacesTool: Found ${results.length} results', tag: 'PlacesTool');
      
      return {
        'success': true,
        'query': query,
        'results': results.map((p) => p.toJson()).toList(),
        'count': results.length,
      };
      
    } catch (e) {
      Logger.e('GooglePlacesTool error: $e', tag: 'PlacesTool');
      
      // Check if it's a REQUEST_DENIED error (API not enabled)
      final errorStr = e.toString();
      if (errorStr.contains('REQUEST_DENIED')) {
        return {
          'error': 'Places API not enabled. Use webSearch for location info instead.',
          'results': <Map<String, dynamic>>[],
          'suggestion': 'The Google Places API is not enabled for this key. Consider using webSearch to find location details.',
        };
      }
      
      return {
        'error': 'Place search failed: $e',
        'results': <Map<String, dynamic>>[],
      };
    }
  }

  /// Search for places near a location
  Future<List<PlaceDetails>> searchNearby({
    required String query,
    required String location,
    int radius = 5000,
    String? type,
  }) async {
    try {
      final params = {
        'keyword': query,
        'location': location,
        'radius': radius.toString(),
        'key': apiKey,
      };
      
      if (type != null && type.isNotEmpty) {
        params['type'] = type;
      }
      
      final uri = Uri.parse('$_placesBaseUrl/nearbysearch/json')
          .replace(queryParameters: params);
      
      final response = await _httpClient.get(uri).timeout(_requestTimeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final status = data['status'] as String?;
        
        if (status == 'OK' || status == 'ZERO_RESULTS') {
          final results = data['results'] as List<dynamic>? ?? [];
          return results
              .take(5) // Limit to 5 results
              .map((p) => _parsePlaceResult(p as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception('Places API error: $status');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      Logger.e('Nearby search failed: $e', tag: 'PlacesTool');
      rethrow;
    }
  }

  /// Text-based place search (global)
  Future<List<PlaceDetails>> textSearch({
    required String query,
    String? type,
  }) async {
    try {
      final params = {
        'query': query,
        'key': apiKey,
      };
      
      if (type != null && type.isNotEmpty) {
        params['type'] = type;
      }
      
      final uri = Uri.parse('$_placesBaseUrl/textsearch/json')
          .replace(queryParameters: params);
      
      final response = await _httpClient.get(uri).timeout(_requestTimeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final status = data['status'] as String?;
        
        if (status == 'OK' || status == 'ZERO_RESULTS') {
          final results = data['results'] as List<dynamic>? ?? [];
          return results
              .take(5) // Limit to 5 results
              .map((p) => _parsePlaceResult(p as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception('Places API error: $status');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      Logger.e('Text search failed: $e', tag: 'PlacesTool');
      rethrow;
    }
  }

  /// Get detailed information about a specific place
  Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    try {
      final params = {
        'place_id': placeId,
        'fields': 'place_id,name,formatted_address,geometry,rating,user_ratings_total,'
            'formatted_phone_number,website,photos,price_level,opening_hours,types',
        'key': apiKey,
      };
      
      final uri = Uri.parse('$_placesBaseUrl/details/json')
          .replace(queryParameters: params);
      
      final response = await _httpClient.get(uri).timeout(_requestTimeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final status = data['status'] as String?;
        
        if (status == 'OK' && data['result'] != null) {
          return _parsePlaceDetailsResult(data['result'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      Logger.e('Place details failed: $e', tag: 'PlacesTool');
      return null;
    }
  }

  /// Get photo URL from photo reference
  String getPhotoUrl(String photoReference, {int maxWidth = 400}) {
    return '$_placesBaseUrl/photo'
        '?photoreference=$photoReference'
        '&maxwidth=$maxWidth'
        '&key=$apiKey';
  }

  /// Parse place result from search response
  PlaceDetails _parsePlaceResult(Map<String, dynamic> place) {
    final geometry = place['geometry'] as Map<String, dynamic>?;
    final location = geometry?['location'] as Map<String, dynamic>?;
    final lat = location?['lat'] as num? ?? 0;
    final lng = location?['lng'] as num? ?? 0;
    
    // Get photo URLs
    final photos = place['photos'] as List<dynamic>?;
    final photoUrls = photos?.map((p) {
      final ref = (p as Map<String, dynamic>)['photo_reference'] as String?;
      return ref != null ? getPhotoUrl(ref) : null;
    }).whereType<String>().toList();
    
    // Parse price level
    String? priceLevel;
    final priceLevelNum = place['price_level'] as int?;
    if (priceLevelNum != null) {
      priceLevel = '\$' * (priceLevelNum + 1);
    }
    
    // Parse opening hours
    final openingHours = place['opening_hours'] as Map<String, dynamic>?;
    final isOpen = openingHours?['open_now'] as bool?;
    
    return PlaceDetails(
      placeId: place['place_id'] as String? ?? '',
      name: place['name'] as String? ?? 'Unknown Place',
      address: place['formatted_address'] as String? ?? place['vicinity'] as String? ?? '',
      location: '$lat,$lng',
      rating: (place['rating'] as num?)?.toDouble(),
      userRatingsTotal: place['user_ratings_total'] as int?,
      photoUrls: photoUrls,
      priceLevel: priceLevel,
      isOpen: isOpen,
      types: (place['types'] as List<dynamic>?)?.cast<String>(),
    );
  }

  /// Parse detailed place result
  PlaceDetails _parsePlaceDetailsResult(Map<String, dynamic> place) {
    final geometry = place['geometry'] as Map<String, dynamic>?;
    final location = geometry?['location'] as Map<String, dynamic>?;
    final lat = location?['lat'] as num? ?? 0;
    final lng = location?['lng'] as num? ?? 0;
    
    // Get photo URLs
    final photos = place['photos'] as List<dynamic>?;
    final photoUrls = photos?.map((p) {
      final ref = (p as Map<String, dynamic>)['photo_reference'] as String?;
      return ref != null ? getPhotoUrl(ref) : null;
    }).whereType<String>().toList();
    
    // Parse price level
    String? priceLevel;
    final priceLevelNum = place['price_level'] as int?;
    if (priceLevelNum != null) {
      priceLevel = '\$' * (priceLevelNum + 1);
    }
    
    // Parse opening hours
    final openingHoursData = place['opening_hours'] as Map<String, dynamic>?;
    final weekdayText = openingHoursData?['weekday_text'] as List<dynamic>?;
    Map<String, String>? openingHours;
    if (weekdayText != null) {
      openingHours = {};
      for (final text in weekdayText) {
        final parts = (text as String).split(': ');
        if (parts.length == 2) {
          openingHours[parts[0]] = parts[1];
        }
      }
    }
    
    return PlaceDetails(
      placeId: place['place_id'] as String? ?? '',
      name: place['name'] as String? ?? 'Unknown Place',
      address: place['formatted_address'] as String? ?? '',
      location: '$lat,$lng',
      rating: (place['rating'] as num?)?.toDouble(),
      userRatingsTotal: place['user_ratings_total'] as int?,
      phoneNumber: place['formatted_phone_number'] as String?,
      website: place['website'] as String?,
      photoUrls: photoUrls,
      priceLevel: priceLevel,
      openingHours: openingHours,
      isOpen: openingHoursData?['open_now'] as bool?,
      types: (place['types'] as List<dynamic>?)?.cast<String>(),
    );
  }
}
