import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/features/devices/data/services/rest_image_upload_service.dart';

class MockDio extends Mock implements Dio {}

Response<Map<String, dynamic>> buildResponse({
  required String url,
  required int statusCode,
  Map<String, dynamic>? data,
}) {
  return Response<Map<String, dynamic>>(
    data: data,
    statusCode: statusCode,
    requestOptions: RequestOptions(path: url),
  );
}

void main() {
  late MockDio mockDio;
  late RestImageUploadService service;

  const testSiteUrl = 'https://example.rgnetworks.com';
  const testApiKey = 'test-api-key-12345';

  setUpAll(() {
    registerFallbackValue(Options());
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue((int sent, int total) {});
  });

  setUp(() {
    mockDio = MockDio();
    service = RestImageUploadService(
      siteUrl: testSiteUrl,
      apiKey: testApiKey,
      dio: mockDio,
    );
  });

  group('RestImageUploadService', () {
    group('constructor', () {
      test('should create instance with required parameters', () {
        expect(service, isNotNull);
      });

      test('should throw if siteUrl is empty', () {
        expect(
          () => RestImageUploadService(
            siteUrl: '',
            apiKey: testApiKey,
            dio: mockDio,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw if apiKey is empty', () {
        expect(
          () => RestImageUploadService(
            siteUrl: testSiteUrl,
            apiKey: '',
            dio: mockDio,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('fetchCurrentSignedIds', () {
      test('should return signed IDs from response', () async {
        const deviceId = '123';
        const resourceType = 'access_points';
        final expectedUrl =
            'https://example.rgnetworks.com/api/$resourceType/$deviceId.json';

        final responseData = {
          'images': [
            {'signed_id': 'signed_1', 'url': 'https://example.com/a.jpg'},
            {'signed_id': '', 'url': 'https://example.com/b.jpg'},
            {'url': 'https://example.com/c.jpg'},
            {'signed_id': 'signed_2'},
          ],
        };

        when(
          () => mockDio.get<Map<String, dynamic>>(
            any(),
            options: any(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => buildResponse(
            url: expectedUrl,
            statusCode: 200,
            data: responseData,
          ),
        );

        final result = await service.fetchCurrentSignedIds(
          resourceType: resourceType,
          deviceId: deviceId,
        );

        expect(result, ['signed_1', 'signed_2']);

        final captured = verify(
          () => mockDio.get<Map<String, dynamic>>(
            captureAny(),
            options: captureAny(named: 'options'),
          ),
        ).captured;

        final capturedUrl = captured[0] as String;
        final capturedOptions = captured[1] as Options;
        expect(capturedUrl, expectedUrl);
        expect(capturedOptions.headers?['X-API-Key'], testApiKey);
      });

      test('should return empty list on DioException', () async {
        const deviceId = '123';
        const resourceType = 'access_points';
        final url =
            'https://example.rgnetworks.com/api/$resourceType/$deviceId.json';

        final exception = DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: url),
          message: 'Connection failed',
        );

        when(
          () => mockDio.get<Map<String, dynamic>>(
            any(),
            options: any(named: 'options'),
          ),
        ).thenThrow(exception);

        final result = await service.fetchCurrentSignedIds(
          resourceType: resourceType,
          deviceId: deviceId,
        );

        expect(result, isEmpty);
      });
    });

    group('uploadImages', () {
      test('should send PUT request to correct endpoint with body and options',
          () async {
        const deviceId = '123';
        const resourceType = 'access_points';
        final images = ['signed_id_1', 'data:image/jpeg;base64,abc123'];
        final serverImages = [
          {'signed_id': 'new_signed_id', 'url': 'https://example.com/image.jpg'},
        ];

        when(
          () => mockDio.put<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
            onSendProgress: any(named: 'onSendProgress'),
          ),
        ).thenAnswer(
          (invocation) async => buildResponse(
            url: invocation.positionalArguments.first as String,
            statusCode: 200,
            data: {'id': 123, 'images': serverImages},
          ),
        );

        final result = await service.uploadImages(
          deviceId: deviceId,
          resourceType: resourceType,
          images: images,
        );

        expect(result.success, isTrue);
        expect(result.statusCode, equals(200));
        expect(result.serverImages, equals(serverImages));

        final captured = verify(
          () => mockDio.put<Map<String, dynamic>>(
            captureAny(),
            data: captureAny(named: 'data'),
            options: captureAny(named: 'options'),
            onSendProgress: any(named: 'onSendProgress'),
          ),
        ).captured;

        final capturedUrl = captured[0] as String;
        final capturedBody = captured[1] as Map<String, dynamic>;
        final capturedOptions = captured[2] as Options;

        expect(capturedUrl, contains('/api/access_points/123.json'));
        expect(capturedUrl, isNot(contains('api_key=')));
        expect(capturedBody['images'], equals(images));
        expect(capturedOptions.contentType, equals('application/json'));
        expect(capturedOptions.responseType, equals(ResponseType.json));
        expect(capturedOptions.headers?['X-API-Key'], testApiKey);
      });

      test('should send PUT request to correct endpoint for media_converters',
          () async {
        const deviceId = '456';
        const resourceType = 'media_converters';
        final images = ['signed_id_1'];

        when(
          () => mockDio.put<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
            onSendProgress: any(named: 'onSendProgress'),
          ),
        ).thenAnswer(
          (invocation) async => buildResponse(
            url: invocation.positionalArguments.first as String,
            statusCode: 200,
            data: {'id': 456, 'images': images},
          ),
        );

        await service.uploadImages(
          deviceId: deviceId,
          resourceType: resourceType,
          images: images,
        );

        final captured = verify(
          () => mockDio.put<Map<String, dynamic>>(
            captureAny(),
            data: any(named: 'data'),
            options: any(named: 'options'),
            onSendProgress: any(named: 'onSendProgress'),
          ),
        ).captured;

        final capturedUrl = captured.first as String;
        expect(capturedUrl, contains('/api/media_converters/456.json'));
      });

      test('should send PUT request to correct endpoint for switch_devices',
          () async {
        const deviceId = '789';
        const resourceType = 'switch_devices';
        final images = <String>[];

        when(
          () => mockDio.put<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
            onSendProgress: any(named: 'onSendProgress'),
          ),
        ).thenAnswer(
          (invocation) async => buildResponse(
            url: invocation.positionalArguments.first as String,
            statusCode: 200,
            data: {'id': 789, 'images': images},
          ),
        );

        await service.uploadImages(
          deviceId: deviceId,
          resourceType: resourceType,
          images: images,
        );

        final captured = verify(
          () => mockDio.put<Map<String, dynamic>>(
            captureAny(),
            data: any(named: 'data'),
            options: any(named: 'options'),
            onSendProgress: any(named: 'onSendProgress'),
          ),
        ).captured;

        final capturedUrl = captured.first as String;
        expect(capturedUrl, contains('/api/switch_devices/789.json'));
      });

      test('should return failure result on non-200 status code', () async {
        const deviceId = '123';
        const resourceType = 'access_points';
        final images = ['data:image/jpeg;base64,abc123'];

        when(
          () => mockDio.put<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
            onSendProgress: any(named: 'onSendProgress'),
          ),
        ).thenAnswer(
          (invocation) async => buildResponse(
            url: invocation.positionalArguments.first as String,
            statusCode: 500,
            data: {'error': 'Internal Server Error'},
          ),
        );

        final result = await service.uploadImages(
          deviceId: deviceId,
          resourceType: resourceType,
          images: images,
        );

        expect(result.success, isFalse);
        expect(result.statusCode, equals(500));
        expect(result.errorMessage, contains('status 500'));
      });

      test('should handle DioException connectionTimeout', () async {
        const deviceId = '123';
        const resourceType = 'access_points';
        final images = ['data:image/jpeg;base64,abc123'];

        final exception = DioException(
          type: DioExceptionType.connectionTimeout,
          requestOptions: RequestOptions(path: '/test'),
          message: 'Timeout',
        );

        when(
          () => mockDio.put<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
            onSendProgress: any(named: 'onSendProgress'),
          ),
        ).thenThrow(exception);

        final result = await service.uploadImages(
          deviceId: deviceId,
          resourceType: resourceType,
          images: images,
        );

        expect(result.success, isFalse);
        expect(result.statusCode, equals(0));
        expect(result.errorMessage, equals('Connection timeout'));
      });

      test('should handle DioException sendTimeout', () async {
        const deviceId = '123';
        const resourceType = 'access_points';
        final images = ['data:image/jpeg;base64,abc123'];

        final exception = DioException(
          type: DioExceptionType.sendTimeout,
          requestOptions: RequestOptions(path: '/test'),
          message: 'Send timeout',
        );

        when(
          () => mockDio.put<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
            onSendProgress: any(named: 'onSendProgress'),
          ),
        ).thenThrow(exception);

        final result = await service.uploadImages(
          deviceId: deviceId,
          resourceType: resourceType,
          images: images,
        );

        expect(result.success, isFalse);
        expect(result.errorMessage, contains('Send timeout'));
      });

      test('should handle DioException receiveTimeout', () async {
        const deviceId = '123';
        const resourceType = 'access_points';
        final images = ['data:image/jpeg;base64,abc123'];

        final exception = DioException(
          type: DioExceptionType.receiveTimeout,
          requestOptions: RequestOptions(path: '/test'),
          message: 'Receive timeout',
        );

        when(
          () => mockDio.put<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
            onSendProgress: any(named: 'onSendProgress'),
          ),
        ).thenThrow(exception);

        final result = await service.uploadImages(
          deviceId: deviceId,
          resourceType: resourceType,
          images: images,
        );

        expect(result.success, isFalse);
        expect(result.errorMessage, contains('Receive timeout'));
      });

      test('should handle DioException connectionError', () async {
        const deviceId = '123';
        const resourceType = 'access_points';
        final images = ['data:image/jpeg;base64,abc123'];

        final exception = DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: '/test'),
          message: 'No internet',
        );

        when(
          () => mockDio.put<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
            onSendProgress: any(named: 'onSendProgress'),
          ),
        ).thenThrow(exception);

        final result = await service.uploadImages(
          deviceId: deviceId,
          resourceType: resourceType,
          images: images,
        );

        expect(result.success, isFalse);
        expect(result.errorMessage, contains('Connection error'));
      });

      test('should handle DioException unknown/default type', () async {
        const deviceId = '123';
        const resourceType = 'access_points';
        final images = ['data:image/jpeg;base64,abc123'];

        final exception = DioException(
          type: DioExceptionType.unknown,
          requestOptions: RequestOptions(path: '/test'),
          message: 'Unknown error',
        );

        when(
          () => mockDio.put<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
            onSendProgress: any(named: 'onSendProgress'),
          ),
        ).thenThrow(exception);

        final result = await service.uploadImages(
          deviceId: deviceId,
          resourceType: resourceType,
          images: images,
        );

        expect(result.success, isFalse);
        expect(result.errorMessage, contains('Network error'));
      });

      test('should handle generic Exception', () async {
        const deviceId = '123';
        const resourceType = 'access_points';
        final images = ['data:image/jpeg;base64,abc123'];

        when(
          () => mockDio.put<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
            onSendProgress: any(named: 'onSendProgress'),
          ),
        ).thenThrow(Exception('Unexpected error'));

        final result = await service.uploadImages(
          deviceId: deviceId,
          resourceType: resourceType,
          images: images,
        );

        expect(result.success, isFalse);
        expect(result.errorMessage, contains('Network error'));
      });

      test('should normalize siteUrl with https prefix and trailing slash',
          () async {
        final normalizedService = RestImageUploadService(
          siteUrl: 'https://example.rgnetworks.com/',
          apiKey: testApiKey,
          dio: mockDio,
        );

        const deviceId = '123';
        const resourceType = 'access_points';
        final images = ['data:image/jpeg;base64,abc123'];

        when(
          () => mockDio.put<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
            onSendProgress: any(named: 'onSendProgress'),
          ),
        ).thenAnswer(
          (invocation) async => buildResponse(
            url: invocation.positionalArguments.first as String,
            statusCode: 200,
            data: {'id': 123, 'images': images},
          ),
        );

        await normalizedService.uploadImages(
          deviceId: deviceId,
          resourceType: resourceType,
          images: images,
        );

        final captured = verify(
          () => mockDio.put<Map<String, dynamic>>(
            captureAny(),
            data: any(named: 'data'),
            options: any(named: 'options'),
            onSendProgress: any(named: 'onSendProgress'),
          ),
        ).captured;

        final capturedUrl = captured.first as String;
        expect(capturedUrl.startsWith('https://example.rgnetworks.com/'), isTrue);
      });
    });

    group('RestImageUploadResult', () {
      test('should create success result', () {
        final result = RestImageUploadResult.success(
          statusCode: 200,
          serverImages: [
            {'signed_id': 'abc', 'url': 'https://example.com/img.jpg'},
          ],
        );

        expect(result.success, isTrue);
        expect(result.statusCode, equals(200));
        expect(result.serverImages, isNotEmpty);
        expect(result.errorMessage, isNull);
      });

      test('should create failure result', () {
        const result = RestImageUploadResult.failure(
          statusCode: 500,
          errorMessage: 'Server error',
        );

        expect(result.success, isFalse);
        expect(result.statusCode, equals(500));
        expect(result.errorMessage, equals('Server error'));
        expect(result.serverImages, isNull);
      });
    });
  });
}
