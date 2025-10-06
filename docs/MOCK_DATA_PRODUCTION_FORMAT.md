# Mock Data Production Format Implementation

## Overview
This document describes the implementation of production-like device naming format in the mock data service to ensure consistency between development and production environments.

## Production Format Specification

### Format Structure
```
[DeviceType][Building]-[Floor]-[Serial]-[Model]-[RoomDesignation]
```

### Components
- **DeviceType**: Device type prefix (AP, ONT, SW)
- **Building**: Single digit building number (1-5)
- **Floor**: Floor number extracted from room number
- **Serial**: 4-digit padded device ID (last 4 digits if ID > 9999)
- **Model**: Short model code extracted from device model
- **RoomDesignation**: 
  - Regular rooms: `RM[room_number]` (e.g., RM205)
  - MDF rooms: `MDF[building]` (e.g., MDF1 for Building 1's Main Distribution Frame)
  - IDF rooms: `IDF[floor]` (e.g., IDF2 for floor 2's Intermediate Distribution Frame)

### Examples
```
# Regular Rooms
AP1-2-0030-AP520-RM205     # Access Point in Building 1, Floor 2, Room 205
ONT1-2-1001-ONT200-RM205   # ONT in Building 1, Floor 2, Room 205
SW1-2-0001-SW8P-RM205      # Switch in Building 1, Floor 2, Room 205

# Special Rooms (Switches only)
SW1-1-0001-SW900-MDF1      # Core switch in Building 1 MDF room
SW1-1-0002-SW480-MDF1      # Distribution switch in Building 1 MDF room
SW2-1-0433-SW900-MDF2      # Core switch in Building 2 MDF room
SW3-1-0864-SW900-MDF3      # Core switch in Building 3 MDF room
SW1-2-0043-SW240-IDF2      # IDF switch in Building 1, Floor 2
SW2-3-0123-SW240-IDF3      # IDF switch in Building 2, Floor 3
```

## Building Mapping

| Building Name | Building Number |
|--------------|----------------|
| North Tower  | 1              |
| South Tower  | 2              |
| East Wing    | 3              |
| West Wing    | 4              |
| Central Hub  | 5              |

## Model Code Mapping

### Access Points
| Full Model Name | Model Code |
|----------------|------------|
| RG-AP-520      | AP520      |
| RG-AP-320      | AP320      |

### ONTs
| Full Model Name | Model Code |
|----------------|------------|
| RG-ONT-200     | ONT200     |
| RG-ONT-100     | ONT100     |

### Switches
| Full Model Name    | Model Code |
|-------------------|------------|
| RG-CORE-9000      | SW900      |
| RG-DIST-4800      | SW480      |
| RG-IDF-2400       | SW240      |
| RG-SW-8P          | SW8P       |
| RG-SW-24P         | SW24P      |

## Implementation Details

### File Modified
`lib/core/services/mock_data_service.dart`

### Key Methods

#### `_getBuildingNumber(String location)`
Maps building names from location strings to single-digit numbers.

```dart
String _getBuildingNumber(String location) {
  if (location.contains('North Tower')) return '1';
  if (location.contains('South Tower')) return '2';
  if (location.contains('East Wing')) return '3';
  if (location.contains('West Wing')) return '4';
  if (location.contains('Central Hub')) return '5';
  return '0'; // Fallback for unknown buildings
}
```

#### `_getModelCode(String model)`
Extracts short model codes from full model names.

```dart
String _getModelCode(String model) {
  // Access Points
  if (model.contains('AP-520')) return 'AP520';
  if (model.contains('AP-320')) return 'AP320';
  // ONTs
  if (model.contains('ONT-200')) return 'ONT200';
  if (model.contains('ONT-100')) return 'ONT100';
  // Switches
  if (model.contains('CORE-9000')) return 'SW900';
  if (model.contains('DIST-4800')) return 'SW480';
  if (model.contains('IDF-2400')) return 'SW240';
  if (model.contains('SW-8P')) return 'SW8P';
  if (model.contains('SW-24P')) return 'SW24P';
  return 'SW'; // Fallback
}
```

### Device Creation Methods

All device creation methods (`_createAccessPoint`, `_createONT`, `_createSwitch`) now follow the same pattern:

1. Extract building number from location
2. Parse room number to get floor
3. Generate 4-digit serial from device ID
4. Get model code from device model
5. Format name based on device and room type:
   - Access Points & ONTs: Always use `RM[Room]` format
   - Switches: Use appropriate room designation:
     - Core/Distribution switches: `MDF[building]` (e.g., MDF1, MDF2)
     - IDF switches: `IDF[floor]` (e.g., IDF2, IDF3)
     - Regular room switches: `RM[Room]` (e.g., RM205)

#### Special Room Logic for Switches

```dart
// Determine room suffix based on switch type
String roomSuffix;
if (switchType == 'core') {
  roomSuffix = 'MDF$buildingNum';  // MDF with building number
} else if (switchType == 'distribution') {
  roomSuffix = 'MDF$buildingNum';  // Also in MDF with building number
} else if (switchType == 'idf') {
  roomSuffix = 'IDF$floor';  // IDF with floor number
} else {
  roomSuffix = 'RM$roomNumber';  // Regular room format
}
```

## Architectural Compliance

### Clean Architecture ✓
- Changes isolated to data layer (`mock_data_service.dart`)
- No modifications to domain entities or presentation layer
- Data flows correctly through layers

### MVVM Pattern ✓
- No view model changes required
- Mock data service remains a pure data source
- No UI logic in data layer

### Dependency Injection ✓
- MockDataService injection unchanged
- Provider graph unmodified
- All dependencies properly injected

### Riverpod State Management ✓
- No provider modifications needed
- State management flow unchanged
- AsyncValue patterns maintained

### Single Responsibility ✓
- Each method has one clear purpose
- `_getBuildingNumber()`: Maps buildings to numbers
- `_getModelCode()`: Extracts model codes
- Device creation methods: Generate devices with proper naming

## Benefits

1. **Consistency**: Development environment now matches production format exactly
2. **Realism**: Device names look like actual production devices
3. **Testing**: More accurate testing of UI layout with realistic name lengths
4. **Debugging**: Easier to identify devices by their structured names
5. **Documentation**: Clear format makes it easy to understand device information

## Name Length Analysis

| Device Type | Average Length | Min Length | Max Length | Production Example |
|------------|---------------|------------|------------|-------------------|
| AP         | ~23 chars     | 22 chars   | 26 chars   | 22 chars          |
| ONT        | ~24 chars     | 24 chars   | 28 chars   | 23 chars          |
| Switch     | ~22 chars     | 21 chars   | 24 chars   | 22 chars          |

## Migration Notes

This change affects only mock data generation in development mode. No migration is needed as:
- Device IDs remain unchanged (e.g., `ap-1`, `ont-1`, `switch-1`)
- Navigation and routing unaffected
- Only the display name changes

## Special Room Distribution

In a typical deployment:
- **MDF Rooms**: 1 per building (5 total, numbered MDF1-MDF5)
  - MDF1: North Tower (Building 1)
  - MDF2: South Tower (Building 2)
  - MDF3: East Wing (Building 3)
  - MDF4: West Wing (Building 4)
  - MDF5: Central Hub (Building 5)
  - Each contains core switches and distribution switches
  - Located on floor 1, room 1 of each building
- **IDF Rooms**: 1 per floor above ground (39 total across all buildings)
  - Numbered by floor (IDF2, IDF3, IDF4, etc.)
  - Contains floor switches for that floor
  - Located in room 1 of each floor (except floor 1 which has MDF)
- **Regular Rooms**: Majority of rooms (636 total)
  - May contain small room switches (8-port or 24-port)
  - Use standard RM format (e.g., RM205)

## Testing

Test programs created to verify implementation:
- `test_programs/analyze_production_format.dart` - Format analysis
- `test_programs/test_production_format_implementation.dart` - Implementation test
- `test_programs/verify_production_format.dart` - Verification test
- `test_programs/test_switch_format.dart` - Switch format test
- `test_programs/test_special_room_switches.dart` - MDF/IDF format test
- `test_programs/test_mdf_numbering.dart` - MDF building numbering test
- `test_programs/final_compliance_check.dart` - Architecture compliance

All tests pass with zero errors, confirming correct implementation.