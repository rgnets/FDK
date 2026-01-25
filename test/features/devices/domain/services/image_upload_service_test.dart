import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/core/services/image_upload_event_bus.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/image_upload_state.dart';
import 'package:rgnets_fdk/features/devices/domain/services/image_processor.dart';
import 'package:rgnets_fdk/features/devices/domain/services/image_upload_service.dart';
import 'package:rgnets_fdk/features/devices/domain/services/image_upload_verifier.dart';

void main() {
  late ImageUploadEventBus eventBus;

  setUp(() {
    ImageUploadEventBus.resetForTesting();
    eventBus = ImageUploadEventBus();
  });

  tearDown(() {
    eventBus.dispose();
  });

  group('ImageUploadService', () {
    group('uploadImages', () {
      test('should upload images and return success result', () async {
        var uploadCalled = false;
        String? uploadedResourceType;
        Map<String, dynamic>? uploadedParams;

        final service = ImageUploadService(
          uploadCallback: (resourceType, deviceId, params) async {
            uploadCalled = true;
            uploadedResourceType = resourceType;
            uploadedParams = params;
            return {'success': true, 'data': {'id': 123}};
          },
          verifier: ImageUploadVerifier(
            fetchImagesCallback: (deviceType, deviceId) async {
              return ['image1.jpg', 'image2.jpg', 'image3.jpg'];
            },
            initialDelay: const Duration(milliseconds: 10),
            betweenAttempts: const Duration(milliseconds: 10),
            maxTotalWaitTime: const Duration(seconds: 5),
          ),
          eventBus: eventBus,
        );

        final images = [
          ProcessedImage(
            bytes: Uint8List.fromList([1, 2, 3]),
            base64Data: 'data:image/jpeg;base64,AQID',
            fileName: 'test.jpg',
            sizeBytes: 3,
          ),
        ];

        final result = await service.uploadImages(
          deviceType: 'access_point',
          deviceId: 'ap_123',
          roomId: 'room_1',
          images: images,
          existingImages: ['image1.jpg', 'image2.jpg'],
        );

        expect(uploadCalled, isTrue);
        expect(uploadedResourceType, equals('access_points'));
        expect(uploadedParams, isNotNull);
        expect(result.success, isTrue);
        expect(result.verificationResult, equals(VerificationResult.success));
        expect(result.uploadedCount, equals(1));
      });

      test('should convert device types to resource types correctly', () async {
        final testCases = {
          'access_point': 'access_points',
          'ap': 'access_points',
          'ont': 'media_converters',
          'media_converter': 'media_converters',
          'switch': 'switch_devices',
        };

        for (final entry in testCases.entries) {
          String? capturedResourceType;

          final service = ImageUploadService(
            uploadCallback: (resourceType, deviceId, params) async {
              capturedResourceType = resourceType;
              return {'success': true};
            },
            verifier: ImageUploadVerifier(
              fetchImagesCallback: (deviceType, deviceId) async => ['img.jpg'],
              initialDelay: const Duration(milliseconds: 1),
              betweenAttempts: const Duration(milliseconds: 1),
              maxTotalWaitTime: const Duration(milliseconds: 100),
            ),
            eventBus: eventBus,
          );

          await service.uploadImages(
            deviceType: entry.key,
            deviceId: '${entry.key}_1',
            roomId: null,
            images: [
              ProcessedImage(
                bytes: Uint8List(1),
                base64Data: 'data:image/jpeg;base64,AA==',
                fileName: 'test.jpg',
                sizeBytes: 1,
              ),
            ],
            existingImages: [],
          );

          expect(
            capturedResourceType,
            equals(entry.value),
            reason: 'Device type ${entry.key} should map to ${entry.value}',
          );
        }
      });

      test('should extract raw ID from prefixed device ID', () async {
        String? capturedDeviceId;

        final service = ImageUploadService(
          uploadCallback: (resourceType, deviceId, params) async {
            capturedDeviceId = deviceId;
            return {'success': true};
          },
          verifier: ImageUploadVerifier(
            fetchImagesCallback: (deviceType, deviceId) async => ['img.jpg'],
            initialDelay: const Duration(milliseconds: 1),
            betweenAttempts: const Duration(milliseconds: 1),
            maxTotalWaitTime: const Duration(milliseconds: 100),
          ),
          eventBus: eventBus,
        );

        await service.uploadImages(
          deviceType: 'access_point',
          deviceId: 'ap_456',
          roomId: null,
          images: [
            ProcessedImage(
              bytes: Uint8List(1),
              base64Data: 'data:image/jpeg;base64,AA==',
              fileName: 'test.jpg',
              sizeBytes: 1,
            ),
          ],
          existingImages: [],
        );

        expect(capturedDeviceId, equals('456'));
      });

      test('should emit progress events', () async {
        final progressEvents = <UploadProgressEvent>[];
        final subscription = eventBus.uploadProgress.listen(progressEvents.add);

        final service = ImageUploadService(
          uploadCallback: (resourceType, deviceId, params) async {
            return {'success': true};
          },
          verifier: ImageUploadVerifier(
            fetchImagesCallback: (deviceType, deviceId) async => ['img.jpg'],
            initialDelay: const Duration(milliseconds: 1),
            betweenAttempts: const Duration(milliseconds: 1),
            maxTotalWaitTime: const Duration(milliseconds: 100),
          ),
          eventBus: eventBus,
        );

        await service.uploadImages(
          deviceType: 'access_point',
          deviceId: 'ap_123',
          roomId: null,
          images: [
            ProcessedImage(
              bytes: Uint8List(1),
              base64Data: 'data:image/jpeg;base64,AA==',
              fileName: 'test.jpg',
              sizeBytes: 1,
            ),
          ],
          existingImages: [],
        );

        await Future.delayed(const Duration(milliseconds: 50));

        expect(progressEvents, isNotEmpty);
        expect(
          progressEvents.any((e) => e.status == UploadStatus.uploading),
          isTrue,
        );

        await subscription.cancel();
      });

      test('should emit upload complete event on success', () async {
        final uploadEvents = <ImageUploadEvent>[];
        final subscription = eventBus.imageUploaded.listen(uploadEvents.add);

        final service = ImageUploadService(
          uploadCallback: (resourceType, deviceId, params) async {
            return {'success': true};
          },
          verifier: ImageUploadVerifier(
            fetchImagesCallback: (deviceType, deviceId) async => ['img.jpg'],
            initialDelay: const Duration(milliseconds: 1),
            betweenAttempts: const Duration(milliseconds: 1),
            maxTotalWaitTime: const Duration(milliseconds: 100),
          ),
          eventBus: eventBus,
        );

        await service.uploadImages(
          deviceType: 'access_point',
          deviceId: 'ap_123',
          roomId: 'room_1',
          images: [
            ProcessedImage(
              bytes: Uint8List(1),
              base64Data: 'data:image/jpeg;base64,AA==',
              fileName: 'test.jpg',
              sizeBytes: 1,
            ),
          ],
          existingImages: [],
        );

        await Future.delayed(const Duration(milliseconds: 50));

        expect(uploadEvents.length, equals(1));
        expect(uploadEvents[0].deviceId, equals('ap_123'));
        expect(uploadEvents[0].roomId, equals('room_1'));

        await subscription.cancel();
      });

      test('should emit cache invalidation event on success', () async {
        final cacheEvents = <CacheInvalidationEvent>[];
        final subscription = eventBus.cacheInvalidated.listen(cacheEvents.add);

        final service = ImageUploadService(
          uploadCallback: (resourceType, deviceId, params) async {
            return {'success': true};
          },
          verifier: ImageUploadVerifier(
            fetchImagesCallback: (deviceType, deviceId) async => ['img.jpg'],
            initialDelay: const Duration(milliseconds: 1),
            betweenAttempts: const Duration(milliseconds: 1),
            maxTotalWaitTime: const Duration(milliseconds: 100),
          ),
          eventBus: eventBus,
        );

        await service.uploadImages(
          deviceType: 'access_point',
          deviceId: 'ap_123',
          roomId: null,
          images: [
            ProcessedImage(
              bytes: Uint8List(1),
              base64Data: 'data:image/jpeg;base64,AA==',
              fileName: 'test.jpg',
              sizeBytes: 1,
            ),
          ],
          existingImages: [],
        );

        await Future.delayed(const Duration(milliseconds: 50));

        expect(cacheEvents.length, equals(1));
        expect(cacheEvents[0].deviceId, equals('ap_123'));

        await subscription.cancel();
      });

      test('should handle upload failure', () async {
        final service = ImageUploadService(
          uploadCallback: (resourceType, deviceId, params) async {
            throw Exception('Network error');
          },
          verifier: ImageUploadVerifier(
            fetchImagesCallback: (deviceType, deviceId) async => [],
            initialDelay: const Duration(milliseconds: 1),
            betweenAttempts: const Duration(milliseconds: 1),
            maxTotalWaitTime: const Duration(milliseconds: 100),
          ),
          eventBus: eventBus,
        );

        expect(
          () => service.uploadImages(
            deviceType: 'access_point',
            deviceId: 'ap_123',
            roomId: null,
            images: [
              ProcessedImage(
                bytes: Uint8List(1),
                base64Data: 'data:image/jpeg;base64,AA==',
                fileName: 'test.jpg',
                sizeBytes: 1,
              ),
            ],
            existingImages: [],
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw for unknown device type', () async {
        final service = ImageUploadService(
          uploadCallback: (resourceType, deviceId, params) async {
            return {'success': true};
          },
          verifier: ImageUploadVerifier(
            fetchImagesCallback: (deviceType, deviceId) async => [],
            initialDelay: const Duration(milliseconds: 1),
            betweenAttempts: const Duration(milliseconds: 1),
            maxTotalWaitTime: const Duration(milliseconds: 100),
          ),
          eventBus: eventBus,
        );

        expect(
          () => service.uploadImages(
            deviceType: 'unknown_device',
            deviceId: 'unknown_123',
            roomId: null,
            images: [
              ProcessedImage(
                bytes: Uint8List(1),
                base64Data: 'data:image/jpeg;base64,AA==',
                fileName: 'test.jpg',
                sizeBytes: 1,
              ),
            ],
            existingImages: [],
          ),
          throwsArgumentError,
        );
      });
    });

    group('getResourceType', () {
      test('should map device types to resource types', () {
        expect(
          ImageUploadService.getResourceType('access_point'),
          equals('access_points'),
        );
        expect(
          ImageUploadService.getResourceType('ap'),
          equals('access_points'),
        );
        expect(
          ImageUploadService.getResourceType('ont'),
          equals('media_converters'),
        );
        expect(
          ImageUploadService.getResourceType('media_converter'),
          equals('media_converters'),
        );
        expect(
          ImageUploadService.getResourceType('switch'),
          equals('switch_devices'),
        );
      });

      test('should throw for unknown device type', () {
        expect(
          () => ImageUploadService.getResourceType('unknown'),
          throwsArgumentError,
        );
      });
    });

    group('extractRawId', () {
      test('should extract raw ID from prefixed IDs', () {
        expect(ImageUploadService.extractRawId('ap_123'), equals('123'));
        expect(ImageUploadService.extractRawId('ont_456'), equals('456'));
        expect(ImageUploadService.extractRawId('sw_789'), equals('789'));
        expect(ImageUploadService.extractRawId('wlan_101'), equals('101'));
      });

      test('should return original ID if no prefix', () {
        expect(ImageUploadService.extractRawId('123'), equals('123'));
        expect(ImageUploadService.extractRawId('abc'), equals('abc'));
      });
    });
  });

  group('ImageUploadResult', () {
    test('should create with required fields', () {
      final result = ImageUploadResult(
        success: true,
        verificationResult: VerificationResult.success,
        uploadedCount: 2,
        message: 'Success',
      );

      expect(result.success, isTrue);
      expect(result.verificationResult, equals(VerificationResult.success));
      expect(result.uploadedCount, equals(2));
      expect(result.message, equals('Success'));
    });

    test('should indicate error state correctly', () {
      final successResult = ImageUploadResult(
        success: true,
        verificationResult: VerificationResult.success,
        uploadedCount: 1,
        message: 'Success',
      );
      expect(successResult.isError, isFalse);

      final failedResult = ImageUploadResult(
        success: false,
        verificationResult: VerificationResult.failed,
        uploadedCount: 0,
        message: 'Failed',
      );
      expect(failedResult.isError, isTrue);
    });
  });
}
