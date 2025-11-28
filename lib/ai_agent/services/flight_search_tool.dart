/// **Transport Search Tool for Gemini AI (Multi-Modal)**
/// 
/// Provides comprehensive transport search data:
/// - Flights (via RapidAPI Sky-Scrapper + Travelpayouts fallback)
/// - Trains (booking URLs for regional services)
/// - Buses (booking URLs for bus services)
/// - Taxis/Cabs (Uber, Ola, regional services)
/// - Car Rentals (major rental services)
/// - Ferries (where applicable)
/// 
/// Uses RapidAPI for flights (Sky-Scrapper primary, Travelpayouts fallback),
/// curated booking URLs for other transport modes
library;

import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../../core/utils/helpers.dart';
import '../../trip_planning_chat/data/models/booking_models.dart';

/// Flight and Transport Search Tool for AI function calling
class FlightSearchTool {
  // Primary: Sky-Scrapper3 API (kevinagustiansyah298)
  static const String _skyScrapperBaseUrl = 'https://sky-scrapper3.p.rapidapi.com/api/v1';
  static const String _skyScrapperHost = 'sky-scrapper3.p.rapidapi.com';
  
  // Fallback: Travelpayouts API (1000 requests/day FREE!)
  static const String _travelpayoutsBaseUrl = 'https://travelpayouts-travelpayouts-flight-data-v1.p.rapidapi.com';
  static const String _travelpayoutsHost = 'travelpayouts-travelpayouts-flight-data-v1.p.rapidapi.com';
  
  static const Duration _requestTimeout = Duration(seconds: 20);
  
  final String rapidApiKey;
  final http.Client _httpClient;
  
  // Track API failures for fallback logic
  int _skyScrapperFailures = 0;
  static const int _maxFailuresBeforeFallback = 3;
  
  // Cache for airport codes
  final Map<String, String> _airportCache = {};
  
  // Cache for IATA codes (Travelpayouts uses IATA codes)
  final Map<String, String> _iataCodeCache = {};
  
  // Regional transport booking services
  static const Map<String, List<Map<String, String>>> _trainBookingServices = {
    'india': [
      {'name': 'IRCTC', 'url': 'https://www.irctc.co.in/nget/train-search', 'icon': '🚄'},
      {'name': 'Trainman', 'url': 'https://www.trainman.in/', 'icon': '🚄'},
      {'name': 'ConfirmTkt', 'url': 'https://www.confirmtkt.com/', 'icon': '🚄'},
    ],
    'japan': [
      {'name': 'JR Pass', 'url': 'https://www.jrailpass.com/', 'icon': '🚅'},
      {'name': 'Japan Rail', 'url': 'https://www.jrpass.com/', 'icon': '🚅'},
      {'name': 'Shinkansen', 'url': 'https://smart-ex.jp/en/', 'icon': '🚄'},
    ],
    'europe': [
      {'name': 'Trainline', 'url': 'https://www.thetrainline.com/', 'icon': '🚄'},
      {'name': 'Rail Europe', 'url': 'https://www.raileurope.com/', 'icon': '🚄'},
      {'name': 'Eurail', 'url': 'https://www.eurail.com/', 'icon': '🚄'},
      {'name': 'Omio', 'url': 'https://www.omio.com/', 'icon': '🚄'},
    ],
    'usa': [
      {'name': 'Amtrak', 'url': 'https://www.amtrak.com/', 'icon': '🚄'},
      {'name': 'Wanderu', 'url': 'https://www.wanderu.com/', 'icon': '🚄'},
    ],
    'default': [
      {'name': 'Trainline', 'url': 'https://www.thetrainline.com/', 'icon': '🚄'},
      {'name': 'Omio', 'url': 'https://www.omio.com/', 'icon': '🚄'},
    ],
  };
  
  static const Map<String, List<Map<String, String>>> _busBookingServices = {
    'india': [
      {'name': 'RedBus', 'url': 'https://www.redbus.in/', 'icon': '🚌'},
      {'name': 'AbhiBus', 'url': 'https://www.abhibus.com/', 'icon': '🚌'},
      {'name': 'MakeMyTrip Bus', 'url': 'https://www.makemytrip.com/bus-tickets/', 'icon': '🚌'},
      {'name': 'Paytm Bus', 'url': 'https://paytm.com/bus-tickets/', 'icon': '🚌'},
    ],
    'europe': [
      {'name': 'FlixBus', 'url': 'https://www.flixbus.com/', 'icon': '🚌'},
      {'name': 'BlaBlaCar', 'url': 'https://www.blablacar.com/', 'icon': '🚌'},
      {'name': 'Eurolines', 'url': 'https://www.eurolines.com/', 'icon': '🚌'},
    ],
    'usa': [
      {'name': 'Greyhound', 'url': 'https://www.greyhound.com/', 'icon': '🚌'},
      {'name': 'FlixBus US', 'url': 'https://www.flixbus.com/bus/usa', 'icon': '🚌'},
      {'name': 'Megabus', 'url': 'https://us.megabus.com/', 'icon': '🚌'},
    ],
    'default': [
      {'name': 'FlixBus', 'url': 'https://www.flixbus.com/', 'icon': '🚌'},
      {'name': 'BlaBlaCar', 'url': 'https://www.blablacar.com/', 'icon': '🚌'},
      {'name': 'Omio', 'url': 'https://www.omio.com/', 'icon': '🚌'},
    ],
  };
  
