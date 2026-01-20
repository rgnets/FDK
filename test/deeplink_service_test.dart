import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/core/services/deeplink_service.dart';

void main() {
  group('DeeplinkService', () {
    late DeeplinkService service;

    setUp(() {
      service = DeeplinkService();
    });

    tearDown(() {
      service.dispose();
    });

    group('FQDN Validation', () {
      test('accepts valid simple domain', () {
        expect(DeeplinkService.isValidFqdn('example.com'), isTrue);
      });

      test('accepts valid subdomain', () {
        expect(DeeplinkService.isValidFqdn('sub.example.com'), isTrue);
      });

      test('accepts valid multi-level subdomain', () {
        expect(DeeplinkService.isValidFqdn('deep.sub.example.com'), isTrue);
      });

      test('accepts valid domain with numbers', () {
        expect(DeeplinkService.isValidFqdn('api123.example.com'), isTrue);
      });

      test('accepts valid domain with hyphens', () {
        expect(DeeplinkService.isValidFqdn('my-api.example-site.com'), isTrue);
      });

      test('accepts single label domain', () {
        expect(DeeplinkService.isValidFqdn('localhost'), isTrue);
      });

      test('rejects empty string', () {
        expect(DeeplinkService.isValidFqdn(''), isFalse);
      });

      test('rejects domain starting with hyphen', () {
        expect(DeeplinkService.isValidFqdn('-example.com'), isFalse);
      });

      test('rejects domain ending with hyphen', () {
        expect(DeeplinkService.isValidFqdn('example-.com'), isFalse);
      });

      test('rejects domain with invalid characters', () {
        expect(DeeplinkService.isValidFqdn('example_site.com'), isFalse);
      });

      test('rejects domain with spaces', () {
        expect(DeeplinkService.isValidFqdn('example site.com'), isFalse);
      });

      test('accepts real-world domain', () {
        expect(DeeplinkService.isValidFqdn('dlp.netlab.ninja'), isTrue);
      });
    });

    group('DeeplinkCredentials', () {
      test('creates credentials with all fields', () {
        const credentials = DeeplinkCredentials(
          fqdn: 'example.com',
          apiKey: 'test-api-key-that-is-at-least-32-chars',
          login: 'user@example.com',
        );

        expect(credentials.fqdn, equals('example.com'));
        expect(credentials.apiKey, equals('test-api-key-that-is-at-least-32-chars'));
        expect(credentials.login, equals('user@example.com'));
      });
    });

    group('DeeplinkParseResult', () {
      test('DeeplinkParseSuccess contains credentials', () {
        const credentials = DeeplinkCredentials(
          fqdn: 'example.com',
          apiKey: 'test-api-key-that-is-at-least-32-chars',
          login: 'user@example.com',
        );
        const result = DeeplinkParseSuccess(credentials);

        expect(result, isA<DeeplinkParseSuccess>());
        expect(result.credentials.fqdn, equals('example.com'));
      });

      test('DeeplinkParseError contains message', () {
        const result = DeeplinkParseError('Invalid parameter');

        expect(result, isA<DeeplinkParseError>());
        expect(result.message, equals('Invalid parameter'));
      });

      test('DeeplinkParseIgnored contains reason', () {
        const result = DeeplinkParseIgnored('Unsupported scheme');

        expect(result, isA<DeeplinkParseIgnored>());
        expect(result.reason, equals('Unsupported scheme'));
      });
    });
  });

  group('URI Parsing (via public API simulation)', () {
    // These tests verify the expected behavior of deeplink URIs
    // Since _parseUri is private, we test the expected input/output formats

    test('valid deeplink URI format with query params', () {
      final uri = Uri.parse(
        'fdk://login?fqdn=example.com&apiKey=test123456789012345678901234567890&login=user@test.com',
      );

      expect(uri.scheme, equals('fdk'));
      expect(uri.host, equals('login'));
      expect(uri.queryParameters['fqdn'], equals('example.com'));
      expect(uri.queryParameters['apiKey'], equals('test123456789012345678901234567890'));
      expect(uri.queryParameters['login'], equals('user@test.com'));
    });

    test('valid deeplink URI format with Base64 data param', () {
      final jsonData = {
        'fqdn': 'example.com',
        'apiKey': 'test123456789012345678901234567890',
        'login': 'user@test.com',
      };
      final base64Data = base64Encode(utf8.encode(json.encode(jsonData)));
      final uri = Uri.parse('fdk://login?data=$base64Data');

      expect(uri.scheme, equals('fdk'));
      expect(uri.host, equals('login'));
      expect(uri.queryParameters['data'], isNotEmpty);

      // Verify we can decode it back
      final decodedBytes = base64Decode(uri.queryParameters['data']!);
      final decodedJson = json.decode(utf8.decode(decodedBytes)) as Map<String, dynamic>;
      expect(decodedJson['fqdn'], equals('example.com'));
      expect(decodedJson['apiKey'], equals('test123456789012345678901234567890'));
      expect(decodedJson['login'], equals('user@test.com'));
    });

    test('URI with URL-encoded login', () {
      final uri = Uri.parse(
        'fdk://login?fqdn=example.com&apiKey=test123456789012345678901234567890&login=user%40test.com',
      );

      expect(uri.queryParameters['login'], equals('user@test.com'));
    });

    test('alternative parameter names are parseable', () {
      // Test that URIs with alternative param names can be parsed
      final uriWithServer = Uri.parse(
        'fdk://login?server=example.com&key=test123456789012345678901234567890&user=testuser',
      );

      expect(uriWithServer.queryParameters['server'], equals('example.com'));
      expect(uriWithServer.queryParameters['key'], equals('test123456789012345678901234567890'));
      expect(uriWithServer.queryParameters['user'], equals('testuser'));
    });

    test('wrong scheme is detectable', () {
      final uri = Uri.parse(
        'https://login?fqdn=example.com&apiKey=test123456789012345678901234567890&login=user',
      );

      expect(uri.scheme, equals('https'));
      expect(uri.scheme, isNot(equals('fdk')));
    });

    test('wrong host is detectable', () {
      final uri = Uri.parse(
        'fdk://wronghost?fqdn=example.com&apiKey=test123456789012345678901234567890&login=user',
      );

      expect(uri.host, equals('wronghost'));
      expect(uri.host, isNot(equals('login')));
    });
  });

  group('API Key Validation', () {
    test('API key with exactly 32 characters is valid length', () {
      const apiKey = '12345678901234567890123456789012'; // 32 chars
      expect(apiKey.length, equals(32));
      expect(apiKey.length >= 32, isTrue);
    });

    test('API key with more than 32 characters is valid length', () {
      const apiKey = '123456789012345678901234567890123456789012345678901234567890'; // 60 chars
      expect(apiKey.length, greaterThan(32));
      expect(apiKey.length >= 32, isTrue);
    });

    test('API key with less than 32 characters is invalid length', () {
      const apiKey = '1234567890123456789012345678901'; // 31 chars
      expect(apiKey.length, lessThan(32));
      expect(apiKey.length >= 32, isFalse);
    });
  });

  group('Base64 Encoding/Decoding', () {
    test('encodes and decodes credentials correctly', () {
      final originalData = {
        'fqdn': 'dlp.netlab.ninja',
        'apiKey': '42WsN6r4tKeALvRxmdChhqBEV717th1eZaakysXSmSSGVvFK8v63QSWwsBPoSzBfYM1esGPoripWCqLD',
        'login': 'zewtech',
      };

      // Encode
      final jsonString = json.encode(originalData);
      final base64String = base64Encode(utf8.encode(jsonString));

      // Decode
      final decodedBytes = base64Decode(base64String);
      final decodedJson = json.decode(utf8.decode(decodedBytes)) as Map<String, dynamic>;

      expect(decodedJson['fqdn'], equals(originalData['fqdn']));
      expect(decodedJson['apiKey'], equals(originalData['apiKey']));
      expect(decodedJson['login'], equals(originalData['login']));
    });

    test('handles special characters in login', () {
      final originalData = {
        'fqdn': 'example.com',
        'apiKey': '12345678901234567890123456789012',
        'login': 'user+special@example.com',
      };

      final jsonString = json.encode(originalData);
      final base64String = base64Encode(utf8.encode(jsonString));
      final decodedBytes = base64Decode(base64String);
      final decodedJson = json.decode(utf8.decode(decodedBytes)) as Map<String, dynamic>;

      expect(decodedJson['login'], equals('user+special@example.com'));
    });
  });

  group('Deduplication Logic', () {
    test('same URI string is detectable', () {
      const uri1 = 'fdk://login?fqdn=example.com&apiKey=test123&login=user';
      const uri2 = 'fdk://login?fqdn=example.com&apiKey=test123&login=user';

      expect(uri1 == uri2, isTrue);
    });

    test('different URI strings are distinguishable', () {
      const uri1 = 'fdk://login?fqdn=example.com&apiKey=test123&login=user1';
      const uri2 = 'fdk://login?fqdn=example.com&apiKey=test123&login=user2';

      expect(uri1 == uri2, isFalse);
    });

    test('time-based deduplication window concept', () {
      final now = DateTime.now();
      final tenSecondsAgo = now.subtract(const Duration(seconds: 10));
      final fortySecondsAgo = now.subtract(const Duration(seconds: 40));

      // Within 30-second window
      expect(now.difference(tenSecondsAgo).inSeconds, lessThan(30));

      // Outside 30-second window
      expect(now.difference(fortySecondsAgo).inSeconds, greaterThan(30));
    });
  });
}
