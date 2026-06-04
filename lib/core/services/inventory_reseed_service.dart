import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/providers/websocket_sync_providers.dart';
import 'package:rgnets_fdk/core/services/inventory_rest_seeder_service.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/services/websocket_device_cache_service.dart';
import 'package:rgnets_fdk/features/auth/presentation/providers/auth_notifier.dart';

/// Per-resource outcome of a reseed, streamed live so the startup loader can
/// render a checklist as each resource finishes (rather than waiting for the
/// whole batch). [done] carries the item count; [failed] means the REST fetch
/// or cache-apply for that resource did not succeed.
enum ReseedResourceStatus { done, failed }

/// A single live progress event from [InventoryReseedService.progress].
class ReseedProgress {
  const ReseedProgress({
    required this.resourceType,
    required this.status,
    this.count = 0,
  });

  /// Matches [InventoryRestSeederService] resource types, e.g. `access_points`,
  /// `switch_devices`, `media_converters`, `wlan_devices`, `pms_rooms`.
  final String resourceType;
  final ReseedResourceStatus status;

  /// Number of items applied to the cache (only meaningful when [status] is
  /// [ReseedResourceStatus.done]).
  final int count;
}

/// Owns full-inventory loading over REST and is the single entry point for
/// (re)seeding the device/room caches.
///
/// Full inventory is fetched over REST (plain HTTPS) — deliberately OFF the
/// AnyCable gRPC path — so it never competes with WebSocket write actions like
/// `register_ap_device` for the rXg's bounded gRPC worker pool. The WebSocket
/// layer keeps `subscribe_to_resource` for live `action=updated`/`destroyed`
/// deltas; it no longer issues `index` snapshots.
///
/// Dedup/throttle policy (all owned here, not in Auth or the WS layer):
///   - one full seed in flight at a time (concurrent calls are dropped);
///   - a [_cooldown] between completed full seeds, so reconnect flaps don't
///     trigger repeated full fetches;
///   - a trailing reseed: if a request arrives while a seed that *started
///     before* this request is running, exactly one more seed runs after it,
///     so deltas missed during a disconnect gap are still recovered.
class InventoryReseedService {
  InventoryReseedService(this._ref);

  final Ref _ref;

  static const Duration _cooldown = Duration(seconds: 15);
  static const String _tag = 'InventoryReseed';

  bool _seedInFlight = false;
  bool _trailingRequested = false;
  Future<void>? _inFlightSeed;
  DateTime? _lastSeedCompletedAt;

  /// Broadcasts per-resource progress for the active full seed. Broadcast so
  /// the startup loader can subscribe/unsubscribe per init without affecting
  /// background reseeds. Never closed — this service is keep-alive.
  final StreamController<ReseedProgress> _progressController =
      StreamController<ReseedProgress>.broadcast();

  /// Live per-resource progress of full seeds (see [ReseedProgress]).
  Stream<ReseedProgress> get progress => _progressController.stream;

  void _emitProgress(ReseedProgress event) {
    if (!_progressController.isClosed) {
      _progressController.add(event);
    }
  }

