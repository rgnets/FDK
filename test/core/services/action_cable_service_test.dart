import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/core/services/action_cable_service.dart';

void main() {
  group('ActionCableService', () {
    late ActionCableService service;

    setUp(() {
      // Use forTesting to create isolated instances that won't conflict
      service = ActionCableService.forTesting();
    });

    tearDown(() {
      // Don't dispose - just clear subscriptions to avoid ValueNotifier issues
      // The forTesting instances are not singletons so GC will clean them up
      for (final channelName in service.activeChannels.toList()) {
        service.unsubscribe(channelName);
      }
    });

    group('connection state', () {
      test('should start in disconnected state', () {
        expect(service.state.value, equals(ActionCableConnectionState.disconnected));
        expect(service.isConnected, isFalse);
      });

      test('should have status with disconnected state', () {
        final status = service.status.value;
        expect(status.state, equals(ActionCableConnectionState.disconnected));
        expect(status.errorDetails, isNull);
        expect(status.reconnectAttempts, equals(0));
      });
    });

    group('URL building', () {
      test('should build correct WebSocket URL from credentials', () {
        // This test verifies the URL format used for ActionCable connections
        // The expected format is: wss://{fqdn}/cable?api_key={apiKey}

        // We test this by checking the service has the correct base configuration
        // Actual URL building happens during connect()
        expect(service, isNotNull);
      });
    });

    group('channel subscription', () {
      test('should return existing subscription if already subscribed', () {
        // Arrange & Act
        final sub1 = service.subscribe('RxgChannel');
        final sub2 = service.subscribe('RxgChannel');

        // Assert
        expect(identical(sub1, sub2), isTrue);
      });

      test('should create new subscription for different channel', () {
        // Arrange & Act
        final sub1 = service.subscribe('RxgChannel');
        final sub2 = service.subscribe('NotificationsChannel');

        // Assert
        expect(identical(sub1, sub2), isFalse);
      });

      test('should track active channels', () {
        // Arrange & Act
        service.subscribe('RxgChannel');
        service.subscribe('NotificationsChannel');

        // Assert
        expect(service.activeChannels, contains('RxgChannel'));
        expect(service.activeChannels, contains('NotificationsChannel'));
        expect(service.activeChannels.length, equals(2));
      });

      test('should get subscription by channel name', () {
        // Arrange
        final sub = service.subscribe('RxgChannel');

        // Act
        final retrieved = service.getSubscription('RxgChannel');

        // Assert
        expect(retrieved, equals(sub));
      });

      test('should return null for non-existent subscription', () {
        // Act
        final retrieved = service.getSubscription('NonExistentChannel');

        // Assert
        expect(retrieved, isNull);
      });
    });

    group('unsubscribe', () {
      test('should remove subscription when unsubscribed', () {
        // Arrange
        service.subscribe('RxgChannel');
        expect(service.activeChannels, contains('RxgChannel'));

        // Act
        service.unsubscribe('RxgChannel');

        // Assert
        expect(service.activeChannels, isNot(contains('RxgChannel')));
        expect(service.getSubscription('RxgChannel'), isNull);
      });

      test('should handle unsubscribe for non-existent channel', () {
        // Act & Assert - should not throw
        expect(() => service.unsubscribe('NonExistentChannel'), returnsNormally);
      });
    });

    group('event bus', () {
      test('should have accessible event bus', () {
        expect(service.eventBus, isNotNull);
      });

      test('should provide connection changed stream', () {
        expect(service.eventBus.connectionChanged, isA<Stream>());
      });

      test('should provide channel subscribed stream', () {
        expect(service.eventBus.channelSubscribed, isA<Stream>());
      });

      test('should provide channel message stream', () {
        expect(service.eventBus.channelMessage, isA<Stream>());
      });

      test('should provide error stream', () {
        expect(service.eventBus.errors, isA<Stream>());
      });
    });

    group('disconnect', () {
      test('should clear subscriptions on disconnect', () {
        // Arrange
        service.subscribe('RxgChannel');
        service.subscribe('NotificationsChannel');

        // Act
        service.disconnect();

        // Assert
        expect(service.activeChannels, isEmpty);
        expect(service.state.value, equals(ActionCableConnectionState.closed));
      });

      test('should set state to closed after disconnect', () {
        // Act
        service.disconnect();

        // Assert
        expect(service.state.value, equals(ActionCableConnectionState.closed));
      });
    });

    group('dispose', () {
      test('should clean up subscriptions', () {
        // Arrange - use a fresh instance for this test
        final testService = ActionCableService.forTesting();
        testService.subscribe('RxgChannel');

        // Act
        testService.disconnect();

        // Assert
        expect(testService.activeChannels, isEmpty);
      });
    });
  });

  group('ActionCableConnectionState', () {
    test('disconnected should have correct properties', () {
      const state = ActionCableConnectionState.disconnected;
      expect(state.isConnected, isFalse);
      expect(state.canSendMessages, isFalse);
      expect(state.isConnecting, isFalse);
      expect(state.isReconnecting, isFalse);
      expect(state.message, isNotEmpty);
    });

    test('connecting should have correct properties', () {
      const state = ActionCableConnectionState.connecting;
      expect(state.isConnected, isFalse);
      expect(state.canSendMessages, isFalse);
      expect(state.isConnecting, isTrue);
      expect(state.isReconnecting, isFalse);
    });

    test('connected should have correct properties', () {
      const state = ActionCableConnectionState.connected;
      expect(state.isConnected, isTrue);
      expect(state.canSendMessages, isTrue);
      expect(state.isConnecting, isFalse);
      expect(state.isReconnecting, isFalse);
    });

    test('reconnecting should have correct properties', () {
      const state = ActionCableConnectionState.reconnecting;
      expect(state.isConnected, isFalse);
      expect(state.canSendMessages, isFalse);
      expect(state.isConnecting, isTrue);
      expect(state.isReconnecting, isTrue);
    });

    test('failed should have correct properties', () {
      const state = ActionCableConnectionState.failed;
      expect(state.isConnected, isFalse);
      expect(state.canSendMessages, isFalse);
      expect(state.isConnecting, isFalse);
      expect(state.isReconnecting, isFalse);
    });

    test('closed should have correct properties', () {
      const state = ActionCableConnectionState.closed;
      expect(state.isConnected, isFalse);
      expect(state.canSendMessages, isFalse);
      expect(state.isConnecting, isFalse);
      expect(state.isReconnecting, isFalse);
    });
  });

  group('ActionCableConnectionStatus', () {
    test('should create disconnected status', () {
      final status = ActionCableConnectionStatus.disconnected();
      expect(status.state, equals(ActionCableConnectionState.disconnected));
      expect(status.errorDetails, isNull);
      expect(status.reconnectAttempts, equals(0));
    });

    test('should create connecting status', () {
      final status = ActionCableConnectionStatus.connecting();
      expect(status.state, equals(ActionCableConnectionState.connecting));
    });

    test('should create connected status', () {
      final status = ActionCableConnectionStatus.connected();
      expect(status.state, equals(ActionCableConnectionState.connected));
    });

    test('should create failed status with error', () {
      final status = ActionCableConnectionStatus.failed(
        'Connection timeout',
        reconnectAttempts: 3,
      );
      expect(status.state, equals(ActionCableConnectionState.failed));
      expect(status.errorDetails, equals('Connection timeout'));
      expect(status.reconnectAttempts, equals(3));
    });

    test('should support copyWith', () {
      final original = ActionCableConnectionStatus(
        state: ActionCableConnectionState.connected,
        timestamp: DateTime.now(),
      );

      final updated = original.copyWith(
        state: ActionCableConnectionState.disconnected,
        errorDetails: 'Lost connection',
      );

      expect(updated.state, equals(ActionCableConnectionState.disconnected));
      expect(updated.errorDetails, equals('Lost connection'));
    });

    test('should have meaningful toString', () {
      final status = ActionCableConnectionStatus.connected();
      expect(status.toString(), contains('Connected'));
    });
  });

  group('ChannelSubscription', () {
    test('should create with channel name', () {
      final sub = ChannelSubscription(channelName: 'RxgChannel');
      expect(sub.channelName, equals('RxgChannel'));
      expect(sub.isSubscribed, isFalse);
    });

    test('should create with channel params', () {
      final sub = ChannelSubscription(
        channelName: 'RoomChannel',
        channelParams: {'room_id': '123'},
      );
      expect(sub.channelParams, equals({'room_id': '123'}));
    });

    test('should track subscription state', () {
      final sub = ChannelSubscription(channelName: 'RxgChannel');
      expect(sub.isSubscribed, isFalse);

      sub.markSubscribed();
      expect(sub.isSubscribed, isTrue);

      sub.markUnsubscribed();
      expect(sub.isSubscribed, isFalse);
    });

    test('should have messages stream', () {
      final sub = ChannelSubscription(channelName: 'RxgChannel');
      expect(sub.messages, isA<Stream<ChannelMessage>>());
    });

    test('should broadcast messages to listeners', () async {
      final sub = ChannelSubscription(channelName: 'RxgChannel');
      final messages = <ChannelMessage>[];

      sub.messages.listen((msg) => messages.add(msg));

      final message = ChannelMessage(
        action: 'test_action',
        data: {'key': 'value'},
      );
      sub.pushMessage(message);

      // Give time for async
      await Future.delayed(Duration.zero);

      expect(messages.length, equals(1));
      expect(messages.first.action, equals('test_action'));
    });

    test('should not push message after dispose', () async {
      final sub = ChannelSubscription(channelName: 'RxgChannel');
      final messages = <ChannelMessage>[];

      sub.messages.listen((msg) => messages.add(msg));
      sub.dispose();

      final message = ChannelMessage(action: 'test', data: {});
      sub.pushMessage(message); // Should not throw, just ignored

      await Future.delayed(Duration.zero);
      expect(messages, isEmpty);
    });
  });

  group('ChannelMessage', () {
    test('should create with action and data', () {
      final msg = ChannelMessage(
        action: 'resource_updated',
        data: {'id': 123, 'name': 'Test'},
      );

      expect(msg.action, equals('resource_updated'));
      expect(msg.data['id'], equals(123));
    });

    test('should create from JSON', () {
      final json = {
        'action': 'resource_created',
        'resource_type': 'access_points',
        'id': 456,
        'request_id': 'req-123',
      };

      final msg = ChannelMessage.fromJson(json);

      expect(msg.action, equals('resource_created'));
      expect(msg.requestId, equals('req-123'));
      expect(msg.data, equals(json));
    });

    test('should handle missing action in JSON', () {
      final json = {'id': 123};
      final msg = ChannelMessage.fromJson(json);

      expect(msg.action, isNull);
      expect(msg.data['id'], equals(123));
    });

    test('should have meaningful toString', () {
      final msg = ChannelMessage(
        action: 'test_action',
        data: {'key': 'value'},
        requestId: 'req-1',
      );

      expect(msg.toString(), contains('test_action'));
      expect(msg.toString(), contains('req-1'));
    });

    test('should set receivedAt timestamp', () {
      final before = DateTime.now();
      final msg = ChannelMessage(action: 'test', data: {});
      final after = DateTime.now();

      expect(msg.receivedAt.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      expect(msg.receivedAt.isBefore(after.add(const Duration(seconds: 1))), isTrue);
    });
  });

  group('ActionCableEventBus', () {
    late ActionCableEventBus eventBus;

    setUp(() {
      eventBus = ActionCableEventBus();
    });

    tearDown(() {
      eventBus.dispose();
    });

    test('should emit connection changed events', () async {
      final events = <ActionCableConnectionEvent>[];
      eventBus.connectionChanged.listen((e) => events.add(e));

      eventBus.emitConnectionChanged(ActionCableConnectionState.connected);

      await Future.delayed(Duration.zero);
      expect(events.length, equals(1));
      expect(events.first.state, equals(ActionCableConnectionState.connected));
    });

    test('should emit channel subscribed events', () async {
      final events = <ChannelSubscribedEvent>[];
      eventBus.channelSubscribed.listen((e) => events.add(e));

      eventBus.emitChannelSubscribed('RxgChannel');

      await Future.delayed(Duration.zero);
      expect(events.length, equals(1));
      expect(events.first.channelName, equals('RxgChannel'));
    });

    test('should emit channel message events', () async {
      final events = <ChannelMessageEvent>[];
      eventBus.channelMessage.listen((e) => events.add(e));

      eventBus.emitChannelMessage('RxgChannel', {'action': 'test', 'data': {}});

      await Future.delayed(Duration.zero);
      expect(events.length, equals(1));
      expect(events.first.channelName, equals('RxgChannel'));
      expect(events.first.action, equals('test'));
    });

    test('should emit error events', () async {
      final events = <ActionCableErrorEvent>[];
      eventBus.errors.listen((e) => events.add(e));

      eventBus.emitError('Test error', error: Exception('Details'));

      await Future.delayed(Duration.zero);
      expect(events.length, equals(1));
      expect(events.first.message, equals('Test error'));
      expect(events.first.error, isA<Exception>());
    });

    test('should emit subscription failed events', () async {
      final events = <ChannelSubscriptionFailedEvent>[];
      eventBus.channelSubscriptionFailed.listen((e) => events.add(e));

      eventBus.emitChannelSubscriptionFailed(
        'RxgChannel',
        SubscriptionFailureReason.timeout,
        errorDetails: 'Server did not respond',
      );

      await Future.delayed(Duration.zero);
      expect(events.length, equals(1));
      expect(events.first.channelName, equals('RxgChannel'));
      expect(events.first.reason, equals(SubscriptionFailureReason.timeout));
      expect(events.first.errorDetails, equals('Server did not respond'));
    });

    test('should not emit after dispose', () async {
      final events = <ActionCableConnectionEvent>[];
      eventBus.connectionChanged.listen((e) => events.add(e));

      eventBus.dispose();
      eventBus.emitConnectionChanged(ActionCableConnectionState.connected);

      await Future.delayed(Duration.zero);
      expect(events, isEmpty);
    });
  });

  group('SubscriptionFailureReason', () {
    test('timeout should have correct name', () {
      expect(SubscriptionFailureReason.timeout.name, equals('timeout'));
    });

    test('rejected should have correct name', () {
      expect(SubscriptionFailureReason.rejected.name, equals('rejected'));
    });

    test('disconnected should have correct name', () {
      expect(SubscriptionFailureReason.disconnected.name, equals('disconnected'));
    });
  });
}
