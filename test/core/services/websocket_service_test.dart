import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Creates a controllable fake WebSocket channel pair.
///
/// Returns the [WebSocketChannel] to inject into [WebSocketService] and a
/// [StreamController] for simulating server messages.
({WebSocketChannel channel, StreamController<dynamic> controller, List<dynamic> sent}) _createFakeChannel() {
  final controller = StreamController<dynamic>.broadcast();
  final sent = <dynamic>[];

  final channel = _FakeChannel(
    stream: controller.stream,
    onSend: sent.add,
  );

  return (channel: channel, controller: controller, sent: sent);
}

/// Minimal WebSocketChannel fake that avoids implementing the full
/// StreamChannelMixin interface by extending IOWebSocketChannel-style construction.
class _FakeChannel implements WebSocketChannel {
  _FakeChannel({
    required Stream<dynamic> stream,
    required this.onSend,
  }) : _stream = stream;

  final Stream<dynamic> _stream;
  final void Function(dynamic) onSend;
  int? _closeCode;
  String? _closeReason;

  @override
  Stream<dynamic> get stream => _stream;

  @override
  WebSocketSink get sink => _FakeSink(onSend: onSend, onClose: (code, reason) {
    _closeCode = code;
    _closeReason = reason;
  });

  @override
  int? get closeCode => _closeCode;

  @override
  String? get closeReason => _closeReason;

  @override
  String? get protocol => null;

