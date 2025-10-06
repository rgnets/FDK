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
      ref.read(deviceUIStateNotifierProvider.notifier).setFilterType('access_point');
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
  
  @override
  Widget build(BuildContext context) {
    // AppBar removed from DevicesScreen - search and menu functionality needs to be relocated
    LoggerService.debug('DevicesScreen: AppBar removed, search functionality preserved in state');
    return Scaffold(
      body: Consumer(
        builder: (context, ref, child) {
          // Consumer builder executing - watching providers
          final devicesAsync = ref.watch(devicesNotifierProvider);
          // Device state information available in logger
          if (devicesAsync.hasValue) {
            LoggerService.debug('Device count: ${devicesAsync.value?.length ?? 0}');
          }
          final filteredDevices = ref.watch(filteredDevicesListProvider);
          final mockDataState = ref.watch(mockDataStateProvider);
          
          return devicesAsync.when(
            loading: () => const Center(child: LoadingIndicator()),
            error: (error, stack) => Center(
              child: EmptyState(
                icon: Icons.error_outline,
                title: 'Error loading devices',
                subtitle: error.toString(),
                actionLabel: 'Retry',
                onAction: () => ref.read(devicesNotifierProvider.notifier).userRefresh(),
              ),
            ),
            data: (devices) {
              return RefreshIndicator(
                onRefresh: () => ref.read(devicesNotifierProvider.notifier).userRefresh(),
                child: Column(
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
                  
                  // HUD Tab Bar - taller with full data
                  Builder(
                    builder: (context) {
                      final uiState = ref.watch(deviceUIStateNotifierProvider);
                      
                      final apCount = devices.where((d) => d.type == 'access_point').length;
                      final switchCount = devices.where((d) => d.type == 'switch').length;
                      final ontCount = devices.where((d) => d.type == 'ont').length;
                      
                      
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
                          ref.read(deviceUIStateNotifierProvider.notifier).setFilterType(filterValue);
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
                        final uiState = ref.watch(deviceUIStateNotifierProvider);
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
                                  icon: ListItemHelpers.getDeviceIcon(device.type),
                                  status: ListItemHelpers.mapDeviceStatus(device.status),
                                  subtitleLines: [
                                    UnifiedInfoLine(
                                      text: _formatNetworkInfo(device),
                                    ),
                                  ],
                                  statusBadge: UnifiedStatusBadge(
                                    text: device.status.toUpperCase(),
                                    color: ListItemHelpers.getStatusColor(device.status),
                                  ),
                                  showChevron: true,
                                  onTap: () => context.push('/devices/${device.id}'),
                                );
                              },
                            );
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
}