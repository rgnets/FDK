# Field Selection Implementation - Exact Plan

## Why We Failed

**THE SINGLE POINT OF FAILURE:**
```dart
// Line 51-57 in device_remote_data_source.dart
Future<List<Map<String, dynamic>>> _fetchAllPages(String endpoint) async {
  // ❌ NO fields parameter
  final response = await apiService.get<dynamic>(
    '$endpoint${endpoint.contains('?') ? '&' : '?'}page_size=0',
    // ❌ NO &only= parameter added
  );
}
```

This method is called by everything but NEVER adds field selection to the API call.

## Context-Aware Refresh Strategy (Your Requirement)

Based on your input: "depend on what is being looked at"

### Three Refresh Contexts

1. **List View Context**
   - Refresh with `listFields` (14 fields, 33KB)
   - Updates visible list items only
   - Cache key: `devices_list:id,name,status...`

2. **Detail View Context**  
   - Refresh with ALL fields for ONE device
   - Complete data update for viewed device
   - Cache key: `device:$deviceId:all`

3. **Room View Context**
   - Refresh all devices in room with full fields
   - Complete data for room context
   - Cache key: `room:$roomId:all`

## Implementation Order (Do it all at once, no feature branch)

### Step 1: Create Field Sets Constants
```dart
// lib/core/constants/device_field_sets.dart
class DeviceFieldSets {
  static const String version = '2.0.0';
  
  // Minimal fields for list views (33KB instead of 1.5MB)
  static const List<String> listFields = [
    'id',
    'name', 
    'type',
    'status',
    'ip_address',
    'mac_address',
    'pms_room',      // Keep nested as you decided
    'location',
    'last_seen',
    'signal_strength',
    'connected_clients',
    'online',        
    'note',          
    'images',        
  ];
  
  // All fields for detail view
  static const List<String> detailFields = []; // Empty = all fields
  
  // Minimal fields for background refresh
  static const List<String> refreshFields = [
    'id',
    'status',
    'online',
    'last_seen',
    'signal_strength',
  ];
}
```

### Step 2: Fix Remote Data Source (THE CRITICAL FIX)
```dart
// In device_remote_data_source.dart

// FIX 1: Add fields parameter to _fetchAllPages
Future<List<Map<String, dynamic>>> _fetchAllPages(
  String endpoint, {
  List<String>? fields,  // ✅ ADD THIS
}) async {
  try {
    _logger.d('Fetching from $endpoint with fields: ${fields?.join(',')}');
    
    // Build query with field selection
    final fieldsParam = fields?.isNotEmpty == true 
        ? '&only=${fields.join(',')}' 
        : '';
    
    // ✅ NOW includes field selection!
    final response = await apiService.get<dynamic>(
      '$endpoint${endpoint.contains('?') ? '&' : '?'}page_size=0$fieldsParam',
    );
    
    // ... rest of existing implementation unchanged
  }
}

// FIX 2: Add fields to getDevices
@override
Future<List<DeviceModel>> getDevices({
  List<String>? fields,  // ✅ ADD THIS
}) async {
  try {
    _getDevicesCallCount++;
    final callId = _getDevicesCallCount;
    
    _logger.i('📡 getDevices() with fields: ${fields?.join(',')}');
    
    // Pass fields to parallel fetch
    final results = await Future.wait([
      _fetchDeviceTypeWithRetry('access_points', fields: fields),
      _fetchDeviceTypeWithRetry('media_converters', fields: fields),
      _fetchDeviceTypeWithRetry('switch_devices', fields: fields),
      _fetchDeviceTypeWithRetry('wlan_devices', fields: fields),
    ]);
    
    // ... rest unchanged
  }
}

// FIX 3: Update retry method
Future<List<DeviceModel>> _fetchDeviceTypeWithRetry(
  String type, {
  List<String>? fields,  // ✅ ADD THIS
  int maxRetries = 3,
}) async {
  // ... existing retry logic
  final results = await _fetchDeviceType(type, fields: fields);
  // ... rest unchanged
}

// FIX 4: Update fetch type method
Future<List<DeviceModel>> _fetchDeviceType(
  String type, {
  List<String>? fields,  // ✅ ADD THIS
}) async {
  try {
    _logger.d('Fetching $type with fields: ${fields?.join(',')}');
    final results = await _fetchAllPages('/api/$type.json', fields: fields);
    // ... rest unchanged
  }
}

// FIX 5: Add fields to getDevice
@override
Future<DeviceModel> getDevice(String id, {
  List<String>? fields,  // ✅ ADD THIS
}) async {
  // Implementation for single device with field selection
}
```

