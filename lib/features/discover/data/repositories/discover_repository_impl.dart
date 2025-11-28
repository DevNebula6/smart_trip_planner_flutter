import '../../domain/entities/discover_destination.dart';
import '../../domain/repositories/discover_repository.dart';
import '../datasources/google_places_remote_datasource.dart';
import '../datasources/supabase_remote_datasource.dart';
import '../datasources/curated_local_datasource.dart';
import '../../../../core/errors/failures.dart';

/// Implementation of DiscoverRepository with 2-tier fallback:
/// 1. Supabase (cloud database - most up-to-date)
/// 2. Local JSON Cache (bundled with app - offline support)
class DiscoverRepositoryImpl implements DiscoverRepository {
  final GooglePlacesRemoteDataSource googlePlacesDataSource;
  final SupabaseRemoteDataSource? supabaseDataSource;
  final CuratedLocalDataSource localDataSource;
  
  /// Toggle to switch between Google Places API for nearby search
  final bool useApi;
  
  DiscoverRepositoryImpl({
    required this.googlePlacesDataSource,
    this.supabaseDataSource,
    required this.localDataSource,
    this.useApi = true,
  });
  
  @override
  Future<List<DiscoverDestination>> getDestinations({
    required double latitude,
    required double longitude,
    DestinationCategory category = DestinationCategory.all,
    int radius = 50000,
    int limit = 20,
  }) async {
    try {
      print('🔍 Google Places: Searching at $latitude,$longitude');
      
      // Search places using Google Places API
      final places = await googlePlacesDataSource.searchNearby(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        category: category,
      );
      
      // Convert to entities with photo URLs
      final destinations = places.map((place) {
        // Get photo URL if photos exist
        String? photoUrl;
        final photos = place['photos'] as List?;
        if (photos != null && photos.isNotEmpty) {
          final photo = photos[0] as Map<String, dynamic>;
          final photoReference = photo['photo_reference'] as String?;
          if (photoReference != null) {
            photoUrl = googlePlacesDataSource.getPhotoUrl(photoReference, maxWidth: 600);
          }
        }
        
        return DiscoverDestination.fromGooglePlaces(place, photoUrl);
      }).toList();
      
      print('✅ Google Places: Got ${destinations.length} destinations');
      return destinations;
    } catch (e) {
      print('🔴 Google Places Error: $e');
      throw ApiFailure('Failed to load nearby destinations: $e');
    }
  }
  
  @override
  Future<List<DiscoverDestination>> getWorldwideDestinations({
    DestinationCategory? category,
    int limit = 50,
    int offset = 0,
    bool randomize = false,
  }) async {
    // 2-tier fallback: Supabase → Local JSON Cache
    
    // Try Supabase first (if configured)
    if (supabaseDataSource != null) {
      try {
        print('🔍 Fetching from Supabase${randomize ? ' (random)' : ''}...');
        final destinations = await supabaseDataSource!.getAllDestinations(
          category: category,
          limit: limit,
          offset: offset,
          randomize: randomize,
        );
        
        final result = destinations
            .map((json) => DiscoverDestination.fromSupabase(json))
            .toList();
        
        print('✅ Supabase: Got ${result.length} destinations');
        
        // If Supabase returns empty results, fallback to local cache
        if (result.isEmpty) {
          print('⚠️ Supabase returned 0 destinations, falling back to local cache...');
        } else {
          return result;
        }
      } catch (e) {
        print('⚠️ Supabase error: $e, falling back to local cache...');
      }
    } else {
      print('ℹ️ Supabase not configured, using local cache...');
    }
    
    // Fallback to Local JSON Cache
    try {
      print('🔍 Loading from local JSON cache...');
      final destinations = await localDataSource.getAllDestinations(
        category: category,
        limit: limit,
      );
      
      var result = destinations
          .map((json) => DiscoverDestination.fromLocalJson(json))
          .toList();
      
      // Shuffle locally if randomize requested
      if (randomize) {
        result.shuffle();
        result = result.take(limit).toList();
      }
      
      print('✅ Local Cache: Got ${result.length} destinations');
      return result;
    } catch (e) {
      print('🔴 Local cache error: $e');
      throw ApiFailure('Failed to load destinations: $e');
    }
  }
  
