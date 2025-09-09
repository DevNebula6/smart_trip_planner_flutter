import 'package:flutter/material.dart';
import 'package:smart_trip_planner_flutter/core/storage/hive_storage_service.dart';
import 'package:smart_trip_planner_flutter/core/storage/hive_models.dart';

/// **Test Data Helper**
/// 
/// Creates sample trip sessions for testing the home page functionality
class TestDataHelper {
  static Future<void> createSampleSessions({String? userId}) async {
    try {
      final storage = HiveStorageService.instance;
      final targetUserId = userId ?? 'anonymous';
      
      // Create sample sessions
      final sessions = [
        _createSampleSession(
          userId: targetUserId,
          destination: 'Tokyo, Japan',
          duration: '5 days',
          style: 'cultural',
          messagesCount: 12,
          refinements: 3,
          daysAgo: 2,
        ),
        _createSampleSession(
          userId: targetUserId,
          destination: 'Bali, Indonesia',
          duration: '7 days',
          style: 'relaxed',
          messagesCount: 8,
          refinements: 1,
          daysAgo: 5,
        ),
        _createSampleSession(
          userId: targetUserId,
          destination: 'Paris, France',
          duration: '4 days',
          style: 'luxury',
          messagesCount: 15,
          refinements: 4,
          daysAgo: 12,
        ),
      ];
      
      for (final session in sessions) {
        await storage.saveSession(session);
      }
      
      debugPrint('✅ Created ${sessions.length} sample sessions for user: $targetUserId');
      
    } catch (e) {
      debugPrint('❌ Error creating sample sessions: $e');
    }
  }
  
  static HiveSessionState _createSampleSession({
    required String userId,
    required String destination,
    required String duration,
    required String style,
    required int messagesCount,
    required int refinements,
    required int daysAgo,
  }) {
    final now = DateTime.now();
    final createdAt = now.subtract(Duration(days: daysAgo));
    final lastUsed = now.subtract(Duration(days: daysAgo, hours: -2));
    
    final sessionId = '${userId}_trip_${createdAt.millisecondsSinceEpoch}';
    
    return HiveSessionState(
      sessionId: sessionId,
      userId: userId,
      createdAt: createdAt,
      lastUsed: lastUsed,
      conversationHistory: [], // Empty for test
      userPreferences: {
        'travel_style': style,
      },
      tripContext: {
        'destination': destination,
        'duration': duration,
        'duration_number': int.tryParse(duration.split(' ')[0]) ?? 1,
        'duration_unit': duration.split(' ')[1],
      },
      messagesInSession: messagesCount,
      refinementCount: refinements,
      tokensSaved: messagesCount * 150,
      estimatedCostSavings: (messagesCount * 0.05) + (refinements * 0.15),
    );
  }
  
  static Future<void> clearAllSessions({String? userId}) async {
    try {
      final storage = HiveStorageService.instance;
      final targetUserId = userId ?? 'anonymous';
      final sessions = await storage.getUserSessions(targetUserId);
      
      for (final session in sessions) {
        await storage.deleteSession(session.sessionId);
      }
      
      debugPrint('🗑️ Cleared ${sessions.length} sessions for user: $targetUserId');
      
    } catch (e) {
      debugPrint('❌ Error clearing sessions: $e');
    }
  }
}
