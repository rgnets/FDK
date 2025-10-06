# Notification Display Fix Plan

## Problem Summary
Notifications display differently between development, staging, and production:
- **Development**: Shows "Device Offline - north-towe..." (truncated with dash)
- **Staging**: Shows "Device Offline 101" or just "Device Offline" (numeric or empty)
- **Root Cause**: `device.location` contains different formats in each environment

## Root Cause Analysis

### Data Flow
1. **Device Data**:
   - Development: `device.location = "north-tower-101"` (from room.id)
   - Staging: `device.location = null` or `""` or possibly numeric

2. **Notification Generation**:
   - `NotificationGenerationService` sets `notification.roomId = device.location`
   - This propagates the inconsistent format to notifications

3. **Display Logic** (`notifications_screen.dart`):
   - If roomId > 10 chars: truncate with "..."
   - If roomId is numeric: use space separator
   - If roomId is text: use dash separator
   - If roomId is null/empty: show title only

## Recommended Solution

### Solution: Use Room Name from pmsRoomId Lookup

**Approach**: During notification generation, lookup the actual room name using `device.pmsRoomId` and store the consistent room name in the notification.

**Why This Solution**:
1. `pmsRoomId` is consistent across all environments (integer)
2. Room names provide meaningful, human-readable information
3. No performance impact during display (lookup happens once at generation)
4. Follows Clean Architecture principles
5. Ensures identical display across all environments

## Implementation Plan

### Step 1: Update NotificationGenerationService
**File**: `/lib/core/services/notification_generation_service.dart`

**Changes**:
1. Add rooms parameter to `generateFromDevices` method
2. Create helper method to lookup room name by pmsRoomId
3. Use room name instead of device.location for roomId

```dart
// Add rooms parameter
List<AppNotification> generateFromDevices(List<Device> devices, List<Room> rooms) {
  // ... existing code ...
  
  // In _generateDeviceNotifications:
  final roomName = _getRoomNameForDevice(device, rooms);
  
  // Use roomName instead of device.location:
  roomId: roomName,  // was: device.location
}

String? _getRoomNameForDevice(Device device, List<Room> rooms) {
  if (device.pmsRoomId == null) return null;
  
  final roomIdStr = device.pmsRoomId.toString();
  final room = rooms.firstWhereOrNull((r) => r.id == roomIdStr);
  return room?.name;
}
```

### Step 2: Update Provider Calls
**Files**: 
- `/lib/features/devices/presentation/providers/device_list_provider.dart`
- Any other files calling `generateFromDevices`

**Changes**:
1. Pass rooms list when calling `generateFromDevices`
2. Ensure rooms are available when generating notifications

### Step 3: Update Display Logic (Optional Enhancement)
**File**: `/lib/features/notifications/presentation/screens/notifications_screen.dart`

**Changes**:
1. Simplify `_formatNotificationTitle` since roomId will now be consistent
2. Remove numeric check and different separators
3. Use consistent formatting

```dart
String _formatNotificationTitle(AppNotification notification) {
  final baseTitle = notification.title;
  final roomId = notification.roomId;
  
  if (roomId != null && roomId.isNotEmpty) {
    // Always use dash separator for consistency
    return '$baseTitle - $roomId';
  }
  
  return baseTitle;
}
```

### Step 4: Test Implementation
1. Create test program to verify notification generation with room lookup
2. Test in development environment with mock data
3. Test in staging environment with API data
4. Verify consistent display across all environments

## Alternative Quick Fix (If Room Lookup Not Feasible)

### Quick Fix: Normalize Display Logic Only
**File**: `/lib/features/notifications/presentation/screens/notifications_screen.dart`

**Changes**:
```dart
String _formatNotificationTitle(AppNotification notification) {
  final baseTitle = notification.title;
  final roomId = notification.roomId;
  
  if (roomId != null && roomId.isNotEmpty) {
    // Extract meaningful part if possible
    String displayRoom = roomId;
    
    // If it's a long format like "north-tower-101", extract last part
    if (roomId.contains('-')) {
      final parts = roomId.split('-');
      if (parts.length >= 3) {
        // Take last part (room number) and abbreviate building
        displayRoom = '${parts[0].substring(0, 1).toUpperCase()}${parts[1].substring(0, 1).toUpperCase()}-${parts.last}';
      }
    }
    
    // Truncate if still too long
    if (displayRoom.length > 10) {
      displayRoom = '${displayRoom.substring(0, 10)}...';
    }
    
    // Always use consistent separator
    return '$baseTitle - $displayRoom';
  }
  
  return baseTitle;
}
```

## Testing Strategy

### Test Cases
1. **Development**: 
   - Input: `roomId = "north-tower-101"`
   - Expected: "Device Offline - NT-101"

2. **Staging (with room lookup)**:
   - Input: `pmsRoomId = 101`
   - Expected: "Device Offline - NT-101"

3. **Staging (null/empty)**:
   - Input: `roomId = null` or `""`
   - Expected: "Device Offline"

### Verification Steps
1. Run test programs to verify logic
2. Test in development environment
3. Deploy to staging and verify
4. Ensure production will behave identically

## Risk Assessment
- **Low Risk**: Changes are localized to notification generation and display
- **No Breaking Changes**: Existing notifications remain compatible
- **Performance Impact**: Minimal (one-time lookup during generation)

## Timeline
1. **Iteration 1** (30 min): Implement room lookup in NotificationGenerationService
2. **Iteration 2** (30 min): Update providers and test thoroughly
3. **Iteration 3** (30 min): Fine-tune display logic and verify across environments

## Questions for User
1. Do rooms from the API have consistent `name` fields like "NT-101"?
2. Is the room lookup approach acceptable, or would you prefer the quick display-only fix?
3. Should we preserve the truncation logic for long room names?