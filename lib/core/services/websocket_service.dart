import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/models/websocket_events.dart';
import 'package:rgnets_fdk/core/services/websocket_channel_factory.dart';
import 'package:rgnets_fdk/core/utils/log_redaction.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Connection states emitted by [WebSocketService].
enum SocketConnectionState { disconnected, connecting, connected, reconnecting }

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
    this.heartbeatInterval = const Duration(seconds: 30),
    this.heartbeatTimeout = const Duration(seconds: 45),
    this.sendClientPing = true,
    this.logFrameBreakdown = true,
    this.logPingFrames = false,
  });

  final Uri baseUri;
  final bool autoReconnect;
  final Duration initialReconnectDelay;
  final Duration maxReconnectDelay;
  final Duration heartbeatInterval;
  final Duration heartbeatTimeout;
  final bool sendClientPing;
  final bool logFrameBreakdown;
  final bool logPingFrames;
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
  final Map<String, _PendingRequest> _pendingRequests = {};

  SocketConnectionState _state = SocketConnectionState.disconnected;
  SocketMessage? _lastMessage;
  WebSocketConnectionParams? _currentParams;
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _heartbeatTimer;
  Timer? _heartbeatWatchdog;
  DateTime? _lastHeartbeat;
  int _reconnectAttempts = 0;
  int _consecutiveReconnectFailures = 0;
  bool _manuallyClosed = false;

  /// Tracks whether the current channel's sink has been closed. A live
  /// `_channel` reference is not sufficient to know the sink is writable: the
  /// server can drop the connection (e.g. the rXg reject/404 behavior) before
  /// our `onDone`/`onError` handlers run `_closeChannel`, leaving a brief
  /// window where `sink.add` throws "Cannot add event after closing".
  bool _sinkClosed = false;

  /// Maximum consecutive reconnect failures before emitting auth failure signal.
  static const int _maxReconnectBeforeAuthCheck = 3;

  /// Emits connection state updates.
  Stream<SocketConnectionState> get connectionState => _stateController.stream;

  /// Emits parsed socket messages.
  Stream<SocketMessage> get messages => _messageController.stream;

  /// Stream that emits the count of consecutive reconnect failures
  /// when multiple failures suggest a potential auth issue.
  Stream<int> get potentialAuthFailures => _authFailureController.stream;

  /// Latest socket message, useful for debug tooling.
  SocketMessage? get lastMessage => _lastMessage;

  /// Returns the current connection state.
  SocketConnectionState get currentState => _state;

  /// Whether the socket is currently connected.
  bool get isConnected => _state == SocketConnectionState.connected;

  /// Connects to the given socket endpoint using [params].
  Future<void> connect(WebSocketConnectionParams params) async {
    _manuallyClosed = false;
    _currentParams = params;
    _reconnectAttempts = 0;
    _consecutiveReconnectFailures = 0;
    await _open(params);
  }

  /// Disconnects from the socket and prevents automatic reconnection.
  Future<void> disconnect({int? code, String? reason}) async {
    _manuallyClosed = true;
    _reconnectAttempts = 0;
    await _closeChannel(code: code, reason: reason);
    _updateState(SocketConnectionState.disconnected);
  }

  /// Sends a raw payload. The message will be JSON-encoded before dispatch.
  ///
  /// Throws a [StateError] when the socket is not connected or its sink has
  /// already been closed. Callers (and [request]) treat this as a normal
  /// "not connected" failure rather than an uncaught crash.
  void send(Map<String, dynamic> message) {
    final channel = _channel;
    if (channel == null || _sinkClosed) {
      throw StateError('WebSocket not connected');
    }
    final encoded = jsonEncode(message);
    try {
      channel.sink.add(encoded);
      // ignore: avoid_catching_errors
    } on StateError catch (e) {
      // The sink was closed underneath us before `onDone`/`onError` ran
      // (server dropped the connection). Record it and surface the standard
      // not-connected error so callers handle it like any other disconnect
      // instead of crashing on "Cannot add event after closing".
      _sinkClosed = true;
      _logger.w('WebSocketService: send() on a closed sink: ${e.message}');
      throw StateError('WebSocket not connected');
    }
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
    if (_channel == null) {
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
    String? requestId,
  }) async {
    final effectiveRequestId =
        requestId ?? 'req-$resourceType-${_generateRequestId()}';

    final data = <String, dynamic>{
      'action': action,
      'resource_type': resourceType,
      'request_id': effectiveRequestId,
      if (additionalData != null) ...additionalData,
    };

    final message = {
      'command': 'message',
      'identifier': channelIdentifier,
      'data': jsonEncode(data),
      'request_id': effectiveRequestId,
    };

    return request(message, timeout: timeout);
  }

  Future<void> _open(WebSocketConnectionParams params) async {
    if (_state == SocketConnectionState.connected ||
        _state == SocketConnectionState.connecting) {
      _logger.w(
        'WebSocketService: connect() called while already connected/connecting',
      );
      return;
    }
    _updateState(
      _reconnectAttempts > 0
          ? SocketConnectionState.reconnecting
          : SocketConnectionState.connecting,
    );
    try {
      // FM-8: scrub api_key from the URI before logging. `params.uri` carries
      // the ActionCable auth token as a query param on production builds.
      _logger.i(
        'WebSocketService: Connecting to ${scrubUrlForLog(params.uri)}',
      );
      final channel = _channelFactory(params.uri, headers: params.headers);

      _channel = channel;
      _sinkClosed = false;

      // Wait for the actual TCP + WebSocket upgrade to complete before
      // declaring the connection open.  Without this, the state flips to
      // "connected" immediately (IOWebSocketChannel.connect is lazy) and
      // callers start sending messages into a channel that isn't ready yet.
      await channel.ready;

      _subscription = channel.stream.listen(
        _handleMessage,
        onDone: _handleDone,
        onError: _handleError,
        cancelOnError: true,
      );

      _updateState(SocketConnectionState.connected);
      _startHeartbeat();

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
      await _handleError(e, stack);
    }
  }

  Future<void> _handleError(Object error, [StackTrace? stack]) async {
    _logger.e(
      'WebSocketService: Error - ${scrubErrorForLog(error)}',
      stackTrace: stack,
    );
    await _closeChannel();
    if (_config.autoReconnect && !_manuallyClosed) {
      await _scheduleReconnect();
    } else {
      _updateState(SocketConnectionState.disconnected);
    }
  }

  Future<void> _handleDone() async {
    _logger.w('WebSocketService: Connection closed by server');
    await _closeChannel();
    if (_config.autoReconnect && !_manuallyClosed) {
      await _scheduleReconnect();
    } else {
      _updateState(SocketConnectionState.disconnected);
    }
  }

  void _handleMessage(dynamic data) {
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

      final payload = extractSocketPayload(decoded);
      final type = extractSocketType(decoded, payload);
      final headers = extractSocketHeaders(decoded);

      _lastHeartbeat = DateTime.now();

      final message = SocketMessage(
        type: type,
        payload: payload,
        headers: headers,
        raw: decoded,
      );

      _logIncomingFrameBreakdown(decoded);

      // Check if this is a response to a pending request
      final requestId = extractSocketRequestId(decoded, payload);
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

  void _logIncomingFrameBreakdown(Map<String, dynamic> decoded) {
    if (!kDebugMode || !_config.logFrameBreakdown) {
      return;
    }
    final breakdown = WebSocketEnvelopeBreakdown.fromDecoded(decoded);
    if (breakdown.isPing && !_config.logPingFrames) {
      return;
    }

    final prefix = breakdown.isPing ? '[WS_PAYLOAD:ping]' : '[WS_PAYLOAD]';
    _logger.d('$prefix inbound ${formatForLog(breakdown.toLogMap())}');
  }

  Future<void> _scheduleReconnect() async {
    if (_currentParams == null) {
      _logger.w('WebSocketService: No connection params for reconnect');
      return;
    }
    _reconnectAttempts += 1;
    final delay = _computeBackoffDelay(_reconnectAttempts);
    _logger.i('WebSocketService: Reconnecting in ${delay.inMilliseconds}ms');
    _updateState(SocketConnectionState.reconnecting);
    await Future<void>.delayed(delay);
    if (_manuallyClosed) {
      _logger.d('WebSocketService: Reconnect aborted (manually closed)');
      return;
    }

    // Store state before reconnect attempt
    final wasConnected = _state == SocketConnectionState.connected;

    await _open(_currentParams!);

    // Track reconnection success/failure
    if (_state == SocketConnectionState.connected) {
      // Reconnect succeeded - reset failure counter
      _consecutiveReconnectFailures = 0;
    } else if (!wasConnected) {
      // Reconnect failed
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
  }

  Duration _computeBackoffDelay(int attempt) {
    final baseMs = _config.initialReconnectDelay.inMilliseconds;
    final maxMs = _config.maxReconnectDelay.inMilliseconds;
    final delayMs = baseMs * pow(2, attempt - 1);
    return Duration(milliseconds: min(delayMs.toInt(), maxMs));
  }

  void _startHeartbeat() {
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
            TimeoutException('Heartbeat timeout (${diff.inSeconds}s)'),
          ),
        );
      }
    });
  }

  Future<void> _closeChannel({int? code, String? reason}) async {
    _heartbeatTimer?.cancel();
    _heartbeatWatchdog?.cancel();
    _heartbeatTimer = null;
    _heartbeatWatchdog = null;
    await _subscription?.cancel();
    _subscription = null;
    _sinkClosed = true;
    await _channel?.sink.close(code, reason);
    _channel = null;
  }

  void _updateState(SocketConnectionState newState) {
    if (_state == newState) {
      return;
    }
    _state = newState;
    _stateController.add(newState);
  }

  /// Releases resources. Call when the service is no longer needed.
  Future<void> dispose() async {
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

    await disconnect();
    await _stateController.close();
    await _messageController.close();
    await _authFailureController.close();
  }
}
