#!/usr/bin/env dart

// Test: Analysis of current issues before changes

void main() {
  print('=' * 60);
  print('CURRENT ISSUES ANALYSIS');
  print('=' * 60);
  
  print('\n1. DEVICE PAGE - NETWORK INFO DISPLAY:');
  print('-' * 40);
  
  // Current behavior
  final testCases = [
    {'ip': '192.168.1.1', 'mac': 'AA:BB:CC:DD:EE:FF'},
    {'ip': '192.168.1.1', 'mac': null},
    {'ip': null, 'mac': 'AA:BB:CC:DD:EE:FF'},
    {'ip': null, 'mac': null},
  ];
  
  print('\nCURRENT _formatNetworkInfo() output:');
  for (final device in testCases) {
    final result = currentFormatNetworkInfo(device['ip'] as String?, device['mac'] as String?);
    print('  IP: ${device['ip'] ?? "null"}, MAC: ${device['mac'] ?? "null"}');
    print('  → "$result"');
  }
  
  print('\n⚠️ ISSUE: When IP exists but MAC is null, it shows only IP');
  print('         User expects: "192.168.1.1 • No MAC"');
  print('         Currently shows: "192.168.1.1"');
  
  print('\n\n2. NOTIFICATIONS PAGE - LINE COUNT:');
  print('-' * 40);
  
  print('\nCURRENT CODE STRUCTURE:');
  print('  subtitleLines = [');
  print('    UnifiedInfoLine(text: message, maxLines: 1),');
  print('    UnifiedInfoLine(text: timestamp),');
  print('  ]');
  print('  Total subtitle lines: 2');
  print('  Plus title line: 1');
  print('  TOTAL LINES: 3 (title + 2 subtitle)');
  
  print('\n⚠️ POSSIBLE ISSUE: ');
  print('  - Title might be wrapping to 2 lines if room name is long?');
  print('  - Or UnifiedListItem is not respecting max 2 subtitle lines?');
  
  print('\n\n3. ROOMS PAGE - PERCENTAGE CALCULATION:');
  print('-' * 40);
  
  print('\nCURRENT CALCULATION (line 27-28 room_view_models.dart):');
  print('  onlinePercentage = (onlineDevices / deviceCount) * 100');
  print('  Example: 8 online / 10 total = 80%');
  
  print('\n⚠️ ISSUES:');
  print('  1. Shows percentage of ONLINE devices (user wants OFFLINE)');
  print('  2. Line 55: onlineDevices = (deviceCount * 0.8).round()');
  print('     → HARDCODED 80% online! Not using actual device status!');
  
  print('\n\n' + '=' * 60);
  print('QUESTIONS FOR USER');
  print('=' * 60);
  
  print('\n1. DEVICE PAGE:');
  print('   When IP exists but MAC is missing, should it show:');
  print('   a) "192.168.1.1 • No MAC" (explicit)');
  print('   b) "192.168.1.1" (current behavior)');
  print('   ');
  print('   When MAC exists but IP is missing, should it show:');
  print('   a) "No IP • AA:BB:CC:DD:EE:FF" (consistent)');
  print('   b) "MAC: AA:BB:CC:DD:EE:FF" (current behavior)');
  
  print('\n2. NOTIFICATIONS PAGE:');
  print('   Are you seeing the title wrapping to 2 lines?');
  print('   Example: "Device Offline - Conference Room" might wrap?');
  print('   Or is there an extra blank line somewhere?');
  
  print('\n3. ROOMS PAGE PERCENTAGE:');
  print('   Should the percentage show:');
  print('   a) Devices ONLINE (current: 80% if 8/10 online)');
  print('   b) Devices OFFLINE (20% if 2/10 offline)');
  print('   ');
  print('   Also: The onlineDevices count is HARDCODED at 80%.');
  print('   Should this be calculated from actual device statuses?');
  print('   This requires access to devices data in room view model.');
  
  print('\n\n' + '=' * 60);
  print('PROPOSED FIXES');
  print('=' * 60);
  
  print('\n1. DEVICE PAGE FIX:');
  print('''
String _formatNetworkInfo(Device device) {
  final ip = device.ipAddress ?? 'No IP';
  final mac = device.macAddress ?? 'No MAC';
  
  // Special case for IPv6 (too long)
  if (device.ipAddress != null && 
      device.ipAddress!.contains(':') && 
      device.ipAddress!.length > 20) {
    return device.ipAddress!;
  }
  
  return '\$ip • \$mac';
}
''');
  
  print('\n2. NOTIFICATIONS - Need more info to fix');
  
  print('\n3. ROOMS PERCENTAGE FIX:');
  print('   Need to:');
  print('   a) Get actual device statuses (not hardcoded)');
  print('   b) Calculate offline percentage instead of online');
  print('   c) Update RoomViewModel to access device data');
}

String currentFormatNetworkInfo(String? ip, String? mac) {
  if (ip != null && mac != null) {
    if (ip.contains(':') && ip.length > 20) {
      return ip;
    }
    return '$ip • $mac';
  } else if (ip != null) {
    return ip;  // ← ISSUE: Should be "$ip • No MAC"
  } else if (mac != null) {
    return 'MAC: $mac';  // ← ISSUE: Should be "No IP • $mac"?
  } else {
    return 'No network info';
  }
}