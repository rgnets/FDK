# Room Readiness Logic - RG Nets FDK

**Created**: 2025-08-18
**Status**: 🔴 **PLANNED FEATURE - NOT IMPLEMENTED**
**Purpose**: Documentation for future room readiness feature

## ⚠️ IMPORTANT: This Feature Does Not Exist

**Current Status**: 
- UI screens may exist but have no functionality
- No backend implementation
- No device-to-room associations in API
- PMS rooms endpoint exists but lacks readiness data

## Proposed Core Logic (Not Implemented)

A room's readiness would be determined by the **online status** of all associated network devices.

## Readiness States

### 1. Fully Ready ✅
- **Condition**: ALL devices (APs, ONTs, Switches) are online
- **Display**: Green indicator, "Ready" status
- **Meaning**: Room is fully operational for service

### 2. Partially Ready ⚠️
- **Condition**: SOME devices are online, but not all
- **Display**: Yellow/amber indicator, "Partial" status
- **Meaning**: Room has connectivity but may have degraded service
- **Details**: Show which device types are online/offline

### 3. Not Ready ❌
- **Condition**: NO devices are online (or no devices assigned)
- **Display**: Red indicator, "Not Ready" status
- **Meaning**: Room has no network connectivity

## Proposed Implementation (Future Development)

### Data Model (NOT IMPLEMENTED)
```dart
enum RoomReadiness {
  ready,        // All devices online
  partial,      // Some devices online
  notReady,     // No devices online
  unknown,      // No devices assigned
}

class RoomStatus {
  final String roomId;
  final String roomName;
  final RoomReadiness readiness;
  final DeviceStatusBreakdown breakdown;
  final DateTime lastChecked;
  
  bool get isFullyReady => readiness == RoomReadiness.ready;
  bool get isPartiallyReady => readiness == RoomReadiness.partial;
  bool get hasIssues => readiness != RoomReadiness.ready;
}

class DeviceStatusBreakdown {
  final int totalAPs;
  final int onlineAPs;
  final int totalONTs;
  final int onlineONTs;
  final int totalSwitches;
  final int onlineSwitches;
  
  bool get allAPsOnline => totalAPs > 0 && totalAPs == onlineAPs;
  bool get allONTsOnline => totalONTs > 0 && totalONTs == onlineONTs;
  bool get allSwitchesOnline => totalSwitches > 0 && totalSwitches == onlineSwitches;
  
  bool get allDevicesOnline => allAPsOnline && allONTsOnline && allSwitchesOnline;
  bool get someDevicesOnline => onlineAPs > 0 || onlineONTs > 0 || onlineSwitches > 0;
  
  double get readinessPercentage {
    final total = totalAPs + totalONTs + totalSwitches;
    if (total == 0) return 0;
    final online = onlineAPs + onlineONTs + onlineSwitches;
    return (online / total) * 100;
  }
}
```

### Proposed Calculation Logic (NOT IMPLEMENTED)
```dart
// THIS CODE DOES NOT EXIST IN THE APPLICATION
RoomReadiness calculateRoomReadiness(DeviceStatusBreakdown breakdown) {
  // No devices assigned
  if (breakdown.totalAPs == 0 && 
      breakdown.totalONTs == 0 && 
      breakdown.totalSwitches == 0) {
    return RoomReadiness.unknown;
  }
  
  // All devices online
  if (breakdown.allDevicesOnline) {
    return RoomReadiness.ready;
  }
  
  // Some devices online
  if (breakdown.someDevicesOnline) {
    return RoomReadiness.partial;
  }
  
  // No devices online
  return RoomReadiness.notReady;
}
```

## Proposed UI (MAY HAVE EMPTY SCREENS)

