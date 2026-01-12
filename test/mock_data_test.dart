import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/core/mock/mock_data_generator.dart';

void main() {
  group('MockDataGenerator Tests', () {
    test('generates realistic devices with enterprise characteristics', () {
      final devices = MockDataGenerator.generateDevices(count: 10);
      
      expect(devices.length, equals(10));
      
      // Check that devices have proper enterprise naming
      for (final device in devices) {
        expect(device.id, isNotEmpty);
        expect(device.name, isNotEmpty);
        expect(device.type, isNotEmpty);
        expect(device.status, isIn(['online', 'offline', 'warning', 'error']));
        
        // Check enterprise naming conventions (allowing for core devices)
        expect(device.name, matches(RegExp(r'^[A-Z-]+.*$')));
        
        // Check IP addresses are realistic
        if (device.ipAddress != null) {
          expect(device.ipAddress, matches(RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$')));
        }
        
        // Check MAC addresses are properly formatted
        if (device.macAddress != null) {
          expect(device.macAddress, matches(RegExp(r'^[0-9A-F]{2}:[0-9A-F]{2}:[0-9A-F]{2}:[0-9A-F]{2}:[0-9A-F]{2}:[0-9A-F]{2}$')));
        }
        
        // Check metadata exists and has realistic values
        expect(device.metadata, isNotNull);
        expect(device.metadata!['firmware'], isNotNull);
        expect(device.metadata!['model'], isNotNull);
        expect(device.metadata!['vlan'], isNotNull);
      }
    });
    
    test('generates realistic rooms with proper structure', () {
      final rooms = MockDataGenerator.generateRooms(count: 5);
      
      expect(rooms.length, equals(5));
      
      for (final room in rooms) {
        expect(room.id, greaterThan(0));
        expect(room.name, isNotEmpty);
        expect(room.metadata, isNotNull);
        expect(room.metadata!['area_sqft'], isNotNull);
        expect(room.metadata!['department'], isNotNull);
      }
    });
    
    test('generates realistic notifications with enterprise content', () {
      final notifications = MockDataGenerator.generateNotifications(count: 5);
      
      expect(notifications.length, equals(5));
      
      for (final notification in notifications) {
        expect(notification.id, isNotEmpty);
        expect(notification.title, isNotEmpty);
        expect(notification.message, isNotEmpty);
        expect(notification.type, isIn(['error', 'warning', 'info', 'success']));
        expect(notification.timestamp, isA<DateTime>());
        
        // Check that messages contain realistic enterprise network content
        final message = notification.message.toLowerCase();
        final hasNetworkContent = message.contains('device') ||
                                 message.contains('interface') ||
                                 message.contains('cpu') ||
                                 message.contains('memory') ||
                                 message.contains('firmware') ||
                                 message.contains('vlan') ||
                                 message.contains('ip') ||
                                 message.contains('temperature') ||
                                 message.contains('security') ||
                                 message.contains('backup') ||
                                 message.contains('power') ||
                                 message.contains('supply') ||
                                 message.contains('utilization') ||
                                 message.contains('threshold') ||
                                 message.contains('vpn') ||
                                 message.contains('tunnel') ||
                                 message.contains('connectivity') ||
                                 message.contains('network') ||
                                 message.contains('online') ||
                                 message.contains('offline') ||
                                 message.contains('downtime') ||
                                 message.contains('bridge') ||
                                 message.contains('tree') ||
                                 message.contains('topology') ||
                                 message.contains('dhcp') ||
                                 message.contains('configuration');
        
        expect(hasNetworkContent, isTrue, 
               reason: 'Notification should contain enterprise network content: ${notification.message}');
      }
    });
    
    test('device types ONLY include RG Nets field deployment types', () {
      final devices = MockDataGenerator.generateDevices(count: 100);
      
      final typeCounts = <String, int>{};
      for (final device in devices) {
        typeCounts[device.type] = (typeCounts[device.type] ?? 0) + 1;
      }
      
      // Should contain EXACTLY the three RG Nets device types
      expect(typeCounts.keys.toSet(), equals({'Access Point', 'Switch', 'ONT'}));
      
      // Access Points should be most common (around 45%)
      final apCount = typeCounts['Access Point'] ?? 0;
      expect(apCount, greaterThan(30)); // At least 30% (allowing some variance)
      
      // Switches should be second most common (around 35%)
      final switchCount = typeCounts['Switch'] ?? 0;
      expect(switchCount, greaterThan(20)); // At least 20% (allowing more variance)
      
      // ONTs should be present (around 20%)
      final ontCount = typeCounts['ONT'] ?? 0;
      expect(ontCount, greaterThan(10)); // At least 10%
      
      // Should have EXACTLY 3 device types
      expect(typeCounts.keys.length, equals(3));
    });
  });
}
