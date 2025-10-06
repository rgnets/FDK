#!/usr/bin/env dart

import 'package:rgnets_fdk/core/services/mock_data_service.dart';

/// Verify the room ID collision fix
void main() {
  print('=' * 80);
  print('VERIFYING ROOM ID COLLISION FIX');
  print('=' * 80);
  
  final mockService = MockDataService();
  final pmsRoomsJson = mockService.getMockPmsRoomsJson();
  final results = pmsRoomsJson['results'] as List<dynamic>;
  
  print('\n1. CHECKING FOR DUPLICATE IDS:');
  print('-' * 40);
  
  final idSet = <int>{};
  final duplicates = <int>[];
  
  for (final room in results) {
    final id = room['id'] as int;
    if (idSet.contains(id)) {
      duplicates.add(id);
    }
    idSet.add(id);
  }
  
  if (duplicates.isEmpty) {
    print('✓ SUCCESS: No duplicate IDs found!');
  } else {
    print('✗ FAILURE: Found ${duplicates.length} duplicate IDs: $duplicates');
  }
  
  print('\n2. ID RANGES:');
  print('-' * 40);
  
  // Check special rooms (first 40)
  final specialRooms = results.take(40).toList();
  final specialIds = specialRooms.map((r) => r['id'] as int).toList()..sort();
  print('Special rooms (first 40):');
  print('  Count: ${specialIds.length}');
  print('  Range: ${specialIds.first} - ${specialIds.last}');
  print('  Expected: 1000 - 1039');
  print('  Match: ${specialIds.first == 1000 && specialIds.last == 1039 ? "✓" : "✗"}');
  
  // Check standard rooms (remaining)
  final standardRooms = results.skip(40).toList();
  final standardIds = standardRooms.map((r) => r['id'] as int).toList()..sort();
  print('\nStandard rooms (remaining ${standardRooms.length}):');
  print('  Count: ${standardIds.length}');
  print('  Range: ${standardIds.first} - ${standardIds.last}');
  print('  Expected: 1040 - 1679');
  print('  Match: ${standardIds.first == 1040 && standardIds.last == 1679 ? "✓" : "✗"}');
  
  print('\n3. SAMPLE DATA:');
  print('-' * 40);
  print('Last special room:');
  final lastSpecial = results[39];
  print('  ID: ${lastSpecial['id']}, Name: "${lastSpecial['name']}"');
  
  print('\nFirst standard room:');
  final firstStandard = results[40];
  print('  ID: ${firstStandard['id']}, Name: "${firstStandard['name']}"');
  
  print('\n4. TOTAL ROOMS:');
  print('-' * 40);
  print('Total count: ${results.length}');
  print('Expected: 680');
  print('Match: ${results.length == 680 ? "✓" : "✗"}');
  
  print('\n5. UNIQUE IDS:');
  print('-' * 40);
  print('Unique IDs: ${idSet.length}');
  print('Expected: 680');
  print('Match: ${idSet.length == 680 ? "✓" : "✗"}');
  
  // Final summary
  final allGood = duplicates.isEmpty && 
                  results.length == 680 && 
                  idSet.length == 680 &&
                  specialIds.first == 1000 && 
                  specialIds.last == 1039 &&
                  standardIds.first == 1040 && 
                  standardIds.last == 1679;
  
  print('\n' + '=' * 80);
  print(allGood ? '✓ ALL CHECKS PASSED - FIX SUCCESSFUL!' : '✗ SOME CHECKS FAILED');
  print('=' * 80);
}