  static const Map<String, List<Map<String, String>>> _taxiBookingServices = {
    'india': [
      {'name': 'Uber', 'url': 'https://www.uber.com/', 'icon': '🚕'},
      {'name': 'Ola', 'url': 'https://www.olacabs.com/', 'icon': '🚕'},
      {'name': 'Rapido', 'url': 'https://www.rapido.bike/', 'icon': '🛵'},
      {'name': 'Savaari', 'url': 'https://www.savaari.com/', 'icon': '🚗'},
    ],
    'japan': [
      {'name': 'Japan Taxi', 'url': 'https://japantaxi.jp/', 'icon': '🚕'},
      {'name': 'Uber Japan', 'url': 'https://www.uber.com/jp/', 'icon': '🚕'},
      {'name': 'GO Taxi', 'url': 'https://go.mo-t.com/', 'icon': '🚕'},
    ],
    'europe': [
      {'name': 'Uber', 'url': 'https://www.uber.com/', 'icon': '🚕'},
      {'name': 'Bolt', 'url': 'https://bolt.eu/', 'icon': '🚕'},
      {'name': 'FreeNow', 'url': 'https://www.free-now.com/', 'icon': '🚕'},
    ],
    'usa': [
      {'name': 'Uber', 'url': 'https://www.uber.com/', 'icon': '🚕'},
      {'name': 'Lyft', 'url': 'https://www.lyft.com/', 'icon': '🚕'},
    ],
    'default': [
      {'name': 'Uber', 'url': 'https://www.uber.com/', 'icon': '🚕'},
      {'name': 'Bolt', 'url': 'https://bolt.eu/', 'icon': '🚕'},
    ],
  };
  
  static const Map<String, List<Map<String, String>>> _carRentalServices = {
    'india': [
      {'name': 'Zoomcar', 'url': 'https://www.zoomcar.com/', 'icon': '🚗'},
      {'name': 'Revv', 'url': 'https://www.revv.co.in/', 'icon': '🚗'},
      {'name': 'Drivezy', 'url': 'https://www.drivezy.com/', 'icon': '🚗'},
    ],
    'default': [
      {'name': 'Rentalcars', 'url': 'https://www.rentalcars.com/', 'icon': '🚗'},
      {'name': 'Kayak Cars', 'url': 'https://www.kayak.com/cars', 'icon': '🚗'},
      {'name': 'Hertz', 'url': 'https://www.hertz.com/', 'icon': '🚗'},
      {'name': 'Avis', 'url': 'https://www.avis.com/', 'icon': '🚗'},
      {'name': 'Enterprise', 'url': 'https://www.enterprise.com/', 'icon': '🚗'},
    ],
  };
  
  static const Map<String, List<Map<String, String>>> _ferryBookingServices = {
    'default': [
      {'name': 'Direct Ferries', 'url': 'https://www.directferries.com/', 'icon': '⛴️'},
      {'name': 'Ferryhopper', 'url': 'https://www.ferryhopper.com/', 'icon': '⛴️'},
    ],
    'japan': [
      {'name': 'Japan Ferry', 'url': 'https://www.japanferry.jp/', 'icon': '⛴️'},
    ],
    'europe': [
      {'name': 'Direct Ferries', 'url': 'https://www.directferries.com/', 'icon': '⛴️'},
      {'name': 'Ferryhopper', 'url': 'https://www.ferryhopper.com/', 'icon': '⛴️'},
    ],
  };

