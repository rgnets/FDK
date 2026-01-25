import 'package:flutter/material.dart';
import 'package:rgnets_fdk/features/onboarding/data/models/onboarding_state.dart';

/// Visual progress bar showing onboarding stage progress.
class OnboardingProgressIndicator extends StatelessWidget {
  const OnboardingProgressIndicator({
    required this.state,
    this.height = 8,
    this.showLabel = true,
    super.key,
  });

  final OnboardingState state;
  final double height;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final progress = state.progress;
    final color = _getColor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: height,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
              ),
              Text(
                'Stage ${state.currentStage} of ${state.maxStages}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Color _getColor() {
    if (state.isComplete) return Colors.green;
    if (state.isOverdue) return Colors.orange;
    return Colors.blue;
  }
}
