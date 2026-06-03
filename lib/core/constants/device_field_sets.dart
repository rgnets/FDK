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
    'mac', // Canonical MAC column for AP / ONT / switch records
    'scratch', // Legacy: early switch prototypes stored MAC here; read as fallback
    'pms_room', // AP / ONT singular belongs_to (room nested as {id, name})
    'pms_rooms', // SwitchDevice HABTM (rooms nested as [{id, room}, ...])
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

  /// Fields requested by the initial REST inventory seed.
  ///
  /// The seed populates the in-memory + typed device caches that back the list
  /// view AND any screen that reads device data WITHOUT re-fetching. The rXg
  /// serializes every requested column/association per record server-side, so
  /// requesting the full record makes a 1000-row access_points page too heavy
  /// to return inside the seed timeout (APs end up dropped entirely). This set
  /// is [listFields] plus the handful of fields whose consumers do NOT refetch:
  ///   - `ap_onboarding_status` / `ont_onboarding_status`: room-readiness reads
  ///     these straight off the seeded cache (no per-device refetch), so they
  ///     must be seeded or onboarding status goes null.
  ///   - `model` / `serial_number` / `firmware` / `version` / `phase`: cheap
  ///     scalars used by list filters and headers off the seeded cache.
  /// Detail-only data (perf metrics, cpu/mem/temp, vlan, totals) is intentionally
  /// excluded — the detail screen refetches full records ([detailFields]) on open.
  static const List<String> seedFields = [
    ...listFields,
    'ap_onboarding_status',
    'ont_onboarding_status',
    'model',
    'serial_number',
    'firmware',
    'version',
    'phase',
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
