import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/services/message_persistence_service.dart';
import 'package:rgnets_fdk/features/messages/domain/entities/app_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late MessagePersistenceService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    service = MessagePersistenceService(prefs);
  });

  group('MessagePersistenceService', () {
    group('persistMessage', () {
      test('should persist critical message', () async {
        final message = AppMessage(
          id: 'msg-1',
          content: 'Critical error occurred',
          type: MessageType.critical,
          category: MessageCategory.system,
          priority: MessagePriority.critical,
          timestamp: DateTime.now(),
        );

        await service.persistMessage(message);

        final loaded = await service.loadPersistedMessages();
        expect(loaded.length, equals(1));
        expect(loaded[0].content, equals('Critical error occurred'));
      });

      test('should persist error message', () async {
        final message = AppMessage(
          id: 'msg-1',
          content: 'Network error',
          type: MessageType.error,
          category: MessageCategory.network,
          priority: MessagePriority.high,
          timestamp: DateTime.now(),
        );

        await service.persistMessage(message);

        final loaded = await service.loadPersistedMessages();
        expect(loaded.length, equals(1));
      });

      test('should not persist info message', () async {
        final message = AppMessage(
          id: 'msg-1',
          content: 'Info message',
          type: MessageType.info,
          category: MessageCategory.general,
          priority: MessagePriority.normal,
          timestamp: DateTime.now(),
        );

        await service.persistMessage(message);

        final loaded = await service.loadPersistedMessages();
        expect(loaded.isEmpty, isTrue);
      });

      test('should limit persisted messages to max', () async {
        for (var i = 0; i < 15; i++) {
          final message = AppMessage(
            id: 'msg-$i',
            content: 'Error $i',
            type: MessageType.error,
            category: MessageCategory.system,
            priority: MessagePriority.high,
            timestamp: DateTime.now(),
          );
          await service.persistMessage(message);
        }

        final loaded = await service.loadPersistedMessages();
        expect(loaded.length, equals(MessagePersistenceService.maxPersistedMessages));
      });

      test('should track last error', () async {
        final message = AppMessage(
          id: 'msg-1',
          content: 'Last error message',
          type: MessageType.error,
          category: MessageCategory.network,
          priority: MessagePriority.high,
          timestamp: DateTime(2024, 1, 1, 10, 0, 0),
        );

        await service.persistMessage(message);

        expect(service.getLastError(), equals('Last error message'));
        expect(service.getLastErrorTime(), isNotNull);
      });

      test('should persist message with action', () async {
        final message = AppMessage(
          id: 'msg-1',
          content: 'Error with action',
          type: MessageType.error,
          category: MessageCategory.network,
          priority: MessagePriority.high,
          timestamp: DateTime.now(),
          action: const MessageAction(
            label: 'Retry',
            actionKey: 'retry_network',
            data: {'attempt': 1},
          ),
        );

        await service.persistMessage(message);

        final loaded = await service.loadPersistedMessages();
        expect(loaded[0].action, isNotNull);
        expect(loaded[0].action!.label, equals('Retry'));
        expect(loaded[0].action!.actionKey, equals('retry_network'));
        expect(loaded[0].action!.data, equals({'attempt': 1}));
      });
    });

    group('loadPersistedMessages', () {
      test('should return empty list when no messages', () async {
        final loaded = await service.loadPersistedMessages();
        expect(loaded.isEmpty, isTrue);
      });

      test('should filter out expired messages', () async {
        // Manually set an expired message in storage
        SharedPreferences.setMockInitialValues({
          'persisted_messages':
              '[{"id":"old-msg","content":"Old message","type":"error","category":"system","priority":"high","timestamp":"2020-01-01T00:00:00.000","isRead":false,"isDismissed":false}]',
        });
        final prefs = await SharedPreferences.getInstance();
        final serviceWithOldMessages = MessagePersistenceService(prefs);

        final loaded = await serviceWithOldMessages.loadPersistedMessages();
        expect(loaded.isEmpty, isTrue); // Old message should be filtered out
      });

      test('should preserve message properties', () async {
        final message = AppMessage(
          id: 'msg-full',
          content: 'Full message',
          type: MessageType.critical,
          category: MessageCategory.authentication,
          priority: MessagePriority.critical,
          timestamp: DateTime.now(),
          isRead: true,
          isDismissed: false,
          sourceContext: 'auth_service',
          deduplicationKey: 'auth_error_123',
          metadata: {'userId': 'user-1'},
        );

        await service.persistMessage(message);

        final loaded = await service.loadPersistedMessages();
        final loadedMessage = loaded[0];

        expect(loadedMessage.id, equals('msg-full'));
        expect(loadedMessage.content, equals('Full message'));
        expect(loadedMessage.type, equals(MessageType.critical));
        expect(loadedMessage.category, equals(MessageCategory.authentication));
        expect(loadedMessage.priority, equals(MessagePriority.critical));
        expect(loadedMessage.isRead, isTrue);
        expect(loadedMessage.sourceContext, equals('auth_service'));
        expect(loadedMessage.deduplicationKey, equals('auth_error_123'));
      });
    });

    group('clearPersistedMessages', () {
      test('should clear all persisted messages', () async {
        final message = AppMessage(
          id: 'msg-1',
          content: 'Error to clear',
          type: MessageType.error,
          category: MessageCategory.system,
          priority: MessagePriority.high,
          timestamp: DateTime.now(),
        );

        await service.persistMessage(message);
        await service.clearPersistedMessages();

        final loaded = await service.loadPersistedMessages();
        expect(loaded.isEmpty, isTrue);
        expect(service.getLastError(), isNull);
        expect(service.getLastErrorTime(), isNull);
      });
    });

    group('crash detection', () {
      test('should mark app start as potential crash', () async {
        await service.markAppStart();

        // App start should mark as unclean shutdown
        expect(service.didCrashRecently(), isTrue);
      });

      test('should mark clean shutdown', () async {
        await service.markAppStart();
        await service.markCleanShutdown();

        expect(service.didCrashRecently(), isFalse);
      });

      test('should detect recent crash within window', () async {
        // Simulate an unclean shutdown
        SharedPreferences.setMockInitialValues({
          'clean_shutdown': false,
          'last_shutdown_time': DateTime.now()
              .subtract(const Duration(minutes: 2))
              .toIso8601String(),
        });
        final prefs = await SharedPreferences.getInstance();
        final serviceWithCrash = MessagePersistenceService(prefs);

        expect(serviceWithCrash.didCrashRecently(), isTrue);
      });

      test('should not detect crash outside window', () async {
        // Simulate an old unclean shutdown
        SharedPreferences.setMockInitialValues({
          'clean_shutdown': false,
          'last_shutdown_time': DateTime.now()
              .subtract(const Duration(minutes: 10))
              .toIso8601String(),
        });
        final prefs = await SharedPreferences.getInstance();
        final serviceWithOldCrash = MessagePersistenceService(prefs);

        expect(serviceWithOldCrash.didCrashRecently(), isFalse);
      });
    });

    group('cleanupAfterNormalShutdown', () {
      test('should clear message list but keep last error', () async {
        final message = AppMessage(
          id: 'msg-1',
          content: 'Error before shutdown',
          type: MessageType.error,
          category: MessageCategory.system,
          priority: MessagePriority.high,
          timestamp: DateTime.now(),
        );

        await service.persistMessage(message);
        await service.cleanupAfterNormalShutdown();

        // Messages should be cleared
        final loaded = await service.loadPersistedMessages();
        expect(loaded.isEmpty, isTrue);

        // But last error should still be available (for debugging)
        expect(service.getLastError(), equals('Error before shutdown'));
      });
    });

    group('error handling', () {
      test('should handle corrupted JSON gracefully', () async {
        SharedPreferences.setMockInitialValues({
          'persisted_messages': 'invalid json {{{',
        });
        final prefs = await SharedPreferences.getInstance();
        final serviceWithBadData = MessagePersistenceService(prefs);

        final loaded = await serviceWithBadData.loadPersistedMessages();
        expect(loaded.isEmpty, isTrue);
      });

      test('should handle malformed message gracefully', () async {
        SharedPreferences.setMockInitialValues({
          'persisted_messages': '[{"invalid":"message"}]',
        });
        final prefs = await SharedPreferences.getInstance();
        final serviceWithBadMessage = MessagePersistenceService(prefs);

        final loaded = await serviceWithBadMessage.loadPersistedMessages();
        expect(loaded.isEmpty, isTrue);
      });
    });
  });
}
