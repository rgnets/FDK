import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:rgnets_fdk/core/theme/app_colors.dart';
import 'package:rgnets_fdk/core/widgets/hud_tab_bar.dart';
import 'package:rgnets_fdk/core/widgets/unified_list/unified_list_item.dart';
import 'package:rgnets_fdk/core/widgets/widgets.dart';
import 'package:rgnets_fdk/features/room_readiness/domain/entities/room_readiness.dart';
import 'package:rgnets_fdk/features/room_readiness/presentation/providers/room_readiness_provider.dart';

/// Room readiness screen showing all rooms with their readiness status.
class RoomReadinessScreen extends ConsumerStatefulWidget {
  const RoomReadinessScreen({super.key});

  @override
  ConsumerState<RoomReadinessScreen> createState() => _RoomReadinessScreenState();
}

class _RoomReadinessScreenState extends ConsumerState<RoomReadinessScreen> {
  int _selectedTabIndex = 0; // 0=All, 1=Ready, 2=Partial, 3=Down
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  RoomStatus? _getStatusFilter(int index) {
    switch (index) {
      case 1:
        return RoomStatus.ready;
      case 2:
        return RoomStatus.partial;
      case 3:
        return RoomStatus.down;
      default:
        return null; // All (except empty)
    }
  }

  List<RoomReadinessMetrics> _filterMetrics(
    List<RoomReadinessMetrics> metrics,
    RoomStatus? statusFilter,
  ) {
    // Always exclude empty rooms from the list
    final nonEmptyMetrics = metrics.where((m) => m.status != RoomStatus.empty).toList();

    if (statusFilter == null) {
      return nonEmptyMetrics;
    }

    return nonEmptyMetrics.where((m) => m.status == statusFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer(
        builder: (context, ref, child) {
          final metricsAsync = ref.watch(roomReadinessNotifierProvider);
          final summary = ref.watch(roomReadinessSummaryProvider);

          return metricsAsync.when(
            loading: () => const Center(child: LoadingIndicator()),
            error: (error, stack) => Center(
              child: EmptyState(
                icon: Icons.error_outline,
                title: 'Error loading room readiness',
                subtitle: error.toString(),
                actionLabel: 'Retry',
                onAction: () => ref.read(roomReadinessNotifierProvider.notifier).refresh(),
              ),
            ),
            data: (metrics) {
              final statusFilter = _getStatusFilter(_selectedTabIndex);
              final filteredMetrics = _filterMetrics(metrics, statusFilter);

              return RefreshIndicator(
                onRefresh: () => ref.read(roomReadinessNotifierProvider.notifier).refresh(),
                child: Column(
                  children: [
                    // HUD Tab Bar with status counts
                    HUDTabBar(
                      height: 80,
                      showFullCount: true,
                      tabs: [
                        HUDTab(
                          label: 'All Rooms',
                          icon: Icons.meeting_room,
                          count: summary.totalRooms - summary.emptyRooms,
                          filterValue: 'all',
                        ),
                        HUDTab(
                          label: 'Ready',
                          icon: Icons.check_circle,
                          iconColor: AppColors.success,
                          count: summary.readyRooms,
                          filterValue: 'ready',
                        ),
                        HUDTab(
                          label: 'Partial',
                          icon: Icons.warning,
                          iconColor: AppColors.warning,
                          count: summary.partialRooms,
                          filterValue: 'partial',
                        ),
                      ],
                      selectedIndex: _selectedTabIndex > 2 ? 0 : _selectedTabIndex,
                      onTabSelected: (index) {
                        setState(() => _selectedTabIndex = index);
                      },
                      onActiveTabTapped: () {
                        _scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      },
                    ),

                    // Down rooms indicator (if any)
                    if (summary.downRooms > 0)
                      GestureDetector(
                        onTap: () => setState(() => _selectedTabIndex = 3),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error, color: AppColors.error, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${summary.downRooms} room${summary.downRooms > 1 ? 's' : ''} down',
                                  style: const TextStyle(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (_selectedTabIndex != 3)
                                const Icon(Icons.chevron_right, color: AppColors.error, size: 20),
                            ],
                          ),
                        ),
                      ),

                    // Rooms list
                    Expanded(
                      child: filteredMetrics.isEmpty
                          ? EmptyState(
                              icon: _getEmptyStateIcon(),
                              title: _getEmptyStateTitle(),
                              subtitle: _getEmptyStateSubtitle(),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.only(bottom: 80),
                              itemCount: filteredMetrics.length,
                              itemBuilder: (context, index) {
                                final room = filteredMetrics[index];
                                return _buildRoomItem(room);
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRoomItem(RoomReadinessMetrics room) {
    final statusColor = _getStatusColor(room.status);
    final subtitleLines = <UnifiedInfoLine>[
      UnifiedInfoLine(
        icon: Icons.devices,
        text: '${room.onlineDevices}/${room.totalDevices} devices online',
      ),
    ];

    // Add issue count if any
    if (room.issues.isNotEmpty) {
      subtitleLines.add(
        UnifiedInfoLine(
          icon: Icons.warning_amber,
          text: '${room.issues.length} issue${room.issues.length > 1 ? 's' : ''}',
          color: room.criticalIssueCount > 0 ? AppColors.error : AppColors.warning,
        ),
      );
    }

    return UnifiedListItem(
      title: room.roomName,
      icon: Icons.meeting_room,
      status: _getItemStatus(room.status),
      subtitleLines: subtitleLines,
      trailingWidget: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(room.statusIcon, size: 12, color: statusColor),
                const SizedBox(width: 4),
                Text(
                  room.statusText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          if (room.criticalIssueCount > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${room.criticalIssueCount} critical',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
      showChevron: true,
      onTap: () => context.push('/rooms/${room.roomId}'),
    );
  }

  UnifiedItemStatus _getItemStatus(RoomStatus status) {
    switch (status) {
      case RoomStatus.ready:
        return UnifiedItemStatus.good;
      case RoomStatus.partial:
        return UnifiedItemStatus.warning;
      case RoomStatus.down:
        return UnifiedItemStatus.error;
      case RoomStatus.empty:
        return UnifiedItemStatus.unknown;
    }
  }

  Color _getStatusColor(RoomStatus status) {
    switch (status) {
      case RoomStatus.ready:
        return AppColors.success;
      case RoomStatus.partial:
        return AppColors.warning;
      case RoomStatus.down:
        return AppColors.error;
      case RoomStatus.empty:
        return AppColors.gray600;
    }
  }

  IconData _getEmptyStateIcon() {
    switch (_selectedTabIndex) {
      case 1:
        return Icons.check_circle;
      case 2:
        return Icons.warning;
      case 3:
        return Icons.error;
      default:
        return Icons.meeting_room;
    }
  }

  String _getEmptyStateTitle() {
    switch (_selectedTabIndex) {
      case 1:
        return 'No ready rooms';
      case 2:
        return 'No partial rooms';
      case 3:
        return 'No down rooms';
      default:
        return 'No rooms found';
    }
  }

  String _getEmptyStateSubtitle() {
    switch (_selectedTabIndex) {
      case 1:
        return 'No rooms are fully ready yet';
      case 2:
        return 'No rooms have partial issues';
      case 3:
        return 'All rooms are operational';
      default:
        return 'Rooms will appear here once synced';
    }
  }
}
