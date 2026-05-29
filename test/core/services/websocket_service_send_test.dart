import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Fake sink whose [add] throws a [StateError] once [closed] is set, mirroring
/// the real `WebSocketSink` "Cannot add event after closing" behavior.
class _FakeWebSocketSink implements WebSocketSink {
  final List<dynamic> added = <dynamic>[];
  bool closed = false;

  @override
  void add(dynamic data) {
    if (closed) {
      throw StateError('Cannot add event after closing');
    }
    added.add(data);
  }

  @override
  Future<void> close([int? closeCode, String? closeReason]) async {
    closed = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeWebSocketChannel implements WebSocketChannel {
  _FakeWebSocketChannel() : _controller = StreamController<dynamic>.broadcast();

  // ignore: close_sinks
  final StreamController<dynamic> _controller;

  @override
  final _FakeWebSocketSink sink = _FakeWebSocketSink();

  @override
  Stream<dynamic> get stream => _controller.stream;

  @override
  Future<void> get ready => Future<void>.value();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('WebSocketService.send', () {
    final uri = Uri.parse('wss://example.test/cable');

    late _FakeWebSocketChannel fake;
    late WebSocketService service;

    Future<void> connectService() async {
      service = WebSocketService(
        config: WebSocketConfig(
          baseUri: uri,
          autoReconnect: false,
          sendClientPing: false,
        ),
        channelFactory: (_, {headers}) => fake = _FakeWebSocketChannel(),
      );
      await service.connect(WebSocketConnectionParams(uri: uri));
    }

    tearDown(() async {
      await service.dispose();
    });

    test('writes the encoded payload when connected', () async {
      await connectService();

      service.send({'hello': 'world'});

      expect(fake.sink.added.single, '{"hello":"world"}');
    });

    test(
      'throws a catchable StateError when the sink was closed by the server '
      'before onDone ran (no uncaught "Cannot add event after closing")',
      () async {
        await connectService();

        // Server dropped the connection: the sink is closed but the service's
        // onDone/onError handler has not run yet, so _channel is still set.
        fake.sink.closed = true;

        expect(
          () => service.send({'hello': 'world'}),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              'WebSocket not connected',
            ),
          ),
        );
      },
    );

    test('throws StateError after disconnect', () async {
      await connectService();
      await service.disconnect();

      expect(
        () => service.send({'hello': 'world'}),
        throwsA(isA<StateError>()),
      );
    });
  });
}
