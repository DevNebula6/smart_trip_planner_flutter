class AppConstants {
  // App Information
  static const String appName = 'Itinera AI';
  static const String appVersion = '1.0.0';
  
  // API Constants
  static const String openAIBaseUrl = 'https://api.openai.com/v1';
  static const String geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static const String searchApiBaseUrl = 'https://www.googleapis.com/customsearch/v1';
  
  // Database Constants
  static const String databaseName = 'smart_trip_planner.db';
  static const int databaseVersion = 1;
  
  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String appThemeKey = 'app_theme';
  
  // Request Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  
  // Token Limits
  static const int maxRequestTokens = 4000;
  static const int maxResponseTokens = 2000;
  
  // Maps
  static const String googleMapsBaseUrl = 'https://maps.google.com';
  static const String appleMapsBaseUrl = 'https://maps.apple.com';
}
