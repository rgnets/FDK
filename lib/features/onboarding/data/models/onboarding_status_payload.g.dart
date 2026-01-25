// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_status_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OnboardingStatusPayloadImpl _$$OnboardingStatusPayloadImplFromJson(
        Map<String, dynamic> json) =>
    _$OnboardingStatusPayloadImpl(
      stage: (json['stage'] as num?)?.toInt(),
      maxStages: (json['max_stages'] as num?)?.toInt(),
      status: json['status'] as String?,
      stageDisplay: json['stage_display'] as String?,
      nextAction: json['next_action'] as String?,
      error: json['error'] as String?,
      lastUpdate: json['last_update'] == null
          ? null
          : DateTime.parse(json['last_update'] as String),
      lastSeenAt: json['last_seen_at'] == null
          ? null
          : DateTime.parse(json['last_seen_at'] as String),
      lastUpdateAgeSecs: (json['last_update_age_secs'] as num?)?.toInt(),
      onboardingComplete: json['onboarding_complete'] as bool?,
    );

Map<String, dynamic> _$$OnboardingStatusPayloadImplToJson(
    _$OnboardingStatusPayloadImpl instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('stage', instance.stage);
  writeNotNull('max_stages', instance.maxStages);
  writeNotNull('status', instance.status);
  writeNotNull('stage_display', instance.stageDisplay);
  writeNotNull('next_action', instance.nextAction);
  writeNotNull('error', instance.error);
  writeNotNull('last_update', instance.lastUpdate?.toIso8601String());
  writeNotNull('last_seen_at', instance.lastSeenAt?.toIso8601String());
  writeNotNull('last_update_age_secs', instance.lastUpdateAgeSecs);
  writeNotNull('onboarding_complete', instance.onboardingComplete);
  return val;
}
