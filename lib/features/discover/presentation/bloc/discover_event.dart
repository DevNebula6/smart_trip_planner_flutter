import 'package:equatable/equatable.dart';
import '../../domain/entities/discover_destination.dart';

/// Events for discover destinations
abstract class DiscoverEvent extends Equatable {
  const DiscoverEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadDestinations extends DiscoverEvent {
  final double latitude;
  final double longitude;
  final DestinationCategory category;
  
  const LoadDestinations({
    required this.latitude,
    required this.longitude,
    this.category = DestinationCategory.all,
  });
  
  @override
  List<Object?> get props => [latitude, longitude, category];
}

class FilterByCategory extends DiscoverEvent {
  final DestinationCategory category;
  
  const FilterByCategory(this.category);
  
  @override
  List<Object?> get props => [category];
}

class LoadDestinationDetails extends DiscoverEvent {
  final String destinationId;
  
  const LoadDestinationDetails(this.destinationId);
  
  @override
  List<Object?> get props => [destinationId];
}

class SearchDestinations extends DiscoverEvent {
  final String query;
  final DestinationCategory category;
  
  const SearchDestinations({
    required this.query,
    this.category = DestinationCategory.all,
  });
  
  @override
  List<Object?> get props => [query, category];
}

/// Load worldwide curated destinations (Supabase + Local Cache)
class LoadWorldwideDestinations extends DiscoverEvent {
  final DestinationCategory? category;
  final int limit;
  final int offset;
  
  const LoadWorldwideDestinations({
    this.category,
    this.limit = 50,
    this.offset = 0,
  });
  
  @override
  List<Object?> get props => [category, limit, offset];
}

/// Search worldwide curated destinations
class SearchWorldwideDestinations extends DiscoverEvent {
  final String query;
  final DestinationCategory? category;
  final int limit;
  
  const SearchWorldwideDestinations({
    required this.query,
    this.category,
    this.limit = 20,
  });
  
  @override
  List<Object?> get props => [query, category, limit];
}

/// Load top rated destinations
class LoadTopRatedDestinations extends DiscoverEvent {
  final int limit;
  
  const LoadTopRatedDestinations({
    this.limit = 20,
  });
  
  @override
  List<Object?> get props => [limit];
}

/// Refresh destinations with new random set
/// Used for pull-to-refresh functionality
class RefreshDestinations extends DiscoverEvent {
  final DestinationCategory? category;
  final int limit;
  
  const RefreshDestinations({
    this.category,
    this.limit = 20,
  });
  
  @override
  List<Object?> get props => [category, limit];
}
