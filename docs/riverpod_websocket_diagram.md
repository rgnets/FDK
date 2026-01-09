# Riverpod + WebSocket Architecture Diagram

## Complete Data Flow

```
                                    WEBSOCKET SERVER
                                          │
                                          │ JSON messages
                                          ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              WebSocketService                                    │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  connectionState: Stream<SocketConnectionState>                          │   │
│  │  messages: Stream<SocketMessage>  ←── Raw JSON parsed here               │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                          │                                      │
│  Responsibilities:                       │                                      │
│  • WebSocket connection management       │                                      │
│  • Reconnection with exponential backoff │                                      │
│  • Heartbeat/ping-pong                   │                                      │
│  • JSON encode/decode                    │                                      │
└──────────────────────────────────────────┼──────────────────────────────────────┘
                                           │
                                           │ SocketMessage { type, payload, headers }
                                           ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           WebSocketMessageRouter                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  PARSE ONCE → Emit typed Freezed events                                  │   │
│  │                                                                          │   │
│  │  _parseToTypedEvent(SocketMessage) → WebSocketEvent                      │   │
│  │     ├─ type.startsWith('device.') → DeviceEvent                          │   │
│  │     ├─ type.startsWith('room.')   → RoomEvent                            │   │
│  │     ├─ type.startsWith('notification.') → NotificationEvent              │   │
│  │     ├─ type.startsWith('sync.')   → SyncEvent                            │   │
│  │     └─ connection state changes   → ConnectionEvent                      │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                          │                                      │
│  Output Streams:                         │                                      │
│  • events: Stream<WebSocketEvent>        │                                      │
│  • deviceEvents: Stream<DeviceEvent>     │                                      │
│  • roomEvents: Stream<RoomEvent>         │                                      │
│  • notificationEvents: Stream<NotificationEvent>                                │
│  • syncEvents: Stream<SyncEvent>         │                                      │
│  • connectionEvents: Stream<ConnectionEvent>                                    │
└──────────────────────────────────────────┼──────────────────────────────────────┘
                                           │
                                           │ Typed Freezed Events
                                           ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                          RIVERPOD STREAM PROVIDERS                               │
│                                                                                  │
│  ┌────────────────────┐  ┌────────────────────┐  ┌────────────────────┐        │
│  │webSocketDevice     │  │webSocketRoom       │  │webSocketNotification│        │
│  │EventsProvider      │  │EventsProvider      │  │EventsProvider      │        │
│  │                    │  │                    │  │                    │        │
│  │Stream<DeviceEvent> │  │Stream<RoomEvent>   │  │Stream<Notification │        │
│  │                    │  │                    │  │       Event>       │        │
│  └─────────┬──────────┘  └─────────┬──────────┘  └─────────┬──────────┘        │
│            │                       │                       │                    │
│            │                       │                       │                    │
│  ┌─────────┴──────────┐  ┌─────────┴──────────┐  ┌─────────┴──────────┐        │
│  │webSocketSync       │  │webSocketConnection │  │connectionStatus    │        │
│  │EventsProvider      │  │EventsProvider      │  │Provider            │        │
│  │                    │  │                    │  │                    │        │
│  │Stream<SyncEvent>   │  │Stream<Connection   │  │ConnectionStatus    │        │
│  │                    │  │       Event>       │  │{state, isConnected}│        │
│  └────────────────────┘  └────────────────────┘  └────────────────────┘        │
└──────────────────────────────────────────┼──────────────────────────────────────┘
                                           │
                                           │ ref.listen() in providers
                                           ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           DOMAIN NOTIFIERS                                       │
│                                                                                  │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                         DevicesNotifier                                  │   │
│  │  ┌─────────────────────────────────────────────────────────────────┐    │   │
│  │  │  Internal State: Map<String, Device> _byId  ← O(1) lookups      │    │   │
│  │  └─────────────────────────────────────────────────────────────────┘    │   │
│  │                                                                          │   │
│  │  ref.listen(webSocketDeviceEventsProvider, (_, next) {                  │   │
│  │    next.whenData(_handleDeviceEvent);                                    │   │
│  │  });                                                                     │   │
│  │                                                                          │   │
│  │  _handleDeviceEvent(DeviceEvent event) {                                │   │
│  │    event.when(                         ← O(1) Freezed jump table        │   │
│  │      created: _addDevice,              ← _byId[id] = device             │   │
│  │      updated: _updateDevice,           ← _byId[id] = device             │   │
│  │      deleted: _removeDevice,           ← _byId.remove(id)               │   │
│  │      statusChanged: _updateStatus,     ← _byId[id] = updated            │   │
│  │      batchUpdate: _updateMultiple,     ← for (d in list) _byId[d.id]=d  │   │
│  │      snapshot: _handleSnapshot,        ← _byId.clear(); addAll(...)     │   │
│  │    );                                                                    │   │
│  │  }                                                                       │   │
│  │                                                                          │   │
│  │  _emitList() {                                                          │   │
│  │    state = AsyncValue.data(_byId.values.toList());  ← Derive list      │   │
│  │  }                                                                       │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                  │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                          RoomsNotifier                                   │   │
│  │  ┌─────────────────────────────────────────────────────────────────┐    │   │
│  │  │  Internal State: Map<String, Room> _byId  ← O(1) lookups        │    │   │
│  │  └─────────────────────────────────────────────────────────────────┘    │   │
│  │                                                                          │   │
│  │  ref.listen(webSocketRoomEventsProvider, ...)                           │   │
│  │  Same pattern as DevicesNotifier                                         │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                  │
│  External State: AsyncValue<List<Device>> / AsyncValue<List<Room>>              │
└──────────────────────────────────────────┼──────────────────────────────────────┘
                                           │
                                           │ ref.watch() in widgets
                                           ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              UI LAYER                                            │
│                                                                                  │
│  class DevicesScreen extends ConsumerWidget {                                   │
│    Widget build(context, ref) {                                                 │
│      final devicesAsync = ref.watch(devicesNotifierProvider);                   │
│                                                                                  │
│      return devicesAsync.when(                                                  │
│        data: (devices) => ListView.builder(...),  ← AUTO-REBUILDS              │
│        loading: () => CircularProgressIndicator(),                              │
│        error: (e, _) => ErrorWidget(e),                                         │
│      );                                                                          │
│    }                                                                             │
│  }                                                                               │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## Event Type Hierarchy (Freezed Sealed Classes)

```
WebSocketEvent (sealed)
├── DeviceWebSocketEvent
│   └── DeviceEvent (sealed)
│       ├── DeviceCreated(Device device)
│       ├── DeviceUpdated(Device device)
│       ├── DeviceDeleted(String id)
│       ├── DeviceStatusChanged(String id, String status, bool? online, DateTime? lastSeen)
│       ├── DeviceBatchUpdate(List<Device> devices)
│       └── DeviceSnapshot(List<Device> devices)
│
├── RoomWebSocketEvent
│   └── RoomEvent (sealed)
│       ├── RoomCreated(Room room)
│       ├── RoomUpdated(Room room)
│       ├── RoomDeleted(String id)
│       ├── RoomBatchUpdate(List<Room> rooms)
│       └── RoomSnapshot(List<Room> rooms)
│
├── NotificationWebSocketEvent
│   └── NotificationEvent (sealed)
│       ├── NotificationReceived(id, title, message, type, priority, ...)
│       ├── NotificationRead(String id)
│       └── NotificationCleared()
│
├── SyncWebSocketEvent
│   └── SyncEvent (sealed)
│       ├── SyncStarted()
│       ├── SyncCompleted(int deviceCount, int roomCount)
│       ├── SyncFailed(String error)
│       └── SyncDelta(updatedDevices, updatedRooms, deletedIds, ...)
│
├── ConnectionWebSocketEvent
│   └── ConnectionEvent (sealed)
│       ├── ConnectionConnected()
│       ├── ConnectionDisconnected(String? reason)
│       ├── ConnectionReconnecting(int attempt)
│       └── ConnectionError(String message, StackTrace?)
│
└── UnknownWebSocketEvent(String type, Map payload)
```

---

## Provider Dependency Graph

```
                    ┌─────────────────────────┐
                    │  webSocketConfigProvider │
                    │  (WebSocketConfig)       │
                    └────────────┬────────────┘
                                 │
                                 ▼
                    ┌─────────────────────────┐
                    │ webSocketServiceProvider │
                    │ (WebSocketService)       │
                    └────────────┬────────────┘
                                 │
                    ┌────────────┴────────────┐
                    │                         │
                    ▼                         ▼
     ┌──────────────────────────┐  ┌─────────────────────────────┐
     │webSocketMessageRouter    │  │webSocketDataSyncService     │
     │Provider                  │  │Provider                     │
     │(WebSocketMessageRouter)  │  │(WebSocketDataSyncService)   │
     └────────────┬─────────────┘  │  - Caches to local storage  │
                  │                │  - Emits devicesCached/     │
                  │                │    roomsCached events       │
                  │                └──────────────┬──────────────┘
                  │                               │
     ┌────────────┼────────────────┬──────────────┤
     │            │                │              │
     ▼            ▼                ▼              ▼
