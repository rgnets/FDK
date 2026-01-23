import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/core/utils/image_url_normalizer.dart';

void main() {
  group('extractImagesWithSignedIds', () {
    test('should return null for null input', () {
      final result = extractImagesWithSignedIds(null);
      expect(result, isNull);
    });

    test('should return null for non-list input', () {
      final result = extractImagesWithSignedIds('not a list');
      expect(result, isNull);
    });

    test('should return null for empty list', () {
      final result = extractImagesWithSignedIds([]);
      expect(result, isNull);
    });

    test('should extract url and signed_id from map entries', () {
      final images = [
        {'url': 'https://example.com/image1.jpg', 'signed_id': 'abc-123'},
        {'url': 'https://example.com/image2.jpg', 'signed_id': 'def-456'},
      ];

      final result = extractImagesWithSignedIds(images);

      expect(result, isNotNull);
      expect(result!.urls, ['https://example.com/image1.jpg', 'https://example.com/image2.jpg']);
      expect(result.signedIds, ['abc-123', 'def-456']);
    });

    test('should fall back to URL when signed_id is missing', () {
      final images = [
        {'url': 'https://example.com/image1.jpg'},
        {'url': 'https://example.com/image2.jpg', 'signed_id': 'def-456'},
      ];

      final result = extractImagesWithSignedIds(images);

      expect(result, isNotNull);
      expect(result!.urls, ['https://example.com/image1.jpg', 'https://example.com/image2.jpg']);
      // First image falls back to URL, second has signed_id
      expect(result.signedIds, ['https://example.com/image1.jpg', 'def-456']);
    });

    test('should handle string entries (plain URLs)', () {
      final images = [
        'https://example.com/image1.jpg',
        'https://example.com/image2.jpg',
      ];

      final result = extractImagesWithSignedIds(images);

      expect(result, isNotNull);
      expect(result!.urls, ['https://example.com/image1.jpg', 'https://example.com/image2.jpg']);
      // Falls back to URLs since no signed IDs are available
      expect(result.signedIds, ['https://example.com/image1.jpg', 'https://example.com/image2.jpg']);
    });

    test('should handle mixed string and map entries', () {
      final images = [
        'https://example.com/image1.jpg',
        {'url': 'https://example.com/image2.jpg', 'signed_id': 'def-456'},
      ];

      final result = extractImagesWithSignedIds(images);

      expect(result, isNotNull);
      expect(result!.urls.length, 2);
      expect(result.signedIds.length, 2);
      expect(result.signedIds[1], 'def-456');
    });

    test('should normalize relative URLs with base URL', () {
      final images = [
        {'url': '/images/image1.jpg', 'signed_id': 'abc-123'},
      ];

      final result = extractImagesWithSignedIds(images, baseUrl: 'https://example.com');

      expect(result, isNotNull);
      expect(result!.urls, ['https://example.com/images/image1.jpg']);
      expect(result.signedIds, ['abc-123']);
    });

    test('should handle alternative key names for signed_id', () {
      final images = [
        {'url': 'https://example.com/image1.jpg', 'signedId': 'abc-123'},
        {'url': 'https://example.com/image2.jpg', 'signed_blob_id': 'def-456'},
      ];

      final result = extractImagesWithSignedIds(images);

      expect(result, isNotNull);
      expect(result!.signedIds, ['abc-123', 'def-456']);
    });

    test('should handle data URLs', () {
      final images = [
        {'url': 'data:image/png;base64,iVBORw0KGgo=', 'signed_id': 'abc-123'},
      ];

      final result = extractImagesWithSignedIds(images);

      expect(result, isNotNull);
      expect(result!.urls, ['data:image/png;base64,iVBORw0KGgo=']);
      expect(result.signedIds, ['abc-123']);
    });

    test('should skip invalid entries', () {
      final images = [
        {'url': 'https://example.com/image1.jpg', 'signed_id': 'abc-123'},
        {},  // No url key
        {'url': ''},  // Empty url
        {'url': 'https://example.com/image2.jpg', 'signed_id': 'def-456'},
      ];

      final result = extractImagesWithSignedIds(images);

      expect(result, isNotNull);
      expect(result!.urls.length, 2);
      expect(result.signedIds.length, 2);
    });
  });

  group('normalizeImageUrls', () {
    test('should return null for null input', () {
      final result = normalizeImageUrls(null);
      expect(result, isNull);
    });

    test('should extract URLs from map entries', () {
      final images = [
        {'url': 'https://example.com/image1.jpg'},
        {'url': 'https://example.com/image2.jpg'},
      ];

      final result = normalizeImageUrls(images);

      expect(result, ['https://example.com/image1.jpg', 'https://example.com/image2.jpg']);
    });

    test('should handle string entries', () {
      final images = [
        'https://example.com/image1.jpg',
        'https://example.com/image2.jpg',
      ];

      final result = normalizeImageUrls(images);

      expect(result, ['https://example.com/image1.jpg', 'https://example.com/image2.jpg']);
    });
  });

  group('ImageExtraction', () {
    test('should store urls and signedIds', () {
      const extraction = ImageExtraction(
        urls: ['url1', 'url2'],
        signedIds: ['id1', 'id2'],
      );

      expect(extraction.urls, ['url1', 'url2']);
      expect(extraction.signedIds, ['id1', 'id2']);
    });
  });

  group('authenticateImageUrl', () {
    test('should return null for null input', () {
      final result = authenticateImageUrl(null, 'api_key_123');
      expect(result, isNull);
    });

    test('should return empty string for empty input', () {
      final result = authenticateImageUrl('', 'api_key_123');
      expect(result, '');
    });

    test('should return original URL if apiKey is null', () {
      final result = authenticateImageUrl('https://example.com/image.jpg', null);
      expect(result, 'https://example.com/image.jpg');
    });

    test('should return original URL if apiKey is empty', () {
      final result = authenticateImageUrl('https://example.com/image.jpg', '');
      expect(result, 'https://example.com/image.jpg');
    });

    test('should append api_key to URL without query params', () {
      final result = authenticateImageUrl(
        'https://example.com/image.jpg',
        'my_api_key',
      );
      expect(result, 'https://example.com/image.jpg?api_key=my_api_key');
    });

    test('should append api_key to URL with existing query params', () {
      final result = authenticateImageUrl(
        'https://example.com/image.jpg?size=large',
        'my_api_key',
      );
      expect(result, contains('api_key=my_api_key'));
      expect(result, contains('size=large'));
    });

    test('should not duplicate api_key if already present', () {
      final result = authenticateImageUrl(
        'https://example.com/image.jpg?api_key=existing_key',
        'new_api_key',
      );
      expect(result, 'https://example.com/image.jpg?api_key=existing_key');
    });

    test('should not modify data URLs', () {
      final result = authenticateImageUrl(
        'data:image/png;base64,iVBORw0KGgo=',
        'my_api_key',
      );
      expect(result, 'data:image/png;base64,iVBORw0KGgo=');
    });

    test('should not modify non-HTTP URLs', () {
      final result = authenticateImageUrl('/relative/path/image.jpg', 'my_api_key');
      expect(result, '/relative/path/image.jpg');
    });

    test('should handle http URLs (not just https)', () {
      final result = authenticateImageUrl(
        'http://example.com/image.jpg',
        'my_api_key',
      );
      expect(result, 'http://example.com/image.jpg?api_key=my_api_key');
    });

    test('should trim whitespace from URL', () {
      final result = authenticateImageUrl(
        '  https://example.com/image.jpg  ',
        'my_api_key',
      );
      expect(result, 'https://example.com/image.jpg?api_key=my_api_key');
    });
  });

  group('authenticateImageUrls', () {
    test('should return original list if apiKey is null', () {
      final urls = ['https://example.com/1.jpg', 'https://example.com/2.jpg'];
      final result = authenticateImageUrls(urls, null);
      expect(result, urls);
    });

    test('should return original list if apiKey is empty', () {
      final urls = ['https://example.com/1.jpg', 'https://example.com/2.jpg'];
      final result = authenticateImageUrls(urls, '');
      expect(result, urls);
    });

    test('should authenticate all URLs in list', () {
      final urls = ['https://example.com/1.jpg', 'https://example.com/2.jpg'];
      final result = authenticateImageUrls(urls, 'my_api_key');

      expect(result.length, 2);
      expect(result[0], 'https://example.com/1.jpg?api_key=my_api_key');
      expect(result[1], 'https://example.com/2.jpg?api_key=my_api_key');
    });

    test('should handle empty list', () {
      final result = authenticateImageUrls([], 'my_api_key');
      expect(result, isEmpty);
    });
  });

  group('stripApiKeyFromUrl', () {
    test('should return null for null input', () {
      final result = stripApiKeyFromUrl(null);
      expect(result, isNull);
    });

    test('should return empty string for empty input', () {
      final result = stripApiKeyFromUrl('');
      expect(result, '');
    });

    test('should return original URL if no api_key present', () {
      final result = stripApiKeyFromUrl('https://example.com/image.jpg');
      expect(result, 'https://example.com/image.jpg');
    });

    test('should remove api_key from URL with only api_key param', () {
      final result = stripApiKeyFromUrl(
        'https://example.com/image.jpg?api_key=my_api_key',
      );
      expect(result, 'https://example.com/image.jpg');
    });

    test('should remove api_key but keep other params', () {
      final result = stripApiKeyFromUrl(
        'https://example.com/image.jpg?size=large&api_key=my_api_key&format=png',
      );
      expect(result, isNot(contains('api_key')));
      expect(result, contains('size=large'));
      expect(result, contains('format=png'));
    });

    test('should not modify data URLs', () {
      final result = stripApiKeyFromUrl('data:image/png;base64,iVBORw0KGgo=');
      expect(result, 'data:image/png;base64,iVBORw0KGgo=');
    });

    test('should not modify non-HTTP URLs', () {
      final result = stripApiKeyFromUrl('/relative/path/image.jpg?api_key=test');
      expect(result, '/relative/path/image.jpg?api_key=test');
    });

    test('should handle http URLs', () {
      final result = stripApiKeyFromUrl(
        'http://example.com/image.jpg?api_key=my_api_key',
      );
      expect(result, 'http://example.com/image.jpg');
    });

    test('should trim whitespace from URL', () {
      final result = stripApiKeyFromUrl(
        '  https://example.com/image.jpg?api_key=test  ',
      );
      expect(result, 'https://example.com/image.jpg');
    });
  });
}
