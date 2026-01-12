import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rgnets_fdk/core/services/navigation_service.dart';
import 'package:rgnets_fdk/features/devices/presentation/providers/devices_provider.dart';
import 'package:rgnets_fdk/features/home/domain/entities/home_statistics.dart';
import 'package:rgnets_fdk/features/home/presentation/providers/home_screen_provider.dart';
import 'package:rgnets_fdk/features/home/presentation/widgets/stat_card.dart';
import 'package:rgnets_fdk/features/rooms/presentation/providers/rooms_riverpod_provider.dart';
import 'package:rgnets_fdk/core/providers/websocket_providers.dart';

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
    const navigationService = NavigationService();
    
    // Check loading states
    final isHomeStatsLoading = homeStatsAsync.isLoading || homeStatsAsync.isRefreshing;
    final isRoomsLoading = roomsAsync.isLoading || roomsAsync.isRefreshing;
    
    // Extract stats or use default values
    final homeStats = homeStatsAsync.valueOrNull ?? HomeStatistics.loading();
    final hasDeviceData = deviceUpdateAsync.valueOrNull != null;
    final isDeviceStatsLoading =
        !hasDeviceData && (devicesAsync.isLoading || devicesAsync.valueOrNull?.isEmpty == true);
    
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
                icon: Icons.description,
                label: 'Doc Issues',
                value: isDeviceStatsLoading ? '--' : homeStats.missingDocs.toString(),
                color: Colors.blue,
                subtitle: isDeviceStatsLoading ? 'Loading...' : homeStats.missingDocsText,
                onTap: () => navigationService.navigateToNotifications(
                  GoRouter.of(context),
                  tab: NotificationTab.docsMissing,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
