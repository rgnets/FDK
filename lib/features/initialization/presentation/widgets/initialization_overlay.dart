import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rgnets_fdk/core/theme/app_colors.dart';
import 'package:rgnets_fdk/features/initialization/domain/entities/initialization_state.dart';
import 'package:rgnets_fdk/features/initialization/presentation/providers/initialization_provider.dart';
import 'package:rgnets_fdk/features/initialization/presentation/providers/seed_checklist_provider.dart';

/// Full-screen, interaction-blocking overlay shown during app initialization.
///
/// While the inventory seed runs it renders a checklist (Access Points,
/// Switches, ONTs, WLAN Controllers, Rooms) so the technician can see exactly
/// what is loading, and cannot use the app until it is ready. On a connection
/// failure it falls back to an error card with retry / re-scan actions.
class InitializationOverlay extends ConsumerWidget {
  const InitializationOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(initializationNotifierProvider);
    final notifier = ref.read(initializationNotifierProvider.notifier);
    final isError = state.maybeWhen(
      error: (_, __) => true,
      orElse: () => false,
    );

    return Material(
      // Opaque so no part of the app behind the loader is visible or tappable.
      color: AppColors.backgroundDark,
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(minWidth: 320, maxWidth: 440),
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
            margin: const EdgeInsets.all(24),
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
            child: isError
                ? _buildErrorContent(context, ref, notifier, state)
                : _buildLoadingContent(context, ref),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingContent(BuildContext context, WidgetRef ref) {
    final items = ref.watch(seedChecklistProvider);
    final total = items.length;
    final completed = items
        .where((i) =>
            i.status == SeedItemStatus.done ||
            i.status == SeedItemStatus.failed)
        .length;
    // Every resource has been fetched and applied, but the seed is still
    // finishing (persisting to local storage). Show "Finalizing…" so a brief
    // post-checklist gap doesn't read as a stuck popup.
    final finalizing = total > 0 && completed == total;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Image.asset(
          'assets/images/logos/2021_rgnets_logo_twotone_white.png',
          height: 56,
        ),
        const SizedBox(height: 24),
        Text(
          'Loading app…',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Preparing your site inventory. Please wait — this only takes a moment.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 24),
        for (final item in items) _SeedItemRow(item: item),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            // Indeterminate while finalizing so the bar keeps moving during the
            // persist step rather than sitting at a full-but-static 100%.
            value: total == 0 || finalizing ? null : completed / total,
            minHeight: 6,
            backgroundColor: AppColors.gray800,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          finalizing ? 'Finalizing…' : '$completed of $total ready',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildErrorContent(
    BuildContext context,
    WidgetRef ref,
    InitializationNotifier notifier,
    InitializationState state,
  ) {
    final message = state.maybeWhen(
      error: (message, _) => message,
      orElse: () => 'Something went wrong',
    );
    final retryCount = state.maybeWhen(
      error: (_, retryCount) => retryCount,
      orElse: () => 0,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/logos/2021_rgnets_logo_twotone_white.png',
          height: 56,
        ),
        const SizedBox(height: 24),
        const Icon(Icons.error_outline, color: AppColors.error, size: 48),
        const SizedBox(height: 16),
        Text(
          "Couldn't load the app",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.error,
              ),
        ),
        const SizedBox(height: 24),
        // Full-width stacked actions — robust on narrow field phones where a
        // side-by-side row would overflow.
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
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
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
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
        ),
      ],
    );
  }
}

/// One checklist row: status glyph, resource label, and a trailing count or
/// status word.
class _SeedItemRow extends StatelessWidget {
  const _SeedItemRow({required this.item});

  final SeedItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 22, height: 22, child: Center(child: _leading())),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              item.label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: item.status == SeedItemStatus.pending
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                  ),
            ),
          ),
          _trailing(context),
        ],
      ),
    );
  }

  Widget _leading() {
    switch (item.status) {
      case SeedItemStatus.pending:
        return const Icon(
          Icons.radio_button_unchecked,
          size: 20,
          color: AppColors.gray600,
        );
      case SeedItemStatus.loading:
        return const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        );
      case SeedItemStatus.done:
        return const Icon(
          Icons.check_circle,
          size: 20,
          color: AppColors.success,
        );
      case SeedItemStatus.failed:
        return const Icon(
          Icons.error_outline,
          size: 20,
          color: AppColors.warning,
        );
    }
  }

  Widget _trailing(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    switch (item.status) {
      case SeedItemStatus.pending:
      case SeedItemStatus.loading:
        return const SizedBox.shrink();
      case SeedItemStatus.done:
        return Text(
          '${item.count}',
          style: style?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        );
      case SeedItemStatus.failed:
        return Text(
          'Failed',
          style: style?.copyWith(color: AppColors.warning),
        );
    }
  }
}
