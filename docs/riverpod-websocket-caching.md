# Riverpod + WebSocket + Caching Architecture

This document explains how Riverpod state management is integrated with WebSocket real-time updates and multi-level caching for devices, speed tests, and results.

## Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                      WebSocket Server                           │
└────────────────────────────────┬────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                    WebSocketService                              │
│  • Connection lifecycle management                               │
│  • Message parsing & routing                                     │
│  • Heartbeat & reconnection                                      │
└────────────────────────────────┬────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│               WebSocketCacheIntegration                          │
│  • In-memory device cache                                        │
│  • Room cache                                                    │
│  • Speed test cache                                              │
└────────────────────────────────┬────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│            WebSocketDataSyncListener                             │
│  • Listens for cache update events                               │
│  • Invalidates dependent Riverpod providers                      │
└────────────────────────────────┬────────────────────────────────┘
                                 │
         ┌───────────────────────┼───────────────────────┐
         ▼                       ▼                       ▼
   DevicesNotifier        SpeedTestNotifier        RoomsNotifier
         │                       │                       │
         ▼                       ▼                       ▼
    CacheManager           CacheManager            CacheManager
   (Stale-While-          (Stale-While-           (Stale-While-
    Revalidate)            Revalidate)             Revalidate)
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                         UI Layer                                 │
│                    (Widgets watch providers)                     │
└─────────────────────────────────────────────────────────────────┘
```

---

## WebSocket Provider Structure

### Core Providers

Location: `lib/core/providers/websocket_providers.dart`

| Provider | Type | Purpose |
|----------|------|---------|
| `webSocketConfigProvider` | Provider | Configuration from environment (auto-reconnect, heartbeat intervals, base URI) |
| `webSocketServiceProvider` | Provider | Singleton managing WebSocket lifecycle, auto-disposed on app end |
| `webSocketConnectionStateProvider` | StreamProvider | Real-time connection state (`disconnected`, `connecting`, `connected`, `reconnecting`) |
| `webSocketLastMessageProvider` | StreamProvider | Last received message for debugging/instrumentation |
| `webSocketAuthEventsProvider` | StreamProvider | Filtered stream of authentication-related messages |
| `webSocketDataSyncServiceProvider` | Provider | Coordinates typed cache persistence and event emission |
| `webSocketDataSyncListenerProvider` | Provider | Listens for sync events and invalidates providers |
| `webSocketCacheIntegrationProvider` | Provider | Bridges WebSocket messages to in-memory caches |

### Provider Dependencies

```
webSocketConfigProvider
         │
         ▼
webSocketServiceProvider ──────────────────────────┐
         │                                          │
         ├──► webSocketConnectionStateProvider      │
         │                                          │
         ├──► webSocketLastMessageProvider          │
         │                                          │
         └──► webSocketAuthEventsProvider           │
                                                    │
webSocketCacheIntegrationProvider ◄─────────────────┘
         │
         ▼
webSocketDataSyncServiceProvider
         │
         ▼
webSocketDataSyncListenerProvider
         │
         ├──► devicesNotifierProvider
         ├──► deviceNotificationsNotifierProvider
         ├──► healthNoticesNotifierProvider
         ├──► dashboardStatsProvider
         └──► roomsNotifierProvider
```

---

## Data Flow

### Complete Flow: WebSocket to UI

1. **WebSocket Connection**
   - `WebSocketService` establishes connection with server
   - Maintains heartbeat (45-second timeout)
   - Auto-reconnects with exponential backoff on disconnect

2. **Message Reception**
   - Messages arrive via WebSocket stream
   - Parsed into `SocketMessage` envelope (type, payload, headers)
   - Routed based on message type

3. **Cache Update**
   - `WebSocketCacheIntegration._handleMessage()` processes messages
   - Updates appropriate cache (`_deviceCache`, `_roomCache`, `_speedTestCache`)
   - Emits `WebSocketDataSyncEvent` on cache changes

4. **Provider Invalidation**
   - `webSocketDataSyncListenerProvider` receives event
   - Invalidates all dependent providers based on event type
   - Triggers automatic rebuild of affected providers

5. **Notifier Rebuild**
   - `DevicesNotifier.build()` or similar re-executes
   - Checks `CacheManager` for cached data
   - Returns fresh data to watchers

6. **UI Update**
   - Widgets watching providers receive new state
   - UI rebuilds with updated data

### Example: Device List Update

```dart
// 1. WebSocket receives device update
{
  "type": "resource_updated",
  "resource": "access_points",
  "data": { "id": 123, "name": "Living Room AP", ... }
}

// 2. WebSocketCacheIntegration updates cache
_deviceCache['access_points'][123] = updatedDevice;
_dataSyncService.emit(WebSocketDataSyncEvent.devicesCached);

// 3. Listener invalidates providers
ref.invalidate(devicesNotifierProvider);

// 4. DevicesNotifier.build() re-runs
// Returns updated device list

