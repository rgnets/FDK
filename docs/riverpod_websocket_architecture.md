# Riverpod + WebSocket Architecture Improvement Plan

## Goal
Improve the existing FDK implementation to achieve true real-time UI updates via WebSocket, reducing reliance on HTTP polling.

---

## Current Architecture

```
WebSocket → WebSocketService (broadcast streams)
         → WebSocketDataSyncService (snapshot caching only)
         → Event emitted → ref.refresh() → HTTP fetch → UI update
```

**Problem**: WebSocket triggers HTTP fetch instead of directly updating state.

---

## Proposed Architecture

```
WebSocket → WebSocketService (broadcast streams)
         → MessageRouter (type-based dispatch)
         ├→ SnapshotHandler (initial sync) → Cache → Provider refresh
         ├→ IncrementalHandler (real-time) → Direct state update (no HTTP)
         ├→ NotificationHandler → Push notifications
         └→ ErrorHandler → Error state propagation
```

---

## Architecture Layers

### Layer 1: Message Router (Parse Once → Typed Events)

Parse raw WebSocket JSON **once**, emit typed Freezed events:

```dart
// core/services/websocket_message_router.dart
class WebSocketMessageRouter {
  final _eventController = StreamController<WebSocketEvent>.broadcast();

  Stream<WebSocketEvent> get events => _eventController.stream;

  /// Parse raw message ONCE → emit typed event
  void dispatch(SocketMessage message) {
    final event = _parseToTypedEvent(message);
    if (event != null) {
      _eventController.add(event);
    }
  }

  WebSocketEvent? _parseToTypedEvent(SocketMessage message) {
    final type = message.type;
    final payload = message.payload;

    // Parse once here - all downstream gets typed objects
    if (type.startsWith('device.')) {
      return WebSocketEvent.device(_parseDeviceEvent(type, payload));
    }
    if (type.startsWith('room.')) {
      return WebSocketEvent.room(_parseRoomEvent(type, payload));
    }
    if (type.startsWith('notification.')) {
      return WebSocketEvent.notification(_parseNotificationEvent(type, payload));
    }
    if (type.startsWith('sync.')) {
      return WebSocketEvent.sync(_parseSyncEvent(type, payload));
    }
    return null;
  }

  DeviceEvent _parseDeviceEvent(String type, Map<String, dynamic> payload) {
    return switch (type) {
      'device.created' => DeviceEvent.created(Device.fromJson(payload)),
      'device.updated' => DeviceEvent.updated(Device.fromJson(payload)),
      'device.deleted' => DeviceEvent.deleted(payload['id'] as String),
      'device.status_changed' => DeviceEvent.statusChanged(
        payload['id'] as String,
        payload['status'] as String,
      ),
      _ => DeviceEvent.updated(Device.fromJson(payload)), // fallback
    };
  }
}
```

**Key**: String parsing happens **once** in the router. All consumers receive typed `DeviceEvent`, `RoomEvent`, etc. with O(1) `.when()` dispatch.

### Layer 2: Typed Stream Providers (New)

Create filtered stream providers for each domain:

```dart
// Device updates stream
final webSocketDeviceEventsProvider = StreamProvider<DeviceEvent>((ref) {
  return ref.watch(webSocketServiceProvider)
    .messages
    .where((m) => m.type.startsWith('device.'))
    .map((m) => DeviceEvent.fromMessage(m));
});

// Room updates stream
final webSocketRoomEventsProvider = StreamProvider<RoomEvent>((ref) { ... });

// Notification events stream
final webSocketNotificationEventsProvider = StreamProvider<NotificationEvent>((ref) { ... });
```

### Layer 3: Reactive Provider Updates

Wire domain providers to listen to WebSocket events:

```dart
@Riverpod(keepAlive: true)
class DevicesNotifier extends _$DevicesNotifier {
  @override
  Future<List<Device>> build() async {
    // Listen to real-time updates
    ref.listen(webSocketDeviceEventsProvider, (_, event) {
      event.whenData((e) => _handleDeviceEvent(e));
    });

    return _loadInitialDevices();
  }

  void _handleDeviceEvent(DeviceEvent event) {
    switch (event) {
      case DeviceCreated(device: d): _addDevice(d);
      case DeviceUpdated(device: d): _updateDevice(d);
      case DeviceDeleted(id: id): _removeDevice(id);
    }
  }

  void _updateDevice(Device updated) {
    state = state.whenData((devices) =>
      devices.map((d) => d.id == updated.id ? updated : d).toList()
    );
  }
}
```

### Layer 4: Connection State UI

Expose connection status for UI feedback:

```dart
final connectionStatusProvider = Provider<ConnectionStatus>((ref) {
  final state = ref.watch(webSocketConnectionStateProvider);
  final lastSync = ref.watch(lastSyncTimestampProvider);

  return ConnectionStatus(
    state: state.valueOrNull ?? SocketConnectionState.disconnected,
    lastSyncAt: lastSync,
    isStale: DateTime.now().difference(lastSync) > Duration(minutes: 5),
  );
});
```

