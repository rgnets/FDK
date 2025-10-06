# Data Entry Analysis - Current ATT FE Tool

**Created**: 2025-08-17
**Purpose**: Document all actual data entry points in the current application

## Summary

The current app has **VERY LIMITED data entry capabilities**. Most data comes from:
1. **Barcode scanning** (automatic, no manual entry)
2. **API responses** (read-only data)
3. **Room selection** (dropdown, not text entry)

## Actual Data Entry Points Found

### 1. Search Fields (Filter Only - NO Data Creation)

#### Devices View Search
- **Location**: `/lib/views/devices_view.dart:40`
- **Type**: TextField for filtering
- **Purpose**: Filter existing devices by name
- **Creates Data**: NO - only filters existing list
```dart
TextField(
  controller: _searchController,
  decoration: InputDecoration(hintText: 'Search by device name'),
)
```

#### Room Readiness Search
- **Location**: `/lib/views/room_readiness_view.dart:122`
- **Type**: TextField for filtering
- **Purpose**: Filter rooms by name
- **Creates Data**: NO - only filters existing list

### 2. Room Selection (During Registration)

#### Room Dropdown
- **Location**: `/lib/views/barcode_scanner.dart:1004`
- **Type**: DropdownSearch<int>
- **Purpose**: Select PMS room for device registration
- **Creates Data**: INDIRECT - Associates device with room
- **Input Method**: Dropdown selection, not text entry
```dart
DropdownSearch<int>(
  selectedItem: _pmsRoomId,
  items: roomEntries.map((e) => e.key).toList(),
)
```

### 3. Notes Field (Registration Screen - NOT USED)

#### Registration Notes
- **Location**: `/lib/features/scanner/presentation/screens/registration_screen.dart:317`
- **Type**: TextField with 3 lines
- **Purpose**: Add notes during registration
- **Creates Data**: YES - Would add notes to device
- **Status**: **NOT CONNECTED TO API** - This field exists in UI but is not wired up
```dart
TextField(
  controller: _notesController,
  maxLines: 3,
  decoration: InputDecoration(
    hintText: 'Add any additional information...',
  ),
)
```

### 4. Image Upload (Selection Only)

#### Device Images
- **Location**: `/lib/views/device_detail_view.dart:318-343`
- **Type**: ImagePicker (camera/gallery selection)
- **Purpose**: Add photos to devices
- **Creates Data**: YES - Uploads images to device
- **Input Method**: Camera/gallery selection, not manual entry
```dart
final ImagePicker picker = ImagePicker();
final XFile? image = await picker.pickImage(source: source);
// Converts to base64 and uploads
```

## Data MODIFICATION Capabilities

### 1. Clear Device Notes
- **Location**: Multiple views (notifications, device detail)
- **API**: `RxgApiClient.clearNoteOnDevice()`
- **Action**: REMOVES notes (sets to empty string)
- **Not Found**: No way to ADD or EDIT notes

### 2. Delete Device (Swipe to Delete)
- **Location**: `/lib/views/devices_view.dart`
- **API**: `RxgApiClient.deleteDevice()`
- **Action**: REMOVES device entirely
- **Note**: New app should NOT have this feature per requirements

## What's MISSING - No Manual Data Entry For:

### Cannot Manually Enter:
1. **Device Serial Numbers** - Scanner only
2. **Device MAC Addresses** - Scanner only  
3. **Device Names** - Cannot edit
4. **Device Notes** - Can only clear, not add/edit
5. **Room Names** - Read-only from PMS
6. **Device IP Addresses** - Read-only from API
7. **Part Numbers** - Scanner only
8. **Device Models** - Scanner only

### Cannot Create:
1. **New Rooms** - PMS rooms are read-only
2. **New Device Types** - Fixed to AP, ONT, Switch
3. **Custom Fields** - No custom data support

### Cannot Edit:
1. **Device Information** - All fields read-only except images
2. **Room Information** - All PMS data read-only
3. **Device Associations** - Cannot move devices between rooms after registration

## Registration Data Flow

When registering a device, the ONLY manual inputs are:
1. **Room Selection** (dropdown) - Required
2. **Notes** (text field) - NOT WIRED UP/UNUSED

Everything else comes from barcode scanning:
- Serial Number (from barcode)
- MAC Address (from barcode)
- Part Number (from barcode for ONT)
- Model (auto-detected or from barcode)

## API Write Operations Found

### Working Write Operations:
1. `RxgApiClient.registerAP()` - Register new AP
2. `RxgApiClient.registerONT()` - Register new ONT
3. `RxgApiClient.registerSwitch()` - STUBBED OUT
4. `RxgApiClient.setImagesForDevice()` - Upload images
5. `RxgApiClient.clearNoteOnDevice()` - Clear notes
6. `RxgApiClient.deleteDevice()` - Delete device

### Missing Write Operations:
1. Update device name
2. Add/edit device notes
3. Move device to different room
4. Update device details
5. Create/edit rooms

## Implications for New App

The current app is **primarily a read-only viewer** with limited write capabilities:
- **Main Input**: Barcode scanning (automatic)
- **Manual Input**: Room selection only
- **Modifications**: Clear notes, add images
- **No Editing**: Cannot edit any device information

This suggests the new app should maintain this simplicity:
1. Keep data entry minimal
2. Focus on barcode scanning for input
3. Room selection during registration
4. Image upload capability
5. Possibly add note editing (currently missing)

## Critical Finding

**The app is designed to PREVENT manual data entry errors** by:
- Using barcode scanning for all device data
- Using dropdowns for room selection
- Preventing manual editing of device information
- Keeping all critical data read-only

This design philosophy should be maintained in the new app for data integrity.