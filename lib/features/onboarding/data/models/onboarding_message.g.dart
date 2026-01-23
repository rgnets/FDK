// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OnboardingMessageImpl _$$OnboardingMessageImplFromJson(
        Map<String, dynamic> json) =>
    _$OnboardingMessageImpl(
      stage: (json['stage'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      resolution: json['resolution'] as String,
      typicalDurationMinutes:
          (json['typical_duration_minutes'] as num?)?.toInt(),
      isSuccess: json['is_success'] as bool? ?? false,
    );

Map<String, dynamic> _$$OnboardingMessageImplToJson(
    _$OnboardingMessageImpl instance) {
  final val = <String, dynamic>{
    'stage': instance.stage,
    'title': instance.title,
    'description': instance.description,
    'resolution': instance.resolution,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('typical_duration_minutes', instance.typicalDurationMinutes);
  val['is_success'] = instance.isSuccess;
  return val;
}