### Room List View (Not Functional)
```
┌─────────────────────────────────────────┐
│ Room 803                           ✅   │
│ APs: 2/2 ✓  ONTs: 1/1 ✓  SW: 1/1 ✓    │
├─────────────────────────────────────────┤
│ Room 804                           ⚠️   │
│ APs: 1/2 ⚠  ONTs: 1/1 ✓  SW: 0/1 ✗    │
├─────────────────────────────────────────┤
│ Room 805                           ❌   │
│ APs: 0/2 ✗  ONTs: 0/1 ✗  SW: 0/1 ✗    │
└─────────────────────────────────────────┘
```

### Room Detail View
Show detailed device status:
- Device name/ID
- Online/offline status
- Last seen timestamp
- IP address (if online)
- Signal strength (for APs)

### Readiness Percentage
For partial readiness, show percentage:
- "Room 804: 50% Ready (2 of 4 devices online)"

## Implementation Requirements (Not Built)

### Would Need
- Poll device status every 30 seconds
- Update room readiness immediately when status changes
- Show "last updated" timestamp

### WebSocket Option
- If API supports WebSocket, use for real-time updates
- Fall back to polling if WebSocket unavailable

## Filtering and Sorting

### Filter Options
- Show all rooms
- Show only ready rooms
- Show only partial rooms
- Show only not ready rooms
- Show rooms with issues (partial + not ready)

### Sort Options
- By room number/name
- By readiness status (ready first)
- By readiness percentage
- By last updated time

## Notifications

### Alert Conditions
- Room transitions from ready to partial/not ready
- Room stays not ready for >15 minutes
- Device goes offline unexpectedly

### Alert Types
- In-app notification
- Push notification (if enabled)
- Status bar indicator

## Business Value

### Benefits of Partial Readiness
1. **Better visibility**: Field engineers can see progress
2. **Prioritization**: Focus on rooms closest to ready
3. **Troubleshooting**: Identify specific problem devices
4. **Partial service**: Some connectivity better than none

### Use Cases
- **Installation**: Track progress as devices come online
- **Maintenance**: Quickly identify problem rooms
- **Troubleshooting**: See which specific devices are offline

## API Reality Check

### Available Endpoints
- `GET /api/pms_rooms.json` - ✅ EXISTS (141 rooms)
- `GET /api/access_points.json` - ✅ EXISTS (221 APs)
- `GET /api/media_converters.json` - ✅ EXISTS (151 ONTs)
- `GET /api/switch_devices.json` - ✅ EXISTS (1 switch)

### Missing Functionality
- No room-to-device associations in API responses
- No readiness calculations
- No room status fields
- PMS rooms have no device counts

### Why It's Not Implemented
1. PMS rooms don't include device associations
2. Devices don't reference room IDs
3. No API endpoint for room-device mapping
4. Would require backend changes to implement
5. Client can't correlate data without associations

## Caching Strategy

### Cache Rules
- Cache room/device associations for 5 minutes
- Cache device status for 30 seconds
- Invalidate cache on manual refresh
- Store last known state for offline viewing

## To Implement This Feature

### Backend Requirements
1. Room with all devices online → Ready
2. Room with some devices online → Partial
3. Room with no devices online → Not Ready
4. Room with no devices assigned → Unknown
5. Device goes offline → Room changes to Partial
6. Last device goes offline → Room changes to Not Ready
7. Device comes back online → Recalculate readiness

## Current Workarounds

### What Users Can Do Now
1. **Predictive readiness**: Based on installation patterns
2. **Historical tracking**: Room readiness over time
3. **Readiness trends**: Identify problematic rooms
4. **Batch operations**: Mark multiple rooms ready
5. **Custom thresholds**: Different readiness rules per building

## Implementation Status Summary

- **Feature Status**: 🔴 NOT IMPLEMENTED
- **UI Status**: May have placeholder screens
- **Backend Status**: No supporting API functionality
- **Data Model**: Not defined
- **Business Logic**: Documented but not coded
- **Priority**: Unknown (appears to be planned feature)

## References
- API Discovery: Shows PMS rooms exist but lack device associations
- Current Implementation: Feature does not exist in codebase