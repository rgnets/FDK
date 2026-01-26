// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageActionModelImpl _$$MessageActionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$MessageActionModelImpl(
      label: json['label'] as String,
      actionKey: json['action_key'] as String,
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$MessageActionModelImplToJson(
    _$MessageActionModelImpl instance) {
  final val = <String, dynamic>{
    'label': instance.label,
    'action_key': instance.actionKey,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('data', instance.data);
  return val;
}

_$MessageModelImpl _$$MessageModelImplFromJson(Map<String, dynamic> json) =>
    _$MessageModelImpl(
      id: json['id'] as String,
      content: json['content'] as String,
      type: json['type'] as String,
      category: json['category'] as String,
      priority: json['priority'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['is_read'] as bool? ?? false,
      isDismissed: json['is_dismissed'] as bool? ?? false,
      action: json['action'] == null
          ? null
          : MessageActionModel.fromJson(json['action'] as Map<String, dynamic>),
      sourceContext: json['source_context'] as String?,
      deduplicationKey: json['deduplication_key'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$MessageModelImplToJson(_$MessageModelImpl instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'content': instance.content,
    'type': instance.type,
    'category': instance.category,
    'priority': instance.priority,
    'timestamp': instance.timestamp.toIso8601String(),
    'is_read': instance.isRead,
    'is_dismissed': instance.isDismissed,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('action', instance.action?.toJson());
  writeNotNull('source_context', instance.sourceContext);
  writeNotNull('deduplication_key', instance.deduplicationKey);
  writeNotNull('metadata', instance.metadata);
  return val;
}
