import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/auth/domain/repositories/auth_repository.dart';

final class SignOutUser extends UseCaseNoParams<void> {
  SignOutUser(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call() async {
    return repository.signOut();
  }
}