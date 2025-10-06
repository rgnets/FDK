import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:rgnets_fdk/features/auth/domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String username,
    @JsonKey(name: 'api_url') required String apiUrl,
    @JsonKey(name: 'display_name') String? displayName,
    String? email,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

extension UserModelX on UserModel {
  User toEntity() {
    return User(
      username: username,
      apiUrl: apiUrl,
      displayName: displayName,
      email: email,
    );
  }
}

