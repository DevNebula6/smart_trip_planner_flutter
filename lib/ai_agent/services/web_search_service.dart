
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/utils/helpers.dart';

/// **Web Search Service for Tool-Calling Integration**
/// 
/// This service enables Gemini AI to perform real-time web searches using Google Custom Search API
/// or Bing Web Search API. It supports the tool-calling pattern where Gemini requests web search
/// information, and Flutter performs the actual HTTP search and feeds results back to Gemini.
/// 

abstract class WebSearchService {
  Future<List<SearchResult>> search(String query, {int maxResults = 5});
}

/// **Web Search Exception**
class WebSearchException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const WebSearchException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'WebSearchException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// **Search Result Model**
/// 
/// Represents a single search result from web search APIs

class SearchResult {
  /// The title of the web page/result
  final String title;
  
  /// A snippet/summary of the web page content  
  final String snippet;
  
  /// The URL of the web page
  final String url;
  
  /// Optional image URL associated with the result
  final String? imageUrl;
  
  /// Optional display link (domain name)
  final String? displayLink;
  
  /// Optional formatted URL for display
  final String? formattedUrl;
  
  const SearchResult({
    required this.title,
    required this.snippet,
    required this.url,
    this.imageUrl,
    this.displayLink,
    this.formattedUrl,
  });
  
  /// Create SearchResult from JSON response (supports both Google and Bing)
  factory SearchResult.fromJson(Map<String, dynamic> json, {String source = 'google'}) {
    if (source == 'bing') {
      return SearchResult(
        title: json['name'] ?? 'No Title',
        snippet: json['snippet'] ?? 'No description available',
        url: json['url'] ?? '',
        displayLink: json['displayUrl'],
      );
    } else {
      // Google Custom Search format
      return SearchResult(
        title: json['title'] ?? 'No Title',
        snippet: json['snippet'] ?? 'No description available',
        url: json['link'] ?? '',
        displayLink: json['displayLink'],
        formattedUrl: json['formattedUrl'],
      );
    }
  }
  
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'snippet': snippet,
      'url': url,
      'imageUrl': imageUrl,
      'displayLink': displayLink,
      'formattedUrl': formattedUrl,
    };
  }

  /// Convert to format suitable for Gemini tool response
  Map<String, dynamic> toToolResponse() {
    return {
      'title': title,
      'description': snippet,
      'url': url,
      'displayLink': displayLink ?? formattedUrl,
    };
  }

  /// Convert to string format suitable for Gemini tool response
  String toToolResponseFormat() {
    return 'Title: $title\nDescription: $snippet\nURL: $url\n';
  }

  @override
  String toString() => 'SearchResult(title: $title, url: $url)';
}

/// **Google Custom Search Service**
/// 
/// Implementation of WebSearchService using Google Custom Search API
/// Supports real-time web search for travel-related information
class GoogleSearchService implements WebSearchService {
  static const String _baseUrl = 'https://www.googleapis.com/customsearch/v1';
  
  final String apiKey;
  final String searchEngineId;
  final http.Client _httpClient;
  
  /// Request timeout duration
  static const Duration _requestTimeout = Duration(seconds: 10);
  
