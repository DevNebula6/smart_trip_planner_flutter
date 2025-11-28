/// **Booking Models - Transport, Stays & Budget**
/// 
/// Extended models for itinerary booking features:
/// - Transport (flights, trains, buses)
/// - Stays (hotels, hostels, rentals)
/// - Budget tracking and breakdown
/// 
/// Designed to work with:
/// - Google Places API (location verification)
/// - Booking.com RapidAPI (hotels)
/// - Sky-Scrapper RapidAPI (flights)
library;

import 'package:equatable/equatable.dart';

// ============================================================================
// TRANSPORT MODELS
// ============================================================================

/// Transport type enum
enum TransportType {
  flight,
  train,
  bus,
  ferry,
  car,
  taxi,
  metro,
  other;

  String get displayName {
    switch (this) {
      case TransportType.flight:
        return 'Flight';
      case TransportType.train:
        return 'Train';
      case TransportType.bus:
        return 'Bus';
      case TransportType.ferry:
        return 'Ferry';
      case TransportType.car:
        return 'Car Rental';
      case TransportType.taxi:
        return 'Taxi/Cab';
      case TransportType.metro:
        return 'Metro/Subway';
      case TransportType.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case TransportType.flight:
        return '✈️';
      case TransportType.train:
        return '🚄';
      case TransportType.bus:
        return '🚌';
      case TransportType.ferry:
        return '⛴️';
      case TransportType.car:
        return '🚗';
      case TransportType.taxi:
        return '🚕';
      case TransportType.metro:
        return '🚇';
      case TransportType.other:
        return '🚐';
    }
  }
}

/// Transport segment (single leg of journey)
class TransportSegment extends Equatable {
  final String id;
  final TransportType type;
  final String origin;
  final String originCode; // Airport/Station code (DEL, KIX, etc.)
  final String destination;
  final String destinationCode;
  final String departureTime; // ISO 8601 datetime
  final String arrivalTime;
  final String? duration; // "2h 30m"
  final String? carrier; // Airline/Train operator name
  final String? carrierLogo; // URL to carrier logo
  final String? flightNumber; // AI123, 12345 etc.
  final double? price;
  final String currency;
  final String? bookingUrl; // Deep link for booking
  final String? cabinClass; // Economy, Business, First
  final int? stops; // 0 = direct, 1 = 1 stop, etc.
  final List<String>? amenities; // WiFi, Meals, etc.
  final bool isBooked;
  final String? bookingReference;

  const TransportSegment({
    required this.id,
    required this.type,
    required this.origin,
    this.originCode = '',
    required this.destination,
    this.destinationCode = '',
    required this.departureTime,
    required this.arrivalTime,
    this.duration,
    this.carrier,
    this.carrierLogo,
    this.flightNumber,
    this.price,
    this.currency = 'INR',
    this.bookingUrl,
    this.cabinClass,
    this.stops,
    this.amenities,
    this.isBooked = false,
    this.bookingReference,
  });

  @override
  List<Object?> get props => [id, type, origin, destination, departureTime];

  /// Parse departure DateTime
  DateTime? get departureDatetime {
    try {
      return DateTime.parse(departureTime);
    } catch (_) {
      return null;
    }
  }

  /// Parse arrival DateTime
  DateTime? get arrivalDatetime {
    try {
      return DateTime.parse(arrivalTime);
    } catch (_) {
      return null;
    }
  }

  /// Get formatted departure time (12-hour)
  String get formattedDepartureTime {
    final dt = departureDatetime;
    if (dt == null) return departureTime;
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    if (hour == 0) return '12:$minute AM';
    if (hour < 12) return '$hour:$minute AM';
    if (hour == 12) return '12:$minute PM';
    return '${hour - 12}:$minute PM';
  }

  /// Get formatted arrival time (12-hour)
  String get formattedArrivalTime {
    final dt = arrivalDatetime;
    if (dt == null) return arrivalTime;
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    if (hour == 0) return '12:$minute AM';
    if (hour < 12) return '$hour:$minute AM';
    if (hour == 12) return '12:$minute PM';
    return '${hour - 12}:$minute PM';
  }

