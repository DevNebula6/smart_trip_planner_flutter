/// **AI Tools Manager for Gemini**
/// 
/// Manages all AI tools for function calling:
/// - Web Search (existing)
/// - Google Places (location verification)
/// - Flight Search (transport booking)
/// - Hotel Search (accommodation booking)
/// 
/// Provides unified interface for tool registration and handling.
library;

import 'package:google_generative_ai/google_generative_ai.dart';
import 'web_search_service.dart';
import 'google_places_tool.dart';
import 'booking_com_tool.dart';
import 'flight_search_tool.dart';
import '../../core/utils/helpers.dart';

/// Manager for all AI function-calling tools
class AIToolsManager {
  // Tool instances
  final WebSearchTool? webSearchTool;
  final GooglePlacesTool? placesTool;
  final FlightSearchTool? flightTool;
  final BookingComTool? hotelTool;

  AIToolsManager({
    this.webSearchTool,
    this.placesTool,
    this.flightTool,
    this.hotelTool,
  });

  /// Factory constructor with API keys
  factory AIToolsManager.withKeys({
    String? googleSearchApiKey,
    String? googleSearchEngineId,
    String? googlePlacesApiKey,
    String? rapidApiKey,
  }) {
    // Create tools based on available API keys
    final webSearch = _createWebSearchTool(
      googleSearchApiKey: googleSearchApiKey,
      googleSearchEngineId: googleSearchEngineId,
    );
    
    final places = googlePlacesApiKey != null && googlePlacesApiKey.isNotEmpty
        ? GooglePlacesTool(apiKey: googlePlacesApiKey)
        : null;
    
    final flights = rapidApiKey != null && rapidApiKey.isNotEmpty
        ? FlightSearchTool(rapidApiKey: rapidApiKey)
        : null;
    
    final hotels = rapidApiKey != null && rapidApiKey.isNotEmpty
        ? BookingComTool(rapidApiKey: rapidApiKey)
        : null;
    
    // Log initialization status
    Logger.d('AIToolsManager initialization:', tag: 'AITools');
    Logger.d('  - WebSearch: ${webSearch != null ? "✓ ready" : "✗ missing GOOGLE_SEARCH_API_KEY/ENGINE_ID"}', tag: 'AITools');
    Logger.d('  - Places: ${places != null ? "✓ ready" : "✗ missing GOOGLE_PLACES_API_KEY"}', tag: 'AITools');
    Logger.d('  - Flights/Transport: ${flights != null ? "✓ ready" : "✗ missing RAPIDAPI_KEY"}', tag: 'AITools');
    Logger.d('  - Hotels: ${hotels != null ? "✓ ready" : "✗ missing RAPIDAPI_KEY"}', tag: 'AITools');
    
    return AIToolsManager(
      webSearchTool: webSearch,
      placesTool: places,
      flightTool: flights,
      hotelTool: hotels,
    );
  }

  /// Check if any tools are available
  bool get hasTools =>
      webSearchTool != null ||
      placesTool != null ||
      flightTool != null ||
      hotelTool != null;

  /// Get available tool names
  List<String> get availableTools {
    final tools = <String>[];
    if (webSearchTool != null) tools.add('webSearch');
    if (placesTool != null) tools.add('searchPlaces');
    if (flightTool != null) {
      tools.add('searchFlights');
      tools.add('searchTrains');
      tools.add('searchBuses');
      tools.add('searchTaxis');
      tools.add('searchCarRentals');
      tools.add('searchFerries');
      tools.add('searchLocalTransport');
    }
    if (hotelTool != null) tools.add('searchHotels');
    return tools;
  }

