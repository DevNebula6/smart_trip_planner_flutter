/// **Service Configuration Constants**
/// 
/// Centralized configuration for all services in the application
/// Following clean architecture principles with environment-based configs

/// **AI Service Configuration**
class AIConfig {
  AIConfig._(); // Private constructor
  
  // Gemini Model Configuration
  static const String defaultModel = 'gemini-2.0-flash-exp';
  static const double temperature = 0.7;
  static const int topK = 40;
  static const double topP = 0.95;
  static const int maxOutputTokens = 2048;
  
  // Session Management
  static const Duration sessionMaxAge = Duration(days: 90);
  static const Duration saveDebounceDelay = Duration(milliseconds: 300);
  static const int maxHistoryLength = 50;
  static const Duration requestTimeout = Duration(minutes: 2);
  
  // Token Optimization
  static const double costPer1kTokens = 0.03;
  static const int expectedTokenSavingsPercent = 90;
}

/// **Storage Service Configuration**
class StorageConfig {
  StorageConfig._(); // Private constructor
  
  // Hive Configuration
  static const String appName = 'smart_trip_planner';
  static const int maxRetries = 3;
  
  // Box Names - Organized by domain
  static const String sessionsBox = 'sessions';
  static const String itinerariesBox = 'itineraries'; 
  static const String messagesBox = 'messages';
  static const String metadataBox = 'metadata';
  
  // Cleanup Configuration
  static const Duration cleanupInterval = Duration(hours: 24);
  static const int maxInactiveSessions = 100;
  
  // Performance Configuration
  static const bool enableLazyLoading = true;
  static const bool enableAutoCompaction = true;
}

/// **Authentication Configuration**
class AuthConfig {
  AuthConfig._(); // Private constructor
  
  // Session Keys
  static const String currentUserKey = 'current_auth_user';
  static const String registeredUsersKey = 'registered_users';
  
  // Security
  static const Duration sessionTimeout = Duration(days: 30);
  static const int maxLoginAttempts = 5;
}

/// **Logging Configuration** 
class LogConfig {
  LogConfig._(); // Private constructor
  
  // Tags for different components
  static const String hiveStorage = 'HiveStorage';
  static const String geminiAI = 'GeminiAI';
  static const String mockAuth = 'MockAuth';
  static const String homeBloc = 'HomeBloc';
  static const String main = 'Main';
  
  // Log Levels (for future configuration)
  static const bool enableDebugLogs = true;
  static const bool enableErrorLogs = true;
  static const bool enableInfoLogs = true;
}

/// **Performance Configuration**
class PerformanceConfig {
  PerformanceConfig._(); // Private constructor
  
  // Memory Management
  static const int maxCachedSessions = 20;
  static const Duration cacheTimeout = Duration(minutes: 10);
  
  // Network Configuration  
  static const Duration networkTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  
  // UI Performance
  static const Duration animationDuration = Duration(milliseconds: 250);
  static const Duration debounceDelay = Duration(milliseconds: 500);
}

/// **Service Status Enums**
enum ServiceStatus {
  uninitialized,
  initializing, 
  ready,
  error,
  maintenance
}

enum StorageStatus {
  closed,
  opening,
  open,
  error
}

enum AIServiceStatus {
  idle,
  processing,
  streaming,
  error,
  rateLimited
}

/// **Service Result Types**
class ServiceResult<T> {
  final bool isSuccess;
  final T? data;
  final String? error;
  final ServiceStatus status;
  
  const ServiceResult.success(this.data)
      : isSuccess = true,
        error = null,
        status = ServiceStatus.ready;
        
  const ServiceResult.failure(this.error)
      : isSuccess = false,
        data = null,
        status = ServiceStatus.error;
        
  const ServiceResult.loading()
      : isSuccess = false,
        data = null,
        error = null,
        status = ServiceStatus.initializing;
}
