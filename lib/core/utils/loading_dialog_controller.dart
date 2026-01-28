import 'package:flutter/material.dart';
import 'package:rgnets_fdk/core/widgets/widgets.dart';

/// Controller to manage loading dialog state safely.
///
/// This controller ensures that:
/// 1. Loading dialogs are shown using the root navigator
/// 2. Loading dialogs are dismissed using the same root navigator
/// 3. Multiple show() calls don't stack dialogs
/// 4. dismiss() is safe to call even if not showing
///
/// Usage:
/// ```dart
/// final _loadingController = LoadingDialogController();
///
/// // Show loading
/// _loadingController.show(context);
///
/// // Do async work...
///
/// // Dismiss loading (safe even if not showing)
/// _loadingController.dismiss(context);
/// ```
class LoadingDialogController {
  bool _isShowing = false;
  int _showCount = 0;

  /// Whether the loading dialog is currently showing.
  bool get isShowing => _isShowing;

  /// Total number of times show() has been called successfully.
  /// Useful for debugging.
  int get showCount => _showCount;

  /// Mark the dialog as shown (for testing).
  @visibleForTesting
  void markShown() {
    if (!_isShowing) {
      _isShowing = true;
      _showCount++;
    }
  }

  /// Mark the dialog as dismissed (for testing).
  @visibleForTesting
  void markDismissed() {
    _isShowing = false;
  }

  /// Show loading dialog using root navigator.
  ///
  /// This method is safe to call multiple times - subsequent calls
  /// will be ignored if a dialog is already showing.
  ///
  /// The dialog is shown with:
  /// - `useRootNavigator: true` to ensure consistent dismiss behavior
  /// - `barrierDismissible: false` to prevent accidental dismissal
  void show(BuildContext context) {
    if (_isShowing) {
      return; // Prevent double-showing
    }

    _isShowing = true;
    _showCount++;

    // Use unawaited but with useRootNavigator: true for consistency
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true, // KEY: Use root navigator for both show and dismiss
      builder: (context) => const PopScope(
        canPop: false, // Prevent back button dismissal
        child: Center(child: LoadingIndicator()),
      ),
    );
  }

  /// Dismiss the loading dialog using root navigator.
  ///
  /// This method is safe to call even if no dialog is showing -
  /// it will simply be a no-op.
  ///
  /// Returns true if a dialog was dismissed, false otherwise.
  bool dismiss(BuildContext context) {
    if (!_isShowing) {
      return false; // Prevent double-dismissing
    }

    // Check if context is still valid before trying to use it
    if (!context.mounted) {
      _isShowing = false;
      return false;
    }

    final rootNavigator = Navigator.of(context, rootNavigator: true);
    if (rootNavigator.canPop()) {
      rootNavigator.pop();
      _isShowing = false;
      return true;
    }

    _isShowing = false;
    return false;
  }

  /// Ensure the dialog is dismissed, even if context might be invalid.
  ///
  /// Call this in dispose() or when the widget might be unmounted.
  void ensureDismissed(BuildContext? context) {
    if (!_isShowing) {
      return;
    }

    if (context != null && context.mounted) {
      dismiss(context);
    }

    // Reset state regardless
    _isShowing = false;
  }

  /// Reset the controller state.
  ///
  /// Use this when reinitializing the screen.
  void reset() {
    _isShowing = false;
  }
}
