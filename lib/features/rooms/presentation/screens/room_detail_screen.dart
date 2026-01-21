import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:rgnets_fdk/core/providers/websocket_providers.dart';
import 'package:rgnets_fdk/core/services/websocket_cache_integration.dart';
import 'package:rgnets_fdk/core/theme/app_colors.dart';
import 'package:rgnets_fdk/core/widgets/widgets.dart';
import 'package:rgnets_fdk/features/devices/domain/constants/device_types.dart';
import 'package:rgnets_fdk/features/devices/presentation/providers/devices_provider.dart';
<<<<<<< HEAD
import 'package:rgnets_fdk/features/onboarding/presentation/widgets/onboarding_stage_badge.dart';
=======
>>>>>>> da0b3f7 (Integrate room readiness status labels into Locations UI (#12))
import 'package:rgnets_fdk/features/room_readiness/domain/entities/room_readiness.dart';
import 'package:rgnets_fdk/features/rooms/presentation/providers/room_device_view_model.dart';
import 'package:rgnets_fdk/features/rooms/presentation/providers/room_view_models.dart';
import 'package:rgnets_fdk/features/rooms/presentation/providers/rooms_riverpod_provider.dart';
import 'package:rgnets_fdk/features/speed_test/presentation/widgets/room_speed_test_selector.dart';

/// Room detail screen with device management
class RoomDetailScreen extends ConsumerStatefulWidget {
  
  const RoomDetailScreen({
    required this.roomId,
    super.key,
  });
  final String roomId;
  
  static const String routeName = '/room-detail';

  @override
  ConsumerState<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends ConsumerState<RoomDetailScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load room and device data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(roomsNotifierProvider.notifier).refresh();
      ref.read(devicesNotifierProvider.notifier).refresh();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final roomVm = ref.watch(roomViewModelByIdProvider(widget.roomId));
    
    if (roomVm == null) {
      // AppBar removed from loading state
      return const Scaffold(
        body: Center(child: LoadingIndicator()),
      );
    }
    
    // AppBar removed from RoomDetailScreen - menu functionality preserved in state
    return Scaffold(
          body: Column(
            children: [
              // Room header with status
              _RoomHeader(roomVm: roomVm),
              
              // Tab bar
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Devices'),
                  Tab(text: 'Analytics'),
                ],
                labelColor: Theme.of(context).colorScheme.primary,
              ),
              
              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _OverviewTab(roomVm: roomVm),
                    _DevicesTab(roomVm: roomVm),
                    _AnalyticsTab(roomVm: roomVm),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: _QuickActionsBar(
            roomVm: roomVm,
            onAction: _handleQuickAction,
          ),
        );
  }
  
  void _handleQuickAction(String action, RoomViewModel roomVm) {
    switch (action) {
      case 'power_all':
        _toggleAllDevices(roomVm);
        break;
      case 'restart_all':
        _restartAllDevices(roomVm);
        break;
      case 'add_device':
        _addDevice(roomVm);
        break;
      case 'report':
        _generateReport(roomVm);
        break;
    }
  }
  
  
  void _toggleAllDevices(RoomViewModel roomVm) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Toggling all devices in ${roomVm.name}')),
    );
  }
  
  void _restartAllDevices(RoomViewModel roomVm) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restart All Devices'),
        content: Text('Are you sure you want to restart all ${roomVm.deviceCount} devices in ${roomVm.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Restarting all devices in ${roomVm.name}...')),
              );
            },
            child: const Text('Restart All'),
          ),
        ],
      ),
    );
  }
  
  void _addDevice(RoomViewModel roomVm) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Adding device to ${roomVm.name}')),
    );
  }
  
  void _generateReport(RoomViewModel roomVm) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Generating report for ${roomVm.name}')),
    );
  }
}

class _RoomHeader extends StatelessWidget {
  
