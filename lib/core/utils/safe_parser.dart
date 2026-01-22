/// Safe type conversion utilities for handling dynamic JSON data.
/// Provides null-safe parsing methods that handle various input types gracefully.
class SafeParser {
  SafeParser._();

  /// Safely parse an integer from various input types
  static int? parseInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Safely parse an integer with a default value
  static int parseIntOr(Object? value, int defaultValue) {
    return parseInt(value) ?? defaultValue;
  }

  /// Safely parse a double from various input types
  static double? parseDouble(Object? value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Safely parse a double with a default value
  static double parseDoubleOr(Object? value, double defaultValue) {
    return parseDouble(value) ?? defaultValue;
  }

  /// Safely parse a boolean from various input types
  static bool? parseBool(Object? value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1' || lower == 'yes') return true;
      if (lower == 'false' || lower == '0' || lower == 'no') return false;
    }
    if (value is num) return value != 0;
    return null;
  }

  /// Safely parse a boolean with a default value
  static bool parseBoolOr(Object? value, bool defaultValue) {
    return parseBool(value) ?? defaultValue;
  }

  /// Safely parse a string from various input types
  static String? parseString(Object? value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    return value.toString();
  }

  /// Safely parse a string with a default value
  static String parseStringOr(Object? value, String defaultValue) {
    return parseString(value) ?? defaultValue;
  }

  /// Safely parse a DateTime from various input types
  static DateTime? parseDateTime(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) {
      // Assume milliseconds since epoch
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return null;
  }

  /// Safely parse a list of strings from various input types
  static List<String>? parseStringList(Object? value) {
    if (value == null) return null;
    if (value is List) {
      return value
          .map((e) => parseString(e))
          .whereType<String>()
          .toList();
    }
    return null;
  }

  /// Safely cast a map from dynamic
  static Map<String, dynamic>? parseMap(Object? value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), v));
    }
    return null;
  }
}