  @override
  Future<void> get ready => Future<void>.value();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSink implements WebSocketSink {
  _FakeSink({required this.onSend, required this.onClose});

  final void Function(dynamic) onSend;
  final void Function(int?, String?) onClose;
  final _doneCompleter = Completer<void>();

  @override
  void add(dynamic data) => onSend(data);

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future<dynamic> addStream(Stream<dynamic> stream) async {
    await for (final data in stream) {
      add(data);
    }
  }

  @override
  Future<void> close([int? closeCode, String? closeReason]) async {
    onClose(closeCode, closeReason);
    if (!_doneCompleter.isCompleted) _doneCompleter.complete();
  }

  @override
  Future<dynamic> get done => _doneCompleter.future;
}

WebSocketConfig _testConfig({
  bool autoReconnect = false,
  bool sendClientPing = false,
}) {
  return WebSocketConfig(
    baseUri: Uri.parse('ws://localhost:9443/ws'),
    autoReconnect: autoReconnect,
    sendClientPing: sendClientPing,
    initialReconnectDelay: const Duration(milliseconds: 10),
    maxReconnectDelay: const Duration(milliseconds: 100),
    heartbeatInterval: const Duration(seconds: 30),
    heartbeatTimeout: const Duration(seconds: 45),
  );
}

void main() {
  late Logger logger;

  setUp(() {
    logger = Logger(level: Level.off);
  });

  group('WebSocketService', () {
    group('initial state', () {
      test('starts in disconnected state', () {
        final fake = _createFakeChannel();
        final svc = WebSocketService(
          config: _testConfig(),
          logger: logger,
          channelFactory: (uri, {headers}) => fake.channel,
        );

        expect(svc.currentState, SocketConnectionState.disconnected);
        expect(svc.isConnected, isFalse);
        expect(svc.lastMessage, isNull);

        svc.dispose();
        fake.controller.close();
      });
    });

    group('connect', () {
      test('transitions to connected state', () async {
        final fake = _createFakeChannel();
        final svc = WebSocketService(
          config: _testConfig(),
          logger: logger,
          channelFactory: (uri, {headers}) => fake.channel,
        );

        await svc.connect(
          WebSocketConnectionParams(uri: Uri.parse('ws://localhost/ws')),
        );

        expect(svc.isConnected, isTrue);
        expect(svc.currentState, SocketConnectionState.connected);

        await svc.dispose();
        await fake.controller.close();
      });

      test('sends handshake message if provided', () async {
        final fake = _createFakeChannel();
        final svc = WebSocketService(
          config: _testConfig(),
          logger: logger,
          channelFactory: (uri, {headers}) => fake.channel,
        );

        await svc.connect(
          WebSocketConnectionParams(
            uri: Uri.parse('ws://localhost/ws'),
            handshakeMessage: {'type': 'hello'},
          ),
        );

        expect(fake.sent, hasLength(1));
        final decoded =
            jsonDecode(fake.sent.first as String) as Map<String, dynamic>;
        expect(decoded['type'], 'hello');

        await svc.dispose();
        await fake.controller.close();
      });
    });

    group('disconnect', () {
      test('transitions to disconnected state', () async {
        final fake = _createFakeChannel();
        final svc = WebSocketService(
          config: _testConfig(),
          logger: logger,
          channelFactory: (uri, {headers}) => fake.channel,
        );

        await svc.connect(
          WebSocketConnectionParams(uri: Uri.parse('ws://localhost/ws')),
        );
        expect(svc.isConnected, isTrue);

        await svc.disconnect(code: 1000, reason: 'test');

        expect(svc.isConnected, isFalse);
        expect(svc.currentState, SocketConnectionState.disconnected);

        await svc.dispose();
        await fake.controller.close();
      });
    });

    group('send', () {
      test('sends JSON-encoded message', () async {
        final fake = _createFakeChannel();
        final svc = WebSocketService(
          config: _testConfig(),
          logger: logger,
          channelFactory: (uri, {headers}) => fake.channel,
        );

        await svc.connect(
          WebSocketConnectionParams(uri: Uri.parse('ws://localhost/ws')),
        );

        svc.send({'command': 'subscribe', 'identifier': '{"channel":"Test"}'});

        expect(fake.sent, hasLength(1));
        final decoded =
            jsonDecode(fake.sent.first as String) as Map<String, dynamic>;
        expect(decoded['command'], 'subscribe');

        await svc.dispose();
        await fake.controller.close();
      });

      test('throws StateError when not connected', () {
        final fake = _createFakeChannel();
        final svc = WebSocketService(
          config: _testConfig(),
          logger: logger,
          channelFactory: (uri, {headers}) => fake.channel,
        );

        expect(
          () => svc.send({'type': 'test'}),
          throwsA(isA<StateError>()),
        );

        svc.dispose();
        fake.controller.close();
      });
    });

    group('message parsing', () {
      test('parses ActionCable confirm_subscription', () async {
        final fake = _createFakeChannel();
        final svc = WebSocketService(
          config: _testConfig(),
          logger: logger,
          channelFactory: (uri, {headers}) => fake.channel,
        );

        await svc.connect(
          WebSocketConnectionParams(uri: Uri.parse('ws://localhost/ws')),
        );

        final messages = <SocketMessage>[];
        svc.messages.listen(messages.add);

        fake.controller.add(jsonEncode({
          'type': 'confirm_subscription',
          'identifier': '{"channel":"RxgChannel"}',
        }));

        await Future<void>.delayed(Duration.zero);

        expect(messages, hasLength(1));
        expect(messages.first.type, 'confirm_subscription');
        expect(
            messages.first.headers?['identifier'], '{"channel":"RxgChannel"}');

        await svc.dispose();
        await fake.controller.close();
      });

      test('parses message with payload', () async {
        final fake = _createFakeChannel();
        final svc = WebSocketService(
          config: _testConfig(),
          logger: logger,
          channelFactory: (uri, {headers}) => fake.channel,
        );

        await svc.connect(
          WebSocketConnectionParams(uri: Uri.parse('ws://localhost/ws')),
        );

        final messages = <SocketMessage>[];
        svc.messages.listen(messages.add);

        fake.controller.add(jsonEncode({
          'type': 'data.snapshot',
          'payload': {'items': [1, 2, 3]},
        }));

        await Future<void>.delayed(Duration.zero);

        expect(messages, hasLength(1));
        expect(messages.first.type, 'data.snapshot');
        expect(messages.first.payload['items'], [1, 2, 3]);

        await svc.dispose();
        await fake.controller.close();
      });

      test('parses ActionCable message with nested message field', () async {
        final fake = _createFakeChannel();
        final svc = WebSocketService(
          config: _testConfig(),
          logger: logger,
          channelFactory: (uri, {headers}) => fake.channel,
        );

        await svc.connect(
          WebSocketConnectionParams(uri: Uri.parse('ws://localhost/ws')),
        );

        final messages = <SocketMessage>[];
        svc.messages.listen(messages.add);

        fake.controller.add(jsonEncode({
          'identifier': '{"channel":"RxgChannel"}',
          'message': {'action': 'snapshot', 'data': [1, 2]},
        }));

        await Future<void>.delayed(Duration.zero);

        expect(messages, hasLength(1));
        expect(messages.first.type, 'snapshot');
        expect(messages.first.payload['data'], [1, 2]);

        await svc.dispose();
        await fake.controller.close();
      });

      test('defaults type to "message" when no type found', () async {
        final fake = _createFakeChannel();
        final svc = WebSocketService(
          config: _testConfig(),
          logger: logger,
          channelFactory: (uri, {headers}) => fake.channel,
        );

        await svc.connect(
          WebSocketConnectionParams(uri: Uri.parse('ws://localhost/ws')),
        );

        final messages = <SocketMessage>[];
        svc.messages.listen(messages.add);

        fake.controller.add(jsonEncode({'data': 'raw'}));

        await Future<void>.delayed(Duration.zero);

        expect(messages, hasLength(1));
        expect(messages.first.type, 'message');

        await svc.dispose();
        await fake.controller.close();
      });

      test('updates lastMessage', () async {
        final fake = _createFakeChannel();
        final svc = WebSocketService(
          config: _testConfig(),
          logger: logger,
          channelFactory: (uri, {headers}) => fake.channel,
        );

        await svc.connect(
          WebSocketConnectionParams(uri: Uri.parse('ws://localhost/ws')),
        );

        fake.controller.add(jsonEncode({'type': 'ping'}));
        await Future<void>.delayed(Duration.zero);

        expect(svc.lastMessage, isNotNull);
        expect(svc.lastMessage!.type, 'ping');

        await svc.dispose();
        await fake.controller.close();
      });
    });

    group('pending requests', () {
      test('request correlates response by request_id', () async {
        final fake = _createFakeChannel();
        final svc = WebSocketService(
          config: _testConfig(),
          logger: logger,
          channelFactory: (uri, {headers}) => fake.channel,
        );

        await svc.connect(
          WebSocketConnectionParams(uri: Uri.parse('ws://localhost/ws')),
        );

        final responseFuture = svc.request(
          {'command': 'message', 'request_id': 'test-123'},
          timeout: const Duration(seconds: 5),
        );

        // Simulate server response with matching request_id
        fake.controller.add(jsonEncode({
          'type': 'response',
          'request_id': 'test-123',
          'payload': {'status': 'ok'},
        }));

        final response = await responseFuture;
        expect(response.type, 'response');
        expect(response.payload['status'], 'ok');

        await svc.dispose();
        await fake.controller.close();
      });

      test('request times out with TimeoutException', () async {
        final fake = _createFakeChannel();
        final svc = WebSocketService(
          config: _testConfig(),
          logger: logger,
          channelFactory: (uri, {headers}) => fake.channel,
        );

        await svc.connect(
          WebSocketConnectionParams(uri: Uri.parse('ws://localhost/ws')),
        );

        expect(
          svc.request(
            {'command': 'message', 'request_id': 'timeout-test'},
            timeout: const Duration(milliseconds: 50),
          ),
          throwsA(isA<TimeoutException>()),
        );

        // Wait for timeout to fire
        await Future<void>.delayed(const Duration(milliseconds: 100));

        await svc.dispose();
        await fake.controller.close();
      });

      test('disconnect fails pending requests', () async {
        final fake = _createFakeChannel();
        final svc = WebSocketService(
          config: _testConfig(),
          logger: logger,
          channelFactory: (uri, {headers}) => fake.channel,
        );

        await svc.connect(
          WebSocketConnectionParams(uri: Uri.parse('ws://localhost/ws')),
        );

        // Start request but don't await - capture the future
        Object? caughtError;
        final responseFuture = svc.request(
          {'command': 'message', 'request_id': 'disconnect-test'},
          timeout: const Duration(seconds: 5),
        ).catchError((Object e) {
          caughtError = e;
          return const SocketMessage(type: 'error', payload: {});
        });

        await svc.disconnect();
        await responseFuture;

        expect(caughtError, isA<StateError>());

        await svc.dispose();
        await fake.controller.close();
      });
    });

    group('connection state stream', () {
      test('emits connected then disconnected', () async {
        final fake = _createFakeChannel();
        final svc = WebSocketService(
          config: _testConfig(),
          logger: logger,
          channelFactory: (uri, {headers}) => fake.channel,
        );

        // Subscribe before connecting to capture all states
        final states = <SocketConnectionState>[];
        svc.connectionState.listen(states.add);

        await svc.connect(
          WebSocketConnectionParams(uri: Uri.parse('ws://localhost/ws')),
        );

        // Give stream time to emit
        await Future<void>.delayed(Duration.zero);

        expect(states, contains(SocketConnectionState.connecting));
        expect(states, contains(SocketConnectionState.connected));

        await svc.disconnect();
        await Future<void>.delayed(Duration.zero);

        expect(states, contains(SocketConnectionState.disconnected));

        await svc.dispose();
        await fake.controller.close();
      });

      test('does not emit duplicate states', () async {
        final fake = _createFakeChannel();
        final svc = WebSocketService(
          config: _testConfig(),
          logger: logger,
          channelFactory: (uri, {headers}) => fake.channel,
        );

        final states = <SocketConnectionState>[];
        svc.connectionState.listen(states.add);

        await svc.connect(
          WebSocketConnectionParams(uri: Uri.parse('ws://localhost/ws')),
        );
        await svc.disconnect();
        await Future<void>.delayed(Duration.zero);
        final countBefore = states.length;

        await svc.disconnect(); // second disconnect should not emit
        await Future<void>.delayed(Duration.zero);

        expect(states.length, countBefore);

        await svc.dispose();
        await fake.controller.close();
      });
    });

    group('sendType', () {
      test('composes envelope with type and payload', () async {
        final fake = _createFakeChannel();
        final svc = WebSocketService(
          config: _testConfig(),
          logger: logger,
          channelFactory: (uri, {headers}) => fake.channel,
        );

        await svc.connect(
          WebSocketConnectionParams(uri: Uri.parse('ws://localhost/ws')),
        );

        svc.sendType('system.ping', payload: {'ts': '2024'});

        expect(fake.sent, hasLength(1));
        final decoded =
            jsonDecode(fake.sent.first as String) as Map<String, dynamic>;
        expect(decoded['type'], 'system.ping');
        expect(decoded['payload']['ts'], '2024');

        await svc.dispose();
        await fake.controller.close();
      });
    });

    group('WebSocketConfig', () {
      test('has correct defaults', () {
        final config = WebSocketConfig(
          baseUri: Uri.parse('ws://test'),
        );
        expect(config.autoReconnect, isTrue);
        expect(config.sendClientPing, isTrue);
        expect(config.initialReconnectDelay, const Duration(seconds: 1));
        expect(config.maxReconnectDelay, const Duration(seconds: 32));
      });
    });

    group('WebSocketConnectionParams', () {
      test('stores uri and optional fields', () {
        final params = WebSocketConnectionParams(
          uri: Uri.parse('ws://test'),
          headers: {'Authorization': 'Bearer token'},
          handshakeMessage: {'type': 'hello'},
        );
        expect(params.uri.toString(), 'ws://test');
        expect(params.headers?['Authorization'], 'Bearer token');
        expect(params.handshakeMessage?['type'], 'hello');
      });
    });

    group('SocketMessage', () {
      test('stores all fields', () {
        const msg = SocketMessage(
          type: 'test',
          payload: {'key': 'value'},
          headers: {'id': 'abc'},
          raw: {'type': 'test', 'key': 'value'},
        );
        expect(msg.type, 'test');
        expect(msg.payload['key'], 'value');
        expect(msg.headers?['id'], 'abc');
        expect(msg.raw?['type'], 'test');
      });
    });
  });
}
