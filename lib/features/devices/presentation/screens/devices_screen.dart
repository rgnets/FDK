import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/utils/list_item_helpers.dart';
import 'package:rgnets_fdk/core/widgets/hud_tab_bar.dart';
import 'package:rgnets_fdk/core/widgets/unified_list/unified_list_item.dart';
import 'package:rgnets_fdk/core/widgets/widgets.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/devices/presentation/providers/device_ui_state_provider.dart';
import 'package:rgnets_fdk/features/devices/presentation/providers/devices_provider.dart';
import 'package:rgnets_fdk/features/devices/presentation/providers/phase_filter_provider.dart';
import 'package:rgnets_fdk/features/devices/presentation/providers/room_filter_provider.dart';
import 'package:rgnets_fdk/features/devices/presentation/providers/status_filter_provider.dart';

/// Screen for managing devices
class DevicesScreen extends ConsumerStatefulWidget {
  const DevicesScreen({super.key});

  @override
  ConsumerState<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends ConsumerState<DevicesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _formatNetworkInfo(Device device) {
    // Safely handle null and empty values using null-aware operators
    final ip = (device.ipAddress?.trim().isEmpty ?? true)
        ? 'No IP'
        : device.ipAddress!.trim();
    final mac = (device.macAddress?.trim().isEmpty ?? true)
        ? 'No MAC'
        : device.macAddress!.trim();

    // Special case: IPv6 addresses are too long to show with MAC
    // Use local variable to avoid multiple null checks
    final ipAddr = device.ipAddress;
    if (ipAddr != null &&
        ipAddr.trim().isNotEmpty &&
        ipAddr.contains(':') &&
        ipAddr.length > 20) {
      return ipAddr.trim();
    }

    return '$ip • $mac';
  }

