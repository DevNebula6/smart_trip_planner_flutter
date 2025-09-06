import 'package:isar/isar.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';

part 'trip_session_model.g.dart';

/// **Trip Planning Session Model
/// 
/// Handles persistent session state for trip planning conversations
/// Enables "refine my trip", "make day 2 more relaxed" type interactions
/// 
/// Key Features from AI Companion Integration:
/// - Smart context management
/// - Token optimization through session reuse
/// - Conversation continuity across app restarts

@Collection()
class TripPlanningSession {
  Id isarId = Isar.autoIncrement;
  
  /// Unique session identifier: "${userId}_trip_${timestamp}"
  @Index(unique: true)
  late String sessionId;
  
  /// User identifier (can be "anonymous" for guest users)
  @Index()
  late String userId;
  
  /// Session timestamps
  late DateTime createdAt;
  DateTime? lastUsed;
  DateTime? lastReset; // For session cleanup validation
  
  /// **Trip-Specific Context** (JSON serialized)
  late String conversationHistoryJson;  // List<Content> from Gemini
  late String userPreferencesJson;      // Budget, style, interests extracted from conversation
  late String tripContextJson;          // Current trip being planned (destination, dates, etc.)
  late String refinementPatternsJson;   // Patterns for understanding refinements
  
  /// **Session Optimization Metrics** (inspired by AI Companion)
  int tokensSaved = 0;              // Tokens saved vs creating new session each time
  int messagesInSession = 0;        // Track session size for cleanup
  double estimatedCostSavings = 0.0; // USD saved through session reuse
  int refinementCount = 0;          // Number of trip refinements made
  
  /// **Session Status**
  bool isActive = true;
  String? lastError;               // Track any session errors for debugging
  
