import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Lightweight error reporter to centralise crash/telemetry forwarding.
///
/// Implements a toggleable reporting layer so we can swap backends without
/// changing call sites.
class ErrorReporter {
  ErrorReporter._();

  static bool isEnabled = false;
  static bool _isInResumeGracePeriod = false;

  static bool get isInResumeGracePeriod => _isInResumeGracePeriod;

  static void setResumeGracePeriod(bool value) {
    _isInResumeGracePeriod = value;
  }

  /// Report an error to the configured backend.
  static Future<void> report(
    Object error, {
    StackTrace? stackTrace,
    String? hint,
  }) async {
    if (!isEnabled || _isInResumeGracePeriod) {
      if (kDebugMode) {
        debugPrint('[ErrorReporter] (disabled) $hint -> $error');
        if (stackTrace != null) {
          debugPrint(stackTrace.toString());
        }
      }
      return;
    }

    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
      hint: hint != null ? Hint.withMap({'message': hint}) : null,
    );
  }
}
