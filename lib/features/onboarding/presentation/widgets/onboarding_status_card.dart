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
<<<<<<< HEAD
<<<<<<< HEAD
    this.showDivider = true,
=======
>>>>>>> 6a559fa (Draft for device onboarding)
=======
    this.showDivider = true,
>>>>>>> 0a05c3e (Pass in onboarding state through websocket)
    super.key,
  });

  final OnboardingState state;
  final String title;
  final String resolution;
  final VoidCallback? onTap;
<<<<<<< HEAD
<<<<<<< HEAD
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final isComplete = state.isComplete;
    final isStageOne = state.currentStage == 1;


    
    final titleColor = isComplete
        ? Colors.black87
        : isStageOne
            ? Colors.orange
            : Colors.white;
    final stageColor = isComplete ? Colors.green : Colors.orange;
    final titleBgColor = isComplete || isStageOne ? null : Colors.orange;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDivider && isComplete)
          Divider(
            color: Colors.grey[300],
            thickness: 1,
            height: 1,
          ),

        if (!isComplete && !isStageOne)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: titleBgColor,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: titleColor,
              ),
            ),
          ),

        if (!isComplete && isStageOne)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: titleColor,
              ),
            ),
          ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.errorText != null && state.errorText!.isNotEmpty) ...[
                _buildErrorBox(context),
                const SizedBox(height: 12),
              ],

              if (isComplete)
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),

              if (isComplete) const SizedBox(height: 4),

              Text(
                'Stage ${state.currentStage}/${state.maxStages}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: stageColor,
                ),
              ),

              const SizedBox(height: 16),

              _buildStageCircles(context),

              const SizedBox(height: 16),

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
      ],
=======
=======
  final bool showDivider;
>>>>>>> 0a05c3e (Pass in onboarding state through websocket)

  @override
  Widget build(BuildContext context) {
    final isComplete = state.isComplete;

    // Use orange/warning styling when not complete
    final titleColor = isComplete ? Colors.black87 : Colors.white;
    final stageColor = isComplete ? Colors.green : Colors.orange;
    final titleBgColor = isComplete ? null : Colors.orange;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Divider line at top (matches design) - only for complete state
        if (showDivider && isComplete)
          Divider(
            color: Colors.grey[300],
            thickness: 1,
            height: 1,
          ),

        // Title header with background when not complete
        if (!isComplete)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: titleBgColor,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: titleColor,
              ),
            ),
          ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Error box (if error exists) - show at top
              if (state.errorText != null && state.errorText!.isNotEmpty) ...[
                _buildErrorBox(context),
                const SizedBox(height: 12),
              ],

              // Title header (black text, bold) - only for complete state
              if (isComplete)
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),

              if (isComplete) const SizedBox(height: 4),

              // Stage indicator
              Text(
                'Stage ${state.currentStage}/${state.maxStages}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: stageColor,
                ),
              ),

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
<<<<<<< HEAD
      ),
>>>>>>> 6a559fa (Draft for device onboarding)
=======
      ],
>>>>>>> 0a05c3e (Pass in onboarding state through websocket)
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

<<<<<<< HEAD
<<<<<<< HEAD
=======
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

>>>>>>> 6a559fa (Draft for device onboarding)
=======
>>>>>>> 0a05c3e (Pass in onboarding state through websocket)
  Widget _buildStageCircles(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(state.maxStages, (index) {
        final stageNumber = index + 1;
<<<<<<< HEAD
        final isCompleted = stageNumber <= state.currentStage;
        final isCurrent = stageNumber == state.currentStage;
        final isComplete = state.isComplete;

=======
        final isCompleted = stageNumber < state.currentStage;
        final isCurrent = stageNumber == state.currentStage;
        final isComplete = state.isComplete;

        // If onboarding is complete, all stages show as completed
>>>>>>> 6a559fa (Draft for device onboarding)
        if (isComplete) {
          return _buildCompletedCircle();
        }

<<<<<<< HEAD
=======
        // Current stage or completed stages
>>>>>>> 6a559fa (Draft for device onboarding)
        if (isCompleted || (isCurrent && state.isComplete)) {
          return _buildCompletedCircle();
        }

<<<<<<< HEAD
=======
        // Pending stages (including current if not complete)
>>>>>>> 6a559fa (Draft for device onboarding)
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
