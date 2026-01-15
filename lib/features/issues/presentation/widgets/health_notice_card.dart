import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:rgnets_fdk/features/issues/domain/entities/health_notice.dart';

/// A card widget that displays a single health notice
class HealthNoticeCard extends StatelessWidget {
  const HealthNoticeCard({
    required this.notice,
    this.onTap,
    super.key,
  });

  final HealthNotice notice;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _getBackgroundColor().withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with severity and time
              Row(
                children: [
                  _buildSeverityBadge(),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      notice.shortMessage,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Device info
              if (notice.deviceName != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.router,
                      size: 16,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      notice.deviceName!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                    ),
                    if (notice.roomName != null) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.room,
                        size: 16,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        notice.roomName!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
              ],

              // Time info
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(notice.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                  ),
                  if (notice.isOverdue) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'OVERDUE',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeverityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getSeverityColor().withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: _getSeverityColor().withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getSeverityIcon(),
            size: 14,
            color: _getSeverityColor(),
          ),
          const SizedBox(width: 4),
          Text(
            _getSeverityLabel(),
            style: TextStyle(
              color: _getSeverityColor(),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    return _getSeverityColor();
  }

  Color _getSeverityColor() {
    switch (notice.severity) {
      case HealthNoticeSeverity.fatal:
        return Colors.red;
      case HealthNoticeSeverity.critical:
        return Colors.orange;
      case HealthNoticeSeverity.warning:
        return Colors.yellow;
      case HealthNoticeSeverity.notice:
        return Colors.blue;
    }
  }

  IconData _getSeverityIcon() {
    switch (notice.severity) {
      case HealthNoticeSeverity.fatal:
        return Icons.error;
      case HealthNoticeSeverity.critical:
        return Icons.warning;
      case HealthNoticeSeverity.warning:
        return Icons.info;
      case HealthNoticeSeverity.notice:
        return Icons.notifications;
    }
  }

  String _getSeverityLabel() {
    switch (notice.severity) {
      case HealthNoticeSeverity.fatal:
        return 'FATAL';
      case HealthNoticeSeverity.critical:
        return 'CRITICAL';
      case HealthNoticeSeverity.warning:
        return 'WARNING';
      case HealthNoticeSeverity.notice:
        return 'NOTICE';
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(time);
    }
  }
}
