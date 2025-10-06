import 'dart:math';

import 'package:rgnets_fdk/core/config/mock_network_config.dart';
import 'package:rgnets_fdk/features/devices/data/models/device_model.dart';
import 'package:rgnets_fdk/features/notifications/data/models/notification_model.dart';
import 'package:rgnets_fdk/features/rooms/data/models/room_model.dart';

/// Generates realistic mock data for the RG Nets network management system
/// This class creates production-like data for devices, rooms, and notifications
/// to provide a realistic development and testing experience with enterprise networking scenarios.
class MockDataGenerator {
  static final _random = Random();
  
  // Enterprise campus building structure for large organization
  static const _buildings = [
    'Corporate Headquarters',
    'Technology Center',
    'Research & Development',
    'Manufacturing East',
    'Manufacturing West', 
    'Distribution Center',
    'Data Center Primary',
    'Data Center Secondary',
    'Executive Building',
    'Training Facility',
    'Customer Center',
    'Support Operations',
  ];
  
  // Multi-story enterprise building floors
  static const _floors = [
    'Sub-Basement',
    'Basement', 
    'Ground Floor',
    '1st Floor',
    '2nd Floor',
    '3rd Floor',
    '4th Floor',
    '5th Floor',
    '6th Floor',
    '7th Floor',
    '8th Floor',
    'Mechanical Floor',
    'Penthouse',
  ];
  
  // Enterprise facility room classifications
  static const _roomTypes = [
    'Executive Conference Room',
    'Small Conference Room',
    'Large Conference Room',
    'Board Room',
    'Executive Office',
    'Manager Office',
    'Open Office Area',
    'Cubicle Farm',
    'Server Room',
    'Network Operations Center',
    'IDF Closet',
    'MDF Room',
    'Telecommunications Room',
    'Equipment Room',
    'Main Lobby',
    'Reception Area',
    'Break Room',
    'Kitchen/Cafeteria',
    'Training Room',
    'Classroom',
    'R&D Lab',
    'Testing Lab',
    'Quality Assurance Lab',
    'Manufacturing Floor',
    'Warehouse Area',
    'Loading Dock',
    'Storage Room',
    'Utility Room',
    'Electrical Room',
    'HVAC Room',
    'Security Office',
    'Help Desk',
    'Call Center',
    'Data Center Aisle',
    'Backup Power Room',
  ];
  
  // RG Nets field deployment device naming conventions
  static const _devicePrefixes = {
    'Access Point': ['AP', 'WAP', 'WIFI'],
    'Switch': ['SW', 'SWT', 'L2SW', 'L3SW'],
    'ONT': ['ONT', 'GPON', 'FIBER'],
    'Gateway': ['GW', 'RXG', 'GWAY'],
    'Router': ['RTR', 'R', 'CORE', 'EDGE'],
    'Firewall': ['FW', 'ASA', 'NGFW', 'UTM'],
    'Server': ['SRV', 'SVR', 'HOST'],
    'Load Balancer': ['LB', 'F5', 'LOAD'],
    'IPS': ['IPS', 'IDS', 'SNSR'],
    'Camera': ['CAM', 'IP-CAM', 'CCTV'],
    'Phone': ['IP-PHONE', 'VoIP', 'PHONE'],
    'Printer': ['PRT', 'PRINT', 'MFP'],
    'UPS': ['UPS', 'PWR', 'BACKUP'],
  };
  
  // Enterprise VLAN segmentation strategy
  static const _vlans = [
    'MGMT-VLAN',           // Network management
    'CORP-DATA',           // Corporate user data
    'CORP-VOICE',          // VoIP systems
    'GUEST-ACCESS',        // Guest wireless
    'IOT-DEVICES',         // Internet of Things
    'SECURITY-CAM',        // IP cameras
    'BMS-HVAC',           // Building management
    'INDUSTRIAL',          // Manufacturing systems
    'DMZ-SERVERS',         // Demilitarized zone
    'QUARANTINE',          // Isolated systems
    'BACKUP-REPL',         // Backup and replication
    'STORAGE-SAN',         // Storage area network
    'ADMIN-TOOLS',         // Administrative tools
    'MONITORING',          // Network monitoring
    'DEV-TEST',           // Development/testing
  ];
  
