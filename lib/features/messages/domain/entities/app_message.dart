import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_message.freezed.dart';

/// Message types following ATT-FE-Tool patterns
enum MessageType {
  /// Transient messages that disappear quickly
  transient,

  /// Informational messages
  info,

  /// Success messages
  success,

  /// Warning messages
  warning,

  /// Error messages
  error,

  /// Critical messages that persist and require attention
  critical,
}

/// Message categories for filtering and analytics
enum MessageCategory {
  /// Network-related messages
  network,

  /// Authentication-related messages
  authentication,

  /// Validation-related messages
  validation,

  /// Upload-related messages
  upload,

  /// System-related messages
  system,

  /// General/uncategorized messages
  general,
}

/// Message priority for queue management
enum MessagePriority {
  /// Low priority messages
  low,

  /// Normal priority messages
  normal,

  /// High priority messages
  high,

  /// Critical priority messages (always displayed)
  critical,
}

/// An action that can be performed on a message
@freezed
class MessageAction with _$MessageAction {
  const factory MessageAction({
    /// Display label for the action button
    required String label,

    /// Unique key identifying this action (used for callback lookup)
    required String actionKey,

    /// Optional data to pass to the action callback
    Map<String, dynamic>? data,
  }) = _MessageAction;

  const MessageAction._();
}

/// A message in the message center
@freezed
class AppMessage with _$AppMessage {
  const factory AppMessage({
    /// Unique identifier
    required String id,

    /// Message content
    required String content,

    /// Message type
    required MessageType type,

    /// Message category
    required MessageCategory category,

    /// Message priority
    required MessagePriority priority,

    /// When the message was created
    required DateTime timestamp,

    /// Whether the message has been read
    @Default(false) bool isRead,

    /// Whether the message has been dismissed
    @Default(false) bool isDismissed,

    /// Optional action for the message
    MessageAction? action,

    /// Source context (where the message originated)
    String? sourceContext,

    /// Deduplication key (messages with same key within window are deduplicated)
    String? deduplicationKey,

    /// Additional metadata
    Map<String, dynamic>? metadata,
  }) = _AppMessage;

  const AppMessage._();

  /// Calculate display duration based on message type
  Duration get displayDuration => switch (type) {
        MessageType.transient => const Duration(seconds: 1),
        MessageType.info => const Duration(seconds: 2),
        MessageType.success => const Duration(seconds: 2),
        MessageType.warning => const Duration(seconds: 3),
        MessageType.error => const Duration(seconds: 4),
        MessageType.critical => const Duration(seconds: 5),
      };

  /// Whether this message should be persisted
  bool get shouldPersist =>
      type == MessageType.critical || type == MessageType.error;
}
