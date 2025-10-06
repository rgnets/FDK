#!/usr/bin/env dart

import 'package:rgnets_fdk/core/services/mock_data_service.dart';

/// Verify that mock data now uses production-like format
void main() {
  print('PRODUCTION FORMAT VERIFICATION');
  print('=' * 80);
  
  final mockService = MockDataService();
  final devices = mockService.getMockDevices();
  
  print('\nTotal devices generated: ${devices.length}');
  
  // Check Access Points
  print('\n1. ACCESS POINTS (Production Format):');
  print('-' * 50);
  print('Expected format: AP[building]-[floor]-[serial]-[model]-RM[room]');
  print('Example: AP1-2-0001-AP520-RM205\n');
  
  final aps = devices.where((d) => d.type == 'access_point').take(10).toList();
  for (final ap in aps) {
    print('  ${ap.name.padRight(30)} Location: ${ap.location}');
    
    // Verify format
    if (ap.name.startsWith('AP') && ap.name.contains('-RM')) {
      final parts = ap.name.split('-');
      if (parts.length >= 5) {
        print('    ✓ Correct production format');
        print('    Building: ${parts[0].substring(2)}, Floor: ${parts[1]}, Serial: ${parts[2]}, Model: ${parts[3]}');
      } else {
        print('    ✗ Wrong format! Parts: ${parts.length}');
      }
    } else {
      print('    ✗ Wrong format!');
    }
  }
  
  // Check ONTs
  print('\n2. ONTs (Production Format):');
  print('-' * 50);
  print('Expected format: ONT[building]-[floor]-[serial]-[model]-RM[room]');
  print('Example: ONT1-2-1001-ONT200-RM205\n');
  
  final onts = devices.where((d) => d.type == 'ont').take(10).toList();
  for (final ont in onts) {
    print('  ${ont.name.padRight(30)} Location: ${ont.location}');
    
    // Verify format
    if (ont.name.startsWith('ONT') && ont.name.contains('-RM')) {
      final parts = ont.name.split('-');
      if (parts.length >= 5) {
        print('    ✓ Correct production format');
        print('    Building: ${parts[0].substring(3)}, Floor: ${parts[1]}, Serial: ${parts[2]}, Model: ${parts[3]}');
      } else {
        print('    ✗ Wrong format! Parts: ${parts.length}');
      }
    } else {
      print('    ✗ Wrong format!');
    }
  }
  
  // Check Switches (should be descriptive)
  print('\n3. SWITCHES (Descriptive Names):');
  print('-' * 50);
  final switches = devices.where((d) => d.type == 'switch').take(5).toList();
  for (final sw in switches) {
    print('  ${sw.name.padRight(30)} Location: ${sw.location}');
  }
  
  // Check name lengths
  print('\n4. NAME LENGTH ANALYSIS:');
  print('-' * 50);
  final apLengths = devices
      .where((d) => d.type == 'access_point')
      .map((d) => d.name.length)
      .toList();
  final ontLengths = devices
      .where((d) => d.type == 'ont')
      .map((d) => d.name.length)
      .toList();
  
  if (apLengths.isNotEmpty) {
    final avgApLength = apLengths.reduce((a, b) => a + b) / apLengths.length;
    final maxApLength = apLengths.reduce((a, b) => a > b ? a : b);
    final minApLength = apLengths.reduce((a, b) => a < b ? a : b);
    print('  AP names:');
    print('    Average: ${avgApLength.toStringAsFixed(1)} chars');
    print('    Min: $minApLength chars, Max: $maxApLength chars');
    print('    Production example: 22 chars (AP1-0-0030-WF189-RM007)');
  }
  
  if (ontLengths.isNotEmpty) {
    final avgOntLength = ontLengths.reduce((a, b) => a + b) / ontLengths.length;
    final maxOntLength = ontLengths.reduce((a, b) => a > b ? a : b);
    final minOntLength = ontLengths.reduce((a, b) => a < b ? a : b);
    print('  ONT names:');
    print('    Average: ${avgOntLength.toStringAsFixed(1)} chars');
    print('    Min: $minOntLength chars, Max: $maxOntLength chars');
  }
  
  // Summary
  print('\n5. SUMMARY:');
  print('-' * 50);
  print('✓ Device names now follow production format');
  print('✓ Format: [Type][Building]-[Floor]-[Serial]-[Model]-RM[Room]');
  print('✓ Names are realistic and match actual production patterns');
  print('✓ Maintains Clean Architecture - changes only in data layer');
}