import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/widgets/widgets.dart';
import 'package:rgnets_fdk/features/devices/domain/constants/device_types.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/devices/presentation/providers/devices_provider.dart';
import 'package:rgnets_fdk/features/devices/presentation/widgets/advanced_info_section.dart';
import 'package:rgnets_fdk/features/devices/presentation/widgets/device_detail_sections.dart';
import 'package:rgnets_fdk/features/devices/presentation/widgets/editable_note_section.dart';
import 'package:rgnets_fdk/features/devices/presentation/widgets/unified_summary_card.dart';

/// Default networking configuration values
class _NetworkDefaults {
  static const String subnetMask = '255.255.255.0';
  static const String gateway = '10.0.0.1';  // Default management VLAN gateway
  static const String dnsServers = '8.8.8.8, 8.8.4.4';
}

/// Device detail screen with actions
class DeviceDetailScreen extends ConsumerStatefulWidget {
  
  const DeviceDetailScreen({
    required this.deviceId,
    super.key,
  });
  final String deviceId;
  
  static const String routeName = '/device-detail';

  @override
  ConsumerState<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends ConsumerState<DeviceDetailScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Load device details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Device will be automatically loaded by the provider
      ref.read(deviceNotifierProvider(widget.deviceId).notifier).refresh();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final deviceAsync = ref.watch(deviceNotifierProvider(widget.deviceId));
    
    return deviceAsync.when(
      loading: () {
        // AppBar removed from loading state
        return const Scaffold(
          body: Center(child: LoadingIndicator()),
        );
      },
      error: (error, stack) {
        // AppBar removed from error state
        return Scaffold(
          body: Center(
            child: EmptyState(
              icon: Icons.error_outline,
              title: 'Error loading device',
              subtitle: error.toString(),
              actionLabel: 'Retry',
              onAction: () => ref.read(deviceNotifierProvider(widget.deviceId).notifier).refresh(),
            ),
          ),
        );
      },
      data: (device) {
        if (device == null) {
          // AppBar removed from null device state
          return Scaffold(
            body: Center(
              child: EmptyState(
                icon: Icons.device_unknown,
                title: 'Device not found',
                subtitle: 'The requested device could not be found',
                actionLabel: 'Go Back',
                onAction: () => Navigator.of(context).pop(),
              ),
            ),
          );
        }
        
        // AppBar removed from DeviceDetailScreen - menu functionality preserved in state
        return Scaffold(
          body: Column(
            children: [
              // Device header with status
              _DeviceHeader(device: device),
              
              // Tab bar
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Network'),
                  Tab(text: 'Statistics'),
                  Tab(text: 'Logs'),
                ],
                labelColor: Theme.of(context).colorScheme.primary,
              ),
              
              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _OverviewTab(device: device),
                    _NetworkTab(device: device),
                    _StatisticsTab(device: device),
                    _LogsTab(device: device),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: _QuickActionsBar(
            device: device,
            onAction: _handleQuickAction,
          ),
        );
      },
    );
  }
  
  void _handleQuickAction(String action, Device device) {
    switch (action) {
      case 'power':
        _togglePower(device);
        break;
      case 'wifi':
        _toggleWifi(device);
        break;
      case 'locate':
        _locateDevice(device);
        break;
      case 'support':
        _openSupport(device);
        break;
    }
  }
  
  
  void _togglePower(Device device) {
    final newStatus = device.status == 'online' ? 'offline' : 'online';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${device.name} is now $newStatus')),
    );
  }
  
  void _toggleWifi(Device device) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('WiFi toggled for ${device.name}')),
    );
  }
  
  void _locateDevice(Device device) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Locating ${device.name}...')),
    );
  }
  
  void _openSupport(Device device) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening support for ${device.name}')),
    );
  }
}

class _DeviceHeader extends StatelessWidget {
  
  const _DeviceHeader({required this.device});
  final Device device;
  
  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(device.status);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Device icon with status
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
                  _getDeviceIcon(device.type),
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
          
