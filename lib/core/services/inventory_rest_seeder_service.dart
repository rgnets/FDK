import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/services/secure_http_client.dart';
import 'package:rgnets_fdk/core/utils/log_redaction.dart' as log_redaction;

/// Outcome of one resource's seed attempt.
class SeedOutcome {
  const SeedOutcome({
    required this.resourceType,
    required this.success,
    required this.itemCount,
    this.statusCode,
    this.error,
  });

  final String resourceType;
  final bool success;
  final int itemCount;
  final int? statusCode;
  final String? error;
}

/// Aggregate result of a seed pass — one [SeedOutcome] per resource attempted.
class SeedResult {
  const SeedResult(this.outcomes);
  final List<SeedOutcome> outcomes;

  bool get allSucceeded => outcomes.every((o) => o.success);
  int get totalItems => outcomes.fold(0, (s, o) => s + o.itemCount);
}

/// Callback shape used by the seeder to push results into the existing
/// device/room cache services. Kept as a function reference (not a hard
/// dependency on `WebSocketDeviceCacheService` / `WebSocketRoomCacheService`)
/// so the seeder is trivial to unit-test in isolation and the wiring layer
/// can decide whether to apply the snapshot, queue it, or discard it.
///
/// `FutureOr<void>` so callers can run async validation (e.g. an auth-context
/// check that consults secure storage) inside the callback; the seeder
/// awaits before recording the outcome.
typedef SeedDeviceApply = FutureOr<void> Function(
  String resourceType,
  List<Map<String, dynamic>> items,
);
typedef SeedRoomApply = FutureOr<void> Function(List<Map<String, dynamic>> items);

/// Fetches the full inventory of paging-sensitive resources via REST at
/// sign-in, then pushes the results into the existing WS cache services.
///
/// Why REST instead of WS for the initial inventory load:
///   - rxg's `RxgChannel#resource_action` is rate-limited at 100 req/60s
///     per user_key (see `~/Git/RXG/console/app/channels/rxg_channel.rb:418`).
///     Rapid sign-in/sign-out cycles can exhaust the bucket before the
///     paged WS index path completes, freezing the inventory mid-load.
///   - The WS handler on large sites can degrade into a streaming-upserts
///     codepath that only broadcasts polled-online devices, leaving offline
///     devices invisible to the app. REST returns the full inventory.
///
/// WS subscriptions and `action=updated` upserts remain authoritative for
/// LIVE state changes after the seed. The seeder fires once per sign-in.
class InventoryRestSeederService {
  InventoryRestSeederService({
    required String siteUrl,
    required this.apiKey,
    http.Client? client,
  })  : siteUrl = _normalizeSiteUrl(siteUrl),
        _client = client ?? SecureHttpClient.getClient();

  final String siteUrl;
  final String apiKey;
  final http.Client _client;

  static const _tag = 'InventoryRestSeederService';
  static const _timeout = Duration(seconds: 30);

  /// Resource types served via REST seed. Matches the paged set we previously
  /// tried to fetch over WS `resource_action index`. Order is intentional:
  /// access_points first because the UI binds device count off it.
  static const List<String> deviceResourceTypes = [
    'access_points',
    'switch_devices',
    'media_converters',
    // WLAN controllers are a first-class device type held in the typed SQLite
    // caches (the in-memory WSCI device cache does not model them). Seed them
    // over REST so the device repo's fallback isn't missing a device class.
    'wlan_devices',
  ];
  static const String roomResourceType = 'pms_rooms';

