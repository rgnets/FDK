# Staging API Room Display Issue - Diagnosis Summary

## Executive Summary

**Problem**: Staging shows "Room 128" instead of "(Interurban) 803"

**Root Cause**: The staging API returns a `room` field, but our simplified parser only checks for a `name` field that doesn't exist.

## Critical Discovery

### What Staging API Actually Returns:
```json
{
  "id": 128,
  "room": "803",  // <-- Field is "room", not "name"!
  "pms_property": {
    "id": 1,
    "name": "Interurban"
  },
  ...
}
```

### What Our Parser Expects:
```dart
// Current (WRONG) - checks for "name" field
name: (roomData['name'] ?? 'Room ${roomData['id']}').toString()
```

Since `roomData['name']` is null (field doesn't exist), it always falls back to `"Room 128"`.

## Why This Happened

1. **Original parser** checked multiple fields:
   ```dart
   name: (roomData['room'] ?? roomData['name'] ?? roomData['room_number'] ?? 'Room ${id}').toString()
   ```
   This would have worked because it checks `room` first!

2. **Simplified parser** only checks `name`:
   ```dart
   name: (roomData['name'] ?? 'Room ${roomData['id']}').toString()
   ```
   This fails because staging API doesn't have a `name` field!

3. **Mock data** uses wrong structure:
   ```json
   {"id": 1000, "name": "(North Tower) 101"}  // Has "name" field
   ```
   Should match real API:
   ```json
   {"id": 1000, "room": "101", "pms_property": {"name": "North Tower"}}
   ```

## API Response Analysis

- **Total rooms in staging**: 141
- **Rooms with null `name` field**: 141 (100%)
- **Rooms with `room` field**: 141 (100%)
- **Conclusion**: ALL rooms have the data, just in a different field!

## Recommended Fix

Update the parser to:
1. Check the `room` field (which exists in real API)
2. Build the display format from `pms_property.name` + `room`
3. Update mock to match real API structure

```dart
// Proposed fix
final roomNumber = roomData['room']?.toString() ?? roomData['name']?.toString();
final propertyName = roomData['pms_property']?['name']?.toString();
final displayName = propertyName != null && roomNumber != null
    ? '($propertyName) $roomNumber'  // "(Interurban) 803"
    : roomNumber ?? 'Room ${roomData['id']}';
```

## Testing Performed

1. **Direct API test with pagination**: Confirmed `room` field exists
2. **Direct API test with `page_size=0`**: Returns List, all have `room` field
3. **Single room fetch**: Confirmed structure matches
4. **Field analysis**: 100% of rooms have `room` field, 0% have `name` field

## Conclusion

This is NOT a data quality issue. The staging API is returning correct data. Our parser was simplified incorrectly to only check for a `name` field that doesn't exist in the real API. The fix is straightforward: check the `room` field instead.