┌─────────┐ ┌─────────┐ ┌──────────────┐ ┌────────────────────────┐
│webSocket│ │webSocket│ │webSocket     │ │webSocketDataSync       │
│Device   │ │Room     │ │Notification  │ │ListenerProvider        │
│Events   │ │Events   │ │Events        │ │                        │
│Provider │ │Provider │ │Provider      │ │ ref.refresh(devices)   │
└────┬────┘ └────┬────┘ └──────────────┘ │ ref.refresh(rooms)     │
     │           │                       └────────────────────────┘
     │           │
     ▼           ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Domain Notifiers                            │
│  ┌─────────────────────┐     ┌─────────────────────┐            │
│  │ devicesNotifier     │     │ roomsNotifier       │            │
│  │ Provider            │     │ Provider            │            │
│  │                     │     │                     │            │
│  │ ref.listen(         │     │ ref.listen(         │            │
│  │   webSocketDevice   │     │   webSocketRoom     │            │
│  │   EventsProvider)   │     │   EventsProvider)   │            │
│  └──────────┬──────────┘     └──────────┬──────────┘            │
└─────────────┼────────────────────────────┼──────────────────────┘
              │                            │
              ▼                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Computed Providers                          │
│  ┌─────────────────────┐     ┌─────────────────────┐            │
│  │ filteredDevices     │     │ roomStatistics      │            │
│  │ Provider            │     │ Provider            │            │
│  │                     │     │                     │            │
│  │ ref.watch(devices)  │     │ ref.watch(rooms)    │            │
│  │ ref.watch(filters)  │     │ ref.watch(devices)  │            │
│  └──────────┬──────────┘     └──────────┬──────────┘            │
└─────────────┼────────────────────────────┼──────────────────────┘
              │                            │
              ▼                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                         UI Widgets                               │
