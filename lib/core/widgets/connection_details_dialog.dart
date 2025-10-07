import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/features/auth/domain/entities/auth_status.dart';
import 'package:rgnets_fdk/features/auth/presentation/providers/auth_notifier.dart';
import 'package:rgnets_fdk/features/settings/presentation/providers/settings_riverpod_provider.dart';

/// Reusable connection details dialog widget
class ConnectionDetailsDialog extends ConsumerStatefulWidget {
  const ConnectionDetailsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const ConnectionDetailsDialog(),
    );
  }

  @override
  ConsumerState<ConnectionDetailsDialog> createState() =>
      _ConnectionDetailsDialogState();
}

class _ConnectionDetailsDialogState
    extends ConsumerState<ConnectionDetailsDialog> {
  Timer? _timer;
  DateTime _lastSyncTime = DateTime.now().subtract(const Duration(minutes: 1));
  final int _responseTimeMs = 42; // Mock response time

  @override
  void initState() {
    super.initState();
    // Update countdown every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _getNextSyncCountdown(SettingsState? settings) {
    if (settings == null) {
      return 'Loading...';
    }

    if (!settings.autoSync) {
      return 'Disabled';
    }

    final syncIntervalSeconds = settings.syncInterval * 60;
    final secondsSinceLastSync = DateTime.now()
        .difference(_lastSyncTime)
        .inSeconds;
    final secondsUntilNextSync = syncIntervalSeconds - secondsSinceLastSync;

    if (secondsUntilNextSync <= 0) {
      // Simulate sync happening
      _lastSyncTime = DateTime.now();
      return 'Syncing...';
    }

    final minutes = secondsUntilNextSync ~/ 60;
    final seconds = secondsUntilNextSync % 60;

    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  String _getLastSyncTime() {
    final hour = _lastSyncTime.hour;
    final minute = _lastSyncTime.minute.toString().padLeft(2, '0');
    final second = _lastSyncTime.second.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute:$second $period';
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authProvider);
    final auth = authAsync.when(
      data: (status) => status,
      loading: () => const AuthStatus.authenticating(),
      error: (_, __) => const AuthStatus.unauthenticated(),
    );
    final settingsAsync = ref.watch(settingsNotifierProvider);
    final settings = settingsAsync.value;

    return AlertDialog(
      backgroundColor: Colors.black87,
      title: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: const DecorationImage(
            image: AssetImage('assets/images/ui_elements/hud_box.png'),
            fit: BoxFit.fill,
            opacity: 0.2,
          ),
        ),
        child: const Text(
          'Connection Details',
          style: TextStyle(color: Colors.white),
        ),
      ),
      content: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: const DecorationImage(
            image: AssetImage('assets/images/ui_elements/hud_box.png'),
            fit: BoxFit.fill,
            opacity: 0.15,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
              'Status',
              auth.maybeWhen(
                authenticated: (_) => 'Connected',
                orElse: () => 'Disconnected',
              ),
              auth.maybeWhen(
                authenticated: (_) => Colors.green,
                orElse: () => Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Server',
              auth.maybeWhen(
                authenticated: (user) => user.apiUrl,
                orElse: () => 'Not configured',
              ),
              null,
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Username',
              auth.maybeWhen(
                authenticated: (user) => user.username,
                orElse: () => 'Not configured',
              ),
              null,
            ),
            const SizedBox(height: 8),
            _buildDetailRow('Mode', 'Read-only (Test)', null),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Response Time',
              '${_responseTimeMs}ms',
              _responseTimeMs < 100
                  ? Colors.green
                  : _responseTimeMs < 500
                  ? Colors.orange
                  : Colors.red,
            ),
            const SizedBox(height: 8),
            _buildDetailRow('Last Sync', _getLastSyncTime(), null),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Next Sync',
              _getNextSyncCountdown(settings),
              Colors.blue,
            ),
            if (EnvironmentConfig.environment != Environment.production) ...[
              const SizedBox(height: 8),
              _buildDetailRow(
                'Env',
                EnvironmentConfig.name.toUpperCase(),
                EnvironmentConfig.isDevelopment ? Colors.green : Colors.orange,
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                'Mock Data',
                EnvironmentConfig.useSyntheticData ? 'Yes' : 'No',
                null,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close', style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, Color? valueColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: valueColor ?? Colors.white),
          ),
        ),
      ],
    );
  }
}
