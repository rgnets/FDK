import 'package:flutter/material.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';

/// Header card widget for device detail screen
class DeviceHeaderCard extends StatelessWidget {
  const DeviceHeaderCard({
    required this.device,
    super.key,
  });
  
  final Device device;
  
  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(device.status);
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Device icon with status indicator
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    _getDeviceIcon(device.type),
                    size: 32,
                    color: statusColor,
                  ),
                  // Status indicator
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            
            // Device info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    device.type,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          device.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                      if (device.firmware != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          'FW: ${device.firmware}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            // Signal strength indicator
            if (device.signalStrength != null)
              Column(
                children: [
                  Icon(
                    _getSignalIcon(device.signalStrength!),
                    size: 32,
                    color: _getSignalColor(device.signalStrength!),
                  ),
                  Text(
                    '${device.signalStrength} dBm',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'online':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'error':
      case 'offline':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  IconData _getDeviceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'access_point':
      case 'access point':
        return Icons.wifi;
      case 'switch':
        return Icons.hub;
      case 'ont':
        return Icons.fiber_manual_record;
      case 'gateway':
        return Icons.router;
      case 'router':
        return Icons.router_outlined;
      case 'firewall':
        return Icons.security;
      case 'server':
        return Icons.dns;
      case 'wlan_controller':
        return Icons.wifi_tethering;
      default:
        return Icons.device_unknown;
    }
  }
  
  IconData _getSignalIcon(int strength) {
    if (strength >= -50) {
      return Icons.signal_wifi_4_bar;
    } else if (strength >= -60) {
      return Icons.network_wifi_3_bar;
    } else if (strength >= -70) {
      return Icons.network_wifi_2_bar;
    } else if (strength >= -80) {
      return Icons.network_wifi_1_bar;
    } else {
      return Icons.signal_wifi_0_bar;
    }
  }
  
  Color _getSignalColor(int strength) {
    if (strength >= -50) {
      return Colors.green;
    } else if (strength >= -70) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}