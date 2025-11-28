import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/errors/failures.dart';
import '../../domain/entities/discover_destination.dart';

/// Remote datasource for Google Places API (Legacy Nearby Search)
/// 
/// Uses Legacy API for simplicity and better free tier support:
/// - Base URL: https://maps.googleapis.com/maps/api/place/nearbysearch/json
/// - Free Tier: $200/month credit (~32,000 Nearby Search requests)
/// - Photos INCLUDED in response (photo_reference)
/// - Well-documented and stable
class GooglePlacesRemoteDataSource {
  final http.Client client;
  final String _apiKey;
  
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
  static const int _defaultRadius = 50000; // 50km radius
  
  GooglePlacesRemoteDataSource({
    required http.Client client,
    required String apiKey,
  })  : client = client,
        _apiKey = apiKey;
  
  /// Search for destinations near a location with optional category filtering
  /// 
  /// [latitude] and [longitude] define the center point
  /// [radius] in meters (max 50,000)
  /// [category] filters by type (maps to Google Place types)
  Future<List<Map<String, dynamic>>> searchNearby({
    required double latitude,
    required double longitude,
    int radius = _defaultRadius,
    DestinationCategory? category,
  }) async {
    try {
      print('🔍 Google Places: Searching at $latitude,$longitude');
      
      // Build query parameters
      final queryParams = {
        'location': '$latitude,$longitude',
        'radius': radius.toString(),
        'key': _apiKey,
      };
      
      // Add type filter if category specified
      if (category != null && category != DestinationCategory.all) {
        final type = _mapCategoryToGoogleType(category);
        if (type != null) {
          queryParams['type'] = type;
        }
      }
      
      // Build URL
      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);
      print('🌐 Google Places Request: $uri');
      print('🔑 API Key: ${_apiKey.substring(0, 10)}...');
      
      // Make request
      final response = await client.get(uri);
      print('📡 Google Places Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final status = data['status'];
        
        if (status == 'OK') {
          final results = data['results'] as List<dynamic>;
          print('✅ Google Places: Got ${results.length} results');
          return results.cast<Map<String, dynamic>>();
        } else if (status == 'ZERO_RESULTS') {
          print('⚠️ Google Places: No results found');
          return [];
        } else {
          final errorMessage = data['error_message'] ?? status;
          print('❌ Google Places Error: $errorMessage');
          throw ApiFailure('Google Places API error: $errorMessage');
        }
      } else if (response.statusCode == 403) {
        throw ApiFailure('Google Places API key invalid or quota exceeded');
      } else if (response.statusCode == 400) {
        throw ApiFailure('Invalid request parameters');
      } else {
        throw ApiFailure('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('🔴 Google Places Error: $e');
      if (e is ApiFailure) rethrow;
      throw ApiFailure('Failed to search destinations: $e');
    }
  }
  
  /// Get photo URL from photo_reference
  /// 
  /// [photoReference] from the photos[] array in place response
  /// [maxWidth] maximum width in pixels (1-1600)
  String getPhotoUrl(String photoReference, {int maxWidth = 400}) {
    return 'https://maps.googleapis.com/maps/api/place/photo'
        '?photoreference=$photoReference'
        '&maxwidth=$maxWidth'
        '&key=$_apiKey';
  }
  
  /// Map our category to Google Place type
  /// 
  /// Google types: https://developers.google.com/maps/documentation/places/web-service/supported_types
  String? _mapCategoryToGoogleType(DestinationCategory category) {
    switch (category) {
      case DestinationCategory.natural:
        return 'park'; // Parks, nature reserves
      case DestinationCategory.cultural:
        return 'museum'; // Museums, galleries, cultural sites
      case DestinationCategory.architecture:
        return 'church'; // Historical buildings, monuments
      case DestinationCategory.adventure:
        return 'tourist_attraction'; // Adventure activities
      case DestinationCategory.urban:
        return 'point_of_interest'; // Urban POIs
      case DestinationCategory.coastal:
        return 'natural_feature'; // Beaches, coastal features
      case DestinationCategory.all:
        return null; // No filter
    }
  }
}