  const _RoomHeader({required this.roomVm});
  final RoomViewModel roomVm;
  
  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(roomVm.status);
    final healthPercentage = roomVm.onlinePercentage;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Room icon with status
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.meeting_room,
                  size: 32,
                  color: statusColor,
                ),
                // Status indicator
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          
          // Room info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roomVm.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        roomVm.statusText.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.devices, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${roomVm.onlineDevices}/${roomVm.deviceCount}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Health indicator
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: healthPercentage / 100,
                  strokeWidth: 6,
                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    healthPercentage >= 90 ? Colors.green :
                    healthPercentage >= 70 ? Colors.orange : Colors.red,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${healthPercentage.toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Health',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
}

<<<<<<< HEAD
<<<<<<< HEAD
class _OverviewTab extends ConsumerWidget {
=======
class _OverviewTab extends StatelessWidget {
>>>>>>> 24906fa (Add pms speed test)
=======
class _OverviewTab extends ConsumerWidget {
>>>>>>> 47e623e (Json credential and room readiness (#18))

  const _OverviewTab({required this.roomVm});
  final RoomViewModel roomVm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get actual device statistics from RoomDeviceNotifier
    final roomDeviceState = ref.watch(roomDeviceNotifierProvider(roomVm.id));
    final stats = roomDeviceState.stats;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Speed Test Results for this room
          RoomSpeedTestSelector(
            pmsRoomId: roomVm.room.id,
            roomName: roomVm.name,
            apIds: const [], // TODO: Get AP IDs from room devices
          ),
          const SizedBox(height: 16),

          // Room Information
          _SectionCard(
            title: 'Room Information',
            children: [
              _InfoRow('Room Name', roomVm.name),
              _InfoRow('Room ID', roomVm.id),
              if (roomVm.metadata?['area_sqft'] != null)
                _InfoRow('Area', '${roomVm.metadata!['area_sqft']} sq ft'),
              if (roomVm.metadata?['capacity'] != null)
                _InfoRow('Capacity', '${roomVm.metadata!['capacity']} people'),
              if (roomVm.metadata?['department'] != null)
                _InfoRow('Department', roomVm.metadata!['department'] as String),
            ],
          ),
          const SizedBox(height: 16),
          
          // Device Statistics
          _SectionCard(
            title: 'Device Statistics',
            children: [
              _InfoRow('Total Devices', roomVm.deviceCount.toString()),
              _InfoRow('Online Devices', roomVm.onlineDevices.toString()),
              _InfoRow('Offline Devices', (roomVm.deviceCount - roomVm.onlineDevices).toString()),
              _InfoRow('Health Score', '${roomVm.onlinePercentage.toStringAsFixed(1)}%'),
              _InfoRow('Status', roomVm.statusText),
            ],
          ),
          const SizedBox(height: 16),
          
          // Quick Stats Grid - using actual device statistics
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.wifi,
                  label: 'Access Points',
                  value: '${stats.accessPoints}',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.hub,
                  label: 'Switches',
                  value: '${stats.switches}',
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.fiber_manual_record,
                  label: 'ONTs',
                  value: '${stats.onts}',
                  color: Colors.teal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.router,
                  label: 'WLAN Controllers',
                  value: '${stats.wlanControllers}',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 80), // Space for bottom bar
        ],
      ),
    );
  }
}

class _DevicesTab extends ConsumerWidget {
  
  const _DevicesTab({required this.roomVm});
  final RoomViewModel roomVm;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the new RoomDeviceNotifier for proper MVVM architecture
    final roomDeviceState = ref.watch(roomDeviceNotifierProvider(roomVm.id));
    final cacheIntegration = ref.watch(webSocketCacheIntegrationProvider);
    
