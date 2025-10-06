# Data Flow Architecture - RG Nets FDK

**Created**: 2025-08-18
**Status**: ACTUAL IMPLEMENTATION
**Purpose**: Document real data flows based on working endpoints

## Overview

Data flows through four layers with critical implementation notes:
1. **Data Source** (Paginated API responses)
2. **Repository** (Must handle pagination)
3. **Provider** (Riverpod AsyncNotifier)
4. **UI** (ConsumerWidget)

⚠️ **Critical**: All API responses are paginated, not direct arrays!

## Layer Architecture

```
┌─────────────────────────────────────────────────┐
│                    UI Layer                     │
│         (Widgets consume providers)             │
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────┐
│               Provider Layer                    │
│    (Riverpod providers manage state)            │
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────┐
│              Repository Layer                   │
│   (Business logic & data transformation)        │
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────┐
│               Data Source Layer                 │
│      (API, Cache, Mock based on flavor)         │
└─────────────────────────────────────────────────┘
```

## 1. Data Source Layer

### API Data Source (ACTUAL IMPLEMENTATION)
```dart
class ApiDataSource {
  // Working endpoints:
  // - /api/access_points.json (221 items)
  // - /api/media_converters.json (151 items)
  // - /api/switch_devices.json (1 item)
  // - /api/pms_rooms.json (141 items)
  
  // NON-EXISTENT (404):
  // - /api/wlan_controllers.json
  // - /api/notifications.json
  
  ApiDataSource({
    required String fqdn,
    required String apiKey,
  }) : _baseUrl = 'https://$fqdn',
       _apiKey = apiKey,
       _dio = Dio() {
    _configureDio();
  }
  
  void _configureDio() {
    _dio.options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 30),
      queryParameters: {'api_key': _apiKey},
    );
    
    // Add interceptors
    _dio.interceptors.add(LogInterceptor());
    _dio.interceptors.add(RetryInterceptor());
    _dio.interceptors.add(CacheInterceptor());
  }
  
  // CRITICAL: Must handle pagination structure
  Future<List<T>> fetchAllPages<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final List<T> allResults = [];
    String? nextUrl = endpoint;
    
    while (nextUrl != null) {
      final response = await _dio.get(nextUrl);
      final data = response.data;
      
      // ACTUAL PAGINATION STRUCTURE:
      // {
      //   "count": 221,
      //   "page": 1,
      //   "page_size": 30,
      //   "total_pages": 8,
      //   "next": "https://[host]/api/endpoint.json?page=2",
      //   "results": [...] // DATA IS HERE!
      // }
      
      if (data['results'] != null) {
        final results = (data['results'] as List)
          .map((json) => fromJson(json))
          .toList();
        allResults.addAll(results);
      }
      
      nextUrl = data['next'];
    }
    
    return allResults;
  }
  
  // Fetch single resource
  Future<T> fetchOne<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final response = await _dio.get(endpoint);
    return fromJson(response.data);
  }
  
  // Update resource
  Future<T> update<T>(
    String endpoint,
    Map<String, dynamic> data,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final response = await _dio.patch(endpoint, data: data);
    return fromJson(response.data);
  }
}
```

### Cache Data Source
```dart
class CacheDataSource {
  final Database _database;
  static const Duration cacheValidDuration = Duration(hours: 12);
  
  // Store data with timestamp
  Future<void> cacheData<T>(
    String key,
    List<T> data,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    final batch = _database.batch();
    
    // Clear old data
    batch.delete('cache', where: 'key = ?', whereArgs: [key]);
    
    // Insert new data
    for (final item in data) {
      batch.insert('cache', {
        'key': key,
        'data': jsonEncode(toJson(item)),
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
    
    await batch.commit(noResult: true);
  }
  
  // Retrieve cached data
  Future<List<T>?> getCachedData<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final results = await _database.query(
      'cache',
      where: 'key = ?',
      whereArgs: [key],
      orderBy: 'timestamp DESC',
    );
    
    if (results.isEmpty) return null;
    
    // Check if cache is still valid
    final timestamp = DateTime.parse(results.first['timestamp'] as String);
    if (DateTime.now().difference(timestamp) > cacheValidDuration) {
      return null; // Cache expired
    }
    
    // Parse and return data
    return results.map((row) {
      final json = jsonDecode(row['data'] as String);
      return fromJson(json);
    }).toList();
  }
  
  // Clear all cache
  Future<void> clearCache() async {
    await _database.delete('cache');
  }
}
```

