import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_attempt.freezed.dart';
part 'auth_attempt.g.dart';

@freezed
class AuthAttempt with _$AuthAttempt {
  const factory AuthAttempt({
    required DateTime timestamp,
    @Default('') String fqdn,
    @Default('') String login,
    @Default(false) bool success,
    String? siteName,
    String? message,
  }) = _AuthAttempt;

  factory AuthAttempt.fromJson(Map<String, dynamic> json) =>
      _$AuthAttemptFromJson(json);
}
