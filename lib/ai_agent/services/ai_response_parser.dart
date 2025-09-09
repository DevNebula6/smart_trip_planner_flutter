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
    
    // Try to extract itinerary JSON
    final itinerary = _extractItinerary(aiResponse);
    
    if (itinerary != null) {
      // AI responded with itinerary
      Logger.d('Extracted itinerary from response: ${itinerary.title}', tag: 'AIParser');
      
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
      Logger.d('AI response is text-only (no itinerary detected)', tag: 'AIParser');
      
      return ChatMessageModel.aiText(
        sessionId: sessionId,
        content: aiResponse,
        tokenCount: tokenCount,
      );
    }
  }
  
  /// Extract itinerary JSON from AI response
  static ItineraryModel? _extractItinerary(String response) {
    try {
      // Look for JSON blocks in various formats
      final jsonPatterns = [
        RegExp(r'```json\s*(\{.*?\})\s*```', dotAll: true),
        RegExp(r'```\s*(\{.*?\})\s*```', dotAll: true),
        RegExp(r'(\{.*?"title".*?"startDate".*?"endDate".*?"days".*?\})', dotAll: true),
      ];
      
      for (final pattern in jsonPatterns) {
        final match = pattern.firstMatch(response);
        if (match != null) {
          // Safely extract JSON string - try group(1) first, then fallback to group(0)
          String jsonStr;
          try {
            jsonStr = match.group(1) ?? match.group(0)!;
          } catch (e) {
            // If group(1) doesn't exist, use group(0)
            jsonStr = match.group(0)!;
          }
          
          final cleaned = _cleanJsonString(jsonStr);
          
          try {
            final json = jsonDecode(cleaned);
            if (json is Map<String, dynamic> && _isValidItinerary(json)) {
              return ItineraryModel.fromJson(json);
            }
          } catch (e) {
            Logger.w('Failed to parse JSON match: $e', tag: 'AIParser');
            continue;
          }
        }
      }
      
      // Try parsing the entire response as JSON (fallback)
      final cleaned = _cleanJsonString(response);
      try {
        final json = jsonDecode(cleaned);
        if (json is Map<String, dynamic> && _isValidItinerary(json)) {
          return ItineraryModel.fromJson(json);
        }
      } catch (e) {
        // Not a JSON response, that's fine
      }
      
      return null;
    } catch (e) {
      Logger.w('Error extracting itinerary: $e', tag: 'AIParser');
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
    return jsonStr
        .replaceAll(RegExp(r'^```json\s*'), '')
        .replaceAll(RegExp(r'^```\s*'), '')
        .replaceAll(RegExp(r'\s*```$'), '')
        .trim();
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
