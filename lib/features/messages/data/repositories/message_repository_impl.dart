import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/services/message_center_service.dart';
import 'package:rgnets_fdk/core/services/message_persistence_service.dart';
import 'package:rgnets_fdk/features/messages/data/datasources/message_local_data_source.dart';
import 'package:rgnets_fdk/features/messages/data/models/message_model.dart';
import 'package:rgnets_fdk/features/messages/domain/entities/app_message.dart';
import 'package:rgnets_fdk/features/messages/domain/entities/message_metrics.dart';
import 'package:rgnets_fdk/features/messages/domain/repositories/message_repository.dart';

/// Implementation of MessageRepository
class MessageRepositoryImpl implements MessageRepository {
  MessageRepositoryImpl({
    required this.localDataSource,
    required this.persistenceService,
    required this.messageCenterService,
  });

  final MessageLocalDataSource localDataSource;
  final MessagePersistenceService persistenceService;
  final MessageCenterService messageCenterService;

  @override
  Future<Either<Failure, List<AppMessage>>> getMessages({
    MessageType? type,
    MessageCategory? category,
    bool? unreadOnly,
    int? limit,
    int? offset,
  }) async {
    try {
      var messages = await localDataSource.getMessages();
      var entities = messages.map((m) => m.toEntity()).toList();

      // Apply filters
      if (type != null) {
        entities = entities.where((m) => m.type == type).toList();
      }
      if (category != null) {
        entities = entities.where((m) => m.category == category).toList();
      }
      if (unreadOnly == true) {
        entities = entities.where((m) => !m.isRead).toList();
      }

      // Sort by timestamp descending (newest first)
      entities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Apply pagination
      if (offset != null && offset > 0) {
        entities = entities.skip(offset).toList();
      }
      if (limit != null && limit > 0) {
        entities = entities.take(limit).toList();
      }

      return Right(entities);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get messages: $e'));
    }
  }

  @override
  Future<Either<Failure, AppMessage>> getMessage(String id) async {
    try {
      final messages = await localDataSource.getMessages();
      final message = messages.firstWhere(
        (m) => m.id == id,
        orElse: () => throw Exception('Message not found'),
      );
      return Right(message.toEntity());
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get message: $e'));
    }
  }

  @override
  Future<Either<Failure, AppMessage>> addMessage(AppMessage message) async {
    try {
      final model = MessageModel.fromEntity(message);
      await localDataSource.addMessage(model);

      // Persist critical messages
      if (message.shouldPersist) {
        await persistenceService.persistMessage(message);
      }

      return Right(message);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to add message: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String id) async {
    try {
      final messages = await localDataSource.getMessages();
      final index = messages.indexWhere((m) => m.id == id);
      if (index != -1) {
        final updated = messages[index].copyWith(isRead: true);
        await localDataSource.updateMessage(updated);
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to mark as read: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      final messages = await localDataSource.getMessages();
      final updatedMessages =
          messages.map((m) => m.copyWith(isRead: true)).toList();
      await localDataSource.saveMessages(updatedMessages);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to mark all as read: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> dismissMessage(String id) async {
    try {
      final messages = await localDataSource.getMessages();
      final index = messages.indexWhere((m) => m.id == id);
      if (index != -1) {
        final updated = messages[index].copyWith(isDismissed: true);
        await localDataSource.updateMessage(updated);
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to dismiss message: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMessage(String id) async {
    try {
      await localDataSource.deleteMessage(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to delete message: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearMessages() async {
    try {
      await localDataSource.clearMessages();
      messageCenterService.clear();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to clear messages: $e'));
    }
  }

  @override
  Future<Either<Failure, MessageMetrics>> getMetrics() async {
    try {
      final metrics = messageCenterService.getMetrics();
      return Right(metrics);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get metrics: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final messages = await localDataSource.getMessages();
      final unreadCount = messages.where((m) => !m.isRead).length;
      return Right(unreadCount);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get unread count: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> persistCriticalMessages(
      List<AppMessage> messages) async {
    try {
      for (final message in messages) {
        await persistenceService.persistMessage(message);
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to persist messages: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AppMessage>>> loadPersistedMessages() async {
    try {
      final messages = await persistenceService.loadPersistedMessages();
      return Right(messages);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to load persisted messages: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearPersistedMessages() async {
    try {
      await persistenceService.clearPersistedMessages();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to clear persisted messages: $e'));
    }
  }
}
