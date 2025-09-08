import 'package:equatable/equatable.dart';

/// **AI Response Model**
/// 
/// Represents the response from the AI service, including content,
/// token usage, and optional itinerary data
class AIResponse extends Equatable {
  final String content;
  final int? tokenCount;
  final bool hasItinerary;
  final Map<String, dynamic>? itinerary;
  final String? error;
  
  const AIResponse({
    required this.content,
    this.tokenCount,
    this.hasItinerary = false,
    this.itinerary,
    this.error,
  });
  
  /// Success response with content
  factory AIResponse.success({
    required String content,
    int? tokenCount,
    Map<String, dynamic>? itinerary,
  }) {
    return AIResponse(
      content: content,
      tokenCount: tokenCount,
      hasItinerary: itinerary != null,
      itinerary: itinerary,
    );
  }
  
  /// Error response
  factory AIResponse.error({
    required String error,
    String? partialContent,
  }) {
    return AIResponse(
      content: partialContent ?? 'Error occurred: $error',
      error: error,
    );
  }
  
  /// Response with itinerary
  factory AIResponse.withItinerary({
    required String content,
    required Map<String, dynamic> itinerary,
    int? tokenCount,
  }) {
    return AIResponse(
      content: content,
      tokenCount: tokenCount,
      hasItinerary: true,
      itinerary: itinerary,
    );
  }
  
  bool get isSuccess => error == null;
  bool get isError => error != null;
  
  @override
  List<Object?> get props => [content, tokenCount, hasItinerary, itinerary, error];
}
