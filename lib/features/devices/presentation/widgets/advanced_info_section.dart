import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';

/// An expandable section that shows advanced/technical device information.
/// Collapsed by default, can be expanded to show detailed data.
class AdvancedInfoSection extends StatelessWidget {
  const AdvancedInfoSection({
    required this.device,
    super.key,
  });

  final Device device;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ExpansionTile(
        leading: Icon(
          Icons.code,
          color: Colors.grey[600],
        ),
        title: Text(
          'Advanced Information',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Tap to view technical details',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[500],
            fontStyle: FontStyle.italic,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 8),
                _buildAdvancedFields(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedFields(BuildContext context) {
    final fields = <MapEntry<String, String>>[];

    // Core identifiers
    fields.add(MapEntry('Device ID', device.id));

    // Model and hardware info
    if (device.model != null) {
      fields.add(MapEntry('Model', device.model!));
    }
    if (device.serialNumber != null) {
      fields.add(MapEntry('Serial Number', device.serialNumber!));
    }
    if (device.firmware != null) {
      fields.add(MapEntry('Firmware Version', device.firmware!));
    }

    // Network info
    if (device.macAddress != null) {
      fields.add(MapEntry('MAC Address', device.macAddress!));
      final manufacturer = _lookupMacManufacturer(device.macAddress!);
      if (manufacturer != null) {
        fields.add(MapEntry('MAC Manufacturer', manufacturer));
      }
    }
    if (device.ipAddress != null) {
      fields.add(MapEntry('IP Address', device.ipAddress!));
    }
    if (device.vlan != null) {
      fields.add(MapEntry('VLAN', device.vlan.toString()));
    }

    // Room info
    if (device.pmsRoom != null) {
      fields.add(MapEntry('PMS Room ID', device.pmsRoom!.id.toString()));
      fields.add(MapEntry('PMS Room Name', device.pmsRoom!.displayName));
      if (device.pmsRoom!.extractedBuilding != null) {
        fields.add(
          MapEntry('Building', device.pmsRoom!.extractedBuilding!),
        );
      }
      if (device.pmsRoom!.extractedNumber != null) {
        fields.add(
          MapEntry('Room Number', device.pmsRoom!.extractedNumber!),
        );
      }
    } else if (device.pmsRoomId != null) {
      fields.add(MapEntry('PMS Room ID', device.pmsRoomId.toString()));
    }

    // Performance stats
    if (device.uptime != null) {
      fields.add(MapEntry('Uptime (seconds)', device.uptime.toString()));
    }
    if (device.restartCount != null) {
      fields.add(MapEntry('Restart Count', device.restartCount.toString()));
    }

    // Metadata
    if (device.metadata != null && device.metadata!.isNotEmpty) {
      for (final entry in device.metadata!.entries) {
        final value = entry.value?.toString() ?? 'null';
        fields.add(MapEntry(_formatKey(entry.key), value));
      }
    }

    if (fields.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No additional information available',
            style: TextStyle(
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: fields.map((entry) {
        return _AdvancedInfoRow(
          label: entry.key,
          value: entry.value,
        );
      }).toList(),
    );
  }

  String _formatKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) =>
              word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '',
        )
        .join(' ');
  }

  /// Simple MAC manufacturer lookup based on OUI prefix.
  /// In a real app, this would use a proper OUI database.
  String? _lookupMacManufacturer(String mac) {
    final normalizedMac =
        mac.replaceAll(RegExp(r'[:\-\.]'), '').toUpperCase();
    if (normalizedMac.length < 6) return null;

    final oui = normalizedMac.substring(0, 6);

    // Common OUI prefixes (subset)
    const ouiMap = <String, String>{
      'D8C497': 'Ubiquiti Networks',
      '802AA8': 'Ubiquiti Networks',
      'F09FC2': 'Ubiquiti Networks',
      '24A43C': 'Ubiquiti Networks',
      '788A20': 'Ubiquiti Networks',
      'B4FBE4': 'Ubiquiti Networks',
      'AC8BA9': 'Ubiquiti Networks',
      'E063DA': 'Ubiquiti Networks',
      'FC15B4': 'Hewlett-Packard',
      '001C23': 'Dell',
      '00215A': 'Hewlett-Packard',
      '00237D': 'Hewlett-Packard',
      '001DD8': 'Microsoft',
      '001E68': 'Quanta',
      '001A6B': 'Universal Global',
      '000C29': 'VMware',
      '005056': 'VMware',
      '001C14': 'VMware',
      '000347': 'Intel',
      '001517': 'Intel',
      '001921': 'Elitegroup',
      'E0D55E': 'Liteon',
      'F8A963': 'Compal',
      '00D861': 'Micro-Star',
      '001E37': 'Aruba Networks',
      '00248C': 'Aruba Networks',
      '203A07': 'Aruba Networks',
      '701A04': 'Aruba Networks',
      '00155D': 'Microsoft Hyper-V',
      '000D3A': 'Microsoft',
    };

    return ouiMap[oui];
  }
}

/// A row displaying a label-value pair in monospace font with selectable text.
class _AdvancedInfoRow extends StatelessWidget {
  const _AdvancedInfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$label copied'),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: SelectableText(
                value,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
