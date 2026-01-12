import 'package:flutter/material.dart';
import 'package:rgnets_fdk/features/devices/domain/constants/device_types.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';

/// A summary card that displays device overview information at the top of the
/// device detail view. Matches the ATT-FE-Tool's unified summary card layout.
class UnifiedSummaryCard extends StatelessWidget {
  const UnifiedSummaryCard({
    required this.device,
    super.key,
  });

  final Device device;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOnline = device.status.toLowerCase() == 'online';
    final statusColor = isOnline ? Colors.green : Colors.red;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Device Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getDeviceIcon(device.type),
                size: 32,
                color: statusColor,
              ),
            ),
            const SizedBox(width: 16),

            // Device Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Device Name
                  Text(
                    device.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Device Type Label
                  Text(
                    _getDeviceTypeLabel(device.type),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Status Column
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Online/Offline Status Badge
                _StatusBadge(
                  isOnline: isOnline,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDeviceIcon(String type) {
    // Handle different type formats
    final normalizedType = type.toLowerCase();

    if (normalizedType == DeviceTypes.accessPoint ||
        normalizedType == 'ap' ||
        normalizedType.contains('access')) {
      return Icons.wifi;
    } else if (normalizedType == DeviceTypes.networkSwitch ||
        normalizedType.contains('switch')) {
      return Icons.hub;
    } else if (normalizedType == DeviceTypes.ont ||
        normalizedType.contains('ont') ||
        normalizedType.contains('media_converter')) {
      return Icons.settings_input_hdmi;
    } else if (normalizedType == DeviceTypes.wlanController ||
        normalizedType.contains('wlan')) {
      return Icons.router;
    }
    return Icons.device_hub;
  }

  String _getDeviceTypeLabel(String type) {
    final normalizedType = type.toLowerCase();

    if (normalizedType == DeviceTypes.accessPoint ||
        normalizedType == 'ap' ||
        normalizedType.contains('access')) {
      return 'Access Point';
    } else if (normalizedType == DeviceTypes.networkSwitch ||
        normalizedType.contains('switch')) {
      return 'Network Switch';
    } else if (normalizedType == DeviceTypes.ont ||
        normalizedType.contains('ont') ||
        normalizedType.contains('media_converter')) {
      return 'ONT / Media Converter';
    } else if (normalizedType == DeviceTypes.wlanController ||
        normalizedType.contains('wlan')) {
      return 'WLAN Controller';
    }
    return type;
  }
}

/// Status badge showing online/offline status with icon and text.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.isOnline,
  });

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final color = isOnline ? Colors.green : Colors.red;
    final text = isOnline ? 'Online' : 'Offline';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