  @override
  Future<List<DiscoverDestination>> searchWorldwideDestinations({
    required String query,
    DestinationCategory? category,
    int limit = 20,
  }) async {
    // 2-tier fallback: Supabase → Local JSON Cache
    
    // Try Supabase first (if configured)
    if (supabaseDataSource != null) {
      try {
        print('🔍 Searching in Supabase: "$query"');
        final destinations = await supabaseDataSource!.searchDestinations(
          query: query,
          category: category,
          limit: limit,
        );
        
        final result = destinations
            .map((json) => DiscoverDestination.fromSupabase(json))
            .toList();
        
        print('✅ Supabase Search: Got ${result.length} results');
        
        if (result.isEmpty) {
          print('⚠️ Supabase returned 0 results, trying local cache...');
        } else {
          return result;
        }
      } catch (e) {
        print('⚠️ Supabase search error: $e, trying local cache...');
      }
    }
    
    // Fallback to Local JSON Cache
    try {
      print('🔍 Searching in local JSON: "$query"');
      final destinations = await localDataSource.searchDestinations(
        query: query,
        category: category,
        limit: limit,
      );
      
      final result = destinations
          .map((json) => DiscoverDestination.fromLocalJson(json))
          .toList();
      
      print('✅ Local Search: Got ${result.length} results');
      return result;
    } catch (e) {
      print('🔴 Local search error: $e');
      throw ApiFailure('Failed to search destinations: $e');
    }
  }
  
  @override
  Future<List<DiscoverDestination>> getTopRatedDestinations({
    int limit = 20,
  }) async {
    // 2-tier fallback: Supabase → Local JSON Cache
    
    // Try Supabase first (if configured)
    if (supabaseDataSource != null) {
      try {
        print('🔍 Fetching top rated from Supabase...');
        final destinations = await supabaseDataSource!.getTopRatedDestinations(
          limit: limit,
        );
        
        final result = destinations
            .map((json) => DiscoverDestination.fromSupabase(json))
            .toList();
        
        print('✅ Supabase Top Rated: Got ${result.length} destinations');
        
        if (result.isEmpty) {
          print('⚠️ Supabase returned 0 destinations, trying local cache...');
        } else {
          return result;
        }
      } catch (e) {
        print('⚠️ Supabase error: $e, trying local cache...');
      }
    }
    
    // Fallback to Local JSON Cache
    try {
      print('🔍 Fetching top rated from local JSON...');
      final destinations = await localDataSource.getTopRatedDestinations(
        limit: limit,
      );
      
      final result = destinations
          .map((json) => DiscoverDestination.fromLocalJson(json))
          .toList();
      
      print('✅ Local Top Rated: Got ${result.length} destinations');
      return result;
    } catch (e) {
      print('🔴 Local error: $e');
      throw ApiFailure('Failed to load top rated destinations: $e');
    }
  }
  
  @override
  Future<DiscoverDestination> getDestinationDetails(String id) async {
    // Try Supabase first
    if (supabaseDataSource != null) {
      try {
        print('🔍 Fetching destination details from Supabase...');
        final destination = await supabaseDataSource!.getDestinationById(id);
        final result = DiscoverDestination.fromSupabase(destination);
        print('✅ Supabase: Got destination details');
        return result;
      } catch (e) {
        print('⚠️ Supabase error: $e, trying local cache...');
      }
    }
    
    // Fallback to Local JSON Cache
    try {
      print('🔍 Fetching destination details from local JSON...');
      final destination = await localDataSource.getDestinationById(id);
      final result = DiscoverDestination.fromLocalJson(destination);
      print('✅ Local Cache: Got destination details');
      return result;
    } catch (e) {
      print('🔴 Local error: $e');
      throw ApiFailure('Failed to load destination details: $e');
    }
  }
  
  @override
  Future<List<DiscoverDestination>> searchDestinations({
    required String placeName,
    DestinationCategory category = DestinationCategory.all,
    int limit = 20,
  }) async {
    // Use worldwide search for place name search
    return searchWorldwideDestinations(
      query: placeName,
      category: category == DestinationCategory.all ? null : category,
      limit: limit,
    );
  }
  
  @override
  Future<List<DiscoverDestination>> getRandomDestinations({
    DestinationCategory? category,
    int limit = 20,
  }) async {
    // Use the randomize flag in getWorldwideDestinations
    return getWorldwideDestinations(
      category: category,
      limit: limit,
      randomize: true,
    );
  }
}
