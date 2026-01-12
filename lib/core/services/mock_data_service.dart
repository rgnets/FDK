import 'dart:math';

import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/config/mock_network_config.dart';
import 'package:rgnets_fdk/features/auth/domain/entities/user.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/notifications/domain/entities/notification.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/room.dart';

/// Service that provides mock/synthetic data for development mode
class MockDataService {
  factory MockDataService() => _instance;
  MockDataService._internal() {
    if (EnvironmentConfig.isDevelopment) {
      _generateNetworkTopology();
    } else {
      _rooms = const [];
      _devices = const [];
      _notifications = const [];
    }
  }
  static final MockDataService _instance = MockDataService._internal();

  final Random _random = Random(42); // Seed for consistent generation
  final Logger _logger = Logger();
  late final List<Room> _rooms;
  late final List<Device> _devices;
  late final List<AppNotification> _notifications;
  final Map<int, List<String>> _roomDeviceIds = {}; // Track device IDs per room

  /// Generate the entire network topology once
  void _generateNetworkTopology() {
    final initialRooms = _generateRooms();
    _devices = _generateDevices(initialRooms);
    // Now update rooms with their device IDs
    _rooms = initialRooms.map((room) {
      return room.copyWith(deviceIds: _roomDeviceIds[room.id] ?? []);
    }).toList();
    _notifications = _generateNotifications();
    
    _logger
      ..i('MockDataService: Generated ${_rooms.length} rooms')
      ..i('MockDataService: Generated ${_devices.length} total devices')
      ..i('  - Access Points: ${_devices.where((d) => d.type == 'access_point').length}')
      ..i('  - ONTs: ${_devices.where((d) => d.type == 'ont').length}')
      ..i('  - Switches: ${_devices.where((d) => d.type == 'switch').length}')
      ..i('  - WLAN Controllers: ${_devices.where((d) => d.type == 'wlan_controller').length}');
  }

  /// Mock user for development
  User getMockUser() {
    return const User(
      username: 'developer',
      siteUrl: 'https://dev.local',
      displayName: 'Developer User',
      email: 'dev@example.com',
    );
  }

  /// Generate 680 rooms across multiple buildings
  List<Room> _generateRooms() {
    final rooms = <Room>[];
    final buildings = ['North Tower', 'South Tower', 'East Wing', 'West Wing', 'Central Hub'];
    
    var roomCounter = 0;
    var roomIdCounter = 1000; // Start room IDs at 1000 to match PMS pattern
    for (final building in buildings) {
      final roomsPerBuilding = building == 'Central Hub' ? 80 : 150;
      final floorsPerBuilding = building == 'Central Hub' ? 4 : 10;
      
      for (var floor = 1; floor <= floorsPerBuilding; floor++) {
        final roomsPerFloor = roomsPerBuilding ~/ floorsPerBuilding;
        
        for (var roomNum = 1; roomNum <= roomsPerFloor; roomNum++) {
          if (roomCounter >= 680) {
            break;
          }
          
          final roomId = roomIdCounter;
          final roomName = '${building.substring(0, 2).toUpperCase()}-$floor${roomNum.toString().padLeft(2, '0')}';
          final displayLocation = '($building) $floor${roomNum.toString().padLeft(2, '0')}';
          
          // Determine room type
          String description;
          if (roomNum == 1 && floor == 1) {
            description = 'MDF/Core Network Room';
          } else if (roomNum == 1) {
            description = 'IDF Room - Floor $floor';
          } else if (_random.nextDouble() < 0.15) {
            description = 'Suite - Premium accommodation';
          } else if (_random.nextDouble() < 0.3) {
            description = 'Deluxe Room - Enhanced amenities';
          } else {
            description = 'Standard Room';
          }
          
          rooms.add(Room(
            id: roomId,
            name: roomName,
            description: description,
            location: displayLocation, // Use full location format like API
            deviceIds: null, // Will be populated when generating devices
            createdAt: DateTime.now().subtract(Duration(days: 365 - roomCounter)),
            updatedAt: DateTime.now().subtract(Duration(
              minutes: _random.nextInt(60 * 24 * 7), // Random update within last week
            )),
          ));
          
          roomCounter++;
          roomIdCounter++;
        }
        if (roomCounter >= 680) {
          break;
        }
      }
      if (roomCounter >= 680) {
        break;
      }
    }
    
    return rooms;
  }

