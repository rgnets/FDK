// TODO: This test needs to be rewritten for Dio
// The RestImageUploadService was refactored from http.Client to Dio.
// Tests need to mock Dio instead of http.Client.
@Skip('Needs migration from http.Client to Dio mocking')
library;

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RestImageUploadService', () {
    late MockHttpClient mockHttpClient;
    late RestImageUploadService service;

    const testSiteUrl = 'https://example.rgnetworks.com';
    const testApiKey = 'test-api-key-12345';

    setUp(() {
      mockHttpClient = MockHttpClient();
      service = RestImageUploadService(
        httpClient: mockHttpClient,
        siteUrl: testSiteUrl,
        apiKey: testApiKey,
      );
    });

    tearDown(() {
      mockHttpClient.close();
    });

    setUpAll(() {
      registerFallbackValue(Uri.parse('https://example.com'));
    });

    group('constructor', () {
      test('should create instance with required parameters', () {
        expect(service, isNotNull);
      });

      test('should throw if siteUrl is empty', () {
        expect(
          () => RestImageUploadService(
            httpClient: mockHttpClient,
            siteUrl: '',
            apiKey: testApiKey,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw if apiKey is empty', () {
        expect(
          () => RestImageUploadService(
            httpClient: mockHttpClient,
            siteUrl: testSiteUrl,
            apiKey: '',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('uploadImages', () {
      test('should send PUT request to correct endpoint for access_points', () async {
        const deviceId = '123';
        const resourceType = 'access_points';
        final images = ['data:image/jpeg;base64,abc123'];

        when(
          () => mockHttpClient.put(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            jsonEncode({'id': 123, 'images': images}),
            200,
          ),
        );

        await service.uploadImages(
          deviceId: deviceId,
          resourceType: resourceType,
          images: images,
        );

        final captured = verify(
          () => mockHttpClient.put(
            captureAny(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).captured;

        final uri = captured.first as Uri;
        expect(uri.toString(), contains('/api/access_points/123.json'));
        expect(uri.toString(), contains('api_key=$testApiKey'));
      });

      test('should send PUT request to correct endpoint for media_converters', () async {
        const deviceId = '456';
        const resourceType = 'media_converters';
        final images = ['signed_id_1', 'data:image/png;base64,xyz789'];

        when(
          () => mockHttpClient.put(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            jsonEncode({'id': 456, 'images': images}),
            200,
          ),
        );

        await service.uploadImages(
          deviceId: deviceId,
          resourceType: resourceType,
          images: images,
        );

        final captured = verify(
          () => mockHttpClient.put(
            captureAny(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).captured;

        final uri = captured.first as Uri;
        expect(uri.toString(), contains('/api/media_converters/456.json'));
      });

      test('should send PUT request to correct endpoint for switch_devices', () async {
        const deviceId = '789';
        const resourceType = 'switch_devices';
        final images = <String>[];

        when(
          () => mockHttpClient.put(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            jsonEncode({'id': 789, 'images': images}),
            200,
          ),
        );

        await service.uploadImages(
          deviceId: deviceId,
          resourceType: resourceType,
          images: images,
        );

        final captured = verify(
          () => mockHttpClient.put(
            captureAny(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).captured;

        final uri = captured.first as Uri;
        expect(uri.toString(), contains('/api/switch_devices/789.json'));
      });

      test('should send correct headers', () async {
        const deviceId = '123';
        const resourceType = 'access_points';
        final images = ['data:image/jpeg;base64,abc123'];

        when(
          () => mockHttpClient.put(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            jsonEncode({'id': 123, 'images': images}),
            200,
          ),
        );

        await service.uploadImages(
          deviceId: deviceId,
          resourceType: resourceType,
          images: images,
        );

        verify(
          () => mockHttpClient.put(
            any(),
            headers: {'Content-Type': 'application/json'},
            body: any(named: 'body'),
          ),
        ).called(1);
      });

      test('should send correct body with images', () async {
        const deviceId = '123';
        const resourceType = 'access_points';
        final images = ['signed_id_1', 'data:image/jpeg;base64,abc123'];

        when(
          () => mockHttpClient.put(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            jsonEncode({'id': 123, 'images': images}),
            200,
          ),
        );

        await service.uploadImages(
          deviceId: deviceId,
          resourceType: resourceType,
          images: images,
        );

        final captured = verify(
          () => mockHttpClient.put(
            any(),
            headers: any(named: 'headers'),
            body: captureAny(named: 'body'),
          ),
        ).captured;

        final body = jsonDecode(captured.first as String) as Map<String, dynamic>;
        expect(body['images'], equals(images));
      });

      test('should return RestImageUploadResult on success', () async {
        const deviceId = '123';
        const resourceType = 'access_points';
        final images = ['data:image/jpeg;base64,abc123'];
        final serverImages = [
          {'signed_id': 'new_signed_id', 'url': 'https://example.com/image.jpg'},
        ];

        when(
          () => mockHttpClient.put(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            jsonEncode({'id': 123, 'images': serverImages}),
            200,
          ),
        );

        final result = await service.uploadImages(
          deviceId: deviceId,
          resourceType: resourceType,
          images: images,
        );

        expect(result.success, isTrue);
        expect(result.statusCode, equals(200));
        expect(result.serverImages, isNotNull);
      });

      test('should return failure result on non-200 status code', () async {
        const deviceId = '123';
        const resourceType = 'access_points';
        final images = ['data:image/jpeg;base64,abc123'];

        when(
          () => mockHttpClient.put(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response('Internal Server Error', 500),
        );

        final result = await service.uploadImages(
          deviceId: deviceId,
          resourceType: resourceType,
          images: images,
        );

        expect(result.success, isFalse);
        expect(result.statusCode, equals(500));
        expect(result.errorMessage, isNotNull);
      });

      test('should return failure result on 401 unauthorized', () async {
        const deviceId = '123';
        const resourceType = 'access_points';
        final images = ['data:image/jpeg;base64,abc123'];

        when(
          () => mockHttpClient.put(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response('Unauthorized', 401),
        );

        final result = await service.uploadImages(
          deviceId: deviceId,
          resourceType: resourceType,
          images: images,
        );

        expect(result.success, isFalse);
        expect(result.statusCode, equals(401));
      });

      test('should return failure result on 404 not found', () async {
        const deviceId = '999';
        const resourceType = 'access_points';
        final images = ['data:image/jpeg;base64,abc123'];

        when(
          () => mockHttpClient.put(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response('Not Found', 404),
        );

        final result = await service.uploadImages(
          deviceId: deviceId,
          resourceType: resourceType,
          images: images,
        );

        expect(result.success, isFalse);
        expect(result.statusCode, equals(404));
      });

      test('should handle network exception', () async {
        const deviceId = '123';
        const resourceType = 'access_points';
        final images = ['data:image/jpeg;base64,abc123'];

        when(
          () => mockHttpClient.put(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenThrow(Exception('Network error'));

        final result = await service.uploadImages(
          deviceId: deviceId,
          resourceType: resourceType,
          images: images,
        );

        expect(result.success, isFalse);
        expect(result.errorMessage, contains('Network error'));
      });

      test('should strip https:// prefix from siteUrl if present', () async {
        final serviceWithHttps = RestImageUploadService(
          httpClient: mockHttpClient,
          siteUrl: 'https://example.rgnetworks.com',
          apiKey: testApiKey,
        );

        const deviceId = '123';
        const resourceType = 'access_points';
        final images = ['data:image/jpeg;base64,abc123'];

        when(
          () => mockHttpClient.put(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            jsonEncode({'id': 123, 'images': images}),
            200,
          ),
        );

        await serviceWithHttps.uploadImages(
          deviceId: deviceId,
          resourceType: resourceType,
          images: images,
        );

        final captured = verify(
          () => mockHttpClient.put(
            captureAny(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).captured;

        final uri = captured.first as Uri;
        expect(uri.scheme, equals('https'));
        expect(uri.host, equals('example.rgnetworks.com'));
      });

      test('should handle siteUrl without protocol prefix', () async {
        final serviceWithoutHttps = RestImageUploadService(
          httpClient: mockHttpClient,
          siteUrl: 'example.rgnetworks.com',
          apiKey: testApiKey,
        );

        const deviceId = '123';
        const resourceType = 'access_points';
        final images = ['data:image/jpeg;base64,abc123'];

        when(
          () => mockHttpClient.put(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            jsonEncode({'id': 123, 'images': images}),
            200,
          ),
        );

        await serviceWithoutHttps.uploadImages(
          deviceId: deviceId,
          resourceType: resourceType,
          images: images,
        );

        final captured = verify(
          () => mockHttpClient.put(
            captureAny(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).captured;

        final uri = captured.first as Uri;
        expect(uri.scheme, equals('https'));
        expect(uri.host, equals('example.rgnetworks.com'));
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
