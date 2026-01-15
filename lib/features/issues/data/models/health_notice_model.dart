import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:rgnets_fdk/features/issues/domain/entities/health_notice.dart';

part 'health_notice_model.freezed.dart';
part 'health_notice_model.g.dart';

@freezed
class HealthNoticeModel with _$HealthNoticeModel {
  const factory HealthNoticeModel({
    required int id,
    required String name,
    required String severity,
    @JsonKey(name: 'short_message') required String shortMessage,
    @JsonKey(name: 'created_at') required DateTime createdAt, @JsonKey(name: 'long_message') String? longMessage,
    @JsonKey(name: 'cured_at') DateTime? curedAt,
    @JsonKey(name: 'device_id') String? deviceId,
    @JsonKey(name: 'device_name') String? deviceName,
    @JsonKey(name: 'room_name') String? roomName,
  }) = _HealthNoticeModel;

  factory HealthNoticeModel.fromJson(Map<String, dynamic> json) =>
      _$HealthNoticeModelFromJson(json);
}

extension HealthNoticeModelX on HealthNoticeModel {
  HealthNotice toEntity() {
    return HealthNotice(
      id: id,
      name: name,
      severity: HealthNoticeSeverity.fromString(severity),
      shortMessage: shortMessage,
      longMessage: longMessage,
      createdAt: createdAt,
      curedAt: curedAt,
      deviceId: deviceId,
      deviceName: deviceName,
      roomName: roomName,
    );
  }
}