  /// Generate a list of realistic devices
  static List<DeviceModel> generateDevices({int count = 50}) {
    final devices = <DeviceModel>[];
    final now = DateTime.now();
    
    // RG Nets field deployment device distribution (ONLY core deployment types)
    final typeDistribution = {
      'Access Point': 0.45,      // 45% - Wireless infrastructure (primary focus)
      'Switch': 0.35,            // 35% - Layer 2/3 switching (core networking)
      'ONT': 0.20,               // 20% - Optical Network Terminals (fiber endpoints)
    };
    
    // Status distribution (realistic network)
    final statusDistribution = {
      'online': 0.85,       // 85% online
      'offline': 0.08,      // 8% offline
      'warning': 0.05,      // 5% warning
      'error': 0.02,        // 2% error
    };
    
    // Create core infrastructure devices first
    devices.addAll(_generateCoreDevices(now));
    
    // Generate remaining devices based on distribution
    while (devices.length < count) {
      final deviceType = _pickByDistribution(typeDistribution);
      final status = _pickByDistribution(statusDistribution);
      final building = _buildings[_random.nextInt(_buildings.length)];
      final floor = _floors[_random.nextInt(_floors.length)];
      final room = _roomTypes[_random.nextInt(_roomTypes.length)];
      
      final id = 'dev_${devices.length + 1}';
      final prefix = _devicePrefixes[deviceType]![_random.nextInt(_devicePrefixes[deviceType]!.length)];
      final number = (_random.nextInt(900) + 100).toString();
      
      // Generate realistic IP based on device type
      final vlanId = _random.nextInt(_vlans.length);
      final ipAddress = _generateIP(vlanId, devices.length);
      
      // Generate MAC address
      final macAddress = _generateMAC();
      
      // Last seen based on status
      DateTime? lastSeen;
      if (status == 'online') {
        lastSeen = now.subtract(Duration(seconds: _random.nextInt(300)));
      } else if (status == 'warning') {
        lastSeen = now.subtract(Duration(minutes: _random.nextInt(30) + 5));
      } else if (status == 'offline') {
        lastSeen = now.subtract(Duration(hours: _random.nextInt(24) + 1));
      } else {
        lastSeen = now.subtract(Duration(days: _random.nextInt(7) + 1));
      }
      
      final signalStrength = deviceType == 'Access Point' ? -(_random.nextInt(40) + 40) : null;
      final connectedClients = deviceType == 'Access Point' ? _random.nextInt(50) : null;
      final uptime = _random.nextInt(86400 * 30); // Up to 30 days in seconds
      
      devices.add(DeviceModel(
        id: id,
        name: '$prefix-$building-$floor-$number'.replaceAll(' ', '-').toUpperCase(),
        type: deviceType,
        status: status,
        ipAddress: ipAddress,
        macAddress: macAddress,
        location: '$building - $floor - $room',
        lastSeen: lastSeen,
        model: _getDeviceModel(deviceType),
        serialNumber: 'SN${_random.nextInt(900000) + 100000}',
        firmware: '${_random.nextInt(10) + 1}.${_random.nextInt(20)}.${_random.nextInt(100)}',
        signalStrength: signalStrength,
        uptime: uptime,
        connectedClients: connectedClients,
        vlan: vlanId + 1,
        ssid: deviceType == 'Access Point' ? 'RGNets-${building.replaceAll(' ', '')}' : null,
        channel: deviceType == 'Access Point' ? _random.nextInt(11) + 1 : null,
        totalUpload: _random.nextInt(10000),
        totalDownload: _random.nextInt(20000),
        currentUpload: _random.nextDouble() * 100,
        currentDownload: _random.nextDouble() * 500,
        packetLoss: _random.nextDouble() * 0.5,
        latency: _random.nextInt(50) + 1,
        cpuUsage: status == 'warning' ? _random.nextInt(30) + 70 : _random.nextInt(50),
        memoryUsage: status == 'warning' ? _random.nextInt(30) + 60 : _random.nextInt(60),
        temperature: _random.nextInt(20) + 30,
        restartCount: _random.nextInt(5),
        maxClients: deviceType == 'Access Point' ? _random.nextInt(30) + 20 : null,
        metadata: {
          'firmware': '${_random.nextInt(10) + 1}.${_random.nextInt(20)}.${_random.nextInt(100)}',
          'model': _getDeviceModel(deviceType),
          'vlan': _vlans[vlanId],
          'uptime': '${_random.nextInt(365)}d ${_random.nextInt(24)}h ${_random.nextInt(60)}m',
          'cpu_usage': status == 'warning' ? _random.nextInt(30) + 70 : _random.nextInt(50),
          'memory_usage': status == 'warning' ? _random.nextInt(30) + 60 : _random.nextInt(60),
          'temperature': _random.nextInt(20) + 30,
          'clients': connectedClients,
          'bandwidth': '${_random.nextInt(900) + 100} Mbps',
        },
      ));
    }
    
    return devices;
  }
  
