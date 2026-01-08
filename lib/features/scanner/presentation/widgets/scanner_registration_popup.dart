import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/features/devices/domain/constants/device_types.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/rooms/domain/entities/room.dart';
import 'package:rgnets_fdk/features/rooms/presentation/providers/room_device_view_model.dart';
import 'package:rgnets_fdk/features/rooms/presentation/providers/rooms_riverpod_provider.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/device_registration_state.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/scan_session.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/scanner_state.dart';
import 'package:rgnets_fdk/features/scanner/presentation/providers/device_registration_provider.dart';
import 'package:rgnets_fdk/features/scanner/presentation/providers/scanner_notifier.dart';

/// Registration popup shown when scan is complete.
///
/// Displays scanned data, device match status, room picker, and action buttons.
class ScannerRegistrationPopup extends ConsumerStatefulWidget {
  const ScannerRegistrationPopup({
    super.key,
    this.onRegister,
    this.onCancel,
  });

  final VoidCallback? onRegister;
  final VoidCallback? onCancel;

  /// Show the registration popup as a modal bottom sheet.
  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ScannerRegistrationPopup(),
    );
  }

  @override
  ConsumerState<ScannerRegistrationPopup> createState() =>
      _ScannerRegistrationPopupState();
}

class _ScannerRegistrationPopupState
    extends ConsumerState<ScannerRegistrationPopup> {
  bool _isLoading = false;
  Device? _selectedDevice;
  bool _createNewDevice = true; // Default to create new

  @override
  void initState() {
    super.initState();
    // Notify scanner that popup is showing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(scannerNotifierProvider.notifier).showRegistrationPopup();
      _checkDeviceMatch();
    });
  }

  Future<void> _checkDeviceMatch() async {
    final scannerState = ref.read(scannerNotifierProvider);
    final scanData = scannerState.scanData;

    if (scanData.mac.isEmpty || scanData.serialNumber.isEmpty) {
      return;
    }

    setState(() => _isLoading = true);

    // Check for existing device
    await ref.read(deviceRegistrationNotifierProvider.notifier).checkDeviceMatch(
          mac: scanData.mac,
          serial: scanData.serialNumber,
          deviceType: _toDeviceType(scannerState.scanMode),
        );

    if (mounted) {
      setState(() => _isLoading = false);

      // Update scanner with match status
      final regState = ref.read(deviceRegistrationNotifierProvider);
      ref.read(scannerNotifierProvider.notifier).setDeviceMatchStatus(
            status: regState.matchStatus,
            deviceId: regState.matchedDeviceId,
            deviceName: regState.matchedDeviceName,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scannerState = ref.watch(scannerNotifierProvider);
    final scanData = scannerState.scanData;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Register Device',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Device type badge
              _buildDeviceTypeBadge(context, scannerState.scanMode),
              const SizedBox(height: 20),

              // Scanned data summary
              _buildDataSummary(context, scanData),
              const SizedBox(height: 16),

              // Match status
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                _buildMatchStatus(context, scannerState.matchStatus),
              const SizedBox(height: 20),

              // Room selection
              _buildRoomSelector(context, scannerState),
              const SizedBox(height: 24),

              // Action buttons
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceTypeBadge(BuildContext context, ScanMode mode) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getModeIcon(mode),
              size: 16,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 6),
            Text(
              mode.displayName,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSummary(BuildContext context, AccumulatedScanData data) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (data.mac.isNotEmpty)
            _buildDataRow(context, 'MAC Address', _formatMac(data.mac)),
          if (data.serialNumber.isNotEmpty)
            _buildDataRow(context, 'Serial Number', data.serialNumber),
          if (data.partNumber.isNotEmpty)
            _buildDataRow(context, 'Part Number', data.partNumber),
          if (data.model.isNotEmpty)
            _buildDataRow(context, 'Model', data.model),
        ],
      ),
    );
  }

  Widget _buildDataRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchStatus(BuildContext context, DeviceMatchStatus status) {
    final theme = Theme.of(context);

    Color backgroundColor;
    Color foregroundColor;
    IconData icon;
    String message;

    switch (status) {
      case DeviceMatchStatus.noMatch:
        backgroundColor = Colors.green.shade50;
        foregroundColor = Colors.green.shade700;
        icon = Icons.add_circle_outline;
        message = 'New device - ready to register';
      case DeviceMatchStatus.fullMatch:
        backgroundColor = Colors.blue.shade50;
        foregroundColor = Colors.blue.shade700;
        icon = Icons.check_circle_outline;
        message = 'Device already registered';
      case DeviceMatchStatus.mismatch:
        backgroundColor = Colors.orange.shade50;
        foregroundColor = Colors.orange.shade700;
        icon = Icons.warning_amber_outlined;
        message = 'Device found with different data';
      case DeviceMatchStatus.multipleMatch:
        backgroundColor = Colors.red.shade50;
        foregroundColor = Colors.red.shade700;
        icon = Icons.error_outline;
        message = 'Multiple devices match - please verify';
      case DeviceMatchStatus.unchecked:
        backgroundColor = theme.colorScheme.surfaceContainerHighest;
        foregroundColor = theme.colorScheme.onSurfaceVariant;
        icon = Icons.help_outline;
        message = 'Checking device status...';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: foregroundColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomSelector(BuildContext context, ScannerState state) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Room Selection
        Text(
          'Select Room',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _showRoomPicker,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.meeting_room_outlined,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    state.selectedRoomNumber ?? 'Tap to select room',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: state.selectedRoomNumber != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),

        // Device Selection (shown after room is selected)
        if (state.selectedRoomId != null) ...[
          const SizedBox(height: 16),
          _buildDeviceSelector(context, state),
        ],
      ],
    );
  }

  Widget _buildDeviceSelector(BuildContext context, ScannerState state) {
    final theme = Theme.of(context);
    final roomId = state.selectedRoomId?.toString() ?? '';
    final deviceState = ref.watch(roomDeviceNotifierProvider(roomId));

    // Get the device type to filter based on scan mode
    final deviceTypeFilter = _getDeviceTypeForMode(state.scanMode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select ${_getDeviceTypeName(state.scanMode)} or Create New',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        if (deviceState.isLoading)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text(
                  'Loading devices...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          )
        else if (deviceState.error != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.error),
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: theme.colorScheme.error),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Failed to load devices',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          _buildDeviceDropdown(
            context,
            deviceState.allDevices,
            deviceTypeFilter,
            state.scanMode,
          ),
      ],
    );
  }

  Widget _buildDeviceDropdown(
    BuildContext context,
    List<Device> allDevices,
    String? deviceTypeFilter,
    ScanMode scanMode,
  ) {
    final theme = Theme.of(context);

    // Filter devices by type
    final filteredDevices = deviceTypeFilter != null
        ? allDevices.where((d) => d.type == deviceTypeFilter).toList()
        : allDevices;

    // Categorize devices
    final designedDevices = filteredDevices.where(_isDesignedDevice).toList();
    final assignedDevices = filteredDevices.where(_isAssignedDevice).toList();

    // Build dropdown items
    final items = <DropdownMenuItem<String>>[];

    // Create New option (always first)
    items.add(
      DropdownMenuItem(
        value: 'create_new',
        child: Row(
          children: [
            Icon(Icons.add_circle_outline, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Text(
              'Create New ${_getDeviceTypeName(scanMode)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );

    // Designed devices (placeholders waiting to be assigned)
    if (designedDevices.isNotEmpty) {
      items.add(
        DropdownMenuItem(
          enabled: false,
          value: null,
          child: Text(
            '── DESIGNED (${designedDevices.length}) ──',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.blue.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
      for (final device in designedDevices) {
        items.add(
          DropdownMenuItem(
            value: 'designed_${device.id}',
            child: Row(
              children: [
                Icon(_getDeviceIcon(scanMode), color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    device.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    // Assigned devices (can be replaced)
    if (assignedDevices.isNotEmpty) {
      items.add(
        DropdownMenuItem(
          enabled: false,
          value: null,
          child: Text(
            '── ASSIGNED (${assignedDevices.length}) ──',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.purple.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
      for (final device in assignedDevices) {
        items.add(
          DropdownMenuItem(
            value: 'assigned_${device.id}',
            child: Row(
              children: [
                Icon(_getDeviceIcon(scanMode), color: Colors.purple, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        device.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'MAC: ${_formatMac(device.macAddress ?? '')}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    // Current selection value
    String currentValue = 'create_new';
    if (!_createNewDevice && _selectedDevice != null) {
      final category = _isDesignedDevice(_selectedDevice!) ? 'designed' : 'assigned';
      currentValue = '${category}_${_selectedDevice!.id}';
    }

    return DropdownButtonFormField<String>(
      value: currentValue,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      isExpanded: true,
      items: items,
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          if (value == 'create_new') {
            _createNewDevice = true;
            _selectedDevice = null;
          } else {
            _createNewDevice = false;
            // Extract device ID from value (format: "category_id")
            final parts = value.split('_');
            if (parts.length >= 2) {
              final deviceId = parts.sublist(1).join('_');
              _selectedDevice = filteredDevices.firstWhere(
                (d) => d.id == deviceId,
                orElse: () => filteredDevices.first,
              );
            }
          }
        });
      },
    );
  }

  /// Check if device is "designed" (placeholder - has name but missing MAC or Serial)
  bool _isDesignedDevice(Device device) {
    final hasName = device.name.isNotEmpty;
    final hasMac = device.macAddress?.isNotEmpty ?? false;
    final hasSerial = device.serialNumber?.isNotEmpty ?? false;
    // Designed = has name but missing MAC or Serial
    return hasName && (!hasMac || !hasSerial);
  }

  /// Check if device is "assigned" (has both MAC and Serial)
  bool _isAssignedDevice(Device device) {
    final hasName = device.name.isNotEmpty;
    final hasMac = device.macAddress?.isNotEmpty ?? false;
    final hasSerial = device.serialNumber?.isNotEmpty ?? false;
    // Assigned = has name AND both MAC and Serial
    return hasName && hasMac && hasSerial;
  }

  String? _getDeviceTypeForMode(ScanMode mode) {
    switch (mode) {
      case ScanMode.accessPoint:
        return DeviceTypes.accessPoint;
      case ScanMode.ont:
        return DeviceTypes.ont;
      case ScanMode.switchDevice:
        return DeviceTypes.networkSwitch;
      case ScanMode.auto:
      case ScanMode.rxg:
        return null; // Show all types
    }
  }

  String _getDeviceTypeName(ScanMode mode) {
    switch (mode) {
      case ScanMode.accessPoint:
        return 'AP';
      case ScanMode.ont:
        return 'ONT';
      case ScanMode.switchDevice:
        return 'Switch';
      case ScanMode.auto:
      case ScanMode.rxg:
        return 'Device';
    }
  }

  IconData _getDeviceIcon(ScanMode mode) {
    switch (mode) {
      case ScanMode.accessPoint:
        return Icons.wifi;
      case ScanMode.ont:
        return Icons.router;
      case ScanMode.switchDevice:
        return Icons.lan;
      case ScanMode.auto:
      case ScanMode.rxg:
        return Icons.devices;
    }
  }

  Widget _buildActionButtons(BuildContext context) {
    final scannerState = ref.watch(scannerNotifierProvider);
    final canRegister = scannerState.selectedRoomId != null &&
        scannerState.matchStatus != DeviceMatchStatus.multipleMatch;

    // Determine button text based on selection
    String buttonText;
    Color? buttonColor;
    if (scannerState.matchStatus == DeviceMatchStatus.fullMatch) {
      buttonText = 'View Device';
    } else if (_createNewDevice) {
      buttonText = 'Create New';
      buttonColor = Colors.green;
    } else if (_selectedDevice != null && _isDesignedDevice(_selectedDevice!)) {
      buttonText = 'Assign';
      buttonColor = Colors.blue;
    } else if (_selectedDevice != null && _isAssignedDevice(_selectedDevice!)) {
      buttonText = 'Replace';
      buttonColor = Colors.orange;
    } else {
      buttonText = 'Register';
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _handleCancel,
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: FilledButton(
            onPressed: canRegister ? _handleRegister : null,
            style: buttonColor != null
                ? FilledButton.styleFrom(backgroundColor: buttonColor)
                : null,
            child: Text(buttonText),
          ),
        ),
      ],
    );
  }

  void _showRoomPicker() {
    showModalBottomSheet<Room>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RoomPickerSheet(
        onRoomSelected: (room) {
          Navigator.pop(context, room);
        },
      ),
    ).then((selectedRoom) {
      if (selectedRoom != null) {
        // Use room.id as int if possible, otherwise use hashCode
        final roomId = int.tryParse(selectedRoom.id) ?? selectedRoom.id.hashCode;
        final displayName = selectedRoom.roomNumber ?? selectedRoom.name;
        ref.read(scannerNotifierProvider.notifier).setRoomSelection(
              roomId,
              displayName,
            );
      }
    });
  }

  void _handleCancel() {
    ref.read(scannerNotifierProvider.notifier).hideRegistrationPopup();
    ref.read(scannerNotifierProvider.notifier).clearScanData();
    Navigator.pop(context, false);
    widget.onCancel?.call();
  }

  Future<void> _handleRegister() async {
    final scannerState = ref.read(scannerNotifierProvider);

    ref.read(scannerNotifierProvider.notifier).setRegistrationInProgress(true);

    // Get existing device ID if assigning/replacing
    int? existingDeviceId;
    if (!_createNewDevice && _selectedDevice != null) {
      existingDeviceId = int.tryParse(_selectedDevice!.id);
    }

    try {
      // Register device via WebSocket
      final result = await ref
          .read(deviceRegistrationNotifierProvider.notifier)
          .registerDevice(
            mac: scannerState.scanData.mac,
            serial: scannerState.scanData.serialNumber,
            deviceType: _toDeviceType(scannerState.scanMode),
            pmsRoomId: scannerState.selectedRoomId!,
            partNumber: scannerState.scanData.partNumber.isNotEmpty
                ? scannerState.scanData.partNumber
                : null,
            existingDeviceId: existingDeviceId,
          );

      if (mounted) {
        ref
            .read(scannerNotifierProvider.notifier)
            .setRegistrationInProgress(false);
        ref.read(scannerNotifierProvider.notifier).hideRegistrationPopup();

        if (result.isSuccess) {
          // Show success message with action taken
          final actionText = _createNewDevice
              ? 'Device created'
              : (_selectedDevice != null && _isDesignedDevice(_selectedDevice!)
                  ? 'Device assigned'
                  : 'Device replaced');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$actionText successfully'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to device details
          Navigator.pop(context, true);
          widget.onRegister?.call();

          // TODO(scanner): Navigate to device details page
          // context.push('/devices/${result.deviceId}');
        } else {
          // Show error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Registration failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        ref
            .read(scannerNotifierProvider.notifier)
            .setRegistrationInProgress(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IconData _getModeIcon(ScanMode mode) {
    switch (mode) {
      case ScanMode.accessPoint:
        return Icons.wifi;
      case ScanMode.ont:
        return Icons.router;
      case ScanMode.switchDevice:
        return Icons.lan;
      case ScanMode.rxg:
        return Icons.qr_code;
      case ScanMode.auto:
        return Icons.auto_awesome;
    }
  }

  String _formatMac(String mac) {
    if (mac.length != 12) {
      return mac;
    }
    return '${mac.substring(0, 2)}:${mac.substring(2, 4)}:'
        '${mac.substring(4, 6)}:${mac.substring(6, 8)}:'
        '${mac.substring(8, 10)}:${mac.substring(10, 12)}';
  }

  DeviceType _toDeviceType(ScanMode mode) {
    switch (mode) {
      case ScanMode.accessPoint:
        return DeviceType.accessPoint;
      case ScanMode.ont:
        return DeviceType.ont;
      case ScanMode.switchDevice:
        return DeviceType.switchDevice;
      case ScanMode.auto:
      case ScanMode.rxg:
        return DeviceType.accessPoint; // Default fallback
    }
  }

}

extension on RegistrationResult {
  bool get isSuccess => this is RegistrationSuccess;
  String? get message {
    final result = this;
    if (result is RegistrationFailure) {
      return result.message;
    }
    return null;
  }
}

/// Room picker bottom sheet with search functionality.
class _RoomPickerSheet extends ConsumerStatefulWidget {
  const _RoomPickerSheet({required this.onRoomSelected});

  final void Function(Room room) onRoomSelected;

  @override
  ConsumerState<_RoomPickerSheet> createState() => _RoomPickerSheetState();
}

class _RoomPickerSheetState extends ConsumerState<_RoomPickerSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Room> _filterRooms(List<Room> rooms) {
    if (_searchQuery.isEmpty) return rooms;
    final query = _searchQuery.toLowerCase();
    return rooms.where((room) {
      final name = room.name.toLowerCase();
      final number = room.roomNumber?.toLowerCase() ?? '';
      final location = room.location?.toLowerCase() ?? '';
      return name.contains(query) ||
          number.contains(query) ||
          location.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roomsAsync = ref.watch(roomsNotifierProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Select Room',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search rooms...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          const SizedBox(height: 8),

          // Room list
          Expanded(
            child: roomsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load rooms',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.invalidate(roomsNotifierProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (rooms) {
                final filteredRooms = _filterRooms(rooms);

                if (filteredRooms.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.meeting_room_outlined,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No rooms available'
                              : 'No rooms match "$_searchQuery"',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filteredRooms.length,
                  itemBuilder: (context, index) {
                    final room = filteredRooms[index];
                    return _RoomListTile(
                      room: room,
                      onTap: () => widget.onRoomSelected(room),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomListTile extends StatelessWidget {
  const _RoomListTile({required this.room, required this.onTap});

  final Room room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceCount = room.deviceIds?.length ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.meeting_room,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          room.roomNumber ?? room.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (room.roomNumber != null && room.name != room.roomNumber)
              Text(room.name),
            if (room.location != null)
              Text(
                room.location!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (deviceCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$deviceCount device${deviceCount == 1 ? '' : 's'}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
