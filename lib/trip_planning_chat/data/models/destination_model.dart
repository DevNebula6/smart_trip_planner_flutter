/// Model for discover section destination cards
class DestinationModel {
  final String id;
  final String name;
  final String country;
  final String countryFlag;
  final String imageUrl;
  final List<String> activities;  // e.g., ['🥾 Hiking', '🛶 Kayaking']
  final String description;
  final int days;
  final String difficulty;  // e.g., '8/10'
  final String distance;  // e.g., '10km'
  final DestinationType type;

  DestinationModel({
    required this.id,
    required this.name,
    required this.country,
    required this.countryFlag,
    required this.imageUrl,
    required this.activities,
    required this.description,
    required this.days,
    required this.difficulty,
    required this.distance,
    required this.type,
  });
}

enum DestinationType {
  nature,
  architectural,
  cultural,
  adventure,
  urban,
  coastal,
}

/// Sample destinations for discover section
class DiscoverDestinations {
  static final List<DestinationModel> popular = [
    DestinationModel(
      id: '1',
      name: 'Nature Power',
      country: 'NORWAY',
      countryFlag: '🇳🇴',
      imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80',  // Norwegian forest
      activities: ['🥾 Hiking', '🛶 Kayaking', '🚴 Biking'],
      description: 'A real adventure where nature reveals its grandeur and beauty in its purest form',
      days: 7,
      difficulty: '8/10',
      distance: '10km',
      type: DestinationType.nature,
    ),
    DestinationModel(
      id: '2',
      name: 'Tyrolean Alps',
      country: 'AUSTRIA',
      countryFlag: '🇦🇹',
      imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80',  // Mountain landscape
      activities: ['⛷️ Skiing', '🥾 Hiking', '🏔️ Climbing'],
      description: 'Discovering the Magic of Austrian Mountains',
      days: 5,
      difficulty: '8/10',
      distance: '10km',
      type: DestinationType.nature,
    ),
    DestinationModel(
      id: '3',
      name: 'Heart of Norway\'s Majestic Forests',
      country: 'NORWAY',
      countryFlag: '🇳🇴',
      imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80',  // Forest path
      activities: ['🥾 Hiking', '📸 Photography', '🌲 Nature'],
      description: 'Explore pristine Nordic forests and tranquil landscapes',
      days: 10,
      difficulty: '6/10',
      distance: '30km',
      type: DestinationType.nature,
    ),
    DestinationModel(
      id: '4',
      name: 'The Sounds of Nature',
      country: 'BELGIUM',
      countryFlag: '🇧🇪',
      imageUrl: 'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?w=800&q=80',  // Forest trail
      activities: ['🥾 Hiking', '🎧 Nature Sounds', '🦅 Wildlife'],
      description: 'A real adventure where nature reveals its grandeur and beauty',
      days: 7,
      difficulty: '7/10',
      distance: '4km',
      type: DestinationType.nature,
    ),
  ];
  
  static final List<DestinationModel> architectural = [
    DestinationModel(
      id: '5',
      name: 'Paris Romance',
      country: 'FRANCE',
      countryFlag: '🇫🇷',
      imageUrl: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=800&q=80',  // Eiffel Tower
      activities: ['🗼 Landmarks', '🎨 Museums', '🍷 Gastronomy'],
      description: 'Experience the charm and elegance of the City of Light',
      days: 5,
      difficulty: '3/10',
      distance: '15km',
      type: DestinationType.architectural,
    ),
    DestinationModel(
      id: '6',
      name: 'Ancient Rome',
      country: 'ITALY',
      countryFlag: '🇮🇹',
      imageUrl: 'https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=800&q=80',  // Roman Colosseum
      activities: ['🏛️ History', '🍝 Cuisine', '🏺 Museums'],
      description: 'Walk through millennia of history in the Eternal City',
      days: 6,
      difficulty: '4/10',
      distance: '20km',
      type: DestinationType.architectural,
    ),
  ];
  
  static final List<DestinationModel> adventure = [
    DestinationModel(
      id: '7',
      name: 'Iceland Expedition',
      country: 'ICELAND',
      countryFlag: '🇮🇸',
      imageUrl: 'https://images.unsplash.com/photo-1504893524553-b855bce32c67?w=800&q=80',  // Iceland landscape
      activities: ['🌋 Volcanoes', '❄️ Glaciers', '♨️ Hot Springs'],
      description: 'Land of fire and ice - an unforgettable adventure',
      days: 8,
      difficulty: '7/10',
      distance: '50km',
      type: DestinationType.adventure,
    ),
  ];
}
