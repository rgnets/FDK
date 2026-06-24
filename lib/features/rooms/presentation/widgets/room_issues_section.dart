import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rgnets_fdk/core/theme/app_colors.dart';
import 'package:rgnets_fdk/features/room_readiness/domain/entities/issue.dart';
import 'package:rgnets_fdk/features/room_readiness/presentation/providers/room_readiness_provider.dart';

/// A PMS room's issues as a collapsible "Issues (N)" dropdown (ATT-FE-Tool
/// style): an outer accordion with the highest-severity color, per-severity
/// count badges, and a chevron; expanding it reveals one collapsible section
/// per severity (Critical → Warning → Notice), each holding the issue rows.
/// Tapping an issue opens the offending device's detail. Hidden when no issues.
class RoomIssuesSection extends ConsumerStatefulWidget {
  const RoomIssuesSection({required this.roomId, super.key});

  /// rXg pms_rooms id.
  final int roomId;

  @override
  ConsumerState<RoomIssuesSection> createState() => _RoomIssuesSectionState();
}

class _RoomIssuesSectionState extends ConsumerState<RoomIssuesSection> {
  bool _expanded = false;
  final Set<IssueSeverity> _openSeverities = {};

  /// Severity display order: critical, then warning, then info ("notice").
  static const List<IssueSeverity> _order = [
    IssueSeverity.critical,
    IssueSeverity.warning,
    IssueSeverity.info,
  ];

  @override
  Widget build(BuildContext context) {
    final metricsAsync = ref.watch(roomReadinessNotifierProvider);

    final issues = metricsAsync.maybeWhen(
      data: (rooms) {
        for (final m in rooms) {
          if (m.roomId == widget.roomId) return m.issues;
        }
        return const <Issue>[];
      },
      orElse: () => const <Issue>[],
    );

    if (issues.isEmpty) return const SizedBox.shrink();

    final grouped = {
      for (final s in _order) s: issues.where((i) => i.severity == s).toList(),
    };
    final highest = _order.firstWhere((s) => grouped[s]!.isNotEmpty);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            _outerHeader(issues.length, grouped, highest),
            if (_expanded)
              for (final severity in _order)
                if (grouped[severity]!.isNotEmpty)
                  _severitySection(severity, grouped[severity]!),
          ],
        ),
      ),
    );
  }

  /// "Issues (N)" header: highest-severity icon, count badges, chevron.
  Widget _outerHeader(
    int total,
    Map<IssueSeverity, List<Issue>> grouped,
    IssueSeverity highest,
  ) {
    final color = _severityColor(highest);
    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(_severityIcon(highest), color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Issues ($total)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    'Highest: ${_severityName(highest)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: color.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            for (final s in _order)
              if (grouped[s]!.isNotEmpty) ...[
                _CountBadge(count: grouped[s]!.length, color: _severityColor(s)),
                const SizedBox(width: 4),
              ],
            Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: color),
          ],
        ),
      ),
    );
  }

  /// One collapsible severity section: "Critical (n)" header → issue rows.
  Widget _severitySection(IssueSeverity severity, List<Issue> issues) {
    final color = _severityColor(severity);
    final open = _openSeverities.contains(severity);
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gray300),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() {
              if (open) {
                _openSeverities.remove(severity);
              } else {
                _openSeverities.add(severity);
              }
            }),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(_severityIcon(severity), size: 16, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_severityName(severity)} (${issues.length})',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                  Icon(
                    open ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: color,
                  ),
                ],
              ),
            ),
          ),
          if (open)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Column(
                children: [
                  for (final issue in issues)
                    _IssueCard(issue: issue, onTap: _onIssueTap(context, issue)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Tapping an issue opens the offending device's detail, when it has one.
  VoidCallback? _onIssueTap(BuildContext context, Issue issue) {
    final route = _deviceRoute(issue);
    if (route == null) return null;
    return () => context.push(route);
  }

  /// `/devices/<prefixed-id>` from the issue's `metadata` deviceId + deviceType.
  static String? _deviceRoute(Issue issue) {
    final id = issue.metadata['deviceId'];
    if (id == null) return null;
    final type = (issue.metadata['deviceType'] as String?)?.toUpperCase();
    final prefix = switch (type) {
      'AP' => 'ap_',
      'ONT' => 'ont_',
      'SWITCH' => 'sw_',
      'WLAN' => 'wlan_',
      _ => null,
    };
    if (prefix == null) return null;
    return '/devices/$prefix$id';
  }
}

/// Small colored count pill for the outer header.
class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// One issue row: severity-colored left border + category icon + title +
/// description + severity badge, tappable when it maps to a device.
class _IssueCard extends StatelessWidget {
  const _IssueCard({required this.issue, this.onTap});

  final Issue issue;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(issue.severity);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: InkWell(
        onTap: onTap,
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
                  _severityName(issue.severity).toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
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

/// "Notice" for info, to match the requested Critical / Warning / Notice wording.
String _severityName(IssueSeverity severity) {
  switch (severity) {
    case IssueSeverity.critical:
      return 'Critical';
    case IssueSeverity.warning:
      return 'Warning';
    case IssueSeverity.info:
      return 'Notice';
  }
}

IconData _severityIcon(IssueSeverity severity) {
  switch (severity) {
    case IssueSeverity.critical:
      return Icons.error;
    case IssueSeverity.warning:
      return Icons.warning;
    case IssueSeverity.info:
      return Icons.info;
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
