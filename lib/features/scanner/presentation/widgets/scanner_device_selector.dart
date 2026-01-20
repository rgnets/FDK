import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/scanner_state.dart';
import 'package:rgnets_fdk/features/scanner/presentation/providers/scanner_notifier.dart';

/// Device type selector for the scanner (like AT&T app).
///
/// Shows selectable chips for: Auto, RxG, AP, ONT, Switch
class ScannerDeviceSelector extends ConsumerWidget {
  const ScannerDeviceSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scannerState = ref.watch(scannerNotifierProvider);
    final currentMode = scannerState.scanMode;
    final isAutoLocked = scannerState.isAutoLocked;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildModeChip(
              context,
              ref,
              mode: ScanMode.auto,
              currentMode: currentMode,
              isAutoLocked: isAutoLocked,
            ),
            const SizedBox(width: 8),
            _buildModeChip(
              context,
              ref,
              mode: ScanMode.rxg,
              currentMode: currentMode,
              isAutoLocked: isAutoLocked,
            ),
            const SizedBox(width: 8),
            _buildModeChip(
              context,
              ref,
              mode: ScanMode.accessPoint,
              currentMode: currentMode,
              isAutoLocked: isAutoLocked,
            ),
            const SizedBox(width: 8),
            _buildModeChip(
              context,
              ref,
              mode: ScanMode.ont,
              currentMode: currentMode,
              isAutoLocked: isAutoLocked,
            ),
            const SizedBox(width: 8),
            _buildModeChip(
              context,
              ref,
              mode: ScanMode.switchDevice,
              currentMode: currentMode,
              isAutoLocked: isAutoLocked,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeChip(
    BuildContext context,
    WidgetRef ref, {
    required ScanMode mode,
    required ScanMode currentMode,
    required bool isAutoLocked,
  }) {
    final isSelected = mode == currentMode;
    final isLocked = isAutoLocked && isSelected && mode != ScanMode.auto;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Colors based on selection state
    Color backgroundColor;
    Color foregroundColor;
    Color borderColor;

    if (isSelected) {
      if (isLocked) {
        // Auto-locked mode - use accent color
        backgroundColor = colorScheme.primaryContainer;
        foregroundColor = colorScheme.onPrimaryContainer;
        borderColor = colorScheme.primary;
      } else {
        // Manually selected
        backgroundColor = colorScheme.primary;
        foregroundColor = colorScheme.onPrimary;
        borderColor = colorScheme.primary;
      }
    } else {
      backgroundColor = colorScheme.surface;
      foregroundColor = colorScheme.onSurface;
      borderColor = colorScheme.outline;
    }

    return GestureDetector(
      onTap: () {
        ref.read(scannerNotifierProvider.notifier).setScanMode(mode);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLocked) ...[
              Icon(
                Icons.lock_outline,
                size: 14,
                color: foregroundColor,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              mode.abbreviation,
              style: theme.textTheme.labelMedium?.copyWith(
                color: foregroundColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact version of the device selector as a dropdown.
class ScannerDeviceSelectorDropdown extends ConsumerWidget {
  const ScannerDeviceSelectorDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scannerState = ref.watch(scannerNotifierProvider);
    final currentMode = scannerState.scanMode;
    final isAutoLocked = scannerState.isAutoLocked;

    final theme = Theme.of(context);

    return PopupMenuButton<ScanMode>(
      initialValue: currentMode,
      onSelected: (mode) {
        ref.read(scannerNotifierProvider.notifier).setScanMode(mode);
      },
      itemBuilder: (context) => ScanMode.values.map((mode) {
        final isSelected = mode == currentMode;
        return PopupMenuItem<ScanMode>(
          value: mode,
          child: Row(
            children: [
              if (isSelected && isAutoLocked && mode != ScanMode.auto)
                const Icon(Icons.lock_outline, size: 16)
              else
                const SizedBox(width: 16),
              const SizedBox(width: 8),
              Text(mode.displayName),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isAutoLocked && currentMode != ScanMode.auto) ...[
              Icon(
                Icons.lock_outline,
                size: 14,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              currentMode.displayName,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }
}
