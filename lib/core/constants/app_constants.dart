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
  
  // ===== STORAGE CONFIGURATION =====
  
  /// Maximum retry attempts for Hive box operations
  static const int storageMaxRetries = 3;
  
  /// Session validity duration in days
  static const int sessionRetentionDays = 90;
  
  // ===== TIMING CONFIGURATION =====
  
  /// Debounce delay for session saves (milliseconds)
  static const int sessionSaveDebounceMs = 300;
  
  /// Delay for UI refresh after navigation (milliseconds)
  static const int uiRefreshDelayMs = 500;
  
  /// Short delay for UI refresh (milliseconds)
  static const int shortUiRefreshDelayMs = 300;
  
  /// Timeout for AI requests (seconds)
  static const int aiRequestTimeoutSeconds = 45;
  
  /// Timeout for function responses (seconds)
  static const int functionResponseTimeoutSeconds = 30;
  
  /// Timeout for web search requests (seconds)
  static const int webSearchTimeoutSeconds = 10;
  
  // ===== AI CONFIGURATION =====
  
  /// Temperature setting for AI responses
  static const double aiTemperature = 0.7;
  
  /// Top K sampling parameter
  static const int aiTopK = 40;
  
  /// Top P sampling parameter
  static const double aiTopP = 0.95;
  
  /// Maximum output tokens
  static const int aiMaxOutputTokens = 4096;
  
  // ===== TOKEN COST CALCULATION =====
  
  /// Gemini 2.5 Flash input cost per 1M tokens (USD)
  static const double geminiInputCostPer1M = 0.30;
  
  /// Gemini 2.5 Flash output cost per 1M tokens (USD)
  static const double geminiOutputCostPer1M = 2.50;
  
  /// Average cost per 1M tokens for savings calculation (USD)
  static const double geminiAvgCostPer1M = 1.40;
  
  /// Estimated tokens per character (rough approximation)
  static const double tokensPerCharacter = 0.25; // 1 token ≈ 4 characters
  
  // ===== SESSION REUSE METRICS =====
  
  /// Percentage of context tokens saved through session reuse
  static const double sessionReuseTokenSavingsPercent = 0.9; // 90%
  
  /// Average context tokens per session
  static const int averageContextTokens = 1000;
}

