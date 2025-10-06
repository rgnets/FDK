# Solution: Intermittent Zero Values in Device Counts

## Problem Statement
The UI sometimes shows 0 devices for certain types (e.g., 0 APs), while other times it shows the correct count (220 APs). This intermittent behavior occurs without any code changes.

## Root Cause Analysis

### The Problem
`device_remote_data_source.dart` has **5 silent failure points** that return empty lists `[]` instead of throwing exceptions:

1. **Line 35** - When response.data is null
2. **Line 62** - When no recognized data key found in Map response
3. **Line 66** - When unexpected response type
4. **Line 84** - When any exception occurs in _fetchAllPages
5. **Line 288** - When any exception occurs in _fetchDeviceType

### Why It's Intermittent

The `getDevices()` method fetches 4 device types in parallel:
```dart
final results = await Future.wait([
  _fetchDeviceType('access_points'),     // Sometimes times out → returns []
  _fetchDeviceType('media_converters'),  // Usually works → returns devices
  _fetchDeviceType('switch_devices'),    // Usually works → returns devices
  _fetchDeviceType('wlan_devices'),      // Sometimes fails → returns []
]);
```

**When all endpoints work:** UI shows correct counts
**When one endpoint fails:** That device type shows 0, others show correctly

### Evidence
Testing revealed `/api/access_points.json` times out intermittently, which explains why APs often show as 0.

## The Solution

### Option 1: Retry Logic (Recommended)
Add retry mechanism for failed endpoints:

```dart
Future<List<DeviceModel>> _fetchDeviceTypeWithRetry(
  String type, {int maxRetries = 3}) async {
  for (int attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      return await _fetchDeviceType(type);
    } catch (e) {
      _logger.w('Attempt $attempt failed for $type: $e');
      if (attempt == maxRetries) {
        // After all retries, could return [] or throw
        _logger.e('All retries exhausted for $type');
        return []; // Or throw to show error in UI
      }
      // Wait before retry (exponential backoff)
      await Future.delayed(Duration(seconds: attempt));
    }
  }
  return [];
}
```

Then update `getDevices()`:
```dart
final results = await Future.wait([
  _fetchDeviceTypeWithRetry('access_points'),
  _fetchDeviceTypeWithRetry('media_converters'),
  _fetchDeviceTypeWithRetry('switch_devices'),
  _fetchDeviceTypeWithRetry('wlan_devices'),
]);
```

### Option 2: Cache Last Successful Response
Store and reuse last successful data when endpoints fail:

```dart
static final Map<String, List<Map<String, dynamic>>> _responseCache = {};

Future<List<Map<String, dynamic>>> _fetchAllPages(String endpoint) async {
  try {
    // ... existing fetch logic ...
    
    // On success, cache the response
    _responseCache[endpoint] = results;
    return results;
    
  } on Exception catch (e) {
    _logger.e('Error fetching from $endpoint: $e');
    
    // Return cached data if available
    if (_responseCache.containsKey(endpoint)) {
      _logger.w('Using cached data for $endpoint');
      return _responseCache[endpoint]!;
    }
    
    // No cache available, return empty
    return [];
  }
}
```

### Option 3: Propagate Errors (Breaking Change)
Change all `return []` to `throw` exceptions, letting the UI handle errors:

```dart
} on Exception catch (e) {
  _logger.e('Error fetching from $endpoint: $e');
  throw DeviceDataSourceException('Failed to fetch $endpoint', e);
}
```

## Architecture Compliance

✅ **MVVM**: Solution stays in data layer, ViewModels unchanged
✅ **Clean Architecture**: Problem isolated to data source implementation
✅ **Dependency Injection**: No changes to provider structure
✅ **Riverpod**: State management receives corrected data
✅ **Repository Pattern**: Can add retry logic at repository level

## Immediate Workaround (No Code Changes)

1. **Users**: Pull-to-refresh when seeing 0 devices
2. **Developers**: Check logs for "Error fetching from" messages
3. **Operations**: Monitor API endpoint health, especially `/api/access_points.json`

## Recommendation

Implement **Option 1 (Retry Logic)** because:
- Non-breaking change
- Handles transient network issues
- Improves reliability without hiding persistent problems
- Maintains architectural patterns
- Can be combined with Option 2 for extra resilience

The retry logic with exponential backoff will resolve most intermittent failures while still surfacing persistent issues through logging.