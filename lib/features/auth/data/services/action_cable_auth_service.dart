import 'dart:async';
import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';

/// Result of an ActionCable authentication handshake.
class ActionCableAuthResult {
  const ActionCableAuthResult.success()
      : success = true,
        message = '';
  const ActionCableAuthResult.failure(this.message) : success = false;

  final bool success;
  final String message;
}

/// Handles the ActionCable WebSocket handshake protocol.
///
/// This service is responsible for:
/// - Building the ActionCable URI with authentication query parameters
/// - Connecting to the WebSocket server
/// - Subscribing to the RxgChannel
/// - Waiting for subscription confirmation or rejection
///
/// It does NOT manage authentication state (credentials, sessions, etc.).
/// That responsibility remains with the AuthNotifier.
class ActionCableAuthService {
  ActionCableAuthService({
    required WebSocketService webSocketService,
    required Logger logger,
  })  : _service = webSocketService,
        _logger = logger;

  final WebSocketService _service;
  final Logger _logger;

  /// Performs the ActionCable handshake: connect, subscribe, await confirmation.
  ///
  /// Returns [ActionCableAuthResult.success] if the subscription is confirmed,
  /// or [ActionCableAuthResult.failure] with a reason string otherwise.
  Future<ActionCableAuthResult> performHandshake({
    required String fqdn,
    required String token,
    required Uri baseUri,
    Duration connectionTimeout = const Duration(seconds: 10),
    Duration subscriptionTimeout = const Duration(seconds: 15),
  }) async {
    final uri = buildActionCableUri(
      baseUri: baseUri,
      fqdn: fqdn,
      token: token,
    );
    final headers = buildAuthHeaders(token);

    if (_service.isConnected) {
      await _service.disconnect(code: 4000, reason: 'Re-authenticating');
    }

    final identifier = jsonEncode(const {'channel': 'RxgChannel'});
    final subscriptionPayload = <String, dynamic>{
      'command': 'subscribe',
      'identifier': identifier,
    };

    final completer = Completer<ActionCableAuthResult>();

    final subscription = _service.messages.listen((message) {
      _logger.d(
        'ActionCableAuth: message received: '
        'type=${message.type}, payload=${message.payload}',
      );
      if (message.type == 'confirm_subscription' &&
          _identifierMatches(message, identifier)) {
        _logger.i('ActionCableAuth: Subscription confirmed');
        if (!completer.isCompleted) {
          completer.complete(const ActionCableAuthResult.success());
        }
      } else if (message.type == 'reject_subscription' &&
          _identifierMatches(message, identifier)) {
        _logger.e('ActionCableAuth: Subscription REJECTED by server');
        if (!completer.isCompleted) {
          completer.complete(
            const ActionCableAuthResult.failure(
              'Subscription rejected by server',
            ),
          );
        }
      } else if (message.type == 'disconnect') {
        final reason = message.payload['reason'] as String? ??
            message.payload['message'] as String?;
        _logger.e('ActionCableAuth: Server sent disconnect: $reason');
        if (!completer.isCompleted) {
          completer.complete(
            ActionCableAuthResult.failure(
              reason ?? 'Connection closed by server',
            ),
          );
        }
      }
    });

    final stateSubscription = _service.connectionState.listen((connState) {
      _logger.d('ActionCableAuth: connection state changed: $connState');
      if (connState == SocketConnectionState.disconnected &&
          !completer.isCompleted) {
        _logger.e(
          'ActionCableAuth: Connection closed before subscription confirmed',
        );
        completer.complete(
          const ActionCableAuthResult.failure(
            'Connection closed before subscription confirmed',
          ),
        );
      }
    });

    _logger
      ..i('ActionCableAuth: Initiating WebSocket handshake')
      ..d('ActionCableAuth: WebSocket URI: $uri')
      ..d('ActionCableAuth: Subscription identifier: $identifier');

    try {
      _logger.d('ActionCableAuth: Calling service.connect()...');
      await _service
          .connect(WebSocketConnectionParams(uri: uri, headers: headers))
          .timeout(
        connectionTimeout,
        onTimeout: () {
          _logger.e(
            'ActionCableAuth: Connection TIMED OUT '
            'after ${connectionTimeout.inSeconds} seconds',
          );
          throw TimeoutException('Connection to server timed out');
        },
      );

      _logger.d('ActionCableAuth: Connected, sending subscription...');
      _service.send(subscriptionPayload);
      _logger.d(
        'ActionCableAuth: Subscription sent, '
        'waiting for confirmation (${subscriptionTimeout.inSeconds}s timeout)...',
      );

      final result = await completer.future.timeout(
        subscriptionTimeout,
        onTimeout: () {
          _logger.e(
            'ActionCableAuth: Handshake TIMED OUT '
            'after ${subscriptionTimeout.inSeconds} seconds',
          );
          return const ActionCableAuthResult.failure(
            'WebSocket handshake timed out',
          );
        },
      );

      return result;
    } finally {
      await subscription.cancel();
      await stateSubscription.cancel();
    }
  }

  /// Builds the ActionCable WebSocket URI with authentication query parameters.
  static Uri buildActionCableUri({
    required Uri baseUri,
    required String fqdn,
    required String token,
  }) {
    final useBaseUri = EnvironmentConfig.isDevelopment;
    final uri = useBaseUri
        ? baseUri
        : Uri(
            scheme: 'wss',
            host: fqdn,
            path: '/cable',
          );

    final queryParameters = Map<String, String>.from(uri.queryParameters);
    if (token.isNotEmpty) {
      queryParameters['api_key'] = token;
    }

    return uri.replace(
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );
  }

  /// Builds authorization headers for the WebSocket connection.
  static Map<String, dynamic> buildAuthHeaders(String token) {
    if (token.isEmpty) {
      return const {};
    }
    return {'Authorization': 'Bearer $token'};
  }

  static bool _identifierMatches(SocketMessage message, String identifier) {
    final headerIdentifier = message.headers?['identifier'];
    if (headerIdentifier is String && headerIdentifier.isNotEmpty) {
      return headerIdentifier == identifier;
    }
    return false;
  }
}