### Step 3: Update Repository Layer
```dart
// In domain/repositories/device_repository.dart
abstract class DeviceRepository {
  Future<Either<Failure, List<Device>>> getDevices({
    List<String>? fields,  // ✅ ADD
  });
  Future<Either<Failure, Device>> getDevice(
    String id, {
    List<String>? fields,  // ✅ ADD
  });
  // ... other methods unchanged
}

// In data/repositories/device_repository.dart
@override
Future<Either<Failure, List<Device>>> getDevices({
  List<String>? fields,
}) async {
  try {
    // Pass fields to data source
    final deviceModels = await dataSource.getDevices(fields: fields);
    // ... rest unchanged
  }
}
```

### Step 4: Update Use Cases
```dart
// Create new params class
class GetDevicesParams {
  final List<String>? fields;
  const GetDevicesParams({this.fields});
}

// Update GetDevices use case
class GetDevices extends UseCase<List<Device>, GetDevicesParams> {
  @override
  Future<Either<Failure, List<Device>>> call(GetDevicesParams params) async {
    _logger.d('GetDevices use case with fields: ${params.fields?.join(',')}');
    return await repository.getDevices(fields: params.fields);
  }
}

// Similarly for GetDevice
class GetDeviceParams {
  final String id;
  final List<String>? fields;
  const GetDeviceParams({required this.id, this.fields});
}
```

### Step 5: Update Providers with Context-Aware Refresh
```dart
// In devices_provider.dart

@override
Future<List<Device>> build() async {
  // Load with minimal fields for list view
  try {
    final devices = await _cacheManager.get<List<Device>>(
      key: 'devices_list',
      fields: DeviceFieldSets.listFields,  // ✅ ADD
      fetcher: () async {
        final getDevices = ref.read(getDevicesProvider);
        final result = await getDevices(
          GetDevicesParams(fields: DeviceFieldSets.listFields)  // ✅ USE
        );
        // ... rest unchanged
      },
      ttl: const Duration(minutes: 5),
    );
    return devices ?? [];
  }
}

// Context-aware silent refresh
Future<void> silentRefresh({String? context}) async {
  try {
    // Determine fields based on context
    List<String>? fields;
    String cacheKey;
    
    if (context == 'detail' && _currentDeviceId != null) {
      // Refresh full data for current device
      fields = DeviceFieldSets.detailFields;
      cacheKey = 'device:$_currentDeviceId';
    } else if (context == 'room' && _currentRoomId != null) {
      // Refresh room devices with full data
      fields = DeviceFieldSets.detailFields;
      cacheKey = 'room:$_currentRoomId';
    } else {
      // Default: refresh list view
      fields = DeviceFieldSets.listFields;
      cacheKey = 'devices_list';
    }
    
    final devices = await _cacheManager.get<List<Device>>(
      key: cacheKey,
      fields: fields,
      fetcher: () async {
        final getDevices = ref.read(getDevicesProvider);
        final result = await getDevices(GetDevicesParams(fields: fields));
        return result.fold(
          (failure) => throw Exception(failure.message),
          (devices) => devices,
        );
      },
      ttl: const Duration(minutes: 5),
      forceRefresh: true,
    );
    
    // Update state without loading indicator
    if (devices != null && state.hasValue) {
      state = AsyncValue.data(devices);
    }
  } catch (e) {
    _logger.w('Silent refresh failed: $e');
  }
}
```

