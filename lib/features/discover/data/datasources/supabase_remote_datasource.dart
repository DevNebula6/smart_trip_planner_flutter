import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/discover_destination.dart';

/// Remote data source for fetching curated destinations from Supabase
class SupabaseRemoteDataSource {
  final SupabaseClient supabaseClient;
  
  SupabaseRemoteDataSource({
    required this.supabaseClient,
  });
  
  /// Fetch all destinations from Supabase
  /// Returns list of destination maps
  /// Set [randomize] to true to get random destinations each time
  Future<List<Map<String, dynamic>>> getAllDestinations({
    DestinationCategory? category,
    int limit = 50,
    int offset = 0,
    bool randomize = false,
  }) async {
    try {
      var queryBuilder = supabaseClient
          .from('destinations')
          .select()
          .eq('is_active', true);
      
      // Filter by category if provided
      if (category != null && category != DestinationCategory.all) {
        queryBuilder = queryBuilder.eq('category', category.name);
      }
      
      List<dynamic> response;
      
      if (randomize) {
        // Fetch more destinations and shuffle locally for randomization
        // Since Supabase doesn't have a native random() function easily accessible,
        // we fetch a larger set and shuffle client-side
        response = await queryBuilder
            .order('hidden_score', ascending: false)
            .limit(limit * 3); // Fetch 3x to get variety
        
        // Shuffle and take the required limit
        final shuffled = List<dynamic>.from(response)..shuffle();
        response = shuffled.take(limit).toList();
      } else {
        // Apply ordering and pagination
        response = await queryBuilder
            .order('hidden_score', ascending: false)
            .range(offset, offset + limit - 1);
      }
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch destinations from Supabase: $e');
    }
  }
  
  /// Search destinations by name or tags
  Future<List<Map<String, dynamic>>> searchDestinations({
    required String query,
    DestinationCategory? category,
    int limit = 20,
  }) async {
    try {
      var queryBuilder = supabaseClient
          .from('destinations')
          .select()
          .eq('is_active', true)
          .or('name.ilike.%$query%,description.ilike.%$query%,tags.cs.{$query}');
      
      // Filter by category if provided
      if (category != null && category != DestinationCategory.all) {
        queryBuilder = queryBuilder.eq('category', category.name);
      }
      
      final response = await queryBuilder.limit(limit);
      
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Failed to search destinations in Supabase: $e');
    }
  }
  
  /// Get single destination by ID
  Future<Map<String, dynamic>> getDestinationById(String id) async {
    try {
      final response = await supabaseClient
          .from('destinations')
          .select()
          .eq('id', id)
          .single();
      
      return response;
    } catch (e) {
      throw Exception('Failed to fetch destination details from Supabase: $e');
    }
  }
  
  /// Get destinations by country
  Future<List<Map<String, dynamic>>> getDestinationsByCountry({
    required String countryCode,
    int limit = 20,
  }) async {
    try {
      final response = await supabaseClient
          .from('destinations')
          .select()
          .eq('is_active', true)
          .eq('country_code', countryCode)
          .order('hidden_score', ascending: false)
          .limit(limit);
      
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Failed to fetch destinations by country: $e');
    }
  }
  
  /// Get top rated destinations (by hidden score)
  Future<List<Map<String, dynamic>>> getTopRatedDestinations({
    int limit = 20,
  }) async {
    try {
      final response = await supabaseClient
          .from('destinations')
          .select()
          .eq('is_active', true)
          .gte('hidden_score', 8.5)
          .order('hidden_score', ascending: false)
          .limit(limit);
      
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Failed to fetch top rated destinations: $e');
    }
  }
  
  /// Increment view count for analytics
  Future<void> incrementViewCount(String destinationId) async {
    try {
      await supabaseClient.rpc('increment_view_count', params: {
        'destination_id': destinationId,
      });
    } catch (e) {
      // Don't throw error for analytics - fail silently
      print('Failed to increment view count: $e');
    }
  }
  
  /// Get random destinations from the entire database
  /// Uses a seed-based approach for efficient randomization
  Future<List<Map<String, dynamic>>> getRandomDestinations({
    DestinationCategory? category,
    int limit = 20,
  }) async {
    try {
      var queryBuilder = supabaseClient
          .from('destinations')
          .select()
          .eq('is_active', true);
      
      // Filter by category if provided
      if (category != null && category != DestinationCategory.all) {
        queryBuilder = queryBuilder.eq('category', category.name);
      }
      
      // Fetch all matching destinations (or a large subset)
      final response = await queryBuilder.limit(250);
      
      // Shuffle client-side for true randomization
      final List<dynamic> shuffled = List<dynamic>.from(response as List);
      shuffled.shuffle();
      
      // Return requested limit
      return List<Map<String, dynamic>>.from(
        shuffled.take(limit).toList()
      );
    } catch (e) {
      throw Exception('Failed to fetch random destinations from Supabase: $e');
    }
  }
}
