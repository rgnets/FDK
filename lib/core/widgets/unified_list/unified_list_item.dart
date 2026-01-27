import 'package:flutter/material.dart';
import 'package:rgnets_fdk/core/theme/app_colors.dart';

/// Unified list item widget for consistent display across the app
/// Used for devices, tasks/alerts, and rooms lists
class UnifiedListItem extends StatelessWidget {
  const UnifiedListItem({
    required this.title,
    required this.icon,
    required this.status,
    super.key,
    this.subtitleLines = const [],
    this.iconColorOverride,
    this.titleColor,
    this.statusBadge,
    this.onTap,
    this.showChevron = false,
    this.trailingWidget,
    this.isUnread = false,
  }) : assert(subtitleLines.length <= 2, 'Maximum 2 subtitle lines allowed');

  final String title;
  final IconData icon;
  final UnifiedItemStatus status;
  final List<UnifiedInfoLine> subtitleLines;
  final Color? iconColorOverride;
  final Color? titleColor;
  final UnifiedStatusBadge? statusBadge;
  final VoidCallback? onTap;
  final bool showChevron;
  final Widget? trailingWidget;
  final bool isUnread;

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(status);
    final iconColor = iconColorOverride ?? statusColor;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: const DecorationImage(
          image: AssetImage('assets/images/ui_elements/hud_box.png'),
          fit: BoxFit.fill,
          opacity: 0.1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                  color: titleColor ?? AppColors.textPrimary,
                ),
              ),
            ),
            if (isUnread)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(left: 8),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: subtitleLines.isEmpty
            ? null
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  ...subtitleLines.map(_buildInfoLine),
                ],
              ),
        trailing: _buildTrailing(statusColor),
      ),
    );
  }

  Widget _buildInfoLine(UnifiedInfoLine line) {
    if (line.icon == null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(
          line.text,
          maxLines: line.maxLines,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: line.color ?? AppColors.textSecondary,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(
            line.icon,
            size: 12,
            color: line.color ?? AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              line.text,
              maxLines: line.maxLines,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: line.color ?? AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildTrailing(Color statusColor) {
    if (trailingWidget != null) {
      return trailingWidget;
    }

    final widgets = <Widget>[];

    // Add status badge if provided
    if (statusBadge != null) {
      widgets.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusBadge!.color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            statusBadge!.text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: statusBadge!.color,
            ),
          ),
        ),
      );
    }

    // Add chevron if tappable to details
    if (showChevron && onTap != null) {
      widgets.add(
        Icon(
          Icons.chevron_right,
          size: 20,
          color: Colors.grey[400],
        ),
      );
    }

    if (widgets.isEmpty) {
      return null;
    }
    if (widgets.length == 1) {
      return widgets.first;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: widgets,
    );
  }

  Color _getStatusColor(UnifiedItemStatus status) {
    switch (status) {
      case UnifiedItemStatus.good:
      case UnifiedItemStatus.online:
        return AppColors.success;
      case UnifiedItemStatus.warning:
        return AppColors.warning;
      case UnifiedItemStatus.error:
      case UnifiedItemStatus.offline:
        return AppColors.error;
      case UnifiedItemStatus.info:
        return AppColors.info;
      case UnifiedItemStatus.unknown:
        return AppColors.gray600;
    }
  }
}

/// Status states for unified list items
enum UnifiedItemStatus {
  good,     // Green - working properly
  warning,  // Orange - has issues
  error,    // Red - critical problem
  offline,  // Red - device offline
  online,   // Green - device online
  info,     // Blue - informational
  unknown,  // Gray - status unknown
}

/// Configuration for a status badge
class UnifiedStatusBadge {
  const UnifiedStatusBadge({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;
}

/// Configuration for an info line in the subtitle
class UnifiedInfoLine {
  const UnifiedInfoLine({
    required this.text,
    this.icon,
    this.color,
    this.maxLines = 1,
  });

  final String text;
  final IconData? icon;
  final Color? color;
  final int maxLines;
}
