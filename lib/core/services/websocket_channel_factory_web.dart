import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Creates a WebSocket channel for the web platform.
///
/// Note: Browser WebSocket APIs do not support custom headers.
/// The [headers] parameter (including Authorization) is ignored on web.
/// Authentication must rely on query parameters (e.g., api_key) instead.
WebSocketChannel createWebSocketChannel(
  Uri uri, {
  Map<String, dynamic>? headers,
}) {
  if (headers != null && headers.isNotEmpty) {
    LoggerService.warning(
      'WebSocket headers are not supported on web platform. '
      'Authorization header will not be sent. '
      'Ensure api_key query parameter is included for authentication.',
      tag: 'WebSocketChannelFactory',
    );
  }
  return WebSocketChannel.connect(uri);
}
