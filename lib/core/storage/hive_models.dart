import 'package:hive/hive.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

part 'hive_models.g.dart';

/// **Hive Itinerary Model**
/// 
/// Replaces ItineraryModel with Hive compatibility
@HiveType(typeId: 0)
class HiveItineraryModel extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String startDate;
  
  @HiveField(3)
  String endDate;
  
  @HiveField(4)
  List<HiveDayPlanModel> days;
  
  @HiveField(5)
  String? originalPrompt;
  
  @HiveField(6)
  DateTime? createdAt;
  
  @HiveField(7)
  DateTime? updatedAt;

  HiveItineraryModel({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.days,
    this.originalPrompt,
    this.createdAt,
    this.updatedAt,
  });

  /// Convert to JSON for API responses (maintains assignment spec)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'startDate': startDate,
      'endDate': endDate,
      'days': days.map((day) => day.toJson()).toList(),
    };
  }

  /// Create from JSON (for AI responses)
  factory HiveItineraryModel.fromJson(Map<String, dynamic> json) {
    return HiveItineraryModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      days: (json['days'] as List<dynamic>)
          .map((dayJson) => HiveDayPlanModel.fromJson(dayJson as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.now(),
    );
  }
  
  /// Calculate trip duration in days
  int get durationDays => days.length;
}

/// **Hive Day Plan Model**
@HiveType(typeId: 1)
class HiveDayPlanModel {
  @HiveField(0)
  String date;
  
  @HiveField(1)
  String summary;
  
  @HiveField(2)
  List<HiveActivityItemModel> items;

