import 'package:equatable/equatable.dart';

/// Destination category for filtering
enum DestinationCategory {
  all('All', 'attractions'),
  natural('Natural', 'natural'),
  cultural('Cultural', 'cultural'),
  architecture('Architecture', 'architecture'),
  adventure('Adventure', 'sport,climbing,diving'),
  urban('Urban', 'interesting_places'),
  coastal('Coastal', 'beaches');

  final String displayName;
  final String apiKinds; // OpenTripMap API 'kinds' parameter
  
  const DestinationCategory(this.displayName, this.apiKinds);
  
  /// Parse category from string
  static DestinationCategory fromString(String value) {
    return DestinationCategory.values.firstWhere(
      (cat) => cat.name.toLowerCase() == value.toLowerCase(),
      orElse: () => DestinationCategory.all,
    );
  }
}

/// Entity for discover destinations
class DiscoverDestination extends Equatable {
  final String id;
  final String name;
  final String? country;
  final String? countryCode;
  final double latitude;
  final double longitude;
  final List<String>? imageUrls; // Multiple images (use first for cards)
  final String? description;
  final DestinationCategory category;
  final double? rating; // 0-5 for Google Places, 0-10 for hidden_score
  final String? wikipediaLink;
  final String? kinds; // Raw API kinds
  
  // Additional fields for curated destinations
  final String? slug;
  final double? hiddenScore; // 0-10 scale for how underrated it is
  final String? bestSeason;
  final List<String>? travelTips;
  final String? difficulty; // 'Easy', 'Moderate', 'Challenging'
  final String? budgetLevel; // '$', '$$', '$$$'
  final int? visitDuration; // Recommended days
  final List<String>? tags;
  
  const DiscoverDestination({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
    this.countryCode,
    this.imageUrls,
    this.description,
    this.category = DestinationCategory.all,
    this.rating,
    this.wikipediaLink,
    this.kinds,
    this.slug,
    this.hiddenScore,
    this.bestSeason,
    this.travelTips,
    this.difficulty,
    this.budgetLevel,
    this.visitDuration,
    this.tags,
  });
  
  /// Get primary image URL (first from list) for destination cards
  String? get primaryImageUrl => imageUrls?.isNotEmpty == true ? imageUrls!.first : null;
  
  @override
  List<Object?> get props => [
    id,
    name,
    country,
    countryCode,
    latitude,
    longitude,
    imageUrls,
    description,
    category,
    rating,
    wikipediaLink,
    kinds,
    slug,
    hiddenScore,
    bestSeason,
    travelTips,
    difficulty,
    budgetLevel,
    visitDuration,
    tags,
  ];
  
  /// Create from Google Places API (Legacy) response
  factory DiscoverDestination.fromGooglePlaces(
    Map<String, dynamic> json,
    String? photoUrl,
  ) {
    // Extract location from geometry
    final geometry = json['geometry'] as Map<String, dynamic>?;
    final location = geometry?['location'] as Map<String, dynamic>?;
    final lat = (location?['lat'] ?? 0.0) as double;
    final lng = (location?['lng'] ?? 0.0) as double;
    
    // Extract types (categories)
    final types = json['types'] as List?;
    String? typeName;
    if (types != null && types.isNotEmpty) {
      typeName = types[0] as String?;
    }
    
    // Extract address components for country
    final addressComponents = json['address_components'] as List?;
    String? country;
    String? countryCode;
    if (addressComponents != null) {
      for (final component in addressComponents) {
        final types = component['types'] as List?;
        if (types != null && types.contains('country')) {
          country = component['long_name'];
          countryCode = component['short_name'];
          break;
        }
      }
    }
    
    // Extract rating (1-5 scale)
    final rating = (json['rating'] ?? 0.0) as double;
    
    // Use vicinity or formatted_address as description
    final description = json['vicinity'] ?? json['formatted_address'];
    
    return DiscoverDestination(
      id: json['place_id'] ?? '',
      name: json['name'] ?? 'Unknown',
      latitude: lat,
      longitude: lng,
      country: country,
      countryCode: countryCode,
      imageUrls: photoUrl != null ? [photoUrl] : null,
      description: description,
      kinds: typeName,
      rating: rating,
      category: _categorizeFromGoogleType(typeName),
    );
  }
  
  /// Create from Supabase database response
  factory DiscoverDestination.fromSupabase(Map<String, dynamic> json) {
    return DiscoverDestination(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'],
      description: json['description'],
      latitude: (json['latitude'] ?? 0.0) is int 
          ? (json['latitude'] as int).toDouble() 
          : (json['latitude'] ?? 0.0) as double,
      longitude: (json['longitude'] ?? 0.0) is int 
          ? (json['longitude'] as int).toDouble() 
          : (json['longitude'] ?? 0.0) as double,
      country: json['country'],
      countryCode: json['country_code'],
      category: DestinationCategory.fromString(json['category'] ?? 'all'),
      hiddenScore: (json['hidden_score'] ?? 0.0) is int 
          ? (json['hidden_score'] as int).toDouble() 
          : (json['hidden_score'] ?? 0.0) as double,
      bestSeason: json['best_season'],
      travelTips: json['travel_tips'] != null 
          ? List<String>.from(json['travel_tips'] as List)
          : null,
      difficulty: json['difficulty'],
      budgetLevel: json['budget_level'],
      visitDuration: json['visit_duration'],
      tags: json['tags'] != null 
          ? List<String>.from(json['tags'] as List)
          : null,
      imageUrls: json['image_urls'] != null 
          ? List<String>.from(json['image_urls'] as List)
          : null,
    );
  }
  
