import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/theme/app_colors.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/devices/presentation/providers/device_issues_provider.dart';
import 'package:rgnets_fdk/features/room_readiness/domain/entities/issue.dart';

/// Lists a device's outstanding issues (e.g. "Missing Device Images", "Missing
/// Speed Test") on the device detail screen, sourced from the backend
/// compliance feeds via [deviceComplianceIssuesProvider] — the compliance
/// manager creates these; nothing is computed app-side. Renders nothing when
/// there are no issues (no empty-state card), matching ATT-FE-Tool.
class DeviceIssuesSection extends ConsumerWidget {
  const DeviceIssuesSection({required this.device, super.key});

  final Device device;

  /// Parse the numeric rXg id out of a prefixed device id (`ap_1203` -> 1203).
  static int? _numericId(String id) {
    final parts = id.split('_');
    return int.tryParse(parts.length >= 2 ? parts.sublist(1).join('_') : id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final numericId = _numericId(device.id);
    if (numericId == null) return const SizedBox.shrink();

    final issues = ref.watch(
      deviceComplianceIssuesProvider(
        (deviceId: numericId, deviceType: device.type),
      ),
    );
    if (issues.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final issue in issues) _DeviceIssueCard(issue: issue),
      ],
    );
  }
}

/// A single issue row: colored left border + category icon + title/description
/// + severity badge.
class _DeviceIssueCard extends StatelessWidget {
  const _DeviceIssueCard({required this.issue});

  final Issue issue;

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(issue.severity);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_categoryIcon(issue.category), color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    issue.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    issue.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _severityLabel(issue.severity),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _severityColor(IssueSeverity severity) {
    switch (severity) {
      case IssueSeverity.critical:
        return AppColors.error;
      case IssueSeverity.warning:
        return AppColors.warning;
      case IssueSeverity.info:
        return AppColors.primary;
    }
  }

  String _severityLabel(IssueSeverity severity) {
    switch (severity) {
      case IssueSeverity.critical:
        return 'CRITICAL';
      case IssueSeverity.warning:
        return 'WARNING';
      case IssueSeverity.info:
        return 'INFO';
    }
  }

  IconData _categoryIcon(IssueCategory category) {
    switch (category) {
      case IssueCategory.connectivity:
        return Icons.wifi_off;
      case IssueCategory.configuration:
        return Icons.settings;
      case IssueCategory.performance:
        return Icons.speed;
      case IssueCategory.documentation:
        return Icons.image_not_supported;
      case IssueCategory.onboarding:
        return Icons.play_circle_outline;
      case IssueCategory.maintenance:
        return Icons.build;
      case IssueCategory.compliance:
        return Icons.policy;
    }
  }
}