  /// Request a full REST reseed of the device + room caches. Coalesced and
  /// throttled per the class policy. [reason] is for logging only.
  ///
  /// [force] bypasses the [_cooldown] (but NOT the in-flight guard). Explicit/
  /// programmatic loads — sign-in, the repurposed manual `requestFullSnapshots`,
  /// and the trailing reseed — pass `force: true` so they are never suppressed
  /// by a recently-completed seed (e.g. on rapid re-login or site switch, where
  /// the cache was just cleared and MUST be repopulated). Automatic reconnect
  /// heals pass `force: false` so connection flaps stay throttled.
  ///
  /// [coalesceWhenInFlight] controls what happens when a seed is ALREADY
  /// running. Only genuine reconnect-after-gap recovery sets it `true`: the
  /// in-flight seed may have started before the gap and missed deltas, so a
  /// trailing seed is queued to run afterward. Every other caller just wants
  /// fresh full inventory — which the in-flight seed already produces — so they
  /// default to *joining* (awaiting) it rather than queuing a redundant second
  /// full fetch. This is what keeps a boot where both the first-connect seed
  /// and the `init` seed fire from running the whole inventory twice (~2×10s);
  /// the blocking `init` caller still awaits the single in-flight seed, so the
  /// startup loader holds the technician out until inventory is actually ready.
  Future<void> triggerReseed({
    required String reason,
    bool force = false,
    bool coalesceWhenInFlight = false,
  }) async {
    if (_seedInFlight) {
      if (coalesceWhenInFlight) {
        // A reconnect landed mid-seed; ensure one more runs afterward so deltas
        // missed during the disconnect gap are still recovered.
        _trailingRequested = true;
        LoggerService.debug(
          'Reseed ($reason) folded into trailing request (seed in flight)',
          tag: _tag,
        );
        return;
      }
      // A full seed is already running and produces complete inventory; join it
      // instead of queuing a redundant second full fetch. Awaiting keeps
      // blocking callers (the startup loader's `init` seed) holding the
      // technician out until the inventory is seeded.
      LoggerService.debug(
        'Reseed ($reason) joined in-flight seed',
        tag: _tag,
      );
      await _inFlightSeed;
      return;
    }

    final last = _lastSeedCompletedAt;
    if (!force && last != null && DateTime.now().difference(last) < _cooldown) {
      LoggerService.debug(
        'Reseed ($reason) skipped — within ${_cooldown.inSeconds}s cooldown',
        tag: _tag,
      );
      return;
    }

    _seedInFlight = true;
    final seed = _runFullSeed(reason);
    _inFlightSeed = seed;
    try {
      await seed;
    } finally {
      _lastSeedCompletedAt = DateTime.now();
      _seedInFlight = false;
      _inFlightSeed = null;
    }

    if (_trailingRequested) {
      _trailingRequested = false;
      LoggerService.debug('Running trailing reseed (background)', tag: _tag);
      // Fire-and-forget: the trailing reseed is a delta-recovery safety net for
      // deltas missed during a disconnect gap. It must NOT block the caller —
      // notably the startup loader's `init` seed, which would otherwise hold the
      // technician behind a second full inventory fetch even though the first
      // seed already populated everything. Run it detached so callers are
      // released as soon as the first full seed is applied and persisted.
      // force: runs immediately after the previous seed, so it would otherwise
      // always be suppressed by the cooldown.
      // coalesceWhenInFlight: a reconnect during the trailing seed should queue
      // yet another recovery seed, matching the pre-existing recovery chain.
      unawaited(
        triggerReseed(
          reason: 'trailing',
          force: true,
          coalesceWhenInFlight: true,
        ).catchError((Object e, StackTrace st) {
          LoggerService.warning('Trailing reseed failed: $e', tag: _tag);
        }),
      );
    }
  }

  /// Reseed a single resource over REST (e.g. after a registration write or an
  /// image upload) without re-fetching the whole inventory.
  Future<void> triggerResourceReseed(String resourceType) async {
    final creds = await _credentialsIfFresh();
    if (creds == null) {
      return;
    }
    final seeder = InventoryRestSeederService(
      siteUrl: creds.siteUrl,
      apiKey: creds.apiKey,
    );
    final wsci = _ref.read(webSocketCacheIntegrationProvider);
    final dataSync = _ref.read(webSocketDataSyncServiceProvider);
    try {
      if (resourceType == InventoryRestSeederService.roomResourceType) {
        await seeder.seedRoomResource((items) async {
          if (await _staleReason(creds) != null) {
            return;
          }
          wsci.roomCacheService.applySnapshot(items);
          await dataSync.applyRestRoomSnapshot(items);
        });
      } else if (resourceType ==
          InventoryRestSeederService.speedTestResourceType) {
        await seeder.seedSpeedTestResource((items) async {
          if (await _staleReason(creds) != null) {
            return;
          }
          wsci.speedTestCacheService.applySnapshot(items, isConfig: true);
        });
      } else if (resourceType ==
          InventoryRestSeederService.speedTestResultResourceType) {
        await seeder.seedSpeedTestResultResource((items) async {
          if (await _staleReason(creds) != null) {
            return;
          }
          wsci.speedTestCacheService.applySnapshot(items, isConfig: false);
        });
      } else {
        await seeder.seedDeviceResource(resourceType, (type, items) async {
          if (await _staleReason(creds) != null) {
            return;
          }
          if (WebSocketDeviceCacheService.isDeviceResourceType(type)) {
            wsci.deviceCacheService.applySnapshot(type, items);
          }
          await dataSync.applyRestDeviceSnapshot(type, items);
        });
      }
      await dataSync.flushTypedCaches();
    } on Object catch (e) {
      LoggerService.warning(
        'Targeted reseed for $resourceType failed: $e',
        tag: _tag,
      );
    }
  }