  /// Generate devices based on realistic distribution
  List<Device> _generateDevices(List<Room> rooms) {
    final devices = <Device>[];
    var deviceIdCounter = 1;
    
    for (final room in rooms) {
      final roomDeviceIds = <String>[];
      
      // Determine device configuration based on room type
      int numAPs;
      int numONTs;
      var hasSwitch = false;
      String? switchType;
      
      if (room.description?.contains('MDF') ?? false) {
        // MDF room: Core switch + multiple distribution switches
        numAPs = 0;
        numONTs = 2; // Redundant uplinks
        hasSwitch = true;
        switchType = 'core';
        
        // Add core switch
        final coreSwitch = _createSwitch(
          deviceIdCounter++,
          room.id,
          room.location ?? '',
          'Core Switch - ${room.name.split('(').first.replaceAll(')', '').trim()}',
          'RG-CORE-9000',
          'core',
          true, // Always online
        );
        devices.add(coreSwitch);
        roomDeviceIds.add(coreSwitch.id);
        
        // Add distribution switches
        for (var i = 0; i < 3; i++) {
          final distSwitch = _createSwitch(
            deviceIdCounter++,
            room.id,
            room.location ?? '',
            'Distribution Switch ${i + 1}',
            'RG-DIST-4800',
            'distribution',
            _random.nextDouble() > 0.05, // 95% online
          );
          devices.add(distSwitch);
          roomDeviceIds.add(distSwitch.id);
        }
      } else if (room.description?.contains('IDF') ?? false) {
        // IDF room: Floor switch
        numAPs = 1; // Management AP
        numONTs = 1;
        hasSwitch = true;
        switchType = 'idf';
        
        final idfSwitch = _createSwitch(
          deviceIdCounter++,
          room.id,
          room.location ?? '',
          'Floor Switch - ${room.name}',
          'RG-IDF-2400',
          'idf',
          _random.nextDouble() > 0.08, // 92% online
        );
        devices.add(idfSwitch);
        roomDeviceIds.add(idfSwitch.id);
      } else if (room.description?.contains('Suite') ?? false) {
        // Suite: More devices
        numAPs = _random.nextDouble() < 0.7 ? 3 : 2; // 70% have 3 APs, 30% have 2
        numONTs = _random.nextDouble() < 0.3 ? 2 : 1; // 30% have 2 ONTs
        hasSwitch = _random.nextDouble() < 0.4; // 40% have room switches
        switchType = 'room';
      } else if (room.description?.contains('Deluxe') ?? false) {
        // Deluxe: Medium configuration
        numAPs = _random.nextDouble() < 0.6 ? 2 : 1; // 60% have 2 APs
        numONTs = _random.nextDouble() < 0.2 ? 2 : 1; // 20% have 2 ONTs
        hasSwitch = _random.nextDouble() < 0.2; // 20% have room switches
        switchType = 'room';
      } else {
        // Standard room: Basic configuration
        numAPs = _random.nextDouble() < 0.8 ? 1 : 2; // 80% have 1 AP, 20% have 2
        numONTs = 1; // Always 1 ONT
        hasSwitch = _random.nextDouble() < 0.1; // 10% have room switches
        switchType = 'room';
      }
      
      // Generate Access Points
      for (var i = 0; i < numAPs; i++) {
        final ap = _createAccessPoint(
          deviceIdCounter++,
          room.id,
          room.location ?? '',
          i + 1,
          numAPs,
        );
        devices.add(ap);
        roomDeviceIds.add(ap.id);
      }
      
      // Generate ONTs
      for (var i = 0; i < numONTs; i++) {
        final ont = _createONT(
          deviceIdCounter++,
          room.id,
          room.location ?? '',
          i + 1,
          numONTs,
        );
        devices.add(ont);
        roomDeviceIds.add(ont.id);
      }
      
      // Generate Room Switch if needed
      if (hasSwitch && switchType == 'room') {
        final roomSwitch = _createSwitch(
          deviceIdCounter++,
          room.id,
          room.location ?? '',
          'Room Switch',
          'RG-SW-8P',
          'room',
          _random.nextDouble() > 0.1, // 90% online
        );
        devices.add(roomSwitch);
        roomDeviceIds.add(roomSwitch.id);
      }
      
      // Store device IDs for this room
      _roomDeviceIds[room.id] = roomDeviceIds;
    }
    
    // Add WLAN Controllers (one per building)
    // Extract building names from location field which has format "(North Tower) 101"
    final buildings = rooms
        .where((r) => r.location != null && r.location!.contains('('))
        .map((r) => r.location!.split(')').first.replaceAll('(', '').trim())
        .toSet();
    for (final building in buildings) {
      final controller = Device(
        id: 'wlan-ctrl-${deviceIdCounter++}',
        name: 'WLAN Controller - $building',
        type: 'wlan_controller',
        status: 'online',
        location: building,
        macAddress: _generateMac(deviceIdCounter),
        ipAddress: MockNetworkConfig.generateIpForVlan(0, deviceIdCounter),
        model: 'RG-WLAN-5000',
        serialNumber: 'SN-WLAN-${deviceIdCounter.toString().padLeft(6, '0')}',
        lastSeen: DateTime.now().subtract(Duration(seconds: _random.nextInt(60))),
        metadata: {
          'managed_aps': devices.where((d) => 
            d.type == 'access_point' && 
            d.location != null &&
            d.location!.contains(building)
          ).length,
          'active_clients': _random.nextInt(500) + 100,
        },
      );
      devices.add(controller);
    }
    
    return devices;
  }

