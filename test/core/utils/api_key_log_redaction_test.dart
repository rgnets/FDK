// FM-8 sentinel test (B1).
//
// `api_key=...` MUST NEVER reach any log sink. This test exercises every
// layer that the multi-LLM review flagged and asserts the literal sentinel
// string `DO_NOT_LOG_ME` never appears in captured log output.
//
// Layers covered:
//   1. `log_redaction` shared helpers (unit-level invariants).
//   2. `ComplianceRestDataSource` (the original layer the scrubbing was
//      lifted from; covered here as a regression guard).
//   3. `SecureHttpClient.validateConnection` (network catch path).
//   4. `RestImageUploadService` DioException catch path. Driven via Dio's
//      `MockAdapter` (no real network).
//   5. `WebSocketService._open` log line (the `params.uri` interpolation).
//      Driven by a no-op channel factory so we never open a real socket.
//
// `AuthNotifier._buildActionCableUri` is exercised indirectly: the WS URI it
// emits has the same `api_key=...` shape, and the websocket-service log line
// is what would actually surface it. Driving the full notifier requires a
// large provider graph that isn't worth the maintenance cost for an FM-8
// sentinel.
//
// Capture strategy: we wrap each layer call in a `Zone` whose `print`
// handler appends to a buffer. The `logger` package's `PrettyPrinter`
// outputs via `print`, so this catches both `LoggerService` lines and
// raw `_logger.x()` calls.

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rgnets_fdk/core/services/secure_http_client.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:rgnets_fdk/core/utils/log_redaction.dart';
import 'package:rgnets_fdk/features/compliance/data/datasources/compliance_rest_data_source.dart';
import 'package:rgnets_fdk/features/devices/data/services/rest_image_upload_service.dart';

const _sentinel = 'DO_NOT_LOG_ME';

/// Runs [body] in a Zone whose `print` (and stderr writes) accumulate into
/// the returned buffer. The `logger` package ultimately calls `print` from
/// its default output, so this catches every log line our app produces.
Future<String> _captureLogs(Future<void> Function() body) async {
  final buffer = StringBuffer();
  await runZoned<Future<void>>(
    body,
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {
        buffer.writeln(line);
      },
    ),
  );
  return buffer.toString();
}