  /// Create Gemini Tool declarations
  List<Tool> createToolDeclarations() {
    final functionDeclarations = <FunctionDeclaration>[];

    // Web Search Tool
    if (webSearchTool != null) {
      functionDeclarations.add(
      FunctionDeclaration(
        'webSearch',
        'Search the web for real-time information about travel destinations, restaurants, events, attractions, transportations. Use for current pricing, hours, reviews.',
        Schema(
          SchemaType.object,
          properties: {
            'query': Schema(
              SchemaType.string,
              description: 'The search query. Be specific with location and dates.',
            ),
            'maxResults': Schema(
              SchemaType.integer,
              description: 'Maximum results to return (default: 8, max: 13)',
            ),
          },
          requiredProperties: ['query'],
        ),
      ));
    }

    // Google Places Tool
    if (placesTool != null) {
      functionDeclarations.add(FunctionDeclaration(
        'searchPlaces',
        'Search for verified places using Google Places. Returns accurate coordinates, ratings, photos, opening hours. Use to verify restaurant/attraction details.',
        Schema(
          SchemaType.object,
          properties: {
            'query': Schema(
              SchemaType.string,
              description: 'Place name or search query (e.g., "Fushimi Inari Shrine", "restaurants in Kyoto")',
            ),
            'location': Schema(
              SchemaType.string,
              description: 'Center point as "lat,lng" for nearby search (optional)',
            ),
            'radius': Schema(
              SchemaType.integer,
              description: 'Search radius in meters (default: 5000)',
            ),
            'type': Schema(
              SchemaType.string,
              description: 'Place type: restaurant, hotel, tourist_attraction, etc.',
            ),
          },
          requiredProperties: ['query'],
        ),
      ));
    }

    // Flight Search Tool
    if (flightTool != null) {
      functionDeclarations.add(FunctionDeclaration(
        'searchFlights',
        'Search for flights between cities. Returns real prices, carriers, and booking links. Use for outbound and return flight suggestions.',
        Schema(
          SchemaType.object,
          properties: {
            'origin': Schema(
              SchemaType.string,
              description: 'Origin city or airport code (e.g., "Delhi", "DEL", "New Delhi")',
            ),
            'destination': Schema(
              SchemaType.string,
              description: 'Destination city or airport code (e.g., "Osaka", "KIX", "Tokyo")',
            ),
            'departureDate': Schema(
              SchemaType.string,
              description: 'Departure date in YYYY-MM-DD format',
            ),
            'returnDate': Schema(
              SchemaType.string,
              description: 'Return date in YYYY-MM-DD format (optional for one-way)',
            ),
            'adults': Schema(
              SchemaType.integer,
              description: 'Number of adult passengers (default: 1)',
            ),
            'cabinClass': Schema(
              SchemaType.string,
              description: 'Cabin class: economy, premium_economy, business, first (default: economy)',
            ),
            'currency': Schema(
              SchemaType.string,
              description: 'Currency code: INR, USD, EUR, etc. (default: INR)',
            ),
          },
          requiredProperties: ['origin', 'destination', 'departureDate'],
        ),
      ));

      functionDeclarations.add(FunctionDeclaration(
        'searchTrains',
        'Get train booking information for a route. Returns booking site URLs for the specific region (IRCTC for India, JR for Japan, Trainline for Europe, Amtrak for USA).',
        Schema(
          SchemaType.object,
          properties: {
            'origin': Schema(
              SchemaType.string,
              description: 'Origin city or station',
            ),
            'destination': Schema(
              SchemaType.string,
              description: 'Destination city or station',
            ),
            'date': Schema(
              SchemaType.string,
              description: 'Travel date in YYYY-MM-DD format',
            ),
            'country': Schema(
              SchemaType.string,
              description: 'Country or region (india, japan, europe, usa) for region-specific booking sites',
            ),
          },
          requiredProperties: ['origin', 'destination', 'date'],
        ),
      ));
      
      functionDeclarations.add(FunctionDeclaration(
        'searchBuses',
        'Get bus booking information for a route. Returns booking site URLs (RedBus/AbhiBus for India, FlixBus for Europe, Greyhound for USA).',
        Schema(
          SchemaType.object,
          properties: {
            'origin': Schema(
              SchemaType.string,
              description: 'Origin city',
            ),
            'destination': Schema(
              SchemaType.string,
              description: 'Destination city',
            ),
            'date': Schema(
              SchemaType.string,
              description: 'Travel date in YYYY-MM-DD format',
            ),
            'country': Schema(
              SchemaType.string,
              description: 'Country or region for region-specific booking sites',
            ),
          },
          requiredProperties: ['origin', 'destination', 'date'],
        ),
      ));
      
      functionDeclarations.add(FunctionDeclaration(
        'searchTaxis',
        'Get taxi/cab booking options for a location. Returns apps like Uber, Ola (India), Lyft (USA), Bolt (Europe), Japan Taxi.',
        Schema(
          SchemaType.object,
          properties: {
            'location': Schema(
              SchemaType.string,
              description: 'City or area name',
            ),
            'country': Schema(
              SchemaType.string,
              description: 'Country or region for region-specific taxi apps',
            ),
          },
          requiredProperties: ['location'],
        ),
      ));
      
      functionDeclarations.add(FunctionDeclaration(
        'searchCarRentals',
        'Get car rental booking options. Returns rental sites like Zoomcar/Revv (India), Hertz, Avis, Enterprise.',
        Schema(
          SchemaType.object,
          properties: {
            'location': Schema(
              SchemaType.string,
              description: 'Pickup city or airport',
            ),
            'pickupDate': Schema(
              SchemaType.string,
              description: 'Pickup date in YYYY-MM-DD format',
            ),
            'dropoffDate': Schema(
              SchemaType.string,
              description: 'Drop-off date in YYYY-MM-DD format',
            ),
            'country': Schema(
              SchemaType.string,
              description: 'Country or region for region-specific rental services',
            ),
          },
          requiredProperties: ['location'],
        ),
      ));
      
      functionDeclarations.add(FunctionDeclaration(
        'searchFerries',
        'Get ferry booking information for water routes. Returns booking sites for ferry travel.',
        Schema(
          SchemaType.object,
          properties: {
            'origin': Schema(
              SchemaType.string,
              description: 'Origin port or city',
            ),
            'destination': Schema(
              SchemaType.string,
              description: 'Destination port or city',
            ),
            'date': Schema(
              SchemaType.string,
              description: 'Travel date in YYYY-MM-DD format',
            ),
            'country': Schema(
              SchemaType.string,
              description: 'Country or region',
            ),
          },
          requiredProperties: ['origin', 'destination'],
        ),
      ));
      
      functionDeclarations.add(FunctionDeclaration(
        'searchLocalTransport',
        'Get comprehensive local transport options for a destination including metro, buses, taxis, bike rentals, and day passes. Use this for daily transport recommendations.',
        Schema(
          SchemaType.object,
          properties: {
            'location': Schema(
              SchemaType.string,
              description: 'City name (e.g., "Tokyo", "Delhi", "London")',
            ),
            'country': Schema(
              SchemaType.string,
              description: 'Country or region for region-specific options',
            ),
          },
          requiredProperties: ['location'],
        ),
      ));
    }

    // Hotel Search Tool
    if (hotelTool != null) {
      functionDeclarations.add(FunctionDeclaration(
        'searchHotels',
        'Search for hotels in a destination. Returns real prices, ratings, amenities, and booking links. Use for accommodation recommendations.',
        Schema(
          SchemaType.object,
          properties: {
            'destination': Schema(
              SchemaType.string,
              description: 'City or area name (e.g., "Kyoto", "Tokyo Shinjuku")',
            ),
            'checkIn': Schema(
              SchemaType.string,
              description: 'Check-in date in YYYY-MM-DD format',
            ),
            'checkOut': Schema(
              SchemaType.string,
              description: 'Check-out date in YYYY-MM-DD format',
            ),
            'adults': Schema(
              SchemaType.integer,
              description: 'Number of adult guests (default: 2)',
            ),
            'rooms': Schema(
              SchemaType.integer,
              description: 'Number of rooms (default: 1)',
            ),
            'currency': Schema(
              SchemaType.string,
              description: 'Currency code: INR, USD, EUR, etc. (default: INR)',
            ),
            'priceRange': Schema(
              SchemaType.string,
              description: 'Price range: budget, mid-range, luxury (optional)',
            ),
          },
          requiredProperties: ['destination', 'checkIn', 'checkOut'],
        ),
      ));
    }

    if (functionDeclarations.isEmpty) {
      return [];
    }

    return [Tool(functionDeclarations: functionDeclarations)];
  }