### Client-Side Notification Generation
```dart
class NotificationGenerationService {
  // NO API ENDPOINT - Generated locally
  List<Notification> generateFromDevices(List<Device> devices) {
    final notifications = <Notification>[];
    
    for (final device in devices) {
      // URGENT: Device offline (red)
      if (device['online'] == false) {
        notifications.add(Notification(
          priority: Priority.urgent,
          deviceId: device['id'],
          message: '${device['name']} is offline',
        ));
      }
      
      // MEDIUM: Has note (orange)
      if (device['note'] != null) {
        notifications.add(Notification(
          priority: Priority.medium,
          deviceId: device['id'],
          message: device['note'],
        ));
      }
      
      // LOW: Missing images (green)
      if (device['images'] == null || device['images'].isEmpty) {
        notifications.add(Notification(
          priority: Priority.low,
          deviceId: device['id'],
          message: 'Missing device images',
        ));
      }
    }
    
    return notifications;
  }
  
  Future<List<Room>> getMockRooms() async {
    await Future.delayed(Duration(milliseconds: 300));
    
    return List.generate(20, (index) => Room(
      id: index,
      name: 'Room ${100 + index}',
      building: 'Building ${index ~/ 5}',
      floor: index % 5,
      deviceIds: List.generate(
        Random().nextInt(5) + 1,
        (i) => index * 5 + i,
      ),
    ));
  }
}
```

## 2. Repository Layer

### Device Repository Implementation
```dart
@riverpod
class DeviceRepository extends _$DeviceRepository {
  late final DataSource _dataSource;
  late final CacheDataSource _cache;
  
  @override
  Future<List<Device>> build() async {
    _initializeDataSource();
    return _loadDevices();
  }
  
  void _initializeDataSource() {
    final flavor = ref.read(flavorProvider);
    
    switch (flavor) {
      case Flavor.production:
      case Flavor.staging:
        final creds = ref.read(authProvider).credentials!;
        _dataSource = ApiDataSource(
          fqdn: creds.fqdn,
          apiKey: creds.apiKey,
        );
        break;
      case Flavor.development:
        _dataSource = MockDataSource();
        break;
    }
    
    _cache = ref.read(cacheProvider);
  }
  
  Future<List<Device>> _loadDevices() async {
    try {
      // Try cache first if offline
      if (!await _isOnline()) {
        final cached = await _cache.getCachedData<Device>(
          'devices',
          Device.fromJson,
        );
        if (cached != null) return cached;
      }
      
      // Fetch from WORKING endpoints only
      List<Device> devices;
      
      if (_dataSource is ApiDataSource) {
        // Fetch from ACTUAL working endpoints
        final results = await Future.wait([
          (_dataSource as ApiDataSource).fetchAllPages(
            '/api/access_points.json',    // ✅ 221 items
            (json) => Device.fromJson({...json, 'type': 'access_point'}),
          ),
          (_dataSource as ApiDataSource).fetchAllPages(
            '/api/media_converters.json',  // ✅ 151 items (ONTs)
            (json) => Device.fromJson({...json, 'type': 'ont'}),
          ),
          (_dataSource as ApiDataSource).fetchAllPages(
            '/api/switch_devices.json',    // ✅ 1 item
            (json) => Device.fromJson({...json, 'type': 'switch'}),
          ),
          // NOT CALLED: /api/wlan_controllers.json (404)
          // NOT CALLED: /api/notifications.json (404)
        ]);
        
        devices = results.expand((list) => list).toList();
        
        // Generate notifications client-side
        final notifications = NotificationGenerationService()
          .generateFromDevices(devices);
      }
      
      // Cache the data
      await _cache.cacheData('devices', devices, (d) => d.toJson());
      
      // Start background refresh
      _startBackgroundRefresh();
      
      return devices;
    } catch (e) {
      // Try cache on error
      final cached = await _cache.getCachedData<Device>(
        'devices',
        Device.fromJson,
      );
      
      if (cached != null) {
        return cached;
      }
      
      throw RepositoryException('Failed to load devices: $e');
    }
  }
  
  void _startBackgroundRefresh() {
    Timer.periodic(Duration(minutes: 5), (_) async {
      if (await _isOnline()) {
        final freshData = await _loadDevices();
        state = AsyncData(freshData);
      }
    });
  }
  
  // Business logic methods
  Future<void> updateDeviceNote(int deviceId, String note) async {
    final devices = state.value ?? [];
    final index = devices.indexWhere((d) => d.id == deviceId);
    
    if (index == -1) throw NotFoundException('Device not found');
    
    // Update via API
    if (_dataSource is ApiDataSource) {
      await (_dataSource as ApiDataSource).update(
        '/api/devices/$deviceId.json',
        {'note': note},
        Device.fromJson,
      );
    }
    
    // Update local state
    final updated = [...devices];
    updated[index] = updated[index].copyWith(note: note);
    state = AsyncData(updated);
    
    // Update cache
    await _cache.cacheData('devices', updated, (d) => d.toJson());
  }
  
  List<Device> getDevicesByRoom(int roomId) {
    return state.value?.where((d) => d.roomId == roomId).toList() ?? [];
  }
  
  List<Device> getOfflineDevices() {
    return state.value?.where((d) => !d.online).toList() ?? [];
  }
}
```

