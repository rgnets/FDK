import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rgnets_fdk/core/services/navigation_service.dart';
import 'package:rgnets_fdk/features/home/domain/entities/home_statistics.dart';
import 'package:rgnets_fdk/features/home/presentation/providers/home_screen_provider.dart';
import 'package:rgnets_fdk/features/home/presentation/widgets/stat_card.dart';
import 'package:rgnets_fdk/features/rooms/presentation/providers/rooms_riverpod_provider.dart';

/// Network overview section showing device and room statistics
class NetworkOverviewSection extends ConsumerWidget {
  const NetworkOverviewSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeStatsAsync = ref.watch(homeScreenStatisticsProvider);
    final roomsAsync = ref.watch(roomsNotifierProvider);
    final roomStats = ref.watch(roomStatisticsProvider);
    const navigationService = NavigationService();
    
    // Check loading states
    final isHomeStatsLoading = homeStatsAsync.isLoading || homeStatsAsync.isRefreshing;
    final isRoomsLoading = roomsAsync.isLoading || roomsAsync.isRefreshing;
    
    // Extract stats or use default values
    final homeStats = homeStatsAsync.valueOrNull ?? HomeStatistics.loading();
    
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
                value: homeStats.totalDevices.toString(),
                color: Colors.blue,
                subtitle: isHomeStatsLoading ? 'Loading...' : '${homeStats.onlineDevices} online',
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
                value: homeStats.offlineDevices.toString(),
                color: Colors.red,
                subtitle: homeStats.offlineBreakdown,
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
                value: homeStats.missingDocs.toString(),
                color: Colors.blue,
                subtitle: homeStats.missingDocsText,
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