  Future<void> _runFullSeed(String reason) async {
    final creds = await _credentialsIfFresh();
    if (creds == null) {
      LoggerService.debug('Reseed ($reason) skipped — no fresh credentials', tag: _tag);
      return;
    }
    LoggerService.info('Starting full REST reseed ($reason)', tag: _tag);
    final seeder = InventoryRestSeederService(
      siteUrl: creds.siteUrl,
      apiKey: creds.apiKey,
    );
    final wsci = _ref.read(webSocketCacheIntegrationProvider);
    final dataSync = _ref.read(webSocketDataSyncServiceProvider);
    try {
      final result = await seeder.seedAll(
        onDevices: (resourceType, items) async {
          final stale = await _staleReason(creds);
          if (stale != null) {
            LoggerService.warning(
              'Dropping stale reseed for $resourceType — $stale',
              tag: _tag,
            );
            return;
          }
          // Feed BOTH caches from one REST fetch: the in-memory WSCI cache
          // (primary read path) and the typed SQLite caches (offline/cold-start
          // fallback the device repo falls back to). Only resource types the
          // WSCI device cache actually models go in-memory (e.g. wlan_devices
          // is typed-cache-only); all device types go to the typed caches.
          if (WebSocketDeviceCacheService.isDeviceResourceType(resourceType)) {
            wsci.deviceCacheService.applySnapshot(resourceType, items);
          }
          await dataSync.applyRestDeviceSnapshot(resourceType, items);
          _emitProgress(
            ReseedProgress(
              resourceType: resourceType,
              status: ReseedResourceStatus.done,
              count: items.length,
            ),
          );
        },
        onRooms: (items) async {
          final stale = await _staleReason(creds);
          if (stale != null) {
            LoggerService.warning('Dropping stale reseed for rooms — $stale', tag: _tag);
            return;
          }
          wsci.roomCacheService.applySnapshot(items);
          await dataSync.applyRestRoomSnapshot(items);
          _emitProgress(
            ReseedProgress(
              resourceType: InventoryRestSeederService.roomResourceType,
              status: ReseedResourceStatus.done,
              count: items.length,
            ),
          );
        },
        onSpeedTests: (items) async {
          final stale = await _staleReason(creds);
          if (stale != null) {
            LoggerService.warning(
                'Dropping stale reseed for speed_tests — $stale', tag: _tag);
            return;
          }
          // Speed-test configs live only in the in-memory WS cache (no typed
          // SQLite fallback), so applying the snapshot there is the whole job.
          wsci.speedTestCacheService.applySnapshot(items, isConfig: true);
          _emitProgress(
            ReseedProgress(
              resourceType: InventoryRestSeederService.speedTestResourceType,
              status: ReseedResourceStatus.done,
              count: items.length,
            ),
          );
        },
        onSpeedTestResults: (items) async {
          final stale = await _staleReason(creds);
          if (stale != null) {
            LoggerService.warning(
                'Dropping stale reseed for speed_test_results — $stale',
                tag: _tag);
            return;
          }
          wsci.speedTestCacheService.applySnapshot(items, isConfig: false);
          _emitProgress(
            ReseedProgress(
              resourceType:
                  InventoryRestSeederService.speedTestResultResourceType,
              status: ReseedResourceStatus.done,
              count: items.length,
            ),
          );
        },
      );
      // Surface any resource whose fetch/apply failed so the loader can mark
      // it (the success callbacks above never fired for these).
      for (final outcome in result.outcomes) {
        if (!outcome.success) {
          _emitProgress(
            ReseedProgress(
              resourceType: outcome.resourceType,
              status: ReseedResourceStatus.failed,
            ),
          );
        }
      }
      // Persist the typed SQLite caches once after the batch.
      await dataSync.flushTypedCaches();
      LoggerService.info(
        'Full REST reseed ($reason) complete — '
        '${result.outcomes.where((o) => o.success).length}/${result.outcomes.length} '
        'resources, ${result.totalItems} items',
        tag: _tag,
      );
    } on Object catch (e) {
      LoggerService.warning('Full REST reseed ($reason) failed: $e', tag: _tag);
    }
  }

  /// Read credentials once. Returns null if not authenticated / no key yet.
  Future<_SeedCredentials?> _credentialsIfFresh() async {
    final apiKey = await _ref.read(secureStorageServiceProvider).getToken();
    final siteUrl = _ref.read(storageServiceProvider).siteUrl;
    final authed = _ref.read(authStatusProvider)?.isAuthenticated ?? false;
    if (!authed || apiKey == null || apiKey.isEmpty || siteUrl == null || siteUrl.isEmpty) {
      return null;
    }
    return _SeedCredentials(siteUrl: siteUrl, apiKey: apiKey);
  }

  /// Returns a reason string if the captured [creds] no longer match current
  /// auth state, else null. The async token read is done FIRST so the
  /// subsequent sync comparisons form an atomic verdict within one event-loop
  /// slice (a sign-out+sign-in landing mid-await can't flip state between
  /// checks).
  Future<String?> _staleReason(_SeedCredentials creds) async {
    final currentKey = await _ref.read(secureStorageServiceProvider).getToken();
    if (_ref.read(authStatusProvider)?.isAuthenticated != true) {
      return 'unauthenticated';
    }
    final currentSiteUrl = _ref.read(storageServiceProvider).siteUrl;
    if (currentSiteUrl != creds.siteUrl) {
      return 'site changed';
    }
    if (currentKey != creds.apiKey) {
      return 'api_key changed';
    }
    return null;
  }
}

class _SeedCredentials {
  const _SeedCredentials({required this.siteUrl, required this.apiKey});
  final String siteUrl;
  final String apiKey;
}

/// Keep-alive coordinator: never auto-disposed so its in-flight/cooldown state
/// survives screen rebuilds and reconnect flaps.
final inventoryReseedProvider = Provider<InventoryReseedService>((ref) {
  return InventoryReseedService(ref);
});
