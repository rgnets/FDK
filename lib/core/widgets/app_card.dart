import 'package:flutter/material.dart';
import 'package:rgnets_fdk/core/theme/app_colors.dart';

/// Custom card widget with consistent styling
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    super.key,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.elevation,
    this.borderRadius,
  });
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      color: color ?? Theme.of(context).cardColor,
      elevation: elevation ?? 2,
      margin: margin ?? EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: borderRadius ?? BorderRadius.circular(12)),
      child: Padding(padding: padding ?? const EdgeInsets.all(16), child: child),
    );

    if (onTap != null) {
      return InkWell(onTap: onTap, borderRadius: borderRadius ?? BorderRadius.circular(12), child: card);
    }

    return card;
  }
}

/// Status card widget for displaying metrics
class StatusCard extends StatelessWidget {
  const StatusCard({required this.label, required this.value, super.key, this.icon, this.color, this.onTap});
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 32, color: color ?? Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
          ],
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