  /// Generate core infrastructure devices (RG Nets focused - ONLY core deployment types)
  static List<DeviceModel> _generateCoreDevices(DateTime now) {
    return [
      // Core distribution switch
      DeviceModel(
        id: 'core_sw_001',
        name: 'SW-CORE-DISTRIBUTION',
        type: 'Switch',
        status: 'online',
        ipAddress: MockNetworkConfig.coreDistributionSwitchIp,
        macAddress: _generateMAC(),
        location: 'Data Center Primary - Core Rack 1',
        lastSeen: now,
        model: 'Cisco Catalyst 9400',
        serialNumber: 'SN100001',
        firmware: '16.2.1',
        uptime: 180 * 86400, // 180 days in seconds
        vlan: 1,
        totalUpload: 50000,
        totalDownload: 100000,
        currentUpload: 850.5,
        currentDownload: 1200.75,
        packetLoss: 0.01,
        latency: 2,
        cpuUsage: 15,
        memoryUsage: 35,
        temperature: 38,
        restartCount: 0,
        metadata: const {
          'firmware': '16.2.1',
          'model': 'Cisco Catalyst 9400',
          'vlan': 'MGMT-VLAN',
          'uptime': '180d 12h 30m',
          'cpu_usage': 15,
          'memory_usage': 35,
          'temperature': 38,
          'bandwidth': '40000 Mbps',
          'ports': 48,
          'ports_active': 42,
        },
      ),
    ];
  }
  
  /// Generate realistic rooms
  static List<RoomModel> generateRooms({int count = 30}) {
    final rooms = <RoomModel>[];
    final usedCombinations = <String>{};
    
    for (var i = 0; i < count; i++) {
      String building;
      String floor;
      String roomType;
      String combination;
      
      // Ensure unique room combinations
      do {
        building = _buildings[_random.nextInt(_buildings.length)];
        floor = _floors[_random.nextInt(_floors.length)];
        roomType = _roomTypes[_random.nextInt(_roomTypes.length)];
        combination = '$building-$floor-$roomType';
      } while (usedCombinations.contains(combination));
      
      usedCombinations.add(combination);
      
      // Device counts are now calculated in presentation layer
      // so we don't need to generate them here
      
      // Generate room number
      final roomNumber = floor == 'Basement' || floor == 'Ground Floor' 
        ? roomType.substring(0, 3).toUpperCase() + (_random.nextInt(90) + 10).toString()
        : '${_floors.indexOf(floor)}${(_random.nextInt(90) + 10).toString().padLeft(2, '0')}';
      
      rooms.add(RoomModel(
        id: 'room_${i + 1}',
        name: '$roomType $roomNumber',
        metadata: {
          'area_sqft': _random.nextInt(2000) + 200,
          'capacity': roomType.contains('Conference') ? _random.nextInt(20) + 5 : null,
          'department': _getDepartment(),
          'last_maintenance': DateTime.now().subtract(
            Duration(days: _random.nextInt(90))
          ).toIso8601String(),
        },
      ));
    }
    
    return rooms;
  }
  