          // Device info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  device.type,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
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
                        device.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                    if (device.firmware != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        'FW: ${device.firmware}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          // Signal strength indicator
          if (device.signalStrength != null)
            Column(
              children: [
                Icon(
                  _getSignalIcon(device.signalStrength!),
                  size: 32,
                  color: _getSignalColor(device.signalStrength!),
                ),
                Text(
                  '${device.signalStrength} dBm',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
        ],
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'online':
        return Colors.green;
      case 'offline':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  IconData _getDeviceIcon(String type) {
    switch (type) {
      case DeviceTypes.accessPoint:
        return Icons.wifi;
      case DeviceTypes.networkSwitch:
        return Icons.hub;
      case DeviceTypes.ont:
        return Icons.fiber_manual_record;
      default:
        return Icons.device_hub;
    }
  }
  
  IconData _getSignalIcon(int strength) {
    if (strength >= -50) {
      return Icons.signal_wifi_4_bar;
    } else if (strength >= -60) {
      return Icons.network_wifi_3_bar;
    } else if (strength >= -70) {
      return Icons.network_wifi_2_bar;
    } else if (strength >= -80) {
      return Icons.network_wifi_1_bar;
    } else {
      return Icons.signal_wifi_0_bar;
    }
  }
  
  Color _getSignalColor(int strength) {
    if (strength >= -50) {
      return Colors.green;
    } else if (strength >= -70) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

class _OverviewTab extends ConsumerStatefulWidget {
  const _OverviewTab({required this.device});

  final Device device;

  @override
  ConsumerState<_OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends ConsumerState<_OverviewTab>
    with AutomaticKeepAliveClientMixin<_OverviewTab> {
  @override
  bool get wantKeepAlive => true;

  Future<void> _handleImageDeleted(String signedId) async {
    final notifier = ref.read(deviceNotifierProvider(widget.device.id).notifier);
    final success = await notifier.deleteDeviceImage(signedId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Image deleted successfully' : 'Failed to delete image',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _handleUploadComplete() {
    // Refresh device data to show newly uploaded images
    ref.read(deviceNotifierProvider(widget.device.id).notifier).refresh();
  }

  void _handleEditNote() {
    // TODO(note-api): Navigate to note edit screen.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Note editing not yet implemented'),
      ),
    );
  }

  void _handleClearNote() {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Note'),
        content: const Text('Are you sure you want to clear this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    ).then((confirmed) {
      if ((confirmed ?? false) && mounted) {
        // TODO(note-api): Implement note clearing via API.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note clearing not yet implemented'),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Unified Summary Card at the top
        UnifiedSummaryCard(device: widget.device),
        const SizedBox(height: 16),

        // Device detail sections
        DeviceDetailSections(
          device: widget.device,
          onImageDeletedBySignedId: _handleImageDeleted,
          onUploadComplete: _handleUploadComplete,
        ),

        // Editable Note Section
        const SizedBox(height: 16),
        EditableNoteSection(
          note: widget.device.note,
          onEditNote: _handleEditNote,
          onClearNote: _handleClearNote,
        ),

        // Advanced Information (expandable)
        const SizedBox(height: 16),
        AdvancedInfoSection(device: widget.device),

        // Bottom padding for safe area
        const SizedBox(height: 80),
      ],
    );
  }
}

class _NetworkTab extends StatefulWidget {
  const _NetworkTab({required this.device});

  final Device device;

  @override
  State<_NetworkTab> createState() => _NetworkTabState();
}

class _NetworkTabState extends State<_NetworkTab>
    with AutomaticKeepAliveClientMixin<_NetworkTab> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final device = widget.device;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Network Configuration
          SectionCard(
            title: 'Network Configuration',
            children: [
              _InfoRow('IP Address', device.ipAddress ?? 'Not configured'),
              _InfoRow('MAC Address', device.macAddress ?? 'Unknown'),
              const _InfoRow('Subnet Mask', _NetworkDefaults.subnetMask),
              const _InfoRow('Gateway', _NetworkDefaults.gateway),
              const _InfoRow('DNS Server', _NetworkDefaults.dnsServers),
              _InfoRow('VLAN', device.vlan?.toString() ?? 'None'),
            ],
          ),
          const SizedBox(height: 16),
          
          // WiFi Settings (for Access Points)
          if (device.type == DeviceTypes.accessPoint) ...[
            SectionCard(
              title: 'WiFi Settings',
              children: [
                _InfoRow('SSID', device.ssid ?? 'RGNets-Guest'),
                _InfoRow('Channel', device.channel?.toString() ?? 'Auto'),
                const _InfoRow('Band', '2.4 GHz / 5 GHz'),
                const _InfoRow('Security', 'WPA2-PSK'),
                _InfoRow('Signal Strength', '${device.signalStrength ?? -50} dBm'),
                _InfoRow('Connected Clients', '${device.connectedClients ?? 0}'),
              ],
            ),
            const SizedBox(height: 16),
          ],
          
          // Port Status (for Switches)
          if (device.type == DeviceTypes.networkSwitch) ...[
            const SectionCard(
              title: 'Port Status',
              children: [
                _InfoRow('Total Ports', '24'),
                _InfoRow('Active Ports', '18'),
                _InfoRow('PoE Ports', '12'),
                _InfoRow('Uplink Port', 'Port 24 (1 Gbps)'),
                _InfoRow('VLAN Trunk', 'Ports 23-24'),
              ],
            ),
            const SizedBox(height: 16),
          ],
          
          const SizedBox(height: 80), // Space for bottom bar
        ],
      ),
    );
  }
}