  FlightSearchTool({
    required this.rapidApiKey,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// Headers for Sky-Scrapper API (Primary)
  Map<String, String> get _skyScrapperHeaders => {
    'X-RapidAPI-Key': rapidApiKey,
    'X-RapidAPI-Host': _skyScrapperHost,
  };
  
  /// Headers for Travelpayouts API (Fallback)
  Map<String, String> get _travelpayoutsHeaders => {
    'X-RapidAPI-Key': rapidApiKey,
    'X-RapidAPI-Host': _travelpayoutsHost,
  };
  
  /// Decide which API to use based on failure count
  bool get _useFallbackApi => _skyScrapperFailures >= _maxFailuresBeforeFallback;

  /// Handle function call from Gemini for flight search
  Future<Map<String, dynamic>> handleFlightSearch(Map<String, dynamic> args) async {
    try {
      final origin = args['origin'] as String?;
      final destination = args['destination'] as String?;
      final departureDate = args['departureDate'] as String?; // YYYY-MM-DD
      final returnDate = args['returnDate'] as String?; // YYYY-MM-DD (optional)
      final adults = args['adults'] as int? ?? 1;
      final cabinClass = args['cabinClass'] as String? ?? 'economy';
      final currency = args['currency'] as String? ?? 'INR';
      
      if (origin == null || origin.isEmpty) {
        return {'error': 'Origin is required', 'results': []};
      }
      if (destination == null || destination.isEmpty) {
        return {'error': 'Destination is required', 'results': []};
      }
      if (departureDate == null) {
        return {'error': 'Departure date is required', 'results': []};
      }
      
      Logger.d('FlightSearchTool: Searching flights $origin -> $destination (using ${_useFallbackApi ? "Travelpayouts" : "Sky-Scrapper"})', tag: 'FlightTool');
      
      List<TransportSegment> flights = [];
      String usedApi = 'sky-scrapper';
      
      // Try primary API (Sky-Scrapper) unless we've had too many failures
      if (!_useFallbackApi) {
        // Get airport codes for Sky-Scrapper
        final originCode = await _getAirportCode(origin);
        final destCode = await _getAirportCode(destination);
        
        if (originCode != null && destCode != null) {
          flights = await _searchFlightsSkysScrapper(
            originCode: originCode,
            destinationCode: destCode,
            departureDate: departureDate,
            returnDate: returnDate,
            adults: adults,
            cabinClass: cabinClass,
            currency: currency,
          );
          
          if (flights.isEmpty) {
            _skyScrapperFailures++;
            Logger.w('Sky-Scrapper returned no results, failure count: $_skyScrapperFailures', tag: 'FlightTool');
          }
        } else {
          _skyScrapperFailures++;
        }
      }
      
      // Fallback to Travelpayouts if primary failed or returned empty
      if (flights.isEmpty) {
        Logger.d('Using Travelpayouts fallback API', tag: 'FlightTool');
        usedApi = 'travelpayouts';
        
        // Get IATA codes for Travelpayouts
        final originIata = await _getIataCode(origin);
        final destIata = await _getIataCode(destination);
        
        if (originIata != null && destIata != null) {
          flights = await _searchFlightsTravelpayouts(
            originIata: originIata,
            destinationIata: destIata,
            departureDate: departureDate,
            returnDate: returnDate,
            currency: currency,
          );
        }
      }
      
      Logger.d('FlightSearchTool: Found ${flights.length} flight options via $usedApi', tag: 'FlightTool');
      
      return {
        'success': true,
        'origin': origin,
        'destination': destination,
        'departureDate': departureDate,
        'returnDate': returnDate,
        'results': flights.take(5).map((f) => f.toJson()).toList(),
        'count': flights.length,
        'apiUsed': usedApi,
      };
      
    } catch (e) {
      Logger.e('FlightSearchTool error: $e', tag: 'FlightTool');
      return {
        'error': 'Flight search failed: $e',
        'results': [],
      };
    }
  }

  /// Get airport code from city/airport name (for Sky-Scrapper)
  Future<String?> _getAirportCode(String query) async {
    // Check cache first
    final cached = _airportCache[query.toLowerCase()];
    if (cached != null) return cached;
    
    // Check if query is already a code (3 letters)
    if (query.length == 3 && query.toUpperCase() == query) {
      return query;
    }
    
    // Try common codes first (faster than API call)
    final commonCode = _getCommonIataCode(query);
    if (commonCode != null) {
      _airportCache[query.toLowerCase()] = commonCode;
      return commonCode;
    }
    
    try {
      final uri = Uri.parse('$_skyScrapperBaseUrl/flights/searchAirport').replace(
        queryParameters: {
          'query': query,
        },
      );
      
      final response = await _httpClient
          .get(uri, headers: _skyScrapperHeaders)
          .timeout(_requestTimeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final airports = data['data'] as List<dynamic>?;
        
        if (airports != null && airports.isNotEmpty) {
          // Get first airport result
          final airport = airports.first as Map<String, dynamic>;
          final skyId = airport['skyId'] as String?;
          final entityId = airport['entityId'] as String?;
          
          // Store in cache
          if (skyId != null) {
            _airportCache[query.toLowerCase()] = skyId;
            return skyId;
          }
          if (entityId != null) {
            _airportCache[query.toLowerCase()] = entityId;
            return entityId;
          }
        }
      }
      
      Logger.w('Could not find airport for: $query', tag: 'FlightTool');
      return null;
    } catch (e) {
      Logger.e('Airport search failed: $e', tag: 'FlightTool');
      return null;
    }
  }
  
  /// Get IATA code from city name (for Travelpayouts)
  Future<String?> _getIataCode(String query) async {
    // Check cache first
    final cached = _iataCodeCache[query.toLowerCase()];
    if (cached != null) return cached;
    
    // Check if query is already a code (3 letters)
    if (query.length == 3 && query.toUpperCase() == query) {
      return query.toUpperCase();
    }
    
    // Common city to IATA mappings for faster lookup
    final commonCodes = _getCommonIataCode(query);
    if (commonCodes != null) {
      _iataCodeCache[query.toLowerCase()] = commonCodes;
      return commonCodes;
    }
    
    // Try to autocomplete using Travelpayouts
    try {
      final uri = Uri.parse('$_travelpayoutsBaseUrl/autocomplete').replace(
        queryParameters: {
          'term': query,
          'locale': 'en',
          'types[]': 'city',
        },
      );
      
      final response = await _httpClient
          .get(uri, headers: _travelpayoutsHeaders)
          .timeout(_requestTimeout);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final code = data.first['code'] as String?;
          if (code != null) {
            _iataCodeCache[query.toLowerCase()] = code;
            return code;
          }
        }
      }
    } catch (e) {
      Logger.e('IATA code lookup failed: $e', tag: 'FlightTool');
    }
    
    // Fallback: try to extract from Sky-Scrapper result
    final skyCode = await _getAirportCode(query);
    if (skyCode != null && skyCode.length == 3) {
      _iataCodeCache[query.toLowerCase()] = skyCode.toUpperCase();
      return skyCode.toUpperCase();
    }
    
    return null;
  }
  
