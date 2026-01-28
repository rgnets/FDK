import 'package:flutter/foundation.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/device_category.dart';
import 'package:rgnets_fdk/features/scanner/domain/services/device_classifier.dart';

/// Handles the unassigned device workflow for the scanner.
///
/// This service provides utilities for:
/// - Identifying truly unassigned devices (both MAC and Serial absent)
/// - Filtering and categorizing devices for registration flows
/// - Managing the selection between existing devices and creating new ones
///
/// Based on ATT-FE-Tool's UnassignedDeviceHandler implementation.
class UnassignedDeviceHandler {
  UnassignedDeviceHandler._();

  /// Determine if a device record should be considered "unassigned".
  ///
  /// A device is unassigned only if BOTH MAC and Serial Number are absent
  /// or placeholders. Placeholders include:
  /// - null
  /// - empty string
  /// - whitespace only
  /// - "null" (case-insensitive)
  /// - "placeholder" (case-insensitive)
  ///
  /// This is distinct from "designed" devices which have a name but are
  /// missing only one of MAC or Serial. Unassigned devices are true
  /// placeholders with neither identifier.
  @visibleForTesting
  static bool isUnassignedRecord(Device device) {
    final macAbsent = DeviceClassifier.isPlaceholderValue(device.macAddress);
    final serialAbsent = DeviceClassifier.isPlaceholderValue(device.serialNumber);

    return macAbsent && serialAbsent;
  }

  /// Filter a list of devices to only include unassigned records.
  ///
  /// Unassigned records are devices where BOTH MAC and Serial Number are
  /// absent or placeholders. These are pure placeholder records that need
  /// both identifiers populated.
  static List<Device> filterUnassignedRecords(List<Device> devices) {
    return devices.where(isUnassignedRecord).toList();
  }

  /// Get registration candidates (Designed + Assigned) from a device list.
  ///
  /// Returns devices that can be selected during registration, excluding:
  /// - Ephemeral devices (auto-discovered, name matches MAC/Serial)
  /// - Invalid devices (missing name)
  /// - Unassigned records (both MAC and Serial absent) - optionally
  ///
  /// Results are sorted with Designed devices first, then Assigned devices,
  /// each group sorted alphabetically by name.
  static List<Device> getRegistrationCandidates(List<Device> devices) {
    // Get selectable devices (designed + assigned)
    final selectable = DeviceClassifier.filterSelectableDevices(devices);

    // Sort into designed and assigned lists
    final designed = selectable
        .where((d) => DeviceClassifier.isDesignedDevice(d))
        .toList()
      ..sort(_compareByName);

    final assigned = selectable
        .where((d) => DeviceClassifier.isFullyAssignedDevice(d))
        .toList()
      ..sort(_compareByName);

    // Return designed first, then assigned
    return [...designed, ...assigned];
  }

  /// Categorize devices for selection UI.
  ///
  /// Returns a map with only selectable categories (designed and assigned),
  /// excluding ephemeral and invalid categories. Each category's devices
  /// are sorted alphabetically by name.
  static Map<DeviceCategory, List<Device>> categorizeForSelection(
    List<Device> devices,
  ) {
    final result = <DeviceCategory, List<Device>>{};

    for (final device in devices) {
      final category = DeviceClassifier.classifyDevice(device);

      // Only include selectable categories
      if (category.isSelectable) {
        result.putIfAbsent(category, () => []).add(device);
      }
    }

    // Sort each category by name
    for (final list in result.values) {
      list.sort(_compareByName);
    }

    return result;
  }

  /// Compare devices by name for sorting (case-insensitive).
  static int _compareByName(Device a, Device b) {
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }
}

/// Result of user action in unassigned device selector.
///
/// Used to communicate the user's choice when selecting a device:
/// - [addNew] - User chose to create a new device record
/// - [useDevice] - User selected an existing device to update
class UnassignedDeviceAction {
  final bool addAsNew;
  final Device? selectedDevice;

  UnassignedDeviceAction._({
    required this.addAsNew,
    this.selectedDevice,
  });

  /// Create an action indicating the user wants to add a new device.
  factory UnassignedDeviceAction.addNew() {
    return UnassignedDeviceAction._(addAsNew: true);
  }

  /// Create an action indicating the user selected an existing device.
  factory UnassignedDeviceAction.useDevice(Device device) {
    return UnassignedDeviceAction._(
      addAsNew: false,
      selectedDevice: device,
    );
  }
}
