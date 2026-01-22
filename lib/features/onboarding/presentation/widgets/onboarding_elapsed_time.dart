import 'package:flutter/material.dart';
import 'package:rgnets_fdk/features/onboarding/data/models/onboarding_state.dart';

/// Widget displaying elapsed time since entering current stage.
/// Shows overdue warning styling when applicable.
class OnboardingElapsedTime extends StatelessWidget {
  const OnboardingElapsedTime({
    required this.state,
    this.showOverdueWarning = true,
    this.showIcon = true,
    super.key,
  });

  final OnboardingState state;
  final bool showOverdueWarning;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    if (state.isComplete) {
      return _buildCompleteBadge(context);
    }

    final elapsedText = state.elapsedTimeFormatted;
    if (elapsedText == null) {
      return const SizedBox.shrink();
    }

    final isOverdue = showOverdueWarning && state.isOverdue;
    final color = isOverdue ? Colors.orange : Colors.white.withValues(alpha: 0.6);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOverdue
            ? Colors.orange.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(4),
        border: isOverdue
            ? Border.all(color: Colors.orange.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              isOverdue ? Icons.warning_amber : Icons.timer_outlined,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            elapsedText,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            const Icon(
              Icons.check_circle,
              size: 14,
              color: Colors.green,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            'Complete',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
