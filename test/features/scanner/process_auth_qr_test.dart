import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/features/scanner/domain/usecases/process_auth_qr.dart';

void main() {
  group('ProcessAuthQr', () {
    final fixedNow = DateTime.utc(2025, 1, 1, 12, 0, 0);
    ProcessAuthQr buildUseCase() => ProcessAuthQr(clock: () => fixedNow);

    test('parses valid JSON payload', () async {
      final useCase = buildUseCase();
      final payload =
          '''
      {
        "fqdn": "vgw1-01.location.mdu.attwifi.com",
        "login": "fieldtech",
        "api_key": "secret-key",
        "site_name": "Dallas Interurban",
        "timestamp": "${fixedNow.toIso8601String()}",
        "signature": "abc123"
      }
      ''';

      final result = await useCase(
        ProcessAuthQrParams(qrCode: payload),
      );

      expect(result.isRight(), isTrue);
      result.match(
        (failure) => fail('Expected success but got ${failure.message}'),
        (credentials) {
          expect(credentials.fqdn, 'vgw1-01.location.mdu.attwifi.com');
          expect(credentials.login, 'fieldtech');
          expect(credentials.apiKey, 'secret-key');
          expect(credentials.siteName, 'Dallas Interurban');
          expect(credentials.issuedAt, fixedNow);
          expect(credentials.signature, 'abc123');
        },
      );
    });

    test('defaults site name to login when missing', () async {
      final useCase = buildUseCase();
      final payload =
          '''
      {
        "fqdn": "vgw1-01.location.mdu.attwifi.com",
        "login": "fieldtech",
        "api_key": "secret-key",
        "timestamp": "${fixedNow.toIso8601String()}"
      }
      ''';

      final result = await useCase(
        ProcessAuthQrParams(qrCode: payload),
      );

      expect(result.isRight(), isTrue);
      result.match(
        (failure) => fail('Expected success but got ${failure.message}'),
        (credentials) {
          expect(credentials.siteName, 'fieldtech');
        },
      );
    });

    test('defaults timestamp to now when missing', () async {
      final useCase = buildUseCase();
      const payload =
          '''
      {
        "fqdn": "vgw1-01.location.mdu.attwifi.com",
        "login": "fieldtech",
        "api_key": "secret-key",
        "site_name": "Dallas Interurban"
      }
      ''';

      final result = await useCase(
        const ProcessAuthQrParams(qrCode: payload),
      );

      expect(result.isRight(), isTrue);
      result.match(
        (failure) => fail('Expected success but got ${failure.message}'),
        (credentials) {
          expect(credentials.issuedAt, fixedNow);
        },
      );
    });

    test('rejects expired timestamp', () async {
      final useCase = buildUseCase();
      final staleTime = fixedNow.subtract(const Duration(minutes: 16));
      final payload =
          '''
      {
        "fqdn": "vgw1-01.location.mdu.attwifi.com",
        "login": "fieldtech",
        "api_key": "secret-key",
        "site_name": "Dallas Interurban",
        "timestamp": "${staleTime.toIso8601String()}"
      }
      ''';

      final result = await useCase(ProcessAuthQrParams(qrCode: payload));

      expect(result.isLeft(), isTrue);
    });

    test('parses key=value payload', () async {
      final useCase = buildUseCase();
      final payload =
          '''
fqdn=vgw1-01.location.mdu.attwifi.com
login=fieldtech
api_key=secret-key
site_name=Dallas Interurban
timestamp=${fixedNow.toIso8601String()}
''';

      final result = await useCase(ProcessAuthQrParams(qrCode: payload));

      expect(result.isRight(), isTrue);
    });

    test('rejects invalid host', () async {
      final useCase = buildUseCase();
      final payload =
          '''
      {
        "fqdn": "invalid host",
        "login": "fieldtech",
        "api_key": "secret-key",
        "site_name": "Dallas Interurban",
        "timestamp": "${fixedNow.toIso8601String()}"
      }
      ''';

      final result = await useCase(ProcessAuthQrParams(qrCode: payload));

      expect(result.isLeft(), isTrue);
    });
  });
}
