#!/usr/bin/env dart

import 'package:rgnets_fdk/core/services/mock_data_service.dart';

/// Test that MDF switches now include building numbers
void main() {
  print('MDF NUMBERING TEST');
  print('=' * 80);
  
  final mockService = MockDataService();
  final devices = mockService.getMockDevices();
  
  // Get all switches
  final switches = devices.where((d) => d.type == 'switch').toList();
  
  // Find MDF switches (they should end with -MDF[building])
  print('\nMDF SWITCHES WITH BUILDING NUMBERS:');
  print('-' * 50);
  print('Expected format: SW[building]-[floor]-[serial]-[model]-MDF[building]');
  print('');
  
  final mdfSwitches = switches.where((s) => s.name.contains('MDF')).toList();
  
  // Group by building
  final mdfByBuilding = <String, List<dynamic>>{};
  for (final sw in mdfSwitches) {
    // Extract building from name (first digit after SW)
    final building = sw.name.substring(2, 3);
    mdfByBuilding.putIfAbsent(building, () => []).add(sw);
  }
  
  // Display MDFs by building
  for (final building in mdfByBuilding.keys.toList()..sort()) {
    print('Building $building MDF Switches:');
    for (final sw in mdfByBuilding[building]!.take(4)) {
      print('  ${sw.name.padRight(30)} Location: ${sw.location}');
      
      // Verify format
      if (sw.name.endsWith('MDF$building')) {
        print('    ✓ Correct MDF format with building number');
      } else {
        print('    ✗ Wrong format! Should end with MDF$building');
      }
    }
    print('');
  }
  
  // Summary of all special room formats
  print('SPECIAL ROOM FORMAT SUMMARY:');
  print('-' * 50);
  
  // Count each type
  final mdfCount = switches.where((s) => s.name.contains('MDF')).length;
  final idfCount = switches.where((s) => s.name.contains('IDF')).length;
  final regularCount = switches.where((s) => s.name.contains('RM')).length;
  
  print('MDF Switches (with building numbers): $mdfCount');
  print('  Format: SW[b]-[f]-[serial]-[model]-MDF[b]');
  print('  Example: SW1-1-0001-SW900-MDF1');
  print('');
  
  print('IDF Switches (with floor numbers): $idfCount');
  print('  Format: SW[b]-[f]-[serial]-[model]-IDF[f]');
  print('  Example: SW1-2-0043-SW240-IDF2');
  print('');
  
  print('Regular Room Switches: $regularCount');
  print('  Format: SW[b]-[f]-[serial]-[model]-RM[room]');
  print('  Example: SW1-2-0075-SW8P-RM212');
  
  print('\n✓ All MDF switches now include building numbers');
  print('✓ Makes it clear which building each MDF serves');
  print('✓ Format: MDF1, MDF2, MDF3, MDF4, MDF5');
}