  GoogleSearchService({
    required this.apiKey,
    required this.searchEngineId,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();
  
  @override
  Future<List<SearchResult>> search(String query, {int maxResults = 5}) async {
    if (query.trim().isEmpty) {
      throw const WebSearchException('Search query cannot be empty');
    }

    if (apiKey.isEmpty || searchEngineId.isEmpty) {
      throw const WebSearchException('API key and search engine ID are required');
    }

    Logger.d('Performing Google Custom Search: "$query"', tag: 'WebSearch');

    try {
      // Build request URL with parameters
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'key': apiKey,
        'cx': searchEngineId,
        'q': query,
        'num': maxResults.toString(),
        'hl': 'en',
        'gl': 'us',
        'safe': 'active', // Safe search enabled
        'fields': 'items(title,snippet,link,displayLink,formattedUrl)', // Only fetch needed fields
      });

      Logger.d('Google Search URL: ${uri.toString().replaceAll(apiKey, '***')}', tag: 'WebSearch');

      // Make HTTP request with timeout
      final response = await _httpClient
          .get(uri)
          .timeout(_requestTimeout, onTimeout: () {
        throw const WebSearchException('Search request timed out');
      });

      return _parseGoogleResponse(response, query);
      
    } on SocketException catch (e) {
      Logger.e('Network error during Google search: $e', tag: 'WebSearch');
      throw WebSearchException('Network error: Please check your internet connection', originalError: e);
    } on TimeoutException catch (e) {
      Logger.e('Timeout during Google search: $e', tag: 'WebSearch');
      throw WebSearchException('Search request timed out', originalError: e);
    } on FormatException catch (e) {
      Logger.e('JSON parsing error during Google search: $e', tag: 'WebSearch');
      throw WebSearchException('Failed to parse search results', originalError: e);
    } catch (e) {
      Logger.e('Unexpected error during Google search: $e', tag: 'WebSearch');
      throw WebSearchException('Google search failed: $e', originalError: e);
    }
  }

  /// Parse Google Custom Search API response
  List<SearchResult> _parseGoogleResponse(http.Response response, String query) {
    Logger.d('Google search response status: ${response.statusCode}', tag: 'WebSearch');

    if (response.statusCode == 429) {
      throw const WebSearchException('Google Search API quota exceeded. Please try again later.', code: '429');
    }

    if (response.statusCode == 403) {
      throw const WebSearchException('Google Search API access forbidden. Please check your API key.', code: '403');
    }

    if (response.statusCode != 200) {
      throw WebSearchException(
        'Google Search API returned error: ${response.statusCode} ${response.reasonPhrase}',
        code: response.statusCode.toString(),
      );
    }

    try {
      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      
      // Check for API errors
      if (jsonData.containsKey('error')) {
        final error = jsonData['error'] as Map<String, dynamic>;
        throw WebSearchException(
          'Google API Error: ${error['message'] ?? 'Unknown error'}',
          code: error['code']?.toString(),
        );
      }

      // Extract search results
      final items = jsonData['items'] as List<dynamic>? ?? [];
      
      if (items.isEmpty) {
        Logger.w('No Google search results found for query: "$query"', tag: 'WebSearch');
        return [];
      }

      final results = items
          .cast<Map<String, dynamic>>()
          .map((item) => SearchResult.fromJson(item, source: 'google'))
          .where((result) => result.url.isNotEmpty) // Filter out results without URLs
          .toList();

      Logger.d('Successfully parsed ${results.length} Google search results', tag: 'WebSearch');
      return results;

    } on FormatException catch (e) {
      Logger.e('Failed to decode Google JSON response: $e', tag: 'WebSearch');
      Logger.d('Google response body: ${response.body}', tag: 'WebSearch');
      throw WebSearchException('Invalid JSON response from Google Search API', originalError: e);
    }
  }

  void dispose() {
    _httpClient.close();
  }
}

/// **Bing Web Search Service**
/// 
/// Implementation of WebSearchService using Bing Web Search API
/// Alternative to Google Custom Search for real-time information
class BingSearchService implements WebSearchService {
  final String apiKey;
  final http.Client _httpClient;
  
  /// Bing Web Search API base URL
  static const String _baseUrl = 'https://api.bing.microsoft.com/v7.0/search';
  
  /// Request timeout duration
  static const Duration _requestTimeout = Duration(seconds: 10);
  
