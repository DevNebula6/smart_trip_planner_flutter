import 'dart:convert';
import 'dart:developer';

class Logger {
  static const String _tag = 'SmartTripPlanner';
  
  static void d(String message, {String? tag}) {
    log('[DEBUG] ${tag ?? _tag}: $message');
  }
  
  static void i(String message, {String? tag}) {
    log('[INFO] ${tag ?? _tag}: $message');
  }
  
  static void w(String message, {String? tag}) {
    log('[WARNING] ${tag ?? _tag}: $message');
  }
  
  static void e(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    log('[ERROR] ${tag ?? _tag}: $message', error: error, stackTrace: stackTrace);
  }
  
  static void json(Object? object, {String? tag}) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      final prettyJson = encoder.convert(object);
      log('[JSON] ${tag ?? _tag}:\n$prettyJson');
    } catch (e) {
      log('[JSON] ${tag ?? _tag}: Failed to encode JSON: $e');
    }
  }
}

class ValidationUtils {
  static bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }
  
  static bool isValidPassword(String password) {
    return password.length >= 8;
  }
  
  static bool isValidUrl(String url) {
    try {
      Uri.parse(url);
      return true;
    } catch (_) {
      return false;
    }
  }
}

class FormatUtils {
  static String formatCurrency(double amount, {String currency = 'USD'}) {
    return '\$${amount.toStringAsFixed(2)} $currency';
  }
  
  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  static String formatTime(DateTime time) {
    final hour = time.hour == 0 ? 12 : time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}

class LocationUtils {
  static String formatCoordinates(double lat, double lng) {
    return '$lat,$lng';
  }
  
  static String getGoogleMapsUrl(double lat, double lng, {String? label}) {
    final coords = formatCoordinates(lat, lng);
    final labelParam = label != null ? '($label)' : '';
    return 'https://www.google.com/maps/search/?api=1&query=$coords$labelParam';
  }
  
  static String getAppleMapsUrl(double lat, double lng, {String? label}) {
    final coords = formatCoordinates(lat, lng);
    return 'https://maps.apple.com/?q=$coords';
  }
}
