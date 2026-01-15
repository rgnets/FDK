import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/auth/domain/entities/user.dart';
import 'package:rgnets_fdk/features/auth/domain/repositories/auth_repository.dart';

final class AuthenticateUser extends UseCase<User, AuthenticateUserParams> {
  AuthenticateUser(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, User>> call(AuthenticateUserParams params) async {
    return repository.authenticate(
      fqdn: params.fqdn,
      login: params.login,
      token: params.token,
      siteName: params.siteName,
      issuedAt: params.issuedAt,
      signature: params.signature,
    );
  }
}

class AuthenticateUserParams extends Params {
  const AuthenticateUserParams({
    required this.fqdn,
    required this.login,
    required this.token,
    this.siteName,
    this.issuedAt,
    this.signature,
  });

  final String fqdn;
  final String login;
  final String token;
  final String? siteName;
  final DateTime? issuedAt;
  final String? signature;

  @override
  List<Object?> get props => [
    fqdn,
    login,
    token,
    siteName,
    issuedAt,
    signature,
  ];
}