// 5. UI automatically updates
```

---

## Caching Implementation

### Devices Caching

Location: `lib/features/devices/presentation/providers/devices_provider.dart`

#### DevicesNotifier

```dart
@Riverpod(keepAlive: true)
class DevicesNotifier extends _$DevicesNotifier {
  @override
  Future<List<Device>> build() async {
    // 1. Check authentication
    // 2. Get from CacheManager (stale-while-revalidate)
    // 3. Subscribe to real-time stream
    // 4. Return cached or fresh data
  }
}
```

**Key Features:**
- `keepAlive: true` - Provider persists across navigation
- 5-minute TTL for cache entries
- Stream subscription for real-time updates

#### Multi-Level Caching

| Level | Location | Purpose |
|-------|----------|---------|
| Memory | `CacheManager` | Fast access, 5-min TTL, stale-while-revalidate |
| Typed Local | Hive (`APLocalDataSource`, `ONTLocalDataSource`, etc.) | Persistent storage by device type |
| Real-Time | WebSocket stream | Immediate updates, source of truth |

#### Refresh Strategies

| Method | Behavior | Use Case |
|--------|----------|----------|
| `userRefresh()` | Shows loading indicator, waits for fresh data | Pull-to-refresh |
| `silentRefresh()` | Background refresh, no UI blocking | Periodic updates |
| Stream updates | Automatic, immediate | Real-time WebSocket events |

#### Device Detail View

`DeviceNotifier` handles individual device detail:
- Subscribes to `imageUploadEventBus` for cache invalidation
- Subscribes to `deviceUpdateEventBus` for external changes
- Debounces rapid updates (500ms) to coalesce burst events
- Uses `DeviceFieldSets.detailFields` for complete data

---

### Speed Tests Caching

Location: `lib/features/speed_test/presentation/providers/speed_test_providers.dart`

#### SpeedTestConfigsNotifier

```dart
@riverpod
class SpeedTestConfigsNotifier extends _$SpeedTestConfigsNotifier {
  @override
  Future<List<SpeedTestConfig>> build() async {
    return await repository.getSpeedTestConfigs();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await repository.getSpeedTestConfigs());
  }
}
```

**Features:**
- Configs loaded once from WebSocket
- Kept in memory via `WebSocketCacheIntegration`
- Adhoc config detection (name contains 'adhoc')

#### SpeedTestResultsNotifier

```dart
@riverpod
class SpeedTestResultsNotifier extends _$SpeedTestResultsNotifier {
  @override
  Future<List<SpeedTestResult>> build({
    String? speedTestId,
    String? accessPointId,
  }) async {
    return await repository.getSpeedTestResults(
      speedTestId: speedTestId,
      accessPointId: accessPointId,
    );
  }
}
```

**Features:**
- Parameterized by `speedTestId` or `accessPointId`
- Supports CRUD with immediate refresh
- Sorted by timestamp (newest first)
- Pagination support (offset, limit)

#### SpeedTestRunNotifier

Manages actual speed test execution:
- Subscribes to status, progress, message, and result streams
- Config validation and auto-validation on completion
- Supports config-based and adhoc test submissions
- Network info synchronization (local IP, gateway)

---

### Results Caching

**Storage:**
- Accumulated from WebSocket snapshots
- Stored in `WebSocketCacheIntegration._speedTestResultsCache`

**Query Pattern:**
```dart
// Filtered by speed test ID
final results = await cacheIntegration.getSpeedTestResults(
  speedTestId: 'test-123',
);

// Filtered by access point
final results = await cacheIntegration.getSpeedTestResults(
  accessPointId: 'ap-456',
);
```

**Characteristics:**
- Cache-first approach for queries
- Background refresh on WebSocket updates
- 10-second timeout for initial snapshot requests

---

## Caching Strategies

### Stale-While-Revalidate

Location: `lib/core/services/cache_manager.dart`

```dart
Future<T> get<T>(
  String key,
  Future<T> Function() fetcher, {
  Duration ttl = const Duration(minutes: 5),
}) async {
  final entry = _cache[key];

  // Fresh: Return immediately
  if (entry != null && !entry.isStale) {
    return entry.data as T;
  }

  // Stale: Return immediately + background refresh
  if (entry != null && entry.isStale && !entry.isExpired) {
    unawaited(_fetchAndCache(key, fetcher, ttl));
    return entry.data as T;
  }

  // Expired or missing: Wait for fresh data
  return await _fetchAndCache(key, fetcher, ttl);
}
```

**States:**
| State | Condition | Behavior |
|-------|-----------|----------|
| Fresh | `age < TTL` | Return immediately |
| Stale | `TTL < age < 2×TTL` | Return stale + background refresh |
| Expired | `age > 2×TTL` | Wait for fresh data |

### Request Deduplication

```dart
Future<T> _fetchAndCache<T>(String key, ...) async {
  // Reuse pending request if exists
  if (_pendingRequests.containsKey(key)) {
    return await _pendingRequests[key]!.future;
  }

  final completer = Completer<T>();
  _pendingRequests[key] = completer;

  try {
    final data = await fetcher();
    _cache[key] = CacheEntry<T>(data: data, ...);
    completer.complete(data);
    return data;
  } finally {
    _pendingRequests.remove(key);
  }
}
```

**Benefit:** Prevents multiple concurrent fetches for the same resource.

### Field Selection Optimization

Location: `lib/core/services/websocket_cache_integration.dart`

```dart
// Request snapshot with field selection
final fields = _deviceResourceTypes.contains(resource)
    ? DeviceFieldSets.listFields
    : null;

