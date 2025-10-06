#!/usr/bin/env python3
"""
Design Comprehensive Detail View Sections
Design organized sections to display ALL available device data beautifully
"""

import json
from datetime import datetime
from typing import Dict, List, Any

def design_detail_view_sections():
    """Design logical sections for device detail views"""
    print("="*80)
    print("DETAIL VIEW SECTIONS DESIGN")
    print("="*80)
    
    # Based on API fields analysis from docs/api_fields_reference.md
    device_sections = {
        "access_points": {
            "total_fields": 94,
            "sections": [
                {
                    "name": "Device Identity",
                    "icon": "device_info",
                    "priority": 1,
                    "fields": [
                        {"key": "name", "label": "Name", "type": "string", "important": True},
                        {"key": "id", "label": "ID", "type": "string", "important": True},
                        {"key": "mac_address", "label": "MAC Address", "type": "mac", "important": True},
                        {"key": "model", "label": "Model", "type": "string", "important": True},
                        {"key": "device_type", "label": "Device Type", "type": "string", "important": False},
                        {"key": "firmware_version", "label": "Firmware", "type": "version", "important": False}
                    ]
                },
                {
                    "name": "Status & Health",
                    "icon": "health_check",
                    "priority": 2,
                    "fields": [
                        {"key": "online", "label": "Online Status", "type": "boolean", "important": True},
                        {"key": "status", "label": "Status", "type": "status", "important": True},
                        {"key": "uptime", "label": "Uptime", "type": "duration", "important": True},
                        {"key": "last_seen", "label": "Last Seen", "type": "datetime", "important": True},
                        {"key": "reboot_reason", "label": "Last Reboot", "type": "string", "important": False},
                        {"key": "cpu_usage", "label": "CPU Usage", "type": "percentage", "important": False},
                        {"key": "memory_usage", "label": "Memory Usage", "type": "percentage", "important": False}
                    ]
                },
                {
                    "name": "Network Configuration",
                    "icon": "network_settings",
                    "priority": 3,
                    "fields": [
                        {"key": "ip_address", "label": "IP Address", "type": "ip", "important": True},
                        {"key": "subnet_mask", "label": "Subnet Mask", "type": "ip", "important": False},
                        {"key": "gateway", "label": "Gateway", "type": "ip", "important": False},
                        {"key": "dns_servers", "label": "DNS Servers", "type": "array", "important": False},
                        {"key": "vlan", "label": "VLAN", "type": "number", "important": False},
                        {"key": "port", "label": "Port", "type": "string", "important": False}
                    ]
                },
                {
                    "name": "Wireless Settings",
                    "icon": "wifi",
                    "priority": 4,
                    "fields": [
                        {"key": "ssid", "label": "SSID", "type": "array", "important": True},
                        {"key": "channel", "label": "Channel", "type": "number", "important": True},
                        {"key": "frequency", "label": "Frequency", "type": "frequency", "important": True},
                        {"key": "power_level", "label": "TX Power", "type": "dbm", "important": False},
                        {"key": "antenna_gain", "label": "Antenna Gain", "type": "db", "important": False},
                        {"key": "radio_mode", "label": "Radio Mode", "type": "string", "important": False}
                    ]
                },
                {
                    "name": "Location & Environment",
                    "icon": "location_on",
                    "priority": 5,
                    "fields": [
                        {"key": "pms_room", "label": "Room", "type": "room_object", "important": True},
                        {"key": "building", "label": "Building", "type": "string", "important": True},
                        {"key": "floor", "label": "Floor", "type": "string", "important": True},
                        {"key": "coordinates", "label": "Coordinates", "type": "coordinates", "important": False},
                        {"key": "temperature", "label": "Temperature", "type": "temperature", "important": False},
                        {"key": "humidity", "label": "Humidity", "type": "percentage", "important": False}
                    ]
                },
                {
                    "name": "Performance Metrics",
                    "icon": "analytics",
                    "priority": 6,
                    "fields": [
                        {"key": "client_count", "label": "Connected Clients", "type": "number", "important": True},
                        {"key": "throughput_rx", "label": "RX Throughput", "type": "bandwidth", "important": False},
                        {"key": "throughput_tx", "label": "TX Throughput", "type": "bandwidth", "important": False},
                        {"key": "signal_strength", "label": "Signal Strength", "type": "dbm", "important": False},
                        {"key": "noise_floor", "label": "Noise Floor", "type": "dbm", "important": False},
                        {"key": "error_rate", "label": "Error Rate", "type": "percentage", "important": False}
                    ]
                },
                {
                    "name": "Configuration",
                    "icon": "settings",
                    "priority": 7,
                    "fields": [
                        {"key": "management_url", "label": "Management URL", "type": "url", "important": False},
                        {"key": "snmp_community", "label": "SNMP Community", "type": "string", "important": False},
                        {"key": "admin_state", "label": "Admin State", "type": "string", "important": False},
                        {"key": "config_hash", "label": "Config Hash", "type": "hash", "important": False}
                    ]
                },
                {
                    "name": "Metadata",
                    "icon": "info",
                    "priority": 8,
                    "fields": [
                        {"key": "created_at", "label": "Created", "type": "datetime", "important": False},
                        {"key": "updated_at", "label": "Updated", "type": "datetime", "important": False},
                        {"key": "discovered_at", "label": "Discovered", "type": "datetime", "important": False},
                        {"key": "tags", "label": "Tags", "type": "array", "important": False},
                        {"key": "notes", "label": "Notes", "type": "text", "important": False}
                    ]
                }
            ]
        },
        
        "switches": {
            "total_fields": 155,
            "sections": [
                {
                    "name": "Device Identity", 
                    "icon": "device_info",
                    "priority": 1,
                    "fields": [
                        {"key": "name", "label": "Name", "type": "string", "important": True},
                        {"key": "id", "label": "ID", "type": "string", "important": True},
                        {"key": "mac_address", "label": "MAC Address", "type": "mac", "important": True},
                        {"key": "model", "label": "Model", "type": "string", "important": True},
                        {"key": "serial_number", "label": "Serial Number", "type": "string", "important": True},
                        {"key": "firmware_version", "label": "Firmware", "type": "version", "important": False}
                    ]
                },
                {
                    "name": "Status & Health",
                    "icon": "health_check", 
                    "priority": 2,
                    "fields": [
                        {"key": "online", "label": "Online Status", "type": "boolean", "important": True},
                        {"key": "status", "label": "Status", "type": "status", "important": True},
                        {"key": "uptime", "label": "Uptime", "type": "duration", "important": True},
                        {"key": "last_seen", "label": "Last Seen", "type": "datetime", "important": True},
                        {"key": "cpu_usage", "label": "CPU Usage", "type": "percentage", "important": False},
                        {"key": "memory_usage", "label": "Memory Usage", "type": "percentage", "important": False},
                        {"key": "temperature", "label": "Temperature", "type": "temperature", "important": False}
                    ]
                },
                {
                    "name": "Network Configuration",
                    "icon": "network_settings",
                    "priority": 3,
                    "fields": [
                        {"key": "ip_address", "label": "Management IP", "type": "ip", "important": True},
                        {"key": "subnet_mask", "label": "Subnet Mask", "type": "ip", "important": False},
                        {"key": "gateway", "label": "Gateway", "type": "ip", "important": False},
                        {"key": "dns_servers", "label": "DNS Servers", "type": "array", "important": False},
                        {"key": "spanning_tree", "label": "Spanning Tree", "type": "boolean", "important": False}
                    ]
                },
                {
                    "name": "Port Configuration",
                    "icon": "cable",
                    "priority": 4,
                    "fields": [
                        {"key": "port_count", "label": "Total Ports", "type": "number", "important": True},
                        {"key": "active_ports", "label": "Active Ports", "type": "number", "important": True},
                        {"key": "port_speeds", "label": "Port Speeds", "type": "array", "important": False},
                        {"key": "poe_capable", "label": "PoE Capable", "type": "boolean", "important": True},
                        {"key": "poe_usage", "label": "PoE Usage", "type": "power", "important": False}
                    ]
                },
                {
                    "name": "VLAN Configuration",
                    "icon": "network_vlan",
                    "priority": 5,
                    "fields": [
                        {"key": "vlan_count", "label": "VLAN Count", "type": "number", "important": False},
                        {"key": "native_vlan", "label": "Native VLAN", "type": "number", "important": False},
                        {"key": "trunk_ports", "label": "Trunk Ports", "type": "array", "important": False}
                    ]
                },
                {
                    "name": "Location & Environment",
                    "icon": "location_on",
                    "priority": 6,
                    "fields": [
                        {"key": "pms_room", "label": "Room", "type": "room_object", "important": True},
                        {"key": "building", "label": "Building", "type": "string", "important": True},
                        {"key": "floor", "label": "Floor", "type": "string", "important": True},
                        {"key": "rack_position", "label": "Rack Position", "type": "string", "important": False}
                    ]
                },
                {
                    "name": "Performance Metrics",
                    "icon": "analytics",
                    "priority": 7,
                    "fields": [
                        {"key": "throughput", "label": "Throughput", "type": "bandwidth", "important": False},
                        {"key": "packet_loss", "label": "Packet Loss", "type": "percentage", "important": False},
                        {"key": "error_count", "label": "Error Count", "type": "number", "important": False},
                        {"key": "collision_count", "label": "Collision Count", "type": "number", "important": False}
                    ]
                },
                {
                    "name": "Metadata",
                    "icon": "info",
                    "priority": 8,
                    "fields": [
                        {"key": "created_at", "label": "Created", "type": "datetime", "important": False},
                        {"key": "updated_at", "label": "Updated", "type": "datetime", "important": False},
                        {"key": "discovered_at", "label": "Discovered", "type": "datetime", "important": False}
                    ]
                }
            ]
        },
        
        "media_converters": {
            "total_fields": 28,
            "sections": [
                {
                    "name": "Device Identity",
                    "icon": "device_info",
                    "priority": 1,
                    "fields": [
                        {"key": "name", "label": "Name", "type": "string", "important": True},
                        {"key": "id", "label": "ID", "type": "string", "important": True},
                        {"key": "mac_address", "label": "MAC Address", "type": "mac", "important": True},
                        {"key": "serial_number", "label": "Serial Number", "type": "string", "important": True},
                        {"key": "model", "label": "Model", "type": "string", "important": True}
                    ]
                },
                {
                    "name": "Status & Health",
                    "icon": "health_check",
                    "priority": 2,
                    "fields": [
                        {"key": "online", "label": "Online Status", "type": "boolean", "important": True},
                        {"key": "status", "label": "Status", "type": "status", "important": True},
                        {"key": "last_seen", "label": "Last Seen", "type": "datetime", "important": True},
                        {"key": "uptime", "label": "Uptime", "type": "duration", "important": False}
                    ]
                },
                {
                    "name": "Media Conversion",
                    "icon": "swap_horiz",
                    "priority": 3,
                    "fields": [
                        {"key": "media_type_a", "label": "Media Type A", "type": "string", "important": True},
                        {"key": "media_type_b", "label": "Media Type B", "type": "string", "important": True},
                        {"key": "link_speed", "label": "Link Speed", "type": "speed", "important": True},
                        {"key": "duplex_mode", "label": "Duplex Mode", "type": "string", "important": False}
                    ]
                },
                {
                    "name": "Location & Environment",
                    "icon": "location_on", 
                    "priority": 4,
                    "fields": [
                        {"key": "pms_room", "label": "Room", "type": "room_object", "important": True},
                        {"key": "building", "label": "Building", "type": "string", "important": True},
                        {"key": "floor", "label": "Floor", "type": "string", "important": True}
                    ]
                },
                {
                    "name": "Metadata",
                    "icon": "info",
                    "priority": 5,
                    "fields": [
                        {"key": "created_at", "label": "Created", "type": "datetime", "important": False},
                        {"key": "updated_at", "label": "Updated", "type": "datetime", "important": False}
                    ]
                }
            ]
        }
    }
    
    return device_sections

