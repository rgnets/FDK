import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> authenticate({
    required String fqdn,
    required String login,
    required String apiKey,
  });
  
  Future<Either<Failure, void>> signOut();
  
  Future<Either<Failure, User?>> getCurrentUser();
  
  Future<Either<Failure, bool>> isAuthenticated();
}