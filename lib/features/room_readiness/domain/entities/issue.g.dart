// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'issue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IssueImpl _$$IssueImplFromJson(Map<String, dynamic> json) => _$IssueImpl(
      id: json['id'] as String,
      code: json['code'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      severity: $enumDecode(_$IssueSeverityEnumMap, json['severity']),
      category: $enumDecode(_$IssueCategoryEnumMap, json['category']),
      detectedAt: DateTime.parse(json['detected_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      resolution: json['resolution'] as String?,
      isAutoDismissible: json['is_auto_dismissible'] as bool? ?? false,
      autoDismissAfter: json['auto_dismiss_after'] == null
          ? null
          : Duration(microseconds: (json['auto_dismiss_after'] as num).toInt()),
    );

Map<String, dynamic> _$$IssueImplToJson(_$IssueImpl instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'code': instance.code,
    'title': instance.title,
    'description': instance.description,
    'severity': _$IssueSeverityEnumMap[instance.severity]!,
    'category': _$IssueCategoryEnumMap[instance.category]!,
    'detected_at': instance.detectedAt.toIso8601String(),
    'metadata': instance.metadata,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('resolution', instance.resolution);
  val['is_auto_dismissible'] = instance.isAutoDismissible;
  writeNotNull('auto_dismiss_after', instance.autoDismissAfter?.inMicroseconds);
  return val;
}

const _$IssueSeverityEnumMap = {
  IssueSeverity.critical: 'critical',
  IssueSeverity.warning: 'warning',
  IssueSeverity.info: 'info',
};

const _$IssueCategoryEnumMap = {
  IssueCategory.connectivity: 'connectivity',
  IssueCategory.configuration: 'configuration',
  IssueCategory.performance: 'performance',
  IssueCategory.compliance: 'compliance',
  IssueCategory.maintenance: 'maintenance',
  IssueCategory.documentation: 'documentation',
  IssueCategory.onboarding: 'onboarding',
};
