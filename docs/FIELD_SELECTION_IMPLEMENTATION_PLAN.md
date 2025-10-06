# Field Selection Implementation Plan

## Why This Wasn't Done Initially

**Critical Oversight**: The original implementation fetched ALL fields from the API without utilizing the `only` parameter for field selection. This caused:
- 17.7 second load times for access points
- Fetching 1.5MB when only 33KB was needed
- Poor user experience
- Unnecessary server load

## Current Problems

1. **No Field Selection**: `device_remote_data_source.dart` fetches all fields
2. **No Hierarchical Loading**: List and detail views get same data
3. **Environment Divergence**: Mock data has different fields than API
4. **Cache Inefficiency**: Caching full objects when minimal data needed

## Implementation Strategy

### Principle: ONE CODE PATH FOR ALL ENVIRONMENTS

All environments (development, staging, production) MUST:
- Use the same data models
- Use the same field selection logic
- Follow the same loading patterns
- Have consistent behavior

### Phase 1: Define Field Sets

```dart
class DeviceFieldSets {
  // Minimal fields for list views
  static const List<String> listFields = [
    'id',
    'name', 
    'type',
    'status',
    'ip_address',
    'mac_address',
    'pms_room',
    'location',
    'last_seen',
    'signal_strength',
    'connected_clients',
    'online',  // For notifications
    'note',    // For notifications
    'images',  // For notifications
  ];
  
  // All fields for detail view
  static const List<String> detailFields = []; // Empty = all fields
  
  // Fields for background refresh
  static const List<String> refreshFields = [
    'id',
    'status',
    'online',
    'last_seen',
    'signal_strength',
  ];
}
```

### Phase 2: Update Remote Data Source

```dart
class DeviceRemoteDataSourceImpl {
  Future<List<DeviceModel>> getDevices({
    List<String>? fields,  // NEW: field selection
  }) async {
    // Build query with field selection
    final fieldsParam = fields?.isNotEmpty == true 
        ? '&only=${fields.join(',')}' 
        : '';
    
    // Fetch with field selection
    final endpoint = '/api/access_points?page_size=0$fieldsParam';
    // ... existing fetch logic
  }
  
  Future<DeviceModel> getDevice(String id, {
    List<String>? fields,  // NEW: field selection for single device
  }) async {
    // Similar implementation
  }
}
```

### Phase 3: Update Mock Data Source (Development)

```dart
class DeviceMockDataSourceImpl {
  Future<List<DeviceModel>> getDevices({
    List<String>? fields,  // Match remote signature
  }) async {
    // Return mock data with SAME structure as API
    // If fields specified, filter the mock data
  }
}
```

### Phase 4: Update Use Cases

```dart
class GetDevices {
  Future<Either<Failure, List<Device>>> call({
    List<String>? fields,  // Pass through field selection
  }) async {
    return await repository.getDevices(fields: fields);
  }
}
```

### Phase 5: Update Providers

```dart
class DevicesNotifier {
  Future<List<Device>> build() async {
    // Load with minimal fields for list view
    final devices = await _loadDevices(
      fields: DeviceFieldSets.listFields,
    );
  }
  
  Future<void> silentRefresh() async {
    // Background refresh with minimal fields
    final devices = await _loadDevices(
      fields: DeviceFieldSets.refreshFields,
    );
  }
}
```

### Phase 6: Update Detail View Loading

```dart
class DeviceNotifier {
  Future<Device?> build(String deviceId) async {
    // First try cache (might have minimal data)
    final cached = await _cacheManager.get(deviceId);
    if (cached != null) return cached;
    
    // Fetch complete device data for detail view
    final device = await getDevice(
      deviceId,
      fields: DeviceFieldSets.detailFields, // All fields
    );
  }
}
```

## Testing Strategy

### 1. Create Unified Test
```dart
// Test that all environments behave identically
void testUnifiedBehavior() {
  for (final env in [development, staging, production]) {
    // Test same field selection
    // Test same data structure
    // Test same performance characteristics
  }
}
```

### 2. Performance Benchmarks
- List view load time: < 500ms
- Detail view load time: < 1s
- Data transfer: 97% reduction
- Memory usage: 90% reduction

### 3. Compatibility Tests
- Ensure mock data matches API structure
- Verify all fields mapped correctly
- Test offline/online transitions

## Migration Plan

1. **Implement field selection in remote data source**
2. **Update mock data to match API exactly**
3. **Add field parameters through all layers**
4. **Update providers to use appropriate field sets**
5. **Test in all environments**
6. **Deploy with monitoring**

## Expected Results

### Before
- Access Points: 17.7s, 1.5MB
- All fields fetched always
- Different behavior per environment

### After
- List View: 350ms, 33KB (98% improvement)
- Detail View: 1s, full data only when needed
- Consistent behavior across all environments

## Architecture Compliance

✅ **MVVM**: Field selection in ViewModel (provider)
✅ **Clean Architecture**: Field sets defined in domain layer
✅ **DI**: All via providers
✅ **Single Responsibility**: Each layer handles its concern
✅ **DRY**: One code path for all environments

## Questions for Implementation

1. **Should we cache different field sets separately?**
   - List data with long TTL
   - Detail data with short TTL
   
2. **Should we progressively enhance?**
   - Show list data immediately
   - Load detail data in background when viewing

3. **How to handle field addition?**
   - Version field sets?
   - Migration strategy?

## Critical Success Factors

1. **MUST work identically in all environments**
2. **MUST reduce load time by >95%**
3. **MUST maintain backward compatibility**
4. **MUST follow all architectural patterns**
5. **MUST have zero errors/warnings**