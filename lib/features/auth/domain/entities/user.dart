import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

@freezed
class User with _$User {
  const factory User({
    required String username,
    required String apiUrl,
    String? displayName,
    String? email,
  }) = _User;
}