---

## Data Flow Comparison

### Before (Current)
```
WebSocket message
  → WebSocketDataSyncService caches to local storage
  → Emits devicesCached event
  → webSocketDataSyncListenerProvider calls ref.refresh()
  → devicesNotifierProvider.build() re-executes
  → HTTP fetch from API (!)
  → UI rebuilds
```

### After (Proposed)
```
WebSocket message
  → MessageRouter dispatches by type
  → For snapshots: Cache + ref.refresh() (existing flow)
  → For incremental: Direct state mutation via _updateDevice()
  → UI rebuilds immediately (no HTTP)
```

---

## Key Improvements

| Area | Current | Proposed |
|------|---------|----------|
| Real-time updates | HTTP fetch on every event | Direct state mutation |
| Message routing | Manual filtering | Centralized dispatcher |
| Error handling | Silent failures | Error state provider |
| Connection UI | None | Status indicator |
| Incremental updates | Full list refresh | Single item update |

---

## Files to Modify

| File | Changes |
|------|---------|
| `core/services/websocket_message_router.dart` | **NEW** - Message dispatcher |
| `core/providers/websocket_providers.dart` | Add typed stream providers |
| `features/devices/providers/devices_provider.dart` | Add `ref.listen()` for events |
| `features/rooms/providers/rooms_riverpod_provider.dart` | Add `ref.listen()` for events |
| `core/models/websocket_events.dart` | **NEW** - Event type unions |

---

## Implementation Priority

### Phase 1: Foundation
1. Create `WebSocketMessageRouter` service
2. Define event types (`DeviceEvent`, `RoomEvent`, etc.)
3. Add typed stream providers

### Phase 2: Provider Integration
4. Update `DevicesNotifier` with `ref.listen()` for incremental updates
5. Update `RoomsNotifier` similarly
6. Add connection status provider

### Phase 3: UI Feedback
7. Create connection indicator widget
8. Add stale data indicators
9. Implement error state UI

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        WebSocketService                          │
│  connectionState: Stream<SocketConnectionState>                  │
│  messages: Stream<SocketMessage>                                 │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                     WebSocketMessageRouter                       │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌───────────┐  │
│  │ device.*    │ │ room.*      │ │ notification│ │ sync.*    │  │
│  └──────┬──────┘ └──────┬──────┘ └──────┬──────┘ └─────┬─────┘  │
└─────────┼───────────────┼───────────────┼──────────────┼────────┘
          │               │               │              │
          ▼               ▼               ▼              ▼
┌─────────────────┐ ┌───────────┐ ┌────────────┐ ┌─────────────┐
│ DeviceEvents    │ │ RoomEvents│ │ Notif      │ │ SyncService │
│ StreamProvider  │ │ Provider  │ │ Provider   │ │ (existing)  │
└────────┬────────┘ └─────┬─────┘ └─────┬──────┘ └──────┬──────┘
         │                │             │               │
         ▼                ▼             ▼               ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Domain Providers                            │
│  ┌─────────────────┐ ┌─────────────┐ ┌────────────────────────┐ │
│  │ DevicesNotifier │ │RoomsNotifier│ │NotificationsNotifier   │ │
│  │ ref.listen()    │ │ref.listen() │ │ref.listen()            │ │
│  │ _updateDevice() │ │_updateRoom()│ │_addNotification()      │ │
│  └────────┬────────┘ └──────┬──────┘ └───────────┬────────────┘ │
└───────────┼─────────────────┼────────────────────┼──────────────┘
            │                 │                    │
            ▼                 ▼                    ▼
┌─────────────────────────────────────────────────────────────────┐
│                         UI Layer                                 │
│  ConsumerWidget + ref.watch() = automatic rebuilds               │
└─────────────────────────────────────────────────────────────────┘
```

---

## Key Pattern: Map-Based State for O(1) Updates

**Core Insight**: Keep internal state as `Map<String, Device>` for constant-time updates, derive list only when UI needs it.

### DevicesNotifier Implementation

```dart
@Riverpod(keepAlive: true)
class DevicesNotifier extends _$DevicesNotifier {
  // Internal state: Map for O(1) lookups/updates
  final Map<String, Device> _byId = {};

  @override
  Future<List<Device>> build() async {
    // Listen to real-time WebSocket events
    ref.listen(webSocketDeviceEventsProvider, (_, event) {
      event.whenData((e) => _handleDeviceEvent(e));
    });

    // Initial load
    final devices = await _fetchInitialDevices();
    _byId
      ..clear()
      ..addAll({for (final d in devices) d.id: d});

    return _byId.values.toList();
  }