def generate_flutter_widgets():
    """Generate Flutter widgets for detail view sections"""
    print("\\n" + "="*80)
    print("FLUTTER DETAIL VIEW WIDGETS")
    print("="*80)
    
    print("\\n📱 Section Widget Implementation:")
    print("-" * 60)
    
    widget_code = '''
// Main detail view with organized sections
class DeviceDetailView extends ConsumerWidget {
  final Device device;
  
  const DeviceDetailView({Key? key, required this.device}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sections = DeviceSectionConfig.getSectionsForDeviceType(device.type);
    
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // App bar with device name and status
        SliverAppBar(
          expandedHeight: 120,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(device.name),
            subtitle: DeviceStatusChip(device: device),
          ),
        ),
        
        // Device sections
        ...sections.map((section) => SliverToBoxAdapter(
          child: DeviceDetailSection(
            device: device,
            section: section,
          ),
        )),
        
        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
      ],
    );
  }
}

// Individual section widget
class DeviceDetailSection extends StatefulWidget {
  final Device device;
  final DeviceSection section;
  
  const DeviceDetailSection({
    Key? key,
    required this.device,
    required this.section,
  }) : super(key: key);
  
  @override
  _DeviceDetailSectionState createState() => _DeviceDetailSectionState();
}

class _DeviceDetailSectionState extends State<DeviceDetailSection> {
  bool _isExpanded = true;
  
  @override
  void initState() {
    super.initState();
    // Auto-collapse low priority sections
    _isExpanded = widget.section.priority <= 3;
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImportantData = _hasImportantData();
    
    // Skip section if no data available
    if (!hasImportantData && _getAllSectionData().isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    _getSectionIcon(),
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.section.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_hasImportantData())
                          Text(
                            '${_getImportantFieldsCount()} important fields',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          
          // Section content
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildSectionContent(),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildSectionContent() {
    final sectionData = _getAllSectionData();
    
    if (sectionData.isEmpty) {
      return const Text('No data available');
    }
    
    return Column(
      children: sectionData.entries.map((entry) {
        final fieldConfig = _getFieldConfig(entry.key);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DeviceFieldRow(
            label: fieldConfig?.label ?? entry.key,
            value: entry.value,
            type: fieldConfig?.type ?? 'string',
            important: fieldConfig?.important ?? false,
          ),
        );
      }).toList(),
    );
  }
  
  Map<String, dynamic> _getAllSectionData() {
    final data = <String, dynamic>{};
    
    for (final field in widget.section.fields) {
      final value = _getFieldValue(field.key);
      if (value != null) {
        data[field.key] = value;
      }
    }
    
    return data;
  }
  
  dynamic _getFieldValue(String key) {
    // Extract field value from device object
    switch (key) {
      case 'name':
        return widget.device.name;
      case 'online':
        return widget.device.isOnline;
      case 'ip_address':
        return widget.device.ipAddress;
      case 'mac_address':
        return widget.device.macAddress;
      case 'pms_room':
        return widget.device.pmsRoom;
      // ... add more field mappings
      default:
        return widget.device.rawData?[key];
    }
  }
  
  bool _hasImportantData() {
    return widget.section.fields
        .where((f) => f.important)
        .any((f) => _getFieldValue(f.key) != null);
  }
  
  int _getImportantFieldsCount() {
    return widget.section.fields
        .where((f) => f.important && _getFieldValue(f.key) != null)
        .length;
  }
  
  IconData _getSectionIcon() {
    switch (widget.section.icon) {
      case 'device_info':
        return Icons.device_info;
      case 'health_check':
        return Icons.health_check;
      case 'network_settings':
        return Icons.settings_ethernet;
      case 'wifi':
        return Icons.wifi;
      case 'location_on':
        return Icons.location_on;
      case 'analytics':
        return Icons.analytics;
      case 'settings':
        return Icons.settings;
      case 'info':
        return Icons.info;
      default:
        return Icons.category;
    }
  }
}

// Individual field row widget
class DeviceFieldRow extends StatelessWidget {
  final String label;
  final dynamic value;
  final String type;
  final bool important;
  
  const DeviceFieldRow({
    Key? key,
    required this.label,
    required this.value,
    required this.type,
    this.important = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: important ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Value
        Expanded(
          child: _buildValueWidget(context),
        ),
      ],
    );
  }
  
  Widget _buildValueWidget(BuildContext context) {
    final theme = Theme.of(context);
    
    if (value == null) {
      return Text(
        'N/A',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
          fontStyle: FontStyle.italic,
        ),
      );
    }
    
    switch (type) {
      case 'boolean':
        return StatusChip(
          label: value == true ? 'Online' : 'Offline',
          color: value == true ? Colors.green : Colors.red,
        );
        
      case 'ip':
        return SelectableText(
          value.toString(),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontFamily: 'monospace',
          ),
        );
        
      case 'mac':
        return SelectableText(
          value.toString().toUpperCase(),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontFamily: 'monospace',
          ),
        );
        
      case 'datetime':
        return Text(
          _formatDateTime(value),
          style: theme.textTheme.bodyMedium,
        );
        
      case 'room_object':
        return _buildRoomWidget(value);
        
      case 'percentage':
        return Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: (value as num).toDouble() / 100,
              ),
            ),
            const SizedBox(width: 8),
            Text('${value}%'),
          ],
        );
        
      case 'array':
        if (value is List) {
          return Wrap(
            spacing: 4,
            children: (value as List)
                .map((item) => Chip(
                      label: Text(item.toString()),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ))
                .toList(),
          );
        }
        return Text(value.toString());
        
      default:
        return SelectableText(
          value.toString(),
          style: theme.textTheme.bodyMedium,
        );
    }
  }
  
  Widget _buildRoomWidget(dynamic room) {
    if (room == null) return const Text('N/A');
    
    if (room is Map) {
      final roomName = room['name'] ?? room['room'] ?? 'Unknown';
      final building = room['building'];
      final floor = room['floor'];
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(roomName.toString()),
          if (building != null || floor != null)
            Text(
              [building, floor != null ? 'Floor $floor' : null]
                  .where((e) => e != null)
                  .join(' - '),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      );
    }
    
    return Text(room.toString());
  }
  
  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return 'N/A';
    
    try {
      final date = dateTime is DateTime 
          ? dateTime 
          : DateTime.parse(dateTime.toString());
      
      return DateFormat('MMM d, y h:mm a').format(date);
    } catch (e) {
      return dateTime.toString();
    }
  }
}

// Status chip widget
class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  
  const StatusChip({
    Key? key,
    required this.label,
    required this.color,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}'''
    
    print(widget_code)

