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
  });

  final Uri baseUri;
  final bool autoReconnect;
  final Duration initialReconnectDelay;
  final Duration maxReconnectDelay;
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
  final _lateResponseController = StreamController<SocketMessage>.broadcast();
  final Map<String, _PendingRequest> _pendingRequests = {};

  // ActionCable channel subscription tracking, keyed by channel name (e.g.
  // "RxgChannel"). requestActionCable() waits on this so a register/query
  // isn't fired into a channel the server hasn't confirmed yet — the common
  // case is the brief window right after a reconnect re-subscribes the
  // channel, during which sends get no reply and the caller would otherwise
  // burn its full request timeout.
  final Set<String> _confirmedChannels = {};
  final Map<String, List<Completer<void>>> _channelConfirmWaiters = {};

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

  /// Maximum consecutive reconnect failures before emitting auth failure signal.
  static const int _maxReconnectBeforeAuthCheck = 3;

  /// Emits connection state updates.
  Stream<SocketConnectionState> get connectionState => _stateController.stream;

  /// Emits parsed socket messages.
  Stream<SocketMessage> get messages => _messageController.stream;

  /// Stream that emits the count of consecutive reconnect failures
  /// when multiple failures suggest a potential auth issue.
  Stream<int> get potentialAuthFailures => _authFailureController.stream;

  /// Emits messages that arrived bearing a `request_id` but matched no
  /// in-flight pending request — i.e. the client-side caller already
  /// gave up (timed out, was cancelled, etc.) but the server eventually
  /// replied. Useful as a backstop for slow controllers whose responses
  /// outlive the caller's deadline.
  Stream<SocketMessage> get lateResponses => _lateResponseController.stream;

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
  void send(Map<String, dynamic> message) {
    if (_channel == null) {
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
  }) async {
    // Don't fire into an unconfirmed channel (e.g. mid-reconnect). Wait for
    // the server's confirm_subscription first, but fail open so a tracking
    // miss can't permanently block sends — at worst we fall back to today's
    // behaviour of relying on the request timeout below.
    final channelName = _channelNameOf(channelIdentifier);
    if (channelName != null && !_confirmedChannels.contains(channelName)) {
      final waitBudget = timeout < const Duration(seconds: 10)
          ? timeout
          : const Duration(seconds: 10);
      await _awaitChannelConfirmation(channelName, waitBudget);
    }

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

  /// Marks an ActionCable [channel] confirmed and releases any callers
  /// blocked in [_awaitChannelConfirmation].
  void _markChannelConfirmed(String channel) {
    _confirmedChannels.add(channel);
    final waiters = _channelConfirmWaiters.remove(channel);
    if (waiters != null) {
      for (final waiter in waiters) {
        if (!waiter.isCompleted) {
          waiter.complete();
        }
      }
    }
  }

  /// Waits until [channel] is confirmed by the server, or [timeout] elapses.
  /// On timeout it returns normally (fail open) so the caller proceeds.
  Future<void> _awaitChannelConfirmation(
    String channel,
    Duration timeout,
  ) async {
    if (_confirmedChannels.contains(channel)) {
      return;
    }
    final completer = Completer<void>();
    _channelConfirmWaiters.putIfAbsent(channel, () => []).add(completer);
    try {
      await completer.future.timeout(timeout);
    } on TimeoutException {
      _channelConfirmWaiters[channel]?.remove(completer);
      _logger.w(
        'WebSocketService: proceeding without confirmed subscription for '
        '"$channel" (waited ${timeout.inSeconds}s)',
      );
    }
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
      _logger.i('WebSocketService: Connecting to ${scrubUrlForLog(params.uri)}');
      final channel = _channelFactory(params.uri, headers: params.headers);

      _channel = channel;

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

      final payload = _extractPayload(decoded);
      final type = _extractType(decoded, payload);
      final headers = _extractHeaders(decoded);

      // Track ActionCable channel (un)subscription so requestActionCable()
      // can wait for confirmation before sending into the channel.
      if (type == 'confirm_subscription') {
        final channel = _channelNameOf(decoded['identifier']);
        if (channel != null) {
          _markChannelConfirmed(channel);
        }
      } else if (type == 'reject_subscription') {
        final channel = _channelNameOf(decoded['identifier']);
        if (channel != null) {
          _confirmedChannels.remove(channel);
        }
      }

      _lastHeartbeat = DateTime.now();

      final message = SocketMessage(
        type: type,
        payload: payload,
        headers: headers,
        raw: decoded,
      );

      // Check if this is a response to a pending request
      final requestId = _extractRequestId(decoded, payload);
      if (requestId != null) {
        final pending = _pendingRequests.remove(requestId);
        if (pending != null) {
          if (!pending.completer.isCompleted) {
            pending.cancel();
            pending.completer.complete(message);
          }
        } else {
          // The caller already gave up (timed out / cancelled), but the
          // server replied anyway. Surface it on the late-response stream
          // so downstream features (e.g. registration) can reconcile.
          _logger.w(
            'WebSocketService: late response received (no pending request) '
            'requestId=$requestId type=${message.type}',
          );
          _lateResponseController.add(message);
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
    // The channel is gone; a reconnect must re-subscribe and be re-confirmed.
    // Leave any in-flight confirmation waiters pending — they'll be satisfied
    // by the post-reconnect confirm_subscription or by their own timeout.
    _confirmedChannels.clear();
    await _subscription?.cancel();
    _subscription = null;
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

    // Release anyone blocked waiting for channel confirmation so they don't
    // hang past disposal; they'll proceed and fail on the closed channel.
    for (final waiters in _channelConfirmWaiters.values) {
      for (final waiter in waiters) {
        if (!waiter.isCompleted) {
          waiter.complete();
        }
      }
    }
    _channelConfirmWaiters.clear();
    _confirmedChannels.clear();

    await disconnect();
    await _stateController.close();
    await _messageController.close();
    await _authFailureController.close();
    await _lateResponseController.close();
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

/// Extracts the ActionCable channel name (e.g. "RxgChannel") from a JSON
/// identifier string like `{"channel":"RxgChannel"}`. Returns null if the
/// identifier is absent or not a recognizable channel envelope.
String? _channelNameOf(Object? identifier) {
  if (identifier is! String || identifier.isEmpty) {
    return null;
  }
  try {
    final decoded = jsonDecode(identifier);
    if (decoded is Map && decoded['channel'] is String) {
      return decoded['channel'] as String;
    }
  } on FormatException {
    return null;
  }
  return null;
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
