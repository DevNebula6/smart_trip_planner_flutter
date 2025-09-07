import 'dart:async';
import 'package:smart_trip_planner_flutter/ai_agent/models/trip_session_model.dart';
import 'package:smart_trip_planner_flutter/ai_agent/services/gemini_service.dart';
import 'package:smart_trip_planner_flutter/trip_planning_chat/data/models/itinerary_models.dart';


/// * AI Service with Session Persistence**
/// 
/// This implements the core session persistence patterns from your AI Companion:
/// - Session-based conversation continuity using Hive storage
/// - Context management and token optimization
/// - Debounced state saving with better performance
/// - 90-day session persistence with reliable storage

abstract class AIAgentService {
  Future<ItineraryModel> generateItinerary({
    required String userPrompt,
    String? userId,
    String? sessionId,
  });

  Future<ItineraryModel> refineItinerary({
    required String userPrompt,
    required String sessionId,
    String? userId,
  });

  Stream<String> streamItineraryGeneration({
    required String userPrompt,
    String? userId,
    String? sessionId,
  });

  Future<String> getOrCreateSession({
    required String userId,
    String? existingSessionId,
  });

  Future<SessionState?> getSession(String sessionId);
  Future<void> clearSession(String sessionId);
  TokenUsageStats get tokenUsage;
  bool validateItinerarySchema(Map<String, dynamic> json);
  Future<Map<String, dynamic>> getSessionMetrics(String userId);
}
