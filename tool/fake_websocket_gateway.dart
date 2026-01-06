import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Simple WebSocket gateway simulator used during Phase 2.
/// Goal: let the Flutter client exercise auth handshake, heartbeats,
/// and event streams before the real backend is live.
Future<void> main(List<String> args) async {
  final config = _GatewayConfig.fromArgs(args);
  final server = await _startServer(config);

  stdout
    ..writeln(
      'Fake gateway running on ws://${config.host}:${config.port}${config.path}',
    )
    ..writeln('Press CTRL+C to stop.');

  await ProcessSignal.sigint.watch().first;
  stdout.writeln('\nStopping fake gateway...');
  await server.close();
  exit(0);
}

Future<HttpServer> _startServer(_GatewayConfig config) async {
  final httpServer = await HttpServer.bind(config.host, config.port);
  final clients = <_ClientConnection>{};

  unawaited(_serveRequests(httpServer, clients, config));
  return httpServer;
}

Future<void> _serveRequests(
  HttpServer httpServer,
  Set<_ClientConnection> clients,
  _GatewayConfig config,
) async {
  await for (final request in httpServer) {
    if (request.uri.path != config.path) {
      final response = request.response
        ..statusCode = HttpStatus.notFound
        ..write('Not Found');
      await response.close();
      continue;
    }

    // Closing handled by _ClientConnection.dispose().
    // ignore: close_sinks
    final socket = await WebSocketTransformer.upgrade(request);
    final client = _ClientConnection(socket, config);
    if (config.verbose) {
      stdout.writeln(
        '[gateway] client connected ${request.connectionInfo?.remoteAddress.address}:${request.connectionInfo?.remotePort}',
      );
    }
    clients.add(client);

    socket.listen(
      (raw) => _handleMessage(raw, client, clients, config),
      onError: (Object error) {
        stderr.writeln('Socket error: $error');
        clients.remove(client);
      },
      onDone: () {
        if (config.verbose) {
          stdout.writeln('[gateway] client disconnected ${client.id}');
        }
        clients.remove(client);
        client.dispose();
      },
    );
  }
}

void _handleMessage(
  dynamic raw,
  _ClientConnection client,
  Set<_ClientConnection> clients,
  _GatewayConfig config,
) {
  try {
    final message = raw is String
        ? jsonDecode(raw) as Map<String, dynamic>
        : jsonDecode(utf8.decode(raw as List<int>)) as Map<String, dynamic>;
    final type = message['type'] as String? ?? '';

    if (type == 'auth.init') {
      if (config.verbose) {
        stdout.writeln(
          '[gateway] auth.init received: ${jsonEncode(message['payload'])}',
        );
      }
      _handleAuthInit(message, client, config);
      return;
    }

    if (type.startsWith('cmd/')) {
      if (config.verbose) {
        stdout.writeln('[gateway] command received: $type');
      }
      client.socket.add(
        jsonEncode({
          'type': 'cmd.ack',
          'payload': {
            'command': type,
            'receivedAt': DateTime.now().toUtc().toIso8601String(),
          },
        }),
      );
      return;
    }

    // Echo unknown types for visibility.
    client.socket.add(
      jsonEncode({
        'type': 'system.warning',
        'payload': {'message': 'Unknown message type "$type"'},
      }),
    );
  } on Object catch (e) {
    stderr.writeln('Failed to decode message: $e');
    client.socket.add(
      jsonEncode({
        'type': 'system.error',
        'payload': {'message': 'Invalid payload', 'error': e.toString()},
      }),
    );
  }
}

void _handleAuthInit(
  Map<String, dynamic> message,
  _ClientConnection client,
  _GatewayConfig config,
) {
  // WebSocket closure is managed by _ClientConnection.dispose().
  // ignore: close_sinks
  final socket = client.socket;
  final payload = message['payload'] as Map<String, dynamic>? ?? const {};
  final timestamp = payload['timestamp'] as String?;
  final issuedAt = timestamp != null ? DateTime.tryParse(timestamp) : null;
  final now = DateTime.now().toUtc();

  if (issuedAt == null ||
      (now.difference(issuedAt.toUtc()).abs() > const Duration(minutes: 15))) {
    socket.add(
      jsonEncode({
        'type': 'auth.error',
        'payload': {'message': 'Timestamp missing or too old'},
      }),
    );
    return;
  }

  socket.add(
    jsonEncode({
      'type': 'auth.ack',
      'payload': {
        'sessionToken': 'fake-token-${client.id}',
        'expiresAt': now.add(const Duration(hours: 2)).toIso8601String(),
        'user': {
          'login': payload['login'] ?? 'unknown',
          'siteName': payload['site_name'] ?? 'Unknown Site',
        },
      },
    }),
  );

  client
    ..startHeartbeat()
    ..startBroadcasts();
  if (config.verbose) {
    stdout.writeln('[gateway] auth.ack sent to client ${client.id}');
  }
}

