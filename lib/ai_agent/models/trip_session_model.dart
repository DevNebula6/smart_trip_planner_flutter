import 'package:google_generative_ai/google_generative_ai.dart';

class SessionState {
  final String sessionId;
  final String userId;
  final DateTime createdAt;
  DateTime lastUsed;
  List<Content> conversationHistory;
  Map<String, dynamic> userPreferences;
  Map<String, dynamic> tripContext;
  int tokensSaved;
  int messagesInSession;
  double estimatedCostSavings;
  int refinementCount;
  bool isActive;

  SessionState({
    required this.sessionId,
    required this.userId,
    required this.createdAt,
    required this.lastUsed,
    required this.conversationHistory,
    required this.userPreferences,
    required this.tripContext,
    this.tokensSaved = 0,
    this.messagesInSession = 0,
    this.estimatedCostSavings = 0.0,
    this.refinementCount = 0,
    this.isActive = true,
  });

  factory SessionState.create(String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sessionId = '${userId}_trip_$timestamp';

    return SessionState(
      sessionId: sessionId,
      userId: userId,
      createdAt: DateTime.now(),
      lastUsed: DateTime.now(),
      conversationHistory: [],
      userPreferences: {},
      tripContext: {},
    );
  }

  bool get isValid {
    if (!isActive) return false;
    const maxAge = Duration(days: 90);
    return DateTime.now().difference(createdAt) < maxAge;
  }

  void updateConversation({
    required Content userMessage,
    required Content aiResponse,
    int? tokensUsed,
    int? tokensSavedFromReuse,
  }) {
    conversationHistory.add(userMessage);
    conversationHistory.add(aiResponse);

    // Trim history if too long
    const maxHistoryLength = 50;
    if (conversationHistory.length > maxHistoryLength) {
      final keepCount = maxHistoryLength;
      conversationHistory = conversationHistory.skip(conversationHistory.length - keepCount).toList();
    }

    messagesInSession += 2;
    lastUsed = DateTime.now();

    if (tokensUsed != null && tokensUsed > 0) {
      const costPer1kTokens = 0.03;
      final costForThisRequest = tokensUsed / 1000 * costPer1kTokens;
      estimatedCostSavings += costForThisRequest;
    }

    if (tokensSavedFromReuse != null) {
      tokensSaved += tokensSavedFromReuse;
    }
  }

  void extractUserPreferences(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains(RegExp(r'budget|cheap|affordable'))) {
      userPreferences['budget_style'] = 'budget';
    } else if (lowerMessage.contains(RegExp(r'luxury|expensive|premium'))) {
      userPreferences['budget_style'] = 'luxury';
    }

    if (lowerMessage.contains(RegExp(r'adventure|hiking|outdoor|active'))) {
      userPreferences['travel_style'] = 'adventure';
    } else if (lowerMessage.contains(RegExp(r'relax|peaceful|calm|quiet'))) {
      userPreferences['travel_style'] = 'relaxed';
    } else if (lowerMessage.contains(RegExp(r'culture|museum|history|art'))) {
      userPreferences['travel_style'] = 'cultural';
    }

    if (lowerMessage.contains(RegExp(r'vegetarian|vegan|gluten.free|halal|kosher'))) {
      final match = RegExp(r'(vegetarian|vegan|gluten.free|halal|kosher)').firstMatch(lowerMessage);
      if (match != null) {
        userPreferences['dietary_restrictions'] = match.group(1);
      }
    }
  }

  void extractTripContext(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('to ') || lowerMessage.contains('visit ')) {
      final destinationMatch = RegExp(r'(?:to|visit)\s+([a-zA-Z\s]+?)(?:\s|$|,)').firstMatch(lowerMessage);
      if (destinationMatch != null) {
        tripContext['destination'] = destinationMatch.group(1)?.trim();
      }
    }

    final durationMatch = RegExp(r'(\d+)\s*(day|week|month)').firstMatch(lowerMessage);
    if (durationMatch != null) {
      final number = int.parse(durationMatch.group(1)!);
      final unit = durationMatch.group(2)!;
      tripContext['duration_number'] = number;
      tripContext['duration_unit'] = unit;
    }
  }

  String buildRefinementContext() {
    final buffer = StringBuffer();

    if (userPreferences.isNotEmpty) {
      buffer.writeln('User Preferences:');
      userPreferences.forEach((key, value) {
        buffer.writeln('- $key: $value');
      });
      buffer.writeln();
    }

    if (tripContext.isNotEmpty) {
      buffer.writeln('Trip Context:');
      tripContext.forEach((key, value) {
        buffer.writeln('- $key: $value');
      });
      buffer.writeln();
    }

    if (refinementCount > 0) {
      buffer.writeln('Previous Refinements: $refinementCount');
      buffer.writeln();
    }

    return buffer.toString();
  }

  void markRefinement() {
    refinementCount++;
    lastUsed = DateTime.now();
  }

  // Serialization
  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'lastUsed': lastUsed.toIso8601String(),
      'conversationHistory': conversationHistory.map((c) => _contentToJson(c)).toList(),
      'userPreferences': userPreferences,
      'tripContext': tripContext,
      'tokensSaved': tokensSaved,
      'messagesInSession': messagesInSession,
      'estimatedCostSavings': estimatedCostSavings,
      'refinementCount': refinementCount,
      'isActive': isActive,
    };
  }

  factory SessionState.fromJson(Map<String, dynamic> json) {
    return SessionState(
      sessionId: json['sessionId'],
      userId: json['userId'],
      createdAt: DateTime.parse(json['createdAt']),
      lastUsed: DateTime.parse(json['lastUsed']),
      conversationHistory: (json['conversationHistory'] as List)
          .map((c) => _contentFromJson(c))
          .toList(),
      userPreferences: Map<String, dynamic>.from(json['userPreferences'] ?? {}),
      tripContext: Map<String, dynamic>.from(json['tripContext'] ?? {}),
      tokensSaved: json['tokensSaved'] ?? 0,
      messagesInSession: json['messagesInSession'] ?? 0,
      estimatedCostSavings: json['estimatedCostSavings']?.toDouble() ?? 0.0,
      refinementCount: json['refinementCount'] ?? 0,
      isActive: json['isActive'] ?? true,
    );
  }

  static Map<String, dynamic> _contentToJson(Content content) {
    return {
      'role': content.role,
      'parts': content.parts.map((part) {
        if (part is TextPart) {
          return {'type': 'text', 'text': part.text};
        }
        return {'type': 'unknown', 'text': part.toString()};
      }).toList(),
    };
  }

  static Content _contentFromJson(Map<String, dynamic> json) {
    final role = json['role'] as String;
    final parts = (json['parts'] as List).map((partJson) {
      final type = partJson['type'] as String;
      if (type == 'text') {
        return TextPart(partJson['text'] as String);
      }
      return TextPart(partJson['text'] as String);
    }).toList();

    if (role == 'user') {
      return Content.text(parts.first.text);
    } else if (role == 'model') {
      return Content.model(parts);
    } else {
      return Content('system', parts);
    }
  }
}
