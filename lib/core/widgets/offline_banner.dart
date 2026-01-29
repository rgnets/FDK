import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/providers/connectivity_provider.dart';
import 'package:rgnets_fdk/core/theme/app_colors.dart';

/// A banner widget that displays the app's connection status.
/// Shows at the bottom of the screen when offline, connecting, or reconnecting.
/// Hides automatically when online.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionStatus = ref.watch(appConnectionStatusProvider);

    return connectionStatus.when(
      data: (status) => _buildBanner(status),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => _buildBanner(AppConnectionStatus.offline),
    );
  }

  Widget _buildBanner(AppConnectionStatus status) {
    if (status == AppConnectionStatus.online) {
      return const SizedBox.shrink();
    }

    final (color, icon, message) = switch (status) {
      AppConnectionStatus.offline => (
        AppColors.error,
        Icons.cloud_off,
        'No connection',
      ),
      AppConnectionStatus.connecting => (
        AppColors.warning,
        Icons.cloud_sync,
        'Connecting...',
      ),
      AppConnectionStatus.reconnecting => (
        AppColors.warning,
        Icons.cloud_sync,
        'Reconnecting...',
      ),
      AppConnectionStatus.online => (
        AppColors.success,
        Icons.cloud_done,
        'Connected',
      ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: color,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
