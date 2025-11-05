import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_trip_planner_flutter/core/storage/hive_models.dart';
import 'package:smart_trip_planner_flutter/core/utils/helpers.dart';
import 'package:smart_trip_planner_flutter/core/constants/app_constants.dart';
import 'dart:async';

/// **Hive Storage Service**
/// 
/// Centralized storage service using Hive for persistent local storage


class HiveStorageService {
  // Thread-safe singleton using late final
  static late final HiveStorageService instance = HiveStorageService._();
  static const int _maxRetries = AppConstants.storageMaxRetries;
  
  // Box names
  static const String _sessionsBoxName = 'sessions';
  static const String _itinerariesBoxName = 'itineraries';
  static const String _messagesBoxName = 'messages';
  static const String _metadataBoxName = 'metadata';

  // Lazy-loaded boxes
  Box<HiveSessionState>? _sessionsBox;
  Box<HiveItineraryModel>? _itinerariesBox;
  Box<HiveChatMessageModel>? _messagesBox;
  Box<Map>? _metadataBox;

  bool _isInitialized = false;

  // Private constructor for singleton pattern
  HiveStorageService._();

  /// Initialize Hive and register adapters
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      Logger.d('Initializing Hive storage', tag: 'HiveStorage');
      
      // Initialize Hive Flutter
      await Hive.initFlutter();

      // Register all type adapters
      _registerAdapters();

