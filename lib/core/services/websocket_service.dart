import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/services/websocket_channel_factory.dart';
import 'package:rgnets_fdk/core/utils/log_redaction.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Connection states emitted by [WebSocketService].
enum SocketConnectionState { disconnected, connecting, connected, reconnecting }

/// Thrown to in-flight requests when the socket closes (drop, reconnect, or an
/// app-lifecycle suspend). It is an [Exception], not an [Error], so existing
/// `on Exception` handlers catch it instead of it surfacing as a raw
/// "Bad state" failure in the UI.
class WebSocketConnectionClosed implements Exception {
  const WebSocketConnectionClosed([this.message = 'WebSocket connection closed']);

  final String message;

  @override
  String toString() => 'WebSocketConnectionClosed: $message';
}

/// Represents a pending request waiting for a response.
class _PendingRequest {
  _PendingRequest({
    required this.completer,
    required this.timeout,
    required this.requestId,
  });

  final Completer<SocketMessage> completer;
  final Timer timeout;
  final String requestId;

  void cancel() {
    timeout.cancel();
  }
}

/// Configuration for the core WebSocket service.
class WebSocketConfig {
  const WebSocketConfig({
    required this.baseUri,
    this.autoReconnect = true,
    this.initialReconnectDelay = const Duration(seconds: 1),
    this.maxReconnectDelay = const Duration(seconds: 32),
    this.connectionTimeout = const Duration(seconds: 10),
    this.heartbeatInterval = const Duration(seconds: 30),
    this.heartbeatTimeout = const Duration(seconds: 45),
    this.sendClientPing = true,
  });

  final Uri baseUri;
  final bool autoReconnect;
  final Duration initialReconnectDelay;
  final Duration maxReconnectDelay;

  /// Wall-clock budget for establishing a connection. Bounds each individual
  /// attempt's upgrade handshake and the whole connect/reconnect cycle: if the
  /// socket cannot reach `connected` within this window, the service stops
  /// retrying and emits [connectionFailed] instead of looping forever (e.g. an
  /// unresolvable host).
  final Duration connectionTimeout;

  final Duration heartbeatInterval;
  final Duration heartbeatTimeout;
  final bool sendClientPing;
}

/// Parameters used when establishing a socket connection.
class WebSocketConnectionParams {
  const WebSocketConnectionParams({
    required this.uri,
    this.handshakeMessage,
    this.headers,
  });

  final Uri uri;
  final Map<String, dynamic>? handshakeMessage;
  final Map<String, dynamic>? headers;
}

/// Envelope for socket messages.
class SocketMessage {
  const SocketMessage({
    required this.type,
    required this.payload,
    this.headers,
    this.raw,
  });

  final String type;
  final Map<String, dynamic> payload;
  final Map<String, dynamic>? headers;
  final Map<String, dynamic>? raw;
}

typedef WebSocketChannelFactory =
    WebSocketChannel Function(Uri uri, {Map<String, dynamic>? headers});

/// Service responsible for managing WebSocket connections, reconnection,
/// heartbeat, and message dispatch.
class WebSocketService {
  WebSocketService({
    required WebSocketConfig config,
    Logger? logger,
    WebSocketChannelFactory? channelFactory,
  }) : _config = config,
       _logger = logger ?? Logger(),
       _channelFactory = channelFactory ?? connectWebSocket;

  final WebSocketConfig _config;
  final Logger _logger;
  final WebSocketChannelFactory _channelFactory;

  final _stateController = StreamController<SocketConnectionState>.broadcast();
  final _messageController = StreamController<SocketMessage>.broadcast();
  final _authFailureController = StreamController<int>.broadcast();
  final _connectionFailedController = StreamController<void>.broadcast();
  final Map<String, _PendingRequest> _pendingRequests = {};

  SocketConnectionState _state = SocketConnectionState.disconnected;
  SocketMessage? _lastMessage;
  WebSocketConnectionParams? _currentParams;
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _heartbeatTimer;
  Timer? _heartbeatWatchdog;
  Timer? _reconnectTimer;
  DateTime? _lastHeartbeat;
  int _reconnectAttempts = 0;
  int _consecutiveReconnectFailures = 0;
  bool _manuallyClosed = false;