class _ClientConnection {
  _ClientConnection(this.socket, this.config) : id = _idCounter++;

  final WebSocket socket;
  final _GatewayConfig config;
  final int id;
  Timer? _heartbeatTimer;
  Timer? _broadcastTimer;

  void startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(config.heartbeatInterval, (_) {
      socket.add(
        jsonEncode({
          'type': 'system.heartbeat',
          'payload': {'timestamp': DateTime.now().toUtc().toIso8601String()},
        }),
      );
      if (config.verbose) {
        stdout.writeln('[gateway] heartbeat -> client $id');
      }
    });
  }

  void startBroadcasts() {
    _broadcastTimer?.cancel();
    _broadcastTimer = Timer.periodic(config.broadcastInterval, (_) {
      final now = DateTime.now().toUtc().toIso8601String();
      final messages = [
        {
          'type': 'devices.summary',
          'payload': {
            'generatedAt': now,
            'devices': [
              {
                'id': 1,
                'name': 'Room AP',
                'status': 'online',
                'pms_room_id': 1001,
              },
              {
                'id': 2,
                'name': 'Hallway Switch',
                'status': 'offline',
                'pms_room_id': null,
              },
            ],
          },
        },
        {
          'type': 'rooms.summary',
          'payload': {
            'generatedAt': now,
            'rooms': [
              {
                'id': 1001,
                'name': 'Room 101',
                'deviceCount': 1,
                'readiness': 'READY',
              },
              {
                'id': 1002,
                'name': 'Room 102',
                'deviceCount': 0,
                'readiness': 'MISSING_DATA',
              },
            ],
          },
        },
        {
          'type': 'scanner.events',
          'payload': {
            'event': 'scan.session.update',
            'timestamp': now,
            'deviceType': 'AP',
            'barcodeCount': 2,
            'status': 'complete',
          },
        },
      ];

      for (final message in messages) {
        socket.add(jsonEncode(message));
      }
      if (config.verbose) {
        stdout.writeln('[gateway] broadcast -> client $id');
      }
    });
  }

  void dispose() {
    _heartbeatTimer?.cancel();
    _broadcastTimer?.cancel();
    socket.close();
  }
}

class _GatewayConfig {
  const _GatewayConfig({
    required this.host,
    required this.port,
    required this.path,
    required this.heartbeatInterval,
    required this.broadcastInterval,
    required this.verbose,
  });

  factory _GatewayConfig.fromArgs(List<String> args) {
    var host = '127.0.0.1';
    var port = 9443;
    var path = '/ws';
    var heartbeat = const Duration(seconds: 30);
    var broadcast = const Duration(seconds: 10);
    var verbose = false;

    for (final arg in args) {
      if (arg.startsWith('--host=')) {
        host = arg.split('=').last;
      } else if (arg.startsWith('--port=')) {
        port = int.tryParse(arg.split('=').last) ?? port;
      } else if (arg.startsWith('--path=')) {
        path = arg.split('=').last;
      } else if (arg.startsWith('--heartbeat=')) {
        final seconds = int.tryParse(arg.split('=').last);
        if (seconds != null) {
          heartbeat = Duration(seconds: seconds);
        }
      } else if (arg.startsWith('--broadcast=')) {
        final seconds = int.tryParse(arg.split('=').last);
        if (seconds != null) {
          broadcast = Duration(seconds: seconds);
        }
      } else if (arg == '--verbose') {
        verbose = true;
      }
    }

    return _GatewayConfig(
      host: host,
      port: port,
      path: path.startsWith('/') ? path : '/$path',
      heartbeatInterval: heartbeat,
      broadcastInterval: broadcast,
      verbose: verbose,
    );
  }

  final String host;
  final int port;
  final String path;
  final Duration heartbeatInterval;
  final Duration broadcastInterval;
  final bool verbose;
}

int _idCounter = 1;
