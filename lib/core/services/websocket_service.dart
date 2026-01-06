import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Connection states emitted by [WebSocketService].
enum SocketConnectionState { disconnected, connecting, connected, reconnecting }

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
  const WebSocketConnectionParams({required this.uri, this.handshakeMessage});

  final Uri uri;
  final Map<String, dynamic>? handshakeMessage;
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

typedef WebSocketChannelFactory = WebSocketChannel Function(Uri uri);

/// Service responsible for managing WebSocket connections, reconnection,
/// heartbeat, and message dispatch.
class WebSocketService {
  WebSocketService({
    required WebSocketConfig config,
    Logger? logger,
    WebSocketChannelFactory? channelFactory,
  }) : _config = config,
       _logger = logger ?? Logger(),
       _channelFactory = channelFactory ?? WebSocketChannel.connect;

  final WebSocketConfig _config;
  final Logger _logger;
  final WebSocketChannelFactory _channelFactory;

  final _stateController = StreamController<SocketConnectionState>.broadcast();
  final _messageController = StreamController<SocketMessage>.broadcast();

  SocketConnectionState _state = SocketConnectionState.disconnected;
  WebSocketConnectionParams? _currentParams;
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _heartbeatTimer;
  Timer? _heartbeatWatchdog;
  DateTime? _lastHeartbeat;
  int _reconnectAttempts = 0;
  bool _manuallyClosed = false;

  /// Emits connection state updates.
  Stream<SocketConnectionState> get connectionState => _stateController.stream;

  /// Emits parsed socket messages.
  Stream<SocketMessage> get messages => _messageController.stream;

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
      _logger.i('WebSocketService: Connecting to ${params.uri}');
      final channel = _channelFactory(params.uri);

      _channel = channel;
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
      _logger.e(
        'WebSocketService: Connection failed',
        error: e,
        stackTrace: stack,
      );
      await _handleError(e, stack);
    }
  }

  Future<void> _handleError(Object error, [StackTrace? stack]) async {
    _logger.e(
      'WebSocketService: Error - $error',
      error: error,
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

      if (type == 'system.heartbeat' || type == 'ping') {
        _lastHeartbeat = DateTime.now();
      }

      _messageController.add(
        SocketMessage(
          type: type,
          payload: payload,
          headers: headers,
          raw: decoded,
        ),
      );
      _lastMessage = SocketMessage(
        type: type,
        payload: payload,
        headers: headers,
        raw: decoded,
      );
    } on Object catch (e, stack) {
      _logger.e(
        'WebSocketService: Failed to parse message',
        error: e,
        stackTrace: stack,
      );
    }
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
    await _open(_currentParams!);
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
    await disconnect();
    await _stateController.close();
    await _messageController.close();
  }
}

SocketMessage? _lastMessage;

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