  /// Generate realistic notifications
  static List<NotificationModel> generateNotifications({int count = 20}) {
    final notifications = <NotificationModel>[];
    final now = DateTime.now();
    
    // Need device types for notification generation (RG Nets focused - ONLY core types)
    final typeDistribution = {
      'Access Point': 0.45,      
      'Switch': 0.35,            
      'ONT': 0.20,               
    };
    
    // Production-level network monitoring notifications
    final notificationTemplates = [
      {
        'title': 'Critical Device Offline',
        'type': 'error',
        'messageTemplate': '{device} ({model}) in {location} has been offline for {duration}. Last seen: {timestamp}',
      },
      {
        'title': 'High CPU Utilization',
        'type': 'warning',
        'messageTemplate': '{device} CPU utilization at {value}% (threshold: 80%). Running processes may be affected.',
      },
      {
        'title': 'Memory Usage Critical',
        'type': 'error',
        'messageTemplate': '{device} memory usage at {value}% (critical threshold: 90%). System performance degraded.',
      },
      {
        'title': 'Device Connectivity Restored',
        'type': 'success',
        'messageTemplate': '{device} in {location} is back online after {duration} downtime.',
      },
      {
        'title': 'Firmware Security Update',
        'type': 'warning',
        'messageTemplate': 'Security firmware {version} available for {device}. Current version {current} has known vulnerabilities.',
      },
      {
        'title': 'Network Bandwidth Saturation',
        'type': 'warning',
        'messageTemplate': 'Interface {interface} on {device} is {value}% utilized. Consider load balancing.',
      },
      {
        'title': 'IPS Security Threat Blocked',
        'type': 'error',
        'messageTemplate': 'IPS detected and blocked {threat_type} from {ip} targeting {target}. Rule: {rule_id}',
      },
      {
        'title': 'Automated Backup Completed',
        'type': 'success',
        'messageTemplate': 'Nightly configuration backup completed for {count} devices. {size} stored in repository.',
      },
      {
        'title': 'Software License Expiration',
        'type': 'warning',
        'messageTemplate': '{feature} license expires in {days} days. Contact vendor for renewal. Affected devices: {count}',
      },
      {
        'title': 'Environmental Alert - Temperature',
        'type': 'warning',
        'messageTemplate': '{device} temperature {temp}°C exceeds threshold (70°C). Check facility cooling systems.',
      },
      {
        'title': 'Port Link Down',
        'type': 'warning',
        'messageTemplate': 'Interface {interface} on {device} changed state to DOWN. Connected device may be offline.',
      },
      {
        'title': 'DHCP Pool Exhaustion',
        'type': 'error',
        'messageTemplate': 'DHCP pool for {vlan} is {value}% full. Expand pool or investigate excessive requests.',
      },
      {
        'title': 'VPN Tunnel Failure',
        'type': 'error',
        'messageTemplate': 'Site-to-site VPN tunnel to {remote_site} is DOWN. Remote connectivity affected.',
      },
      {
        'title': 'Unauthorized Device Detected',
        'type': 'error',
        'messageTemplate': 'Rogue device {mac} detected on {vlan}. Device quarantined pending investigation.',
      },
      {
        'title': 'STP Topology Change',
        'type': 'info',
        'messageTemplate': 'Spanning Tree topology change detected. Root bridge: {device}. Convergence time: {time}s',
      },
      {
        'title': 'Power Supply Redundancy Lost',
        'type': 'warning',
        'messageTemplate': '{device} power supply {psu_id} failed. Operating on single supply - replace immediately.',
      },
    ];
    
    for (var i = 0; i < count; i++) {
      final template = notificationTemplates[_random.nextInt(notificationTemplates.length)];
      final minutesAgo = _random.nextInt(10080); // Up to 7 days
      final timestamp = now.subtract(Duration(minutes: minutesAgo));
      
      // Generate realistic message based on template with enterprise context
      var message = template['messageTemplate'] as String;
      final deviceType = _pickByDistribution(typeDistribution);
      final devicePrefix = _devicePrefixes[deviceType]![_random.nextInt(_devicePrefixes[deviceType]!.length)];
      final deviceName = '$devicePrefix-${_random.nextInt(999) + 100}';
      final building = _buildings[_random.nextInt(_buildings.length)];
      final floor = _floors[_random.nextInt(_floors.length)];
      final room = _roomTypes[_random.nextInt(_roomTypes.length)];
      
      message = message.replaceAll('{device}', deviceName);
      message = message.replaceAll('{model}', _getDeviceModel(deviceType));
      message = message.replaceAll('{location}', '$building - $floor - $room');
      message = message.replaceAll('{value}', '${_random.nextInt(30) + 70}');
      message = message.replaceAll('{duration}', '${_random.nextInt(120) + 1} minutes');
      message = message.replaceAll('{version}', '${_random.nextInt(5) + 15}.${_random.nextInt(10)}.${_random.nextInt(20)}');
      message = message.replaceAll('{current}', '${_random.nextInt(3) + 12}.${_random.nextInt(10)}.${_random.nextInt(20)}');
      message = message.replaceAll('{vlan}', _vlans[_random.nextInt(_vlans.length)]);
      message = message.replaceAll('{ip}', _generateIP(_random.nextInt(15), _random.nextInt(255)));
      message = message.replaceAll('{count}', '${_random.nextInt(50) + 10}');
      message = message.replaceAll('{feature}', 'Advanced Security Module');
      message = message.replaceAll('{days}', '${_random.nextInt(30) + 1}');
      message = message.replaceAll('{temp}', '${_random.nextInt(20) + 70}');
      message = message.replaceAll('{interface}', 'GigabitEthernet0/${_random.nextInt(48) + 1}');
      message = message.replaceAll('{timestamp}', timestamp.subtract(Duration(hours: _random.nextInt(24))).toString().substring(0, 19));
      message = message.replaceAll('{threat_type}', ['DDoS Attack', 'Port Scan', 'Malware', 'Brute Force'][_random.nextInt(4)]);
      message = message.replaceAll('{target}', _generateIP(_random.nextInt(15), _random.nextInt(255)));
      message = message.replaceAll('{rule_id}', 'SEC-${_random.nextInt(9999) + 1000}');
      message = message.replaceAll('{size}', '${_random.nextInt(900) + 100} MB');
      message = message.replaceAll('{remote_site}', '${_buildings[_random.nextInt(_buildings.length)]} Branch');
      message = message.replaceAll('{mac}', _generateMAC());
      message = message.replaceAll('{time}', '${_random.nextInt(30) + 5}');
      message = message.replaceAll('{psu_id}', '${_random.nextInt(2) + 1}');
      
      notifications.add(NotificationModel(
        id: 'notif_${i + 1}',
        title: template['title'] as String,
        message: message,
        type: template['type'] as String,
        timestamp: timestamp,
        isRead: minutesAgo > 1440 && _random.nextBool(), // Older than 1 day might be read
        data: {
          'severity': template['type'] == 'error' ? 'high' : template['type'] == 'warning' ? 'medium' : 'low',
          'source': 'System Monitor',
          'actionRequired': template['type'] == 'error' || (template['type'] == 'warning' && _random.nextBool()),
        },
      ));
    }
    
    // Sort by timestamp (newest first)
    notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return notifications;
  }
  