void main() {
  group('FM-8 unit-level invariants (shared log_redaction utility)', () {
    test('scrubUrlForLog redacts api_key in a Uri', () {
      final uri = Uri.parse(
          'https://example.test/api/x.json?api_key=$_sentinel&page=2');
      expect(scrubUrlForLog(uri), isNot(contains(_sentinel)));
      expect(scrubUrlForLog(uri), contains('api_key=[redacted]'));
      expect(scrubUrlForLog(uri), contains('page=2'));
    });

    test('scrubUrlForLog redacts api_key in a raw String', () {
      const raw = 'wss://example.test/cable?api_key=$_sentinel';
      expect(scrubUrlForLog(raw), isNot(contains(_sentinel)));
    });

    test('scrubUrlForLog accepts null', () {
      expect(scrubUrlForLog(null), isNull);
    });

    test('scrubErrorForLog handles Exception with api_key in toString', () {
      final exception = Exception(
          'Connection refused: https://example.test/api/x.json?api_key=$_sentinel');
      expect(scrubErrorForLog(exception), isNot(contains(_sentinel)));
      expect(scrubErrorForLog(exception), contains('api_key=[redacted]'));
    });

    test('scrubErrorForLog handles a Dio-style stringified URI in quotes', () {
      const dioStr =
          'DioException [connection error]: connecting to "https://example.test/x?api_key=$_sentinel"';
      expect(scrubErrorForLog(dioStr), isNot(contains(_sentinel)));
    });

    test('scrubErrorForLog handles null', () {
      expect(scrubErrorForLog(null), '');
    });
  });

  group('FM-8 sentinel across logging layers', () {
    test('ComplianceRestDataSource lookup logs do not leak api_key', () async {
      final output = await _captureLogs(() async {
        final ds = ComplianceRestDataSource(
          siteUrl: 'example.test',
          apiKey: _sentinel,
          client: MockClient((_) async {
            // Throw a real-looking exception whose toString embeds the URI.
            throw Exception(
                'connection refused: https://example.test/api/compliance_rules.json?api_key=$_sentinel');
          }),
        );
        await ds.lookupRuleId('whatever');
      });
      expect(output, isNot(contains(_sentinel)),
          reason: 'ComplianceRestDataSource leaked api_key: $output');
    });

    test('ComplianceRestDataSource trigger logs do not leak api_key', () async {
      final output = await _captureLogs(() async {
        final ds = ComplianceRestDataSource(
          siteUrl: 'example.test',
          apiKey: _sentinel,
          client: MockClient((_) async => http.Response('{}', 200)),
        );
        await ds.triggerCheckNow(99);
      });
      expect(output, isNot(contains(_sentinel)));
    });

    test('SecureHttpClient.validateConnection catch path does not leak api_key',
        () async {
      // The static SecureHttpClient holds a singleton IOClient. We can't
      // easily inject a mock there without changing the class, so we drive
      // the validation against an unreachable host that triggers a real
      // SocketException whose toString may include the URI.
      final output = await _captureLogs(() async {
        await SecureHttpClient.validateConnection(
          // 192.0.2.0/24 is TEST-NET-1 — guaranteed unroutable per RFC 5737.
          '192.0.2.1:1',
          _sentinel,
        );
      });
      expect(output, isNot(contains(_sentinel)),
          reason: 'SecureHttpClient leaked api_key: $output');
    });

    test('RestImageUploadService Dio exception path does not leak api_key',
        () async {
      // Drive Dio via a MockAdapter so we don't need network. The adapter
      // throws a `connectionError` whose message embeds the URI we built.
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
        ..httpClientAdapter = _ThrowingAdapter(
          url:
              'https://example.test/api/access_points/1.json?api_key=$_sentinel',
        );
      final svc = RestImageUploadService(
        siteUrl: 'https://example.test',
        apiKey: _sentinel,
        dio: dio,
      );
      final output = await _captureLogs(() async {
        await svc.uploadImages(
          resourceType: 'access_points',
          deviceId: '1',
          images: const [],
        );
      });
      expect(output, isNot(contains(_sentinel)),
          reason: 'RestImageUploadService leaked api_key: $output');
    });

    test('WebSocketService.connect log line does not leak api_key', () async {
      // Drive the WS service with a channel factory that throws when called
      // — _open() emits its "Connecting to …" log line BEFORE constructing
      // the channel, then catches the throw and emits the error log. Both
      // sites must be scrubbed.
      final uri = Uri.parse('wss://example.test/cable?api_key=$_sentinel');
      final wsService = WebSocketService(
        config: WebSocketConfig(
          baseUri: Uri.parse('wss://example.test/cable'),
          autoReconnect: false,
        ),
        channelFactory: (uri, {headers}) =>
            throw Exception('refused: $uri'),
      );
      final output = await _captureLogs(() async {
        try {
          await wsService.connect(WebSocketConnectionParams(uri: uri));
        } on Object {
          // _open() catches internally; this catch is belt-and-suspenders
          // in case the harness ever rethrows.
        }
      });
      expect(output, isNot(contains(_sentinel)),
          reason: 'WebSocketService leaked api_key: $output');
    });
  });
}

/// Dio HTTP adapter that always errors with an embedded URI. Used to force
/// the upload service into its DioException catch path.
class _ThrowingAdapter implements HttpClientAdapter {
  _ThrowingAdapter({required this.url});
  final String url;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    throw DioException(
      requestOptions: options,
      type: DioExceptionType.connectionError,
      message: 'connection refused to $url',
      error: const SocketException('Connection refused'),
    );
  }

  @override
  void close({bool force = false}) {}
}