      Logger.d('Hive storage initialized successfully', tag: 'HiveStorage');
      _isInitialized = true;
      
    } catch (e) {
      Logger.e('Failed to initialize Hive: $e', tag: 'HiveStorage');
      throw HiveStorageException('Failed to initialize storage: $e');
    }
  }

  /// Register all Hive type adapters
  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(HiveItineraryModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(HiveDayPlanModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(HiveActivityItemModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(HiveChatMessageModelAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(HiveSessionStateAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(HiveContentModelAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(HivePartModelAdapter());
    }
  }

  /// Get sessions box (lazy loaded)
  Future<Box<HiveSessionState>> _getSessionsBox() async {
    if (_sessionsBox == null || !_sessionsBox!.isOpen) {
      _sessionsBox = await _openBoxWithRetry<HiveSessionState>(_sessionsBoxName);
    }
    return _sessionsBox!;
  }

  /// Get itineraries box (lazy loaded)
  Future<Box<HiveItineraryModel>> _getItinerariesBox() async {
    if (_itinerariesBox == null || !_itinerariesBox!.isOpen) {
      _itinerariesBox = await _openBoxWithRetry<HiveItineraryModel>(_itinerariesBoxName);
    }
    return _itinerariesBox!;
  }

  /// Get messages box (lazy loaded)
  Future<Box<HiveChatMessageModel>> _getMessagesBox() async {
    if (_messagesBox == null || !_messagesBox!.isOpen) {
      _messagesBox = await _openBoxWithRetry<HiveChatMessageModel>(_messagesBoxName);
    }
    return _messagesBox!;
  }

  /// Get metadata box (lazy loaded)
  Future<Box<Map>> _getMetadataBox() async {
    if (_metadataBox == null || !_metadataBox!.isOpen) {
      _metadataBox = await _openBoxWithRetry<Map>(_metadataBoxName);
    }
    return _metadataBox!;
  }

  /// Open box with retry logic for reliability
  Future<Box<T>> _openBoxWithRetry<T>(String boxName) async {
    Exception? lastException;
    
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        Logger.d('Opening box: $boxName (attempt $attempt)', tag: 'HiveStorage');
        return await Hive.openBox<T>(boxName);
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        Logger.w('Failed to open box $boxName (attempt $attempt): $e', tag: 'HiveStorage');
        
        if (attempt < _maxRetries) {
          await Future.delayed(Duration(milliseconds: attempt * 100));
        }
      }
    }
    
    throw HiveStorageException('Failed to open box $boxName after $_maxRetries attempts: $lastException');
  }

  // ===== SESSION OPERATIONS =====

  /// Save session state
  Future<void> saveSession(HiveSessionState session) async {
    try {
      final box = await _getSessionsBox();
      
      // Debug logging to see what we're saving
      Logger.d('Saving session ${session.sessionId} with tripContext: ${session.tripContext}', tag: 'HiveStorage');
      Logger.d('Session tripContext keys before save: ${session.tripContext.keys}', tag: 'HiveStorage');
      
      await box.put(session.sessionId, session);
      
      // Verify what was actually saved
      final savedSession = box.get(session.sessionId);
      Logger.d('Verified saved session tripContext keys: ${savedSession?.tripContext.keys}', tag: 'HiveStorage');
      Logger.d('Verified saved tripContext: ${savedSession?.tripContext}', tag: 'HiveStorage');
      
      Logger.d('Saved session: ${session.sessionId}', tag: 'HiveStorage');
    } catch (e) {
      Logger.e('Failed to save session: $e', tag: 'HiveStorage');
      throw HiveStorageException('Failed to save session: $e');
    }
  }

  /// Get session by ID
  Future<HiveSessionState?> getSession(String sessionId) async {
    try {
      final box = await _getSessionsBox();
      return box.get(sessionId);
    } catch (e) {
      Logger.e('Failed to get session: $e', tag: 'HiveStorage');
      return null;
    }
  }

  /// Get all sessions for a user
  Future<List<HiveSessionState>> getUserSessions(String userId) async {
    try {
      final box = await _getSessionsBox();
      final sessions = box.values.where((session) => 
          session.userId == userId && session.isValid).toList();
          
      Logger.d('Loading ${sessions.length} sessions for user: $userId', tag: 'HiveStorage');
      
      for (final session in sessions) {
        Logger.d('Loaded session ${session.sessionId} with tripContext keys: ${session.tripContext.keys}', tag: 'HiveStorage');
        Logger.d('Session tripContext content: ${session.tripContext}', tag: 'HiveStorage');
      }
      
      return sessions;
    } catch (e) {
      Logger.e('Failed to get user sessions: $e', tag: 'HiveStorage');
      return [];
    }
  }

  /// Delete session
  Future<void> deleteSession(String sessionId) async {
    try {
      final box = await _getSessionsBox();
      await box.delete(sessionId);
      Logger.d('Deleted session: $sessionId', tag: 'HiveStorage');
    } catch (e) {
      Logger.e('Failed to delete session: $e', tag: 'HiveStorage');
    }
  }

  /// Clean up expired sessions
  Future<int> cleanupExpiredSessions() async {
    try {
      final box = await _getSessionsBox();
      final expiredKeys = <String>[];
      
      for (final entry in box.toMap().entries) {
        if (!entry.value.isValid) {
          expiredKeys.add(entry.key);
        }
      }
      
      for (final key in expiredKeys) {
        await box.delete(key);
      }
      
      Logger.d('Cleaned up ${expiredKeys.length} expired sessions', tag: 'HiveStorage');
      return expiredKeys.length;
    } catch (e) {
      Logger.e('Failed to cleanup sessions: $e', tag: 'HiveStorage');
      return 0;
    }
  }

  // ===== ITINERARY OPERATIONS =====

  /// Save itinerary
  Future<void> saveItinerary(HiveItineraryModel itinerary) async {
    try {
      final box = await _getItinerariesBox();
      itinerary.updatedAt = DateTime.now();
      await box.put(itinerary.id, itinerary);
      Logger.d('Saved itinerary: ${itinerary.id}', tag: 'HiveStorage');
    } catch (e) {
      Logger.e('Failed to save itinerary: $e', tag: 'HiveStorage');
      throw HiveStorageException('Failed to save itinerary: $e');
    }
  }

  /// Get itinerary by ID
  Future<HiveItineraryModel?> getItinerary(String id) async {
    try {
      final box = await _getItinerariesBox();
      return box.get(id);
    } catch (e) {
      Logger.e('Failed to get itinerary: $e', tag: 'HiveStorage');
      return null;
    }
  }

  /// Get all itineraries
  Future<List<HiveItineraryModel>> getAllItineraries() async {
    try {
      final box = await _getItinerariesBox();
      return box.values.toList()
        ..sort((a, b) => (b.updatedAt ?? b.createdAt ?? DateTime(0))
            .compareTo(a.updatedAt ?? a.createdAt ?? DateTime(0)));
    } catch (e) {
      Logger.e('Failed to get all itineraries: $e', tag: 'HiveStorage');
      return [];
    }
  }

  /// Delete itinerary
  Future<void> deleteItinerary(String id) async {
    try {
      final box = await _getItinerariesBox();
      await box.delete(id);
      
      // Also delete related chat messages (deprecated - now using sessions)
      // await deleteMessagesForSession(sessionId);
      
      Logger.d('Deleted itinerary: $id', tag: 'HiveStorage');
    } catch (e) {
      Logger.e('Failed to delete itinerary: $e', tag: 'HiveStorage');
    }
  }

  // ===== CHAT MESSAGE OPERATIONS =====

  /// Save chat message
  Future<void> saveMessage(HiveChatMessageModel message) async {
    try {
      final box = await _getMessagesBox();
      await box.put(message.id, message);
    } catch (e) {
      Logger.e('Failed to save message: $e', tag: 'HiveStorage');
      throw HiveStorageException('Failed to save message: $e');
    }
  }

  /// Get messages for session
  Future<List<HiveChatMessageModel>> getMessagesForSession(String sessionId) async {
    try {
      final box = await _getMessagesBox();
      return box.values
          .where((message) => message.sessionId == sessionId)
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    } catch (e) {
      Logger.e('Failed to get messages: $e', tag: 'HiveStorage');
      return [];
    }
  }

  /// Delete messages for session
  Future<void> deleteMessagesForSession(String sessionId) async {
    try {
      final box = await _getMessagesBox();
      final messagesToDelete = <String>[];
      
      for (final entry in box.toMap().entries) {
        if (entry.value.sessionId == sessionId) {
          messagesToDelete.add(entry.key);
        }
      }
      
      for (final key in messagesToDelete) {
        await box.delete(key);
      }
    } catch (e) {
      Logger.e('Failed to delete messages: $e', tag: 'HiveStorage');
    }
  }

  // ===== METADATA OPERATIONS =====

  /// Save metadata
  Future<void> saveMetadata(String key, Map<String, dynamic> data) async {
    try {
      final box = await _getMetadataBox();
      await box.put(key, data);
    } catch (e) {
      Logger.e('Failed to save metadata: $e', tag: 'HiveStorage');
    }
  }

  /// Get metadata
  Future<Map<String, dynamic>?> getMetadata(String key) async {
    try {
      final box = await _getMetadataBox();
      final data = box.get(key);
      return data?.cast<String, dynamic>();
    } catch (e) {
      Logger.e('Failed to get metadata: $e', tag: 'HiveStorage');
      return null;
    }
  }

  // ===== UTILITY OPERATIONS =====

  /// Get storage statistics
  Future<Map<String, dynamic>> getStorageStats() async {
    try {
      final sessionsBox = await _getSessionsBox();
      final itinerariesBox = await _getItinerariesBox();
      final messagesBox = await _getMessagesBox();
      
      return {
        'sessions_count': sessionsBox.length,
        'itineraries_count': itinerariesBox.length,
        'messages_count': messagesBox.length,
        'last_cleanup': await getMetadata('last_cleanup'),
      };
    } catch (e) {
      Logger.e('Failed to get storage stats: $e', tag: 'HiveStorage');
      return {};
    }
  }

  /// Compact all boxes for better performance
  Future<void> compactStorage() async {
    try {
      Logger.d('Compacting storage...', tag: 'HiveStorage');
      
      if (_sessionsBox?.isOpen == true) await _sessionsBox!.compact();
      if (_itinerariesBox?.isOpen == true) await _itinerariesBox!.compact();
      if (_messagesBox?.isOpen == true) await _messagesBox!.compact();
      if (_metadataBox?.isOpen == true) await _metadataBox!.compact();
      
      Logger.d('Storage compaction completed', tag: 'HiveStorage');
    } catch (e) {
      Logger.e('Failed to compact storage: $e', tag: 'HiveStorage');
    }
  }

  /// Close all boxes (call on app termination)
  Future<void> close() async {
    try {
      await _sessionsBox?.close();
      await _itinerariesBox?.close();
      await _messagesBox?.close();
      await _metadataBox?.close();
      
      _sessionsBox = null;
      _itinerariesBox = null;
      _messagesBox = null;
      _metadataBox = null;
      
      Logger.d('All Hive boxes closed', tag: 'HiveStorage');
    } catch (e) {
      Logger.e('Failed to close Hive boxes: $e', tag: 'HiveStorage');
    }
  }

  /// Migrate data from SharedPreferences
  Future<void> migrateFromSharedPreferences() async {
    try {
      Logger.d('Starting migration from SharedPreferences', tag: 'HiveStorage');
      
      // This would contain migration logic from SharedPreferences
      // For now, we'll skip this since the session implementation is new
      
      await saveMetadata('migration_completed', {
        'timestamp': DateTime.now().toIso8601String(),
        'version': '1.0',
      });
      
      Logger.d('Migration completed successfully', tag: 'HiveStorage');
    } catch (e) {
      Logger.e('Migration failed: $e', tag: 'HiveStorage');
      throw HiveStorageException('Migration failed: $e');
    }
  }
}

/// Custom exception for storage operations
class HiveStorageException implements Exception {
  final String message;
  HiveStorageException(this.message);
  
  @override
  String toString() => 'HiveStorageException: $message';
}

/// Migration utility for moving from SharedPreferences to Hive
class StorageMigrator {
  static Future<void> migrateSessionData() async {
    try {
      Logger.d('Migrating session data to Hive', tag: 'Migration');
      
      // Add migration logic here if needed
      // For now, fresh start is acceptable since sessions expire in 90 days
      
      Logger.d('Session data migration completed', tag: 'Migration');
    } catch (e) {
      Logger.e('Session data migration failed: $e', tag: 'Migration');
      throw Exception('Migration failed: $e');
    }
  }
}
