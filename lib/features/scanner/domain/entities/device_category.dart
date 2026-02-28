/// Category classification for devices in the unassigned device workflow.
///
/// Used to determine how devices should be displayed in the device selector
/// and what operations are valid for them.
enum DeviceCategory {
  /// Placeholder device - has a name but missing MAC or Serial Number.
  /// These are "designed" in the system but not yet physically deployed.
  /// Can be assigned scanned data.
  designed,

  /// Fully configured device - has name, MAC, and Serial Number.
  /// Can be replaced with new scanned data if needed.
  assigned,

  /// Auto-discovered device - name matches MAC address or Serial Number.
  /// These should be hidden from selection as they're temporary records.
  ephemeral,

  /// Invalid device - missing required name field.
  /// Should be excluded from selection.
  invalid,
}

/// Extension methods for DeviceCategory.
extension DeviceCategoryX on DeviceCategory {
  /// Returns true if this category represents a selectable device.
  bool get isSelectable => this == DeviceCategory.designed || this == DeviceCategory.assigned;

  /// Returns true if this device is a placeholder waiting for assignment.
  bool get isPlaceholder => this == DeviceCategory.designed;

  /// Returns a human-readable label for UI display.
  String get displayLabel => switch (this) {
    DeviceCategory.designed => 'Designed',
    DeviceCategory.assigned => 'Assigned',
    DeviceCategory.ephemeral => 'Ephemeral',
    DeviceCategory.invalid => 'Invalid',
  };
}
