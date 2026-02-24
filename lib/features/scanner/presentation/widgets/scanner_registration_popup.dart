import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/features/devices/domain/constants/device_types.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/room.dart';
import 'package:rgnets_fdk/features/rooms/presentation/providers/room_device_view_model.dart';
import 'package:rgnets_fdk/features/rooms/presentation/providers/rooms_riverpod_provider.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/device_category.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/device_registration_state.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/scan_session.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/scanner_state.dart';
import 'package:rgnets_fdk/features/scanner/domain/services/device_classifier.dart';
import 'package:rgnets_fdk/features/scanner/presentation/providers/device_registration_provider.dart';
import 'package:rgnets_fdk/features/scanner/presentation/providers/scanner_notifier_v2.dart';
import 'package:rgnets_fdk/features/scanner/presentation/utils/scanner_utils.dart';

/// Registration popup shown when scan is complete.
///
/// Styled like ATT-FE-Tool with:
/// - Color-coded top border (green=new, orange=move, red=mismatch)
/// - Header with action icon, title, device type icon
/// - Scanned data display
/// - Room selection with search
/// - Device selection (Designed/Assigned/Create New)
/// - Move/Reset indicator
/// - Cancel and Register buttons
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
  bool _createNewDevice = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDeviceMatch();
    });
  }

  Future<void> _checkDeviceMatch() async {
    final scannerState = ref.read(scannerNotifierV2Provider);
    final scanData = scannerState.scanData;

    if (scanData.mac.isEmpty && scanData.serialNumber.isEmpty) {
      return;
    }

    setState(() => _isLoading = true);

    // Check for existing device via WebSocket query
    await ref.read(deviceRegistrationNotifierProvider.notifier).checkDeviceMatch(
          mac: scanData.mac,
          serial: scanData.serialNumber,
          deviceType: _toDeviceType(scannerState.scanMode),
        );

    if (mounted) {
      setState(() => _isLoading = false);

      // Sync the match status to scanner state
      final regState = ref.read(deviceRegistrationNotifierProvider);
      ref.read(scannerNotifierV2Provider.notifier).setDeviceMatchStatus(
            status: regState.matchStatus,
            deviceId: regState.matchedDeviceId,
            deviceName: regState.matchedDeviceName,
            deviceRoomId: regState.matchedDeviceRoomId,
            deviceRoomName: regState.matchedDeviceRoomName,
          );
    }
  }

  /// Get status color based on match status.
  Color _getStatusColor(DeviceMatchStatus status) {
    switch (status) {
      case DeviceMatchStatus.noMatch:
      case DeviceMatchStatus.unchecked:
        return Colors.green;
      case DeviceMatchStatus.fullMatch:
        return Colors.orange;
      case DeviceMatchStatus.mismatch:
      case DeviceMatchStatus.multipleMatch:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scannerState = ref.watch(scannerNotifierV2Provider);

    // Show loading view while checking device status
    if (_isLoading) {
      return _buildLoadingView(context, theme, scannerState);
    }

    // Show appropriate UI based on match status
    final scanData = scannerState.scanData;
    final statusColor = _getStatusColor(scannerState.matchStatus);
    final isExisting = scannerState.matchStatus == DeviceMatchStatus.fullMatch;
    final isMismatch = scannerState.matchStatus == DeviceMatchStatus.mismatch ||
        scannerState.matchStatus == DeviceMatchStatus.multipleMatch;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Color-coded top border (ATT-FE-Tool style)
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header row (ATT-FE-Tool style)
                  _buildHeader(context, scannerState, statusColor, isExisting, isMismatch),
                  const SizedBox(height: 8),

                  // Subtitle
                  _buildSubtitle(context, isExisting, isMismatch),
                  const SizedBox(height: 20),

                  // Scanned data summary
                  _buildDataSummary(context, scanData, scannerState.scanMode),
                  const SizedBox(height: 16),

                  // Existing device banner (if device exists)
                  if (isExisting) _buildExistingDeviceBanner(context, scannerState),

                  // Room selection
                  _buildRoomSelector(context, scannerState),
                  const SizedBox(height: 16),

                  // Move indicator (when room selected and device exists)
                  if (isExisting && scannerState.selectedRoomId != null)
                    _buildMoveIndicator(context, scannerState),

                  // Device selection (only if not mismatch)
                  if (!isMismatch && scannerState.selectedRoomId != null) ...[
                    const SizedBox(height: 16),
                    _buildDeviceSelector(context, scannerState),
                  ],

                  const SizedBox(height: 24),

                  // Action buttons
                  _buildActionButtons(context, scannerState, isMismatch),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build a simple loading view while checking device status.
  Widget _buildLoadingView(BuildContext context, ThemeData theme, ScannerState scannerState) {
    final scanData = scannerState.scanData;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Loading spinner
            const CircularProgressIndicator(),
            const SizedBox(height: 24),

            // Loading text
            Text(
              'Checking device...',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // Show what we're checking
            Text(
              scanData.serialNumber.isNotEmpty
                  ? 'Serial: ${scanData.serialNumber}'
                  : 'MAC: ${scanData.mac}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ScannerState state,
    Color statusColor,
    bool isExisting,
    bool isMismatch,
  ) {
    final theme = Theme.of(context);

    IconData actionIcon;
    String titleText;

    if (isMismatch) {
      actionIcon = Icons.error;
      titleText = 'Data Mismatch Detected';
    } else if (isExisting) {
      actionIcon = Icons.swap_horiz;
      titleText = 'Existing ${_getDeviceTypeName(state.scanMode)} Found';
    } else {
      actionIcon = Icons.add_circle_outline;
      titleText = 'New ${_getDeviceTypeName(state.scanMode)}';
    }

    return Row(
      children: [
        Icon(actionIcon, color: statusColor, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            titleText,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Icon(
          ScannerUtils.getModeIcon(state.scanMode),
          color: theme.colorScheme.onSurfaceVariant,
          size: 24,
        ),
      ],
    );
  }

  Widget _buildSubtitle(BuildContext context, bool isExisting, bool isMismatch) {
    final theme = Theme.of(context);

    String subtitle;
    if (isMismatch) {
      subtitle = 'Scanned data does not match existing device records';
    } else if (isExisting) {
      subtitle = 'This device will be moved to a new room';
    } else {
      subtitle = 'This device will be registered as new';
    }

    return Text(
      subtitle,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildDataSummary(BuildContext context, AccumulatedScanData data, ScanMode mode) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (data.mac.isNotEmpty)
            _buildDataRow(context, 'MAC Address', ScannerUtils.formatMac(data.mac)),
          if (data.serialNumber.isNotEmpty)
            _buildDataRow(context, 'Serial Number', data.serialNumber),
          if (data.partNumber.isNotEmpty)
            _buildDataRow(context, 'Part Number', data.partNumber),
          if (data.model.isNotEmpty)
            _buildDataRow(context, 'Model', data.model),
          _buildDataRow(context, 'Device Type', _getDeviceTypeName(mode)),
        ],
      ),
    );
  }

  Widget _buildDataRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
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
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExistingDeviceBanner(BuildContext context, ScannerState state) {
    final theme = Theme.of(context);
    final currentRoom = state.matchedDeviceRoomName ?? 'Unknown Room';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Device Already Registered',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.orange.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Currently in: $currentRoom',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.orange.shade700,
                  ),
                ),
                if (state.matchedDeviceName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Device: ${state.matchedDeviceName}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ],
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
        Text(
          'Select Room',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _showRoomPicker,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: state.selectedRoomId != null
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(12),
              color: state.selectedRoomId != null
                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.meeting_room_outlined,
                  color: state.selectedRoomId != null
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    state.selectedRoomNumber ?? 'Tap to select room',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: state.selectedRoomNumber != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: state.selectedRoomNumber != null
                          ? FontWeight.w500
                          : FontWeight.normal,
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
      ],
    );
  }

  Widget _buildMoveIndicator(BuildContext context, ScannerState state) {
    final theme = Theme.of(context);
    final currentRoom = state.matchedDeviceRoomName ?? 'Unknown';
    final targetRoom = state.selectedRoomNumber ?? 'Selected Room';
    final isSameRoom = state.matchedDeviceRoomId == state.selectedRoomId;

    Color backgroundColor;
    Color foregroundColor;
    IconData icon;
    String message;

    if (isSameRoom) {
      backgroundColor = Colors.red.shade50;
      foregroundColor = Colors.red.shade700;
      icon = Icons.refresh;
      message = 'Will RESET device in this room';
    } else {
      backgroundColor = Colors.orange.shade50;
      foregroundColor = Colors.orange.shade700;
      icon = Icons.swap_horiz;
      message = 'Will move from "$currentRoom" → "$targetRoom"';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: foregroundColor.withValues(alpha: 0.3)),
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
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceSelector(BuildContext context, ScannerState state) {
    final theme = Theme.of(context);
    final roomId = state.selectedRoomId?.toString() ?? '';
    final deviceState = ref.watch(roomDeviceNotifierProvider(roomId));
    final deviceTypeFilter = _getDeviceTypeForMode(state.scanMode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Designed ${_getDeviceTypeName(state.scanMode)} or Create New',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
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

    // Filter by type
    final filteredDevices = deviceTypeFilter != null
        ? allDevices.where((d) => d.type == deviceTypeFilter).toList()
        : allDevices;

    // Categorize
    final categorized = DeviceClassifier.categorizeDevices(filteredDevices);
    final designedDevices = categorized[DeviceCategory.designed] ?? [];
    final assignedDevices = categorized[DeviceCategory.assigned] ?? [];

    // Build items
    final items = <DropdownMenuItem<String>>[];

    // Create New option (always first, green)
    items.add(
      DropdownMenuItem(
        value: 'create_new',
        child: Row(
          children: [
            const Icon(Icons.add_circle_outline, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Create New ${_getDeviceTypeName(scanMode)}',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Designed devices (blue)
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
                Icon(ScannerUtils.getModeIcon(scanMode), color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    device.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    // Assigned devices (purple)
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
                Icon(ScannerUtils.getModeIcon(scanMode), color: Colors.purple, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(device.name, overflow: TextOverflow.ellipsis, maxLines: 1),
                      Text(
                        'MAC: ${ScannerUtils.formatMac(device.macAddress ?? '')}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
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

    // Current value
    String currentValue = 'create_new';
    if (!_createNewDevice && _selectedDevice != null) {
      final category = DeviceClassifier.isDesignedDevice(_selectedDevice!) ? 'designed' : 'assigned';
      currentValue = '${category}_${_selectedDevice!.id}';
    }

    // Build a combined list for selectedItemBuilder lookups
    // This prevents vertical overflow when a two-line item (assigned device) is selected
    final combinedDevices = [...designedDevices, ...assignedDevices];

    return DropdownButtonFormField<String>(
      value: currentValue,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      isExpanded: true,
      items: items,
      // Use selectedItemBuilder to provide single-line display for selected value
      // This prevents vertical overflow when assigned devices (which have 2-line layout
      // in dropdown menu) are selected
      selectedItemBuilder: (context) {
        return items.map((item) {
          final value = item.value;
          if (value == null) {
            // Separator/header items - return empty container (won't be selected)
            return const SizedBox.shrink();
          } else if (value == 'create_new') {
            return Row(
              children: [
                const Icon(Icons.add_circle_outline, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Create New ${_getDeviceTypeName(scanMode)}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          } else if (value.startsWith('designed_')) {
            final deviceId = value.substring('designed_'.length);
            final device = combinedDevices.where((d) => d.id == deviceId).firstOrNull;
            return Row(
              children: [
                Icon(ScannerUtils.getModeIcon(scanMode), color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    device?.name ?? 'Unknown Device',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            );
          } else if (value.startsWith('assigned_')) {
            final deviceId = value.substring('assigned_'.length);
            final device = combinedDevices.where((d) => d.id == deviceId).firstOrNull;
            // Single-line display for assigned devices to prevent overflow
            return Row(
              children: [
                Icon(ScannerUtils.getModeIcon(scanMode), color: Colors.purple, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    device?.name ?? 'Unknown Device',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        }).toList();
      },
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          if (value == 'create_new') {
            _createNewDevice = true;
            _selectedDevice = null;
          } else {
            _createNewDevice = false;
            final parts = value.split('_');
            if (parts.length >= 2) {
              final deviceId = parts.sublist(1).join('_');
              final found = filteredDevices.where((d) => d.id == deviceId);
              _selectedDevice = found.isNotEmpty ? found.first : null;
              if (_selectedDevice == null) {
                _createNewDevice = true;
              }
            }
          }
        });
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, ScannerState state, bool isMismatch) {
    final isExisting = state.matchStatus == DeviceMatchStatus.fullMatch;
    final isSameRoom = isExisting && state.matchedDeviceRoomId == state.selectedRoomId;
    final canRegister = state.selectedRoomId != null && !isMismatch;

    // Determine button text and color
    String buttonText;
    Color? buttonColor;

    if (isMismatch) {
      buttonText = 'Cannot Register';
    } else if (isExisting) {
      if (isSameRoom) {
        buttonText = 'Reset Device';
        buttonColor = Colors.red;
      } else if (state.selectedRoomId != null) {
        buttonText = 'Move Device';
        buttonColor = Colors.orange;
      } else {
        buttonText = 'Select Room First';
      }
    } else if (_createNewDevice) {
      buttonText = 'Create New';
      buttonColor = Colors.green;
    } else if (_selectedDevice != null && DeviceClassifier.isDesignedDevice(_selectedDevice!)) {
      buttonText = 'Assign to Designed';
      buttonColor = Colors.blue;
    } else if (_selectedDevice != null) {
      buttonText = 'Replace Existing';
      buttonColor = Colors.orange;
    } else {
      buttonText = 'Register';
      buttonColor = Colors.green;
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _handleCancel,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: FilledButton(
            onPressed: canRegister ? _handleRegister : null,
            style: buttonColor != null
                ? FilledButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  )
                : FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
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
        final roomId = selectedRoom.id;
        final displayName = selectedRoom.number ?? selectedRoom.shortName;
        ref.read(scannerNotifierV2Provider.notifier).setRoomSelection(
              roomId,
              displayName,
            );
      }
    });
  }

  void _handleCancel() {
    ref.read(scannerNotifierV2Provider.notifier).hideRegistrationPopup();
    ref.read(scannerNotifierV2Provider.notifier).clearScanData();
    Navigator.pop(context, false);
    widget.onCancel?.call();
  }

  Future<void> _handleRegister() async {
    final scannerState = ref.read(scannerNotifierV2Provider);

    if (scannerState.selectedRoomId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a room before registering'),
          ),
        );
      }
      return;
    }

    ref.read(scannerNotifierV2Provider.notifier).setRegistrationInProgress(true);

    final isExisting = scannerState.matchStatus == DeviceMatchStatus.fullMatch;
    final isSameRoom = isExisting && scannerState.matchedDeviceRoomId == scannerState.selectedRoomId;

    int? existingDeviceId;
    if (isExisting) {
      existingDeviceId = scannerState.matchedDeviceId;
    } else if (!_createNewDevice && _selectedDevice != null) {
      existingDeviceId = int.tryParse(_selectedDevice!.id);
    }

    try {
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
        ref.read(scannerNotifierV2Provider.notifier).setRegistrationInProgress(false);
        ref.read(scannerNotifierV2Provider.notifier).hideRegistrationPopup();

        if (result.isSuccess) {
          String actionText;
          Color snackBarColor;

          if (isSameRoom) {
            actionText = 'Device reset';
            snackBarColor = Colors.red;
          } else if (isExisting) {
            actionText = 'Device moved';
            snackBarColor = Colors.orange;
          } else if (_createNewDevice) {
            actionText = 'Device created';
            snackBarColor = Colors.green;
          } else if (_selectedDevice != null && DeviceClassifier.isDesignedDevice(_selectedDevice!)) {
            actionText = 'Device assigned';
            snackBarColor = Colors.blue;
          } else {
            actionText = 'Device replaced';
            snackBarColor = Colors.orange;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$actionText successfully!'),
              backgroundColor: snackBarColor,
            ),
          );

          Navigator.pop(context, true);
          widget.onRegister?.call();
        } else {
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
        ref.read(scannerNotifierV2Provider.notifier).setRegistrationInProgress(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getDeviceTypeName(ScanMode mode) {
    switch (mode) {
      case ScanMode.accessPoint:
        return 'Access Point';
      case ScanMode.ont:
        return 'ONT';
      case ScanMode.switchDevice:
        return 'Switch';
      case ScanMode.auto:
      case ScanMode.rxg:
        return 'Device';
    }
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
        return null;
    }
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
        return DeviceType.accessPoint;
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

/// Room picker bottom sheet with search.
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
      final number = room.number?.toLowerCase() ?? '';
      final location = room.location?.toLowerCase() ?? '';
      return name.contains(query) || number.contains(query) || location.contains(query);
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
          // Handle
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
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Search
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                    Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                    const SizedBox(height: 16),
                    Text('Failed to load rooms', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.invalidate(roomsNotifierProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (rooms) {
                final filtered = _filterRooms(rooms);
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.meeting_room_outlined, size: 48, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty ? 'No rooms available' : 'No rooms match "$_searchQuery"',
                          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final room = filtered[index];
                    return _RoomListTile(room: room, onTap: () => widget.onRoomSelected(room));
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
          child: Icon(Icons.meeting_room, color: theme.colorScheme.onPrimaryContainer),
        ),
        title: Text(
          room.number ?? room.name,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (room.number != null && room.name != room.number)
              Text(room.name, overflow: TextOverflow.ellipsis),
            if (room.location != null)
              Text(
                room.location!,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
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
                  style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSecondaryContainer),
                ),
              ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