  // O(1) update - no list scanning
  void _updateDevice(Device updated) {
    _byId[updated.id] = updated;
    _emitList();
  }

  // O(1) add
  void _addDevice(Device device) {
    _byId[device.id] = device;
    _emitList();
  }

  // O(1) remove
  void _removeDevice(String id) {
    _byId.remove(id);
    _emitList();
  }

  // Derive list only when emitting to UI
  void _emitList() {
    state = AsyncValue.data(_byId.values.toList());
  }

  // Batch updates for efficiency
  void _updateMultiple(List<Device> devices) {
    for (final d in devices) {
      _byId[d.id] = d;
    }
    _emitList(); // Single UI update
  }
}
```

### Performance Comparison

| Operation | List-based O(n) | Map-based O(1) |
|-----------|-----------------|----------------|
| Update 1 device | Scan 1000 items | Direct lookup |
| Remove device | Scan + rebuild | Direct remove |
| Add device | Append + possible realloc | Direct insert |
| Batch update 50 | 50 * O(n) scans | 50 * O(1) + 1 emit |

---

## Freezed Sealed Classes for Type-Safe Event Routing

**Why Freezed over String Matching:**

| Approach | Performance | Safety |
|----------|-------------|--------|
| String switch `case 'device.updated':` | O(n) string comparisons | Runtime errors on typos |
| Freezed `.when()` | O(1) jump table | Compile-time exhaustiveness |

### Event Definition (freezed)

```dart
// core/models/websocket_events.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'websocket_events.freezed.dart';

@freezed
sealed class DeviceEvent with _$DeviceEvent {
  const factory DeviceEvent.created(Device device) = DeviceCreated;
  const factory DeviceEvent.updated(Device device) = DeviceUpdated;
  const factory DeviceEvent.deleted(String id) = DeviceDeleted;
  const factory DeviceEvent.statusChanged(String id, String status) = DeviceStatusChanged;
  const factory DeviceEvent.batchUpdate(List<Device> devices) = DeviceBatchUpdate;
}

@freezed
sealed class RoomEvent with _$RoomEvent {
  const factory RoomEvent.created(Room room) = RoomCreated;
  const factory RoomEvent.updated(Room room) = RoomUpdated;
  const factory RoomEvent.deleted(String id) = RoomDeleted;
}

@freezed
sealed class WebSocketEvent with _$WebSocketEvent {
  const factory WebSocketEvent.device(DeviceEvent event) = DeviceWebSocketEvent;
  const factory WebSocketEvent.room(RoomEvent event) = RoomWebSocketEvent;
  const factory WebSocketEvent.notification(NotificationEvent event) = NotificationWebSocketEvent;
  const factory WebSocketEvent.sync(SyncEvent event) = SyncWebSocketEvent;
  const factory WebSocketEvent.error(String message, StackTrace? stack) = ErrorWebSocketEvent;
}
```

### Event Handler with `.when()` (O(1) Jump Table)

```dart
void _handleDeviceEvent(DeviceEvent event) {
  // Compiler optimizes to O(1) jump table - NOT sequential checking
  event.when(
    created: (device) => _addDevice(device),        // O(1) map insert
    updated: (device) => _updateDevice(device),     // O(1) map update
    deleted: (id) => _removeDevice(id),             // O(1) map remove
    statusChanged: (id, status) => _updateDeviceStatus(id, status),
    batchUpdate: (devices) => _updateMultiple(devices),
  );
}
```

### Why This is Fast

1. **Type Check, Not String Check**: `is DeviceUpdated` is faster than `== 'device.updated'`
2. **Compiler Jump Table**: Dart compiler knows all sealed subtypes → generates O(1) dispatch
3. **Zero Runtime Overhead**: Type resolution happens once during parsing
4. **Exhaustiveness**: Compiler error if you miss a case → no runtime bugs

---

## Selective Field Updates

For partial updates (e.g., only status changed):

```dart
void _updateDeviceStatus(String id, String status) {
  final existing = _byId[id];
  if (existing != null) {
    _byId[id] = existing.copyWith(status: status);
    _emitList();
  }
}

void _updateDeviceFields(String id, Map<String, dynamic> fields) {
  final existing = _byId[id];
  if (existing != null) {
    _byId[id] = existing.copyWith(
      status: fields['status'] ?? existing.status,
      online: fields['online'] ?? existing.online,
      lastSeen: fields['last_seen'] != null
        ? DateTime.parse(fields['last_seen'])
        : existing.lastSeen,
    );
    _emitList();
  }
}
```

---

## Summary

The core improvement is that WebSocket events directly mutate the internal map with O(1) operations, only converting to list when emitting to UI. Combined with Freezed sealed classes for O(1) type dispatch, this eliminates:

1. HTTP fetches triggered by WebSocket events
2. O(n) list scanning on every update
3. String-based message routing with runtime errors

**Result**: True real-time UI updates with minimal latency and maximum type safety.
