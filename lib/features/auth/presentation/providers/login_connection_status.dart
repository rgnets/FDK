import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stages of the login connection handshake, surfaced live in the login overlay
/// so the user sees progress (and any failure) instead of a bare spinner.
///
/// Order matters: [validatingCredentials] → [connecting] → [authorizing] →
/// [connected]. [failed] is terminal and carries an error message.
enum LoginStep {
  validatingCredentials,
  connecting,
  authorizing,
  connected,
  failed,
}

/// Snapshot of where the in-progress login attempt is. Driven by
/// `AuthNotifier` during `authenticate()` / the WebSocket handshake and read by
/// the login overlay.
class LoginConnectionStatus {
  const LoginConnectionStatus({
    this.step = LoginStep.validatingCredentials,
    this.error,
  });

  final LoginStep step;

  /// Failure reason when [step] is [LoginStep.failed]; otherwise null.
  final String? error;

  bool get isFailed => step == LoginStep.failed;
}

class LoginConnectionStatusNotifier extends Notifier<LoginConnectionStatus> {
  @override
  LoginConnectionStatus build() => const LoginConnectionStatus();

  /// Advance to [step] (clears any prior error).
  void set(LoginStep step) => state = LoginConnectionStatus(step: step);

  /// Mark the attempt failed with a user-facing [message].
  void fail(String message) =>
      state = LoginConnectionStatus(step: LoginStep.failed, error: message);

  /// Reset to the initial stage. Call before starting a fresh attempt.
  void reset() => state = const LoginConnectionStatus();
}

final loginConnectionStatusProvider =
    NotifierProvider<LoginConnectionStatusNotifier, LoginConnectionStatus>(
  LoginConnectionStatusNotifier.new,
);
