import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:rgnets_fdk/core/widgets/widgets.dart';
import 'package:rgnets_fdk/features/devices/domain/constants/device_types.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/devices/presentation/providers/devices_provider.dart';
import 'package:rgnets_fdk/features/onboarding/domain/entities/onboarding_state.dart';
import 'package:rgnets_fdk/features/onboarding/presentation/providers/device_onboarding_provider.dart';
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

class _OverviewTab extends ConsumerWidget {

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
          const SizedBox(height: 16),

          // Speed Test Results Section
          RoomSpeedTestSelector(
            pmsRoomId: int.tryParse(roomVm.id) ?? 0,
            roomName: roomVm.name,
            apIds: roomVm.deviceIds
                ?.where((id) => id.startsWith('ap_'))
                .map((id) => int.tryParse(id.replaceFirst('ap_', '')) ?? 0)
                .where((id) => id > 0)
                .toList() ?? [],
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
              return _DeviceListItem(
                device: device,
                onTap: () => context.push('/devices/${device.id}'),
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

class _DeviceListItem extends ConsumerStatefulWidget {

  const _DeviceListItem({
    required this.device,
    this.onTap,
  });
  final Device device;
  final VoidCallback? onTap;

  @override
  ConsumerState<_DeviceListItem> createState() => _DeviceListItemState();
}

class _DeviceListItemState extends ConsumerState<_DeviceListItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final device = widget.device;
    final onboardingState = ref.watch(deviceOnboardingStateProvider(device.id));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Header section (always visible)
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Device info (name + status)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Device name (tappable to go to detail)
                        GestureDetector(
                          onTap: widget.onTap,
                          child: Text(
                            device.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Stage indicator with dots
                        _OnboardingStageIndicator(state: onboardingState),
                      ],
                    ),
                  ),
                  // Device icon
                  _DeviceIcon(deviceType: device.type),
                  const SizedBox(width: 8),
                  // Expand/collapse chevron
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.chevron_right,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          // Expanded details section
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _DeviceDetailRow(label: 'Name', value: device.name),
                  _DeviceDetailRow(
                    label: 'MAC',
                    value: device.macAddress ?? 'N/A',
                  ),
                  _DeviceDetailRow(
                    label: 'IP',
                    value: device.ipAddress ?? 'N/A',
                  ),
                  _DeviceDetailRow(
                    label: 'Uptime',
                    value: _formatUptime(device.uptime),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatUptime(int? uptimeSeconds) {
    if (uptimeSeconds == null) return 'N/A';

    final days = uptimeSeconds ~/ 86400;
    final hours = (uptimeSeconds % 86400) ~/ 3600;
    final minutes = (uptimeSeconds % 3600) ~/ 60;

    if (days > 0) {
      return '${days}d ${hours}h';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}

class _OnboardingStageIndicator extends StatelessWidget {
  const _OnboardingStageIndicator({this.state});

  final OnboardingState? state;

  @override
  Widget build(BuildContext context) {
    // If no state or hasn't started, show "Not Started"
    if (state == null || !state!.hasStarted) {
      return Text(
        'Not Started',
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
        ),
      );
    }

    final currentStage = state!.currentStage;
    final maxStages = state!.maxStages;
    final isComplete = state!.isComplete;

    return Row(
      children: [
        // Stage dots
        for (int i = 1; i <= maxStages; i++) ...[
          _StageDot(
            isCompleted: i < currentStage || isComplete,
            isCurrent: i == currentStage && !isComplete,
          ),
          if (i < maxStages) const SizedBox(width: 4),
        ],
        const SizedBox(width: 12),
        // Stage text
        Text(
          isComplete ? 'Complete' : 'Stage $currentStage of $maxStages',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _StageDot extends StatelessWidget {
  const _StageDot({
    required this.isCompleted,
    required this.isCurrent,
  });

  final bool isCompleted;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    Color fillColor;
    Color borderColor;
    IconData? icon;

    if (isCompleted) {
      fillColor = Colors.green;
      borderColor = Colors.green;
      icon = Icons.check;
    } else if (isCurrent) {
      fillColor = Colors.transparent;
      borderColor = Colors.grey;
    } else {
      fillColor = Colors.transparent;
      borderColor = Colors.grey.shade300;
    }

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: fillColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: icon != null
          ? Icon(icon, size: 12, color: Colors.white)
          : (isCurrent
              ? Icon(Icons.close, size: 12, color: Colors.grey.shade400)
              : null),
    );
  }
}

class _DeviceIcon extends StatelessWidget {
  const _DeviceIcon({required this.deviceType});

  final String deviceType;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _getIconPath(),
      width: 48,
      height: 48,
      errorBuilder: (_, __, ___) => Icon(
        _getFallbackIcon(),
        size: 48,
        color: Colors.grey,
      ),
    );
  }

  String _getIconPath() {
    switch (deviceType) {
      case DeviceTypes.accessPoint:
        return 'assets/images/devices/access_point.png';
      case DeviceTypes.ont:
        return 'assets/images/devices/ont.png';
      case DeviceTypes.networkSwitch:
        return 'assets/images/devices/switch.png';
      case DeviceTypes.wlanController:
        return 'assets/images/devices/router.png';
      default:
        return 'assets/images/devices/device.png';
    }
  }

  IconData _getFallbackIcon() {
    switch (deviceType) {
      case DeviceTypes.accessPoint:
        return Icons.wifi;
      case DeviceTypes.ont:
        return Icons.fiber_manual_record;
      case DeviceTypes.networkSwitch:
        return Icons.hub;
      case DeviceTypes.wlanController:
        return Icons.router;
      default:
        return Icons.device_hub;
    }
  }
}

class _DeviceDetailRow extends StatelessWidget {
  const _DeviceDetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
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