  /// Handle a function call from Gemini
  Future<Map<String, dynamic>> handleFunctionCall(
    String functionName,
    Map<String, dynamic> args,
  ) async {
    Logger.d('AIToolsManager: Handling $functionName with args: $args', tag: 'AITools');

    try {
      switch (functionName) {
        case 'webSearch':
          if (webSearchTool != null) {
            return await webSearchTool!.handleFunctionCall(args);
          }
          return {'error': 'Web search tool not available', 'results': []};

        case 'searchPlaces':
          if (placesTool != null) {
            return await placesTool!.handleFunctionCall(args);
          }
          return {'error': 'Places tool not available', 'results': []};

        case 'searchFlights':
          if (flightTool != null) {
            return await flightTool!.handleFlightSearch(args);
          }
          return {'error': 'Flight search tool not available', 'results': []};

        case 'searchTrains':
          if (flightTool != null) {
            return await flightTool!.handleTrainSearch(args);
          }
          return {'error': 'Train search tool not available', 'results': []};

        case 'searchBuses':
          if (flightTool != null) {
            return await flightTool!.handleBusSearch(args);
          }
          return {'error': 'Bus search tool not available', 'results': []};

        case 'searchTaxis':
          if (flightTool != null) {
            return await flightTool!.handleTaxiSearch(args);
          }
          return {'error': 'Taxi search tool not available', 'results': []};

        case 'searchCarRentals':
          if (flightTool != null) {
            return await flightTool!.handleCarRentalSearch(args);
          }
          return {'error': 'Car rental search tool not available', 'results': []};

        case 'searchFerries':
          if (flightTool != null) {
            return await flightTool!.handleFerrySearch(args);
          }
          return {'error': 'Ferry search tool not available', 'results': []};

        case 'searchLocalTransport':
          if (flightTool != null) {
            return await flightTool!.handleLocalTransportSearch(args);
          }
          return {'error': 'Local transport search tool not available', 'results': []};

        case 'searchHotels':
          if (hotelTool != null) {
            return await hotelTool!.handleHotelSearch(args);
          }
          return {'error': 'Hotel search tool not available', 'results': []};

        default:
          Logger.w('Unknown function call: $functionName', tag: 'AITools');
          return {'error': 'Unknown function: $functionName', 'results': []};
      }
    } catch (e) {
      Logger.e('Error handling $functionName: $e', tag: 'AITools');
      return {'error': 'Function call failed: $e', 'results': []};
    }
  }