def design_responsive_layout():
    """Design responsive layout for different screen sizes"""
    print("\\n" + "="*80)
    print("RESPONSIVE DETAIL VIEW DESIGN")
    print("="*80)
    
    print("\\n📱 Layout Adaptations:")
    print("-" * 60)
    
    responsive_code = '''
// Responsive detail view that adapts to screen size
class ResponsiveDeviceDetailView extends ConsumerWidget {
  final Device device;
  
  const ResponsiveDeviceDetailView({Key? key, required this.device}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sections = DeviceSectionConfig.getSectionsForDeviceType(device.type);
    
    // Tablet/Desktop layout (wide screens)
    if (screenWidth > 768) {
      return _buildWideLayout(sections);
    }
    
    // Phone layout (narrow screens)
    return _buildNarrowLayout(sections);
  }
  
  Widget _buildWideLayout(List<DeviceSection> sections) {
    // Two-column layout for tablets/desktop
    final importantSections = sections.where((s) => s.priority <= 3).toList();
    final additionalSections = sections.where((s) => s.priority > 3).toList();
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column - Important sections
        Expanded(
          flex: 3,
          child: Column(
            children: importantSections.map((section) => 
              DeviceDetailSection(device: device, section: section)
            ).toList(),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Right column - Additional sections
        Expanded(
          flex: 2,
          child: Column(
            children: additionalSections.map((section) => 
              DeviceDetailSection(device: device, section: section)
            ).toList(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildNarrowLayout(List<DeviceSection> sections) {
    // Single column layout for phones
    return Column(
      children: sections.map((section) => 
        DeviceDetailSection(device: device, section: section)
      ).toList(),
    );
  }
}

// Device header with key information
class DeviceDetailHeader extends StatelessWidget {
  final Device device;
  
  const DeviceDetailHeader({Key? key, required this.device}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.surface,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // Device icon and name
          Row(
            children: [
              DeviceTypeIcon(deviceType: device.type, size: 48),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      device.type.displayName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              DeviceStatusChip(device: device),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Quick stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _QuickStat(
                icon: Icons.wifi,
                label: 'IP Address',
                value: device.ipAddress ?? 'N/A',
              ),
              _QuickStat(
                icon: Icons.device_hub,
                label: 'MAC',
                value: device.macAddress?.substring(0, 8) ?? 'N/A',
              ),
              _QuickStat(
                icon: Icons.location_on,
                label: 'Location',
                value: device.locationDisplay,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  
  const _QuickStat({
    required this.icon,
    required this.label,
    required this.value,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}'''
    
    print(responsive_code)