  // Wall-clock give-up timer for the current connect/reconnect cycle. Armed on
  // the first attempt of a cycle, cleared on a successful connect. When it fires
  // the service has spent the whole connectionTimeout budget without connecting,
  // so it stops retrying (see _onConnectDeadlineExpired).
  Timer? _connectDeadline;

  // Set once the deadline fired: blocks _scheduleReconnect from restarting the
  // loop. Cleared by a fresh manual connect / lifecycle resume.
  bool _gaveUp = false;

  // True once this params cycle has reached `connected` at least once. The
  // give-up deadline only guards the INITIAL connect (an unreachable host that
  // never connects); a previously-established session that drops keeps
  // reconnecting indefinitely so it heals after a transient network blip.
  // Reset by a fresh manual connect / disconnect.
  bool _hasEverConnected = false;

  // The channel for an in-flight _open() that is still awaiting `ready` (not yet
  // promoted to _channel). Tracked so the give-up / teardown path can close it
  // immediately instead of leaving a half-open socket until its own timeout.
  WebSocketChannel? _pendingChannel;

  // Suspended by the OS app-lifecycle (background), as opposed to a manual
  // disconnect/sign-out. Resume reconnects only what lifecycle suspended.
  bool _lifecycleSuspended = false;

  // Serializes connect/disconnect/suspend/resume so unawaited lifecycle calls
  // can't interleave and dead-end the socket.
  Future<void> _lifecycleQueue = Future<void>.value();

  // Once disposed, queued lifecycle ops must not open a socket or touch the
  // (closing) stream controllers.
  bool _disposed = false;

  // Bumped on every open and every close. Stream callbacks (message/done/error)
  // and the in-progress _open() capture the generation they belong to and no-op
  // if it is stale — so a socket killed during sleep can never tear down or
  // mark "connected" a socket opened by a later reconnect.
  int _connectionGeneration = 0;

  /// Maximum consecutive reconnect failures before emitting auth failure signal.
  static const int _maxReconnectBeforeAuthCheck = 3;

  /// Emits connection state updates.
  Stream<SocketConnectionState> get connectionState => _stateController.stream;

  /// Emits parsed socket messages.
  Stream<SocketMessage> get messages => _messageController.stream;

  /// Stream that emits the count of consecutive reconnect failures
  /// when multiple failures suggest a potential auth issue.
  Stream<int> get potentialAuthFailures => _authFailureController.stream;

  /// Emits when the service gives up connecting after exhausting
  /// [WebSocketConfig.connectionTimeout] without reaching `connected`. Auto
  /// reconnection has stopped; the UI should surface a real error (e.g. the
  /// host is unreachable) rather than show an indefinite spinner.
  Stream<void> get connectionFailed => _connectionFailedController.stream;

  /// Latest socket message, useful for debug tooling.
  SocketMessage? get lastMessage => _lastMessage;

  /// Returns the current connection state.
  SocketConnectionState get currentState => _state;

  /// Whether the socket is currently connected.
  bool get isConnected => _state == SocketConnectionState.connected;

  /// Connects to the given socket endpoint using [params].
  ///
  /// Serialized through the same queue as suspend/resume so a connect can't
  /// interleave with an in-flight lifecycle close and dead-end (connect wants
  /// "connected", so it must not be clobbered by a suspend finishing late).
  Future<void> connect(WebSocketConnectionParams params) =>
      _enqueueLifecycle(() => _connect(params));

  Future<void> _connect(WebSocketConnectionParams params) async {
    _manuallyClosed = false;
    _lifecycleSuspended = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _clearConnectDeadline();
    // Fresh connect (possibly new params / a manual retry after giving up):
    // the give-up deadline guards this attempt again until it connects.
    _hasEverConnected = false;
    _currentParams = params;
    _reconnectAttempts = 0;
    _consecutiveReconnectFailures = 0;
    await _open(params);
  }

  /// Disconnects from the socket and prevents automatic reconnection.
  ///
  /// Serialized through the same queue as connect/suspend/resume so it can't be
  /// reordered against a queued connect (which would otherwise clear
  /// `_manuallyClosed` and reconnect after a sign-out).
  Future<void> disconnect({int? code, String? reason}) =>
      _enqueueLifecycle(() => _disconnect(code: code, reason: reason));

