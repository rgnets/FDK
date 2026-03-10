import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> authenticate({
    required String fqdn,
    required String login,
    required String token,
    String? siteName,
    DateTime? issuedAt,
    String? signature,
  });
  
  Future<Either<Failure, void>> signOut();
  
  Future<Either<Failure, User?>> getCurrentUser();
  
  Future<Either<Failure, bool>> isAuthenticated();

  /// Records an authentication attempt for auditing/debugging.
  Future<void> recordAuthAttempt({
    required String fqdn,
    required String login,
    required bool success,
    String? siteName,
    String? message,
  });

  /// Creates and saves a user after successful WebSocket handshake.
  Future<User> createAndSaveUser({
    required String login,
    required String fqdn,
    required String siteName,
  });
}