    if (roomDeviceState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (roomDeviceState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading devices',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              roomDeviceState.error!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(roomDeviceNotifierProvider(roomVm.id).notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    final filteredDevices = roomDeviceState.filteredDevices;
    final stats = roomDeviceState.stats;
    
    if (filteredDevices.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.devices_other,
          title: 'No devices in this room',
          subtitle: 'Add devices to this room to see them here',
          actionLabel: 'Add Device',
          onAction: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Add device will be implemented')),
            );
          },
        ),
      );
    }
    
    return Column(
      children: [
        // Device type filter using correct constants and statistics
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _DeviceTypeChip(
                label: 'All (${stats.total})',
                isSelected: true,
              ),
              const SizedBox(width: 8),
              _DeviceTypeChip(
                label: 'Access Points',
                icon: Icons.wifi,
                count: stats.accessPoints,
              ),
              const SizedBox(width: 8),
              _DeviceTypeChip(
                label: 'Switches',
                icon: Icons.hub,
                count: stats.switches,
              ),
              const SizedBox(width: 8),
              _DeviceTypeChip(
                label: 'ONTs',
                icon: Icons.fiber_manual_record,
                count: stats.onts,
              ),
              const SizedBox(width: 8),
              _DeviceTypeChip(
                label: 'WLAN Controllers',
                icon: Icons.router,
                count: stats.wlanControllers,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        
        // Device list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: filteredDevices.length,
            itemBuilder: (context, index) {
              final device = filteredDevices[index];
              Color? titleColor;
              if (device.type == DeviceTypes.accessPoint) {
                final apId = _extractApId(device.id);
                if (apId != null) {
                  ref.watch(apUplinkInfoProvider(apId));
                  titleColor = _getAPNameColor(apId, cacheIntegration);
                }
              }
              return _DeviceListItem(
                device: {
                  'id': device.id,
                  'name': device.name,
                  'type': device.type,
                  'status': device.status,
                  'ipAddress': device.ipAddress,
                },
                titleColor: titleColor,
                onTap: () {
                  // Navigate to device detail
                  context.push('/devices/${device.id}');
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AnalyticsTab extends StatelessWidget {
  
  const _AnalyticsTab({required this.roomVm});
  final RoomViewModel roomVm;
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Performance Metrics
          const _SectionCard(
            title: 'Performance Metrics',
            children: [
              _InfoRow('Average Uptime', '99.8%'),
              _InfoRow('Average Response Time', '12 ms'),
              _InfoRow('Packet Loss', '0.02%'),
              _InfoRow('Bandwidth Utilization', '45%'),
              _InfoRow('Error Rate', '0.1%'),
            ],
          ),
          const SizedBox(height: 16),
          
          // Usage Statistics
          _SectionCard(
            title: 'Usage Statistics (30 days)',
            children: [
              _InfoRow('Total Traffic', '${roomVm.deviceCount * 50} GB'),
              _InfoRow('Peak Concurrent Users', '${roomVm.deviceCount * 10}'),
              const _InfoRow('Average Session Duration', '2.5 hours'),
              _InfoRow('Total Sessions', '${roomVm.deviceCount * 500}'),
              _InfoRow('Unique Users', '${roomVm.deviceCount * 25}'),
            ],
          ),
          const SizedBox(height: 16),
          
          // Maintenance History
          _SectionCard(
            title: 'Maintenance',
            children: [
              if (roomVm.metadata?['last_maintenance'] != null)
                _InfoRow(
                  'Last Maintenance',
                  _formatDate(DateTime.tryParse(roomVm.metadata!['last_maintenance'] as String)),
                ),
              const _InfoRow('Scheduled Maintenance', 'None'),
              const _InfoRow('Open Tickets', '0'),
              const _InfoRow('Resolved Issues (30d)', '3'),
              const _InfoRow('Average Resolution Time', '4.2 hours'),
            ],
          ),
          const SizedBox(height: 16),
          
          // Recommendations
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        'Recommendations',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (roomVm.onlinePercentage < 95)
                    const _RecommendationItem(
                      text: 'Some devices are offline. Check network connectivity.',
                      priority: 'high',
                    ),
                  if (roomVm.deviceCount > 20)
                    const _RecommendationItem(
                      text: 'Consider adding another switch for better load distribution.',
                      priority: 'medium',
                    ),
                  const _RecommendationItem(
                    text: 'Schedule regular firmware updates for all devices.',
                    priority: 'low',
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 80), // Space for bottom bar
        ],
      ),
    );
  }
  
  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Never';
    }
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) {
      return '${diff.inDays} days ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hours ago';
    } else {
      return '${diff.inMinutes} minutes ago';
    }
  }
}

int? _extractApId(String deviceId) {
  final parts = deviceId.split('_');
  final rawId = parts.length >= 2 ? parts.sublist(1).join('_') : deviceId;
  return int.tryParse(rawId);
}

