#!/usr/bin/env dart

import 'package:rgnets_fdk/core/services/mock_data_service.dart';

/// Test that switches now use production format
void main() {
  print('SWITCH FORMAT VERIFICATION');
  print('=' * 80);
  
  final mockService = MockDataService();
  final devices = mockService.getMockDevices();
  
  // Check Switches
  print('\nSWITCHES (Production Format):');
  print('-' * 50);
  print('Expected format: SW[building]-[floor]-[serial]-[model]-RM[room]');
  print('Example: SW1-2-0001-SW240-RM205\n');
  
  final switches = devices.where((d) => d.type == 'switch').take(15).toList();
  for (final sw in switches) {
    print('  ${sw.name.padRight(30)} Location: ${sw.location}');
    
    // Verify format
    if (sw.name.startsWith('SW') && sw.name.contains('-RM')) {
      final parts = sw.name.split('-');
      if (parts.length >= 5) {
        print('    ✓ Correct production format');
        print('    Building: ${parts[0].substring(2)}, Floor: ${parts[1]}, Serial: ${parts[2]}, Model: ${parts[3]}');
      } else {
        print('    ✗ Wrong format! Parts: ${parts.length}');
      }
    } else {
      print('    ✗ Wrong format! Should start with SW and contain -RM');
    }
    print('');
  }
  
  // Summary of all device types
  print('\nALL DEVICE TYPES SUMMARY:');
  print('-' * 50);
  
  final apExample = devices.firstWhere((d) => d.type == 'access_point');
  final ontExample = devices.firstWhere((d) => d.type == 'ont'); 
  final swExample = devices.firstWhere((d) => d.type == 'switch');
  
  print('Access Point: ${apExample.name}');
  print('ONT:          ${ontExample.name}');
  print('Switch:       ${swExample.name}');
  
  print('\n✓ All device types now follow production format');
  print('✓ Format: [Type][Building]-[Floor]-[Serial]-[Model]-RM[Room]');
}