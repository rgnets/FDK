import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rgnets_fdk/features/auth/domain/entities/user.dart';

part 'auth_status.freezed.dart';

@freezed
class AuthStatus with _$AuthStatus {
  const factory AuthStatus.unauthenticated() = _Unauthenticated;
  const factory AuthStatus.authenticating() = _Authenticating;
  const factory AuthStatus.authenticated(User user) = _Authenticated;
  const factory AuthStatus.failure(String message) = _AuthFailure;

  const AuthStatus._();

  bool get isAuthenticated => this is _Authenticated;
  bool get isUnauthenticated => this is _Unauthenticated;
  bool get isAuthenticating => this is _Authenticating;
  bool get isFailure => this is _AuthFailure;

  User? get user {
    return when(
      unauthenticated: () => null,
      authenticating: () => null,
      authenticated: (user) => user,
      failure: (_) => null,
    );
  }
}