  BingSearchService({
    required this.apiKey,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();
  
  @override
  Future<List<SearchResult>> search(String query, {int maxResults = 5}) async {
    if (query.trim().isEmpty) {
      throw const WebSearchException('Search query cannot be empty');
    }

    if (apiKey.isEmpty) {
      throw const WebSearchException('Bing API key is required');
    }

    Logger.d('Performing Bing Web Search: "$query"', tag: 'WebSearch');

    try {
      // Build request URL with parameters
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'q': query,
        'count': maxResults.toString(),
        'mkt': 'en-US',
        'safeSearch': 'moderate',
        'textFormat': 'raw',
      });

      Logger.d('Bing Search URL: ${uri.toString()}', tag: 'WebSearch');

      // Make HTTP request with timeout and headers
      final response = await _httpClient.get(
        uri,
        headers: {
          'Ocp-Apim-Subscription-Key': apiKey,
          'User-Agent': 'SmartTripPlanner/1.0',
        },
      ).timeout(_requestTimeout, onTimeout: () {
        throw const WebSearchException('Bing search request timed out');
      });

      return _parseBingResponse(response, query);
      
    } on SocketException catch (e) {
      Logger.e('Network error during Bing search: $e', tag: 'WebSearch');
      throw WebSearchException('Network error: Please check your internet connection', originalError: e);
    } on TimeoutException catch (e) {
      Logger.e('Timeout during Bing search: $e', tag: 'WebSearch');
      throw WebSearchException('Bing search request timed out', originalError: e);
    } on FormatException catch (e) {
      Logger.e('JSON parsing error during Bing search: $e', tag: 'WebSearch');
      throw WebSearchException('Failed to parse Bing search results', originalError: e);
    } catch (e) {
      Logger.e('Unexpected error during Bing search: $e', tag: 'WebSearch');
      throw WebSearchException('Bing search failed: $e', originalError: e);
    }
  }

  /// Parse Bing Web Search API response
  List<SearchResult> _parseBingResponse(http.Response response, String query) {
    Logger.d('Bing search response status: ${response.statusCode}', tag: 'WebSearch');

    if (response.statusCode == 429) {
      throw const WebSearchException('Bing Search API quota exceeded. Please try again later.', code: '429');
    }

    if (response.statusCode == 403) {
      throw const WebSearchException('Bing Search API access forbidden. Please check your API key.', code: '403');
    }

    if (response.statusCode != 200) {
      throw WebSearchException(
        'Bing Search API returned error: ${response.statusCode} ${response.reasonPhrase}',
        code: response.statusCode.toString(),
      );
    }

    try {
      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      
      // Check for API errors
      if (jsonData.containsKey('errors')) {
        final errors = jsonData['errors'] as List;
        final error = errors.isNotEmpty ? errors.first : {'message': 'Unknown Bing API error'};
        throw WebSearchException(
          'Bing API Error: ${error['message'] ?? 'Unknown error'}',
          code: error['code']?.toString(),
        );
      }

      // Extract web pages from search results
      final webPages = jsonData['webPages'] as Map<String, dynamic>?;
      if (webPages == null) {
        Logger.w('No web pages found in Bing search results for query: "$query"', tag: 'WebSearch');
        return [];
      }

      final values = webPages['value'] as List<dynamic>? ?? [];
      
      if (values.isEmpty) {
        Logger.w('No Bing search results found for query: "$query"', tag: 'WebSearch');
        return [];
      }

      final results = values
          .cast<Map<String, dynamic>>()
          .map((item) => SearchResult.fromJson(item, source: 'bing'))
          .where((result) => result.url.isNotEmpty) // Filter out results without URLs
          .toList();

      Logger.d('Successfully parsed ${results.length} Bing search results', tag: 'WebSearch');
      return results;

    } on FormatException catch (e) {
      Logger.e('Failed to decode Bing JSON response: $e', tag: 'WebSearch');
      Logger.d('Bing response body: ${response.body}', tag: 'WebSearch');
      throw WebSearchException('Invalid JSON response from Bing Search API', originalError: e);
    }
  }

  void dispose() {
    _httpClient.close();
  }
}

