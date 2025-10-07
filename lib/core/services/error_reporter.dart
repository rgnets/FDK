import 'package:flutter/foundation.dart';

/// Lightweight error reporter stub to centralise crash/telemetry forwarding.
///
/// Implements a toggleable reporting layer so we can plug in Sentry or another
/// backend without changing call sites.
class ErrorReporter {
  ErrorReporter._();

  static bool isEnabled = false;

  /// Report an error to the configured backend. Currently this is a stub that
  /// simply writes to the debug console when enabled.
  static void report(Object error, {StackTrace? stackTrace, String? hint}) {
    if (!isEnabled) {
      if (kDebugMode) {
        debugPrint('[ErrorReporter] (disabled) $hint -> $error');
        if (stackTrace != null) {
          debugPrint(stackTrace.toString());
        }
      }
      return;
    }

    // TODO(rgnets): Integrate real crash/telemetry backend (e.g., Sentry).
    debugPrint('[ErrorReporter] $hint -> $error');
    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
  }
}