  @override
  void initState() {
    super.initState();
    // Ensure the UI state matches the selected tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(deviceUIStateNotifierProvider.notifier)
          .setFilterType('access_point');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  int _getTabIndex(String filterType) {
    switch (filterType) {
      case 'access_point':
        return 0;
      case 'switch':
        return 1;
      case 'ont':
        return 2;
      default:
        return 0; // Default to APs
    }
  }

  String _getFilterFromIndex(int index) {
    switch (index) {
      case 0:
        return 'access_point';
      case 1:
        return 'switch';
      case 2:
        return 'ont';
      default:
        return 'access_point';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'online':
        return Icons.check_circle;
      case 'offline':
        return Icons.cancel;
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'online':
        return Colors.green;
      case 'offline':
        return Colors.grey;
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _capitalizeStatus(String status) {
    if (status.isEmpty) {
      return status;
    }
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  Widget _buildFilterRow(WidgetRef ref) {
    final phases = ref.watch(devicePhasesProvider);
    final statuses = ref.watch(deviceStatusesProvider);
    final rooms = ref.watch(deviceRoomsProvider);
    final phaseState = ref.watch(phaseFilterNotifierProvider);
    final statusState = ref.watch(statusFilterNotifierProvider);
    final roomState = ref.watch(roomFilterNotifierProvider);

    // Always show filter if user has an active filter (so they can clear it)
    final hasPhases = phases.length > 1 || phaseState.isFiltering;
    final hasStatuses = statuses.length > 1 || statusState.isFiltering;
    final hasRooms = rooms.length > 1 || roomState.isFiltering;

    // Count how many filters are available
    final activeFilters = [hasPhases, hasStatuses, hasRooms].where((b) => b).length;

    // If no filters have options or active filters, show nothing
    if (activeFilters == 0) {
      return const SizedBox.shrink();
    }

    // Build list of available filter widgets
    final filterWidgets = <Widget>[];
    if (hasRooms) {
      filterWidgets.add(Expanded(child: _buildRoomFilterContent(ref)));
    }
    if (hasPhases) {
      filterWidgets.add(Expanded(child: _buildPhaseFilterContent(ref)));
    }
    if (hasStatuses) {
      filterWidgets.add(Expanded(child: _buildStatusFilterContent(ref)));
    }

    // Add spacing between filters
    final spacedWidgets = <Widget>[];
    for (var i = 0; i < filterWidgets.length; i++) {
      spacedWidgets.add(filterWidgets[i]);
      if (i < filterWidgets.length - 1) {
        spacedWidgets.add(const SizedBox(width: 8));
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: spacedWidgets),
    );
  }

  Widget _buildPhaseFilterContent(WidgetRef ref) {
    final phases = ref.watch(devicePhasesProvider);
    final phaseState = ref.watch(phaseFilterNotifierProvider);
    final isFiltering = phaseState.isFiltering;
    final selectedPhase = phaseState.selectedPhase;

    return PopupMenuButton<String>(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isFiltering
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isFiltering
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFiltering ? Icons.label : Icons.filter_list,
              size: 18,
              color: isFiltering
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isFiltering ? selectedPhase : 'Phase',
                style: TextStyle(
                  color: isFiltering
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: isFiltering
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ],
        ),
      ),
      itemBuilder: (BuildContext context) {
        return phases.map((String phase) {
          final isSelected = phase == selectedPhase;
          return PopupMenuItem<String>(
            value: phase,
            child: Row(
              children: [
                Icon(
                  phase == PhaseFilterState.allPhases
                      ? Icons.filter_list_off
                      : Icons.label,
                  size: 18,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    phase,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          );
        }).toList();
      },
      onSelected: (String newPhase) {
        ref
            .read(deviceUIStateNotifierProvider.notifier)
            .setPhaseFilter(newPhase);
      },
    );
  }

  Widget _buildStatusFilterContent(WidgetRef ref) {
    final statuses = ref.watch(deviceStatusesProvider);
    final statusState = ref.watch(statusFilterNotifierProvider);
    final isFiltering = statusState.isFiltering;
    final selectedStatus = statusState.selectedStatus;

    return PopupMenuButton<String>(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isFiltering
              ? _getStatusColor(selectedStatus)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isFiltering
                ? _getStatusColor(selectedStatus)
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFiltering ? _getStatusIcon(selectedStatus) : Icons.filter_list,
              size: 18,
              color: isFiltering
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isFiltering ? _capitalizeStatus(selectedStatus) : 'Status',
                style: TextStyle(
                  color: isFiltering
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: isFiltering
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ],
        ),
      ),
      itemBuilder: (BuildContext context) {
        return statuses.map((String status) {
          final isSelected = status == selectedStatus;
          final isAllStatuses = status == StatusFilterState.allStatuses;
          return PopupMenuItem<String>(
            value: status,
            child: Row(
              children: [
                Icon(
                  isAllStatuses
                      ? Icons.filter_list_off
                      : _getStatusIcon(status),
                  size: 18,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : isAllStatuses
                      ? Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7)
                      : _getStatusColor(status),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isAllStatuses ? status : _capitalizeStatus(status),
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          );
        }).toList();
      },
      onSelected: (String newStatus) {
        ref
            .read(deviceUIStateNotifierProvider.notifier)
            .setStatusFilter(newStatus);
      },
    );
  }

  Widget _buildRoomFilterContent(WidgetRef ref) {
    final rooms = ref.watch(deviceRoomsProvider);
    final roomState = ref.watch(roomFilterNotifierProvider);
    final isFiltering = roomState.isFiltering;
    final selectedRoom = roomState.selectedRoom;

    return PopupMenuButton<String>(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isFiltering
              ? Theme.of(context).colorScheme.tertiary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isFiltering
                ? Theme.of(context).colorScheme.tertiary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFiltering ? Icons.meeting_room : Icons.filter_list,
              size: 18,
              color: isFiltering
                  ? Theme.of(context).colorScheme.onTertiary
                  : Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isFiltering ? selectedRoom : 'Room',
                style: TextStyle(
                  color: isFiltering
                      ? Theme.of(context).colorScheme.onTertiary
                      : Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: isFiltering
                  ? Theme.of(context).colorScheme.onTertiary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ],
        ),
      ),
      itemBuilder: (BuildContext context) {
        return rooms.map((String room) {
          final isSelected = room == selectedRoom;
          final isAllRooms = room == RoomFilterState.allRooms;
          return PopupMenuItem<String>(
            value: room,
            child: Row(
              children: [
                Icon(
                  isAllRooms ? Icons.filter_list_off : Icons.meeting_room,
                  size: 18,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    room,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          );
        }).toList();
      },
      onSelected: (String newRoom) {
        ref
            .read(deviceUIStateNotifierProvider.notifier)
            .setRoomFilter(newRoom);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // AppBar removed from DevicesScreen - search and menu functionality needs to be relocated
    LoggerService.debug(
      'DevicesScreen: AppBar removed, search functionality preserved in state',
    );
    return Scaffold(
      body: Consumer(
        builder: (context, ref, child) {
          // Consumer builder executing - watching providers
          final devicesAsync = ref.watch(devicesNotifierProvider);
          // Device state information available in logger
          if (devicesAsync.hasValue) {
            LoggerService.debug(
              'Device count: ${devicesAsync.value?.length ?? 0}',
            );
          }
          final filteredDevices = ref.watch(filteredDevicesListProvider);
          final mockDataState = ref.watch(mockDataStateProvider);

          return devicesAsync.when(
            loading: () => const DeviceListSkeleton(),
            error: (error, stack) => Center(
              child: EmptyState(
                icon: Icons.error_outline,
                title: 'Error loading devices',
                subtitle: error.toString(),
                actionLabel: 'Retry',
                onAction: () =>
                    ref.read(devicesNotifierProvider.notifier).userRefresh(),
              ),
            ),
            data: (devices) {
              // No RefreshIndicator - WebSocket provides real-time updates
              return Column(
                children: [
                  // Data source indicator
                  if (mockDataState.isUsingMockData)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      color: Colors.orange.withValues(alpha: 0.1),
                      child: Row(
                        children: [
                          Icon(
                            Icons.developer_mode,
                            color: Colors.orange[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Using Mock Data',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[800],
                                    fontSize: 14,
                                  ),
                                ),
                                if (mockDataState.apiErrorMessage != null)
                                  Text(
                                    mockDataState.apiErrorMessage!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange[700],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Search bar
                  SearchBarWidget(
                    controller: _searchController,
                    hintText: 'Search devices...',
                    onChanged: (query) {
                      ref
                          .read(deviceUIStateNotifierProvider.notifier)
                          .setSearchQuery(query);
                    },
                    onClear: () {
                      ref
                          .read(deviceUIStateNotifierProvider.notifier)
                          .clearSearch();
                    },
                  ),

                  // Filter bars (phase and status)
                  _buildFilterRow(ref),

                  // HUD Tab Bar - taller with full data
                  Builder(
                    builder: (context) {
                      final uiState = ref.watch(deviceUIStateNotifierProvider);

                      final apCount = devices
                          .where((d) => d.type == 'access_point')
                          .length;
                      final switchCount = devices
                          .where((d) => d.type == 'switch')
                          .length;
                      final ontCount = devices
                          .where((d) => d.type == 'ont')
                          .length;

                      return HUDTabBar(
                        height: 80,
                        showFullCount: true,
                        tabs: [
                          HUDTab(
                            label: 'Access Points',
                            icon: Icons.wifi,
                            iconColor: Colors.blue,
                            count: apCount,
                            filterValue: 'access_point',
                          ),
                          HUDTab(
                            label: 'Switches',
                            icon: Icons.hub,
                            iconColor: Colors.green,
                            count: switchCount,
                            filterValue: 'switch',
                          ),
                          HUDTab(
                            label: 'ONTs',
                            icon: Icons.fiber_manual_record,
                            iconColor: Colors.orange,
                            count: ontCount,
                            filterValue: 'ont',
                          ),
                        ],
                        selectedIndex: _getTabIndex(uiState.filterType),
                        onTabSelected: (index) {
                          final filterValue = _getFilterFromIndex(index);
                          ref
                              .read(deviceUIStateNotifierProvider.notifier)
                              .setFilterType(filterValue);
                        },
                        onActiveTabTapped: () {
                          _scrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        },
                      );
                    },
                  ),

                  // Device list
                  Expanded(
                    child: Consumer(
                      builder: (context, ref, child) {
                        final uiState = ref.watch(
                          deviceUIStateNotifierProvider,
                        );
                        return filteredDevices.isEmpty
                            ? EmptyState(
                                icon: Icons.devices_other,
                                title: 'No devices found',
                                subtitle: uiState.searchQuery.isNotEmpty
                                    ? 'Try adjusting your search'
                                    : 'No devices match the current filter',
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.only(bottom: 80),
                                itemCount: filteredDevices.length,
                                itemBuilder: (context, index) {
                                  final device = filteredDevices[index];
                                  return UnifiedListItem(
                                    title: device.name,
                                    icon: ListItemHelpers.getDeviceIcon(
                                      device.type,
                                    ),
                                    status: ListItemHelpers.mapDeviceStatus(
                                      device.status,
                                    ),
                                    subtitleLines: [
                                      UnifiedInfoLine(
                                        text: _formatNetworkInfo(device),
                                      ),
                                    ],
                                    statusBadge: UnifiedStatusBadge(
                                      text: device.status.toUpperCase(),
                                      color: ListItemHelpers.getStatusColor(
                                        device.status,
                                      ),
                                    ),
                                    showChevron: true,
                                    onTap: () =>
                                        context.push('/devices/${device.id}'),
                                  );
                                },
                              );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