│  ref.watch(devicesNotifierProvider)                              │
│  ref.watch(filteredDevicesProvider)                              │
│  ref.watch(roomsNotifierProvider)                                │
│  ref.watch(roomStatisticsProvider)                               │
│  ref.watch(connectionStatusProvider)                             │
└─────────────────────────────────────────────────────────────────┘
```

---

## Data Update Flow Comparison

### OLD: HTTP Fetch on Every WebSocket Event

```
WebSocket Message
       │
       ▼
WebSocketDataSyncService
       │
       ▼
Cache to local storage
       │
       ▼
Emit devicesCached event
       │
       ▼
webSocketDataSyncListenerProvider
       │
       ▼
ref.refresh(devicesNotifierProvider)  ← TRIGGERS REBUILD
       │
       ▼
devicesNotifierProvider.build() re-executes
       │
       ▼
HTTP FETCH FROM API  ← SLOW, UNNECESSARY
       │
       ▼
UI rebuilds with new data
```

### NEW: Direct State Mutation (No HTTP)

```
WebSocket Message
       │
       ▼
WebSocketMessageRouter._parseToTypedEvent()  ← PARSE ONCE
       │
       ▼
DeviceEvent.updated(device)  ← TYPED EVENT
       │
       ▼
webSocketDeviceEventsProvider (Stream)
       │
       ▼
DevicesNotifier.ref.listen() receives event
       │
       ▼
event.when(updated: _updateDevice)  ← O(1) DISPATCH
       │
       ▼
_byId[device.id] = device  ← O(1) MAP UPDATE
       │
       ▼
_emitList() → state = AsyncValue.data(_byId.values.toList())
       │
       ▼
UI rebuilds IMMEDIATELY  ← NO HTTP, NO DELAY
```

---

## Performance Characteristics

| Operation | List-based (Old) | Map-based (New) |
|-----------|------------------|-----------------|
| Find device by ID | O(n) scan | O(1) lookup |
| Update single device | O(n) scan + rebuild | O(1) insert |
| Delete device | O(n) scan + filter | O(1) remove |
| Batch update 50 devices | 50 × O(n) scans | 50 × O(1) + 1 emit |
| Event type dispatch | String comparison | O(1) jump table |

---

## File Locations

```
lib/
├── core/
│   ├── models/
│   │   └── websocket_events.dart          # Freezed event types
│   ├── services/
│   │   ├── websocket_service.dart         # Connection management
│   │   ├── websocket_message_router.dart  # Type-safe event routing
│   │   └── websocket_data_sync_service.dart # Legacy cache sync
│   └── providers/
│       └── websocket_providers.dart       # All WebSocket providers
│
└── features/
    ├── devices/presentation/providers/
    │   └── devices_provider.dart          # Map-based DevicesNotifier
    └── rooms/presentation/providers/
        └── rooms_riverpod_provider.dart   # Map-based RoomsNotifier
```