def create_section_configuration():
    """Create section configuration system"""
    print("\\n" + "="*80)
    print("SECTION CONFIGURATION SYSTEM")
    print("="*80)
    
    print("\\n⚙️ Configuration System:")
    print("-" * 60)
    
    config_code = '''
// Section configuration for different device types
class DeviceSectionConfig {
  static Map<DeviceType, List<DeviceSection>> _sectionConfigs = {
    DeviceType.accessPoint: _accessPointSections,
    DeviceType.switch: _switchSections,
    DeviceType.mediaConverter: _mediaConverterSections,
    DeviceType.wlanController: _wlanControllerSections,
  };
  
  static List<DeviceSection> getSectionsForDeviceType(DeviceType type) {
    return _sectionConfigs[type] ?? _defaultSections;
  }
  
  // Access Point sections
  static final List<DeviceSection> _accessPointSections = [
    DeviceSection(
      name: 'Device Identity',
      icon: 'device_info',
      priority: 1,
      fields: [
        FieldConfig(key: 'name', label: 'Name', type: 'string', important: true),
        FieldConfig(key: 'id', label: 'ID', type: 'string', important: true),
        FieldConfig(key: 'mac_address', label: 'MAC Address', type: 'mac', important: true),
        FieldConfig(key: 'model', label: 'Model', type: 'string', important: true),
      ],
    ),
    DeviceSection(
      name: 'Status & Health',
      icon: 'health_check', 
      priority: 2,
      fields: [
        FieldConfig(key: 'online', label: 'Online Status', type: 'boolean', important: true),
        FieldConfig(key: 'uptime', label: 'Uptime', type: 'duration', important: true),
        FieldConfig(key: 'last_seen', label: 'Last Seen', type: 'datetime', important: true),
      ],
    ),
    // ... more sections
  ];
  
  // Switch sections
  static final List<DeviceSection> _switchSections = [
    DeviceSection(
      name: 'Device Identity',
      icon: 'device_info',
      priority: 1,
      fields: [
        FieldConfig(key: 'name', label: 'Name', type: 'string', important: true),
        FieldConfig(key: 'serial_number', label: 'Serial', type: 'string', important: true),
      ],
    ),
    // ... more sections
  ];
}

class DeviceSection {
  final String name;
  final String icon;
  final int priority;
  final List<FieldConfig> fields;
  final bool expandedByDefault;
  
  const DeviceSection({
    required this.name,
    required this.icon,
    required this.priority,
    required this.fields,
    this.expandedByDefault = true,
  });
}

class FieldConfig {
  final String key;
  final String label;
  final String type;
  final bool important;
  final bool copyable;
  final String? unit;
  
  const FieldConfig({
    required this.key,
    required this.label,
    required this.type,
    this.important = false,
    this.copyable = true,
    this.unit,
  });
}

// User preferences for detail view
@riverpod
class DetailViewPreferences extends _$DetailViewPreferences {
  @override
  DetailViewSettings build() {
    return const DetailViewSettings(
      showAllSections: true,
      compactMode: false,
      highlightImportantFields: true,
      autoExpandSections: true,
    );
  }
  
  void toggleCompactMode() {
    state = state.copyWith(compactMode: !state.compactMode);
    _saveToPreferences();
  }
  
  void toggleSectionVisibility(String sectionName, bool visible) {
    final hiddenSections = Set<String>.from(state.hiddenSections);
    if (visible) {
      hiddenSections.remove(sectionName);
    } else {
      hiddenSections.add(sectionName);
    }
    state = state.copyWith(hiddenSections: hiddenSections);
    _saveToPreferences();
  }
}

class DetailViewSettings {
  final bool showAllSections;
  final bool compactMode;
  final bool highlightImportantFields;
  final bool autoExpandSections;
  final Set<String> hiddenSections;
  
  const DetailViewSettings({
    required this.showAllSections,
    required this.compactMode,
    required this.highlightImportantFields,
    required this.autoExpandSections,
    this.hiddenSections = const {},
  });
  
  DetailViewSettings copyWith({
    bool? showAllSections,
    bool? compactMode,
    bool? highlightImportantFields,
    bool? autoExpandSections,
    Set<String>? hiddenSections,
  }) {
    return DetailViewSettings(
      showAllSections: showAllSections ?? this.showAllSections,
      compactMode: compactMode ?? this.compactMode,
      highlightImportantFields: highlightImportantFields ?? this.highlightImportantFields,
      autoExpandSections: autoExpandSections ?? this.autoExpandSections,
      hiddenSections: hiddenSections ?? this.hiddenSections,
    );
  }
}'''
    
    print(config_code)

