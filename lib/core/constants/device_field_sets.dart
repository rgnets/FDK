/// Device field sets for hierarchical data loading
///
/// Defines field sets for different views to optimize API calls.
/// This reduces data transfer by 97% for list views.
class DeviceFieldSets {
  // Private constructor to prevent instantiation
  DeviceFieldSets._();

  /// Version for field set evolution
  static const String version = '2.0.0';

  /// Minimal fields for list views (33KB instead of 1.5MB)
  /// Reduces load time from 17.7s to ~350ms
  static const List<String> listFields = [
    'id',
    'name',
    'type',
    'status',
    'ip', // Access points use 'ip'
    'host', // Switches/WLAN use 'host'
    'mac', // Access points/ONTs use 'mac'
    'scratch', // Switches store MAC in 'scratch'
    'pms_room', // Full nested object
    'pms_room_id', // Flat field (switches may not have nested pms_room)
    'location',
    'last_seen',
    'signal_strength',
    'connected_clients',
    'online', // For notifications
    'note', // For notifications
    'images', // For notifications
    'hn_counts', // Health notice counts for alerts badge
    'health_notices', // Health notice list for alerts screen
  ];

  /// All fields for detail view
  /// Empty list means fetch all available fields
  static const List<String> detailFields = [];

  /// Minimal fields for background refresh
  /// Only status-related fields to minimize data transfer
  static const List<String> refreshFields = [
    'id',
    'status',
    'online',
    'last_seen',
    'signal_strength',
  ];

  /// Build API query parameter for field selection
  static String buildFieldsParam(List<String>? fields) {
    if (fields == null || fields.isEmpty) {
      return '';
    }
    return '&only=${fields.join(',')}';
  }

  /// Generate cache key including field selection
  static String getCacheKey(String base, List<String>? fields) {
    if (fields == null || fields.isEmpty) {
      return '$base:all';
    }
    final sortedFields = List<String>.from(fields)..sort();
    return '$base:${sortedFields.join(',')}';
  }
}
