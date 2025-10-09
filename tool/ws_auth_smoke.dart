import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:web_socket_channel/web_socket_channel.dart';

Future<void> main(List<String> args) async {
  final env = Platform.environment;
  final fqdn = _argValue(args, '--fqdn') ?? env['WS_FQDN'] ?? 'zew.netlab.ninja';
  final login =
      _argValue(args, '--login') ?? env['WS_LOGIN'] ?? 'fieldtech';
  final apiKey =
      _argValue(args, '--api-key') ?? env['WS_API_KEY'] ?? 'replace-me';
  final site =
      _argValue(args, '--site') ?? env['WS_SITE'] ?? 'Lab A';
  final wsUrl =
      _argValue(args, '--url') ?? env['WS_URL'] ?? 'wss://$fqdn/ws';

  final uri = Uri.parse(wsUrl);
  stdout.writeln('Connecting to $uri as $login...');

  final channel = WebSocketChannel.connect(uri);
  final handshake = <String, dynamic>{
    'type': 'auth.init',
    'payload': {
      'fqdn': fqdn,
      'login': login,
      'api_key': apiKey,
      'site_name': site,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    },
  };

  unawaited(Future<void>.delayed(const Duration(milliseconds: 100), () {
    channel.sink.add(jsonEncode(handshake));
  }));

  final completer = Completer<int>();
  late final StreamSubscription<dynamic> sub;
  sub = channel.stream.listen(
    (event) {
      final message = _decode(event);
      final type = message['type']?.toString() ?? 'unknown';
      if (type == 'auth.ack') {
        stdout.writeln('✅ auth.ack received: ${jsonEncode(message)}');
        completer.complete(0);
        sub.cancel();
        channel.sink.close();
      } else if (type == 'auth.error') {
        stderr.writeln('❌ auth.error: ${jsonEncode(message)}');
        completer.complete(1);
        sub.cancel();
        channel.sink.close();
      } else {
        stdout.writeln('↪️ $type: ${jsonEncode(message)}');
      }
    },
    onError: (Object error) {
      stderr.writeln('WebSocket error: $error');
      if (!completer.isCompleted) {
        completer.complete(1);
      }
    },
    onDone: () {
      if (!completer.isCompleted) {
        stderr.writeln('Connection closed before auth response');
        completer.complete(1);
      }
    },
  );

  final exitCode = await completer.future.timeout(
    const Duration(seconds: 15),
    onTimeout: () {
      stderr.writeln('Timed out waiting for auth response');
      sub.cancel();
      channel.sink.close();
      return 1;
    },
  );

  exit(exitCode);
}

String? _argValue(List<String> args, String key) {
  final index = args.indexOf(key);
  if (index == -1 || index + 1 >= args.length) {
    return null;
  }
  return args[index + 1];
}

Map<String, dynamic> _decode(dynamic data) {
  if (data is String) {
    return jsonDecode(data) as Map<String, dynamic>;
  }
  if (data is List<int>) {
    return jsonDecode(utf8.decode(data)) as Map<String, dynamic>;
  }
  return const <String, dynamic>{};
}