  /// Get formatted price
  String get formattedPrice {
    if (price == null) return 'Price N/A';
    final symbol = currency == 'INR' ? '₹' : currency == 'USD' ? '\$' : currency;
    return '$symbol${price!.toStringAsFixed(0)}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'origin': origin,
      'originCode': originCode,
      'destination': destination,
      'destinationCode': destinationCode,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'duration': duration,
      'carrier': carrier,
      'carrierLogo': carrierLogo,
      'flightNumber': flightNumber,
      'price': price,
      'currency': currency,
      'bookingUrl': bookingUrl,
      'cabinClass': cabinClass,
      'stops': stops,
      'amenities': amenities,
      'isBooked': isBooked,
      'bookingReference': bookingReference,
    };
  }

  factory TransportSegment.fromJson(Map<String, dynamic> json) {
    return TransportSegment(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: TransportType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransportType.other,
      ),
      origin: json['origin'] as String? ?? '',
      originCode: json['originCode'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
      destinationCode: json['destinationCode'] as String? ?? '',
      departureTime: json['departureTime'] as String? ?? '',
      arrivalTime: json['arrivalTime'] as String? ?? '',
      duration: json['duration'] as String?,
      carrier: json['carrier'] as String?,
      carrierLogo: json['carrierLogo'] as String?,
      flightNumber: json['flightNumber'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'INR',
      bookingUrl: json['bookingUrl'] as String?,
      cabinClass: json['cabinClass'] as String?,
      stops: json['stops'] as int?,
      amenities: (json['amenities'] as List<dynamic>?)?.cast<String>(),
      isBooked: json['isBooked'] as bool? ?? false,
      bookingReference: json['bookingReference'] as String?,
    );
  }

  TransportSegment copyWith({
    String? id,
    TransportType? type,
    String? origin,
    String? originCode,
    String? destination,
    String? destinationCode,
    String? departureTime,
    String? arrivalTime,
    String? duration,
    String? carrier,
    String? carrierLogo,
    String? flightNumber,
    double? price,
    String? currency,
    String? bookingUrl,
    String? cabinClass,
    int? stops,
    List<String>? amenities,
    bool? isBooked,
    String? bookingReference,
  }) {
    return TransportSegment(
      id: id ?? this.id,
      type: type ?? this.type,
      origin: origin ?? this.origin,
      originCode: originCode ?? this.originCode,
      destination: destination ?? this.destination,
      destinationCode: destinationCode ?? this.destinationCode,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      duration: duration ?? this.duration,
      carrier: carrier ?? this.carrier,
      carrierLogo: carrierLogo ?? this.carrierLogo,
      flightNumber: flightNumber ?? this.flightNumber,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      bookingUrl: bookingUrl ?? this.bookingUrl,
      cabinClass: cabinClass ?? this.cabinClass,
      stops: stops ?? this.stops,
      amenities: amenities ?? this.amenities,
      isBooked: isBooked ?? this.isBooked,
      bookingReference: bookingReference ?? this.bookingReference,
    );
  }
}

/// Complete transport plan for an itinerary
class TransportPlan extends Equatable {
  final TransportSegment? outbound; // Main outbound journey
  final TransportSegment? returnTrip; // Main return journey
  final List<TransportSegment> interCity; // Between cities during trip
  final LocalTransportInfo? localTransport; // Daily local transport

  const TransportPlan({
    this.outbound,
    this.returnTrip,
    this.interCity = const [],
    this.localTransport,
  });

  @override
  List<Object?> get props => [outbound, returnTrip, interCity, localTransport];

  /// Get total transport cost
  double get totalCost {
    double total = 0;
    if (outbound?.price != null) total += outbound!.price!;
    if (returnTrip?.price != null) total += returnTrip!.price!;
    for (final segment in interCity) {
      if (segment.price != null) total += segment.price!;
    }
    if (localTransport?.estimatedTotalCost != null) {
      total += localTransport!.estimatedTotalCost!;
    }
    return total;
  }

  /// Check if all transport is booked
  bool get isFullyBooked {
    if (outbound != null && !outbound!.isBooked) return false;
    if (returnTrip != null && !returnTrip!.isBooked) return false;
    for (final segment in interCity) {
      if (!segment.isBooked) return false;
    }
    return true;
  }

  /// Get all segments as a list
  List<TransportSegment> get allSegments {
    return [
      if (outbound != null) outbound!,
      ...interCity,
      if (returnTrip != null) returnTrip!,
    ];
  }

