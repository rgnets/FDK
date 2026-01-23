import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/core/services/image_upload_event_bus.dart';

void main() {
  late ImageUploadEventBus eventBus;

  setUp(() {
    // Reset singleton for each test
    ImageUploadEventBus.resetForTesting();
    eventBus = ImageUploadEventBus();
  });

  tearDown(() {
    eventBus.dispose();
  });

  group('ImageUploadEventBus', () {
    group('singleton pattern', () {
      test('should return same instance', () {
        final instance1 = ImageUploadEventBus();
        final instance2 = ImageUploadEventBus();

        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('imageUploaded stream', () {
      test('should emit ImageUploadEvent when notifyImageUploaded is called',
          () async {
        final events = <ImageUploadEvent>[];
        final subscription = eventBus.imageUploaded.listen(events.add);

        eventBus.notifyImageUploaded(
          deviceType: 'access_point',
          deviceId: 'ap_123',
          roomId: 'room_1',
          newImageCount: 2,
        );

        await Future.delayed(const Duration(milliseconds: 10));

        expect(events.length, equals(1));
        expect(events[0].deviceType, equals('access_point'));
        expect(events[0].deviceId, equals('ap_123'));
        expect(events[0].roomId, equals('room_1'));
        expect(events[0].newImageCount, equals(2));
        expect(events[0].timestamp, isNotNull);

        await subscription.cancel();
      });

      test('should support multiple listeners', () async {
        final events1 = <ImageUploadEvent>[];
        final events2 = <ImageUploadEvent>[];

        final subscription1 = eventBus.imageUploaded.listen(events1.add);
        final subscription2 = eventBus.imageUploaded.listen(events2.add);

        eventBus.notifyImageUploaded(
          deviceType: 'ont',
          deviceId: 'ont_456',
          roomId: 'room_2',
          newImageCount: 1,
        );

        await Future.delayed(const Duration(milliseconds: 10));

        expect(events1.length, equals(1));
        expect(events2.length, equals(1));
        expect(events1[0].deviceId, equals('ont_456'));
        expect(events2[0].deviceId, equals('ont_456'));

        await subscription1.cancel();
        await subscription2.cancel();
      });

      test('should handle null roomId', () async {
        final events = <ImageUploadEvent>[];
        final subscription = eventBus.imageUploaded.listen(events.add);

        eventBus.notifyImageUploaded(
          deviceType: 'switch',
          deviceId: 'sw_789',
          roomId: null,
          newImageCount: 3,
        );

        await Future.delayed(const Duration(milliseconds: 10));

        expect(events.length, equals(1));
        expect(events[0].roomId, isNull);

        await subscription.cancel();
      });
    });

    group('cacheInvalidated stream', () {
      test('should emit CacheInvalidationEvent when notifyCacheInvalidated is called',
          () async {
        final events = <CacheInvalidationEvent>[];
        final subscription = eventBus.cacheInvalidated.listen(events.add);

        eventBus.notifyCacheInvalidated(
          deviceType: 'access_point',
          deviceId: 'ap_123',
        );

        await Future.delayed(const Duration(milliseconds: 10));

        expect(events.length, equals(1));
        expect(events[0].deviceType, equals('access_point'));
        expect(events[0].deviceId, equals('ap_123'));
        expect(events[0].timestamp, isNotNull);

        await subscription.cancel();
      });
    });

    group('uploadProgress stream', () {
      test('should emit UploadProgressEvent when notifyUploadProgress is called',
          () async {
        final events = <UploadProgressEvent>[];
        final subscription = eventBus.uploadProgress.listen(events.add);

        eventBus.notifyUploadProgress(
          deviceId: 'ap_123',
          current: 1,
          total: 3,
          status: UploadStatus.uploading,
        );

        await Future.delayed(const Duration(milliseconds: 10));

        expect(events.length, equals(1));
        expect(events[0].deviceId, equals('ap_123'));
        expect(events[0].current, equals(1));
        expect(events[0].total, equals(3));
        expect(events[0].status, equals(UploadStatus.uploading));

        await subscription.cancel();
      });

      test('should track progress updates', () async {
        final events = <UploadProgressEvent>[];
        final subscription = eventBus.uploadProgress.listen(events.add);

        eventBus.notifyUploadProgress(
          deviceId: 'ap_123',
          current: 0,
          total: 3,
          status: UploadStatus.uploading,
        );

        eventBus.notifyUploadProgress(
          deviceId: 'ap_123',
          current: 1,
          total: 3,
          status: UploadStatus.uploading,
        );

        eventBus.notifyUploadProgress(
          deviceId: 'ap_123',
          current: 3,
          total: 3,
          status: UploadStatus.completed,
        );

        await Future.delayed(const Duration(milliseconds: 10));

        expect(events.length, equals(3));
        expect(events[2].status, equals(UploadStatus.completed));

        await subscription.cancel();
      });
    });

    group('event history', () {
      test('should track recent events', () {
        eventBus.notifyImageUploaded(
          deviceType: 'ap',
          deviceId: 'ap_1',
          roomId: null,
          newImageCount: 1,
        );

        eventBus.notifyCacheInvalidated(
          deviceType: 'ap',
          deviceId: 'ap_1',
        );

        expect(eventBus.recentEvents.length, equals(2));
      });

      test('should maintain max 20 events', () {
        for (var i = 0; i < 25; i++) {
          eventBus.notifyImageUploaded(
            deviceType: 'ap',
            deviceId: 'ap_$i',
            roomId: null,
            newImageCount: 1,
          );
        }

        expect(eventBus.recentEvents.length, equals(20));
      });

      test('clearHistory should remove all events', () {
        for (var i = 0; i < 5; i++) {
          eventBus.notifyImageUploaded(
            deviceType: 'ap',
            deviceId: 'ap_$i',
            roomId: null,
            newImageCount: 1,
          );
        }

        eventBus.clearHistory();

        expect(eventBus.recentEvents.length, equals(0));
      });
    });

    group('getStats', () {
      test('should return event statistics', () {
        eventBus.notifyImageUploaded(
          deviceType: 'ap',
          deviceId: 'ap_1',
          roomId: null,
          newImageCount: 1,
        );

        eventBus.notifyImageUploaded(
          deviceType: 'ont',
          deviceId: 'ont_1',
          roomId: null,
          newImageCount: 2,
        );

        eventBus.notifyCacheInvalidated(
          deviceType: 'ap',
          deviceId: 'ap_1',
        );

        final stats = eventBus.getStats();

        expect(stats['totalEvents'], equals(3));
        expect(stats['eventTypes'], isA<Map>());
        expect(stats['oldestEvent'], isNotNull);
        expect(stats['newestEvent'], isNotNull);
      });
    });
  });

  group('ImageUploadEvent', () {
    test('toString should return readable representation', () {
      final event = ImageUploadEvent(
        deviceType: 'access_point',
        deviceId: 'ap_123',
        roomId: 'room_1',
        newImageCount: 2,
        timestamp: DateTime.now(),
      );

      final str = event.toString();
      expect(str, contains('ImageUploadEvent'));
      expect(str, contains('access_point'));
      expect(str, contains('ap_123'));
    });
  });

  group('CacheInvalidationEvent', () {
    test('toString should return readable representation', () {
      final event = CacheInvalidationEvent(
        deviceType: 'ont',
        deviceId: 'ont_456',
        timestamp: DateTime.now(),
      );

      final str = event.toString();
      expect(str, contains('CacheInvalidationEvent'));
      expect(str, contains('ont'));
    });
  });

  group('UploadStatus', () {
    test('should have all expected statuses', () {
      expect(UploadStatus.values.length, equals(4));
      expect(UploadStatus.values, contains(UploadStatus.pending));
      expect(UploadStatus.values, contains(UploadStatus.uploading));
      expect(UploadStatus.values, contains(UploadStatus.completed));
      expect(UploadStatus.values, contains(UploadStatus.failed));
    });
  });
}
