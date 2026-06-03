import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// A controllable fake [WebSocketSink].
class _FakeSink implements WebSocketSink {
  _FakeSink(this._onClose);

  final void Function() _onClose;
  final List<dynamic> added = [];
  bool closed = false;

  @override
  void add(dynamic data) => added.add(data);

  @override
  Future<dynamic> close([int? closeCode, String? closeReason]) async {
    if (!closed) {
      closed = true;
      _onClose();
    }
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future<dynamic> addStream(Stream<dynamic> stream) async {}

  @override
  Future<dynamic> get done => Future<void>.value();
}

/// A controllable fake [WebSocketChannel] for driving the service in tests.
class _FakeChannel implements WebSocketChannel {
  _FakeChannel({bool failReady = false, bool hangReady = false, Object? readyError})
      : _failReady = failReady,
        _hangReady = hangReady,
        _readyError = readyError {
    _sink = _FakeSink(() {
      if (!_inbound.isClosed) _inbound.close();
    });
  }

  final _inbound = StreamController<dynamic>.broadcast();
  final bool _failReady;
  // Never completes its `ready` future — simulates a host that accepts the
  // socket but stalls the upgrade, so the service must time the attempt out.
  final bool _hangReady;
  // A specific error to fail `ready` with (e.g. a SocketException-like message),
  // for exercising connectivity-vs-auth failure classification.
  final Object? _readyError;
  late final _FakeSink _sink;

  /// Simulate an inbound server message.
  void emit(dynamic message) {
    if (!_inbound.isClosed) _inbound.add(message);
  }

  /// Simulate the server/OS closing the socket (fires onDone).
  void serverClose() {
    if (!_inbound.isClosed) _inbound.close();
  }

  /// Simulate a transport error (fires onError).
  void emitError(Object error) {
    if (!_inbound.isClosed) _inbound.addError(error);
  }

  @override
  Stream<dynamic> get stream => _inbound.stream;

  @override
  WebSocketSink get sink => _sink;

  // Built lazily on access so a failing future is consumed by _open's await in
  // the same microtask (never floats as an unhandled async error).
  @override
  Future<void> get ready {
    if (_hangReady) {
      return Completer<void>().future;
    }
    if (_readyError != null) {
      return Future<void>.error(_readyError);
    }
    return _failReady
        ? Future<void>.error(Exception('conn failed'))
        : Future<void>.value();
  }

  @override
  int? get closeCode => null;

  @override
  String? get closeReason => null;

  @override
  String? get protocol => null;

  // StreamChannel adds transform/cast helpers the service never calls.
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  // Tiny delays so reconnect timing is observable without slow tests.
  WebSocketService buildService(
    List<_FakeChannel> channels, {
    required _Counter calls,
    Duration? connectionTimeout,
    int? maxReconnectAttempts,
  }) {
    final config = WebSocketConfig(
      baseUri: Uri.parse('wss://example.test/cable'),
      initialReconnectDelay: const Duration(milliseconds: 20),
      maxReconnectDelay: const Duration(milliseconds: 40),
      connectionTimeout: connectionTimeout ?? const Duration(seconds: 10),
      // Default to unbounded in tests so existing multi-retry cases aren't
      // capped; the give-up-after-max test sets this explicitly.
      maxReconnectAttempts: maxReconnectAttempts,
      sendClientPing: false,
    );
    return WebSocketService(
      config: config,
      channelFactory: (uri, {headers}) {
        calls.value += 1;
        // Past the supplied list, keep handing back failing channels so an
        // all-failing run exercises the give-up path without a RangeError.
        return calls.value <= channels.length
            ? channels[calls.value - 1]
            : _FakeChannel(failReady: true);
      },
    );
  }

  WebSocketConnectionParams paramsFor() =>
      WebSocketConnectionParams(uri: Uri.parse('wss://example.test/cable'));

