import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/features/onboarding/data/models/onboarding_state.dart';
import 'package:rgnets_fdk/features/onboarding/presentation/providers/device_onboarding_provider.dart';

/// Card widget displaying full onboarding status matching the design:
/// - Orange title header with stage message
/// - Error/status box (if applicable)
/// - Stage indicator with elapsed time
/// - Visual stage progress circles
/// - Resolution text
class OnboardingStatusCard extends ConsumerWidget {
  const OnboardingStatusCard({
    required this.deviceId,
    this.onTap,
    super.key,
  });

  final String deviceId;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deviceOnboardingStateProvider(deviceId));

    if (state == null || !state.hasStarted) {
      return const SizedBox.shrink();
    }

    final resolver = ref.watch(messageResolverProvider);
    final message = resolver.getMessage(state.deviceType, state.currentStage);

    return OnboardingStatusCardContent(
      state: state,
      title: message.title,
      resolution: message.resolution,
      onTap: onTap,
    );
  }
}

/// Standalone card that takes state directly (for use without provider).
class OnboardingStatusCardContent extends StatelessWidget {
  const OnboardingStatusCardContent({
    required this.state,
    required this.title,
    required this.resolution,
    this.onTap,
    super.key,
  });

  final OnboardingState state;
  final String title;
  final String resolution;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title header (orange text)
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),

                const SizedBox(height: 12),

                // Error box (if error exists)
                if (state.errorText != null && state.errorText!.isNotEmpty)
                  _buildErrorBox(context),

                if (state.errorText != null && state.errorText!.isNotEmpty)
                  const SizedBox(height: 12),

                // Stage indicator row
                _buildStageRow(context),

                const SizedBox(height: 16),

                // Stage progress circles
                _buildStageCircles(context),

                const SizedBox(height: 16),

                // Resolution text
                Text(
                  resolution,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBox(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 18,
            color: Colors.red[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              state.errorText!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.red[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageRow(BuildContext context) {
    final elapsedText = state.elapsedTimeFormatted;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Stage indicator
        Text(
          'Stage ${state.currentStage}/${state.maxStages}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.orange,
          ),
        ),

        // Elapsed time
        if (elapsedText != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              elapsedText,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStageCircles(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(state.maxStages, (index) {
        final stageNumber = index + 1;
        final isCompleted = stageNumber < state.currentStage;
        final isCurrent = stageNumber == state.currentStage;
        final isComplete = state.isComplete;

        // If onboarding is complete, all stages show as completed
        if (isComplete) {
          return _buildCompletedCircle();
        }

        // Current stage or completed stages
        if (isCompleted || (isCurrent && state.isComplete)) {
          return _buildCompletedCircle();
        }

        // Pending stages (including current if not complete)
        return _buildPendingCircle();
      }),
    );
  }

  Widget _buildCompletedCircle() {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check,
        color: Colors.white,
        size: 22,
      ),
    );
  }

  Widget _buildPendingCircle() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.close,
        color: Colors.grey[400],
        size: 22,
      ),
    );
  }
}
