import 'dart:convert';
import 'package:smart_trip_planner_flutter/trip_planning_chat/data/models/itinerary_models.dart';
import 'package:smart_trip_planner_flutter/core/utils/helpers.dart';

/// **AI Response Parser Service**
/// 
/// Handles parsing of AI responses into structured messages with optional itineraries
class AIResponseParser {
  
  /// Parse AI response and create appropriate message
  static ChatMessageModel parseResponse({
    required String sessionId,
    required String aiResponse,
    int? tokenCount,
  }) {
    Logger.d('Parsing AI response (${aiResponse.length} chars)', tag: 'AIParser');
    
    // Log first 200 chars to help debug
    final preview = aiResponse.length > 200 ? '${aiResponse.substring(0, 200)}...' : aiResponse;
    Logger.d('Response preview: $preview', tag: 'AIParser');
    
    // Check for follow-up question first
    if (aiResponse.trim().startsWith('FOLLOWUP:')) {
      final question = aiResponse.substring(9).trim(); // Remove "FOLLOWUP: " prefix
      Logger.d('Detected follow-up question', tag: 'AIParser');
      
      return ChatMessageModel.aiText(
        sessionId: sessionId,
        content: question,
        tokenCount: tokenCount,
      );
    }
    
    // Check if response likely contains JSON
    final hasJsonIndicators = aiResponse.contains('"title"') && 
                              aiResponse.contains('"days"') && 
                              aiResponse.contains('"startDate"');
    
    if (hasJsonIndicators) {
      Logger.d('Response contains JSON indicators, attempting extraction', tag: 'AIParser');
    }
    
    // Try to extract itinerary JSON
    final itinerary = _extractItinerary(aiResponse);
    
    if (itinerary != null) {
      // AI responded with itinerary
      Logger.d('✓ Extracted itinerary: "${itinerary.title}" (${itinerary.days.length} days)', tag: 'AIParser');
      
      // Extract any additional text message (description, notes)
      final textContent = _extractTextContent(aiResponse);
      
      return ChatMessageModel.aiWithItinerary(
        sessionId: sessionId,
        content: textContent ?? "I've created an itinerary for your trip!",
        itinerary: itinerary,
        tokenCount: tokenCount,
      );
    } else {
      // AI responded with text only (no itinerary)
      if (hasJsonIndicators) {
        Logger.w('✗ Response has JSON indicators but extraction failed - displaying as text', tag: 'AIParser');
      } else {
        Logger.d('AI response is text-only (no itinerary detected)', tag: 'AIParser');
      }
      
      return ChatMessageModel.aiText(
        sessionId: sessionId,
        content: aiResponse,
        tokenCount: tokenCount,
      );
    }
  }
  
  /// Extract itinerary JSON from AI response
  /// Uses multiple robust strategies to handle various response formats
  static ItineraryModel? _extractItinerary(String response) {
    try {
      Logger.d('Starting itinerary extraction from ${response.length} char response', tag: 'AIParser');
      
      // Strategy 1: Try to find JSON in code blocks with non-greedy matching
      final codeBlockPatterns = [
        RegExp(r'```json\s*(\{[\s\S]*?\})\s*```', multiLine: true),
        RegExp(r'```\s*(\{[\s\S]*?\})\s*```', multiLine: true),
      ];
      
      for (final pattern in codeBlockPatterns) {
        final match = pattern.firstMatch(response);
        if (match != null) {
          final jsonStr = match.group(1) ?? match.group(0)!;
          final itinerary = _tryParseJson(jsonStr, 'code block');
          if (itinerary != null) return itinerary;
        }
      }
      
      // Strategy 2: Find JSON by looking for opening brace and matching closing brace
      final jsonStart = response.indexOf('{');
      if (jsonStart != -1) {
        final jsonStr = _extractBalancedJson(response, jsonStart);
        if (jsonStr != null) {
          final itinerary = _tryParseJson(jsonStr, 'balanced braces');
          if (itinerary != null) return itinerary;
        }
      }
      
      // Strategy 3: Look for title/startDate/endDate/days pattern (most specific)
      final structuredPattern = RegExp(
        r'\{\s*"title"\s*:\s*"[^"]+"\s*,\s*"startDate"\s*:\s*"[^"]+"\s*,\s*"endDate"\s*:\s*"[^"]+"\s*,\s*"days"\s*:\s*\[[\s\S]*?\]\s*\}',
        multiLine: true,
      );
      final structuredMatch = structuredPattern.firstMatch(response);
      if (structuredMatch != null) {
        final jsonStr = structuredMatch.group(0)!;
        final itinerary = _tryParseJson(jsonStr, 'structured pattern');
        if (itinerary != null) return itinerary;
      }
      
      // Strategy 4: Try to repair truncated JSON
      if (response.contains('"title"') && response.contains('"days"')) {
        Logger.d('Attempting JSON repair for potentially truncated response', tag: 'AIParser');
        final repaired = _attemptJsonRepair(response);
        if (repaired != null) {
          final itinerary = _tryParseJson(jsonEncode(repaired), 'repaired JSON');
          if (itinerary != null) return itinerary;
        }
      }
      
      // Strategy 5: Try parsing entire response (last resort)
      final itinerary = _tryParseJson(response, 'full response');
      if (itinerary != null) return itinerary;
      
      Logger.d('No valid itinerary found after all extraction strategies', tag: 'AIParser');
      return null;
      
    } catch (e) {
      Logger.w('Error extracting itinerary: $e', tag: 'AIParser');
      return null;
    }
  }
  