def create_testing_checklist():
    """Create testing checklist for detail views"""
    print("\\n" + "="*80)
    print("DETAIL VIEW TESTING CHECKLIST")
    print("="*80)
    
    checklist = [
        "Data Display",
        "  [ ] All available fields show correctly for each device type",
        "  [ ] Null/missing fields display 'N/A' gracefully",
        "  [ ] Room correlation data displays properly",
        "  [ ] Field types format correctly (IP, MAC, datetime, etc.)",
        "",
        "UI/UX",
        "  [ ] Sections expand/collapse smoothly",
        "  [ ] Important sections expanded by default",
        "  [ ] Responsive layout works on phones and tablets",
        "  [ ] Device header shows key information clearly",
        "  [ ] Pull-to-refresh triggers single device update",
        "",
        "Performance",
        "  [ ] Large field sets don't cause UI lag",
        "  [ ] Section rendering is efficient",
        "  [ ] Memory usage reasonable with many fields",
        "  [ ] Scroll performance smooth with all sections",
        "",
        "Data Integration",
        "  [ ] Single device API calls on navigation",
        "  [ ] Fresh data updates existing detail view",
        "  [ ] Cached data shows immediately, updates seamlessly",
        "  [ ] Error states handled gracefully",
        "",
        "Accessibility",
        "  [ ] All fields accessible via screen reader",
        "  [ ] Proper semantic labels on sections",
        "  [ ] Focus management works correctly",
        "  [ ] Color contrast meets guidelines"
    ]
    
    print("\\n📋 Testing Requirements:")
    print("-" * 60)
    for item in checklist:
        print(f"  {item}")