  Map<String, dynamic> toJson() {
    return {
      'outbound': outbound?.toJson(),
      'return': returnTrip?.toJson(),
      'interCity': interCity.map((s) => s.toJson()).toList(),
      'localTransport': localTransport?.toJson(),
    };
  }

  factory TransportPlan.fromJson(Map<String, dynamic> json) {
    return TransportPlan(
      outbound: json['outbound'] != null
          ? TransportSegment.fromJson(json['outbound'] as Map<String, dynamic>)
          : null,
      returnTrip: json['return'] != null
          ? TransportSegment.fromJson(json['return'] as Map<String, dynamic>)
          : null,
      interCity: (json['interCity'] as List<dynamic>?)
              ?.map((e) => TransportSegment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      localTransport: json['localTransport'] != null
          ? LocalTransportInfo.fromJson(json['localTransport'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Local transport information (metro, buses, taxis)
class LocalTransportInfo extends Equatable {
  final String? recommendation; // "Get Kyoto Bus Day Pass"
  final double? estimatedDailyCost;
  final double? estimatedTotalCost;
  final String currency;
  final List<String>? tips;
  final String? passName; // "JR Pass", "Metro Card"
  final String? passUrl; // URL to buy pass

  const LocalTransportInfo({
    this.recommendation,
    this.estimatedDailyCost,
    this.estimatedTotalCost,
    this.currency = 'INR',
    this.tips,
    this.passName,
    this.passUrl,
  });

  @override
  List<Object?> get props => [recommendation, estimatedDailyCost];

  Map<String, dynamic> toJson() {
    return {
      'recommendation': recommendation,
      'estimatedDailyCost': estimatedDailyCost,
      'estimatedTotalCost': estimatedTotalCost,
      'currency': currency,
      'tips': tips,
      'passName': passName,
      'passUrl': passUrl,
    };
  }

  factory LocalTransportInfo.fromJson(Map<String, dynamic> json) {
    return LocalTransportInfo(
      recommendation: json['recommendation'] as String?,
      estimatedDailyCost: (json['estimatedDailyCost'] as num?)?.toDouble(),
      estimatedTotalCost: (json['estimatedTotalCost'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'INR',
      tips: (json['tips'] as List<dynamic>?)?.cast<String>(),
      passName: json['passName'] as String?,
      passUrl: json['passUrl'] as String?,
    );
  }
}

// ============================================================================
// STAYS/ACCOMMODATION MODELS
// ============================================================================

/// Stay type enum
enum StayType {
  hotel,
  hostel,
  apartment,
  resort,
  guesthouse,
  villa,
  homestay,
  other;

  String get displayName {
    switch (this) {
      case StayType.hotel:
        return 'Hotel';
      case StayType.hostel:
        return 'Hostel';
      case StayType.apartment:
        return 'Apartment';
      case StayType.resort:
        return 'Resort';
      case StayType.guesthouse:
        return 'Guesthouse';
      case StayType.villa:
        return 'Villa';
      case StayType.homestay:
        return 'Homestay';
      case StayType.other:
        return 'Accommodation';
    }
  }

  String get icon {
    switch (this) {
      case StayType.hotel:
        return '🏨';
      case StayType.hostel:
        return '🛏️';
      case StayType.apartment:
        return '🏠';
      case StayType.resort:
        return '🏝️';
      case StayType.guesthouse:
        return '🏡';
      case StayType.villa:
        return '🏛️';
      case StayType.homestay:
        return '🏘️';
      case StayType.other:
        return '🏢';
    }
  }
}

/// Single accommodation/stay
class Stay extends Equatable {
  final String id;
  final String name;
  final StayType type;
  final String address;
  final String location; // "lat,lng"
  final String? city;
  final String checkIn; // YYYY-MM-DD
  final String checkOut; // YYYY-MM-DD
  final int nights;
  final double? pricePerNight;
  final double? totalPrice;
  final String currency;
  final double? rating; // 0-10 or 0-5
  final int? reviewCount;
  final List<String>? imageUrls;
  final String? thumbnailUrl;
  final List<String>? amenities;
  final String? roomType;
  final bool freeCancellation;
  final bool breakfastIncluded;
  final String? bookingUrl;
  final bool isBooked;
  final String? bookingReference;
  final String? nearbyAttraction; // "5 min walk to Fushimi Inari"

  const Stay({
    required this.id,
    required this.name,
    this.type = StayType.hotel,
    required this.address,
    required this.location,
    this.city,
    required this.checkIn,
    required this.checkOut,
    required this.nights,
    this.pricePerNight,
    this.totalPrice,
    this.currency = 'INR',
    this.rating,
    this.reviewCount,
    this.imageUrls,
    this.thumbnailUrl,
    this.amenities,
    this.roomType,
    this.freeCancellation = false,
    this.breakfastIncluded = false,
    this.bookingUrl,
    this.isBooked = false,
    this.bookingReference,
    this.nearbyAttraction,
  });

  @override
  List<Object?> get props => [id, name, checkIn, checkOut];

  /// Parse latitude from location
  double? get latitude {
    try {
      final parts = location.split(',');
      return double.parse(parts[0]);
    } catch (_) {
      return null;
    }
  }

  /// Parse longitude from location
  double? get longitude {
    try {
      final parts = location.split(',');
      return double.parse(parts[1]);
    } catch (_) {
      return null;
    }
  }

  /// Get formatted price per night
  String get formattedPricePerNight {
    if (pricePerNight == null) return 'Price N/A';
    final symbol = currency == 'INR' ? '₹' : currency == 'USD' ? '\$' : currency;
    return '$symbol${pricePerNight!.toStringAsFixed(0)}/night';
  }

  /// Get formatted total price
  String get formattedTotalPrice {
    if (totalPrice == null) return 'Total N/A';
    final symbol = currency == 'INR' ? '₹' : currency == 'USD' ? '\$' : currency;
    return '$symbol${totalPrice!.toStringAsFixed(0)}';
  }

  /// Get rating display (convert to 5-star if needed)
  String get ratingDisplay {
    if (rating == null) return 'No rating';
    // If rating is out of 10, convert to 5
    final normalizedRating = rating! > 5 ? rating! / 2 : rating!;
    return '${normalizedRating.toStringAsFixed(1)} ★';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'address': address,
      'location': location,
      'city': city,
      'checkIn': checkIn,
      'checkOut': checkOut,
      'nights': nights,
      'pricePerNight': pricePerNight,
      'totalPrice': totalPrice,
      'currency': currency,
      'rating': rating,
      'reviewCount': reviewCount,
      'imageUrls': imageUrls,
      'thumbnailUrl': thumbnailUrl,
      'amenities': amenities,
      'roomType': roomType,
      'freeCancellation': freeCancellation,
      'breakfastIncluded': breakfastIncluded,
      'bookingUrl': bookingUrl,
      'isBooked': isBooked,
      'bookingReference': bookingReference,
      'nearbyAttraction': nearbyAttraction,
    };
  }

  factory Stay.fromJson(Map<String, dynamic> json) {
    return Stay(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? 'Unknown Hotel',
      type: StayType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => StayType.hotel,
      ),
      address: json['address'] as String? ?? '',
      location: json['location'] as String? ?? '0,0',
      city: json['city'] as String?,
      checkIn: json['checkIn'] as String? ?? '',
      checkOut: json['checkOut'] as String? ?? '',
      nights: json['nights'] as int? ?? 1,
      pricePerNight: (json['pricePerNight'] as num?)?.toDouble(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'INR',
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: json['reviewCount'] as int?,
      imageUrls: (json['imageUrls'] as List<dynamic>?)?.cast<String>(),
      thumbnailUrl: json['thumbnailUrl'] as String?,
      amenities: (json['amenities'] as List<dynamic>?)?.cast<String>(),
      roomType: json['roomType'] as String?,
      freeCancellation: json['freeCancellation'] as bool? ?? false,
      breakfastIncluded: json['breakfastIncluded'] as bool? ?? false,
      bookingUrl: json['bookingUrl'] as String?,
      isBooked: json['isBooked'] as bool? ?? false,
      bookingReference: json['bookingReference'] as String?,
      nearbyAttraction: json['nearbyAttraction'] as String?,
    );
  }

  Stay copyWith({
    String? id,
    String? name,
    StayType? type,
    String? address,
    String? location,
    String? city,
    String? checkIn,
    String? checkOut,
    int? nights,
    double? pricePerNight,
    double? totalPrice,
    String? currency,
    double? rating,
    int? reviewCount,
    List<String>? imageUrls,
    String? thumbnailUrl,
    List<String>? amenities,
    String? roomType,
    bool? freeCancellation,
    bool? breakfastIncluded,
    String? bookingUrl,
    bool? isBooked,
    String? bookingReference,
    String? nearbyAttraction,
  }) {
    return Stay(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      address: address ?? this.address,
      location: location ?? this.location,
      city: city ?? this.city,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      nights: nights ?? this.nights,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      totalPrice: totalPrice ?? this.totalPrice,
      currency: currency ?? this.currency,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrls: imageUrls ?? this.imageUrls,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      amenities: amenities ?? this.amenities,
      roomType: roomType ?? this.roomType,
      freeCancellation: freeCancellation ?? this.freeCancellation,
      breakfastIncluded: breakfastIncluded ?? this.breakfastIncluded,
      bookingUrl: bookingUrl ?? this.bookingUrl,
      isBooked: isBooked ?? this.isBooked,
      bookingReference: bookingReference ?? this.bookingReference,
      nearbyAttraction: nearbyAttraction ?? this.nearbyAttraction,
    );
  }
}

/// Complete stays plan for an itinerary
class StaysPlan extends Equatable {
  final List<Stay> stays;
  final String? aiRecommendation; // "Stay near Gion for best access"

  const StaysPlan({
    this.stays = const [],
    this.aiRecommendation,
  });

  @override
  List<Object?> get props => [stays];

  /// Get total accommodation cost
  double get totalCost {
    return stays.fold(0.0, (sum, stay) => sum + (stay.totalPrice ?? 0));
  }

  /// Get total nights
  int get totalNights {
    return stays.fold(0, (sum, stay) => sum + stay.nights);
  }

  /// Check if all stays are booked
  bool get isFullyBooked {
    return stays.isNotEmpty && stays.every((s) => s.isBooked);
  }

  Map<String, dynamic> toJson() {
    return {
      'stays': stays.map((s) => s.toJson()).toList(),
      'aiRecommendation': aiRecommendation,
    };
  }

  factory StaysPlan.fromJson(Map<String, dynamic> json) {
    return StaysPlan(
      stays: (json['stays'] as List<dynamic>?)
              ?.map((e) => Stay.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      aiRecommendation: json['aiRecommendation'] as String?,
    );
  }
}

// ============================================================================
// BUDGET MODELS
// ============================================================================

/// Expense category enum
enum ExpenseCategory {
  transport,
  accommodation,
  food,
  activities,
  shopping,
  misc;

  String get displayName {
    switch (this) {
      case ExpenseCategory.transport:
        return 'Transport';
      case ExpenseCategory.accommodation:
        return 'Accommodation';
      case ExpenseCategory.food:
        return 'Food & Dining';
      case ExpenseCategory.activities:
        return 'Activities';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.misc:
        return 'Miscellaneous';
    }
  }

  String get icon {
    switch (this) {
      case ExpenseCategory.transport:
        return '✈️';
      case ExpenseCategory.accommodation:
        return '🏨';
      case ExpenseCategory.food:
        return '🍽️';
      case ExpenseCategory.activities:
        return '🎫';
      case ExpenseCategory.shopping:
        return '🛍️';
      case ExpenseCategory.misc:
        return '📦';
    }
  }

  /// Get chart color for this category
  int get colorValue {
    switch (this) {
      case ExpenseCategory.transport:
        return 0xFF4CAF50; // Green
      case ExpenseCategory.accommodation:
        return 0xFF2196F3; // Blue
      case ExpenseCategory.food:
        return 0xFFFF9800; // Orange
      case ExpenseCategory.activities:
        return 0xFF9C27B0; // Purple
      case ExpenseCategory.shopping:
        return 0xFFE91E63; // Pink
      case ExpenseCategory.misc:
        return 0xFF607D8B; // Blue Grey
    }
  }
}

/// Budget breakdown by category
class BudgetBreakdown extends Equatable {
  final double transport;
  final double accommodation;
  final double food;
  final double activities;
  final double shopping;
  final double misc;

  const BudgetBreakdown({
    this.transport = 0,
    this.accommodation = 0,
    this.food = 0,
    this.activities = 0,
    this.shopping = 0,
    this.misc = 0,
  });

  @override
  List<Object?> get props => [transport, accommodation, food, activities, shopping, misc];

  double get total => transport + accommodation + food + activities + shopping + misc;

  /// Get as map for iteration
  Map<ExpenseCategory, double> get asMap => {
        ExpenseCategory.transport: transport,
        ExpenseCategory.accommodation: accommodation,
        ExpenseCategory.food: food,
        ExpenseCategory.activities: activities,
        ExpenseCategory.shopping: shopping,
        ExpenseCategory.misc: misc,
      };

  /// Get percentage for a category
  double percentageFor(ExpenseCategory category) {
    if (total == 0) return 0;
    return (asMap[category] ?? 0) / total * 100;
  }

  Map<String, dynamic> toJson() {
    return {
      'transport': transport,
      'accommodation': accommodation,
      'food': food,
      'activities': activities,
      'shopping': shopping,
      'misc': misc,
    };
  }

  factory BudgetBreakdown.fromJson(Map<String, dynamic> json) {
    return BudgetBreakdown(
      transport: (json['transport'] as num?)?.toDouble() ?? 0,
      accommodation: (json['accommodation'] as num?)?.toDouble() ?? 0,
      food: (json['food'] as num?)?.toDouble() ?? 0,
      activities: (json['activities'] as num?)?.toDouble() ?? 0,
      shopping: (json['shopping'] as num?)?.toDouble() ?? 0,
      misc: (json['misc'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Single expense item
class ExpenseItem extends Equatable {
  final String id;
  final ExpenseCategory category;
  final String description;
  final double amount;
  final String currency;
  final String date; // YYYY-MM-DD
  final bool isPaid;
  final String? notes;

  const ExpenseItem({
    required this.id,
    required this.category,
    required this.description,
    required this.amount,
    this.currency = 'INR',
    required this.date,
    this.isPaid = false,
    this.notes,
  });

  @override
  List<Object?> get props => [id, category, amount, date];

  String get formattedAmount {
    final symbol = currency == 'INR' ? '₹' : currency == 'USD' ? '\$' : currency;
    return '$symbol${amount.toStringAsFixed(0)}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category.name,
      'description': description,
      'amount': amount,
      'currency': currency,
      'date': date,
      'isPaid': isPaid,
      'notes': notes,
    };
  }

  factory ExpenseItem.fromJson(Map<String, dynamic> json) {
    return ExpenseItem(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      category: ExpenseCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ExpenseCategory.misc,
      ),
      description: json['description'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'INR',
      date: json['date'] as String? ?? '',
      isPaid: json['isPaid'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }
}

/// Complete budget plan for an itinerary
class BudgetPlan extends Equatable {
  final double? totalBudget; // User's total budget
  final String currency;
  final BudgetBreakdown estimated; // AI-estimated breakdown
  final BudgetBreakdown actual; // Actual spent (from bookings + manual)
  final List<ExpenseItem> expenses; // Manual expense entries
  final double? perDayAverage;
  final List<String>? savingTips; // AI-generated tips

  const BudgetPlan({
    this.totalBudget,
    this.currency = 'INR',
    this.estimated = const BudgetBreakdown(),
    this.actual = const BudgetBreakdown(),
    this.expenses = const [],
    this.perDayAverage,
    this.savingTips,
  });

  @override
  List<Object?> get props => [totalBudget, estimated, actual, expenses];

  /// Get total estimated cost
  double get totalEstimated => estimated.total;

  /// Get total actual spent
  double get totalSpent => actual.total + expenses.fold(0.0, (sum, e) => sum + e.amount);

  /// Get remaining budget
  double get remaining => (totalBudget ?? 0) - totalSpent;

  /// Is over budget?
  bool get isOverBudget => totalBudget != null && totalSpent > totalBudget!;

  /// Get budget utilization percentage
  double get utilizationPercentage {
    if (totalBudget == null || totalBudget == 0) return 0;
    return (totalSpent / totalBudget!) * 100;
  }

  /// Get formatted total budget
  String get formattedTotalBudget {
    if (totalBudget == null) return 'No budget set';
    final symbol = currency == 'INR' ? '₹' : currency == 'USD' ? '\$' : currency;
    return '$symbol${totalBudget!.toStringAsFixed(0)}';
  }

  /// Get formatted remaining
  String get formattedRemaining {
    final symbol = currency == 'INR' ? '₹' : currency == 'USD' ? '\$' : currency;
    return '$symbol${remaining.toStringAsFixed(0)}';
  }

  Map<String, dynamic> toJson() {
    return {
      'totalBudget': totalBudget,
      'currency': currency,
      'estimated': estimated.toJson(),
      'actual': actual.toJson(),
      'expenses': expenses.map((e) => e.toJson()).toList(),
      'perDayAverage': perDayAverage,
      'savingTips': savingTips,
    };
  }

  factory BudgetPlan.fromJson(Map<String, dynamic> json) {
    return BudgetPlan(
      totalBudget: (json['totalBudget'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'INR',
      estimated: json['estimated'] != null
          ? BudgetBreakdown.fromJson(json['estimated'] as Map<String, dynamic>)
          : const BudgetBreakdown(),
      actual: json['actual'] != null
          ? BudgetBreakdown.fromJson(json['actual'] as Map<String, dynamic>)
          : const BudgetBreakdown(),
      expenses: (json['expenses'] as List<dynamic>?)
              ?.map((e) => ExpenseItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      perDayAverage: (json['perDayAverage'] as num?)?.toDouble(),
      savingTips: (json['savingTips'] as List<dynamic>?)?.cast<String>(),
    );
  }

  BudgetPlan copyWith({
    double? totalBudget,
    String? currency,
    BudgetBreakdown? estimated,
    BudgetBreakdown? actual,
    List<ExpenseItem>? expenses,
    double? perDayAverage,
    List<String>? savingTips,
  }) {
    return BudgetPlan(
      totalBudget: totalBudget ?? this.totalBudget,
      currency: currency ?? this.currency,
      estimated: estimated ?? this.estimated,
      actual: actual ?? this.actual,
      expenses: expenses ?? this.expenses,
      perDayAverage: perDayAverage ?? this.perDayAverage,
      savingTips: savingTips ?? this.savingTips,
    );
  }
}

// ============================================================================
// ENHANCED PLACE MODEL (for Google Places data)
// ============================================================================

/// Enhanced place data from Google Places API
class PlaceDetails extends Equatable {
  final String placeId;
  final String name;
  final String address;
  final String location; // "lat,lng"
  final double? rating;
  final int? userRatingsTotal;
  final String? phoneNumber;
  final String? website;
  final List<String>? photoUrls;
  final String? priceLevel; // "$", "$$", "$$$", "$$$$"
  final Map<String, String>? openingHours; // {"Monday": "9:00 AM - 5:00 PM"}
  final bool? isOpen;
  final List<String>? types; // ["restaurant", "food"]

  const PlaceDetails({
    required this.placeId,
    required this.name,
    required this.address,
    required this.location,
    this.rating,
    this.userRatingsTotal,
    this.phoneNumber,
    this.website,
    this.photoUrls,
    this.priceLevel,
    this.openingHours,
    this.isOpen,
    this.types,
  });

  @override
  List<Object?> get props => [placeId, name, location];

  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'name': name,
      'address': address,
      'location': location,
      'rating': rating,
      'userRatingsTotal': userRatingsTotal,
      'phoneNumber': phoneNumber,
      'website': website,
      'photoUrls': photoUrls,
      'priceLevel': priceLevel,
      'openingHours': openingHours,
      'isOpen': isOpen,
      'types': types,
    };
  }

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    return PlaceDetails(
      placeId: json['placeId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      location: json['location'] as String? ?? '0,0',
      rating: (json['rating'] as num?)?.toDouble(),
      userRatingsTotal: json['userRatingsTotal'] as int?,
      phoneNumber: json['phoneNumber'] as String?,
      website: json['website'] as String?,
      photoUrls: (json['photoUrls'] as List<dynamic>?)?.cast<String>(),
      priceLevel: json['priceLevel'] as String?,
      openingHours: (json['openingHours'] as Map<String, dynamic>?)?.cast<String, String>(),
      isOpen: json['isOpen'] as bool?,
      types: (json['types'] as List<dynamic>?)?.cast<String>(),
    );
  }
}
