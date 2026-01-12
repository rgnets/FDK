import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rgnets_fdk/features/devices/domain/constants/device_types.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/devices/presentation/widgets/led_control_section.dart';
import 'package:rgnets_fdk/features/devices/presentation/widgets/light_indicator_reference.dart';

/// Widget for displaying all device fields in organized sections
class DeviceDetailSections extends StatelessWidget {
  final Device device;

  const DeviceDetailSections({
    super.key,
    required this.device,
  });

  @override
  Widget build(BuildContext context) {
    final isAccessPoint = device.type == DeviceTypes.accessPoint;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildBasicInfoSection(context),
        const SizedBox(height: 16),
        _buildLocationSection(context),
        const SizedBox(height: 16),
        _buildNetworkSection(context),
        const SizedBox(height: 16),
        _buildWirelessSection(context),
        const SizedBox(height: 16),
        // LED Controls - only for Access Points
        if (isAccessPoint) ...[
          LedControlSection(deviceId: device.id),
          const SizedBox(height: 16),
          const LightIndicatorReference(),
          const SizedBox(height: 16),
        ],
        _buildPerformanceSection(context),
        const SizedBox(height: 16),
        _buildTrafficSection(context),
        const SizedBox(height: 16),
        _buildSystemSection(context),
        const SizedBox(height: 16),
        _buildHardwareSection(context),
        const SizedBox(height: 16),
        _buildNotesSection(context),
        const SizedBox(height: 16),
        _buildImagesSection(context),
        const SizedBox(height: 16),
        _buildMetadataSection(context),
      ],
    );
  }

  Widget _buildBasicInfoSection(BuildContext context) {
    return _SectionCard(
      title: 'Basic Information',
      icon: Icons.info_outline,
      children: [
        _DetailRow('ID', device.id),
        _DetailRow('Name', device.name),
        _DetailRow('Type', device.type),
        _DetailRow('Status', device.status, 
          valueColor: _getStatusColor(device.status)),
        if (device.lastSeen != null)
          _DetailRow('Last Seen', _formatDateTime(device.lastSeen!)),
      ],
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    if (device.pmsRoom == null && device.location == null) return const SizedBox.shrink();
    
    return _SectionCard(
      title: 'Location',
      icon: Icons.location_on_outlined,
      children: [
        if (device.pmsRoom != null) ...[
          _DetailRow('Room', device.pmsRoom!.displayName),
          _DetailRow('Room ID', device.pmsRoom!.id.toString()),
          if (device.pmsRoom!.extractedBuilding != null)
            _DetailRow('Building', device.pmsRoom!.extractedBuilding!),
          if (device.pmsRoom!.extractedNumber != null)
            _DetailRow('Room Number', device.pmsRoom!.extractedNumber!),
        ],
        if (device.location != null)
          _DetailRow('Location', device.location!),
        if (device.pmsRoomId != null)
          _DetailRow('PMS Room ID', device.pmsRoomId.toString()),
      ],
    );
  }

  Widget _buildNetworkSection(BuildContext context) {
    return _SectionCard(
      title: 'Network Configuration',
      icon: Icons.network_check,
      children: [
        if (device.ipAddress != null)
          _DetailRow('IP Address', device.ipAddress!),
        if (device.macAddress != null)
          _DetailRow('MAC Address', device.macAddress!),
        if (device.vlan != null)
          _DetailRow('VLAN', device.vlan.toString()),
      ],
    );
  }

  Widget _buildWirelessSection(BuildContext context) {
    if (device.ssid == null && device.channel == null && device.signalStrength == null) {
      return const SizedBox.shrink();
    }
    
    return _SectionCard(
      title: 'Wireless Configuration',
      icon: Icons.wifi,
      children: [
        if (device.ssid != null)
          _DetailRow('SSID', device.ssid!),
        if (device.channel != null)
          _DetailRow('Channel', device.channel.toString()),
        if (device.signalStrength != null)
          _DetailRow('Signal Strength', '${device.signalStrength} dBm'),
        if (device.connectedClients != null)
          _DetailRow('Connected Clients', device.connectedClients.toString()),
        if (device.maxClients != null)
          _DetailRow('Max Clients', device.maxClients.toString()),
      ],
    );
  }

  Widget _buildPerformanceSection(BuildContext context) {
    if (device.cpuUsage == null && device.memoryUsage == null && 
        device.temperature == null && device.uptime == null) {
      return const SizedBox.shrink();
    }
    
    return _SectionCard(
      title: 'Performance',
      icon: Icons.speed,
      children: [
        if (device.cpuUsage != null)
          _DetailRow('CPU Usage', '${device.cpuUsage}%'),
        if (device.memoryUsage != null)
          _DetailRow('Memory Usage', '${device.memoryUsage}%'),
        if (device.temperature != null)
          _DetailRow('Temperature', '${device.temperature}°C'),
        if (device.uptime != null)
          _DetailRow('Uptime', _formatUptime(device.uptime!)),
        if (device.latency != null)
          _DetailRow('Latency', '${device.latency} ms'),
        if (device.packetLoss != null)
          _DetailRow('Packet Loss', '${device.packetLoss}%'),
      ],
    );
  }

  Widget _buildTrafficSection(BuildContext context) {
    if (device.currentUpload == null && device.currentDownload == null &&
        device.totalUpload == null && device.totalDownload == null) {
      return const SizedBox.shrink();
    }
    
    return _SectionCard(
      title: 'Traffic Statistics',
      icon: Icons.swap_vert,
      children: [
        if (device.currentUpload != null)
          _DetailRow('Current Upload', '${device.currentUpload!.toStringAsFixed(2)} Mbps'),
        if (device.currentDownload != null)
          _DetailRow('Current Download', '${device.currentDownload!.toStringAsFixed(2)} Mbps'),
        if (device.totalUpload != null)
          _DetailRow('Total Upload', _formatBytes(device.totalUpload!)),
        if (device.totalDownload != null)
          _DetailRow('Total Download', _formatBytes(device.totalDownload!)),
      ],
    );
  }

  Widget _buildSystemSection(BuildContext context) {
    if (device.model == null && device.serialNumber == null && 
        device.firmware == null && device.restartCount == null) {
      return const SizedBox.shrink();
    }
    
    return _SectionCard(
      title: 'System Information',
      icon: Icons.computer,
      children: [
        if (device.model != null)
          _DetailRow('Model', device.model!),
        if (device.serialNumber != null)
          _DetailRow('Serial Number', device.serialNumber!),
        if (device.firmware != null)
          _DetailRow('Firmware', device.firmware!),
        if (device.restartCount != null)
          _DetailRow('Restart Count', device.restartCount.toString()),
      ],
    );
  }

  Widget _buildHardwareSection(BuildContext context) {
    // Reserved for future hardware-specific fields
    return const SizedBox.shrink();
  }

  Widget _buildNotesSection(BuildContext context) {
    if (device.note == null) return const SizedBox.shrink();
    
    return _SectionCard(
      title: 'Notes',
      icon: Icons.note,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            device.note!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildImagesSection(BuildContext context) {
    if (device.images == null || device.images!.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return _SectionCard(
      title: 'Images',
      icon: Icons.photo_library,
      children: [
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: device.images!.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 120,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 40, color: Colors.grey),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataSection(BuildContext context) {
    if (device.metadata == null || device.metadata!.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return _SectionCard(
      title: 'Additional Metadata',
      icon: Icons.data_object,
      children: device.metadata!.entries.map((entry) {
        return _DetailRow(
          _formatMetadataKey(entry.key),
          entry.value?.toString() ?? 'N/A',
        );
      }).toList(),
    );
  }

  String _formatMetadataKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty 
            ? '${word[0].toUpperCase()}${word.substring(1)}' 
            : '')
        .join(' ');
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, y h:mm a').format(dateTime);
    }
  }

  String _formatUptime(int seconds) {
    final days = seconds ~/ 86400;
    final hours = (seconds % 86400) ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    
    if (days > 0) {
      return '$days days, $hours hours';
    } else if (hours > 0) {
      return '$hours hours, $minutes minutes';
    } else {
      return '$minutes minutes';
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1073741824) return '${(bytes / 1048576).toStringAsFixed(2)} MB';
    return '${(bytes / 1073741824).toStringAsFixed(2)} GB';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'online':
        return Colors.green;
      case 'offline':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: valueColor,
                fontWeight: valueColor != null ? FontWeight.bold : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}