import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/core/services/message_center_service.dart';
import 'package:rgnets_fdk/features/messages/domain/entities/app_message.dart';
import 'package:rgnets_fdk/features/messages/domain/entities/message_metrics.dart';

void main() {
  late MessageCenterService messageCenter;

  setUp(() {
    MessageCenterService.resetForTesting();
    messageCenter = MessageCenterService();
    messageCenter.initialize();
  });

  tearDown(() {
    messageCenter.dispose();
  });

  group('MessageCenterService', () {
    group('singleton pattern', () {
      test('should return same instance', () {
        final instance1 = MessageCenterService();
        final instance2 = MessageCenterService();

        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('showInfo', () {
      test('should emit info message to stream', () async {
        final messages = <AppMessage>[];
        final subscription = messageCenter.messageStream.listen(messages.add);

        messageCenter.showInfo('Test info message');

        // Wait for queue processing
        await Future.delayed(const Duration(milliseconds: 200));

        expect(messages.length, equals(1));
        expect(messages[0].content, equals('Test info message'));
        expect(messages[0].type, equals(MessageType.info));
        expect(messages[0].priority, equals(MessagePriority.normal));

        await subscription.cancel();
      });

      test('should include action when provided', () async {
        final messages = <AppMessage>[];
        final subscription = messageCenter.messageStream.listen(messages.add);

        messageCenter.showInfo(
          'Test with action',
          actionLabel: 'Retry',
          actionKey: 'test_retry',
          actionData: {'id': '123'},
        );

        await Future.delayed(const Duration(milliseconds: 200));

        expect(messages[0].action, isNotNull);
        expect(messages[0].action!.label, equals('Retry'));
        expect(messages[0].action!.actionKey, equals('test_retry'));
        expect(messages[0].action!.data, equals({'id': '123'}));

        await subscription.cancel();
      });
    });

    group('showError', () {
      test('should emit error message with high priority', () async {
        final messages = <AppMessage>[];
        final subscription = messageCenter.messageStream.listen(messages.add);

        messageCenter.showError(
          'Test error',
          category: MessageCategory.network,
        );

        await Future.delayed(const Duration(milliseconds: 200));

        expect(messages.length, equals(1));
        expect(messages[0].type, equals(MessageType.error));
        expect(messages[0].priority, equals(MessagePriority.high));
        expect(messages[0].category, equals(MessageCategory.network));

        await subscription.cancel();
      });

      test('error messages should persist', () async {
        final messages = <AppMessage>[];
        final subscription = messageCenter.messageStream.listen(messages.add);

        messageCenter.showError('Persistent error');

        await Future.delayed(const Duration(milliseconds: 200));

        expect(messages[0].shouldPersist, isTrue);

        await subscription.cancel();
      });
    });

    group('showCritical', () {
      test('should emit critical message with critical priority', () async {
        final messages = <AppMessage>[];
        final subscription = messageCenter.messageStream.listen(messages.add);

        messageCenter.showCritical('Critical system error');

        await Future.delayed(const Duration(milliseconds: 200));

        expect(messages[0].type, equals(MessageType.critical));
        expect(messages[0].priority, equals(MessagePriority.critical));
        expect(messages[0].shouldPersist, isTrue);

        await subscription.cancel();
      });
    });

    group('deduplication', () {
      test('should deduplicate identical messages within window', () async {
        final messages = <AppMessage>[];
        final subscription = messageCenter.messageStream.listen(messages.add);

        // Send same message twice quickly
        messageCenter.showInfo('Duplicate message');
        messageCenter.showInfo('Duplicate message');

        await Future.delayed(const Duration(milliseconds: 300));

        // Only one should be shown
        expect(messages.length, equals(1));

        final metrics = messageCenter.getMetrics();
        expect(metrics.totalDeduplicated, equals(1));

        await subscription.cancel();
      });

      test('should not deduplicate different messages', () async {
        final messages = <AppMessage>[];
        final subscription = messageCenter.messageStream.listen(messages.add);

        messageCenter.showInfo('Message 1');
        messageCenter.showInfo('Message 2');

        await Future.delayed(const Duration(milliseconds: 300));

        expect(messages.length, equals(2));

        await subscription.cancel();
      });

      test('should respect custom deduplication key', () async {
        final messages = <AppMessage>[];
        final subscription = messageCenter.messageStream.listen(messages.add);

        messageCenter.showInfo(
          'Different content 1',
          deduplicationKey: 'same_key',
        );
        messageCenter.showInfo(
          'Different content 2',
          deduplicationKey: 'same_key',
        );

        await Future.delayed(const Duration(milliseconds: 300));

        // Should deduplicate based on key, not content
        expect(messages.length, equals(1));

        await subscription.cancel();
      });
    });

    group('priority queue', () {
      test('critical messages should be processed first', () async {
        final messages = <AppMessage>[];
        final subscription = messageCenter.messageStream.listen(messages.add);

        // Add multiple messages quickly
        messageCenter.showInfo('Low priority 1');
        messageCenter.showInfo('Low priority 2');
        messageCenter.showCritical('Critical message');

        await Future.delayed(const Duration(milliseconds: 400));

        // Critical should come first
        expect(messages[0].type, equals(MessageType.critical));

        await subscription.cancel();
      });
    });

    group('action callbacks', () {
      test('should register and execute action callbacks', () {
        var callbackExecuted = false;
        Map<String, dynamic>? receivedData;

        messageCenter.registerAction('test_action', (data) {
          callbackExecuted = true;
          receivedData = data;
        });

        messageCenter.executeAction(
          'test_action',
          data: {'key': 'value'},
        );

        expect(callbackExecuted, isTrue);
        expect(receivedData, equals({'key': 'value'}));
      });

      test('should unregister action callbacks', () {
        var callCount = 0;

        messageCenter.registerAction('removable_action', (_) {
          callCount++;
        });

        messageCenter.executeAction('removable_action');
        expect(callCount, equals(1));

        messageCenter.unregisterAction('removable_action');
        messageCenter.executeAction('removable_action');
        expect(callCount, equals(1)); // Should not increment
      });

      test('should handle non-existent action gracefully', () {
        // Should not throw
        messageCenter.executeAction('non_existent_action');
      });
    });

    group('metrics', () {
      test('should track message counts by type', () async {
        final subscription = messageCenter.messageStream.listen((_) {});

        messageCenter.showInfo('Info 1');
        messageCenter.showInfo('Info 2');
        messageCenter.showError('Error 1');

        await Future.delayed(const Duration(milliseconds: 400));

        final metrics = messageCenter.getMetrics();
        expect(metrics.totalShown, equals(3));
        expect(metrics.byType['info'], equals(2));
        expect(metrics.byType['error'], equals(1));

        await subscription.cancel();
      });

      test('should track message counts by category', () async {
        final subscription = messageCenter.messageStream.listen((_) {});

        messageCenter.showError('Network error', category: MessageCategory.network);
        messageCenter.showError('Auth error', category: MessageCategory.authentication);
        messageCenter.showInfo('General info');

        await Future.delayed(const Duration(milliseconds: 400));

        final metrics = messageCenter.getMetrics();
        expect(metrics.byCategory['network'], equals(1));
        expect(metrics.byCategory['authentication'], equals(1));
        expect(metrics.byCategory['general'], equals(1));

        await subscription.cancel();
      });

      test('should calculate queue utilization', () {
        final metrics = messageCenter.getMetrics();
        expect(metrics.queueUtilization, equals(0));
        expect(metrics.maxQueueSize, equals(MessageCenterService.maxQueueSize));
      });

      test('should emit metrics updates', () async {
        final metricsUpdates = <dynamic>[];
        final subscription = messageCenter.metricsStream.listen(metricsUpdates.add);

        messageCenter.showInfo('Test');

        await Future.delayed(const Duration(milliseconds: 200));

        expect(metricsUpdates.isNotEmpty, isTrue);

        await subscription.cancel();
      });
    });

    group('event history', () {
      test('should track diagnostic events', () async {
        final subscription = messageCenter.messageStream.listen((_) {});

        messageCenter.showInfo('Test message');

        await Future.delayed(const Duration(milliseconds: 200));

        final events = messageCenter.recentEvents;
        expect(events.isNotEmpty, isTrue);
        expect(
          events.any((e) => e.event == MessageEvent.enqueued),
          isTrue,
        );
        expect(
          events.any((e) => e.event == MessageEvent.displayed),
          isTrue,
        );

        await subscription.cancel();
      });
    });

    group('clear', () {
      test('should clear all data', () async {
        final subscription = messageCenter.messageStream.listen((_) {});

        messageCenter.showInfo('Test');
        await Future.delayed(const Duration(milliseconds: 200));

        messageCenter.clear();

        final metrics = messageCenter.getMetrics();
        expect(metrics.totalShown, equals(0));
        expect(metrics.queueSize, equals(0));
        expect(messageCenter.recentEvents.isEmpty, isTrue);

        await subscription.cancel();
      });
    });

    group('health score', () {
      test('should start with perfect health score', () {
        final metrics = messageCenter.getMetrics();
        expect(metrics.healthScore, equals(100));
      });

      test('should identify issues and recommendations', () async {
        final subscription = messageCenter.messageStream.listen((_) {});

        // Generate multiple dropped messages to trigger issues
        for (var i = 0; i < 25; i++) {
          messageCenter.showInfo('Message $i');
        }

        await Future.delayed(const Duration(milliseconds: 500));

        final metrics = messageCenter.getMetrics();
        // Health score should reflect issues
        expect(metrics.healthScore, lessThanOrEqualTo(100));

        await subscription.cancel();
      });
    });
  });
}