  Future<void> _disconnect({int? code, String? reason}) async {
    _manuallyClosed = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempts = 0;
    _clearConnectDeadline();
    _hasEverConnected = false;
    await _closeChannel(code: code, reason: reason);
    _updateState(SocketConnectionState.disconnected);
  }

  /// Suspends the socket for an OS app-lifecycle pause (screen off /
  /// backgrounded). Closes the channel, fails in-flight requests, and cancels
  /// any pending reconnect so no work runs while backgrounded. Does NOT mark a
  /// manual close, so [resumeForLifecycle] can bring it back. Idempotent.
  Future<void> suspendForLifecycle() => _enqueueLifecycle(_suspendForLifecycle);

  /// Resumes the socket after an app-lifecycle resume. Reconnects exactly once
  /// — but only if the socket was lifecycle-suspended and not manually closed
  /// (e.g. signed out). Idempotent / safe to call when not suspended.
  Future<void> resumeForLifecycle() => _enqueueLifecycle(_resumeForLifecycle);

  // Serialize suspend/resume. The app-scope observer fires these fire-and-forget
  // (unawaited), so a rapid pause→resume could otherwise interleave a resume's
  // _open() with the suspend's still-awaiting _closeChannel() and dead-end the
  // socket. Queuing guarantees resume runs only after suspend fully completes.
  Future<void> _enqueueLifecycle(Future<void> Function() op) {
    final result = _lifecycleQueue.then((_) => op());
    _lifecycleQueue = result.catchError((Object _) {});
    return result;
  }

  Future<void> _suspendForLifecycle() async {
    if (_lifecycleSuspended) {
      return;
    }
    _lifecycleSuspended = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _clearConnectDeadline();
    await _closeChannel();
    _updateState(SocketConnectionState.disconnected);
  }

  Future<void> _resumeForLifecycle() async {
    if (!_lifecycleSuspended) {
      return;
    }
    _lifecycleSuspended = false;
    if (_manuallyClosed || _currentParams == null) {
      return;
    }
    _clearConnectDeadline();
    _reconnectAttempts = 0;
    _consecutiveReconnectFailures = 0;
    await _open(_currentParams!);
  }

  /// Sends a raw payload. The message will be JSON-encoded before dispatch.
  void send(Map<String, dynamic> message) {
    if (_state != SocketConnectionState.connected || _channel == null) {
      throw StateError('WebSocket not connected');
    }
    final encoded = jsonEncode(message);
    _channel!.sink.add(encoded);
  }

  /// Convenience helper that composes a message envelope.
  void sendType(
    String type, {
    Map<String, dynamic>? payload,
    Map<String, dynamic>? headers,
  }) {
    send({
      'type': type,
      if (payload != null) 'payload': payload,
      if (headers != null) 'headers': headers,
    });
  }

  /// Generates a unique request ID.
  String _generateRequestId() {
    return '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(100000)}';
  }

  /// Sends a request and waits for a response with matching request_id.
  /// Returns the response message or throws on timeout.
  Future<SocketMessage> request(
    Map<String, dynamic> message, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (_state != SocketConnectionState.connected || _channel == null) {
      throw StateError('WebSocket not connected');
    }

    final requestId = message['request_id']?.toString() ?? _generateRequestId();
    final messageWithId = Map<String, dynamic>.from(message)
      ..['request_id'] = requestId;

    final completer = Completer<SocketMessage>();
    final timeoutTimer = Timer(timeout, () {
      final pending = _pendingRequests.remove(requestId);
      if (pending != null && !pending.completer.isCompleted) {
        pending.completer.completeError(
          TimeoutException('Request timed out: $requestId'),
        );
      }
    });

    _pendingRequests[requestId] = _PendingRequest(
      completer: completer,
      timeout: timeoutTimer,
      requestId: requestId,
    );

    try {
      send(messageWithId);
      return await completer.future;
    } catch (e) {
      _pendingRequests.remove(requestId)?.cancel();
      rethrow;
    }
  }

