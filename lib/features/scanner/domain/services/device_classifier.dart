import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/scanner/data/utils/mac_normalizer.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/device_category.dart';

/// Classifies devices for the unassigned device workflow.
///
/// This service determines how devices should be categorized and displayed
/// in the device selector during the registration flow.
///
/// Based on ATT-FE-Tool's UnassignedDeviceHandler implementation.
///
/// Categories:
/// - **Designed**: Placeholder devices with a name but missing MAC or Serial.
/// - **Assigned**: Fully configured devices with name, MAC, and Serial.
/// - **Ephemeral**: Auto-discovered devices (name matches MAC or Serial).
/// - **Invalid**: Devices missing required name field.
class DeviceClassifier {
  DeviceClassifier._();

  /// Check if a value should be considered a placeholder.
  ///
  /// Returns true for:
  /// - null
  /// - empty string
  /// - whitespace only
  /// - "null" (case insensitive)
  /// - "placeholder" (case insensitive)
  static bool isPlaceholderValue(String? value) {
    if (value == null) return true;

    final trimmed = value.trim();
    if (trimmed.isEmpty) return true;

    final lower = trimmed.toLowerCase();
    return lower == 'null' || lower == 'placeholder';
  }

  /// Check if a device has an ephemeral name (auto-discovered).
  ///
  /// A device is ephemeral if its name matches its MAC address or serial number,
  /// indicating it was auto-discovered and hasn't been given a proper name.
  static bool isEphemeralName(Device device) {
    final name = device.name.trim();
    if (name.isEmpty) return false;

    // Check if name matches MAC address
    final mac = device.macAddress;
    if (mac != null && mac.isNotEmpty) {
      try {
        final normalizedMac = MACNormalizer.tryNormalize(mac);
        final normalizedName = MACNormalizer.tryNormalize(name);
        if (normalizedMac != null && normalizedName != null && normalizedMac == normalizedName) {
          return true;
        }
      } catch (_) {
        // If normalization fails, do a simple comparison
        final macClean = mac.toUpperCase().replaceAll(RegExp(r'[^0-9A-F]'), '');
        final nameClean = name.toUpperCase().replaceAll(RegExp(r'[^0-9A-F]'), '');
        if (macClean.isNotEmpty && macClean == nameClean) {
          return true;
        }
      }
    }

    // Check if name matches serial number
    final serial = device.serialNumber;
    if (serial != null && serial.isNotEmpty) {
      if (name.toLowerCase().trim() == serial.toLowerCase().trim()) {
        return true;
      }
    }

    return false;
  }

  /// Check if a device is "designed" (placeholder waiting for assignment).
  ///
  /// A designed device has a proper name but is missing MAC or Serial Number.
  /// These are placeholders in the system that haven't been physically deployed yet.
  static bool isDesignedDevice(Device device) {
    // Must have a name
    if (device.name.trim().isEmpty) return false;

    // Must not be ephemeral
    if (isEphemeralName(device)) return false;

    // Check if MAC is missing or placeholder
    final macMissing = isPlaceholderValue(device.macAddress);

    // Check if Serial is missing or placeholder
    final serialMissing = isPlaceholderValue(device.serialNumber);

    // Designed if missing MAC OR Serial (or both)
    return macMissing || serialMissing;
  }

  /// Check if a device is fully assigned (has all required fields).
  ///
  /// A fully assigned device has a name, MAC address, and serial number.
  /// These devices can be replaced with new scanned data if needed.
  static bool isFullyAssignedDevice(Device device) {
    // Must have a name
    if (device.name.trim().isEmpty) return false;

    // Must not be ephemeral
    if (isEphemeralName(device)) return false;

    // Must have both MAC and Serial (non-placeholder values)
    final hasMAC = !isPlaceholderValue(device.macAddress);
    final hasSerial = !isPlaceholderValue(device.serialNumber);

    return hasMAC && hasSerial;
  }

  /// Classify a device into a category.
  ///
  /// Returns the appropriate [DeviceCategory] based on the device's fields.
  static DeviceCategory classifyDevice(Device device) {
    // Check for invalid (no name)
    if (device.name.trim().isEmpty) {
      return DeviceCategory.invalid;
    }

    // Check for ephemeral (auto-discovered)
    if (isEphemeralName(device)) {
      return DeviceCategory.ephemeral;
    }

    // Check for designed (placeholder)
    if (isDesignedDevice(device)) {
      return DeviceCategory.designed;
    }

    // Check for fully assigned
    if (isFullyAssignedDevice(device)) {
      return DeviceCategory.assigned;
    }

    // Fallback to invalid (shouldn't happen with proper data)
    return DeviceCategory.invalid;
  }

  /// Filter a list of devices to only include selectable ones.
  ///
  /// Returns only devices that are either "designed" or "assigned",
  /// excluding ephemeral and invalid devices.
  static List<Device> filterSelectableDevices(List<Device> devices) {
    return devices.where((device) {
      final category = classifyDevice(device);
      return category.isSelectable;
    }).toList();
  }

  /// Categorize a list of devices into groups by category.
  ///
  /// Returns a map where keys are [DeviceCategory] values and values are
  /// lists of devices in that category.
  static Map<DeviceCategory, List<Device>> categorizeDevices(List<Device> devices) {
    final result = <DeviceCategory, List<Device>>{};

    for (final device in devices) {
      final category = classifyDevice(device);
      result.putIfAbsent(category, () => []).add(device);
    }

    return result;
  }
}
