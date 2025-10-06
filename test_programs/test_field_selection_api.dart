import 'dart:convert';
import 'dart:io';

// Test if staging API supports field selection with 'only' parameter

const String baseUrl = 'https://vgw1-01.dal-interurban.mdu.attwifi.com';
const String username = 'rgnets';
const String password = 'venti-red-sty-why';

Future<void> testFieldSelection() async {
  print('=== TESTING FIELD SELECTION ON STAGING API ===\n');
  
  // Test access_points endpoint with field selection
  final endpoints = [
    '/api/access_points',
    '/api/media_converters',
    '/api/switch_devices',
    '/api/wlan_devices',
  ];
  
  // Fields for list view (minimal)
  final listFields = [
    'id',
    'name',
    'type',
    'status',
    'ip_address',
    'mac_address',
    'pms_room',
    'location',
    'last_seen',
    'signal_strength',
    'connected_clients',
  ];
  
  for (final endpoint in endpoints) {
    print('\n--- Testing $endpoint ---');
    
    // Test 1: Full data (no field selection)
    print('1. Fetching ALL fields...');
    var fullResponse = await makeRequest('$endpoint?page_size=1');
    if (fullResponse != null) {
      final fullSize = jsonEncode(fullResponse).length;
      final fieldCount = fullResponse is Map ? fullResponse.keys.length : 
                         (fullResponse is List && fullResponse.isNotEmpty) ? 
                         (fullResponse.first as Map).keys.length : 0;
      print('   Response size: $fullSize bytes');
      print('   Field count: $fieldCount');
    }
    
    // Test 2: With field selection
    print('\n2. Fetching with field selection (only parameter)...');
    final onlyParam = listFields.join(',');
    var selectedResponse = await makeRequest('$endpoint?page_size=1&only=$onlyParam');
    if (selectedResponse != null) {
      final selectedSize = jsonEncode(selectedResponse).length;
      final selectedFieldCount = selectedResponse is Map ? selectedResponse.keys.length :
                                 (selectedResponse is List && selectedResponse.isNotEmpty) ?
                                 (selectedResponse.first as Map).keys.length : 0;
      print('   Response size: $selectedSize bytes');
      print('   Field count: $selectedFieldCount');
      
      // Calculate improvement
      if (fullResponse != null) {
        final fullSize = jsonEncode(fullResponse).length;
        final reduction = ((fullSize - selectedSize) / fullSize * 100).toStringAsFixed(1);
        print('   Size reduction: $reduction%');
      }
    }
    
    // Test 3: Check if 'fields' parameter works instead
    print('\n3. Testing alternative: fields parameter...');
    var fieldsResponse = await makeRequest('$endpoint?page_size=1&fields=$onlyParam');
    if (fieldsResponse != null) {
      final fieldsSize = jsonEncode(fieldsResponse).length;
      print('   Response size: $fieldsSize bytes');
    }
  }
}

Future<dynamic> makeRequest(String path) async {
  try {
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) => true;
    
    final uri = Uri.parse('$baseUrl$path');
    final request = await client.getUrl(uri);
    
    // Add basic auth
    final credentials = base64Encode(utf8.encode('$username:$password'));
    request.headers.add('Authorization', 'Basic $credentials');
    
    final response = await request.close();
    
    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      return jsonDecode(responseBody);
    } else {
      print('   ERROR: Status ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('   ERROR: $e');
    return null;
  }
}

void main() async {
  await testFieldSelection();
  print('\n=== FIELD SELECTION TEST COMPLETE ===');
}