  Device _createAccessPoint(int id, int roomId, String roomLocation, int apNumber, int totalAPs) {
    final isOnline = _random.nextDouble() > 0.15; // 85% online
    final suffix = totalAPs > 1 ? '-${String.fromCharCode(64 + apNumber)}' : ''; // A, B, C...
    
    final pmsRoomId = roomId;
    
    // Extract building and room info for production-like naming
    final buildingNum = _getBuildingNumber(roomLocation);
    final roomNumber = roomLocation.contains(') ') 
        ? roomLocation.split(') ').last 
        : roomId.toString();
    
    // Parse room number to get floor and room
    final roomInt = int.tryParse(roomNumber) ?? 101;
    final floor = roomInt ~/ 100; // e.g., 205 -> 2
    final serial = id.toString().padLeft(4, '0').substring((id.toString().length - 4).clamp(0, id.toString().length));
    final model = _random.nextDouble() < 0.7 ? 'RG-AP-520' : 'RG-AP-320';
    final modelCode = _getModelCode(model);
    
    return Device(
      id: 'ap-$id',
      name: 'AP$buildingNum-$floor-$serial-$modelCode-RM$roomNumber$suffix',
      type: 'access_point',
      status: isOnline ? 'online' : 'offline',
      pmsRoomId: pmsRoomId,
      location: roomLocation,
      macAddress: _generateMac(id),
      ipAddress: isOnline ? MockNetworkConfig.generateIpForVlan(5, id) : null,
      model: model,
      serialNumber: 'SN-AP-${id.toString().padLeft(6, '0')}',
      lastSeen: isOnline 
          ? DateTime.now().subtract(Duration(seconds: _random.nextInt(300)))
          : DateTime.now().subtract(Duration(hours: _random.nextInt(48) + 1)),
      signalStrength: isOnline ? -35 - _random.nextInt(30) : null, // -35 to -65 dBm
      connectedClients: isOnline ? _random.nextInt(20) : 0,
      ssid: 'RGNets-WiFi',
      channel: [1, 6, 11, 36, 40, 44, 48, 149, 153, 157, 161][_random.nextInt(11)],
      metadata: {
        'band': _random.nextDouble() < 0.8 ? '2.4GHz/5GHz' : '2.4GHz',
        'firmware': '3.2.${_random.nextInt(10)}',
        'uptime': isOnline ? '${_random.nextInt(30)}d ${_random.nextInt(24)}h' : null,
      },
    );
  }

  Device _createONT(int id, int roomId, String roomLocation, int ontNumber, int totalONTs) {
    final isOnline = _random.nextDouble() > 0.1; // 90% online
    final suffix = totalONTs > 1 ? '-$ontNumber' : '';
    
    final pmsRoomId = roomId;
    
    // Extract building and room info for production-like naming
    final buildingNum = _getBuildingNumber(roomLocation);
    final roomNumber = roomLocation.contains(') ') 
        ? roomLocation.split(') ').last 
        : roomId.toString();
    
    // Parse room number to get floor
    final roomInt = int.tryParse(roomNumber) ?? 101;
    final floor = roomInt ~/ 100;
    final serial = id.toString().padLeft(4, '0').substring((id.toString().length - 4).clamp(0, id.toString().length));
    final model = _random.nextDouble() < 0.6 ? 'RG-ONT-200' : 'RG-ONT-100';
    final modelCode = _getModelCode(model);
    
    return Device(
      id: 'ont-$id',
      name: 'ONT$buildingNum-$floor-$serial-$modelCode-RM$roomNumber$suffix',
      type: 'ont',
      status: isOnline ? 'online' : 'offline',
      pmsRoomId: pmsRoomId,
      location: roomLocation,
      macAddress: _generateMac(id + 10000),
      ipAddress: isOnline ? MockNetworkConfig.generateIpForVlan(1, id) : null,
      model: model,
      serialNumber: 'SN-ONT-${id.toString().padLeft(6, '0')}',
      lastSeen: isOnline
          ? DateTime.now().subtract(Duration(seconds: _random.nextInt(600)))
          : DateTime.now().subtract(Duration(hours: _random.nextInt(72) + 1)),
      temperature: isOnline ? 35 + _random.nextInt(15) : null, // 35-50°C
      metadata: {
        'rx_power': isOnline ? '-${18 + _random.nextInt(7)}' : null, // -18 to -25 dBm
        'tx_power': isOnline ? '${1 + _random.nextInt(3)}' : null, // 1-4 dBm
        'fiber_status': isOnline ? 'connected' : 'disconnected',
        'pon_port': 'PON${(id ~/ 32) % 8}/SLOT${(id ~/ 8) % 4}/PORT${id % 8}',
      },
    );
  }