  static String _normalizeSiteUrl(String url) {
    var normalized = url;
    if (normalized.startsWith('https://')) {
      normalized = normalized.substring(8);
    } else if (normalized.startsWith('http://')) {
      normalized = normalized.substring(7);
    }
    if (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return normalized;
  }

  Uri _api(String resourceFile) => Uri.parse(
        'https://$siteUrl/api/$resourceFile?api_key=$apiKey&per_page=10000',
      );

  /// Fire one parallel batch of GETs and apply each successful result to the
  /// caller-provided cache callbacks. Per-resource failures are tolerated —
  /// one bad endpoint does not block the others.
  Future<SeedResult> seedAll({
    required SeedDeviceApply onDevices,
    required SeedRoomApply onRooms,
  }) async {
    LoggerService.info(
      'Starting REST seed for ${deviceResourceTypes.length} device types + rooms',
      tag: _tag,
    );
    final futures = <Future<SeedOutcome>>[
      for (final type in deviceResourceTypes) seedDeviceResource(type, onDevices),
      seedRoomResource(onRooms),
    ];
    final outcomes = await Future.wait(futures);
    final total = outcomes.fold<int>(0, (s, o) => s + o.itemCount);
    LoggerService.info(
      'REST seed complete: ${outcomes.where((o) => o.success).length}/${outcomes.length} '
      'resources, $total total items',
      tag: _tag,
    );
    return SeedResult(outcomes);
  }

  /// Seed a single device resource type (access_points / switch_devices /
  /// media_converters) via REST and apply it to the cache. Public so a
  /// targeted reseed (e.g. after a registration write) can refresh just one
  /// resource without re-fetching the entire inventory.
  Future<SeedOutcome> seedDeviceResource(
    String resourceType,
    SeedDeviceApply onDevices,
  ) async {
    final uri = _api('$resourceType.json');
    LoggerService.debug('GET ${_scrub(uri)}', tag: _tag);
    final fetch = await _fetchList(uri, resourceType);
    if (fetch.items == null) {
      return SeedOutcome(
        resourceType: resourceType,
        success: false,
        itemCount: 0,
        statusCode: fetch.statusCode,
        error: fetch.error,
      );
    }
    try {
      await onDevices(resourceType, fetch.items!);
    } on Object catch (e) {
      LoggerService.error(
        'Apply $resourceType to device cache failed: ${_safeError(e)}',
        tag: _tag,
      );
      return SeedOutcome(
        resourceType: resourceType,
        success: false,
        itemCount: fetch.items!.length,
        statusCode: fetch.statusCode,
        error: _safeError(e),
      );
    }
    LoggerService.info(
      'Seeded $resourceType: ${fetch.items!.length} items',
      tag: _tag,
    );
    return SeedOutcome(
      resourceType: resourceType,
      success: true,
      itemCount: fetch.items!.length,
      statusCode: fetch.statusCode,
    );
  }

  /// Seed the rooms resource via REST and apply it to the cache. Public for
  /// targeted single-resource reseed (see [seedDeviceResource]).
  Future<SeedOutcome> seedRoomResource(SeedRoomApply onRooms) async {
    final uri = _api('$roomResourceType.json');
    LoggerService.debug('GET ${_scrub(uri)}', tag: _tag);
    final fetch = await _fetchList(uri, roomResourceType);
    if (fetch.items == null) {
      return SeedOutcome(
        resourceType: roomResourceType,
        success: false,
        itemCount: 0,
        statusCode: fetch.statusCode,
        error: fetch.error,
      );
    }
    try {
      await onRooms(fetch.items!);
    } on Object catch (e) {
      LoggerService.error(
        'Apply $roomResourceType to room cache failed: ${_safeError(e)}',
        tag: _tag,
      );
      return SeedOutcome(
        resourceType: roomResourceType,
        success: false,
        itemCount: fetch.items!.length,
        statusCode: fetch.statusCode,
        error: _safeError(e),
      );
    }
    LoggerService.info(
      'Seeded $roomResourceType: ${fetch.items!.length} items',
      tag: _tag,
    );
    return SeedOutcome(
      resourceType: roomResourceType,
      success: true,
      itemCount: fetch.items!.length,
      statusCode: fetch.statusCode,
    );
  }

  /// GET [uri] and extract the result list. Returns a [_FetchResult] whose
  /// `items` is `null` for any failure (non-200, parse error, unknown shape,
  /// network exception). `statusCode` is set whenever the HTTP layer
  /// produced a response.
  Future<_FetchResult> _fetchList(Uri uri, String resourceType) async {
    final http.Response response;
    try {
      response = await _client.get(uri).timeout(_timeout);
    } on Object catch (e) {
      final scrubbed = _safeError(e);
      LoggerService.warning(
        '$resourceType fetch failed: $scrubbed',
        tag: _tag,
      );
      return _FetchResult(error: scrubbed);
    }
    if (response.statusCode != 200) {
      LoggerService.warning(
        '$resourceType returned status ${response.statusCode}',
        tag: _tag,
      );
      return _FetchResult(statusCode: response.statusCode);
    }
    final dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException catch (e) {
      LoggerService.warning(
        '$resourceType body parse failed: ${e.message}',
        tag: _tag,
      );
      return _FetchResult(statusCode: response.statusCode, error: e.message);
    }
    final list = _extractList(decoded);
    if (list == null) {
      LoggerService.warning(
        '$resourceType unrecognized body shape',
        tag: _tag,
      );
      return _FetchResult(
        statusCode: response.statusCode,
        error: 'unrecognized body shape',
      );
    }
    return _FetchResult(
      items: list.whereType<Map<String, dynamic>>().toList(),
      statusCode: response.statusCode,
    );
  }

  /// rxg's REST list endpoints emit one of three shapes:
  ///   - bare array `[...]`
  ///   - `{"records": [...]}`
  ///   - `{"results": [...], "count":..., "page":..., ...}`
  static List<dynamic>? _extractList(dynamic body) {
    if (body is List) return body;
    if (body is Map<String, dynamic>) {
      final records = body['records'];
      if (records is List) return records;
      final results = body['results'];
      if (results is List) return results;
    }
    return null;
  }

  static String _scrub(Uri uri) =>
      log_redaction.scrubUrlForLog(uri) ?? uri.toString();

  /// `http.ClientException` and TimeoutException can include the full
  /// request URL in their message — which on our REST calls always
  /// contains `?api_key=...`. Scrub before truncating.
  static String _safeError(Object e) {
    final scrubbed = log_redaction.scrubErrorForLog(e);
    return scrubbed.length > 200 ? '${scrubbed.substring(0, 200)}…' : scrubbed;
  }
}

/// Internal carrier for `_fetchList` so the seeder methods can populate
/// [SeedOutcome.statusCode] on non-200 responses without losing the
/// "items unavailable" signal.
class _FetchResult {
  _FetchResult({this.items, this.statusCode, this.error});
  final List<Map<String, dynamic>>? items;
  final int? statusCode;
  final String? error;
}