if (fields != null) {
  payload['only'] = fields.join(',');
}
```

**Field Sets:**
| Set | Purpose | Payload Reduction |
|-----|---------|-------------------|
| `listFields` | Device list view | ~80% smaller |
| `detailFields` | Device detail view | Full data |
| `refreshFields` | Background refresh | Minimal fields |

---

## Provider Invalidation

### Event-Driven Chain

Location: `lib/core/providers/websocket_providers.dart`

```dart
final webSocketDataSyncListenerProvider = Provider<void>((ref) {
  final service = ref.watch(webSocketDataSyncServiceProvider);

  service.events.listen((event) {
    switch (event.type) {
      case WebSocketDataSyncEventType.devicesCached:
        ref.invalidate(devicesNotifierProvider);
        ref.invalidate(deviceNotificationsNotifierProvider);
        ref.invalidate(healthNoticesNotifierProvider);
        ref.invalidate(dashboardStatsProvider);
        break;

      case WebSocketDataSyncEventType.roomsCached:
        ref.invalidate(roomsNotifierProvider);
        break;

      case WebSocketDataSyncEventType.speedTestsCached:
        ref.invalidate(speedTestConfigsNotifierProvider);
        ref.invalidate(speedTestResultsNotifierProvider);
        break;
    }
  });
});
```

### Invalidation Matrix

| Event Type | Invalidated Providers |
|------------|----------------------|
| `devicesCached` | `devicesNotifierProvider`, `deviceNotificationsNotifierProvider`, `healthNoticesNotifierProvider`, `dashboardStatsProvider` |
| `roomsCached` | `roomsNotifierProvider` |
| `speedTestsCached` | `speedTestConfigsNotifierProvider`, `speedTestResultsNotifierProvider` |

---

## Key Files Reference

| File | Role |
|------|------|
| `lib/core/services/websocket_service.dart` | WebSocket lifecycle, message handling, reconnection logic |
| `lib/core/providers/websocket_providers.dart` | Exposes WebSocket & cache as reactive Riverpod streams |
| `lib/core/services/websocket_cache_integration.dart` | In-memory caching, snapshot accumulation, resource tracking (~1600 lines) |
| `lib/core/services/cache_manager.dart` | Stale-while-revalidate, TTL management, request deduplication |
| `lib/core/services/websocket_data_sync_service.dart` | Typed cache persistence, event emission coordination |
| `lib/features/devices/presentation/providers/devices_provider.dart` | Device list/detail notifiers, refresh strategies |
| `lib/features/speed_test/presentation/providers/speed_test_providers.dart` | Speed test configs, results, and execution state |
| `lib/features/devices/data/datasources/device_websocket_data_source.dart` | Bridges WebSocket cache to domain layer |
| `lib/features/devices/data/repositories/device_repository_impl.dart` | Aggregates typed caches, ID-to-type routing |

---

## Resilience & Error Handling

### WebSocket Reconnection

```dart
// Exponential backoff strategy
int _reconnectDelay = 1000; // Start at 1 second
const int _maxReconnectDelay = 32000; // Max 32 seconds

void _scheduleReconnect() {
  Future.delayed(Duration(milliseconds: _reconnectDelay), () {
    connect(lastParams);
    _reconnectDelay = min(_reconnectDelay * 2, _maxReconnectDelay);
  });
}

void _onConnected() {
  _reconnectDelay = 1000; // Reset on successful connection
}
```

### Timeout Handling

| Operation | Timeout | Fallback |
|-----------|---------|----------|
| Snapshot request | 10 seconds | Return empty, retry later |
| Heartbeat | 45 seconds | Trigger reconnection |
| Request/response | Configurable | Reject pending promise |

### Type Safety

```dart
// Runtime type checking in CacheManager
T? get<T>(String key) {
  final entry = _cache[key];
  if (entry == null) return null;

  // Prevent type cast errors
  if (entry.data is! T) {
    _cache.remove(key);
    return null;
  }

  return entry.data as T;
}
```

---

## Performance Optimizations

1. **Field Selection** - Reduces device payload by ~80%
2. **Snapshot Accumulation** - 500ms merge window prevents UI thrashing
3. **Request Deduplication** - Single fetch for concurrent requests
4. **Typed Caches** - Separate caches per device type reduce memory footprint
5. **ID-to-Type Index** - O(1) device lookup vs O(n) search
6. **Stale-While-Revalidate** - Instant UI updates with background refresh
7. **keepAlive Providers** - Prevents unnecessary rebuilds across navigation