  Device _createSwitch(int id, int roomId, String roomLocation, String name, String model, String switchType, bool isOnline) {
    final portCount = switchType == 'core' ? 48 : 
                     switchType == 'distribution' ? 48 :
                     switchType == 'idf' ? 24 : 8;
    
    final pmsRoomId = roomId;
    
    // Extract building and room info for production-like naming
    final buildingNum = _getBuildingNumber(roomLocation);
    final roomNumber = roomLocation.contains(') ') 
        ? roomLocation.split(') ').last 
        : roomId.toString();
    
    // Parse room number to get floor
    final roomInt = int.tryParse(roomNumber) ?? 101;
    final floor = roomInt ~/ 100;
    final serial = id.toString().padLeft(4, '0').substring((id.toString().length - 4).clamp(0, id.toString().length));
    final modelCode = _getModelCode(model);
    
    // Determine room suffix based on switch type
    // MDF/IDF switches use special room designations instead of RM format
    String roomSuffix;
    if (switchType == 'core') {
      roomSuffix = 'MDF$buildingNum';  // Main Distribution Frame with building number
    } else if (switchType == 'distribution') {
      roomSuffix = 'MDF$buildingNum';  // Also in MDF room with building number
    } else if (switchType == 'idf') {
      roomSuffix = 'IDF$floor';  // IDF with floor number
    } else {
      roomSuffix = 'RM$roomNumber';  // Regular room format
    }
    
    return Device(
      id: 'switch-$id',
      name: 'SW$buildingNum-$floor-$serial-$modelCode-$roomSuffix',
      type: 'switch',
      status: isOnline ? 'online' : 'offline',
      pmsRoomId: pmsRoomId,
      location: roomLocation,
      macAddress: _generateMac(id + 20000),
      ipAddress: isOnline ? '10.2.${(id ~/ 255) % 255}.${id % 255}' : null,
      model: model,
      serialNumber: 'SN-SW-${id.toString().padLeft(6, '0')}',
      lastSeen: isOnline
          ? DateTime.now().subtract(Duration(seconds: _random.nextInt(120)))
          : DateTime.now().subtract(Duration(hours: _random.nextInt(24) + 1)),
      vlan: switchType == 'core' ? 1 : 100 + (id % 50),
      metadata: {
        'switch_type': switchType,
        'port_count': portCount,
        'ports_active': isOnline ? _random.nextInt(portCount - 2) + 2 : 0,
        'uplink_status': isOnline ? 'active' : 'down',
        'spanning_tree': switchType != 'room' ? 'enabled' : 'disabled',
        'firmware': '2.1.${_random.nextInt(20)}',
      },
    );
  }

  String _generateMac(int seed) {
    final bytes = List.generate(6, (i) => 
      ((seed * 7 + i * 13) % 256).toRadixString(16).padLeft(2, '0').toUpperCase()
    );
    return bytes.join(':');
  }
  
  /// Get building number from location string for production-like naming
  String _getBuildingNumber(String location) {
    // Map building names to single digit numbers
    if (location.contains('North Tower')) return '1';
    if (location.contains('South Tower')) return '2';
    if (location.contains('East Wing')) return '3';
    if (location.contains('West Wing')) return '4';
    if (location.contains('Central Hub')) return '5';
    return '0'; // Fallback for unknown buildings
  }
  
  /// Extract model code from full model name for production-like naming
  String _getModelCode(String model) {
    // Convert model names to short codes
    if (model.contains('AP-520')) return 'AP520';
    if (model.contains('AP-320')) return 'AP320';
    if (model.contains('ONT-200')) return 'ONT200';
    if (model.contains('ONT-100')) return 'ONT100';
    // Switch models
    if (model.contains('CORE-9000')) return 'SW900';
    if (model.contains('DIST-4800')) return 'SW480';
    if (model.contains('IDF-2400')) return 'SW240';
    if (model.contains('SW-8P')) return 'SW8P';
    if (model.contains('SW-24P')) return 'SW24P';
    return 'SW'; // Fallback for switches
  }

