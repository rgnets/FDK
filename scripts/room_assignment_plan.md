# Room Assignment Plan - Based on API Analysis

## Current Situation

### API Response Structure
1. **Access Points** (`/api/access_points`)
   - Total: 220 devices
   - With pms_room: 218 (99%)
   - pms_room format: `{"id": integer, "name": "(Interurban) XXX"}`

2. **Media Converters** (`/api/media_converters`)
   - Total: 151 devices
   - With pms_room: 150 (99%)
   - pms_room format: Same as access points

3. **Switches** (`/api/switch_devices`)
   - Total: 1 device
   - With pms_room: 0
   - No room assignment

4. **WLAN Devices** (`/api/wlan_devices`)
   - Total: 3 devices
   - With pms_room: 0
   - No room assignment

## Problem Analysis

### Current Code Issues
1. **DeviceModel** expects fields that don't exist:
   - Expects: `pms_room_id` (integer field)
   - API provides: `pms_room` (object with id and name)
   - Expects: `location` (string field)
   - API provides: Nothing (field doesn't exist)

2. **Mock Data Mismatch**:
   - Mock sets `pmsRoomId` to integer
   - Mock sets `location` to room string
   - API has nested `pms_room` object

## Solution Plan

### Option 1: Update DeviceModel to Match API (RECOMMENDED)
**Approach**: Modify DeviceModel to handle the actual API structure

```dart
// Current DeviceModel expects:
pmsRoomId: int?
location: String?

// Should be:
pmsRoom: PmsRoom?  // Object with id and name
location: String?   // Can be derived from pmsRoom.name or set to null
```

**Implementation Steps**:
1. Create PmsRoom model class
2. Update DeviceModel to include pmsRoom object
3. Update JSON mapping to parse pms_room object
4. Derive pmsRoomId from pmsRoom?.id for compatibility
5. Use pmsRoom?.name for display purposes

**Pros**:
- Matches actual API structure
- Preserves room name information
- Architecturally correct

**Cons**:
- Requires model changes
- Need to update JSON mapping

### Option 2: Transform API Response During Parsing
**Approach**: Keep current model, transform data during parsing

**Implementation**:
```dart
// In DeviceModel.fromJson:
pmsRoomId: json['pms_room']?['id'] as int?,
location: json['pms_room']?['name'] as String?,
```

**Pros**:
- Minimal code changes
- Works with existing model

**Cons**:
- Loses nested structure
- Not fully representative of API

### Option 3: Update Mock Data Only
**Approach**: Make mock data return null for consistency

**Implementation**:
```dart
// In MockDataService:
pmsRoomId: null,
location: null,
```

**Pros**:
- Simplest approach
- Consistent display (all null)

**Cons**:
- Loses room information in development
- Not utilizing available API data

## Recommended Implementation

### Step 1: Create PmsRoom Model
```dart
@freezed
class PmsRoom with _$PmsRoom {
  const factory PmsRoom({
    required int id,
    required String name,
  }) = _PmsRoom;
  
  factory PmsRoom.fromJson(Map<String, dynamic> json) => 
      _$PmsRoomFromJson(json);
}
```

### Step 2: Update DeviceModel
```dart
@freezed
class DeviceModel with _$DeviceModel {
  const factory DeviceModel({
    // ... other fields ...
    PmsRoom? pmsRoom,  // New field
    int? pmsRoomId,    // Computed from pmsRoom?.id
    String? location,  // Computed from pmsRoom?.name
  }) = _DeviceModel;
}
```

### Step 3: Update Notification Display
Since `pmsRoom.name` contains "(Interurban) 007" format:
- Extract room number for display
- Or use full name if appropriate

### Step 4: Update Mock Data
Make mock data structure match API:
```dart
Device(
  // ... other fields ...
  pmsRoom: PmsRoom(
    id: 101,
    name: '(North Tower) 101',
  ),
)
```

## Alternative: Minimal Change Approach

If updating models is not feasible:

1. **Parse pms_room during JSON mapping**:
   - Extract `pms_room.id` → `pmsRoomId`
   - Extract `pms_room.name` → `location`

2. **Update mock to match**:
   - Set `pmsRoomId` to room number
   - Set `location` to "(Building) Room" format

3. **Simplify notification display**:
   - Use location if available
   - Otherwise show title only

## Testing Strategy

1. Create test to verify pms_room parsing
2. Test notification display with various formats
3. Ensure consistency across environments
4. Verify architectural compliance

## Architectural Compliance

✓ **MVVM**: Models represent data structure
✓ **Clean Architecture**: Data layer handles transformation
✓ **Dependency Injection**: No changes needed
✓ **Riverpod**: State management unchanged
✓ **go_router**: No routing changes