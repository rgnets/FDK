import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rgnets_fdk/features/messages/domain/entities/app_message.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

/// Data model for message actions
@freezed
class MessageActionModel with _$MessageActionModel {
  const factory MessageActionModel({
    required String label,
    required String actionKey,
    Map<String, dynamic>? data,
  }) = _MessageActionModel;

  const MessageActionModel._();

  factory MessageActionModel.fromJson(Map<String, dynamic> json) =>
      _$MessageActionModelFromJson(json);

  factory MessageActionModel.fromEntity(MessageAction entity) {
    return MessageActionModel(
      label: entity.label,
      actionKey: entity.actionKey,
      data: entity.data,
    );
  }

  MessageAction toEntity() {
    return MessageAction(
      label: label,
      actionKey: actionKey,
      data: data,
    );
  }
}

/// Data model for messages with JSON serialization
@freezed
class MessageModel with _$MessageModel {
  const factory MessageModel({
    required String id,
    required String content,
    required String type,
    required String category,
    required String priority,
    required DateTime timestamp,
    @Default(false) bool isRead,
    @Default(false) bool isDismissed,
    MessageActionModel? action,
    String? sourceContext,
    String? deduplicationKey,
    Map<String, dynamic>? metadata,
  }) = _MessageModel;

  const MessageModel._();

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  factory MessageModel.fromEntity(AppMessage entity) {
    return MessageModel(
      id: entity.id,
      content: entity.content,
      type: entity.type.name,
      category: entity.category.name,
      priority: entity.priority.name,
      timestamp: entity.timestamp,
      isRead: entity.isRead,
      isDismissed: entity.isDismissed,
      action:
          entity.action != null ? MessageActionModel.fromEntity(entity.action!) : null,
      sourceContext: entity.sourceContext,
      deduplicationKey: entity.deduplicationKey,
      metadata: entity.metadata,
    );
  }

  AppMessage toEntity() {
    return AppMessage(
      id: id,
      content: content,
      type: MessageType.values.firstWhere(
        (e) => e.name == type,
        orElse: () => MessageType.info,
      ),
      category: MessageCategory.values.firstWhere(
        (e) => e.name == category,
        orElse: () => MessageCategory.general,
      ),
      priority: MessagePriority.values.firstWhere(
        (e) => e.name == priority,
        orElse: () => MessagePriority.normal,
      ),
      timestamp: timestamp,
      isRead: isRead,
      isDismissed: isDismissed,
      action: action?.toEntity(),
      sourceContext: sourceContext,
      deduplicationKey: deduplicationKey,
      metadata: metadata,
    );
  }
}
