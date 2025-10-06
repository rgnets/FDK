# Fix for Missing IP and MAC in List View

## Problem
The device list view was showing "No IP" and "No MAC" for all devices in staging environment.

## Root Cause
`DeviceFieldSets.listFields` was requesting fields that don't exist in the API:
- Requested: `ip_address` and `mac_address`
- API actually uses different field names per device type

## API Field Names (Per Device Type)

### Access Points (`/api/access_points`)
- **IP field**: `ip`
- **MAC field**: `mac`

### Switches (`/api/switch_devices`)
- **IP field**: `host` 
- **MAC field**: `scratch` (MAC is stored in the scratch field)

### Media Converters/ONTs (`/api/media_converters`)
- **IP field**: None (ONTs don't have IP addresses)
- **MAC field**: `mac`

### WLAN Controllers (`/api/wlan_devices`)
- **IP field**: `host`
- **MAC field**: `mac`

## Solution
Changed `DeviceFieldSets.listFields` to request the correct field names:
```dart
// OLD (incorrect)
'ip_address',
'mac_address',

// NEW (correct)
'ip',        // Access points use 'ip'
'host',      // Switches/WLAN use 'host'
'mac',       // Access points/ONTs use 'mac'
'scratch',   // Switches store MAC in 'scratch'
```

## Data Flow
1. API returns the correct fields (`ip`, `host`, `mac`, `scratch`)
2. Remote data source already correctly maps them:
   - Access Points: `ip` → `ipAddress`, `mac` → `macAddress`
   - Switches: `host` → `ipAddress`, `scratch` → `macAddress`
   - ONTs: `mac` → `macAddress`
3. Entity has the correct fields (`ipAddress`, `macAddress`)
4. UI displays them correctly

## Verification
- 206 of 220 access points have both IP and MAC
- 14 access points have MAC only (offline devices)
- 1 switch has both IP and MAC
- 149 of 151 ONTs have MAC (2 without)
- All data now displays correctly in the UI

## Architecture Compliance
✅ **MVVM**: No changes to ViewModels
✅ **Clean Architecture**: Only constants changed
✅ **Type Safety**: All fields remain strongly typed
✅ **Single Responsibility**: Each layer maintains its role
✅ **Performance**: Field selection still works (98% size reduction)