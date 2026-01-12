import 'package:flutter/material.dart';

/// Data class for AP light indicator information
class LightIndicatorInfo {
  const LightIndicatorInfo({
    required this.pattern,
    required this.duration,
    required this.category,
    required this.description,
  });

  final String pattern;
  final String duration;
  final String category;
  final String description;
}

/// Widget for displaying AP light indicator reference information
class LightIndicatorReference extends StatefulWidget {
  const LightIndicatorReference({super.key});

  @override
  State<LightIndicatorReference> createState() => _LightIndicatorReferenceState();
}

class _LightIndicatorReferenceState extends State<LightIndicatorReference> {
  String? _selectedStatus;

  /// AP Light Indicator definitions
  static const Map<String, LightIndicatorInfo> _lightIndicatorDetails = {
    'Green ↔ Red (2s solid)': LightIndicatorInfo(
      pattern: 'Green ↔ Red',
      duration: '2s solid',
      category: 'Certificate Override',
      description: 'Creating certificate request',
    ),
    'Blue ↔ Red (2s solid)': LightIndicatorInfo(
      pattern: 'Blue ↔ Red',
      duration: '2s solid',
      category: 'Certificate Override',
      description: 'Waiting for certificate approval',
    ),
    'Cyan blink (cert) (1s blink)': LightIndicatorInfo(
      pattern: 'Cyan blink (cert)',
      duration: '1s blink',
      category: 'Certificate Override',
      description: 'EST server blocking certificate operations',
    ),
    'Red blink (500ms blink)': LightIndicatorInfo(
      pattern: 'Red blink',
      duration: '500ms blink',
      category: 'Data Plane',
      description: 'Gateway/internet unreachable',
    ),
    'Blue blink (1s blink)': LightIndicatorInfo(
      pattern: 'Blue blink',
      duration: '1s blink',
      category: 'Management Plane',
      description: 'WebSocket connection lost',
    ),
    'Yellow blink (1s blink)': LightIndicatorInfo(
      pattern: 'Yellow blink',
      duration: '1s blink',
      category: 'Control Plane',
      description: 'RADIUS server unreachable',
    ),
    'Magenta blink (1s blink)': LightIndicatorInfo(
      pattern: 'Magenta blink',
      duration: '1s blink',
      category: 'GRE Data Plane',
      description: 'GRE tunnel connectivity failed',
    ),
    'Cyan blink (normal) (1s blink)': LightIndicatorInfo(
      pattern: 'Cyan blink (normal)',
      duration: '1s blink',
      category: 'Certificate Mgmt',
      description: 'EST server unreachable',
    ),
    'Solid Blue': LightIndicatorInfo(
      pattern: 'Solid Blue',
      duration: 'N/A',
      category: 'Active Service',
      description: 'Stations connected',
    ),
    'Solid Green': LightIndicatorInfo(
      pattern: 'Solid Green',
      duration: 'N/A',
      category: 'Ready/Idle',
      description: 'Ready, no stations',
    ),
    'Green blink (1s blink)': LightIndicatorInfo(
      pattern: 'Green blink',
      duration: '1s blink',
      category: 'Shutdown',
      description: 'Client shutting down',
    ),
  };

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
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'AP Light Indicator Reference',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Select a light status to view details',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            _buildDropdown(),
            const SizedBox(height: 12),
            _buildSelectedDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    final items = _lightIndicatorDetails.keys.toList();
    return InputDecorator(
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedStatus,
          hint: const Text('Select a light status'),
          isExpanded: true,
          items: items
              .map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(
                      status,
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedStatus = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildSelectedDetails() {
    if (_selectedStatus == null) {
      return const SizedBox.shrink();
    }

    final info = _lightIndicatorDetails[_selectedStatus!]!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Description', info.description),
          const SizedBox(height: 8),
          _buildInfoRow('Category', info.category),
          const SizedBox(height: 8),
          _buildInfoRow('Duration', info.duration),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