  /// Extract balanced JSON by counting braces
  static String? _extractBalancedJson(String text, int startPos) {
    var depth = 0;
    var inString = false;
    var escape = false;
    
    for (var i = startPos; i < text.length; i++) {
      final char = text[i];
      
      if (escape) {
        escape = false;
        continue;
      }
      
      if (char == '\\') {
        escape = true;
        continue;
      }
      
      if (char == '"') {
        inString = !inString;
        continue;
      }
      
      if (!inString) {
        if (char == '{') {
          depth++;
        } else if (char == '}') {
          depth--;
          if (depth == 0) {
            // Found matching closing brace
            return text.substring(startPos, i + 1);
          }
        }
      }
    }
    
    return null; // No balanced JSON found
  }
  
  /// Try to parse JSON string into ItineraryModel
  static ItineraryModel? _tryParseJson(String jsonStr, String strategy) {
    try {
      final cleaned = _cleanJsonString(jsonStr);
      final json = jsonDecode(cleaned);
      
      if (json is Map<String, dynamic> && _isValidItinerary(json)) {
        Logger.d('Successfully parsed itinerary using strategy: $strategy', tag: 'AIParser');
        return ItineraryModel.fromJson(json);
      }
    } catch (e) {
      Logger.d('Failed to parse with strategy "$strategy": ${e.toString().substring(0, 100)}', tag: 'AIParser');
    }
    
    return null;
  }
  
  /// Attempt to repair truncated or malformed JSON
  static Map<String, dynamic>? _attemptJsonRepair(String response) {
    try {
      // Find the last complete day object
      final dayPattern = RegExp(r'\{\s*"date"\s*:\s*"[^"]+"\s*,\s*"summary"\s*:\s*"[^"]+"\s*,\s*"items"\s*:\s*\[[^\]]*\]\s*\}', multiLine: true);
      final dayMatches = dayPattern.allMatches(response).toList();
      
      if (dayMatches.isEmpty) return null;
      
      // Extract header (title, startDate, endDate)
      final titleMatch = RegExp(r'"title"\s*:\s*"([^"]+)"').firstMatch(response);
      final startDateMatch = RegExp(r'"startDate"\s*:\s*"([^"]+)"').firstMatch(response);
      final endDateMatch = RegExp(r'"endDate"\s*:\s*"([^"]+)"').firstMatch(response);
      
      if (titleMatch == null || startDateMatch == null || endDateMatch == null) {
        return null;
      }
      
      // Reconstruct valid JSON with all complete days
      final days = dayMatches.map((match) {
        try {
          return jsonDecode(match.group(0)!);
        } catch (e) {
          return null;
        }
      }).where((day) => day != null).toList();
      
      if (days.isEmpty) return null;
      
      final repairedJson = {
        'title': titleMatch.group(1),
        'startDate': startDateMatch.group(1),
        'endDate': endDateMatch.group(1),
        'days': days,
      };
      
      Logger.d('Successfully repaired JSON with ${days.length} days', tag: 'AIParser');
      return repairedJson;
      
    } catch (e) {
      Logger.w('JSON repair failed: $e', tag: 'AIParser');
      return null;
    }
  }
  
  /// Extract text content (description, notes) separate from JSON
  static String? _extractTextContent(String response) {
    // Remove JSON blocks and clean up remaining text
    var textContent = response;
    
    // Remove code blocks
    textContent = textContent.replaceAll(RegExp(r'```json.*?```', dotAll: true), '');
    textContent = textContent.replaceAll(RegExp(r'```.*?```', dotAll: true), '');
    
    // Remove standalone JSON objects
    textContent = textContent.replaceAll(
      RegExp(r'\{.*?"title".*?"startDate".*?"endDate".*?"days".*?\}', dotAll: true), 
      ''
    );
    
    // Clean up whitespace
    textContent = textContent.trim();
    
    // Return null if no meaningful text remains
    if (textContent.isEmpty || textContent.length < 10) {
      return null;
    }
    
    return textContent;
  }
  
  /// Clean JSON string for parsing
  static String _cleanJsonString(String jsonStr) {
    var cleaned = jsonStr
        // Remove code block markers
        .replaceAll(RegExp(r'^```json\s*'), '')
        .replaceAll(RegExp(r'^```\s*'), '')
        .replaceAll(RegExp(r'\s*```$'), '')
        // Remove any leading/trailing whitespace
        .trim();
    
    // Remove any text before the first { or after the last }
    final firstBrace = cleaned.indexOf('{');
    final lastBrace = cleaned.lastIndexOf('}');
    
    if (firstBrace != -1 && lastBrace != -1 && lastBrace > firstBrace) {
      cleaned = cleaned.substring(firstBrace, lastBrace + 1);
    }
    
    return cleaned;
  }
  
  /// Validate if JSON object is a valid itinerary
  static bool _isValidItinerary(Map<String, dynamic> json) {
    return json.containsKey('title') &&
           json.containsKey('startDate') &&
           json.containsKey('endDate') &&
           json.containsKey('days') &&
           json['days'] is List;
  }
  
  /// Check if response contains follow-up question
  static bool hasFollowUpQuestion(String response) {
    return response.trim().startsWith('FOLLOWUP:');
  }
  
  /// Check if response contains itinerary
  static bool hasItinerary(String response) {
    return _extractItinerary(response) != null;
  }
}

/// Exception for when AI asks follow-up questions (deprecated - now handled by parser)
class FollowUpQuestionException implements Exception {
  final String question;
  
  const FollowUpQuestionException(this.question);
  
  @override
  String toString() => 'FollowUpQuestion: $question';
}
