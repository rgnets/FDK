import 'package:web_socket_channel/web_socket_channel.dart';

import 'websocket_channel_factory_io.dart'
    if (dart.library.io) 'websocket_channel_factory_io.dart'
    if (dart.library.html) 'websocket_channel_factory_web.dart';

/// Connects to a WebSocket endpoint with optional headers.
WebSocketChannel connectWebSocket(
  Uri uri, {
  Map<String, dynamic>? headers,
}) {
  return createWebSocketChannel(uri, headers: headers);
}
