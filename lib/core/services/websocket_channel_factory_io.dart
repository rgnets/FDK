import 'dart:io';

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:rgnets_fdk/core/security/certificate_validator.dart';

/// Creates a WebSocket channel with SSL certificate validation.
///
/// Uses [CertificateValidator] to handle self-signed certificates,
/// accepting them only in debug mode for security.
WebSocketChannel createWebSocketChannel(
  Uri uri, {
  Map<String, dynamic>? headers,
}) {
  // Create a custom HttpClient with certificate validation
  final httpClient = HttpClient()
    ..badCertificateCallback = CertificateValidator().validateCertificate;

  return IOWebSocketChannel.connect(
    uri,
    headers: headers,
    customClient: httpClient,
  );
}
