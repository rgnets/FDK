import 'package:flutter/material.dart';

/// "AP Light Indicator Reference" card: pick an AP LED status from the dropdown
/// to see what it means (pattern, duration, category, description).
///
/// Ported from the ATT-FE-Tool (`device_detail_view.dart` —
/// `_apLightIndicatorDetails` + `_buildLightStatusReferenceSection`). The
/// dictionary is the canonical AP LED meaning table and is intentionally kept
/// verbatim so the two tools stay in sync. AP-only — show it for access points.
class ApLightIndicatorReference extends StatefulWidget {
  const ApLightIndicatorReference({super.key});

  @override
  State<ApLightIndicatorReference> createState() =>
      _ApLightIndicatorReferenceState();
}

class _ApLightIndicatorReferenceState extends State<ApLightIndicatorReference> {
  String? _selected;

  /// status label -> { pattern, duration, category, description }.
  static const Map<String, Map<String, String>> _details = {
    'Green ↔ Red (2s solid)': {
      'pattern': 'Green ↔ Red',
      'duration': '2s solid',
      'category': 'Certificate Override',
      'description': 'Creating certificate request',
    },
    'Blue ↔ Red (2s solid)': {
      'pattern': 'Blue ↔ Red',
      'duration': '2s solid',
      'category': 'Certificate Override',
      'description': 'Waiting for certificate approval',
    },
    'Cyan blink (cert) (1s blink)': {
      'pattern': 'Cyan blink (cert)',
      'duration': '1s blink',
      'category': 'Certificate Override',
      'description': 'EST server blocking certificate operations',
    },
    'Red blink (500ms blink)': {
      'pattern': 'Red blink',
      'duration': '500ms blink',
      'category': 'Data Plane',
      'description': 'Gateway/internet unreachable',
    },
    'Blue blink (1s blink)': {
      'pattern': 'Blue blink',
      'duration': '1s blink',
      'category': 'Management Plane',
      'description': 'WebSocket connection lost',
    },
    'Yellow blink (1s blink)': {
      'pattern': 'Yellow blink',
      'duration': '1s blink',
      'category': 'Control Plane',
      'description': 'RADIUS server unreachable',
    },
    'Magenta blink (1s blink)': {
      'pattern': 'Magenta blink',
      'duration': '1s blink',
      'category': 'GRE Data Plane',
      'description': 'GRE tunnel connectivity failed',
    },
    'Cyan blink (normal) (1s blink)': {
      'pattern': 'Cyan blink (normal)',
      'duration': '1s blink',
      'category': 'Certificate Mgmt',
      'description': 'EST server unreachable',
    },
    'Solid Blue': {
      'pattern': 'Solid Blue',
      'duration': 'N/A',
      'category': 'Active Service',
      'description': 'Stations connected',
    },
    'Solid Green': {
      'pattern': 'Solid Green',
      'duration': 'N/A',
      'category': 'Ready/Idle',
      'description': 'Ready, no stations',
    },
    'Green blink (1s blink)': {
      'pattern': 'Green blink',
      'duration': '1s blink',
      'category': 'Shutdown',
      'description': 'Client shutting down',
    },
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline,
                    color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'AP Light Indicator Reference',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Select a light status to view details',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selected,
              isExpanded: true,
              hint: const Text('Select a light status'),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _details.keys
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(status,
                          style: theme.textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selected = value),
            ),
            if (_selected != null) ...[
              const SizedBox(height: 12),
              _SelectedLightDetails(info: _details[_selected]!),
            ],
          ],
        ),
      ),
    );
  }
}

/// Description / Category / Duration panel for the selected status.
class _SelectedLightDetails extends StatelessWidget {
  const _SelectedLightDetails({required this.info});

  final Map<String, String> info;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row(context, 'Description:', info['description']!),
          _row(context, 'Category:', info['category']!),
          _row(context, 'Duration:', info['duration']!),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