  /// **Version Tracking** (for future migration compatibility)
  String version = '1.0';
  
  
  /// Parse conversation history from JSON
  @ignore
  List<Content> get conversationHistory {
    try {
      final jsonList = jsonDecode(conversationHistoryJson) as List;
      return jsonList.map((json) => _contentFromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
  
  /// Set conversation history and serialize to JSON
  set conversationHistory(List<Content> history) {
    conversationHistoryJson = jsonEncode(
      history.map((content) => _contentToJson(content)).toList()
    );
  }
  
  /// Parse user preferences from JSON
  @ignore
  Map<String, dynamic> get userPreferences {
    try {
      return jsonDecode(userPreferencesJson) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }
  
  /// Set user preferences and serialize to JSON
  set userPreferences(Map<String, dynamic> preferences) {
    userPreferencesJson = jsonEncode(preferences);
  }
  
  /// Parse trip context from JSON
  @ignore
  Map<String, dynamic> get tripContext {
    try {
      return jsonDecode(tripContextJson) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }
  
  /// Set trip context and serialize to JSON
  set tripContext(Map<String, dynamic> context) {
    tripContextJson = jsonEncode(context);
  }
  
  /// Parse refinement patterns from JSON
  @ignore
  Map<String, dynamic> get refinementPatterns {
    try {
      return jsonDecode(refinementPatternsJson) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }
  
  /// Set refinement patterns and serialize to JSON
  set refinementPatterns(Map<String, dynamic> patterns) {
    refinementPatternsJson = jsonEncode(patterns);
  }
  
  /// Check if session is still valid (within 90-day limit from AI Companion)
  bool get isValid {
    if (!isActive) return false;
    
    final now = DateTime.now();
    final maxAge = const Duration(days: 90); // Following AI Companion pattern
    
    return now.difference(createdAt) < maxAge;
  }
  
  /// Check if session needs cleanup (following AI Companion LRU pattern)
  bool get needsCleanup {
    if (!isValid) return true;
    
    // Clean up sessions with too many messages (following AI Companion limit)
    const maxMessages = 200;
    return messagesInSession > maxMessages;
  }
  
  /// Get session age in hours for debugging
  double get sessionAgeHours {
    return DateTime.now().difference(createdAt).inHours.toDouble();
  }
  
  /// Calculate token efficiency (tokens saved vs total tokens used)
  double get tokenEfficiency {
    if (messagesInSession == 0) return 0.0;
    final totalTokensUsed = messagesInSession * 100; // Rough estimation
    return tokensSaved / (tokensSaved + totalTokensUsed) * 100;
  }
  
  
  /// Create new trip planning session
  static TripPlanningSession create({
    required String userId,
    String? tripId,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sessionId = tripId != null 
        ? '${userId}_trip_${tripId}_$timestamp'
        : '${userId}_trip_$timestamp';
    
    return TripPlanningSession()
      ..sessionId = sessionId
      ..userId = userId
      ..createdAt = DateTime.now()
      ..lastUsed = DateTime.now()
      ..conversationHistoryJson = jsonEncode([])
      ..userPreferencesJson = jsonEncode({})
      ..tripContextJson = jsonEncode({})
      ..refinementPatternsJson = jsonEncode({});
  }
  
  /// Create session from existing trip context
  static TripPlanningSession fromTripContext({
    required String userId,
    required Map<String, dynamic> tripContext,
    required Map<String, dynamic> userPreferences,
  }) {
    final session = create(userId: userId);
    session.tripContext = tripContext;
    session.userPreferences = userPreferences;
    return session;
  }
  
  // === Session Management Methods ===
  
  /// Update session with new conversation content
  void updateConversation({
    required Content userMessage,
    required Content aiResponse,
    int? tokensUsed,
    int? tokensSavedFromReuse,
  }) {
    // Add to conversation history
    final history = conversationHistory;
    history.add(userMessage);
    history.add(aiResponse);
    
    // Trim if getting too long (following AI Companion pattern)
    const maxHistoryLength = 50;
    if (history.length > maxHistoryLength) {
      // Keep system messages and trim conversation history
      final systemMessages = history.where((c) => c.role == 'system').toList();
      final conversationMessages = history.where((c) => c.role != 'system').toList();
      
      if (conversationMessages.length > maxHistoryLength - systemMessages.length) {
        final keepCount = maxHistoryLength - systemMessages.length;
        final recentMessages = conversationMessages.skip(conversationMessages.length - keepCount).toList();
        
        conversationHistory = [...systemMessages, ...recentMessages];
      }
    } else {
      conversationHistory = history;
    }
    
    // Update metrics
    messagesInSession += 2; // User + AI messages
    lastUsed = DateTime.now();
    
    if (tokensUsed != null && tokensUsed > 0) {
      // Estimate cost savings (based on AI Companion pricing)
      const costPer1kTokens = 0.03; // Approximate Gemini pricing
      final costForThisRequest = tokensUsed / 1000 * costPer1kTokens;
      estimatedCostSavings += costForThisRequest;
    }
    
    if (tokensSavedFromReuse != null) {
      tokensSaved += tokensSavedFromReuse;
    }
  }
  
  /// Extract user preferences from conversation (AI Companion pattern)
  void extractUserPreferences(String userMessage, String aiResponse) {
    final preferences = userPreferences;
    final lowerMessage = userMessage.toLowerCase();
    
    // Extract budget preferences
    if (lowerMessage.contains(RegExp(r'\$\d+|\d+\s*dollar|budget|cheap|expensive|luxury'))) {
      if (lowerMessage.contains(RegExp(r'budget|cheap|affordable'))) {
        preferences['budget_style'] = 'budget';
      } else if (lowerMessage.contains(RegExp(r'luxury|expensive|premium'))) {
        preferences['budget_style'] = 'luxury';
      }
    }
    
    // Extract travel style preferences
    if (lowerMessage.contains(RegExp(r'adventure|hiking|outdoor|active'))) {
      preferences['travel_style'] = 'adventure';
    } else if (lowerMessage.contains(RegExp(r'relax|peaceful|calm|quiet'))) {
      preferences['travel_style'] = 'relaxed';
    } else if (lowerMessage.contains(RegExp(r'culture|museum|history|art'))) {
      preferences['travel_style'] = 'cultural';
    }
    
    // Extract dietary preferences
    if (lowerMessage.contains(RegExp(r'vegetarian|vegan|gluten.free|halal|kosher'))) {
      final match = RegExp(r'(vegetarian|vegan|gluten.free|halal|kosher)').firstMatch(lowerMessage);
      if (match != null) {
        preferences['dietary_restrictions'] = match.group(1);
      }
    }
    
    // Extract group size
    final groupMatch = RegExp(r'(\d+)\s*(people|person|group|traveler)').firstMatch(lowerMessage);
    if (groupMatch != null) {
      preferences['group_size'] = int.parse(groupMatch.group(1)!);
    }
    
    userPreferences = preferences;
  }
  
  /// Extract trip context from initial request
  void extractTripContext(String userMessage) {
    final context = tripContext;
    final lowerMessage = userMessage.toLowerCase();
    
    // Extract destination
    // This would be enhanced with NER or location detection
    if (lowerMessage.contains('to ') || lowerMessage.contains('visit ')) {
      final destinationMatch = RegExp(r'(?:to|visit)\s+([a-zA-Z\s]+?)(?:\s|$|,)').firstMatch(lowerMessage);
      if (destinationMatch != null) {
        context['destination'] = destinationMatch.group(1)?.trim();
      }
    }
    
    // Extract duration
    final durationMatch = RegExp(r'(\d+)\s*(day|week|month)').firstMatch(lowerMessage);
    if (durationMatch != null) {
      final number = int.parse(durationMatch.group(1)!);
      final unit = durationMatch.group(2)!;
      context['duration_number'] = number;
      context['duration_unit'] = unit;
    }
    
    // Extract dates if mentioned
    final dateMatch = RegExp(r'(january|february|march|april|may|june|july|august|september|october|november|december)', 
        caseSensitive: false).firstMatch(lowerMessage);
    if (dateMatch != null) {
      context['mentioned_month'] = dateMatch.group(1);
    }
    
    tripContext = context;
  }
  
  /// Build context for AI refinement requests
  String buildRefinementContext() {
    final buffer = StringBuffer();
    
    // Add user preferences context
    final prefs = userPreferences;
    if (prefs.isNotEmpty) {
      buffer.writeln('User Preferences:');
      prefs.forEach((key, value) {
        buffer.writeln('- $key: $value');
      });
      buffer.writeln();
    }
    
    // Add trip context
    final context = tripContext;
    if (context.isNotEmpty) {
      buffer.writeln('Trip Context:');
      context.forEach((key, value) {
        buffer.writeln('- $key: $value');
      });
      buffer.writeln();
    }
    
    // Add refinement history for pattern recognition
    if (refinementCount > 0) {
      buffer.writeln('Previous Refinements: $refinementCount');
      buffer.writeln('This user tends to refine their trips, maintain consistency with previous adjustments.');
      buffer.writeln();
    }
    
    return buffer.toString();
  }
  
  /// Mark session as needing refinement (increment counter)
  void markRefinement() {
    refinementCount++;
    lastUsed = DateTime.now();
  }
  
  /// Reset session for new trip (keeping user preferences)
  void resetForNewTrip({bool keepPreferences = true}) {
    final oldPreferences = keepPreferences ? userPreferences : <String, dynamic>{};
    
    conversationHistory = [];
    tripContext = {};
    refinementPatterns = {};
    refinementCount = 0;
    messagesInSession = 0;
    tokensSaved = 0;
    estimatedCostSavings = 0.0;
    lastReset = DateTime.now();
    lastUsed = DateTime.now();
    
    if (keepPreferences) {
      userPreferences = oldPreferences;
    } else {
      userPreferences = {};
    }
  }
  
  // === Helper Methods for Content Serialization ===
  
  /// Convert Content to JSON (simplified for basic text content)
  Map<String, dynamic> _contentToJson(Content content) {
    return {
      'role': content.role,
      'parts': content.parts.map((part) {
        if (part is TextPart) {
          return {'type': 'text', 'text': part.text};
        }
        // Handle other part types if needed in future
        return {'type': 'unknown', 'text': part.toString()};
      }).toList(),
    };
  }
  
  /// Convert JSON to Content
  Content _contentFromJson(Map<String, dynamic> json) {
    final role = json['role'] as String;
    final parts = (json['parts'] as List).map((partJson) {
      final type = partJson['type'] as String;
      if (type == 'text') {
        return TextPart(partJson['text'] as String);
      }
      // Handle other types if needed
      return TextPart(partJson['text'] as String);
    }).toList();
    
    if (role == 'user') {
      return Content.text(parts.first.text);
    } else if (role == 'model') {
      return Content.model(parts);
    } else {
      // For system messages, use text content with system role
      return Content('system', parts);
    }
  }
  
  @override
  String toString() {
    return 'TripPlanningSession(id: $sessionId, user: $userId, age: ${sessionAgeHours.toStringAsFixed(1)}h, messages: $messagesInSession, refinements: $refinementCount, tokensSaved: $tokensSaved)';
  }
}

/// **Session Metadata for Performance Tracking** 
@Collection()
class TripSessionMetadata {
  Id isarId = Isar.autoIncrement;
  
  late String userId;
  late DateTime lastCleanup;
  late int totalSessionsCreated;
  late int totalSessionsReused;
  late double totalTokensSaved;
  late double totalCostSavings;
  
  /// Calculate session reuse efficiency
  double get reuseEfficiency {
    final total = totalSessionsCreated + totalSessionsReused;
    if (total == 0) return 0.0;
    return (totalSessionsReused / total) * 100;
  }
  
  static TripSessionMetadata create(String userId) {
    return TripSessionMetadata()
      ..userId = userId
      ..lastCleanup = DateTime.now()
      ..totalSessionsCreated = 0
      ..totalSessionsReused = 0
      ..totalTokensSaved = 0
      ..totalCostSavings = 0;
  }
}
