/// **Booking.com Tool for Gemini AI (RapidAPI)**
/// 
/// Provides hotel search and booking data:
/// - Search hotels by destination
/// - Get prices and availability
/// - Generate booking URLs
/// 
/// Uses RapidAPI's Booking.com endpoint for MVP
/// Can be switched to official Booking.com Affiliate API later
library;

import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../../core/utils/helpers.dart';
import '../../trip_planning_chat/data/models/booking_models.dart';

/// Booking.com Tool for AI function calling (Hotels)
class BookingComTool {
  static const String _baseUrl = 'https://booking-com.p.rapidapi.com';
  static const Duration _requestTimeout = Duration(seconds: 15);
  
  final String rapidApiKey;
  final http.Client _httpClient;

  BookingComTool({
    required this.rapidApiKey,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// Common headers for RapidAPI
  Map<String, String> get _headers => {
    'X-RapidAPI-Key': rapidApiKey,
    'X-RapidAPI-Host': 'booking-com.p.rapidapi.com',
  };

  /// Handle function call from Gemini for hotel search
  Future<Map<String, dynamic>> handleHotelSearch(Map<String, dynamic> args) async {
    try {
      final destination = args['destination'] as String?;
      final checkIn = args['checkIn'] as String?; // YYYY-MM-DD
      final checkOut = args['checkOut'] as String?; // YYYY-MM-DD
      final adults = args['adults'] as int? ?? 2;
      final rooms = args['rooms'] as int? ?? 1;
      final currency = args['currency'] as String? ?? 'INR';
      final priceRange = args['priceRange'] as String?; // budget, mid-range, luxury
      
      if (destination == null || destination.isEmpty) {
        return {'error': 'Destination is required', 'results': []};
      }
      if (checkIn == null || checkOut == null) {
        return {'error': 'Check-in and check-out dates are required', 'results': []};
      }
      
      Logger.d('BookingComTool: Searching hotels in "$destination"', tag: 'BookingTool');
      
      // First, get destination ID
      final destId = await _getDestinationId(destination);
      if (destId == null) {
        return {
          'error': 'Could not find destination: $destination',
          'results': [],
        };
      }
      
      // Search hotels
      final hotels = await searchHotels(
        destId: destId,
        checkIn: checkIn,
        checkOut: checkOut,
        adults: adults,
        rooms: rooms,
        currency: currency,
      );
      
      // Filter by price range if specified
      List<Stay> filteredHotels = hotels;
      if (priceRange != null) {
        filteredHotels = _filterByPriceRange(hotels, priceRange);
      }
      
      Logger.d('BookingComTool: Found ${filteredHotels.length} hotels', tag: 'BookingTool');
      
      return {
        'success': true,
        'destination': destination,
        'checkIn': checkIn,
        'checkOut': checkOut,
        'results': filteredHotels.take(5).map((h) => h.toJson()).toList(),
        'count': filteredHotels.length,
      };
      
    } catch (e) {
      Logger.e('BookingComTool error: $e', tag: 'BookingTool');
      return {
        'error': 'Hotel search failed: $e',
        'results': [],
      };
    }
  }

  /// Get destination ID from location name
  Future<String?> _getDestinationId(String destination) async {
    try {
      final uri = Uri.parse('$_baseUrl/v1/hotels/locations').replace(
        queryParameters: {
          'name': destination,
          'locale': 'en-us',
        },
      );
      
      final response = await _httpClient
          .get(uri, headers: _headers)
          .timeout(_requestTimeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        if (data.isNotEmpty) {
          // Get the first city/region result
          final firstResult = data.first as Map<String, dynamic>;
          return firstResult['dest_id']?.toString();
        }
      }
      return null;
    } catch (e) {
      Logger.e('Failed to get destination ID: $e', tag: 'BookingTool');
      return null;
    }
  }

  /// Search hotels by destination ID
  Future<List<Stay>> searchHotels({
    required String destId,
    required String checkIn,
    required String checkOut,
    int adults = 2,
    int rooms = 1,
    String currency = 'INR',
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/v1/hotels/search').replace(
        queryParameters: {
          'dest_id': destId,
          'dest_type': 'city',
          'checkin_date': checkIn,
          'checkout_date': checkOut,
          'adults_number': adults.toString(),
          'room_number': rooms.toString(),
          'units': 'metric',
          'order_by': 'popularity',
          'filter_by_currency': currency,
          'locale': 'en-us',
          'page_number': '0',
        },
      );
      
      final response = await _httpClient
          .get(uri, headers: _headers)
          .timeout(_requestTimeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['result'] as List<dynamic>? ?? [];
        
        // Calculate nights
        final checkInDate = DateTime.parse(checkIn);
        final checkOutDate = DateTime.parse(checkOut);
        final nights = checkOutDate.difference(checkInDate).inDays;
        
        return results.map((hotel) => _parseHotelResult(
          hotel as Map<String, dynamic>,
          checkIn: checkIn,
          checkOut: checkOut,
          nights: nights,
          currency: currency,
        )).toList();
      } else {
        Logger.e('Hotel search failed: ${response.statusCode}', tag: 'BookingTool');
        return [];
      }
    } catch (e) {
      Logger.e('Hotel search error: $e', tag: 'BookingTool');
      return [];
    }
  }

  /// Parse hotel result from API response
  Stay _parseHotelResult(
    Map<String, dynamic> hotel, {
    required String checkIn,
    required String checkOut,
    required int nights,
    required String currency,
  }) {
    // Extract price
    final priceBreakdown = hotel['price_breakdown'] as Map<String, dynamic>?;
    final grossPrice = priceBreakdown?['gross_price'] as num?;
    final allInclusivePrice = priceBreakdown?['all_inclusive_price'] as num?;
    final totalPrice = allInclusivePrice ?? grossPrice;
    final pricePerNight = totalPrice != null && nights > 0 
        ? totalPrice / nights 
        : null;
    
    // Extract location
    final latitude = hotel['latitude'] as num? ?? 0;
    final longitude = hotel['longitude'] as num? ?? 0;
    
    // Extract images
    final mainPhotoUrl = hotel['main_photo_url'] as String?;
    final maxPhotoUrl = hotel['max_photo_url'] as String?;
    final photoUrls = <String>[];
    if (maxPhotoUrl != null) photoUrls.add(maxPhotoUrl);
    if (mainPhotoUrl != null && mainPhotoUrl != maxPhotoUrl) photoUrls.add(mainPhotoUrl);
    
    // Extract amenities from review scores (simplified)
    final reviewScore = hotel['review_score'] as num?;
    // Review score word available but not used: hotel['review_score_word']
    
    // Build booking URL
    final hotelId = hotel['hotel_id']?.toString() ?? '';
    final bookingUrl = 'https://www.booking.com/hotel/search.html?hotel_id=$hotelId';
    
    return Stay(
      id: hotelId,
      name: hotel['hotel_name'] as String? ?? 'Unknown Hotel',
      type: _determineStayType(hotel),
      address: hotel['address'] as String? ?? '',
      location: '$latitude,$longitude',
      city: hotel['city'] as String?,
      checkIn: checkIn,
      checkOut: checkOut,
      nights: nights,
      pricePerNight: pricePerNight?.toDouble(),
      totalPrice: totalPrice?.toDouble(),
      currency: currency,
      rating: reviewScore?.toDouble(),
      reviewCount: hotel['review_nr'] as int?,
      imageUrls: photoUrls.isNotEmpty ? photoUrls : null,
      thumbnailUrl: mainPhotoUrl,
      amenities: _extractAmenities(hotel),
      roomType: hotel['unit_configuration_label'] as String?,
      freeCancellation: hotel['is_free_cancellable'] == 1,
      breakfastIncluded: hotel['has_free_breakfast'] == 1,
      bookingUrl: bookingUrl,
      nearbyAttraction: hotel['distance_to_cc'] != null 
          ? '${hotel['distance_to_cc']} km from city center'
          : null,
    );
  }

  /// Determine stay type from hotel data
  StayType _determineStayType(Map<String, dynamic> hotel) {
    final accommodationType = hotel['accommodation_type_name'] as String?;
    if (accommodationType != null) {
      final lower = accommodationType.toLowerCase();
      if (lower.contains('hostel')) return StayType.hostel;
      if (lower.contains('apartment')) return StayType.apartment;
      if (lower.contains('resort')) return StayType.resort;
      if (lower.contains('guest')) return StayType.guesthouse;
      if (lower.contains('villa')) return StayType.villa;
      if (lower.contains('home')) return StayType.homestay;
    }
    return StayType.hotel;
  }

  /// Extract amenities from hotel data
  List<String>? _extractAmenities(Map<String, dynamic> hotel) {
    final amenities = <String>[];
    
    if (hotel['has_free_breakfast'] == 1) amenities.add('Free Breakfast');
    if (hotel['is_free_cancellable'] == 1) amenities.add('Free Cancellation');
    if (hotel['has_swimming_pool'] == 1) amenities.add('Swimming Pool');
    
    // Add from badges if available
    final badges = hotel['badges'] as List<dynamic>?;
    if (badges != null) {
      for (final badge in badges) {
        final text = (badge as Map<String, dynamic>)['text'] as String?;
        if (text != null && !amenities.contains(text)) {
          amenities.add(text);
        }
      }
    }
    
    return amenities.isNotEmpty ? amenities : null;
  }

  /// Filter hotels by price range
  List<Stay> _filterByPriceRange(List<Stay> hotels, String priceRange) {
    if (hotels.isEmpty) return hotels;
    
    // Calculate price thresholds based on actual prices
    final prices = hotels
        .where((h) => h.pricePerNight != null)
        .map((h) => h.pricePerNight!)
        .toList();
    
    if (prices.isEmpty) return hotels;
    
    prices.sort();
    final median = prices[prices.length ~/ 2];
    
    switch (priceRange.toLowerCase()) {
      case 'budget':
        return hotels.where((h) => 
          h.pricePerNight != null && h.pricePerNight! < median * 0.7
        ).toList();
      case 'mid-range':
        return hotels.where((h) => 
          h.pricePerNight != null && 
          h.pricePerNight! >= median * 0.7 && 
          h.pricePerNight! <= median * 1.3
        ).toList();
      case 'luxury':
        return hotels.where((h) => 
          h.pricePerNight != null && h.pricePerNight! > median * 1.3
        ).toList();
      default:
        return hotels;
    }
  }
}
