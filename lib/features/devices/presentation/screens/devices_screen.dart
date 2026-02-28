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

  int _getTabIndex(String filterType) => switch (filterType) {
    'access_point' => 0,
    'switch' => 1,
    'ont' => 2,
    _ => 0,
  };

  String _getFilterFromIndex(int index) => switch (index) {
    0 => 'access_point',
    1 => 'switch',
    2 => 'ont',
    _ => 'access_point',
  };

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
    return _buildPopupFilter(
      items: phases,
      selectedValue: phaseState.selectedPhase,
      isFiltering: phaseState.isFiltering,
      defaultLabel: 'Phase',
      allValue: PhaseFilterState.allPhases,
      activeColor: Theme.of(context).colorScheme.primary,
      activeTextColor: Theme.of(context).colorScheme.onPrimary,
      activeIcon: Icons.label,
      defaultItemIcon: Icons.label,
      onSelected: (v) =>
          ref.read(deviceUIStateNotifierProvider.notifier).setPhaseFilter(v),
    );
  }

  Widget _buildStatusFilterContent(WidgetRef ref) {
    final statuses = ref.watch(deviceStatusesProvider);
    final statusState = ref.watch(statusFilterNotifierProvider);
    return _buildPopupFilter(
      items: statuses,
      selectedValue: statusState.selectedStatus,
      isFiltering: statusState.isFiltering,
      defaultLabel: 'Status',
      allValue: StatusFilterState.allStatuses,
      activeColor: ListItemHelpers.getFilterStatusColor(statusState.selectedStatus),
      activeTextColor: Colors.white,
      activeIcon: ListItemHelpers.getStatusIcon(statusState.selectedStatus),
      defaultItemIcon: Icons.help,
      onSelected: (v) =>
          ref.read(deviceUIStateNotifierProvider.notifier).setStatusFilter(v),
      itemColorResolver: ListItemHelpers.getFilterStatusColor,
      itemIconResolver: ListItemHelpers.getStatusIcon,
      labelFormatter: _capitalizeStatus,
    );
  }

  Widget _buildRoomFilterContent(WidgetRef ref) {
    final rooms = ref.watch(deviceRoomsProvider);
    final roomState = ref.watch(roomFilterNotifierProvider);
    return _buildPopupFilter(
      items: rooms,
      selectedValue: roomState.selectedRoom,
      isFiltering: roomState.isFiltering,
      defaultLabel: 'Room',
      allValue: RoomFilterState.allRooms,
      activeColor: Theme.of(context).colorScheme.tertiary,
      activeTextColor: Theme.of(context).colorScheme.onTertiary,
      activeIcon: Icons.meeting_room,
      defaultItemIcon: Icons.meeting_room,
      onSelected: (v) =>
          ref.read(deviceUIStateNotifierProvider.notifier).setRoomFilter(v),
    );
  }

  Widget _buildPopupFilter({
    required List<String> items,
    required String selectedValue,
    required bool isFiltering,
    required String defaultLabel,
    required String allValue,
    required Color activeColor,
    required Color activeTextColor,
    required IconData activeIcon,
    required IconData defaultItemIcon,
    required ValueChanged<String> onSelected,
    Color Function(String)? itemColorResolver,
    IconData Function(String)? itemIconResolver,
    String Function(String)? labelFormatter,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final displayLabel = isFiltering
        ? (labelFormatter?.call(selectedValue) ?? selectedValue)
        : defaultLabel;

    return PopupMenuButton<String>(
      itemBuilder: (BuildContext context) {
        return items.map((String item) {
          final isSelected = item == selectedValue;
          final isAll = item == allValue;
          final icon = isAll
              ? Icons.filter_list_off
              : (itemIconResolver?.call(item) ?? defaultItemIcon);
          final iconColor = isSelected
              ? colorScheme.primary
              : isAll
                  ? colorScheme.onSurface.withValues(alpha: 0.7)
                  : (itemColorResolver?.call(item) ??
                      colorScheme.onSurface.withValues(alpha: 0.7));
          final label = labelFormatter?.call(item) ?? item;

          return PopupMenuItem<String>(
            value: item,
            child: Row(
              children: [
                Icon(icon, size: 18, color: iconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? colorScheme.primary : null,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check, size: 18, color: colorScheme.primary),
              ],
            ),
          );
        }).toList();
      },
      onSelected: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isFiltering ? activeColor : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isFiltering
                ? activeColor
                : colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFiltering ? activeIcon : Icons.filter_list,
              size: 18,
              color: isFiltering ? activeTextColor : colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                displayLabel,
                style: TextStyle(
                  color: isFiltering ? activeTextColor : colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: isFiltering ? activeTextColor : colorScheme.onSurface,
            ),
          ],
        ),
      ),
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
