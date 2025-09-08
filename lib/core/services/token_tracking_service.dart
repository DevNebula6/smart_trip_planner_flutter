import 'package:smart_trip_planner_flutter/core/storage/hive_storage_service.dart';
import '../../core/utils/helpers.dart';

/// Global token tracking service for cost awareness
class TokenTrackingService {
  static final TokenTrackingService _instance = TokenTrackingService._internal();
  factory TokenTrackingService() => _instance;
  TokenTrackingService._internal();

  final HiveStorageService _storage = HiveStorageService.instance;
  static const String _tokenStatsKey = 'global_token_stats';
  
  // Global token tracking (persisted)
  int _totalRequestTokens = 0;
  int _totalResponseTokens = 0;
  int _totalRequests = 0;
  double _totalCost = 0.0;

  // Initialize from storage
  Future<void> init() async {
    try {
      final saved = await _storage.getMetadata(_tokenStatsKey);
      if (saved != null) {
        _totalRequestTokens = (saved['request_tokens'] as num?)?.toInt() ?? 0;
        _totalResponseTokens = (saved['response_tokens'] as num?)?.toInt() ?? 0;
        _totalRequests = (saved['total_requests'] as num?)?.toInt() ?? 0;
        _totalCost = (saved['total_cost'] as num?)?.toDouble() ?? 0.0;
        
        Logger.d('Token stats loaded: ${_totalRequests} requests, ${totalTokens} tokens, \$${_totalCost.toStringAsFixed(4)}', tag: 'TokenTracking');
      }
    } catch (e) {
      Logger.e('Failed to load token stats: $e', tag: 'TokenTracking');
    }
  }

  // Add token usage from API calls
  void addUsage({
    required int promptTokens,
    required int completionTokens,
    required double cost,
  }) {
    _totalRequestTokens += promptTokens;
    _totalResponseTokens += completionTokens;
    _totalRequests += 1;
    _totalCost += cost;

    Logger.d('Token usage added: ${promptTokens} prompt + ${completionTokens} completion = ${promptTokens + completionTokens} total tokens, \$${cost.toStringAsFixed(4)} cost', tag: 'TokenTracking');
    
    // Save to storage
    _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    try {
      await _storage.saveMetadata(_tokenStatsKey, {
        'request_tokens': _totalRequestTokens,
        'response_tokens': _totalResponseTokens,
        'total_requests': _totalRequests,
        'total_cost': _totalCost,
        'last_updated': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      Logger.e('Failed to save token stats: $e', tag: 'TokenTracking');
    }
  }

  // Reset all stats
  Future<void> reset() async {
    _totalRequestTokens = 0;
    _totalResponseTokens = 0;
    _totalRequests = 0;
    _totalCost = 0.0;
    
    await _storage.saveMetadata(_tokenStatsKey, {});
    Logger.d('Token stats reset', tag: 'TokenTracking');
  }

  // Getters for UI display
  int get totalTokens => _totalRequestTokens + _totalResponseTokens;
  int get requestTokens => _totalRequestTokens;
  int get responseTokens => _totalResponseTokens;
  int get totalRequests => _totalRequests;
  double get totalCost => _totalCost;

  // Format for display
  String get formattedCost => '\$${_totalCost.toStringAsFixed(4)} USD';
  String get formattedTokenCount => '${totalTokens.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
}