  /// Create web search tool
  static WebSearchTool? _createWebSearchTool({
    String? googleSearchApiKey,
    String? googleSearchEngineId,
  }) {
    if (googleSearchApiKey != null &&
        googleSearchApiKey.isNotEmpty &&
        googleSearchEngineId != null &&
        googleSearchEngineId.isNotEmpty) {
      return WebSearchTool.google(
        apiKey: googleSearchApiKey,
        searchEngineId: googleSearchEngineId,
      );
    }
    return null;
  }
}

/// Extended system prompt with all tools
String buildEnhancedSystemPrompt() {
  return '''
You are an expert travel planner AI with access to real-time tools for comprehensive trip planning.

AVAILABLE TOOLS:
1. **webSearch**: General web search for travel info, events, news
2. **searchPlaces**: Google Places for verified locations, ratings, hours
3. **searchFlights**: Real flight prices and booking links
4. **searchTrains**: Train booking info (IRCTC, JR Pass, Trainline, Amtrak)
5. **searchBuses**: Bus booking info (RedBus, FlixBus, Greyhound)
6. **searchTaxis**: Taxi/cab apps (Uber, Ola, Lyft, Bolt)
7. **searchCarRentals**: Car rental services (Zoomcar, Hertz, Avis)
8. **searchFerries**: Ferry booking for water routes
9. **searchLocalTransport**: Metro, buses, day passes for daily transport
10. **searchHotels**: Real hotel prices, ratings, and booking links

TOOL USAGE STRATEGY:
- Use **searchPlaces** to verify restaurant/attraction coordinates and hours
- Use **searchFlights** for outbound and return flight options
- Use **searchTrains** for inter-city rail travel (better for Japan, Europe, India)
- Use **searchBuses** for budget inter-city travel
- Use **searchTaxis** for airport transfers and short trips
- Use **searchLocalTransport** for daily getting around recommendations
- Use **searchCarRentals** for road trips or areas with poor public transport
- Use **searchHotels** for accommodation near planned activities
- Use **webSearch** for events, weather, visa requirements, current pricing

MULTI-MODAL TRANSPORT STRATEGY:
- Long distance (500+ km): Prefer flights, then trains
- Medium distance (100-500 km): Trains or buses based on availability
- Short distance (within city): Local transport, metro, taxi
- Daily transport: Metro cards, day passes, ride-hailing apps
- Airport transfers: Taxi, metro, or airport express trains

RESPONSE TYPES:
1. **ITINERARY RESPONSE**: JSON object with complete trip plan
2. **FOLLOW-UP QUESTION**: Start with "FOLLOWUP: " when clarification needed

RESPONSE BEHAVIOR:
- FIRST REQUEST = IMMEDIATE ITINERARY with real data from tools
- Use tools to get actual prices, not estimates
- Include booking URLs from tool responses
- Include multiple transport mode options when appropriate

ENHANCED JSON SCHEMA (includes multi-modal transport, stays, budget):
{
  "title": "Trip Title",
  "startDate": "YYYY-MM-DD", 
  "endDate": "YYYY-MM-DD",
  "days": [
    {
      "date": "YYYY-MM-DD",
      "summary": "Brief day summary (max 8 words)",
      "items": [
        {
          "time": "HH:MM",
          "activity": "Activity with verified details from searchPlaces", 
          "location": "lat,lng"
        }
      ]
    }
  ],
  "transport": {
    "outbound": {
      "type": "flight|train|bus",
      "origin": "City Name",
      "originCode": "DEL",
      "destination": "City Name",
      "destinationCode": "KIX",
      "departureTime": "2025-04-10T06:00:00",
      "arrivalTime": "2025-04-10T18:00:00",
      "duration": "8h 30m",
      "carrier": "Air India",
      "price": 45000,
      "currency": "INR",
      "bookingUrl": "https://..."
    },
    "return": { ... },
    "interCity": [
      {
        "type": "train",
        "origin": "Tokyo",
        "destination": "Kyoto",
        "departureTime": "2025-04-12T08:00:00",
        "arrivalTime": "2025-04-12T10:15:00",
        "duration": "2h 15m",
        "carrier": "JR Shinkansen",
        "price": 13000,
        "currency": "JPY",
        "bookingUrl": "https://..."
      },
      {
        "type": "bus",
        "origin": "Kyoto",
        "destination": "Osaka",
        "departureTime": "2025-04-14T10:00:00",
        "arrivalTime": "2025-04-14T11:30:00",
        "duration": "1h 30m",
        "carrier": "FlixBus",
        "price": 800,
        "currency": "JPY",
        "bookingUrl": "https://..."
      }
    ],
    "localTransport": {
      "recommendation": "Get Suica card for trains and buses",
      "estimatedDailyCost": 800,
      "estimatedTotalCost": 4000,
      "currency": "JPY",
      "tips": [
        "Suica card works on all JR lines",
        "Get Kyoto Bus Day Pass for temple visits",
        "Use Uber/taxi for airport transfers"
      ],
      "passName": "Suica Card",
      "passUrl": "https://..."
    }
  },
  "stays": {
    "stays": [
      {
        "name": "Hotel Name from searchHotels",
        "type": "hotel",
        "address": "Full address",
        "location": "lat,lng",
        "checkIn": "YYYY-MM-DD",
        "checkOut": "YYYY-MM-DD",
        "nights": 5,
        "pricePerNight": 8000,
        "totalPrice": 40000,
        "currency": "INR",
        "rating": 4.5,
        "amenities": ["WiFi", "Breakfast"],
        "bookingUrl": "https://..."
      }
    ],
    "aiRecommendation": "Stay near Gion for best temple access"
  },
  "budget": {
    "totalBudget": 150000,
    "currency": "INR",
    "estimated": {
      "transport": 50000,
      "accommodation": 40000,
      "food": 25000,
      "activities": 20000,
      "shopping": 10000,
      "misc": 5000
    },
    "perDayAverage": 30000,
    "savingTips": [
      "Book JR Pass for ¥29,650 (saves 40% on trains)",
      "Use day passes for local transport",
      "Eat at konbini for budget meals"
    ]
  }
}

TRANSPORT TYPE VALUES:
- "flight" - Air travel
- "train" - Rail (Shinkansen, IRCTC, Amtrak, etc.)
- "bus" - Bus (RedBus, FlixBus, Greyhound)
- "ferry" - Water transport
- "car" - Car rental
- "taxi" - Taxi/cab (Uber, Ola, Lyft)
- "metro" - Metro/subway

CRITICAL RULES:
- 24-hour time format (09:00, 14:30, 18:00)
- Real coordinates from searchPlaces
- Real prices from search tools
- Include bookingUrl from tool responses
- Keep response under 4000 tokens
- Maximum 5-7 days, 3-5 activities per day
- For FOLLOWUP: Start with "FOLLOWUP: " prefix
- Include MULTIPLE transport options when appropriate (e.g., both train and bus)

MANDATORY TOOL USAGE FOR COMPLETE ITINERARY:
1. **ALWAYS** call searchFlights for outbound AND return flights
2. **ALWAYS** call searchHotels for accommodation (at least 1 call per city)
3. **ALWAYS** call searchLocalTransport for daily transport in each destination city
4. If flights not found, try searchTrains or searchBuses for inter-city travel
5. Use searchPlaces to verify activity locations

RESPONSE FORMAT RULES:
- **NEVER** respond with markdown or bullet points for itineraries
- **ALWAYS** respond with valid JSON matching the schema above
- If tools return no results, still include estimated data in the JSON response
- The response MUST be a single JSON object starting with { and ending with }
- Do NOT wrap JSON in markdown code blocks (no \`\`\`json)

JSON VALIDATION:
✓ All strings in double quotes
✓ All arrays closed with ]
✓ All objects closed with }
✓ No trailing commas
✓ Complete and parseable
✓ Response is PURE JSON (no markdown)

Remember: Use ALL relevant tools for real data. Include booking URLs. Always return JSON format.
''';
}