Color _getAPNameColor(int apId, WebSocketCacheIntegration cache) {
  final uplink = cache.getCachedAPUplink(apId);
  if (uplink == null) {
    return AppColors.error;
  }
  if (uplink.speedInBps != null && uplink.speedInBps! < 2500000000) {
    return AppColors.error;
  }
  return AppColors.textPrimary;
}

class _DeviceTypeChip extends StatelessWidget {
  
  const _DeviceTypeChip({
    required this.label,
    this.icon,
    this.count,
    this.isSelected = false,
  });
  final String label;
  final IconData? icon;
  final int? count;
  final bool isSelected;
  
  @override
  Widget build(BuildContext context) {
    final displayLabel = count != null ? '$label ($count)' : label;
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16),
            const SizedBox(width: 4),
          ],
          Text(displayLabel),
        ],
      ),
      selected: isSelected,
      onSelected: (_) {},
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
    );
  }
}

class _DeviceListItem extends StatelessWidget {
  
  const _DeviceListItem({
    required this.device,
    this.titleColor,
    this.onTap,
  });
  final Map<String, dynamic> device;
  final Color? titleColor;
  final VoidCallback? onTap;
  
  @override
  Widget build(BuildContext context) {
    final statusColor = device['status'] == 'online' ? Colors.green :
                       device['status'] == 'offline' ? Colors.red :
                       device['status'] == 'warning' ? Colors.orange : Colors.grey;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            device['type'] == DeviceTypes.accessPoint ? Icons.wifi :
            device['type'] == DeviceTypes.networkSwitch ? Icons.hub :
            device['type'] == DeviceTypes.ont ? Icons.fiber_manual_record :
            device['type'] == DeviceTypes.wlanController ? Icons.router :
            Icons.device_hub,
            color: statusColor,
            size: 20,
          ),
        ),
        title: Text(
          device['name'] as String,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: titleColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              device['type'] as String,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (device['ipAddress'] != null)
              Text(
                device['ipAddress'] as String,
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                device['status'].toString().toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Onboarding stage badge for AP/ONT devices
            OnboardingStageBadge(
              deviceId: device['id'] as String,
              compact: true,
            ),
            const SizedBox(height: 4),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }
}

class _RecommendationItem extends StatelessWidget {
  
  const _RecommendationItem({
    required this.text,
    required this.priority,
  });
  final String text;
  final String priority;
  
  @override
  Widget build(BuildContext context) {
    Color priorityColor;
    IconData priorityIcon;
    
    switch (priority) {
      case 'high':
        priorityColor = Colors.red;
        priorityIcon = Icons.priority_high;
        break;
      case 'medium':
        priorityColor = Colors.orange;
        priorityIcon = Icons.warning_amber;
        break;
      case 'low':
        priorityColor = Colors.blue;
        priorityIcon = Icons.info_outline;
        break;
      default:
        priorityColor = Colors.grey;
        priorityIcon = Icons.circle;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(priorityIcon, size: 16, color: priorityColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  
  const _SectionCard({
    required this.title,
    required this.children,
  });
  final String title;
  final List<Widget> children;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsBar extends StatelessWidget {
  
  const _QuickActionsBar({
    required this.roomVm,
    required this.onAction,
  });
  final RoomViewModel roomVm;
  final void Function(String action, RoomViewModel roomVm) onAction;
  
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _QuickActionButton(
                icon: Icons.power_settings_new,
                label: 'Power All',
                color: Colors.orange,
                onTap: () => onAction('power_all', roomVm),
              ),
              _QuickActionButton(
                icon: Icons.restart_alt,
                label: 'Restart All',
                color: Colors.red,
                onTap: () => onAction('restart_all', roomVm),
              ),
              _QuickActionButton(
                icon: Icons.add_circle,
                label: 'Add Device',
                onTap: () => onAction('add_device', roomVm),
              ),
              _QuickActionButton(
                icon: Icons.analytics,
                label: 'Report',
                onTap: () => onAction('report', roomVm),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: color ?? Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