  /// Create from local JSON cache
  factory DiscoverDestination.fromLocalJson(Map<String, dynamic> json) {
    return DiscoverDestination(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'],
      description: json['description'],
      latitude: (json['latitude'] ?? 0.0) is int 
          ? (json['latitude'] as int).toDouble() 
          : (json['latitude'] ?? 0.0) as double,
      longitude: (json['longitude'] ?? 0.0) is int 
          ? (json['longitude'] as int).toDouble() 
          : (json['longitude'] ?? 0.0) as double,
      country: json['country'],
      countryCode: json['country_code'],
      category: DestinationCategory.fromString(json['category'] ?? 'all'),
      hiddenScore: (json['hidden_score'] ?? 0.0) is int 
          ? (json['hidden_score'] as int).toDouble() 
          : (json['hidden_score'] ?? 0.0) as double,
      bestSeason: json['best_season'],
      travelTips: json['travel_tips'] != null 
          ? List<String>.from(json['travel_tips'] as List)
          : null,
      difficulty: json['difficulty'],
      budgetLevel: json['budget_level'],
      visitDuration: json['visit_duration'],
      tags: json['tags'] != null 
          ? List<String>.from(json['tags'] as List)
          : null,
      imageUrls: json['image_urls'] != null 
          ? List<String>.from(json['image_urls'] as List)
          : null,
    );
  }
  
  /// Determine category from Google Place type
  static DestinationCategory _categorizeFromGoogleType(String? type) {
    if (type == null) return DestinationCategory.all;
    
    final typeLower = type.toLowerCase();
    
    // Natural places
    if (typeLower == 'park' || 
        typeLower == 'natural_feature' ||
        typeLower == 'campground') {
      return DestinationCategory.natural;
    }
    
    // Cultural places
    if (typeLower == 'museum' || 
        typeLower == 'art_gallery' ||
        typeLower == 'library') {
      return DestinationCategory.cultural;
    }
    
    // Architecture/Historic
    if (typeLower == 'church' || 
        typeLower == 'hindu_temple' ||
        typeLower == 'mosque' ||
        typeLower == 'synagogue' ||
        typeLower == 'place_of_worship' ||
        typeLower == 'tourist_attraction') {
      return DestinationCategory.architecture;
    }
    
    // Adventure/Recreation
    if (typeLower == 'amusement_park' || 
        typeLower == 'aquarium' ||
        typeLower == 'zoo' ||
        typeLower == 'stadium' ||
        typeLower == 'bowling_alley') {
      return DestinationCategory.adventure;
    }
    
    // Urban/City
    if (typeLower == 'shopping_mall' || 
        typeLower == 'restaurant' ||
        typeLower == 'cafe' ||
        typeLower == 'bar' ||
        typeLower == 'night_club' ||
        typeLower == 'point_of_interest') {
      return DestinationCategory.urban;
    }
    
    // Coastal (Google doesn't have explicit beach type, uses natural_feature)
    // Will be categorized under natural
    
    return DestinationCategory.all;
  }
  
  DiscoverDestination copyWith({
    String? id,
    String? name,
    String? country,
    String? countryCode,
    double? latitude,
    double? longitude,
    List<String>? imageUrls,
    String? description,
    DestinationCategory? category,
    double? rating,
    String? wikipediaLink,
    String? kinds,
    String? slug,
    double? hiddenScore,
    String? bestSeason,
    List<String>? travelTips,
    String? difficulty,
    String? budgetLevel,
    int? visitDuration,
    List<String>? tags,
  }) {
    return DiscoverDestination(
      id: id ?? this.id,
      name: name ?? this.name,
      country: country ?? this.country,
      countryCode: countryCode ?? this.countryCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrls: imageUrls ?? this.imageUrls,
      description: description ?? this.description,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      wikipediaLink: wikipediaLink ?? this.wikipediaLink,
      kinds: kinds ?? this.kinds,
      slug: slug ?? this.slug,
      hiddenScore: hiddenScore ?? this.hiddenScore,
      bestSeason: bestSeason ?? this.bestSeason,
      travelTips: travelTips ?? this.travelTips,
      difficulty: difficulty ?? this.difficulty,
      budgetLevel: budgetLevel ?? this.budgetLevel,
      visitDuration: visitDuration ?? this.visitDuration,
      tags: tags ?? this.tags,
    );
  }
}
