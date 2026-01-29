import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:rgnets_fdk/core/widgets/hud_tab_bar.dart';
import 'package:rgnets_fdk/core/widgets/unified_list/unified_list_item.dart';
import 'package:rgnets_fdk/core/widgets/widgets.dart';
import 'package:rgnets_fdk/features/room_readiness/domain/entities/room_readiness.dart';
import 'package:rgnets_fdk/features/rooms/presentation/providers/room_ui_state_provider.dart';
import 'package:rgnets_fdk/features/rooms/presentation/providers/room_view_models.dart';
import 'package:rgnets_fdk/features/rooms/presentation/providers/rooms_riverpod_provider.dart';

/// Rooms management screen
class RoomsScreen extends ConsumerStatefulWidget {
  const RoomsScreen({super.key});

  @override
  ConsumerState<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends ConsumerState<RoomsScreen> {
  int _selectedTabIndex = 0; // 0=All, 1=Ready, 2=Issues
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    // Load rooms when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(roomsNotifierProvider.notifier).refresh();
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  String _getFilterFromIndex(int index) {
    switch (index) {
      case 1:
        return 'ready';
      case 2:
        return 'issues';
      default:
        return 'all';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // AppBar removed from RoomsScreen - search and filter functionality preserved in state
    return Scaffold(
      body: Consumer(
        builder: (context, ref, child) {
          final roomsAsync = ref.watch(roomsNotifierProvider);
          final roomStats = ref.watch(roomStatsProvider);
          final currentFilter = _getFilterFromIndex(_selectedTabIndex);
          final filteredRooms = ref.watch(filteredRoomViewModelsProvider(currentFilter));
          
          return roomsAsync.when(
            loading: () => const Center(child: LoadingIndicator()),
            error: (error, stack) => Center(
              child: EmptyState(
                icon: Icons.error_outline,
                title: 'Error loading rooms',
                subtitle: error.toString(),
                actionLabel: 'Retry',
                onAction: () => ref.read(roomsNotifierProvider.notifier).refresh(),
              ),
            ),
            data: (_) {
              return Column(
              children: [
                // Search bar
                SearchBarWidget(
                  controller: _searchController,
                  hintText: 'Search rooms...',
                  onChanged: (query) {
                    ref.read(roomUIStateNotifierProvider.notifier).setSearchQuery(query);
                  },
                  onClear: () {
                    ref.read(roomUIStateNotifierProvider.notifier).clearSearch();
                  },
                ),

                // HUD Tab Bar - taller with full data
                HUDTabBar(
                  height: 80,
                  showFullCount: true,
                  tabs: [
                    HUDTab(
                      label: 'Total Rooms',
                      icon: Icons.meeting_room,
                      count: roomStats.total,
                      filterValue: 'all',
                    ),
                    HUDTab(
                      label: 'Ready',
                      icon: Icons.check_circle,
                      iconColor: Colors.green,
                      count: roomStats.ready,
                      filterValue: 'ready',
                    ),
                    HUDTab(
                      label: 'Issues',
                      icon: Icons.warning,
                      iconColor: Colors.orange,
                      count: roomStats.withIssues,
                      filterValue: 'issues',
                    ),
                  ],
                  selectedIndex: _selectedTabIndex,
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
                
                // Rooms list
                Expanded(
                  child: () {
                    return filteredRooms.isEmpty
                      ? EmptyState(
                          icon: _selectedTabIndex == 1 
                            ? Icons.check_circle
                            : _selectedTabIndex == 2
                              ? Icons.warning
                              : Icons.meeting_room,
                          title: _selectedTabIndex == 1
                            ? 'No ready rooms'
                            : _selectedTabIndex == 2
                              ? 'No rooms with issues'
                              : 'No rooms configured',
                          subtitle: _selectedTabIndex == 0
                            ? 'Rooms will appear here once synced'
                            : 'No rooms match the selected filter',
                          actionLabel: _selectedTabIndex == 0 ? 'Sync Rooms' : null,
                          onAction: _selectedTabIndex == 0 
                            ? () => ref.read(roomsNotifierProvider.notifier).refresh()
                            : null,
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: filteredRooms.length,
                          itemBuilder: (context, index) {
                            final roomVm = filteredRooms[index];
                            final statusColor = _getStatusColor(roomVm.status);
                            final percentage = roomVm.onlinePercentage;

                            // Build subtitle lines
                            final subtitleLines = <UnifiedInfoLine>[
                              UnifiedInfoLine(
                                icon: Icons.devices,
                                text: '${roomVm.onlineDevices}/${roomVm.deviceCount} devices online',
                              ),
                            ];

                            return UnifiedListItem(
                              title: roomVm.name,
                              icon: Icons.meeting_room,
                              status: _getUnifiedItemStatus(roomVm.status),
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
                                    child: Text(
                                      '${percentage.toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    roomVm.statusText,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                              showChevron: true,
                              onTap: () => context.push('/rooms/${roomVm.id}'),
                            );
                          },
                        );
                  }(),
                ),
              ],
            );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(RoomStatus status) {
    switch (status) {
      case RoomStatus.ready:
        return Colors.green;
      case RoomStatus.partial:
        return Colors.orange;
      case RoomStatus.down:
        return Colors.red;
      case RoomStatus.empty:
        return Colors.grey;
    }
  }

  UnifiedItemStatus _getUnifiedItemStatus(RoomStatus status) {
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
}
