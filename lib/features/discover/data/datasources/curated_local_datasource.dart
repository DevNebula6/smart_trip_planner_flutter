import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/entities/discover_destination.dart';

/// Local data source for reading curated destinations from bundled JSON
class CuratedLocalDataSource {
  static const String _jsonPath = 'assets/data/curated_destinations.json';
  
  List<Map<String, dynamic>>? _cachedDestinations;
  DateTime? _cacheTime;
  static const Duration _cacheDuration = Duration(hours: 24);
  
  /// Load all destinations from local JSON file
  Future<List<Map<String, dynamic>>> getAllDestinations({
    DestinationCategory? category,
    int limit = 50,
  }) async {
    try {
      // Load destinations (with caching)
      final destinations = await _loadDestinations();
      
      // Filter by category if provided
      var filtered = category != null && category != DestinationCategory.all
          ? destinations.where((dest) {
              final destCategory = dest['category'] as String?;
              return destCategory?.toLowerCase() == category.name.toLowerCase();
            }).toList()
          : destinations;
      
      // Sort by hidden_score (descending)
      filtered.sort((a, b) {
        final scoreA = (a['hidden_score'] ?? 0.0) as num;
        final scoreB = (b['hidden_score'] ?? 0.0) as num;
        return scoreB.compareTo(scoreA);
      });
      
      // Apply limit
      if (filtered.length > limit) {
        filtered = filtered.sublist(0, limit);
      }
      
      return filtered;
    } catch (e) {
      throw Exception('Failed to load destinations from local JSON: $e');
    }
  }
  
  /// Search destinations by name, description, or tags
  Future<List<Map<String, dynamic>>> searchDestinations({
    required String query,
    DestinationCategory? category,
    int limit = 20,
  }) async {
    try {
      final destinations = await _loadDestinations();
      final queryLower = query.toLowerCase();
      
      // Search in name, description, and tags
      var filtered = destinations.where((dest) {
        final name = (dest['name'] as String? ?? '').toLowerCase();
        final description = (dest['description'] as String? ?? '').toLowerCase();
        final tags = dest['tags'] as List?;
        final tagsString = tags?.join(' ').toLowerCase() ?? '';
        
        final matchesQuery = name.contains(queryLower) ||
            description.contains(queryLower) ||
            tagsString.contains(queryLower);
        
        if (!matchesQuery) return false;
        
        // Filter by category if provided
        if (category != null && category != DestinationCategory.all) {
          final destCategory = dest['category'] as String?;
          return destCategory?.toLowerCase() == category.name.toLowerCase();
        }
        
        return true;
      }).toList();
      
      // Sort by relevance (name match first, then description, then tags)
      filtered.sort((a, b) {
        final nameA = (a['name'] as String? ?? '').toLowerCase();
        final nameB = (b['name'] as String? ?? '').toLowerCase();
        
        final nameMatchA = nameA.contains(queryLower);
        final nameMatchB = nameB.contains(queryLower);
        
        if (nameMatchA && !nameMatchB) return -1;
        if (!nameMatchA && nameMatchB) return 1;
        
        // If both or neither match name, sort by hidden_score
        final scoreA = (a['hidden_score'] ?? 0.0) as num;
        final scoreB = (b['hidden_score'] ?? 0.0) as num;
        return scoreB.compareTo(scoreA);
      });
      
      // Apply limit
      if (filtered.length > limit) {
        filtered = filtered.sublist(0, limit);
      }
      
      return filtered;
    } catch (e) {
      throw Exception('Failed to search destinations in local JSON: $e');
    }
  }
  
  /// Get single destination by ID
  Future<Map<String, dynamic>> getDestinationById(String id) async {
    try {
      final destinations = await _loadDestinations();
      final destination = destinations.firstWhere(
        (dest) => dest['id'] == id,
        orElse: () => throw Exception('Destination not found: $id'),
      );
      return destination;
    } catch (e) {
      throw Exception('Failed to fetch destination from local JSON: $e');
    }
  }
  
  /// Get destinations by country
  Future<List<Map<String, dynamic>>> getDestinationsByCountry({
    required String countryCode,
    int limit = 20,
  }) async {
    try {
      final destinations = await _loadDestinations();
      
      var filtered = destinations.where((dest) {
        final code = dest['country_code'] as String?;
        return code?.toUpperCase() == countryCode.toUpperCase();
      }).toList();
      
      // Sort by hidden_score
      filtered.sort((a, b) {
        final scoreA = (a['hidden_score'] ?? 0.0) as num;
        final scoreB = (b['hidden_score'] ?? 0.0) as num;
        return scoreB.compareTo(scoreA);
      });
      
      // Apply limit
      if (filtered.length > limit) {
        filtered = filtered.sublist(0, limit);
      }
      
      return filtered;
    } catch (e) {
      throw Exception('Failed to fetch destinations by country: $e');
    }
  }
  
  /// Get top rated destinations (by hidden score)
  Future<List<Map<String, dynamic>>> getTopRatedDestinations({
    int limit = 20,
  }) async {
    try {
      final destinations = await _loadDestinations();
      
      // Filter by high hidden_score (>= 8.5)
      var filtered = destinations.where((dest) {
        final score = (dest['hidden_score'] ?? 0.0) as num;
        return score >= 8.5;
      }).toList();
      
      // Sort by hidden_score (descending)
      filtered.sort((a, b) {
        final scoreA = (a['hidden_score'] ?? 0.0) as num;
        final scoreB = (b['hidden_score'] ?? 0.0) as num;
        return scoreB.compareTo(scoreA);
      });
      
      // Apply limit
      if (filtered.length > limit) {
        filtered = filtered.sublist(0, limit);
      }
      
      return filtered;
    } catch (e) {
      throw Exception('Failed to fetch top rated destinations: $e');
    }
  }
  
  /// Get JSON version and last updated info
  Future<Map<String, dynamic>> getMetadata() async {
    try {
      final jsonString = await rootBundle.loadString(_jsonPath);
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      
      return {
        'version': jsonData['version'],
        'last_updated': jsonData['last_updated'],
        'count': (jsonData['destinations'] as List?)?.length ?? 0,
      };
    } catch (e) {
      throw Exception('Failed to load metadata: $e');
    }
  }
  
  /// Clear cache to force reload
  void clearCache() {
    _cachedDestinations = null;
    _cacheTime = null;
  }
  
  /// Internal method to load and cache destinations
  Future<List<Map<String, dynamic>>> _loadDestinations() async {
    // Return cached data if still valid
    if (_cachedDestinations != null && _cacheTime != null) {
      final age = DateTime.now().difference(_cacheTime!);
      if (age < _cacheDuration) {
        return _cachedDestinations!;
      }
    }
    
    // Load from JSON file
    final jsonString = await rootBundle.loadString(_jsonPath);
    final jsonData = json.decode(jsonString) as Map<String, dynamic>;
    final destinations = jsonData['destinations'] as List;
    
    // Cache the results
    _cachedDestinations = destinations.cast<Map<String, dynamic>>();
    _cacheTime = DateTime.now();
    
    return _cachedDestinations!;
  }
}