/// **Web Search Tool Integration for Gemini**
/// 
/// This class provides the tool-calling integration layer that allows Gemini AI
/// to request web searches and receive formatted results for itinerary enhancement.
/// 
/// Usage with Gemini Function Calling:
/// ```dart
/// final webSearchTool = WebSearchTool(googleApiKey, searchEngineId);
/// final tools = [webSearchTool.getFunctionDeclaration()];
/// final model = GenerativeModel(
///   model: 'gemini-pro', 
///   apiKey: apiKey, 
///   tools: tools
/// );
/// ```
class WebSearchTool {
  final WebSearchService _searchService;
  
  WebSearchTool.google({
    required String apiKey,
    required String searchEngineId,
    http.Client? httpClient,
  }) : _searchService = GoogleSearchService(
         apiKey: apiKey,
         searchEngineId: searchEngineId,
         httpClient: httpClient,
       );
  
  WebSearchTool.bing({
    required String apiKey,
    http.Client? httpClient,
  }) : _searchService = BingSearchService(
         apiKey: apiKey,
         httpClient: httpClient,
       );
  
  /// Get the function declaration for Gemini tool-calling
  Map<String, dynamic> getFunctionDeclaration() {
    return {
      'name': 'webSearch',
      'description': '''
Search the web for real-time information about travel destinations, restaurants, hotels, events, attractions, transportation, and other travel-related topics.

Use this tool to:
- Find current operating hours, prices, and contact information
- Get recent reviews and ratings for restaurants and attractions  
- Check for special events or festivals during travel dates
- Find transportation options and schedules
- Get weather information and seasonal recommendations
- Search for local customs, visa requirements, and travel advisories

Examples:
- "best restaurants in Paris with Michelin stars 2024"
- "Rome Colosseum opening hours and ticket prices"
- "events in Tokyo in March 2024"
- "best hiking trails in Swiss Alps difficulty level"
- "direct flights from New York to London December 2024"
      '''.trim(),
      'parameters': {
        'type': 'object',
        'properties': {
          'query': {
            'type': 'string',
            'description': 'The search query for travel-related information. Be specific and include relevant details like location, dates, or preferences.',
          },
          'maxResults': {
            'type': 'integer',
            'description': 'Maximum number of search results to return (default: 5, max: 10)',
            'minimum': 1,
            'maximum': 10,
            'default': 5,
          }
        },
        'required': ['query']
      }
    };
  }
  
  /// Handle web search function call from Gemini
  /// 
  /// This method processes the function call arguments and returns formatted
  /// search results that Gemini can use to enhance itinerary recommendations.
  Future<Map<String, dynamic>> handleFunctionCall(Map<String, dynamic> arguments) async {
    try {
      final query = arguments['query'] as String?;
      if (query == null || query.trim().isEmpty) {
        return {
          'error': 'Search query is required and cannot be empty',
          'results': <Map<String, dynamic>>[],
        };
      }

      final maxResults = (arguments['maxResults'] as int?) ?? 5;
      final clampedMaxResults = maxResults.clamp(1, 10);

      Logger.d('Processing web search function call: "$query" (max: $clampedMaxResults)', tag: 'WebSearchTool');

      final results = await _searchService.search(query.trim(), maxResults: clampedMaxResults);
      
      return {
        'query': query.trim(),
        'totalResults': results.length,
        'results': results.map((result) => result.toToolResponse()).toList(),
        'searchedAt': DateTime.now().toIso8601String(),
      };

    } on WebSearchException catch (e) {
      Logger.e('Web search tool error: ${e.message}', tag: 'WebSearchTool');
      return {
        'error': e.message,
        'errorCode': e.code,
        'results': <Map<String, dynamic>>[],
      };
    } catch (e) {
      Logger.e('Unexpected error in web search tool: $e', tag: 'WebSearchTool');
      return {
        'error': 'An unexpected error occurred during web search: $e',
        'results': <Map<String, dynamic>>[],
      };
    }
  }
  
  void dispose() {
    switch (_searchService.runtimeType) {
      case GoogleSearchService:
        (_searchService as GoogleSearchService).dispose();
        break;
      case BingSearchService:
        (_searchService as BingSearchService).dispose();
        break;
    }
  }
}