  /// Pick a value based on distribution
  static String _pickByDistribution(Map<String, double> distribution) {
    final random = _random.nextDouble();
    double cumulative = 0;
    
    for (final entry in distribution.entries) {
      cumulative += entry.value;
      if (random <= cumulative) {
        return entry.key;
      }
    }
    
    return distribution.keys.last;
  }
  
  /// Generate realistic IP address
  static String _generateIP(int vlanId, int hostId) {
    return MockNetworkConfig.generateIpForVlan(vlanId, hostId);
  }
  
  /// Generate MAC address
  static String _generateMAC() {
    final bytes = List.generate(6, (_) => _random.nextInt(256));
    // Set locally administered bit
    bytes[0] = (bytes[0] & 0xFC) | 0x02;
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join(':');
  }
  
  /// Get device model based on type - Enterprise equipment vendors
  static String _getDeviceModel(String type) {
    final models = {
      'Access Point': [
        'Cisco Meraki MR46', 'Cisco Meraki MR56', 'Cisco Meraki MR86',
        'Aruba AP-515', 'Aruba AP-535', 'Aruba AP-655',
        'Ubiquiti UniFi 6 Pro', 'Ubiquiti UniFi 6 Enterprise',
        'Ruckus R750', 'Ruckus R850', 'Extreme AP-4000',
        'Mist AP43', 'Mist AP63'
      ],
      'Switch': [
        'Cisco Catalyst 9300-48P', 'Cisco Catalyst 9200-24T', 'Cisco Catalyst 9400',
        'Cisco Nexus 9000', 'Cisco Catalyst 3850', 'Cisco Catalyst 2960X',
        'Aruba CX 6300M', 'Aruba CX 6400', 'Aruba CX 8360',
        'HPE FlexNetwork 5130', 'HPE ProCurve 2920',
        'Juniper EX4300', 'Juniper EX2300', 'Juniper QFX5100',
        'Extreme X690', 'Extreme X465'
      ],
      'Router': [
        'Cisco ISR 4431', 'Cisco ISR 4351', 'Cisco ASR 1001-X', 'Cisco ASR 9000',
        'Juniper SRX345', 'Juniper MX204', 'Juniper ACX5448',
        'RG Nets rXg-9000X', 'RG Nets rXg-8500', 'RG Nets rXg-7500'
      ],
      'Firewall': [
        'Cisco ASA 5516-X', 'Cisco FTD 2130', 'Cisco Firepower 4125',
        'Palo Alto PA-5220', 'Palo Alto PA-3220', 'Palo Alto PA-850',
        'Fortinet FortiGate 600E', 'Fortinet FortiGate 200F', 'Fortinet FortiGate 100F',
        'SonicWall NSa 6650', 'SonicWall TZ570',
        'Check Point 15600', 'Check Point 5200'
      ],
      'ONT': [
        'Nokia G-240G-A', 'Nokia G-010G-A', 'Nokia G-010S-A',
        'Huawei HG8245H', 'Huawei HG8310M', 'Huawei HG8247H',
        'ZTE F680', 'ZTE F660', 'ZTE F601',
        'Calix GigaSpire BLAST GS4227E', 'Calix GigaCenter GS-1100',
        'Adtran 854v1', 'Adtran 844E-1'
      ],
      'Gateway': [
        'RG Nets rXg-9000X', 'RG Nets rXg-8500', 'RG Nets rXg-7500',
        'RG Nets rXg-6400', 'RG Nets rXg-5300', 'RG Nets rXg-4200'
      ],
      'Server': [
        'Dell PowerEdge R740', 'Dell PowerEdge R630', 'Dell PowerEdge R420',
        'HPE ProLiant DL380 Gen10', 'HPE ProLiant DL360 Gen10',
        'IBM System x3650 M5', 'Supermicro SuperServer'
      ],
      'Load Balancer': [
        'F5 BIG-IP i4800', 'F5 BIG-IP i2800', 'F5 BIG-IP Virtual Edition',
        'Citrix NetScaler SDX', 'A10 Thunder 3030S', 'Kemp LoadMaster 5300'
      ],
      'IPS': [
        'Cisco Firepower 2130', 'Tipping Point S3020F', 'McAfee Network Security Platform',
        'Trend Micro TippingPoint', 'IBM Security Network Protection'
      ],
      'Camera': [
        'Axis P3245-LVE', 'Axis M3046-V', 'Axis Q6055-E',
        'Hikvision DS-2CD2385G1-I', 'Hikvision DS-2DE7425IW-AE',
        'Dahua IPC-HFW5442E-ZE', 'Bosch Flexidome IP 7000 VR',
        'Avigilon H4A-DC-DO2'
      ],
      'Phone': [
        'Cisco IP Phone 8861', 'Cisco IP Phone 7975', 'Cisco IP Phone 6851',
        'Yealink T54W', 'Yealink T48S', 'Polycom VVX 601',
        'Grandstream GXP2170', 'Avaya J179'
      ],
      'Printer': [
        'HP LaserJet Enterprise M608dn', 'HP Color LaserJet Pro M454dw',
        'Canon imageRUNNER ADVANCE C5535i', 'Xerox VersaLink C405',
        'Brother HL-L6400DW', 'Ricoh MP C3004'
      ],
      'UPS': [
        'APC Smart-UPS RT 5000VA', 'APC Smart-UPS SRT 3000VA',
        'Eaton 9PX 6000', 'Tripp Lite SmartOnline SU3000RTXL3U'
      ],
    };
    
    final typeModels = models[type] ?? ['Unknown Device Model'];
    return typeModels[_random.nextInt(typeModels.length)];
  }
  
  /// Get department name
  static String _getDepartment() {
    final departments = [
      'IT Operations',
      'Engineering',
      'Sales',
      'Marketing',
      'Human Resources',
      'Finance',
      'Customer Service',
      'Research & Development',
      'Legal',
      'Facilities',
    ];
    return departments[_random.nextInt(departments.length)];
  }
}