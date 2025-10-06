import 'dart:convert';
import 'dart:io';

// Test if staging API supports field selection with 'only' parameter
// Using correct Bearer authentication

const String baseUrl = 'https://vgw1-01.dal-interurban.mdu.attwifi.com';
const String apiKey = 'xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r';

Future<void> testFieldSelection() async {
  print('=== TESTING FIELD SELECTION ON STAGING API ===');
  print('Using Bearer token authentication');
  print('Using page_size=0 for full lists\n');
  
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
    print('1. Fetching ALL fields (page_size=0)...');
    var sw = Stopwatch()..start();
    var fullResponse = await makeRequest('$endpoint?page_size=0');
    sw.stop();
    
    if (fullResponse != null) {
      final responseStr = jsonEncode(fullResponse);
      final fullSize = responseStr.length;
      
      // Count fields in first item
      int fieldCount = 0;
      if (fullResponse is Map && fullResponse['results'] is List) {
        final results = fullResponse['results'] as List;
        if (results.isNotEmpty) {
          fieldCount = (results.first as Map).keys.length;
        }
      } else if (fullResponse is List && fullResponse.isNotEmpty) {
        fieldCount = (fullResponse.first as Map).keys.length;
      }
      
      print('   ✅ Success');
      print('   Response size: ${(fullSize / 1024).toStringAsFixed(1)} KB');
      print('   Time taken: ${sw.elapsedMilliseconds} ms');
      print('   Field count per item: $fieldCount');
      
      // Store for comparison
      final fullSizeBytes = fullSize;
      final fullTimeMs = sw.elapsedMilliseconds;
      
      // Test 2: With field selection using 'only' parameter
      print('\n2. Testing with field selection (only parameter)...');
      final onlyParam = listFields.join(',');
      sw = Stopwatch()..start();
      var selectedResponse = await makeRequest('$endpoint?page_size=0&only=$onlyParam');
      sw.stop();
      
      if (selectedResponse != null) {
        final selectedStr = jsonEncode(selectedResponse);
        final selectedSize = selectedStr.length;
        
        // Count fields in first item
        int selectedFieldCount = 0;
        if (selectedResponse is Map && selectedResponse['results'] is List) {
          final results = selectedResponse['results'] as List;
          if (results.isNotEmpty) {
            selectedFieldCount = (results.first as Map).keys.length;
          }
        } else if (selectedResponse is List && selectedResponse.isNotEmpty) {
          selectedFieldCount = (selectedResponse.first as Map).keys.length;
        }
        
        print('   ✅ Success');
        print('   Response size: ${(selectedSize / 1024).toStringAsFixed(1)} KB');
        print('   Time taken: ${sw.elapsedMilliseconds} ms');
        print('   Field count per item: $selectedFieldCount');
        
        // Calculate improvement
        final sizeReduction = ((fullSizeBytes - selectedSize) / fullSizeBytes * 100);
        final timeReduction = ((fullTimeMs - sw.elapsedMilliseconds) / fullTimeMs * 100);
        
        print('\n   📊 PERFORMANCE IMPROVEMENT:');
        print('   Size reduction: ${sizeReduction.toStringAsFixed(1)}%');
        print('   Time reduction: ${timeReduction.toStringAsFixed(1)}%');
        print('   Fields reduced from $fieldCount to $selectedFieldCount');
      } else {
        print('   ❌ Field selection not supported or failed');
      }
      
      // Test 3: Check if 'fields' parameter works instead
      print('\n3. Testing alternative: fields parameter...');
      sw = Stopwatch()..start();
      var fieldsResponse = await makeRequest('$endpoint?page_size=0&fields=$onlyParam');
      sw.stop();
      
      if (fieldsResponse != null) {
        final fieldsStr = jsonEncode(fieldsResponse);
        final fieldsSize = fieldsStr.length;
        print('   Response size: ${(fieldsSize / 1024).toStringAsFixed(1)} KB');
        print('   Time taken: ${sw.elapsedMilliseconds} ms');
        
        // Check if it's different from full response
        if (fieldsSize < fullSizeBytes * 0.9) {
          print('   ✅ fields parameter seems to work!');
        } else {
          print('   ❌ fields parameter has no effect');
        }
      }
    } else {
      print('   ❌ Failed to fetch data');
    }
  }
}

Future<dynamic> makeRequest(String path) async {
  try {
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) => true;
    
    final uri = Uri.parse('$baseUrl$path');
    final request = await client.getUrl(uri);
    
    // Add Bearer token authentication
    request.headers.add('Authorization', 'Bearer $apiKey');
    request.headers.add('Accept', 'application/json');
    
    final response = await request.close();
    
    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      return jsonDecode(responseBody);
    } else {
      print('   ERROR: Status ${response.statusCode}');
      final errorBody = await response.transform(utf8.decoder).join();
      if (errorBody.isNotEmpty) {
        print('   Error message: $errorBody');
      }
      return null;
    }
  } catch (e) {
    print('   ERROR: $e');
    return null;
  }
}

void main() async {
  await testFieldSelection();
  
  print('\n' + '=' * 60);
  print('SUMMARY');
  print('=' * 60);
  print('If field selection is supported, we should implement it to:');
  print('1. Reduce data transfer by 70-90%');
  print('2. Improve API response time significantly');
  print('3. Lower memory usage in the app');
  print('4. Provide better user experience');
}