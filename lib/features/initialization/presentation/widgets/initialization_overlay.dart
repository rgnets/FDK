import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rgnets_fdk/core/theme/app_colors.dart';
import 'package:rgnets_fdk/features/initialization/domain/entities/initialization_state.dart';
import 'package:rgnets_fdk/features/initialization/presentation/providers/initialization_provider.dart';

/// Full-screen overlay shown during app initialization.
/// Displays progress, bytes downloaded, and error recovery options.
class InitializationOverlay extends ConsumerWidget {
  const InitializationOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(initializationNotifierProvider);
    final notifier = ref.read(initializationNotifierProvider.notifier);

    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(
            minWidth: 350,
            maxWidth: 450,
          ),
          padding: const EdgeInsets.fromLTRB(24, 29, 24, 56),
          margin: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // RG Nets Logo
              Image.asset(
                'assets/images/logos/2021_rgnets_logo_twotone_white.png',
                height: 60,
              ),
              const SizedBox(height: 24),

              // Current operation text
              Text(
                _getOperationText(state),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Progress indicator or error icon
              _buildProgressIndicator(state),
              const SizedBox(height: 16),

              // Bytes downloaded (only during loadingData)
              state.maybeWhen(
                loadingData: (bytesDownloaded, _) => Text(
                  '${(bytesDownloaded / 1024).toStringAsFixed(0)} KB downloaded',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                orElse: () => const SizedBox.shrink(),
              ),

              // Error state UI
              state.maybeWhen(
                error: (message, retryCount) => _buildErrorActions(
                  context,
                  ref,
                  notifier,
                  message,
                  retryCount,
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getOperationText(InitializationState state) {
    return state.when(
      uninitialized: () => 'Initializing...',
      checkingConnection: () => 'Checking connection...',
      validatingCredentials: () => 'Validating credentials...',
      loadingData: (_, operation) => operation,
      ready: () => 'Ready!',
      error: (_, __) => 'Error occurred',
    );
  }

  Widget _buildProgressIndicator(InitializationState state) {
    return state.maybeWhen(
      error: (_, __) => const Icon(
        Icons.error_outline,
        color: AppColors.error,
        size: 48,
      ),
      orElse: () => const CircularProgressIndicator(
        color: AppColors.primary,
        strokeWidth: 3,
      ),
    );
  }

  Widget _buildErrorActions(
    BuildContext context,
    WidgetRef ref,
    InitializationNotifier notifier,
    String message,
    int retryCount,
  ) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.error,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Retry button
            ElevatedButton.icon(
              onPressed: notifier.canRetry ? () => notifier.retry() : null,
              icon: const Icon(Icons.refresh),
              label: Text(
                notifier.canRetry
                    ? 'Retry ($retryCount/${InitializationNotifier.maxRetries})'
                    : 'Max retries',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
            ),

            // Scan New button
            ElevatedButton.icon(
              onPressed: () {
                notifier.reset();
                context.go('/auth');
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan New'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gray700,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