  /// Common city to IATA code mappings
  String? _getCommonIataCode(String query) {
    final q = query.toLowerCase();
    const commonCodes = {
      // India
      'delhi': 'DEL', 'new delhi': 'DEL',
      'mumbai': 'BOM', 'bombay': 'BOM',
      'bangalore': 'BLR', 'bengaluru': 'BLR',
      'chennai': 'MAA', 'madras': 'MAA',
      'kolkata': 'CCU', 'calcutta': 'CCU',
      'hyderabad': 'HYD',
      'ahmedabad': 'AMD',
      'pune': 'PNQ',
      'jaipur': 'JAI',
      'goa': 'GOI',
      'kochi': 'COK', 'cochin': 'COK',
      'lucknow': 'LKO',
      'guwahati': 'GAU',
      'patna': 'PAT',
      'ranchi': 'IXR',
      'bhubaneswar': 'BBI',
      'indore': 'IDR',
      'chandigarh': 'IXC',
      'varanasi': 'VNS',
      'srinagar': 'SXR',
      'thiruvananthapuram': 'TRV', 'trivandrum': 'TRV',
      'nagpur': 'NAG',
      'coimbatore': 'CJB',
      'visakhapatnam': 'VTZ', 'vizag': 'VTZ',
      'udaipur': 'UDR',
      'amritsar': 'ATQ',
      'agra': 'AGR',
      'jodhpur': 'JDH',
      'mangalore': 'IXE',
      'mysore': 'MYQ',
      'tiruchirappalli': 'TRZ', 'trichy': 'TRZ',
      'raipur': 'RPR',
      'dehradun': 'DED',
      'leh': 'IXL',
      'surat': 'STV',
      'vadodara': 'BDQ', 'baroda': 'BDQ',
      'bagdogra': 'IXB', 'siliguri': 'IXB',
      'port blair': 'IXZ', 'andaman': 'IXZ',
      // International
      'london': 'LHR', 'heathrow': 'LHR',
      'paris': 'CDG',
      'new york': 'JFK', 'nyc': 'JFK',
      'los angeles': 'LAX', 'la': 'LAX',
      'tokyo': 'NRT', 'narita': 'NRT',
      'singapore': 'SIN',
      'dubai': 'DXB',
      'hong kong': 'HKG',
      'bangkok': 'BKK',
      'sydney': 'SYD',
      'frankfurt': 'FRA',
      'amsterdam': 'AMS',
      'istanbul': 'IST',
      'kuala lumpur': 'KUL',
      'doha': 'DOH',
      'abu dhabi': 'AUH',
      'toronto': 'YYZ',
      'san francisco': 'SFO',
      'chicago': 'ORD',
      'miami': 'MIA',
      'rome': 'FCO',
      'madrid': 'MAD',
      'barcelona': 'BCN',
      'berlin': 'BER',
      'munich': 'MUC',
      'zurich': 'ZRH',
      'vienna': 'VIE',
      'seoul': 'ICN',
      'beijing': 'PEK',
      'shanghai': 'PVG',
      'osaka': 'KIX',
      'bali': 'DPS', 'denpasar': 'DPS',
      'phuket': 'HKT',
      'maldives': 'MLE', 'male': 'MLE',
      'colombo': 'CMB',
      'kathmandu': 'KTM',
      'dhaka': 'DAC',
      // South America
      'caracas': 'CCS',
      'bogota': 'BOG',
      'lima': 'LIM',
      'santiago': 'SCL',
      'buenos aires': 'EZE',
      'sao paulo': 'GRU',
      'rio de janeiro': 'GIG', 'rio': 'GIG',
      'quito': 'UIO',
      'medellin': 'MDE',
      'cartagena': 'CTG',
      'cusco': 'CUZ',
      // Central America & Caribbean
      'mexico city': 'MEX',
      'cancun': 'CUN',
      'havana': 'HAV',
      'san jose': 'SJO',
      'panama city': 'PTY',
      'guatemala city': 'GUA', 'guatemala': 'GUA',
      'san salvador': 'SAL',
      'tegucigalpa': 'TGU',
      'managua': 'MGA',
      'belize city': 'BZE',
      'kingston': 'KIN',
      'santo domingo': 'SDQ',
      'san juan': 'SJU', 'puerto rico': 'SJU',
      'montego bay': 'MBJ',
      'nassau': 'NAS', 'bahamas': 'NAS',
      'punta cana': 'PUJ',
      'aruba': 'AUA',
      // Africa
      'johannesburg': 'JNB',
      'cape town': 'CPT',
      'cairo': 'CAI',
      'nairobi': 'NBO',
      'addis ababa': 'ADD',
      'casablanca': 'CMN',
      'lagos': 'LOS',
      // More Asia
      'hanoi': 'HAN',
      'ho chi minh': 'SGN', 'saigon': 'SGN',
      'manila': 'MNL',
      'taipei': 'TPE',
      'jakarta': 'CGK',
      'yangon': 'RGN',
      'phnom penh': 'PNH',
      'siem reap': 'REP',
      // Middle East
      'tehran': 'IKA',
      'riyadh': 'RUH',
      'jeddah': 'JED',
      'muscat': 'MCT',
      'amman': 'AMM',
      'beirut': 'BEY',
      'tel aviv': 'TLV',
      // More Europe
      'lisbon': 'LIS',
      'dublin': 'DUB',
      'prague': 'PRG',
      'budapest': 'BUD',
      'warsaw': 'WAW',
      'athens': 'ATH',
      'copenhagen': 'CPH',
      'oslo': 'OSL',
      'stockholm': 'ARN',
      'helsinki': 'HEL',
      'brussels': 'BRU',
      'milan': 'MXP',
      'venice': 'VCE',
      'florence': 'FLR',
      'nice': 'NCE',
      'edinburgh': 'EDI',
      'manchester': 'MAN',
      'birmingham': 'BHX',
      // Australia & Pacific
      'melbourne': 'MEL',
      'brisbane': 'BNE',
      'perth': 'PER',
      'auckland': 'AKL',
      'fiji': 'NAN', 'nadi': 'NAN',
    };
    
    for (final entry in commonCodes.entries) {
      if (q.contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }

  /// Search flights using Sky-Scrapper API (Primary)
  Future<List<TransportSegment>> _searchFlightsSkysScrapper({
    required String originCode,
    required String destinationCode,
    required String departureDate,
    String? returnDate,
    int adults = 1,
    String cabinClass = 'economy',
    String currency = 'INR',
  }) async {
    try {
      final params = {
        'originSkyId': originCode,
        'destinationSkyId': destinationCode,
        'originEntityId': originCode,
        'destinationEntityId': destinationCode,
        'date': departureDate,
        'adults': adults.toString(),
        'cabinClass': cabinClass,
        'currency': currency,
        'countryCode': currency == 'INR' ? 'IN' : 'US',
        'market': currency == 'INR' ? 'IN' : 'US',
      };
      
      if (returnDate != null) {
        params['returnDate'] = returnDate;
      }
      
      final uri = Uri.parse('$_skyScrapperBaseUrl/flights/searchFlights').replace(
        queryParameters: params,
      );
      
      final response = await _httpClient
          .get(uri, headers: _skyScrapperHeaders)
          .timeout(_requestTimeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final itineraries = data['data']?['itineraries'] as List<dynamic>?;
        
        if (itineraries != null && itineraries.isNotEmpty) {
          return itineraries.map((itin) => _parseFlightResult(
            itin as Map<String, dynamic>,
            originCode: originCode,
            destinationCode: destinationCode,
            currency: currency,
          )).toList();
        }
      } else {
        Logger.e('Flight search failed: ${response.statusCode}', tag: 'FlightTool');
      }
      
      return [];
    } catch (e) {
      Logger.e('Flight search error: $e', tag: 'FlightTool');
      return [];
    }
  }

  /// Parse flight result from API response
  TransportSegment _parseFlightResult(
    Map<String, dynamic> itinerary, {
    required String originCode,
    required String destinationCode,
    required String currency,
  }) {
    // Extract price
    final price = itinerary['price'] as Map<String, dynamic>?;
    final rawPrice = price?['raw'] as num?;
    // Formatted price available: price?['formatted']
    
    // Extract first leg details
    final legs = itinerary['legs'] as List<dynamic>?;
    final firstLeg = legs?.isNotEmpty == true 
        ? legs!.first as Map<String, dynamic> 
        : null;
    
    // Extract times
    final departure = firstLeg?['departure'] as String? ?? '';
    final arrival = firstLeg?['arrival'] as String? ?? '';
    
    // Extract duration
    final durationMinutes = firstLeg?['durationInMinutes'] as int?;
    String? duration;
    if (durationMinutes != null) {
      final hours = durationMinutes ~/ 60;
      final mins = durationMinutes % 60;
      duration = '${hours}h ${mins}m';
    }
    
    // Extract stops
    final stopCount = firstLeg?['stopCount'] as int? ?? 0;
    
    // Extract carrier info
    final carriers = firstLeg?['carriers'] as Map<String, dynamic>?;
    final marketing = carriers?['marketing'] as List<dynamic>?;
    String? carrier;
    String? carrierLogo;
    if (marketing != null && marketing.isNotEmpty) {
      final firstCarrier = marketing.first as Map<String, dynamic>;
      carrier = firstCarrier['name'] as String?;
      carrierLogo = firstCarrier['logoUrl'] as String?;
    }
    
    // Extract origin/destination details
    final originData = firstLeg?['origin'] as Map<String, dynamic>?;
    final destData = firstLeg?['destination'] as Map<String, dynamic>?;
    final originName = originData?['name'] as String? ?? originCode;
    final destName = destData?['name'] as String? ?? destinationCode;
    final originDisplayCode = originData?['displayCode'] as String? ?? originCode;
    final destDisplayCode = destData?['displayCode'] as String? ?? destinationCode;
    
    // Build booking URL (Skyscanner deep link)
    final bookingUrl = 'https://www.skyscanner.com/transport/flights/'
        '${originDisplayCode.toLowerCase()}/${destDisplayCode.toLowerCase()}/'
        '${departure.substring(0, 10).replaceAll('-', '')}';
    
    return TransportSegment(
      id: itinerary['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: TransportType.flight,
      origin: originName,
      originCode: originDisplayCode,
      destination: destName,
      destinationCode: destDisplayCode,
      departureTime: departure,
      arrivalTime: arrival,
      duration: duration,
      carrier: carrier,
      carrierLogo: carrierLogo,
      price: rawPrice?.toDouble(),
      currency: currency,
      bookingUrl: bookingUrl,
      cabinClass: 'Economy',
      stops: stopCount,
    );
  }

  /// Search flights using Travelpayouts API (Fallback - 1000 requests/day FREE!)
  Future<List<TransportSegment>> _searchFlightsTravelpayouts({
    required String originIata,
    required String destinationIata,
    required String departureDate,
    String? returnDate,
    String currency = 'INR',
  }) async {
    try {
      // Try cheapest flights endpoint first
      final uri = Uri.parse('$_travelpayoutsBaseUrl/v1/prices/cheap').replace(
        queryParameters: {
          'origin': originIata,
          'destination': destinationIata,
          'depart_date': departureDate,
          'return_date': returnDate ?? '',
          'currency': currency.toLowerCase(),
          'page': '1',
        },
      );
      
      final response = await _httpClient
          .get(uri, headers: _travelpayoutsHeaders)
          .timeout(_requestTimeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final success = data['success'] as bool? ?? false;
        
        if (success) {
          final flightsData = data['data'] as Map<String, dynamic>?;
          if (flightsData != null && flightsData.isNotEmpty) {
            return _parseTravelpayoutsResults(
              flightsData,
              originIata: originIata,
              destinationIata: destinationIata,
              departureDate: departureDate,
              currency: currency,
            );
          }
        }
      }
      
      // Try calendar prices as secondary option
      return await _searchTravelpayoutsCalendar(
        originIata: originIata,
        destinationIata: destinationIata,
        departureDate: departureDate,
        currency: currency,
      );
      
    } catch (e) {
      Logger.e('Travelpayouts search error: $e', tag: 'FlightTool');
      return [];
    }
  }
  
  /// Search Travelpayouts calendar for prices
  Future<List<TransportSegment>> _searchTravelpayoutsCalendar({
    required String originIata,
    required String destinationIata,
    required String departureDate,
    String currency = 'INR',
  }) async {
    try {
      final uri = Uri.parse('$_travelpayoutsBaseUrl/v1/prices/calendar').replace(
        queryParameters: {
          'origin': originIata,
          'destination': destinationIata,
          'depart_date': departureDate,
          'currency': currency.toLowerCase(),
        },
      );
      
      final response = await _httpClient
          .get(uri, headers: _travelpayoutsHeaders)
          .timeout(_requestTimeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final success = data['success'] as bool? ?? false;
        
        if (success) {
          final flightsData = data['data'] as Map<String, dynamic>?;
          if (flightsData != null) {
            return _parseTravelpayoutsCalendarResults(
              flightsData,
              originIata: originIata,
              destinationIata: destinationIata,
              departureDate: departureDate,
              currency: currency,
            );
          }
        }
      }
      
      return [];
    } catch (e) {
      Logger.e('Travelpayouts calendar search error: $e', tag: 'FlightTool');
      return [];
    }
  }
  
  /// Parse Travelpayouts cheap flights response
  List<TransportSegment> _parseTravelpayoutsResults(
    Map<String, dynamic> data, {
    required String originIata,
    required String destinationIata,
    required String departureDate,
    required String currency,
  }) {
    final results = <TransportSegment>[];
    
    // Data structure: { "DEST_IATA": { "0": {...}, "1": {...}, ... } }
    final destData = data[destinationIata] as Map<String, dynamic>?;
    if (destData == null) return results;
    
    for (final entry in destData.entries) {
      final flight = entry.value as Map<String, dynamic>?;
      if (flight == null) continue;
      
      final price = flight['price'] as num?;
      final airline = flight['airline'] as String?;
      final flightNumber = flight['flight_number'] as int?;
      final departDate = flight['departure_at'] as String?;
      final returnAt = flight['return_at'] as String?;
      
      // Build Aviasales/Jetradar booking URL
      final bookingUrl = 'https://www.aviasales.com/search/$originIata${departureDate.replaceAll('-', '')}$destinationIata?adults=1';
      
      results.add(TransportSegment(
        id: 'tp_${originIata}_${destinationIata}_${entry.key}',
        type: TransportType.flight,
        origin: _getCityName(originIata),
        originCode: originIata,
        destination: _getCityName(destinationIata),
        destinationCode: destinationIata,
        departureTime: departDate ?? departureDate,
        arrivalTime: returnAt ?? '',
        carrier: _getAirlineName(airline),
        flightNumber: flightNumber != null ? '$airline$flightNumber' : null,
        price: price?.toDouble(),
        currency: currency.toUpperCase(),
        bookingUrl: bookingUrl,
        cabinClass: 'Economy',
        stops: 0, // Travelpayouts returns cheapest which may be direct
      ));
    }
    
    return results;
  }
  
  /// Parse Travelpayouts calendar response
  List<TransportSegment> _parseTravelpayoutsCalendarResults(
    Map<String, dynamic> data, {
    required String originIata,
    required String destinationIata,
    required String departureDate,
    required String currency,
  }) {
    final results = <TransportSegment>[];
    
    // Find the closest date to requested departure
    final targetDate = DateTime.tryParse(departureDate);
    if (targetDate == null) return results;
    
    for (final entry in data.entries) {
      final dateStr = entry.key;
      final flight = entry.value as Map<String, dynamic>?;
      if (flight == null) continue;
      
      final flightDate = DateTime.tryParse(dateStr);
      if (flightDate == null) continue;
      
      // Only include flights within 3 days of target
      final daysDiff = flightDate.difference(targetDate).inDays.abs();
      if (daysDiff > 3) continue;
      
      final price = flight['price'] as num?;
      final airline = flight['airline'] as String?;
      final flightNumber = flight['flight_number'] as int?;
      
      results.add(TransportSegment(
        id: 'tp_cal_${originIata}_${destinationIata}_$dateStr',
        type: TransportType.flight,
        origin: _getCityName(originIata),
        originCode: originIata,
        destination: _getCityName(destinationIata),
        destinationCode: destinationIata,
        departureTime: dateStr,
        arrivalTime: '', // Calendar API doesn't provide arrival time
        carrier: _getAirlineName(airline),
        flightNumber: flightNumber != null ? '$airline$flightNumber' : null,
        price: price?.toDouble(),
        currency: currency.toUpperCase(),
        bookingUrl: 'https://www.aviasales.com/search/$originIata${dateStr.replaceAll('-', '')}$destinationIata?adults=1',
        cabinClass: 'Economy',
        stops: 0,
      ));
    }
    
    // Sort by date proximity to target
    results.sort((a, b) {
      final aDate = DateTime.tryParse(a.departureTime);
      final bDate = DateTime.tryParse(b.departureTime);
      if (aDate == null || bDate == null) return 0;
      final aDiff = aDate.difference(targetDate).inDays.abs();
      final bDiff = bDate.difference(targetDate).inDays.abs();
      return aDiff.compareTo(bDiff);
    });
    
    return results.take(5).toList();
  }
  
  /// Get city name from IATA code
  String _getCityName(String iataCode) {
    const cityNames = {
      'DEL': 'New Delhi',
      'BOM': 'Mumbai',
      'BLR': 'Bangalore',
      'MAA': 'Chennai',
      'CCU': 'Kolkata',
      'HYD': 'Hyderabad',
      'LHR': 'London Heathrow',
      'CDG': 'Paris Charles de Gaulle',
      'JFK': 'New York JFK',
      'LAX': 'Los Angeles',
      'NRT': 'Tokyo Narita',
      'SIN': 'Singapore Changi',
      'DXB': 'Dubai',
      'BKK': 'Bangkok',
      'HKG': 'Hong Kong',
      'SYD': 'Sydney',
    };
    return cityNames[iataCode] ?? iataCode;
  }
  
  /// Get airline name from IATA code
  String _getAirlineName(String? airlineCode) {
    if (airlineCode == null) return 'Multiple Airlines';
    const airlineNames = {
      '6E': 'IndiGo',
      'AI': 'Air India',
      'SG': 'SpiceJet',
      'UK': 'Vistara',
      'G8': 'Go First',
      'I5': 'AirAsia India',
      'EK': 'Emirates',
      'QR': 'Qatar Airways',
      'SQ': 'Singapore Airlines',
      'TG': 'Thai Airways',
      'BA': 'British Airways',
      'LH': 'Lufthansa',
      'AF': 'Air France',
      'AA': 'American Airlines',
      'UA': 'United Airlines',
      'DL': 'Delta Air Lines',
      'JL': 'Japan Airlines',
      'NH': 'ANA',
      'CX': 'Cathay Pacific',
      'QF': 'Qantas',
    };
    return airlineNames[airlineCode] ?? airlineCode;
  }

  /// Search for trains (simplified - redirects to booking sites)
  Future<Map<String, dynamic>> handleTrainSearch(Map<String, dynamic> args) async {
    final origin = args['origin'] as String?;
    final destination = args['destination'] as String?;
    final date = args['date'] as String?;
    final country = args['country'] as String? ?? _detectRegion(origin, destination);
    
    Logger.d('TrainSearch: $origin -> $destination in $country', tag: 'TransportTool');
    
    // Get region-specific booking services
    final services = _getTrainServices(country);
    
    return {
      'success': true,
      'type': 'train',
      'origin': origin,
      'destination': destination,
      'date': date,
      'region': country,
      'bookingOptions': services,
      'segments': [
        TransportSegment(
          id: 'train_${DateTime.now().millisecondsSinceEpoch}',
          type: TransportType.train,
          origin: origin ?? '',
          destination: destination ?? '',
          departureTime: date ?? '',
          arrivalTime: date ?? '',
          bookingUrl: services.isNotEmpty ? services.first['url'] : null,
          carrier: 'Various Operators',
        ).toJson(),
      ],
      'note': 'Train booking available via regional booking platforms',
    };
  }
  
  /// Search for buses
  Future<Map<String, dynamic>> handleBusSearch(Map<String, dynamic> args) async {
    final origin = args['origin'] as String?;
    final destination = args['destination'] as String?;
    final date = args['date'] as String?;
    final country = args['country'] as String? ?? _detectRegion(origin, destination);
    
    Logger.d('BusSearch: $origin -> $destination in $country', tag: 'TransportTool');
    
    // Get region-specific booking services
    final services = _getBusServices(country);
    
    return {
      'success': true,
      'type': 'bus',
      'origin': origin,
      'destination': destination,
      'date': date,
      'region': country,
      'bookingOptions': services,
      'segments': [
        TransportSegment(
          id: 'bus_${DateTime.now().millisecondsSinceEpoch}',
          type: TransportType.bus,
          origin: origin ?? '',
          destination: destination ?? '',
          departureTime: date ?? '',
          arrivalTime: date ?? '',
          bookingUrl: services.isNotEmpty ? services.first['url'] : null,
          carrier: 'Various Operators',
        ).toJson(),
      ],
      'note': 'Bus booking available via regional booking platforms',
    };
  }
  
  /// Search for taxi/cab services
  Future<Map<String, dynamic>> handleTaxiSearch(Map<String, dynamic> args) async {
    final location = args['location'] as String?;
    final country = args['country'] as String? ?? _detectRegion(location, null);
    
    Logger.d('TaxiSearch: in $location ($country)', tag: 'TransportTool');
    
    // Get region-specific taxi services
    final services = _getTaxiServices(country);
    
    return {
      'success': true,
      'type': 'taxi',
      'location': location,
      'region': country,
      'bookingOptions': services,
      'note': 'Download the app or visit the website to book',
      'localTransport': {
        'recommendation': 'Use ${services.isNotEmpty ? services.first['name'] : 'local taxi apps'} for convenient travel',
        'options': services,
      },
    };
  }
  
  /// Search for car rentals
  Future<Map<String, dynamic>> handleCarRentalSearch(Map<String, dynamic> args) async {
    final location = args['location'] as String?;
    final pickupDate = args['pickupDate'] as String?;
    final dropoffDate = args['dropoffDate'] as String?;
    final country = args['country'] as String? ?? _detectRegion(location, null);
    
    Logger.d('CarRentalSearch: in $location ($country)', tag: 'TransportTool');
    
    // Get region-specific car rental services
    final services = _getCarRentalServices(country);
    
    return {
      'success': true,
      'type': 'carRental',
      'location': location,
      'pickupDate': pickupDate,
      'dropoffDate': dropoffDate,
      'region': country,
      'bookingOptions': services,
      'segments': [
        TransportSegment(
          id: 'car_${DateTime.now().millisecondsSinceEpoch}',
          type: TransportType.car,
          origin: location ?? '',
          destination: location ?? '',
          departureTime: pickupDate ?? '',
          arrivalTime: dropoffDate ?? '',
          bookingUrl: services.isNotEmpty ? services.first['url'] : null,
          carrier: 'Various Rental Companies',
        ).toJson(),
      ],
      'note': 'Compare prices across rental services',
    };
  }
  
  /// Search for ferries
  Future<Map<String, dynamic>> handleFerrySearch(Map<String, dynamic> args) async {
    final origin = args['origin'] as String?;
    final destination = args['destination'] as String?;
    final date = args['date'] as String?;
    final country = args['country'] as String? ?? _detectRegion(origin, destination);
    
    Logger.d('FerrySearch: $origin -> $destination in $country', tag: 'TransportTool');
    
    // Get region-specific ferry services
    final services = _getFerryServices(country);
    
    return {
      'success': true,
      'type': 'ferry',
      'origin': origin,
      'destination': destination,
      'date': date,
      'region': country,
      'bookingOptions': services,
      'segments': [
        TransportSegment(
          id: 'ferry_${DateTime.now().millisecondsSinceEpoch}',
          type: TransportType.ferry,
          origin: origin ?? '',
          destination: destination ?? '',
          departureTime: date ?? '',
          arrivalTime: date ?? '',
          bookingUrl: services.isNotEmpty ? services.first['url'] : null,
          carrier: 'Ferry Operators',
        ).toJson(),
      ],
      'note': 'Ferry booking available via regional booking platforms',
    };
  }
  
  /// Get comprehensive local transport options for a location
  Future<Map<String, dynamic>> handleLocalTransportSearch(Map<String, dynamic> args) async {
    final location = args['location'] as String?;
    final country = args['country'] as String? ?? _detectRegion(location, null);
    
    Logger.d('LocalTransportSearch: in $location ($country)', tag: 'TransportTool');
    
    // Compile all local transport options
    final taxiServices = _getTaxiServices(country);
    final carRentalServices = _getCarRentalServices(country);
    
    // Get metro/public transport info based on location
    final publicTransportInfo = _getPublicTransportInfo(location, country);
    
    return {
      'success': true,
      'location': location,
      'region': country,
      'taxi': taxiServices,
      'carRental': carRentalServices,
      'publicTransport': publicTransportInfo,
      'localTransport': {
        'recommendation': publicTransportInfo['recommendation'] ?? 'Use a mix of public transport and ride-hailing apps',
        'estimatedDailyCost': publicTransportInfo['dailyCost'],
        'currency': publicTransportInfo['currency'] ?? 'INR',
        'tips': publicTransportInfo['tips'],
        'passName': publicTransportInfo['passName'],
        'passUrl': publicTransportInfo['passUrl'],
      },
    };
  }
  
  // ============================================================================
  // HELPER METHODS
  // ============================================================================
  
  /// Detect region from location names
  String _detectRegion(String? origin, String? destination) {
    final combined = '${origin ?? ''} ${destination ?? ''}'.toLowerCase();
    
    // India
    if (_containsAny(combined, ['india', 'delhi', 'mumbai', 'bangalore', 'chennai', 'kolkata', 'hyderabad', 'pune', 'jaipur', 'goa', 'kerala'])) {
      return 'india';
    }
    
    // Japan
    if (_containsAny(combined, ['japan', 'tokyo', 'osaka', 'kyoto', 'nagoya', 'fukuoka', 'sapporo', 'nara', 'hiroshima'])) {
      return 'japan';
    }
    
    // USA
    if (_containsAny(combined, ['usa', 'america', 'united states', 'new york', 'los angeles', 'chicago', 'houston', 'san francisco', 'seattle', 'miami'])) {
      return 'usa';
    }
    
    // Europe
    if (_containsAny(combined, ['europe', 'london', 'paris', 'berlin', 'rome', 'madrid', 'amsterdam', 'barcelona', 'vienna', 'prague', 'brussels', 'munich', 'milan', 'zurich', 'lisbon'])) {
      return 'europe';
    }
    
    return 'default';
  }
  
  bool _containsAny(String text, List<String> keywords) {
    for (final keyword in keywords) {
      if (text.contains(keyword)) return true;
    }
    return false;
  }
  
  List<Map<String, String>> _getTrainServices(String region) {
    return _trainBookingServices[region] ?? _trainBookingServices['default']!;
  }
  
  List<Map<String, String>> _getBusServices(String region) {
    return _busBookingServices[region] ?? _busBookingServices['default']!;
  }
  
  List<Map<String, String>> _getTaxiServices(String region) {
    return _taxiBookingServices[region] ?? _taxiBookingServices['default']!;
  }
  
  List<Map<String, String>> _getCarRentalServices(String region) {
    return _carRentalServices[region] ?? _carRentalServices['default']!;
  }
  
  List<Map<String, String>> _getFerryServices(String region) {
    return _ferryBookingServices[region] ?? _ferryBookingServices['default']!;
  }
  
  /// Get public transport information for specific locations
  Map<String, dynamic> _getPublicTransportInfo(String? location, String region) {
    final loc = (location ?? '').toLowerCase();
    
    // Japan-specific
    if (region == 'japan') {
      if (loc.contains('tokyo')) {
        return {
          'recommendation': 'Get a Suica/Pasmo card for trains and buses',
          'dailyCost': 800,
          'currency': 'JPY',
          'tips': [
            'Suica card works on all JR lines and most metros',
            'Avoid rush hours (7:30-9:30 AM)',
            'Last trains around 12:00 AM',
          ],
          'passName': 'Tokyo Metro 24-hour Pass',
          'passUrl': 'https://www.tokyometro.jp/en/ticket/travel/',
        };
      }
      if (loc.contains('kyoto')) {
        return {
          'recommendation': 'Get Kyoto Bus Day Pass for unlimited bus rides',
          'dailyCost': 700,
          'currency': 'JPY',
          'tips': [
            'Bus is the most convenient for temple hopping',
            'Consider renting a bicycle for Arashiyama',
            'Trains better for longer distances',
          ],
          'passName': 'Kyoto Bus Day Pass',
          'passUrl': 'https://www.city.kyoto.lg.jp/kotsu/page/0000028337.html',
        };
      }
      return {
        'recommendation': 'Consider JR Pass for multiple city travel',
        'dailyCost': 1000,
        'currency': 'JPY',
        'tips': ['IC cards like Suica work nationwide', 'Shinkansen for long distances'],
        'passName': 'JR Pass',
        'passUrl': 'https://www.jrpass.com/',
      };
    }
    
    // India-specific
    if (region == 'india') {
      if (loc.contains('delhi')) {
        return {
          'recommendation': 'Delhi Metro is fastest, Uber/Ola for last mile',
          'dailyCost': 200,
          'currency': 'INR',
          'tips': [
            'Get a Delhi Metro Card for discounts',
            'Avoid autos without meters',
            'Metro Airport Express to airport',
          ],
          'passName': 'Delhi Metro Tourist Card',
          'passUrl': 'https://www.delhimetrorail.com/',
        };
      }
      if (loc.contains('mumbai')) {
        return {
          'recommendation': 'Local trains + Uber/Ola combo works best',
          'dailyCost': 250,
          'currency': 'INR',
          'tips': [
            'Avoid local trains during rush hours',
            'Use Mumbai Metro for North Mumbai',
            'Black-yellow taxis are reliable',
          ],
        };
      }
      return {
        'recommendation': 'Use Uber/Ola for convenience, auto for budget',
        'dailyCost': 300,
        'currency': 'INR',
        'tips': ['Always use app-based cabs for safety', 'Negotiate with autos before boarding'],
      };
    }
    
    // Europe-specific
    if (region == 'europe') {
      if (loc.contains('london')) {
        return {
          'recommendation': 'Get an Oyster Card or use contactless',
          'dailyCost': 15,
          'currency': 'GBP',
          'tips': [
            'Daily cap on Oyster limits spending',
            'Avoid Zone 1 during peak hours',
            'Walking is often faster in central London',
          ],
          'passName': 'Oyster Card',
          'passUrl': 'https://oyster.tfl.gov.uk/',
        };
      }
      if (loc.contains('paris')) {
        return {
          'recommendation': 'Get Paris Visite pass for unlimited metro/bus',
          'dailyCost': 12,
          'currency': 'EUR',
          'tips': [
            'Metro is fastest way around',
            'Keep ticket until end of journey',
            'Buses offer great city views',
          ],
          'passName': 'Paris Visite',
          'passUrl': 'https://www.ratp.fr/',
        };
      }
      return {
        'recommendation': 'Most European cities have excellent public transport',
        'dailyCost': 15,
        'currency': 'EUR',
        'tips': ['Look for tourist day passes', 'Download local transport apps'],
      };
    }
    
    // Default
    return {
      'recommendation': 'Use a mix of public transport and ride-hailing apps',
      'dailyCost': 500,
      'currency': 'INR',
      'tips': ['Check Google Maps for local transport options'],
    };
  }
}
