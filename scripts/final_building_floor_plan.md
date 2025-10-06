# Final Plan: Building/Floor Fields Consistency

## Executive Summary

The staging API does **NOT** provide `building` or `floor` fields. The mock data source should match this behavior exactly. The UI already handles null values correctly.

## Detailed Analysis

### 1. API Reality
- **Staging API provides**: `id`, `room`, `pms_property.name`
- **Staging API does NOT provide**: `building`, `floor`
- **Mock should match exactly**: No synthesizing of missing fields

### 2. UI Usage Analysis

#### Rooms List Screen
- Uses `locationDisplay` getter from RoomViewModel
- If `locationDisplay` is not empty, adds extra line
- **Problem**: Extra line appears when building/floor are populated

#### Room Detail Screen  
- Shows building/floor in header (line 222-224)
- Shows building/floor in info section (line 321-324)
- **Already handles null correctly** with conditional rendering

### 3. Architecture Decision

**KEEP** building/floor fields in domain, but ensure they're **null/empty** from both data sources.

**Rationale**:
- ✅ Minimal risk - only data source changes needed
- ✅ Future-proof - ready if API ever adds these fields
- ✅ UI compatible - already has null checks
- ✅ Clean Architecture - domain model stays stable
- ✅ No breaking changes

## Implementation Plan

### File to Modify
`lib/features/rooms/data/datasources/room_mock_data_source.dart`

### Change 1: getRooms() method
```dart
// FROM (synthesizing values):
building: propertyName ?? "",
floor: _extractFloor(roomNumber),

// TO (matching API structure):
building: roomData['building']?.toString() ?? "",
floor: roomData['floor']?.toString() ?? "",
```

### Change 2: getRoom() method
```dart
// FROM (synthesizing values):
building: propertyName ?? "",
floor: _extractFloor(roomNumber),

// TO (matching API structure):
building: roomData['building']?.toString() ?? "",
floor: roomData['floor']?.toString() ?? "",
```

## Expected Behavior After Fix

### Rooms List View
- **Before**: 3 lines per room
  1. "(North Tower) 101"
  2. "North Tower Floor 1" ← Extra line
  3. "3/4 devices online"

- **After**: 2 lines per room
  1. "(North Tower) 101"
  2. "3/4 devices online"

### Room Detail View
- **Before**: Shows Building and Floor sections with values
- **After**: Building and Floor sections not displayed (null check fails)

## Architecture Compliance

| Principle | Status | Notes |
|-----------|--------|-------|
| MVVM | ✅ | ViewModel correctly exposes nullable fields |
| Clean Architecture | ✅ | Domain entity remains unchanged |
| Dependency Injection | ✅ | No changes to injection |
| Riverpod | ✅ | State management unchanged |
| go_router | ✅ | Routing unaffected |
| Single Responsibility | ✅ | Each layer maintains its role |
| Interface Segregation | ✅ | Interfaces unchanged |
| Consistency | ✅ | Mock matches production exactly |

## Testing Strategy

1. **Compile Check**: Run `flutter analyze` - expect zero errors
2. **Visual Check**: Verify rooms list shows 2 lines (not 3)
3. **Detail Check**: Verify room detail doesn't show empty building/floor
4. **Data Check**: Verify `locationDisplay` returns empty string

## Risk Assessment

- **Risk Level**: LOW
- **Files Changed**: 1
- **Methods Changed**: 2
- **Breaking Changes**: None
- **Rollback**: Simple revert if needed

## Key Insight

The room name already contains the complete display information in the format "(Building) Room". Separate building and floor fields are redundant and were never intended to be populated from the API. The mock should faithfully reproduce this behavior.

## Summary

By making RoomMockDataSource use the exact same field extraction logic as RemoteDataSource (looking for fields that don't exist), we ensure consistent behavior across all environments. The UI already gracefully handles the null values, resulting in a clean, consistent display.