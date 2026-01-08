import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/scanner_state.dart';
import 'package:rgnets_fdk/features/scanner/presentation/providers/scanner_notifier.dart';
import 'package:rgnets_fdk/features/scanner/presentation/utils/scanner_utils.dart';

/// Displays the requirements checklist for the current scan mode.
///
/// Shows which fields are collected and which are still needed.
class ScannerRequirementsDisplay extends ConsumerWidget {
  const ScannerRequirementsDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scannerState = ref.watch(scannerNotifierProvider);
    final scanMode = scannerState.scanMode;

    // Don't show for auto or rxg modes
    if (scanMode == ScanMode.auto || scanMode == ScanMode.rxg) {
      return const SizedBox.shrink();
    }

    final collectedFields = scannerState.collectedFields;
    final missingFields = scannerState.missingFields;
    final progress = scannerState.scanProgress;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with mode and progress
          Row(
            children: [
              Icon(
                ScannerUtils.getModeIcon(scanMode),
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                scanMode.displayName,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              _buildProgressIndicator(context, progress),
            ],
          ),
          const SizedBox(height: 12),

          // Collected fields (green checkmarks)
          ...collectedFields.map((field) => _buildFieldRow(
                context,
                field: field,
                isCollected: true,
              )),

          // Missing fields (empty circles)
          ...missingFields.map((field) => _buildFieldRow(
                context,
                field: field,
                isCollected: false,
              )),
        ],
      ),
    );
  }

  Widget _buildFieldRow(
    BuildContext context, {
    required String field,
    required bool isCollected,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCollected
                  ? Colors.green.shade600
                  : Colors.transparent,
              border: Border.all(
                color: isCollected
                    ? Colors.green.shade600
                    : theme.colorScheme.outline,
                width: 2,
              ),
            ),
            child: isCollected
                ? const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              field,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isCollected
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant,
                decoration: isCollected ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context, double progress) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${(progress * 100).toInt()}%',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: progress >= 1.0 ? Colors.green : theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0 ? Colors.green : theme.colorScheme.primary,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }

}

/// Compact inline version showing just the scan data values.
class ScannerDataDisplay extends ConsumerWidget {
  const ScannerDataDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scannerState = ref.watch(scannerNotifierProvider);
    final scanData = scannerState.scanData;
    final scanMode = scannerState.scanMode;

    // Don't show for auto or rxg modes
    if (scanMode == ScanMode.auto || scanMode == ScanMode.rxg) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (scanData.mac.isNotEmpty)
            _buildDataRow(context, 'MAC', ScannerUtils.formatMac(scanData.mac)),
          if (scanData.serialNumber.isNotEmpty)
            _buildDataRow(context, 'Serial', scanData.serialNumber),
          if (scanData.partNumber.isNotEmpty)
            _buildDataRow(context, 'Part #', scanData.partNumber),
          if (scanData.model.isNotEmpty)
            _buildDataRow(context, 'Model', scanData.model),
        ],
      ),
    );
  }

  Widget _buildDataRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