  HiveDayPlanModel({
    required this.date,
    required this.summary,
    required this.items,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'summary': summary,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  /// Create from JSON
  factory HiveDayPlanModel.fromJson(Map<String, dynamic> json) {
    return HiveDayPlanModel(
      date: json['date'] as String,
      summary: json['summary'] as String,
      items: (json['items'] as List<dynamic>)
          .map((itemJson) => HiveActivityItemModel.fromJson(itemJson as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// **Hive Activity Item Model**
@HiveType(typeId: 2)
class HiveActivityItemModel {
  @HiveField(0)
  String time;
  
  @HiveField(1)
  String activity;
  
  @HiveField(2)
  String location;

  HiveActivityItemModel({
    required this.time,
    required this.activity,
    required this.location,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'activity': activity,
      'location': location,
    };
  }

  /// Create from JSON
  factory HiveActivityItemModel.fromJson(Map<String, dynamic> json) {
    return HiveActivityItemModel(
      time: json['time'] as String,
      activity: json['activity'] as String,
      location: json['location'] as String,
    );
  }
  
  /// Parse latitude from location string
  double? get latitude {
    try {
      final parts = location.split(',');
      return double.parse(parts[0]);
    } catch (e) {
      return null;
    }
  }
  
  /// Parse longitude from location string  
  double? get longitude {
    try {
      final parts = location.split(',');
      return double.parse(parts[1]);
    } catch (e) {
      return null;
    }
  }
  
  /// Get formatted time for display (12-hour format)
  String get formattedTime {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts[1];
      
      if (hour == 0) return '12:$minute AM';
      if (hour < 12) return '$hour:$minute AM';
      if (hour == 12) return '12:$minute PM';
      return '${hour - 12}:$minute PM';
    } catch (e) {
      return time;
    }
  }
}

/// **Hive Chat Message Model**
@HiveType(typeId: 3)
class HiveChatMessageModel extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String itineraryId;
  
  @HiveField(2)
  String content;
  
  @HiveField(3)
  String role; // 'user' or 'assistant'
  
  @HiveField(4)
  DateTime timestamp;
  
  @HiveField(5)
  int? tokenCount;

  HiveChatMessageModel({
    required this.id,
    required this.itineraryId,
    required this.content,
    required this.role,
    required this.timestamp,
    this.tokenCount,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itineraryId': itineraryId,
      'content': content,
      'role': role,
      'timestamp': timestamp.toIso8601String(),
      'tokenCount': tokenCount,
    };
  }

  /// Create from JSON
  factory HiveChatMessageModel.fromJson(Map<String, dynamic> json) {
    return HiveChatMessageModel(
      id: json['id'] as String,
      itineraryId: json['itineraryId'] as String,
      content: json['content'] as String,
      role: json['role'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      tokenCount: json['tokenCount'] as int?,
    );
  }
}

/// **Hive Session State Model**
/// 
/// Replaces the SessionState class with Hive persistence
/// Maintains all AI Companion session persistence patterns
@HiveType(typeId: 4)
class HiveSessionState extends HiveObject {
  @HiveField(0)
  String sessionId;
  
  @HiveField(1)
  String userId;
  
  @HiveField(2)
  DateTime createdAt;
  
  @HiveField(3)
  DateTime lastUsed;
  
  @HiveField(4)
  List<HiveContentModel> conversationHistory;
  
  @HiveField(5)
  Map<String, dynamic> userPreferences;
  
  @HiveField(6)
  Map<String, dynamic> tripContext;
  
  @HiveField(7)
  int tokensSaved;
  
  @HiveField(8)
  int messagesInSession;
  
  @HiveField(9)
  double estimatedCostSavings;
  
  @HiveField(10)
  int refinementCount;
  
  @HiveField(11)
  bool isActive;

  HiveSessionState({
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

  /// Create new session
  static HiveSessionState create(String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sessionId = '${userId}_trip_$timestamp';

    return HiveSessionState(
      sessionId: sessionId,
      userId: userId,
      createdAt: DateTime.now(),
      lastUsed: DateTime.now(),
      conversationHistory: [],
      userPreferences: {},
      tripContext: {},
    );
  }

  /// Check if session is valid (90-day limit)
  bool get isValid {
    if (!isActive) return false;
    const maxAge = Duration(days: 90);
    return DateTime.now().difference(createdAt) < maxAge;
  }

  /// Update conversation with new messages
  void updateConversation({
    required Content userMessage,
    required Content aiResponse,
    int? tokensUsed,
    int? tokensSavedFromReuse,
  }) {
    conversationHistory.add(HiveContentModel.fromContent(userMessage));
    conversationHistory.add(HiveContentModel.fromContent(aiResponse));

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

  /// Extract user preferences from conversation
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

  /// Extract trip context from user message
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

  /// Build context for refinement requests
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

  /// Mark session as having a refinement
  void markRefinement() {
    refinementCount++;
    lastUsed = DateTime.now();
  }

  /// Get conversation history as Gemini Content objects
  List<Content> get geminiConversationHistory {
    try {
      final contentList = <Content>[];
      
      for (final hiveContent in conversationHistory) {
        try {
          // Validate the hive content before conversion
          if (hiveContent.parts.isEmpty) {
            print('Warning: Skipping HiveContentModel with empty parts');
            continue;
          }
          
          final content = hiveContent.toContent();
          contentList.add(content);
        } catch (e) {
          print('Warning: Failed to convert HiveContentModel to Content: $e');
          // Skip invalid content rather than crashing
          continue;
        }
      }
      
      print('Successfully converted ${contentList.length} content objects from ${conversationHistory.length} hive objects');
      return contentList;
    } catch (e) {
      print('Error in geminiConversationHistory: $e');
      return [];
    }
  }
}

/// **Hive Content Model**
/// 
/// Stores Gemini Content objects in Hive format
@HiveType(typeId: 5)
class HiveContentModel {
  @HiveField(0)
  String role;
  
  @HiveField(1)
  List<HivePartModel> parts;

  HiveContentModel({
    required this.role,
    required this.parts,
  });

  /// Create from Gemini Content
  factory HiveContentModel.fromContent(Content content) {
    return HiveContentModel(
      role: content.role ?? 'system', // Handle nullable role
      parts: content.parts.map((part) => HivePartModel.fromPart(part)).toList(),
    );
  }

  /// Convert to Gemini Content
  Content toContent() {
    try {
      final geminiParts = parts.map((part) => part.toPart()).toList();
      
      // Validate we have valid parts
      if (geminiParts.isEmpty) {
        print('Warning: Empty parts in HiveContentModel, creating default text part');
        geminiParts.add(TextPart(''));
      }
      
      // Validate role and create appropriate Content
      if (role == 'user') {
        final firstPart = geminiParts.first;
        if (firstPart is TextPart) {
          return Content.text(firstPart.text);
        } else {
          print('Warning: Non-text part in user content, using toString()');
          return Content.text(firstPart.toString());
        }
      } else if (role == 'model') {
        return Content.model(geminiParts);
      } else {
        print('Warning: Unknown role $role, defaulting to model');
        return Content.model(geminiParts);
      }
    } catch (e) {
      print('Error converting HiveContentModel to Content: $e');
      // Return a safe default
      return Content.text('');
    }
  }
}

/// **Hive Part Model**
/// 
/// Stores Gemini Part objects in Hive format
@HiveType(typeId: 6)
class HivePartModel {
  @HiveField(0)
  String type;
  
  @HiveField(1)
  String text;

  HivePartModel({
    required this.type,
    required this.text,
  });

  /// Create from Gemini Part
  factory HivePartModel.fromPart(Part part) {
    if (part is TextPart) {
      return HivePartModel(
        type: 'text',
        text: part.text,
      );
    }
    return HivePartModel(
      type: 'unknown',
      text: part.toString(),
    );
  }

  /// Convert to Gemini Part
  Part toPart() {
    if (type == 'text') {
      return TextPart(text);
    }
    return TextPart(text);
  }
}
