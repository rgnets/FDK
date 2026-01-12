import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/features/auth/domain/entities/auth_status.dart';
import 'package:rgnets_fdk/features/auth/domain/entities/user.dart';
import 'package:rgnets_fdk/features/auth/presentation/providers/auth_notifier.dart';

const testUser = User(
  username: 'test',
  siteUrl: 'https://test.example.com',
  email: 'test@example.com',
);

Override overrideAuthProvider({
  required AuthStatus initialStatus,
  AuthStatus? authenticateStatus,
}) {
  return authProvider.overrideWith(
    () => TestAuthNotifier(
      initialStatus: initialStatus,
      authenticateStatus: authenticateStatus,
    ),
  );
}

class TestAuthNotifier extends Auth {
  TestAuthNotifier({
    required this.initialStatus,
    this.authenticateStatus,
  });

  final AuthStatus initialStatus;
  final AuthStatus? authenticateStatus;

  @override
  Future<AuthStatus> build() async => initialStatus;

  @override
  Future<void> authenticate({
    required String fqdn,
    required String login,
    required String token,
    String? siteName,
    DateTime? issuedAt,
    String? signature,
  }) async {
    final nextStatus = authenticateStatus;
    if (nextStatus != null) {
      state = AsyncValue.data(nextStatus);
    }
  }
}