def main():
    print("="*80)
    print("COMPREHENSIVE DETAIL VIEW SECTIONS DESIGN")
    print(f"Timestamp: {datetime.now().isoformat()}")
    print("="*80)
    
    # Design section structure
    sections = design_detail_view_sections()
    
    # Generate Flutter widgets
    generate_flutter_widgets()
    
    # Design responsive layout
    design_responsive_layout()
    
    # Create configuration system
    create_section_configuration()
    
    # Create testing checklist
    create_testing_checklist()
    
    print("\\n" + "="*80)
    print("DETAIL VIEW DESIGN RESULTS")
    print("="*80)
    
    print("\\n📊 Section Summary:")
    print("-" * 60)
    
    for device_type, config in sections.items():
        total_fields = config['total_fields']
        section_count = len(config['sections'])
        print(f"  {device_type:16s}: {section_count} sections, {total_fields} total fields")
    
    print("\\n✅ DESIGN FEATURES:")
    print("-" * 60)
    print("  • Organized into 5-8 logical sections per device type")
    print("  • Important fields highlighted and auto-expanded")
    print("  • Responsive design for phones and tablets")
    print("  • Collapsible sections to manage information density")
    print("  • Room correlation properly displayed")
    print("  • Type-specific formatting (IP, MAC, datetime, etc.)")
    print("  • User preferences for customization")
    
    print("\\n🎨 SECTION ORGANIZATION:")
    print("-" * 60)
    print("  1. Device Identity (name, ID, MAC, model)")
    print("  2. Status & Health (online, uptime, last seen)")
    print("  3. Network/Wireless Configuration") 
    print("  4. Location & Environment (room, building, floor)")
    print("  5. Performance Metrics (throughput, clients, etc.)")
    print("  6. Hardware/Port Configuration")
    print("  7. System Configuration (management, SNMP)")
    print("  8. Metadata (timestamps, tags, notes)")
    
    print("\\n📱 RESPONSIVE FEATURES:")
    print("-" * 60)
    print("  • Phone: Single column, auto-collapse low priority")
    print("  • Tablet: Two columns, important vs additional sections")
    print("  • Desktop: Wide layout with expanded view options")
    
    print("\\n⚙️ IMPLEMENTATION PRIORITIES:")
    print("-" * 60)
    print("  1. Basic section rendering with expand/collapse")
    print("  2. Field type formatting and display")
    print("  3. Room correlation integration")
    print("  4. Responsive layout adaptation")
    print("  5. User preferences and customization")
    
    print("\\n✅ READY TO IMPLEMENT comprehensive detail views!")
    print("  Design provides organized, scalable way to show ALL device data")

if __name__ == "__main__":
    main()