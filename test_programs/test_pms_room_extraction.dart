#!/usr/bin/env dart

// Test pmsRoomId extraction logic

int? extractPmsRoomId(Map<String, dynamic> deviceMap) {
  if (deviceMap['pms_room'] != null && deviceMap['pms_room'] is Map) {
    final pmsRoom = deviceMap['pms_room'] as Map<String, dynamic>;
    final idValue = pmsRoom['id'];
    if (idValue is int) {
      return idValue;
    } else if (idValue is String) {
      return int.tryParse(idValue);
    }
  }
  return null;
}

void testExtraction(String name, Map<String, dynamic> deviceData) {
  print('\n$name');
  print('Input: $deviceData');
  final result = extractPmsRoomId(deviceData);
  print('Extracted pmsRoomId: $result');
}

void main() {
  print('PMS ROOM ID EXTRACTION TEST');
  print('=' * 80);
  
  // Test various API response formats
  testExtraction('Format 1: Nested Map with int ID', {
    'id': 123,
    'name': 'AP-001',
    'pms_room': {
      'id': 1,
      'name': 'Room 101',
    }
  });
  
  testExtraction('Format 2: Nested Map with String ID', {
    'id': 123,
    'name': 'AP-001',
    'pms_room': {
      'id': '1',
      'name': 'Room 101',
    }
  });
  
  testExtraction('Format 3: No pms_room field', {
    'id': 123,
    'name': 'AP-001',
    'room_id': 1,
  });
  
  testExtraction('Format 4: pms_room is null', {
    'id': 123,
    'name': 'AP-001',
    'pms_room': null,
  });
  
  testExtraction('Format 5: pms_room is not a Map', {
    'id': 123,
    'name': 'AP-001',
    'pms_room': 1,  // Direct ID
  });
  
  testExtraction('Format 6: pms_room Map without id', {
    'id': 123,
    'name': 'AP-001',
    'pms_room': {
      'room_number': '101',
      'name': 'Room 101',
    }
  });
  
  print('\n' + '=' * 80);
  print('OBSERVATIONS:');
  print('=' * 80);
  print('\n1. Current extraction only works for:');
  print('   - pms_room as Map with "id" field');
  print('\n2. Current extraction fails for:');
  print('   - Missing pms_room field');
  print('   - pms_room as direct value');
  print('   - Alternative field names (room_id, pms_room_id)');
  
  print('\n' + '=' * 80);
  print('IMPROVED EXTRACTION:');
  print('=' * 80);
  
  // Improved extraction that checks multiple fields
  int? improvedExtractPmsRoomId(Map<String, dynamic> deviceMap) {
    // Try nested pms_room.id first
    if (deviceMap['pms_room'] != null && deviceMap['pms_room'] is Map) {
      final pmsRoom = deviceMap['pms_room'] as Map<String, dynamic>;
      final idValue = pmsRoom['id'];
      if (idValue is int) return idValue;
      if (idValue is String) {
        final parsed = int.tryParse(idValue);
        if (parsed != null) return parsed;
      }
    }
    
    // Try direct pms_room_id field
    if (deviceMap['pms_room_id'] != null) {
      final value = deviceMap['pms_room_id'];
      if (value is int) return value;
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    
    // Try room_id field
    if (deviceMap['room_id'] != null) {
      final value = deviceMap['room_id'];
      if (value is int) return value;
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    
    // Try direct pms_room as ID
    if (deviceMap['pms_room'] != null && deviceMap['pms_room'] is! Map) {
      final value = deviceMap['pms_room'];
      if (value is int) return value;
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    
    return null;
  }
  
  print('\nTesting improved extraction:');
  
  void testImproved(String name, Map<String, dynamic> data) {
    print('\n$name');
    print('Input: $data');
    final result = improvedExtractPmsRoomId(data);
    print('Improved extraction: $result');
  }
  
  testImproved('Direct pms_room_id field', {
    'id': 123,
    'pms_room_id': 1,
  });
  
  testImproved('room_id field', {
    'id': 123,
    'room_id': 1,
  });
  
  testImproved('pms_room as direct value', {
    'id': 123,
    'pms_room': 1,
  });
}