  /// Generate realistic notifications based on device status
  List<AppNotification> _generateNotifications() {
    final notifications = <AppNotification>[];
    final now = DateTime.now();
    
    // Find offline devices for notifications
    final offlineDevices = _devices.where((d) => d.status == 'offline').toList();
    final criticalDevices = offlineDevices.where((d) => 
      d.type == 'switch' && (d.metadata?['switch_type'] == 'core' || 
      d.metadata?['switch_type'] == 'distribution')
    ).toList();
    
    // Critical alerts for core/distribution switches
    for (final device in criticalDevices.take(3)) {
      notifications.add(AppNotification(
        id: 'notif-crit-${device.id}',
        title: 'Critical Infrastructure Alert',
        message: '${device.name} is offline - affecting multiple services',
        type: NotificationType.error,
        priority: NotificationPriority.urgent,
        timestamp: now.subtract(Duration(minutes: _random.nextInt(30))),
        isRead: false,
        deviceId: device.id,
        location: device.location,
      ));
    }
    
    // High priority alerts for regular offline devices
    for (final device in offlineDevices.take(10)) {
      if (!criticalDevices.contains(device)) {
        notifications.add(AppNotification(
          id: 'notif-off-${device.id}',
          title: 'Device Offline',
          message: '${device.name} has gone offline',
          type: NotificationType.deviceOffline,
          priority: NotificationPriority.urgent,
          timestamp: now.subtract(Duration(minutes: _random.nextInt(120) + 30)),
          isRead: _random.nextDouble() < 0.3,
          deviceId: device.id,
          location: device.location,
        ));
      }
    }
    
    // Some devices coming back online
    final onlineDevices = _devices.where((d) => d.status == 'online').toList()
      ..shuffle(_random);
    
    for (final device in onlineDevices.take(5)) {
      notifications.add(AppNotification(
        id: 'notif-on-${device.id}',
        title: 'Device Recovered',
        message: '${device.name} is back online',
        type: NotificationType.deviceOnline,
        priority: NotificationPriority.medium,
        timestamp: now.subtract(Duration(hours: _random.nextInt(6) + 1)),
        isRead: true,
        deviceId: device.id,
        location: device.location,
      ));
    }
    
    // System notifications
    notifications.addAll([
      AppNotification(
        id: 'notif-sys-1',
        title: 'Firmware Updates Available',
        message: '${_devices.where((d) => d.type == 'access_point').length ~/ 3} access points have firmware updates available',
        type: NotificationType.system,
        priority: NotificationPriority.medium,
        timestamp: now.subtract(const Duration(hours: 3)),
        isRead: false,
      ),
      AppNotification(
        id: 'notif-sys-2',
        title: 'Scheduled Maintenance',
        message: 'Core network maintenance scheduled for tonight 2:00 AM - 4:00 AM',
        type: NotificationType.system,
        priority: NotificationPriority.urgent,
        timestamp: now.subtract(const Duration(hours: 8)),
        isRead: true,
      ),
      AppNotification(
        id: 'notif-sys-3',
        title: 'Scan Session Complete',
        message: 'Successfully registered 47 devices in North Tower Floor 3',
        type: NotificationType.scanComplete,
        priority: NotificationPriority.low,
        timestamp: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
    ]);
    
    return notifications;
  }

  /// Get all mock rooms
  List<Room> getMockRooms() => List.from(_rooms);

  /// Get all mock devices
  List<Device> getMockDevices() => List.from(_devices);

  /// Get mock devices for a specific room
  List<Device> getMockDevicesForRoom(String roomId) {
    final roomIdInt = int.tryParse(roomId);
    if (roomIdInt != null) {
      return _devices.where((d) => d.pmsRoomId == roomIdInt).toList();
    }
    return [];
  }

  /// Get all mock notifications
  List<AppNotification> getMockNotifications() => List.from(_notifications);

  /// Generate mock scan result
  Map<String, dynamic> getMockScanResult(String barcode) {
    // Simulate different types of barcodes
    if (barcode.startsWith('AP-')) {
      return {
        'type': 'access_point',
        'id': barcode,
        'model': 'RG-AP-520',
        'serialNumber': 'SN-$barcode',
        'macAddress': _generateMac(barcode.hashCode),
      };
    } else if (barcode.startsWith('ONT-')) {
      return {
        'type': 'ont',
        'id': barcode,
        'model': 'RG-ONT-200',
        'serialNumber': 'SN-$barcode',
        'macAddress': _generateMac(barcode.hashCode),
      };
    } else if (barcode.startsWith('SW-')) {
      return {
        'type': 'switch',
        'id': barcode,
        'model': 'RG-SW-24P',
        'serialNumber': 'SN-$barcode',
        'macAddress': _generateMac(barcode.hashCode),
      };
    } else {
      return {
        'type': 'unknown',
        'id': barcode,
        'data': barcode,
      };
    }
  }

  /// Get mock dashboard statistics
  Map<String, dynamic> getMockDashboardStats() {
    // Count ready rooms (all devices online)
    var readyRooms = 0;
    var partiallyReadyRooms = 0;
    
    for (final room in _rooms) {
      final roomDevices = _devices.where((d) => d.pmsRoomId == room.id).toList();
      if (roomDevices.isEmpty) {
        continue;
      }
      
      final onlineCount = roomDevices.where((d) => d.status == 'online').length;
      if (onlineCount == roomDevices.length) {
        readyRooms++;
      } else if (onlineCount > 0) {
        partiallyReadyRooms++;
      }
    }
    
    final onlineDevices = _devices.where((d) => d.status == 'online').length;
    final unreadNotifications = _notifications.where((n) => !n.isRead).length;
    final criticalAlerts = _notifications.where((n) => 
        n.priority == NotificationPriority.urgent && !n.isRead).length;
    
    // Device type breakdown
    final apCount = _devices.where((d) => d.type == 'access_point').length;
    final ontCount = _devices.where((d) => d.type == 'ont').length;
    final switchCount = _devices.where((d) => d.type == 'switch').length;
    final controllerCount = _devices.where((d) => d.type == 'wlan_controller').length;
    
    // Online percentages by type
    final apOnline = _devices.where((d) => d.type == 'access_point' && d.status == 'online').length;
    final ontOnline = _devices.where((d) => d.type == 'ont' && d.status == 'online').length;
    final switchOnline = _devices.where((d) => d.type == 'switch' && d.status == 'online').length;
    
    return {
      'totalRooms': _rooms.length,
      'readyRooms': readyRooms,
      'partiallyReadyRooms': partiallyReadyRooms,
      'notReadyRooms': _rooms.length - readyRooms - partiallyReadyRooms,
      'totalDevices': _devices.length,
      'onlineDevices': onlineDevices,
      'offlineDevices': _devices.length - onlineDevices,
      'deviceHealth': (onlineDevices * 100 / _devices.length).toStringAsFixed(1),
      'unreadNotifications': unreadNotifications,
      'criticalAlerts': criticalAlerts,
      'deviceBreakdown': {
        'access_points': {'total': apCount, 'online': apOnline},
        'onts': {'total': ontCount, 'online': ontOnline},
        'switches': {'total': switchCount, 'online': switchOnline},
        'controllers': {'total': controllerCount, 'online': controllerCount},
      },
      'buildings': _rooms
          .where((r) => r.location != null && r.location!.contains('('))
          .map((r) => r.location!.split(')').first.replaceAll('(', '').trim())
          .toSet()
          .length,
      'totalFloors': 0, // Floor information no longer tracked
    };
  }

  /// Generate PMS rooms JSON endpoint data
  Map<String, dynamic> getMockPmsRoomsJson() {
    final pmsRooms = <Map<String, dynamic>>[];
    
    // Add special rooms first (40 total)
    final specialRooms = _generateSpecialRooms();
    pmsRooms.addAll(specialRooms);
    
    // Generate standard rooms (640 total)
    // Skip first 40 rooms to avoid ID collision with special rooms
    for (final room in _rooms.skip(40).take(640)) {
      // Match real API structure exactly
      // room.location has format "(North Tower) 101"
      final locationParts = room.location?.split(')') ?? ['', ''];
      final buildingWithParen = locationParts[0]; // "(North Tower"
      final building = buildingWithParen.replaceAll('(', '').trim(); // "North Tower"
      final roomNumber = locationParts.length > 1 ? locationParts[1].trim() : room.name.split('-').last;
      
      pmsRooms.add({
        'id': room.id,
        'room': roomNumber, // Just the room number, e.g., "101"
        'pms_property': {
          'id': 1,
          'name': building.isNotEmpty ? building : 'North Tower', // Building name
        },
      });
    }
    
    return {
      'count': pmsRooms.length,
      'next': null,
      'previous': null,
      'results': pmsRooms,
    };
  }

  /// Generate special rooms for apartment complexes
  List<Map<String, dynamic>> _generateSpecialRooms() {
    final specialRooms = <Map<String, dynamic>>[];
    var roomId = 1000;
    
    // Common areas (10)
    final commonAreas = [
      'Lobby', 'Main Lobby', 'Concierge Desk', 'Business Center',
      'Rooftop Lounge', 'Clubhouse', 'Community Room', 'Game Room',
      'Library', 'Conference Room'
    ];
    
    for (final area in commonAreas) {
      // Match real API structure exactly
      specialRooms.add({
        'id': roomId++,
        'room': area, // Just the area name, e.g., "Lobby"
        'pms_property': {
          'id': 1,
          'name': 'Central Complex',
        },
      });
    }
    
    // Service rooms (8)
    final serviceRooms = [
      'Maintenance Shop', 'Storage Room A', 'Storage Room B', 
      'Equipment Room', 'Supply Closet', 'Janitor Closet',
      'Tool Room', 'Parts Storage'
    ];
    
    for (final room in serviceRooms) {
      // Match real API structure exactly
      specialRooms.add({
        'id': roomId++,
        'room': room,
        'pms_property': {
          'id': 1,
          'name': 'Central Complex',
        },
      });
    }
    
    // Amenity rooms (8)
    final amenityRooms = [
      'Fitness Center', 'Pool Area', 'Spa Room', 'Yoga Studio',
      'Theater Room', 'Music Room', 'Art Studio', 'Golf Simulator'
    ];
    
    for (final room in amenityRooms) {
      // Match real API structure exactly
      specialRooms.add({
        'id': roomId++,
        'room': room,
        'pms_property': {
          'id': 1,
          'name': 'Central Complex',
        },
      });
    }
    
    // Utility rooms (6)
    final utilityRooms = [
      'Laundry Room A', 'Laundry Room B', 'Trash Room Floor 1',
      'Trash Room Floor 2', 'Recycling Center', 'Mail Room'
    ];
    
    for (final room in utilityRooms) {
      // Match real API structure exactly
      specialRooms.add({
        'id': roomId++,
        'room': room,
        'pms_property': {
          'id': 1,
          'name': 'Central Complex',
        },
      });
    }
    
    // Office spaces (4)
    final officeSpaces = [
      'Leasing Office', 'Management Office', 'Security Office', 'Package Room'
    ];
    
    for (final room in officeSpaces) {
      // Match real API structure exactly
      specialRooms.add({
        'id': roomId++,
        'room': room,
        'pms_property': {
          'id': 1,
          'name': 'Central Complex',
        },
      });
    }
    
    // Technical rooms (4)
    final technicalRooms = [
      'MDF Room', 'IDF Room Floor 1', 'Elevator Machine Room', 'Electrical Room'
    ];
    
    for (final room in technicalRooms) {
      // Match real API structure exactly
      specialRooms.add({
        'id': roomId++,
        'room': room,
        'pms_property': {
          'id': 1,
          'name': 'Central Complex',
        },
      });
    }
    
    return specialRooms;
  }


  /// Extract numeric ID from string device IDs like "ap-7" -> 7
  int _extractIdNumber(String id) {
    final match = RegExp(r'\d+').firstMatch(id);
    if (match != null) {
      return int.tryParse(match.group(0)!) ?? 0;
    }
    // Generate a hash-based ID for strings without numbers
    return id.hashCode.abs() % 10000;
  }

  /// Generate devices JSON with 0.5% null pms_room
  Map<String, dynamic> getMockAccessPointsJson() {
    final aps = <Map<String, dynamic>>[];
    final apDevices = _devices.where((d) => d.type == 'access_point').toList();
    
    // Generate JSON for 99.5% of devices with pms_room
    final devicesWithRoom = (apDevices.length * 0.995).round();
    
    for (int i = 0; i < apDevices.length; i++) {
      final device = apDevices[i];
      final room = _rooms.firstWhere((r) => r.id == device.pmsRoomId, 
        orElse: () => _rooms.first);
      
      aps.add({
        'id': int.tryParse(device.id) ?? _extractIdNumber(device.id),
        'name': device.name,
        'mac': device.macAddress ?? 'XX:XX:XX:XX:XX:XX',
        'ip': device.ipAddress ?? '0.0.0.0',
        'online': device.status == 'online',
        'model': device.model,
        'serial_number': device.serialNumber,
        'firmware': device.firmware,
        'last_seen': device.lastSeen?.toIso8601String(),
        'pms_room': i < devicesWithRoom ? {
          'id': room.id,
          'name': room.location,
          'room_number': room.name.split('-').last,
        } : null, // 0.5% have null pms_room
        'signal_strength': device.signalStrength,
        'client_count': device.connectedClients,
        'note': device.note,
        'images': device.images ?? [],
      });
    }
    
    return {
      'count': aps.length,
      'results': aps,
    };
  }

  /// Generate switches JSON with 0.5% null pms_room
  Map<String, dynamic> getMockSwitchesJson() {
    final switches = <Map<String, dynamic>>[];
    final switchDevices = _devices.where((d) => d.type == 'switch').toList();
    
    // Generate JSON for 99.5% of devices with pms_room
    final devicesWithRoom = (switchDevices.length * 0.995).round();
    
    for (int i = 0; i < switchDevices.length; i++) {
      final device = switchDevices[i];
      final room = _rooms.firstWhere((r) => r.id == device.pmsRoomId,
        orElse: () => _rooms.first);
      
      switches.add({
        'id': int.tryParse(device.id) ?? _extractIdNumber(device.id),
        'name': device.name,
        'mac': device.macAddress ?? 'XX:XX:XX:XX:XX:XX',
        'ip': device.ipAddress ?? '0.0.0.0',
        'online': device.status == 'online',
        'model': device.model,
        'serial_number': device.serialNumber,
        'firmware': device.firmware,
        'last_seen': device.lastSeen?.toIso8601String(),
        'pms_room': i < devicesWithRoom ? {
          'id': room.id,
          'name': room.location,
          'room_number': room.name.split('-').last,
        } : null, // 0.5% have null pms_room
        'ports': 48,
        'uplink_status': 'active',
        'power_consumption': 250,
        'temperature': device.temperature,
        'note': device.note,
        'images': device.images ?? [],
      });
    }
    
    return {
      'count': switches.length,
      'results': switches,
    };
  }

  /// Generate media converters (ONTs) JSON with 0.5% null pms_room
  Map<String, dynamic> getMockMediaConvertersJson() {
    final onts = <Map<String, dynamic>>[];
    final ontDevices = _devices.where((d) => d.type == 'ont').toList();
    
    // Generate JSON for 99.5% of devices with pms_room
    final devicesWithRoom = (ontDevices.length * 0.995).round();
    
    for (int i = 0; i < ontDevices.length; i++) {
      final device = ontDevices[i];
      final room = _rooms.firstWhere((r) => r.id == device.pmsRoomId,
        orElse: () => _rooms.first);
      
      onts.add({
        'id': int.tryParse(device.id) ?? _extractIdNumber(device.id),
        'name': device.name,
        'mac': device.macAddress ?? 'XX:XX:XX:XX:XX:XX',
        'ip': device.ipAddress ?? '0.0.0.0',
        'online': device.status == 'online',
        'model': device.model,
        'serial_number': device.serialNumber,
        'firmware': device.firmware,
        'last_seen': device.lastSeen?.toIso8601String(),
        'pms_room': i < devicesWithRoom ? {
          'id': room.id,
          'name': room.location,
          'room_number': room.name.split('-').last,
        } : null, // 0.5% have null pms_room
        'optical_power': -15.5,
        'note': device.note,
        'images': device.images ?? [],
      });
    }
    
    return {
      'count': onts.length,
      'results': onts,
    };
  }

  /// Generate rooms JSON with 0.5% empty rooms
  Map<String, dynamic> getMockRoomsJson() {
    final roomsJson = <Map<String, dynamic>>[];
    
    // Calculate 0.5% empty rooms (3 out of 680)
    final emptyRoomIndices = <int>{677, 678, 679}; // Last 3 rooms will be empty
    
    for (int i = 0; i < _rooms.length; i++) {
      final room = _rooms[i];
      final devices = emptyRoomIndices.contains(i) 
        ? <Map<String, dynamic>>[] // Empty room
        : _devices
            .where((d) => d.pmsRoomId == room.id)
            .map((d) => {
              'id': int.tryParse(d.id) ?? _extractIdNumber(d.id),
              'name': d.name,
              'type': d.type,
              'online': d.status == 'online',
            })
            .toList();
      
      roomsJson.add({
        'id': room.id,
        'name': room.location, // Use location format
        'room_number': room.name.split('-').last,
        'description': room.description,
        'devices': devices,
        'created_at': room.createdAt?.toIso8601String() ?? DateTime.now().subtract(const Duration(days: 365)).toIso8601String(),
        'updated_at': room.updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      });
    }
    
    return {
      'count': roomsJson.length,
      'results': roomsJson,
    };
  }
}