### Room Repository (PMS Rooms Only)
```dart
@riverpod
class RoomRepository extends _$RoomRepository {
  @override
  Future<List<Room>> build() async {
    // ACTUAL: Only PMS rooms exist
    // /api/pms_rooms.json - 141 items (paginated)
    // NO device associations in response
    // NO readiness calculations
    
    final dataSource = ref.read(dataSourceProvider);
    
    final pmsRooms = await dataSource.fetchAllPages(
      '/api/pms_rooms.json',  // ✅ Working endpoint
      PmsRoom.fromJson,
    );
    
    // PROBLEM: No device-to-room mapping in API!
    // Room readiness feature NOT IMPLEMENTED
    
    return pmsRooms;
  }
  
  // 🔴 NOT IMPLEMENTED - No API support
  RoomReadiness calculateReadiness(Room room) {
    // Would need:
    // 1. Device-to-room associations (doesn't exist)
    // 2. Backend support for room status
    // 3. API changes to link devices to rooms
    
    throw UnimplementedError('Room readiness not supported by API');
  }
}
```

## 3. Provider Layer

### State Management with Riverpod
```dart
// Device providers
@riverpod
List<Device> accessPoints(AccessPointsRef ref) {
  final devices = ref.watch(deviceRepositoryProvider).value ?? [];
  return devices.where((d) => d.type == DeviceType.ap).toList();
}

@riverpod
List<Device> switches(SwitchesRef ref) {
  final devices = ref.watch(deviceRepositoryProvider).value ?? [];
  return devices.where((d) => d.type == DeviceType.switchType).toList();
}

@riverpod
List<Device> onts(OntsRef ref) {
  final devices = ref.watch(deviceRepositoryProvider).value ?? [];
  return devices.where((d) => d.type == DeviceType.ont).toList();
}

// Room providers (LIMITED FUNCTIONALITY)
@riverpod
List<Room> pmsRooms(PmsRoomsRef ref) {
  // 🔴 NO READINESS - Just basic room list
  final rooms = ref.watch(roomRepositoryProvider).value ?? [];
  return rooms;  // No device associations or readiness
}

// Notification provider (CLIENT-SIDE ONLY)
@riverpod
NotificationState notifications(NotificationsRef ref) {
  // 🔴 NO API: /api/notifications.json returns 404
  // Generate notifications locally from device status
  
  final devices = ref.watch(deviceRepositoryProvider).value ?? [];
  
  final urgent = <Notification>[];
  final medium = <Notification>[];
  final low = <Notification>[];
  
  for (final device in devices) {
    // URGENT: Offline devices (red)
    if (device['online'] == false) {
      urgent.add(Notification(
        deviceId: device['id'],
        priority: Priority.urgent,
        message: '${device['name']} is offline',
      ));
    }
    
    // MEDIUM: Devices with notes (orange)
    if (device['note'] != null) {
      medium.add(Notification(
        deviceId: device.id,
        type: NotificationType.medium,
        message: '${device.type} ${device.name}: ${device.note}',
      ));
    }
    
    if (device.images.isEmpty) {
      low.add(Notification(
        deviceId: device.id,
        type: NotificationType.low,
        message: '${device.type} ${device.name} is missing images',
      ));
    }
  }
  
  return NotificationState(
    urgent: urgent,
    medium: medium,
    low: low,
  );
}

// Search/filter providers
@riverpod
List<Device> filteredDevices(FilteredDevicesRef ref) {
  final devices = ref.watch(deviceRepositoryProvider).value ?? [];
  final searchQuery = ref.watch(searchQueryProvider);
  final typeFilter = ref.watch(deviceTypeFilterProvider);
  final statusFilter = ref.watch(deviceStatusFilterProvider);
  
  return devices.where((device) {
    // Search filter
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      if (!device.name.toLowerCase().contains(query) &&
          !device.mac.toLowerCase().contains(query) &&
          !device.serialNumber.toLowerCase().contains(query)) {
        return false;
      }
    }
    
    // Type filter
    if (typeFilter != null && device.type != typeFilter) {
      return false;
    }
    
    // Status filter
    if (statusFilter != null && device.online != statusFilter) {
      return false;
    }
    
    return true;
  }).toList();
}
```

