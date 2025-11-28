import '../entities/discover_destination.dart';

/// Repository interface for discover destinations
abstract class DiscoverRepository {
  /// Get destinations by category and location (Nearby - Google Places)
  Future<List<DiscoverDestination>> getDestinations({
    required double latitude,
    required double longitude,
    DestinationCategory category = DestinationCategory.all,
    int radius = 50000,
    int limit = 20,
  });
  
  /// Get worldwide curated destinations (Supabase + Local Cache + Mock)
  Future<List<DiscoverDestination>> getWorldwideDestinations({
    DestinationCategory? category,
    int limit = 50,
    int offset = 0,
  });
  
  /// Get detailed information about a destination
  Future<DiscoverDestination> getDestinationDetails(String id);
  
  /// Search destinations by place name (for nearby)
  Future<List<DiscoverDestination>> searchDestinations({
    required String placeName,
    DestinationCategory category = DestinationCategory.all,
    int limit = 20,
  });
  
  /// Search worldwide curated destinations
  Future<List<DiscoverDestination>> searchWorldwideDestinations({
    required String query,
    DestinationCategory? category,
    int limit = 20,
  });
  
  /// Get top rated destinations
  Future<List<DiscoverDestination>> getTopRatedDestinations({
    int limit = 20,
  });
  
  /// Get random destinations from the entire database
  /// Used for discover section to show variety each time
  Future<List<DiscoverDestination>> getRandomDestinations({
    DestinationCategory? category,
    int limit = 20,
  });
}
