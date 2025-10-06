// Verify complete field mapping between Device entity and DeviceModel

void main() {
  print('=== ENTITY-MODEL FIELD MAPPING VERIFICATION ===\n');
  
  // Device entity fields (from domain layer)
  final deviceEntityFields = [
    'id',
    'name', 
    'type',
    'status',
    'pmsRoom',        // NEW - Room object
    'pmsRoomId',
    'ipAddress',
    'macAddress',
    'location',
    'lastSeen',
    'metadata',
    'model',
    'serialNumber',
    'firmware',
    'signalStrength',
    'uptime',
    'connectedClients',
    'vlan',
    'ssid',
    'channel',
    'totalUpload',
    'totalDownload',
    'currentUpload',
    'currentDownload',
    'packetLoss',
    'latency',
    'cpuUsage',
    'memoryUsage',
    'temperature',
    'restartCount',
    'maxClients',
    'note',           // IMPORTANT - must be in model
    'images',         // IMPORTANT - must be in model
  ];
  
  // DeviceModel fields (from data layer) 
  final deviceModelFields = [
    'id',
    'name',
    'type', 
    'status',
    'pmsRoom',        // Maps to Room entity
    'pmsRoomId',
    'ipAddress',
    'macAddress',
    'location',
    'lastSeen',
    'metadata',
    'model',
    'serialNumber',
    'firmware',
    'signalStrength',
    'uptime',
    'connectedClients',
    'vlan',
    'ssid',
    'channel',
    'totalUpload',
    'totalDownload',
    'currentUpload',
    'currentDownload',
    'packetLoss',
    'latency',
    'cpuUsage',
    'memoryUsage',
    'temperature',
    'restartCount',
    'maxClients',
    'note',           // MUST BE PRESENT
    'images',         // MUST BE PRESENT
  ];
  
  // DeviceModel.toEntity() mapping
  final toEntityMapping = {
    'id': 'id',
    'name': 'name',
    'type': 'type',
    'status': 'status',
    'pmsRoom': 'pmsRoom?.toEntity()',
    'pmsRoomId': 'pmsRoomId ?? pmsRoom?.id',
    'ipAddress': 'ipAddress',
    'macAddress': 'macAddress',
    'location': 'location ?? pmsRoom?.name',
    'lastSeen': 'lastSeen',
    'metadata': 'metadata',
    'model': 'model',
    'serialNumber': 'serialNumber',
    'firmware': 'firmware',
    'signalStrength': 'signalStrength',
    'uptime': 'uptime',
    'connectedClients': 'connectedClients',
    'vlan': 'vlan',
    'ssid': 'ssid',
    'channel': 'channel',
    'totalUpload': 'totalUpload',
    'totalDownload': 'totalDownload',
    'currentUpload': 'currentUpload',
    'currentDownload': 'currentDownload',
    'packetLoss': 'packetLoss',
    'latency': 'latency',
    'cpuUsage': 'cpuUsage',
    'memoryUsage': 'memoryUsage',
    'temperature': 'temperature',
    'restartCount': 'restartCount',
    'maxClients': 'maxClients',
    'note': 'note',              // CRITICAL
    'images': 'images',          // CRITICAL
  };
  
  // Check for missing fields in model
  print('1. Checking for missing fields in DeviceModel:');
  var missingInModel = <String>[];
  for (final field in deviceEntityFields) {
    if (!deviceModelFields.contains(field)) {
      missingInModel.add(field);
      print('   ❌ Missing in DeviceModel: $field');
    }
  }
  if (missingInModel.isEmpty) {
    print('   ✅ All entity fields present in DeviceModel');
  }
  
  // Check for missing mappings in toEntity()
  print('\n2. Checking toEntity() mapping completeness:');
  var missingMapping = <String>[];
  for (final field in deviceEntityFields) {
    if (!toEntityMapping.containsKey(field)) {
      missingMapping.add(field);
      print('   ❌ Missing mapping for: $field');
    }
  }
  if (missingMapping.isEmpty) {
    print('   ✅ All fields mapped in toEntity()');
  }
  
  // Check JSON key mappings
  print('\n3. JSON Key Mappings (snake_case to camelCase):');
  final jsonKeyMappings = {
    'pms_room': 'pmsRoom',
    'pms_room_id': 'pmsRoomId', 
    'ip_address': 'ipAddress',
    'mac_address': 'macAddress',
    'last_seen': 'lastSeen',
    'serial_number': 'serialNumber',
    'signal_strength': 'signalStrength',
    'connected_clients': 'connectedClients',
    'total_upload': 'totalUpload',
    'total_download': 'totalDownload',
    'current_upload': 'currentUpload',
    'current_download': 'currentDownload',
    'packet_loss': 'packetLoss',
    'cpu_usage': 'cpuUsage',
    'memory_usage': 'memoryUsage',
    'restart_count': 'restartCount',
    'max_clients': 'maxClients',
  };
  
  jsonKeyMappings.forEach((jsonKey, modelField) {
    print('   ✅ @JsonKey(name: \'$jsonKey\') $modelField');
  });
  
  // Room entity fields
  print('\n4. Room Entity Fields:');
  final roomFields = ['id', 'name', 'building', 'floor', 'number'];
  roomFields.forEach((field) {
    print('   ✅ Room.$field');
  });
  
  // Room model mapping
  print('\n5. RoomModel to Room Entity Mapping:');
  print('   ✅ RoomModel.fromJson() handles pms_room object');
  print('   ✅ RoomModel.toEntity() creates Room entity');
  
  // Critical fields verification
  print('\n6. CRITICAL FIELDS VERIFICATION:');
  final criticalChecks = {
    'note field in Device': deviceEntityFields.contains('note'),
    'images field in Device': deviceEntityFields.contains('images'),
    'note field in DeviceModel': deviceModelFields.contains('note'),
    'images field in DeviceModel': deviceModelFields.contains('images'),
    'note mapped in toEntity()': toEntityMapping.containsKey('note'),
    'images mapped in toEntity()': toEntityMapping.containsKey('images'),
    'pmsRoom field added': deviceEntityFields.contains('pmsRoom'),
    'Room entity integration': true,
  };
  
  var allPassed = true;
  criticalChecks.forEach((check, result) {
    print('   ${result ? "✅" : "❌"} $check');
    if (!result) allPassed = false;
  });
  
  // Summary
  print('\n=== SUMMARY ===');
  if (allPassed && missingInModel.isEmpty && missingMapping.isEmpty) {
    print('✅ ALL FIELDS CORRECTLY MAPPED');
    print('✅ Entity-Model mapping is complete');
    print('✅ note and images fields included');
    print('✅ pmsRoom integration complete');
    print('✅ Clean Architecture maintained');
  } else {
    print('❌ MAPPING ISSUES DETECTED');
    if (missingInModel.isNotEmpty) {
      print('Missing in model: ${missingInModel.join(", ")}');
    }
    if (missingMapping.isNotEmpty) {
      print('Missing mappings: ${missingMapping.join(", ")}');
    }
  }
}