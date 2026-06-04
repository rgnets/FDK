import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/theme/app_colors.dart';
import 'package:rgnets_fdk/features/auth/presentation/providers/login_connection_status.dart';

/// Live connection-status overlay shown while a login attempt runs. Watches
/// [loginConnectionStatusProvider] and renders the handshake as a short
/// checklist (Validating credentials → Connecting to server → Authorizing) so
/// the user sees real progress instead of a bare spinner.
class LoginConnectionDialog extends ConsumerWidget {
  const LoginConnectionDialog({super.key});

  static const _stages = <String>[
    'Validating credentials',
    'Connecting to server',
    'Authorizing',
  ];

  /// Index of the stage currently in progress (0-2), or 3 when every stage is
  /// done. Failed/initial states are handled separately by the caller.
  static int _activeIndex(LoginStep step) {
    switch (step) {
      case LoginStep.validatingCredentials:
        return 0;
      case LoginStep.connecting:
        return 1;
      case LoginStep.authorizing:
        return 2;
      case LoginStep.connected:
        return 3;
      case LoginStep.failed:
        return -1;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(loginConnectionStatusProvider);
    final activeIndex = _activeIndex(status.step);

    return Center(
      child: Card(
        color: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                status.isFailed ? 'Could not sign in' : 'Signing in…',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              if (status.isFailed)
                _FailureBody(message: status.error)
              else
                for (var i = 0; i < _stages.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: _StageRow(
                      label: _stages[i],
                      state: activeIndex > i
                          ? _StageState.done
                          : (activeIndex == i
                              ? _StageState.active
                              : _StageState.pending),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _StageState { pending, active, done }

class _StageRow extends StatelessWidget {
  const _StageRow({required this.label, required this.state});

  final String label;
  final _StageState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: _leading(),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: state == _StageState.pending
                ? AppColors.textSecondary
                : AppColors.textPrimary,
            fontWeight:
                state == _StageState.active ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _leading() {
    switch (state) {
      case _StageState.done:
        return Icon(Icons.check_circle, size: 22, color: AppColors.success);
      case _StageState.active:
        return const Padding(
          padding: EdgeInsets.all(2),
          child: CircularProgressIndicator(strokeWidth: 2.5),
        );
      case _StageState.pending:
        return Icon(
          Icons.radio_button_unchecked,
          size: 22,
          color: AppColors.gray400,
        );
    }
  }
}

class _FailureBody extends StatelessWidget {
  const _FailureBody({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.error_outline, size: 22, color: AppColors.error),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            (message == null || message!.trim().isEmpty)
                ? 'Connection failed. Please try again.'
                : message!,
            style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
