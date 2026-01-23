import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/features/onboarding/data/models/onboarding_state.dart';
import 'package:rgnets_fdk/features/onboarding/presentation/providers/device_onboarding_provider.dart';

/// Compact badge for displaying onboarding status in device list items.
class OnboardingStageBadge extends ConsumerWidget {
  const OnboardingStageBadge({
    required this.deviceId,
    this.compact = false,
    super.key,
  });

  final String deviceId;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deviceOnboardingStateProvider(deviceId));

    if (state == null || !state.hasStarted) {
      return const SizedBox.shrink();
    }

    return _OnboardingStageBadgeContent(
      state: state,
      compact: compact,
    );
  }
}

/// Content widget for stage badge (can be used standalone with state).
class _OnboardingStageBadgeContent extends StatelessWidget {
  const _OnboardingStageBadgeContent({
    required this.state,
    this.compact = false,
  });

  final OnboardingState state;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final text = _getText();
    final icon = _getIcon();

    if (compact) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Center(
          child: Icon(icon, size: 14, color: color),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Color _getColor() {
    if (state.isComplete) return Colors.green;
    if (state.isOverdue) return Colors.orange;
    return Colors.blue;
  }

  String _getText() {
    if (state.isComplete) return 'Complete';
    if (state.isOverdue) return 'Stage ${state.currentStage} (Overdue)';
    return 'Stage ${state.currentStage}/${state.maxStages}';
  }

  IconData _getIcon() {
    if (state.isComplete) return Icons.check_circle;
    if (state.isOverdue) return Icons.warning_amber;
    return Icons.pending;
  }
}

/// Standalone badge that takes an OnboardingState directly.
class OnboardingStageBadgeFromState extends StatelessWidget {
  const OnboardingStageBadgeFromState({
    required this.state,
    this.compact = false,
    super.key,
  });

  final OnboardingState? state;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (state == null || !state!.hasStarted) {
      return const SizedBox.shrink();
    }

    return _OnboardingStageBadgeContent(
      state: state!,
      compact: compact,
    );
  }
}
