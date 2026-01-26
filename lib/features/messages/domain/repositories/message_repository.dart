import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/messages/domain/entities/app_message.dart';
import 'package:rgnets_fdk/features/messages/domain/entities/message_metrics.dart';

/// Repository interface for message operations
abstract interface class MessageRepository {
  /// Get all messages with optional filtering
  Future<Either<Failure, List<AppMessage>>> getMessages({
    MessageType? type,
    MessageCategory? category,
    bool? unreadOnly,
    int? limit,
    int? offset,
  });

  /// Get a single message by ID
  Future<Either<Failure, AppMessage>> getMessage(String id);

  /// Add a new message
  Future<Either<Failure, AppMessage>> addMessage(AppMessage message);

  /// Mark a message as read
  Future<Either<Failure, void>> markAsRead(String id);

  /// Mark all messages as read
  Future<Either<Failure, void>> markAllAsRead();

  /// Dismiss a message
  Future<Either<Failure, void>> dismissMessage(String id);

  /// Delete a message
  Future<Either<Failure, void>> deleteMessage(String id);

  /// Clear all messages
  Future<Either<Failure, void>> clearMessages();

  /// Get message metrics
  Future<Either<Failure, MessageMetrics>> getMetrics();

  /// Get unread message count
  Future<Either<Failure, int>> getUnreadCount();

  /// Persist critical messages (for startup recovery)
  Future<Either<Failure, void>> persistCriticalMessages(
      List<AppMessage> messages);

  /// Load persisted critical messages
  Future<Either<Failure, List<AppMessage>>> loadPersistedMessages();

  /// Clear persisted messages
  Future<Either<Failure, void>> clearPersistedMessages();
}
