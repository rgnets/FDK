import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rgnets_fdk/core/providers/websocket_sync_providers.dart';
import 'package:rgnets_fdk/core/services/navigation_service.dart';
import 'package:rgnets_fdk/features/devices/presentation/providers/devices_provider.dart';
import 'package:rgnets_fdk/features/home/domain/entities/home_statistics.dart';
import 'package:rgnets_fdk/features/home/presentation/providers/home_screen_provider.dart';
import 'package:rgnets_fdk/features/home/presentation/widgets/stat_card.dart';
import 'package:rgnets_fdk/features/issues/domain/entities/health_notice.dart';
import 'package:rgnets_fdk/features/issues/presentation/providers/health_notices_provider.dart';
import 'package:rgnets_fdk/features/rooms/presentation/providers/rooms_riverpod_provider.dart';

/// Network overview section showing device and room statistics
class NetworkOverviewSection extends ConsumerWidget {
  const NetworkOverviewSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeStatsAsync = ref.watch(homeScreenStatisticsProvider);
    final devicesAsync = ref.watch(devicesNotifierProvider);
    final deviceUpdateAsync = ref.watch(webSocketDeviceLastUpdateProvider);
    final roomsAsync = ref.watch(roomsNotifierProvider);
    final roomStats = ref.watch(roomStatisticsProvider);
    final allNotices = ref.watch(healthNoticesListProvider);

    // Calculate counts from actual notices
    final fatalCount = allNotices.where((n) => n.severity == HealthNoticeSeverity.fatal).length;
    final criticalCount = allNotices.where((n) => n.severity == HealthNoticeSeverity.critical).length;
    final warningCount = allNotices.where((n) => n.severity == HealthNoticeSeverity.warning).length;
    final noticeCount = allNotices.where((n) => n.severity == HealthNoticeSeverity.notice).length;
    final totalIssues = allNotices.length;

    const navigationService = NavigationService();

    // Check loading states
    final isHomeStatsLoading = homeStatsAsync.isLoading || homeStatsAsync.isRefreshing;
    final isRoomsLoading = roomsAsync.isLoading || roomsAsync.isRefreshing;
    
    // Extract stats or use default values
    final homeStats = homeStatsAsync.valueOrNull ?? HomeStatistics.loading();
    final hasDeviceData = deviceUpdateAsync.valueOrNull != null;
    final isDeviceStatsLoading =
        !hasDeviceData && (devicesAsync.isLoading || (devicesAsync.valueOrNull?.isEmpty ?? false));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Network Overview',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.devices,
                label: 'Total Devices',
                value: isDeviceStatsLoading ? '--' : homeStats.totalDevices.toString(),
                color: Colors.blue,
                subtitle: (isHomeStatsLoading || isDeviceStatsLoading)
                    ? 'Loading...'
                    : '${homeStats.onlineDevices} online',
                onTap: () => navigationService.navigateToDevices(GoRouter.of(context)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.meeting_room,
                label: 'Locations',
                value: roomStats.total.toString(),
                color: Colors.green,
                subtitle: isRoomsLoading ? 'Loading...' : '${roomStats.roomsWithIssues} need attention',
                onTap: () => navigationService.navigateToRooms(GoRouter.of(context)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.wifi_off,
                label: 'Offline Devices',
                value: isDeviceStatsLoading ? '--' : homeStats.offlineDevices.toString(),
                color: Colors.red,
                subtitle: isDeviceStatsLoading ? 'Loading...' : homeStats.offlineBreakdown,
                onTap: () => navigationService.navigateToNotifications(
                  GoRouter.of(context), 
                  tab: NotificationTab.offline,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.warning_amber_rounded,
                label: 'Issues',
                value: isDeviceStatsLoading ? '--' : totalIssues.toString(),
                color: fatalCount > 0 || criticalCount > 0
                    ? Colors.red
                    : warningCount > 0
                        ? Colors.orange
                        : Colors.green,
                subtitle: isDeviceStatsLoading
                    ? 'Loading...'
                    : _buildIssuesSubtitle(fatalCount, criticalCount, warningCount, noticeCount),
                onTap: () => context.go('/notifications'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _buildIssuesSubtitle(int fatal, int critical, int warning, int notice) {
    final total = fatal + critical + warning + notice;
    if (total == 0) {
      return 'All healthy';
    }

    final parts = <String>[];
    if (fatal > 0) {
      parts.add('$fatal fatal');
    }
    if (critical > 0) {
      parts.add('$critical critical');
    }
    if (warning > 0) {
      parts.add('$warning warning');
    }
    if (notice > 0) {
      parts.add('$notice notice');
    }

    return parts.take(2).join(', ');
  }
}
