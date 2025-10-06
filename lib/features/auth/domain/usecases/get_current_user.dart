import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/auth/domain/entities/user.dart';
import 'package:rgnets_fdk/features/auth/domain/repositories/auth_repository.dart';

final class GetCurrentUser extends UseCaseNoParams<User?> {
  GetCurrentUser(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, User?>> call() async {
    return repository.getCurrentUser();
  }
}