## 4. UI Layer

### Widget Data Consumption
```dart
class DeviceListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch filtered devices
    final devicesAsync = ref.watch(filteredDevicesProvider);
    
    return devicesAsync.when(
      data: (devices) => RefreshIndicator(
        onRefresh: () => ref.refresh(deviceRepositoryProvider.future),
        child: ListView.builder(
          itemCount: devices.length,
          itemBuilder: (context, index) {
            final device = devices[index];
            return DeviceTile(device: device);
          },
        ),
      ),
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) => ErrorView(
        error: error,
        onRetry: () => ref.invalidate(deviceRepositoryProvider),
      ),
    );
  }
}

class DeviceTile extends ConsumerWidget {
  final Device device;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Icon(
        device.online ? Icons.check_circle : Icons.error,
        color: device.online ? Colors.green : Colors.red,
      ),
      title: Text(device.name),
      subtitle: Text('${device.type} - ${device.mac}'),
      trailing: device.note != null ? Icon(Icons.note) : null,
      onTap: () => context.push('/device/${device.id}'),
    );
  }
}
```

## Data Flow Examples

### Example 1: Loading Devices
```
1. App starts → DeviceListScreen builds
2. Widget watches deviceRepositoryProvider
3. Provider triggers DeviceRepository.build()
4. Repository checks cache validity
5. If expired/missing → Fetch from API
6. API returns paginated data
7. Repository fetches all pages
8. Transform API JSON to Device models
9. Cache data with timestamp
10. Return devices to provider
11. Provider notifies widget
12. Widget rebuilds with data
```

### Example 2: Updating Device Note
```
1. User edits note in DeviceDetailScreen
2. UI calls repository.updateDeviceNote()
3. Repository sends PATCH to API
4. API confirms update
5. Repository updates local state
6. Repository updates cache
7. Provider notifies all listeners
8. All widgets showing this device update
```

### Example 3: Offline Mode
```
1. App starts offline
2. Repository tries API call
3. API call fails (no network)
4. Repository checks cache
5. Cache has data < 12 hours old
6. Return cached data
7. Show offline indicator in UI
8. Start polling for connectivity
9. When online → Background refresh
10. Update UI seamlessly
```

## Error Handling

### Repository Error Handling
```dart
class RepositoryException implements Exception {
  final String message;
  final dynamic originalError;
  
  RepositoryException(this.message, [this.originalError]);
}

class NetworkException extends RepositoryException {
  NetworkException(String message) : super(message);
}

class CacheException extends RepositoryException {
  CacheException(String message) : super(message);
}

class NotFoundException extends RepositoryException {
  NotFoundException(String message) : super(message);
}
```

### UI Error Handling
```dart
class ErrorBoundary extends ConsumerWidget {
  final Widget child;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ErrorBoundaryWidget(
      onError: (error, stack) {
        // Log error
        ref.read(loggerProvider).error(error, stack);
        
        // Show user-friendly message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getErrorMessage(error)),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => ref.invalidate(deviceRepositoryProvider),
            ),
          ),
        );
      },
      child: child,
    );
  }
  
  String _getErrorMessage(dynamic error) {
    if (error is NetworkException) {
      return 'Connection failed. Using offline data.';
    } else if (error is NotFoundException) {
      return 'Data not found.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }
}
```

## Performance Optimizations

### Debouncing
```dart
@riverpod
class DebouncedSearch extends _$DebouncedSearch {
  Timer? _debounceTimer;
  
  @override
  String build() => '';
  
  void updateQuery(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 300), () {
      state = query;
    });
  }
}
```

### Pagination UI
```dart
class PaginatedDeviceList extends ConsumerStatefulWidget {
  @override
  _PaginatedDeviceListState createState() => _PaginatedDeviceListState();
}

class _PaginatedDeviceListState extends ConsumerState<PaginatedDeviceList> {
  final _scrollController = ScrollController();
  static const _pageSize = 20;
  int _currentPage = 0;
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMore();
    }
  }
  
  void _loadMore() {
    _currentPage++;
    ref.read(deviceRepositoryProvider.notifier).loadPage(_currentPage);
  }
}
```

## Summary

The data flow architecture ensures:
1. **Clear separation** of concerns
2. **Offline-first** capability
3. **Automatic caching** with expiry
4. **Background refresh** for fresh data
5. **Type-safe** data transformation
6. **Reactive UI** updates
7. **Comprehensive error handling**