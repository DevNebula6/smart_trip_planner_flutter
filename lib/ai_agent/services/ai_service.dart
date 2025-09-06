import 'package:smart_trip_planner_flutter/ai_agent/models/trip_session_model.dart';
import 'package:smart_trip_planner_flutter/core/utils/helpers.dart';
import 'dart:async';
import '../../trip_planning/data/models/itinerary_models.dart';


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

  Future<TripPlanningSession?> getSession(String sessionId);
  Future<void> clearSession(String sessionId);
  TokenUsageStats get tokenUsage;
  bool validateItinerarySchema(Map<String, dynamic> json);
  Future<Map<String, dynamic>> getSessionMetrics(String userId);
  Future<void> dispose();
}

/// **Enhanced Token Usage Stats**
class TokenUsageStats {
  int _totalPromptTokens = 0;
  int _totalCompletionTokens = 0;
  int _requestCount = 0;
  int _tokensSaved = 0;

  void addUsage({
    required int promptTokens, 
    required int completionTokens,
    int tokensSaved = 0,
  }) {
    _totalPromptTokens += promptTokens;
    _totalCompletionTokens += completionTokens;
    _tokensSaved += tokensSaved;
    _requestCount++;
    Logger.d('Token usage: +$promptTokens prompt, +$completionTokens completion, +$tokensSaved saved', tag: 'TokenUsage');
  }

  int get totalTokens => _totalPromptTokens + _totalCompletionTokens;
  int get promptTokens => _totalPromptTokens;
  int get completionTokens => _totalCompletionTokens;
  int get requestCount => _requestCount;
  int get tokensSaved => _tokensSaved;
  
  double get estimatedCostUSD {
    const costPer1kTokens = 0.03;
    return (totalTokens / 1000 * costPer1kTokens);
  }

  double get estimatedSavingsUSD {
    const costPer1kTokens = 0.03;
    return (_tokensSaved / 1000 * costPer1kTokens);
  }

  double get optimizationPercentage {
    final totalWithSavings = totalTokens + _tokensSaved;
    if (totalWithSavings == 0) return 0.0;
    return (_tokensSaved / totalWithSavings) * 100;
  }

  void reset() {
    _totalPromptTokens = 0;
    _totalCompletionTokens = 0;
    _requestCount = 0;
    _tokensSaved = 0;
    Logger.d('Token usage stats reset', tag: 'TokenUsage');
  }

  @override
  String toString() {
    return 'TokenUsage(requests: $_requestCount, total: $totalTokens, saved: $_tokensSaved, optimization: ${optimizationPercentage.toStringAsFixed(1)}%, cost: \$${estimatedCostUSD.toStringAsFixed(4)})';
  }
}
