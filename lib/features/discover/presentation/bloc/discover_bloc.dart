import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/discover_repository.dart';
import '../../domain/entities/discover_destination.dart';
import 'discover_event.dart';
import 'discover_state.dart';

/// Bloc for managing discover destinations
class DiscoverBloc extends Bloc<DiscoverEvent, DiscoverState> {
  final DiscoverRepository repository;
  
  // Cache for loaded destinations
  List<DiscoverDestination> _allDestinations = [];
  
  DiscoverBloc({required this.repository}) : super(DiscoverInitial()) {
    on<LoadDestinations>(_onLoadDestinations);
    on<FilterByCategory>(_onFilterByCategory);
    on<LoadDestinationDetails>(_onLoadDestinationDetails);
    on<SearchDestinations>(_onSearchDestinations);
    on<LoadWorldwideDestinations>(_onLoadWorldwideDestinations);
    on<SearchWorldwideDestinations>(_onSearchWorldwideDestinations);
    on<LoadTopRatedDestinations>(_onLoadTopRatedDestinations);
    on<RefreshDestinations>(_onRefreshDestinations);
  }
  
  Future<void> _onLoadDestinations(
    LoadDestinations event,
    Emitter<DiscoverState> emit,
  ) async {
    emit(DiscoverLoading());
    
    try {
      final destinations = await repository.getDestinations(
        latitude: event.latitude,
        longitude: event.longitude,
        category: event.category,
      );
      
      _allDestinations = destinations;
      
      emit(DiscoverLoaded(
        destinations: destinations,
        selectedCategory: event.category,
      ));
    } catch (e) {
      emit(DiscoverError('Failed to load destinations: $e'));
    }
  }
  
  Future<void> _onFilterByCategory(
    FilterByCategory event,
    Emitter<DiscoverState> emit,
  ) async {
    if (_allDestinations.isEmpty) {
      emit(const DiscoverError('No destinations loaded'));
      return;
    }
    
    emit(DiscoverLoading());
    
    try {
      // If filtering locally (mock data)
      if (event.category == DestinationCategory.all) {
        emit(DiscoverLoaded(
          destinations: _allDestinations,
          selectedCategory: event.category,
        ));
      } else {
        final filtered = _allDestinations
            .where((d) => d.category == event.category)
            .toList();
        
        emit(DiscoverLoaded(
          destinations: filtered,
          selectedCategory: event.category,
        ));
      }
    } catch (e) {
      emit(DiscoverError('Failed to filter destinations: $e'));
    }
  }
  
  Future<void> _onLoadDestinationDetails(
    LoadDestinationDetails event,
    Emitter<DiscoverState> emit,
  ) async {
    emit(DiscoverDetailLoading());
    
    try {
      final destination = await repository.getDestinationDetails(event.destinationId);
      emit(DiscoverDetailLoaded(destination));
    } catch (e) {
      emit(DiscoverError('Failed to load destination details: $e'));
    }
  }
  
  Future<void> _onSearchDestinations(
    SearchDestinations event,
    Emitter<DiscoverState> emit,
  ) async {
    emit(DiscoverLoading());
    
    try {
      final destinations = await repository.searchDestinations(
        placeName: event.query,
        category: event.category,
      );
      
      emit(DiscoverLoaded(
        destinations: destinations,
        selectedCategory: event.category,
      ));
    } catch (e) {
      emit(DiscoverError('Failed to search destinations: $e'));
    }
  }
  
  Future<void> _onLoadWorldwideDestinations(
    LoadWorldwideDestinations event,
    Emitter<DiscoverState> emit,
  ) async {
    emit(DiscoverLoading());
    
    try {
      // Use random destinations for better variety
      final destinations = await repository.getRandomDestinations(
        category: event.category,
        limit: event.limit,
      );
      
      _allDestinations = destinations;
      
      emit(DiscoverLoaded(
        destinations: destinations,
        selectedCategory: event.category ?? DestinationCategory.all,
      ));
    } catch (e) {
      emit(DiscoverError('Failed to load worldwide destinations: $e'));
    }
  }
  
  Future<void> _onRefreshDestinations(
    RefreshDestinations event,
    Emitter<DiscoverState> emit,
  ) async {
    // Don't show loading state for refresh - keep current data visible
    try {
      // Fetch new random destinations
      final destinations = await repository.getRandomDestinations(
        category: event.category,
        limit: event.limit,
      );
      
      _allDestinations = destinations;
      
      emit(DiscoverLoaded(
        destinations: destinations,
        selectedCategory: event.category ?? DestinationCategory.all,
      ));
    } catch (e) {
      emit(DiscoverError('Failed to refresh destinations: $e'));
    }
  }
  
  Future<void> _onSearchWorldwideDestinations(
    SearchWorldwideDestinations event,
    Emitter<DiscoverState> emit,
  ) async {
    emit(DiscoverLoading());
    
    try {
      final destinations = await repository.searchWorldwideDestinations(
        query: event.query,
        category: event.category,
        limit: event.limit,
      );
      
      emit(DiscoverLoaded(
        destinations: destinations,
        selectedCategory: event.category ?? DestinationCategory.all,
      ));
    } catch (e) {
      emit(DiscoverError('Failed to search worldwide destinations: $e'));
    }
  }
  
  Future<void> _onLoadTopRatedDestinations(
    LoadTopRatedDestinations event,
    Emitter<DiscoverState> emit,
  ) async {
    emit(DiscoverLoading());
    
    try {
      final destinations = await repository.getTopRatedDestinations(
        limit: event.limit,
      );
      
      _allDestinations = destinations;
      
      emit(DiscoverLoaded(
        destinations: destinations,
        selectedCategory: DestinationCategory.all,
      ));
    } catch (e) {
      emit(DiscoverError('Failed to load top rated destinations: $e'));
    }
  }
}