  /// Sends an ActionCable formatted request and waits for a response.
  Future<SocketMessage> requestActionCable({
    required String action,
    required String resourceType,
    String channelIdentifier = '{"channel":"RxgChannel"}',
    Map<String, dynamic>? additionalData,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final requestId = 'req-$resourceType-${_generateRequestId()}';

    final data = <String, dynamic>{
      'action': action,
      'resource_type': resourceType,
      'request_id': requestId,
      if (additionalData != null) ...additionalData,
    };

    final message = {
      'command': 'message',
      'identifier': channelIdentifier,
      'data': jsonEncode(data),
      'request_id': requestId,
    };

    return request(message, timeout: timeout);
  }

  Future<void> _open(WebSocketConnectionParams params) async {
    if (_disposed) {
      return;
    }
    if (_state == SocketConnectionState.connected ||
        _state == SocketConnectionState.connecting) {
      _logger.w(
        'WebSocketService: connect() called while already connected/connecting',
      );
      return;
    }
    // Arm the give-up deadline on the first attempt of this cycle; idempotent
    // so it spans every retry until we connect or the budget is exhausted.
    _startConnectDeadline();
    _updateState(
      _reconnectAttempts > 0
          ? SocketConnectionState.reconnecting
          : SocketConnectionState.connecting,
    );
    final generation = ++_connectionGeneration;
    // Declared outside the try so the `finally` can reconcile the pending slot
    // regardless of how this attempt ends (success, stale, Exception, Error).
    WebSocketChannel? channel;
    try {
      // FM-8: scrub api_key from the URI before logging. `params.uri` carries
      // the ActionCable auth token as a query param on production builds.
      _logger.i('WebSocketService: Connecting to ${scrubUrlForLog(params.uri)}');
      channel = _channelFactory(params.uri, headers: params.headers);
      // Track the not-yet-promoted channel so the give-up / teardown path can
      // close it immediately (it isn't in `_channel` until `ready` succeeds).
      _pendingChannel = channel;

      // Wait for the actual TCP + WebSocket upgrade to complete before
      // declaring the connection open.  Without this, the state flips to
      // "connected" immediately (IOWebSocketChannel.connect is lazy) and
      // callers start sending messages into a channel that isn't ready yet.
      // Bound the wait: a host that accepts the socket but stalls the upgrade
      // would otherwise hang here forever, never failing into the retry loop.
      await channel.ready.timeout(
        _config.connectionTimeout,
        onTimeout: () {
          // Tear down the half-open socket — it isn't tracked in `_channel`
          // yet, so the error path below can't close it for us.
          unawaited(channel!.sink.close());
          throw TimeoutException(
            'WebSocket upgrade timed out',
            _config.connectionTimeout,
          );
        },
      );

      // A suspend/disconnect/newer-open/dispose happened while we awaited
      // `ready` — abandon this socket instead of marking the service connected
      // on it (or wiring callbacks after disposal).
      if (_disposed || generation != _connectionGeneration) {
        _logger.d('WebSocketService: Abandoning stale connection attempt');
        unawaited(channel.sink.close());
        return;
      }

      _channel = channel;
      _subscription = channel.stream.listen(
        (data) => _handleMessage(generation, data),
        onDone: () => _handleDone(generation),
        onError: (Object error, StackTrace stack) =>
            _handleError(generation, error, stack),
        cancelOnError: true,
      );

      _hasEverConnected = true;
      _clearConnectDeadline();
      _updateState(SocketConnectionState.connected);
      _startHeartbeat(generation);

      if (params.handshakeMessage != null) {
        _logger.d('WebSocketService: Sending handshake message');
        send(params.handshakeMessage!);
      }
    } on Exception catch (e, stack) {
      // FM-8: socket exceptions can embed the URI (with api_key) in their
      // toString(). Scrub before logging. The `error:` field passed to the
      // logger is intentionally the raw object — the underlying logger's
      // formatter doesn't auto-print it as text in our printer config; if
      // that changes, this scrub becomes the only guarantee.
      _logger.e(
        'WebSocketService: Connection failed: ${scrubErrorForLog(e)}',
        stackTrace: stack,
      );
      await _handleError(generation, e, stack);
    } finally {
      // Clear the pending slot only if this attempt still owns it. A newer
      // _open() that started while we awaited `ready` will have replaced
      // _pendingChannel with its own channel — nulling it here would orphan the
      // newer socket. On success the channel is promoted to _channel (still
      // identical), so clearing the pending pointer is correct.
      if (identical(_pendingChannel, channel)) {
        _pendingChannel = null;
      }
    }
  }

  Future<void> _handleError(int generation, Object error, [StackTrace? stack]) async {
    if (generation != _connectionGeneration) {
      return;
    }
    _logger.e(
      'WebSocketService: Error - ${scrubErrorForLog(error)}',
      stackTrace: stack,
    );
    await _closeChannel();
    if (_config.autoReconnect && !_manuallyClosed && !_lifecycleSuspended) {
      _scheduleReconnect();
    } else {
      _updateState(SocketConnectionState.disconnected);
    }
  }

  Future<void> _handleDone(int generation) async {
    if (generation != _connectionGeneration) {
      return;
    }
    _logger.w('WebSocketService: Connection closed by server');
    await _closeChannel();
    if (_config.autoReconnect && !_manuallyClosed && !_lifecycleSuspended) {
      _scheduleReconnect();
    } else {
      _updateState(SocketConnectionState.disconnected);
    }
  }

  void _handleMessage(int generation, dynamic data) {
    if (generation != _connectionGeneration) {
      return;
    }
    try {
      Map<String, dynamic>? decoded;
      if (data is String) {
        decoded = jsonDecode(data) as Map<String, dynamic>;
      } else if (data is List<int>) {
        decoded = jsonDecode(utf8.decode(data)) as Map<String, dynamic>;
      } else if (data is Map<String, dynamic>) {
        decoded = data;
      }

      if (decoded == null) {
        _logger.w(
          'WebSocketService: Received unsupported message type: ${data.runtimeType}',
        );
        return;
      }

      final payload = _extractPayload(decoded);
      final type = _extractType(decoded, payload);
      final headers = _extractHeaders(decoded);

      _lastHeartbeat = DateTime.now();

      final message = SocketMessage(
        type: type,
        payload: payload,
        headers: headers,
        raw: decoded,
      );

      // Check if this is a response to a pending request
      final requestId = _extractRequestId(decoded, payload);
      if (requestId != null && _pendingRequests.containsKey(requestId)) {
        final pending = _pendingRequests.remove(requestId);
        if (pending != null && !pending.completer.isCompleted) {
          pending.cancel();
          pending.completer.complete(message);
        }
      }

      _messageController.add(message);
      _lastMessage = message;
    } on Object catch (e, stack) {
      _logger.e(
        'WebSocketService: Failed to parse message',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// Extracts request_id from message for request/response correlation.
  String? _extractRequestId(
    Map<String, dynamic> decoded,
    Map<String, dynamic> payload,
  ) {
    // Check various locations where request_id might be
    if (decoded['request_id'] != null) {
      return decoded['request_id'].toString();
    }
    if (payload['request_id'] != null) {
      return payload['request_id'].toString();
    }
    // Check in message field for ActionCable responses
    final messageField = decoded['message'];
    if (messageField is Map<String, dynamic> &&
        messageField['request_id'] != null) {
      return messageField['request_id'].toString();
    }
    return null;
  }

  void _scheduleReconnect() {
    if (_currentParams == null) {
      _logger.w('WebSocketService: No connection params for reconnect');
      return;
    }
    // Reentrancy guard: a single reconnect chain at a time. The watchdog
    // timeout and the socket's own onDone/onError can both land on resume —
    // but the connection-generation token already collapses those to one
    // _handleError, and an active reconnect timer means one is already pending.
    // We deliberately do NOT gate on connecting/reconnecting state here: a
    // failed attempt calls _closeChannel() (which leaves the state untouched)
    // and then needs to schedule the NEXT retry, so a state gate would
    // dead-end the loop.
    if (_disposed ||
        _manuallyClosed ||
        _lifecycleSuspended ||
        _gaveUp ||
        (_reconnectTimer?.isActive ?? false)) {
      return;
    }

    _reconnectAttempts += 1;
    final delay = _computeBackoffDelay(_reconnectAttempts);
    _logger.i('WebSocketService: Reconnecting in ${delay.inMilliseconds}ms');
    _updateState(SocketConnectionState.reconnecting);

    _reconnectTimer = Timer(delay, () async {
      _reconnectTimer = null;
      if (_disposed || _manuallyClosed || _lifecycleSuspended) {
        _logger.d('WebSocketService: Reconnect aborted (closed/suspended)');
        return;
      }

      await _open(_currentParams!);

      // Disposal can land while _open() awaits — don't touch counters or the
      // (closed) auth-failure controller afterward.
      if (_disposed) {
        return;
      }

      if (_state == SocketConnectionState.connected) {
        _consecutiveReconnectFailures = 0;
      } else {
        _consecutiveReconnectFailures++;
        _logger.w(
          'WebSocketService: Reconnect failure #$_consecutiveReconnectFailures',
        );
        if (_consecutiveReconnectFailures >= _maxReconnectBeforeAuthCheck) {
          _logger.w(
            'WebSocketService: Multiple reconnect failures ($_consecutiveReconnectFailures), '
            'may indicate auth issue',
          );
          _authFailureController.add(_consecutiveReconnectFailures);
        }
      }
    });
  }

  Duration _computeBackoffDelay(int attempt) {
    final baseMs = _config.initialReconnectDelay.inMilliseconds;
    final maxMs = _config.maxReconnectDelay.inMilliseconds;
    final delayMs = baseMs * pow(2, attempt - 1);
    return Duration(milliseconds: min(delayMs.toInt(), maxMs));
  }

  /// Arms the connect/reconnect give-up deadline. Idempotent: a cycle's first
  /// attempt starts it and every subsequent retry leaves the running timer
  /// alone, so the whole cycle shares one [WebSocketConfig.connectionTimeout]
  /// budget.
  void _startConnectDeadline() {
    // Only guard the initial connect. Once a session has connected, reconnects
    // after a drop retry indefinitely so the app heals after a transient blip;
    // a never-reachable host still gives up here on the first cycle.
    if (_disposed || _gaveUp || _hasEverConnected || _connectDeadline != null) {
      return;
    }
    _connectDeadline = Timer(_config.connectionTimeout, _onConnectDeadlineExpired);
  }

  void _clearConnectDeadline() {
    _connectDeadline?.cancel();
    _connectDeadline = null;
    _gaveUp = false;
  }

  /// Fired when [WebSocketConfig.connectionTimeout] elapses without reaching
  /// `connected`. Stops the retry loop, tears down any in-flight attempt, and
  /// signals listeners so the UI can show a real error instead of spinning.
  void _onConnectDeadlineExpired() {
    _connectDeadline = null;
    // Nothing to give up on if we already connected, were torn down, or the
    // caller has since disconnected / backgrounded us (those paths cancel this
    // timer, but guard against a callback that fired in the same tick).
    if (_disposed ||
        _manuallyClosed ||
        _lifecycleSuspended ||
        _state == SocketConnectionState.connected) {
      return;
    }
    _gaveUp = true;
    _logger.w(
      'WebSocketService: Giving up — could not connect within '
      '${_config.connectionTimeout.inSeconds}s',
    );
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    // Abandons any in-flight _open() (bumps the generation) and closes a
    // half-open socket so a late `ready` can't resurrect the connection.
    unawaited(_closeChannel());
    // Emit the terminal failure BEFORE the disconnected state change so a
    // listener that reacts to both (e.g. the auth handshake) surfaces the
    // specific "could not reach the server" reason rather than the generic
    // "connection closed" one.
    if (!_connectionFailedController.isClosed) {
      _connectionFailedController.add(null);
    }
    _updateState(SocketConnectionState.disconnected);
  }

  void _startHeartbeat(int generation) {
    _lastHeartbeat = DateTime.now();
    _heartbeatTimer?.cancel();
    _heartbeatWatchdog?.cancel();

    if (_config.sendClientPing) {
      _heartbeatTimer = Timer.periodic(_config.heartbeatInterval, (_) {
        if (_channel == null) {
          return;
        }
        try {
          sendType(
            'system.ping',
            payload: {
              'timestamp': DateTime.now().toUtc().toIso8601String(),
              'platform': kIsWeb ? 'web' : 'flutter',
            },
          );
        } on Object catch (e, stack) {
          _logger.e(
            'WebSocketService: Failed to send ping',
            error: e,
            stackTrace: stack,
          );
        }
      });
    }

    _heartbeatWatchdog = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_lastHeartbeat == null) {
        return;
      }
      final diff = DateTime.now().difference(_lastHeartbeat!);
      if (diff > _config.heartbeatTimeout) {
        _logger.w(
          'WebSocketService: Heartbeat timeout after ${diff.inSeconds}s, closing connection',
        );
        unawaited(
          _handleError(
            generation,
            TimeoutException('Heartbeat timeout (${diff.inSeconds}s)'),
          ),
        );
      }
    });
  }

  Future<void> _closeChannel({int? code, String? reason}) async {
    // Invalidate the current generation so any in-flight stream callback or
    // _open() awaiting `ready` becomes a no-op and can't touch a newer socket.
    _connectionGeneration++;

    _heartbeatTimer?.cancel();
    _heartbeatWatchdog?.cancel();
    _heartbeatTimer = null;
    _heartbeatWatchdog = null;

    // Fail in-flight requests immediately instead of letting them hang to their
    // 30s timeout — on a sleep/resume the socket is gone, so callers should
    // learn now rather than the UI freezing.
    if (_pendingRequests.isNotEmpty) {
      final pending = List<_PendingRequest>.of(_pendingRequests.values);
      _pendingRequests.clear();
      for (final request in pending) {
        request.cancel();
        if (!request.completer.isCompleted) {
          request.completer.completeError(const WebSocketConnectionClosed());
        }
      }
    }

    // Null the fields first, then close the captured locals — overlapping
    // close/open work must never close or null a newer socket.
    final subscription = _subscription;
    final channel = _channel;
    // An attempt still awaiting `ready` lives in _pendingChannel (never both set
    // with _channel). Close it too so a half-open socket can't outlive a give-up.
    final pending = _pendingChannel;
    _subscription = null;
    _channel = null;
    _pendingChannel = null;
    await subscription?.cancel();
    await channel?.sink.close(code, reason);
    if (pending != null && !identical(pending, channel)) {
      unawaited(pending.sink.close());
    }
  }

  void _updateState(SocketConnectionState newState) {
    if (_disposed || _state == newState) {
      return;
    }
    _state = newState;
    _stateController.add(newState);
  }

  /// Releases resources. Call when the service is no longer needed.
  Future<void> dispose() async {
    // Mark disposed first so any queued lifecycle op (a pending connect/resume)
    // becomes a no-op instead of reopening a socket or writing to a closing
    // controller.
    _disposed = true;
    _manuallyClosed = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _connectDeadline?.cancel();
    _connectDeadline = null;

    // Cancel all pending requests
    for (final pending in _pendingRequests.values) {
      pending.cancel();
      if (!pending.completer.isCompleted) {
        pending.completer.completeError(
          StateError('WebSocket service disposed'),
        );
      }
    }
    _pendingRequests.clear();

    // Let any already-queued lifecycle work drain (it no-ops now), then tear
    // the channel down and close the controllers.
    await _lifecycleQueue;
    await _closeChannel();
    await _stateController.close();
    await _messageController.close();
    await _authFailureController.close();
    await _connectionFailedController.close();
  }
}

Map<String, dynamic> _extractPayload(Map<String, dynamic> decoded) {
  final payloadValue = decoded['payload'];
  if (payloadValue is Map<String, dynamic>) {
    return Map<String, dynamic>.from(payloadValue);
  }

  final messageValue = decoded['message'];
  if (messageValue is Map<String, dynamic>) {
    return Map<String, dynamic>.from(messageValue);
  }
  if (messageValue != null) {
    return {'message': messageValue};
  }

  final fallback = Map<String, dynamic>.from(decoded)
    ..remove('type')
    ..remove('identifier')
    ..remove('message')
    ..remove('payload')
    ..remove('headers');
  return fallback;
}

String _extractType(
  Map<String, dynamic> decoded,
  Map<String, dynamic> payload,
) {
  final typeValue = decoded['type'];
  if (typeValue is String && typeValue.isNotEmpty) {
    return typeValue;
  }
  final actionValue = payload['action'];
  if (actionValue is String && actionValue.isNotEmpty) {
    return actionValue;
  }
  return 'message';
}

Map<String, dynamic>? _extractHeaders(Map<String, dynamic> decoded) {
  final headers = decoded['headers'] as Map<String, dynamic>?;
  final identifier = decoded['identifier'];
  if (identifier == null) {
    return headers;
  }
  final merged = <String, dynamic>{'identifier': identifier};
  if (headers != null) {
    merged.addAll(headers);
  }
  return merged;
}
