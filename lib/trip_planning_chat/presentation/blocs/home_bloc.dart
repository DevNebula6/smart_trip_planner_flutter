import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_trip_planner_flutter/ai_agent/services/ai_agent_service.dart';
import 'package:smart_trip_planner_flutter/core/storage/hive_storage_service.dart';
import 'package:smart_trip_planner_flutter/core/storage/hive_models.dart';
import '../../../ai_agent/models/trip_session_model.dart';
import '../../../core/utils/helpers.dart';

// Events
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadSavedTrips extends HomeEvent {
  final String userId;
  
  const LoadSavedTrips({required this.userId});
  
  @override
  List<Object?> get props => [userId];
}

class RefreshTrips extends HomeEvent {
  final String userId;
  
  const RefreshTrips({required this.userId});
  
  @override
  List<Object?> get props => [userId];
}

class DeleteTrip extends HomeEvent {
  final String sessionId;
  
  const DeleteTrip({required this.sessionId});
  
  @override
  List<Object?> get props => [sessionId];
}

// States
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<SessionState> savedTrips;
  
  const HomeLoaded({required this.savedTrips});
  
  @override
  List<Object> get props => [savedTrips];
}

class HomeError extends HomeState {
  final String message;
  
  const HomeError({required this.message});
  
  @override
  List<Object?> get props => [message];
}

class TripDeleted extends HomeState {
  final String message;
  
  const TripDeleted({required this.message});
  
  @override
  List<Object?> get props => [message];
}

// Bloc
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AIAgentService _aiService;

  HomeBloc({required AIAgentService aiService})
      : _aiService = aiService,
        super(HomeInitial()) {
    
    on<LoadSavedTrips>(_onLoadSavedTrips);
    on<RefreshTrips>(_onRefreshTrips);
    on<DeleteTrip>(_onDeleteTrip);
  }

  Future<void> _onLoadSavedTrips(LoadSavedTrips event, Emitter<HomeState> emit) async {
    try {
      emit(HomeLoading());
      
      Logger.d('Loading saved trips for user: ${event.userId}', tag: 'HomeBloc');
      
      // Get saved sessions from the AI service
      final sessions = await _getSavedSessions(event.userId);
      
      Logger.d('Found ${sessions.length} saved trips', tag: 'HomeBloc');
      
      emit(HomeLoaded(savedTrips: sessions));
    } catch (error) {
      Logger.e('Error loading saved trips: $error', tag: 'HomeBloc');
      emit(HomeError(message: 'Failed to load saved trips: $error'));
    }
  }

  Future<void> _onRefreshTrips(RefreshTrips event, Emitter<HomeState> emit) async {
    try {
      Logger.d('Refreshing trips for user: ${event.userId}', tag: 'HomeBloc');
      
      final sessions = await _getSavedSessions(event.userId);
      
      emit(HomeLoaded(savedTrips: sessions));
      
      Logger.d('Trips refreshed successfully', tag: 'HomeBloc');
    } catch (error) {
      Logger.e('Error refreshing trips: $error', tag: 'HomeBloc');
      emit(HomeError(message: 'Failed to refresh trips: $error'));
    }
  }

  Future<void> _onDeleteTrip(DeleteTrip event, Emitter<HomeState> emit) async {
    try {
      Logger.d('Deleting trip with session ID: ${event.sessionId}', tag: 'HomeBloc');
      
      final hiveStorage = HiveStorageService.instance;
      
      // Delete associated itineraries efficiently using sessionId reference
      final allItineraries = await hiveStorage.getAllItineraries();
      
      // Filter itineraries by sessionId for O(n) efficiency instead of complex matching
      final sessionItineraries = allItineraries.where((itinerary) {
        return itinerary.sessionId == event.sessionId;
      }).toList();
      
      // Delete all matching itineraries
      for (final itinerary in sessionItineraries) {
        Logger.d('Deleting associated itinerary: ${itinerary.id} (${itinerary.title})', tag: 'HomeBloc');
        await hiveStorage.deleteItinerary(itinerary.id);
      }
      
      // Delete from both AI service and Hive storage for completeness
      await _aiService.clearSession(event.sessionId);
      
      // Also delete the session directly from Hive storage
      await hiveStorage.deleteSession(event.sessionId);
      
      // If currently showing loaded trips, update the list
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        final updatedTrips = currentState.savedTrips
            .where((trip) => trip.sessionId != event.sessionId)
            .toList();
        
        emit(HomeLoaded(savedTrips: updatedTrips));
        Logger.d('Trip deleted and UI updated', tag: 'HomeBloc');
      } else {
        emit(const TripDeleted(message: 'Trip deleted successfully'));
      }
      
      Logger.d('Trip deleted successfully', tag: 'HomeBloc');
    } catch (error) {
      Logger.e('Error deleting trip: $error', tag: 'HomeBloc');
      emit(HomeError(message: 'Failed to delete trip: $error'));
    }
  }

  Future<List<SessionState>> _getSavedSessions(String userId) async {
    try {
      Logger.d('Getting saved sessions for user: $userId', tag: 'HomeBloc');
      
      // Get Hive sessions directly from storage
      final hiveStorage = HiveStorageService.instance;
      final hiveSessions = await hiveStorage.getUserSessions(userId);
      
      Logger.d('Found ${hiveSessions.length} Hive sessions', tag: 'HomeBloc');
      
      // Convert HiveSessionState to SessionState for UI
      final sessionStates = hiveSessions.map((hiveSession) => 
        _convertHiveSessionToSessionState(hiveSession)
      ).toList();
      
      // Sort by last used (most recent first)
      sessionStates.sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
      
      Logger.d('Converted to ${sessionStates.length} SessionState objects', tag: 'HomeBloc');
      
      return sessionStates;
    } catch (error) {
      Logger.e('Error getting saved sessions: $error', tag: 'HomeBloc');
      return [];
    }
  }
  
  /// Convert HiveSessionState to SessionState for UI compatibility
  SessionState _convertHiveSessionToSessionState(HiveSessionState hiveSession) {
    Logger.d('Converting Hive session: ${hiveSession.sessionId}', tag: 'HomeBloc');
    Logger.d('Hive session tripContext keys: ${hiveSession.tripContext.keys}', tag: 'HomeBloc');
    
    if (hiveSession.tripContext.containsKey('itinerary_title')) {
      Logger.d('Found itinerary_title in Hive session: ${hiveSession.tripContext['itinerary_title']}', tag: 'HomeBloc');
    } else {
      Logger.w('No itinerary_title found in Hive session tripContext', tag: 'HomeBloc');
    }
    
    final sessionState = SessionState(
      sessionId: hiveSession.sessionId,
      userId: hiveSession.userId,
      createdAt: hiveSession.createdAt,
      lastUsed: hiveSession.lastUsed,
      conversationHistory: hiveSession.conversationHistory
          .map((hiveContent) => hiveContent.toContent())
          .toList(),
      userPreferences: Map<String, dynamic>.from(hiveSession.userPreferences),
      tripContext: Map<String, dynamic>.from(hiveSession.tripContext),
      tokensSaved: hiveSession.tokensSaved,
      messagesInSession: hiveSession.messagesInSession,
      estimatedCostSavings: hiveSession.estimatedCostSavings,
      refinementCount: hiveSession.refinementCount,
      isActive: hiveSession.isActive,
    );
    
    Logger.d('Converted SessionState tripContext keys: ${sessionState.tripContext.keys}', tag: 'HomeBloc');
    
    return sessionState;
  }
}
