#!/usr/bin/env dart

// Test: MAC address formatting for UI display

void main() {
  print('=' * 60);
  print('MAC ADDRESS FORMATTING TEST');
  print('=' * 60);
  
  // Sample data from actual API
  final testCases = [
    {
      'ip': '192.168.1.100',
      'mac': 'AA:BB:CC:DD:EE:FF',
    },
    {
      'ip': '10.0.0.1',
      'mac': '00:11:22:33:44:55',
    },
    {
      'ip': null,
      'mac': 'AA:BB:CC:DD:EE:FF',
    },
    {
      'ip': '192.168.1.1',
      'mac': null,
    },
    {
      'ip': null,
      'mac': null,
    },
    {
      'ip': '2001:0db8:85a3:0000:0000:8a2e:0370:7334', // IPv6
      'mac': 'AA:BB:CC:DD:EE:FF',
    },
  ];
  
  print('\nFORMAT OPTIONS:');
  print('-' * 40);
  
  print('\nOption 1: Bullet separator');
  for (final device in testCases) {
    final ip = device['ip'] ?? 'No IP';
    final mac = device['mac'] ?? 'No MAC';
    final display = '$ip • $mac';
    print('  $display');
  }
  
  print('\nOption 2: Pipe separator');
  for (final device in testCases) {
    final ip = device['ip'] ?? 'No IP';
    final mac = device['mac'] ?? 'No MAC';
    final display = '$ip | $mac';
    print('  $display');
  }
  
  print('\nOption 3: Two lines (current)');
  for (final device in testCases) {
    final ip = device['ip'] ?? 'No IP assigned';
    final mac = device['mac'] ?? '';
    print('  $ip');
    if (mac.isNotEmpty) {
      print('  MAC: $mac');
    }
  }
  
  print('\nOption 4: Smart formatting');
  for (final device in testCases) {
    String display;
    if (device['ip'] != null && device['mac'] != null) {
      display = '${device['ip']} • ${device['mac']}';
    } else if (device['ip'] != null) {
      display = device['ip'] as String;
    } else if (device['mac'] != null) {
      display = 'MAC: ${device['mac']}';
    } else {
      display = 'No network info';
    }
    print('  $display');
  }
  
  print('\n\n' + '=' * 60);
  print('LENGTH ANALYSIS');
  print('=' * 60);
  
  print('\nTypical lengths:');
  print('  IP (IPv4): 7-15 chars (e.g., "10.0.0.1" to "192.168.100.100")');
  print('  IP (IPv6): up to 39 chars');
  print('  MAC: 17 chars (e.g., "AA:BB:CC:DD:EE:FF")');
  print('  Separator: 3 chars (" • ")');
  print('  Total IPv4: 27-35 chars typical');
  print('  Total IPv6: up to 59 chars');
  
  print('\nMobile screen width analysis:');
  print('  iPhone SE: ~320px width');
  print('  Typical: ~375px width');
  print('  Large: ~428px width');
  print('  With 16px margins: ~288-396px available');
  print('  At 12px font: ~24-33 chars visible');
  
  print('\n\n' + '=' * 60);
  print('RECOMMENDATION');
  print('=' * 60);
  
  print('\nBEST APPROACH:');
  print('-' * 40);
  print('''
subtitleLines: [
  UnifiedInfoLine(
    text: _formatNetworkInfo(device),
  ),
],

// Helper method
String _formatNetworkInfo(Device device) {
  final ip = device.ipAddress;
  final mac = device.macAddress;
  
  if (ip != null && mac != null) {
    // Check for IPv6 (longer addresses)
    if (ip.contains(':') && ip.length > 20) {
      // IPv6 - use two lines
      return ip; // MAC will be in detail view
    }
    return '\$ip • \$mac';
  } else if (ip != null) {
    return ip;
  } else if (mac != null) {
    return 'MAC: \$mac';
  } else {
    return 'No network info';
  }
}
''');
  
  print('\nADVANTAGES:');
  print('  ✅ Handles all cases gracefully');
  print('  ✅ IPv6 addresses don\'t overflow');
  print('  ✅ Clean fallbacks for missing data');
  print('  ✅ Consistent with other list items');
  print('  ✅ Professional appearance');
  
  print('\n\n' + '=' * 60);
  print('FLUTTER WIDGET TEST');
  print('=' * 60);
  
  print('\nTest the actual rendering:');
  print('''
// Test widget
class TestListItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return UnifiedListItem(
      title: 'AP-Floor2-Room201',
      icon: Icons.wifi,
      status: UnifiedItemStatus.online,
      subtitleLines: [
        UnifiedInfoLine(
          text: '192.168.1.100 • AA:BB:CC:DD:EE:FF',
        ),
      ],
      showChevron: true,
      onTap: () {},
    );
  }
}
''');
  
  print('\nThis will render as:');
  print('  ┌─────────────────────────────────┐');
  print('  │ 📶 AP-Floor2-Room201        🟢 > │');
  print('  │     192.168.1.100 • AA:BB:CC... │');
  print('  └─────────────────────────────────┘');
  print('');
  print('With text overflow handled by ellipsis');
}