  group('WebSocketService lifecycle & resilience', () {
    test('send() throws when not connected', () {
      final calls = _Counter();
      final service = buildService([], calls: calls);
      expect(() => service.send({'a': 1}), throwsStateError);
    });

    test('request() throws when not connected', () async {
      final calls = _Counter();
      final service = buildService([], calls: calls);
      await expectLater(service.request({'a': 1}), throwsStateError);
    });

    test('connect() reaches connected with a ready channel', () async {
      final calls = _Counter();
      final ch = _FakeChannel();
      final service = buildService([ch], calls: calls);

      await service.connect(paramsFor());

      expect(service.isConnected, isTrue);
      expect(calls.value, 1);
    });

    test('pending request fails fast when the channel drops (no 30s hang)',
        () async {
      final calls = _Counter();
      final ch = _FakeChannel();
      final service = buildService([ch, _FakeChannel()], calls: calls);
      await service.connect(paramsFor());

      final pending = service.request({'cmd': 'x'}, timeout: const Duration(seconds: 30));
      // Drop the socket immediately.
      ch.emitError(Exception('boom'));

      await expectLater(pending, throwsA(isA<Object>()));
    });

    test('suspendForLifecycle() disconnects and does NOT auto-reconnect',
        () async {
      final calls = _Counter();
      final service = buildService([_FakeChannel(), _FakeChannel()], calls: calls);
      await service.connect(paramsFor());
      expect(calls.value, 1);

      await service.suspendForLifecycle();
      expect(service.isConnected, isFalse);

      // Wait well past the reconnect backoff — no new channel should open.
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(calls.value, 1, reason: 'suspend must not reconnect');
    });

    test('resumeForLifecycle() reconnects after a lifecycle suspend', () async {
      final calls = _Counter();
      final service = buildService([_FakeChannel(), _FakeChannel()], calls: calls);
      await service.connect(paramsFor());
      await service.suspendForLifecycle();

      await service.resumeForLifecycle();

      expect(service.isConnected, isTrue);
      expect(calls.value, 2, reason: 'resume opens exactly one new channel');
    });

    test('resumeForLifecycle() does NOT reconnect after a manual disconnect',
        () async {
      final calls = _Counter();
      final service = buildService([_FakeChannel(), _FakeChannel()], calls: calls);
      await service.connect(paramsFor());

      await service.disconnect();
      await service.resumeForLifecycle();

      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(service.isConnected, isFalse);
      expect(calls.value, 1, reason: 'sign-out/manual close must survive resume');
    });

    test('suspend during reconnect backoff cancels the pending reconnect',
        () async {
      final calls = _Counter();
      final ch = _FakeChannel();
      final service = buildService([ch, _FakeChannel(), _FakeChannel()], calls: calls);
      await service.connect(paramsFor());

      // Trigger a drop -> schedules a reconnect on the 20ms backoff timer.
      ch.emitError(Exception('drop'));
      // Suspend before the backoff fires.
      await service.suspendForLifecycle();

      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(calls.value, 1, reason: 'pending reconnect must be cancelled by suspend');
      expect(service.isConnected, isFalse);
    });

    test('a failed reconnect attempt keeps retrying until it connects', () async {
      // Regression guard: the reconnect mutex must not dead-end the loop when
      // an attempt fails while state is still connecting/reconnecting.
      final calls = _Counter();
      final ch1 = _FakeChannel();
      final failing = _FakeChannel(failReady: true);
      final ch3 = _FakeChannel();
      final service = buildService([ch1, failing, ch3], calls: calls);
      await service.connect(paramsFor());
      expect(service.isConnected, isTrue);

      ch1.emitError(Exception('drop'));
      // backoff: 20ms (failing) then 40ms (ch3) + overhead.
      await Future<void>.delayed(const Duration(milliseconds: 160));

      expect(calls.value, 3, reason: 'retry continues after a failed attempt');
      expect(service.isConnected, isTrue);
    });

    test('pending request fails with a typed Exception (not a bare Error)',
        () async {
      final calls = _Counter();
      final ch = _FakeChannel();
      final service = buildService([ch, _FakeChannel()], calls: calls);
      await service.connect(paramsFor());

      final pending = service.request({'cmd': 'x'});
      // Attach the expectation before suspending so the error has a listener
      // the moment _closeChannel completes it.
      final expectation =
          expectLater(pending, throwsA(isA<WebSocketConnectionClosed>()));
      await service.suspendForLifecycle();
      await expectation;
    });

    test('rapid unawaited suspend then resume ends connected (no dead-end)',
        () async {
      final calls = _Counter();
      final service = buildService([_FakeChannel(), _FakeChannel()], calls: calls);
      await service.connect(paramsFor());

      // Fire-and-forget, exactly as the app-scope observer does — resume must
      // not interleave with the suspend's in-flight close.
      final suspend = service.suspendForLifecycle();
      final resume = service.resumeForLifecycle();
      await Future.wait([suspend, resume]);

      expect(service.isConnected, isTrue, reason: 'resume must win after suspend');
      expect(calls.value, 2);
    });

    test('connect interleaved with an in-flight suspend still ends connected',
        () async {
      final calls = _Counter();
      final service = buildService([_FakeChannel(), _FakeChannel()], calls: calls);
      await service.connect(paramsFor());

      // Unawaited suspend immediately followed by a (re)connect — connect must
      // be serialized after the suspend, not clobbered by it.
      final suspend = service.suspendForLifecycle();
      final reconnect = service.connect(paramsFor());
      await Future.wait([suspend, reconnect]);

      expect(service.isConnected, isTrue);
      expect(calls.value, 2);
    });

    test('suspendForLifecycle() is idempotent', () async {
      final calls = _Counter();
      final service = buildService([_FakeChannel(), _FakeChannel()], calls: calls);
      await service.connect(paramsFor());

      await service.suspendForLifecycle();
      await service.suspendForLifecycle();

      expect(service.isConnected, isFalse);
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(calls.value, 1);
    });

    test('gives up and stops retrying after connectionTimeout', () async {
      // An unresolvable host fails every attempt; the service must stop the
      // reconnect loop once the connectionTimeout budget is spent, rather than
      // retrying forever.
      final calls = _Counter();
      final service = buildService(
        [_FakeChannel(failReady: true)],
        calls: calls,
        connectionTimeout: const Duration(milliseconds: 80),
      );

      final failed = expectLater(service.connectionFailed, emits(null));
      await service.connect(paramsFor());

      // Past the deadline, plus margin for what would be further backoff retries.
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await failed;

      expect(service.isConnected, isFalse);
      final attemptsAtGiveUp = calls.value;
      // No further channels are opened once it has given up.
      await Future<void>.delayed(const Duration(milliseconds: 120));
      expect(calls.value, attemptsAtGiveUp,
          reason: 'reconnect loop must stop after giving up');
    });

    test('a hung ready is timed out and counts as a failed attempt', () async {
      // Host accepts the socket but never completes the upgrade. The attempt
      // must time out (not hang forever) and feed the give-up path.
      final calls = _Counter();
      final service = buildService(
        [_FakeChannel(hangReady: true)],
        calls: calls,
        connectionTimeout: const Duration(milliseconds: 80),
      );

      final failed = expectLater(service.connectionFailed, emits(null));
      await service.connect(paramsFor());

      await Future<void>.delayed(const Duration(milliseconds: 200));
      await failed;
      expect(service.isConnected, isFalse);
    });

    test('a manual connect() preempts a pending reconnect', () async {
      // A manual connect during the reconnect backoff must cancel the pending
      // reconnect and connect via the new attempt, not race it.
      final calls = _Counter();
      final ch1 = _FakeChannel();
      final ch2 = _FakeChannel();
      final ch3 = _FakeChannel();
      final service = buildService([ch1, ch2, ch3], calls: calls);

      await service.connect(paramsFor());
      expect(service.isConnected, isTrue);

      ch1.emitError(Exception('drop')); // schedules a reconnect on the backoff
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await service.connect(paramsFor()); // manual connect via ch2
      await Future<void>.delayed(const Duration(milliseconds: 80));

      expect(service.isConnected, isTrue);
      expect(calls.value, 2,
          reason: 'pending reconnect must not open a third channel');
    });

    test('an established session keeps reconnecting past connectionTimeout',
        () async {
      // Regression guard for the give-up scope: once a session has connected,
      // a later drop must NOT give up after connectionTimeout — it should keep
      // retrying so it heals after a transient network blip.
      final calls = _Counter();
      final ch1 = _FakeChannel();
      final service = buildService(
        [ch1],
        calls: calls,
        connectionTimeout: const Duration(milliseconds: 80),
      );
      var gaveUp = false;
      final sub = service.connectionFailed.listen((_) => gaveUp = true);

      await service.connect(paramsFor());
      expect(service.isConnected, isTrue);

      // Drop the established session; every subsequent attempt fails (buildService
      // hands back failing channels past the list).
      ch1.emitError(Exception('drop'));
      await Future<void>.delayed(const Duration(milliseconds: 300));

      expect(gaveUp, isFalse,
          reason: 'established session must not give up after connectionTimeout');
      expect(calls.value, greaterThan(2),
          reason: 'must keep retrying past the timeout window');

      await sub.cancel();
      await service.disconnect();
    });

    // Connectivity-style errors that must all be classified as network (not
    // auth): native SocketException and the generic web WebSocket failure.
    for (final entry in {
      'native SocketException':
          'WebSocketChannelException: SocketException: Failed host lookup',
      'web generic failure':
          'WebSocketChannelException: WebSocket connection failed.',
    }.entries) {
      test('repeated ${entry.key} reconnects do NOT flag an auth issue',
          () async {
        // A connectivity failure is a network problem, not auth — the
        // potentialAuthFailures signal (which triggers sign-out) must stay
        // silent even on web where only a generic message is available.
        final good = _FakeChannel();
        var first = true;
        var factoryCalls = 0;
        var authSignals = 0;
        final service = WebSocketService(
          config: WebSocketConfig(
            baseUri: Uri.parse('wss://example.test/cable'),
            initialReconnectDelay: const Duration(milliseconds: 20),
            maxReconnectDelay: const Duration(milliseconds: 40),
            maxReconnectAttempts: null, // don't give up — exercise classification
            sendClientPing: false,
          ),
          channelFactory: (uri, {headers}) {
            factoryCalls++;
            if (first) {
              first = false;
              return good;
            }
            return _FakeChannel(readyError: Exception(entry.value));
          },
        );
        final sub = service.potentialAuthFailures.listen((_) => authSignals++);

        await service.connect(paramsFor());
        expect(service.isConnected, isTrue);
        good.emitError(Exception('drop')); // established session drops
        await Future<void>.delayed(const Duration(milliseconds: 250));

        expect(factoryCalls, greaterThanOrEqualTo(4),
            reason: 'must have made the initial + several reconnect attempts so '
                'the >=3-failure threshold was actually crossed');
        expect(authSignals, 0,
            reason: 'network failures must not be reported as auth issues');

        await sub.cancel();
        await service.disconnect();
      });
    }

    test('a 401/403 connect rejection DOES flag a potential auth issue',
        () async {
      final good = _FakeChannel();
      var first = true;
      var authSignals = 0;
      final service = WebSocketService(
        config: WebSocketConfig(
          baseUri: Uri.parse('wss://example.test/cable'),
          initialReconnectDelay: const Duration(milliseconds: 20),
          maxReconnectDelay: const Duration(milliseconds: 40),
          maxReconnectAttempts: null,
          sendClientPing: false,
        ),
        channelFactory: (uri, {headers}) {
          if (first) {
            first = false;
            return good;
          }
          return _FakeChannel(
            readyError: Exception('WebSocketChannelException: HTTP 401 Unauthorized'),
          );
        },
      );
      final sub = service.potentialAuthFailures.listen((_) => authSignals++);

      await service.connect(paramsFor());
      good.emitError(Exception('drop'));
      await Future<void>.delayed(const Duration(milliseconds: 250));

      expect(authSignals, greaterThan(0),
          reason: 'an explicit auth rejection should still flag a potential auth issue');

      await sub.cancel();
      await service.disconnect();
    });

    test('an established session gives up after maxReconnectAttempts', () async {
      // The established-session reconnect must stop after a bounded number of
      // failures instead of churning forever against a dead host.
      final calls = _Counter();
      final ch1 = _FakeChannel();
      var gaveUp = false;
      final service = buildService(
        [ch1],
        calls: calls,
        maxReconnectAttempts: 4,
      );
      final sub = service.connectionFailed.listen((_) => gaveUp = true);

      await service.connect(paramsFor());
      expect(service.isConnected, isTrue);
      ch1.emitError(Exception('drop')); // every later attempt fails
      await Future<void>.delayed(const Duration(milliseconds: 400));

      expect(gaveUp, isTrue, reason: 'must give up after maxReconnectAttempts');
      final attemptsAtGiveUp = calls.value;
      await Future<void>.delayed(const Duration(milliseconds: 120));
      expect(calls.value, attemptsAtGiveUp,
          reason: 'no further attempts after giving up');

      await sub.cancel();
      await service.disconnect();
    });

    test('repeated non-connectivity reconnect failures DO flag an auth issue',
        () async {
      // A non-network repeated failure still surfaces the potential-auth signal.
      final calls = _Counter();
      final good = _FakeChannel();
      var authSignals = 0;
      final service = buildService([good], calls: calls);
      final sub = service.potentialAuthFailures.listen((_) => authSignals++);

      await service.connect(paramsFor());
      expect(service.isConnected, isTrue);
      good.emitError(Exception('drop')); // buildService overflow = 'conn failed'
      await Future<void>.delayed(const Duration(milliseconds: 250));

      expect(authSignals, greaterThan(0),
          reason: 'non-network repeated failures still flag a potential auth issue');

      await sub.cancel();
      await service.disconnect();
    });

    test('a fresh connect() after giving up can succeed', () async {
      // Giving up must not permanently wedge the service: a new connect resets
      // the deadline and connects normally. A toggle decides whether the
      // factory hands back a failing or a healthy channel.
      var healthy = false;
      final service = WebSocketService(
        config: WebSocketConfig(
          baseUri: Uri.parse('wss://example.test/cable'),
          initialReconnectDelay: const Duration(milliseconds: 20),
          maxReconnectDelay: const Duration(milliseconds: 40),
          connectionTimeout: const Duration(milliseconds: 80),
          sendClientPing: false,
        ),
        channelFactory: (uri, {headers}) =>
            healthy ? _FakeChannel() : _FakeChannel(failReady: true),
      );

      await service.connect(paramsFor());
      await expectLater(service.connectionFailed, emits(null));
      expect(service.isConnected, isFalse);

      healthy = true;
      await service.connect(paramsFor());
      expect(service.isConnected, isTrue,
          reason: 'give-up must not wedge future connects');
    });
  });
}

class _Counter {
  int value = 0;
}