class _StatisticsTab extends StatefulWidget {
  const _StatisticsTab({required this.device});

  final Device device;

  @override
  State<_StatisticsTab> createState() => _StatisticsTabState();
}

class _StatisticsTabState extends State<_StatisticsTab>
    with AutomaticKeepAliveClientMixin<_StatisticsTab> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final device = widget.device;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Traffic Statistics
          SectionCard(
            title: 'Traffic Statistics',
            children: [
              _InfoRow('Total Upload', '${device.totalUpload ?? 1024} GB'),
              _InfoRow('Total Download', '${device.totalDownload ?? 2048} GB'),
              _InfoRow('Current Upload', '${device.currentUpload ?? 10} Mbps'),
              _InfoRow('Current Download', '${device.currentDownload ?? 50} Mbps'),
              _InfoRow('Packet Loss', '${device.packetLoss ?? 0.1}%'),
              _InfoRow('Latency', '${device.latency ?? 5} ms'),
            ],
          ),
          const SizedBox(height: 16),
          
          // Performance Metrics
          SectionCard(
            title: 'Performance Metrics',
            children: [
              _InfoRow('CPU Usage', '${device.cpuUsage ?? 25}%'),
              _InfoRow('Memory Usage', '${device.memoryUsage ?? 60}%'),
              _InfoRow('Temperature', '${device.temperature ?? 45}°C'),
              _InfoRow('Uptime', _formatUptime(device.uptime ?? 86400)),
              _InfoRow('Restarts (30d)', '${device.restartCount ?? 0}'),
            ],
          ),
          const SizedBox(height: 16),
          
          // Client Statistics (for Access Points)
          if (device.type == DeviceTypes.accessPoint) ...[
            SectionCard(
              title: 'Client Statistics',
              children: [
                _InfoRow('Current Clients', '${device.connectedClients ?? 0}'),
                _InfoRow('Max Clients (24h)', '${device.maxClients ?? 25}'),
                const _InfoRow('Avg Session Time', '45 minutes'),
                const _InfoRow('Total Sessions (24h)', '156'),
                const _InfoRow('Failed Auth (24h)', '3'),
              ],
            ),
            const SizedBox(height: 16),
          ],
          
          const SizedBox(height: 80), // Space for bottom bar
        ],
      ),
    );
  }
  
  String _formatUptime(int seconds) {
    final days = seconds ~/ 86400;
    final hours = (seconds % 86400) ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    
    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}

class _LogsTab extends StatefulWidget {
  const _LogsTab({required this.device});

  final Device device;

  @override
  State<_LogsTab> createState() => _LogsTabState();
}

class _LogsTabState extends State<_LogsTab>
    with AutomaticKeepAliveClientMixin<_LogsTab> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Logs not available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Device logs are not yet supported',
            style: TextStyle(color: Colors.grey),
          ),
        ],
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
    required this.device,
    required this.onAction,
  });
  final Device device;
  final void Function(String action, Device device) onAction;
  
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
                icon: device.status == 'online' ? Icons.power_off : Icons.power,
                label: device.status == 'online' ? 'Power Off' : 'Power On',
                color: device.status == 'online' ? Colors.red : Colors.green,
                onTap: () => onAction('power', device),
              ),
              _QuickActionButton(
                icon: Icons.wifi,
                label: 'WiFi',
                onTap: () => onAction('wifi', device),
              ),
              _QuickActionButton(
                icon: Icons.location_on,
                label: 'Locate',
                onTap: () => onAction('locate', device),
              ),
              _QuickActionButton(
                icon: Icons.support,
                label: 'Support',
                onTap: () => onAction('support', device),
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