### Step 6: Update Cache Manager for Field-Aware Keys
```dart
// In cache_manager.dart

String _getCacheKey(String key, List<String>? fields) {
  if (fields == null || fields.isEmpty) return '$key:all';
  final sortedFields = List<String>.from(fields)..sort();
  return '$key:${sortedFields.join(',')}';
}

Future<T?> get<T>({
  required String key,
  required Future<T> Function() fetcher,
  required Duration ttl,
  List<String>? fields,  // ✅ ADD
  bool forceRefresh = false,
}) async {
  final cacheKey = _getCacheKey(key, fields);
  
  // Check for existing entry with field-aware key
  if (!forceRefresh && _cache.containsKey(cacheKey)) {
    final entry = _cache[cacheKey] as CacheEntry<T>;
    
    if (entry.isStale) {
      // Stale-while-revalidate
      final staleData = entry.data;
      unawaited(_fetchAndCache(cacheKey, fetcher, ttl));
      return staleData;
    }
    
    if (!entry.isExpired) {
      return entry.data;
    }
  }
  
  // Fetch and cache with field-aware key
  return await _fetchAndCache(cacheKey, fetcher, ttl);
}
```

### Step 7: Update Mock Data Source
```dart
// In device_mock_data_source.dart

@override
Future<List<DeviceModel>> getDevices({
  List<String>? fields,
}) async {
  await Future.delayed(const Duration(milliseconds: 500));
  
  final allDevices = _generateMockDevices();
  
  // If fields specified, filter mock data to match
  if (fields != null && fields.isNotEmpty) {
    return allDevices.map((device) {
      final json = device.toJson();
      final filtered = <String, dynamic>{};
      
      // Only include requested fields
      for (final field in fields) {
        if (json.containsKey(field)) {
          filtered[field] = json[field];
        }
      }
      
      // Always include id for consistency
      filtered['id'] = json['id'];
      
      return DeviceModel.fromJson(filtered);
    }).toList();
  }
  
  return allDevices;
}
```

## Validation Tests

### Test 1: Field Selection Works
```dart
// test_programs/test_field_selection_works.dart
void main() async {
  // Test that API is called with correct fields
  final dataSource = DeviceRemoteDataSourceImpl(apiService: mockApiService);
  
  when(mockApiService.get('/api/access_points.json?page_size=0&only=id,name,status'))
    .thenAnswer((_) async => Response(data: []));
  
  await dataSource.getDevices(fields: ['id', 'name', 'status']);
  
  verify(mockApiService.get(contains('only=id,name,status')));
}
```

### Test 2: Context-Aware Refresh
```dart
// test_programs/test_context_aware_refresh.dart
void main() async {
  // Test list view refresh
  await provider.silentRefresh(context: 'list');
  verify(getDevices(GetDevicesParams(fields: DeviceFieldSets.listFields)));
  
  // Test detail view refresh  
  await provider.silentRefresh(context: 'detail');
  verify(getDevice(GetDeviceParams(id: 'device1', fields: [])));
}
```

### Test 3: Cache Separation
```dart
// test_programs/test_cache_separation.dart
void main() async {
  final cache = CacheManager();
  
  // Store list data
  await cache.set('devices', listData, fields: ['id', 'name']);
  
  // Store detail data
  await cache.set('devices', detailData, fields: null);
  
  // Verify they're separate
  final list = await cache.get('devices', fields: ['id', 'name']);
  final detail = await cache.get('devices', fields: null);
  
  expect(list, isNot(equals(detail)));
}
```

## Success Metrics

1. **API calls include `only` parameter** ✓
2. **List view loads in <500ms** ✓
3. **Data transfer reduced by 97%** ✓
4. **Cache keys include fields** ✓
5. **Context-aware refresh works** ✓
6. **All tests pass** ✓
7. **Zero errors/warnings** ✓

## Architecture Compliance

✅ **MVVM**: Field selection in ViewModels (Notifiers)
✅ **Clean Architecture**: Optional params through layers
✅ **DI**: All via Riverpod providers
✅ **Single Responsibility**: Each layer focused
✅ **DRY**: Field sets defined once
✅ **Type Safety**: Strong typing throughout

## The Fix is Simple

1. Add `fields` parameter to `_fetchAllPages`
2. Build `&only=` query parameter
3. Pass fields through all layers
4. Use context for refresh strategy
5. Separate cache entries by fields

Ready to implement?