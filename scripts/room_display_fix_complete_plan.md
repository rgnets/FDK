# Room Display Fix - Complete Implementation Plan

## Problem Statement
- **Development**: Shows 3 lines per room (Name, Location, Devices)
- **Staging**: Shows 2 lines per room (Name, Devices)
- **Root Cause**: RoomMockDataSource synthesizes `building` and `floor` values that don't exist in the API

## Analysis Results

### API Structure Verification
The staging API returns:
```json
{
  "id": 128,
  "room": "803",
  "pms_property": {
    "id": 1,
    "name": "Interurban"
  }
  // NO "building" field
  // NO "floor" field
}
```

### Current Problem
`RoomMockDataSource` is incorrectly setting:
- `building: propertyName ?? ""` → Results in "North Tower"
- `floor: _extractFloor(roomNumber)` → Results in "1"

But `RemoteDataSource` correctly does:
- `building: roomData['building']?.toString() ?? ""` → Results in ""
- `floor: roomData['floor']?.toString() ?? ""` → Results in ""

## Implementation Plan

### File to Change
`lib/features/rooms/data/datasources/room_mock_data_source.dart`

### Change #1: getRooms() method
**Line ~51 in the return statement**

**FROM:**
```dart
return RoomModel(
  id: roomData['id']?.toString() ?? '',
  name: displayName,
  building: propertyName ?? '',      // ← WRONG
  floor: _extractFloor(roomNumber),  // ← WRONG
  deviceIds: _extractDeviceIds(roomData),
  metadata: roomData,
);
```

**TO:**
```dart
return RoomModel(
  id: roomData['id']?.toString() ?? '',
  name: displayName,
  building: roomData['building']?.toString() ?? '',  // ← FIXED
  floor: roomData['floor']?.toString() ?? '',        // ← FIXED
  deviceIds: _extractDeviceIds(roomData),
  metadata: roomData,
);
```

### Change #2: getRoom() method
**Line ~95 in the return statement**

**FROM:**
```dart
return RoomModel(
  id: roomData['id']?.toString() ?? '',
  name: displayName,
  building: propertyName ?? '',      // ← WRONG
  floor: _extractFloor(roomNumber),  // ← WRONG
  deviceIds: _extractDeviceIds(roomData),
  metadata: roomData,
);
```

**TO:**
```dart
return RoomModel(
  id: roomData['id']?.toString() ?? '',
  name: displayName,
  building: roomData['building']?.toString() ?? '',  // ← FIXED
  floor: roomData['floor']?.toString() ?? '',        // ← FIXED
  deviceIds: _extractDeviceIds(roomData),
  metadata: roomData,
);
```

## Expected Results

### Before Fix
- **Development**: "(North Tower) 101" / "North Tower Floor 1" / "X/Y devices"
- **Staging**: "(Interurban) 803" / "X/Y devices"
- Inconsistent number of lines

### After Fix
- **Development**: "(North Tower) 101" / "X/Y devices"
- **Staging**: "(Interurban) 803" / "X/Y devices"
- Consistent 2 lines in both environments

## Architecture Compliance

✅ **MVVM Pattern**: View layer unchanged, displays ViewModel data correctly
✅ **Clean Architecture**: Fix isolated to data source layer only
✅ **Dependency Injection**: No changes to dependency injection
✅ **Riverpod State Management**: No changes to state providers
✅ **go_router**: No routing changes needed
✅ **Single Responsibility**: Data source maintains its single responsibility
✅ **Interface Segregation**: Same interface implementation maintained
✅ **Consistency Principle**: Mock now matches production exactly

## Testing Plan

1. **Compilation Check**
   - Run `flutter analyze`
   - Expect zero errors and warnings

2. **Visual Verification**
   - Run app in development mode
   - Verify rooms show 2 lines (not 3)
   - Compare with staging appearance

3. **Data Verification**
   - Check `locationDisplay` returns empty string
   - Verify `building` and `floor` are empty strings in RoomModel

## Important Notes

- **DO NOT** delete `_extractFloor()` method - keep for potential future use
- **DO NOT** change `RemoteDataSource` - it's already correct
- **DO NOT** change any other files - this is an isolated fix
- The JSON structure from `getMockPmsRoomsJson()` is already correct

## Risk Assessment

- **Risk Level**: None
- **Impact**: Only affects mock data display in development
- **Backward Compatibility**: Maintained
- **Performance**: No impact
- **Security**: No impact

## Summary

The fix ensures that `RoomMockDataSource` uses the exact same field parsing logic as `RemoteDataSource`, eliminating the synthesized `building` and `floor` values that were causing the extra location line in development mode.