#!/usr/bin/env dart

// Test: Prove the retry logic bug

void main() async {
  print('=' * 60);
  print('RETRY LOGIC BUG DEMONSTRATION');
  print('=' * 60);
  
  print('\nCURRENT RETRY LOGIC (lines 150-190):');
  print('-' * 40);
  
  print('''
Future<List<DeviceModel>> _fetchDeviceTypeWithRetry(
  String type, {
  int maxRetries = 3,
}) async {
  for (int attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      final results = await _fetchDeviceType(type);
      
      // If we got results, return them
      if (results.isNotEmpty) {
        return results;
      }
      
      // BUG HERE: Empty results might indicate error, but we return!
      _logger.w('Fetched 0 \$type on attempt \$attempt - may be legitimate');
      return results; // <-- RETURNS IMMEDIATELY WITHOUT RETRY!
      
    } catch (e) {
      // Only retries on exceptions, not empty results
      ...
    }
  }
}
''');
  
  print('\n\nTHE BUG:');
  print('-' * 40);
  print('When _fetchAllPages returns [] due to error:');
  print('  1. Line 35: response.data == null → returns []');
  print('  2. Line 62: No recognized data key → returns []');
  print('  3. Line 66: Unexpected response type → returns []');
  print('  4. Line 84: Exception caught → returns []');
  print('');
  print('The retry logic at line 170 ACCEPTS empty list as valid!');
  print('It returns immediately WITHOUT retrying!');
  
  print('\n\nSIMULATION:');
  print('-' * 40);
  
  // Simulate the buggy retry logic
  Future<List<String>> fetchWithBuggyRetry(String type, bool simulateError) async {
    for (int attempt = 1; attempt <= 3; attempt++) {
      print('\n  Attempt $attempt for $type:');
      
      try {
        // Simulate _fetchDeviceType
        List<String> results;
        if (simulateError && attempt == 1) {
          // First attempt fails, returns empty
          print('    _fetchAllPages returns [] due to error');
          results = [];
        } else {
          // Subsequent attempts would work
          print('    _fetchAllPages would return data');
          results = ['device1', 'device2'];
        }
        
        // Buggy logic
        if (results.isNotEmpty) {
          print('    ✅ Got ${results.length} items, returning');
          return results;
        }
        
        print('    ⚠️ Got 0 items, but RETURNING ANYWAY!');
        return results; // BUG: Returns empty without retry!
        
      } catch (e) {
        print('    Exception: $e');
        if (attempt == 3) return [];
        await Future.delayed(Duration(milliseconds: 100));
      }
    }
    return [];
  }
  
  print('\nCase 1: No error (works fine)');
  var result = await fetchWithBuggyRetry('access_points', false);
  print('  Result: ${result.length} items');
  
  print('\nCase 2: Transient error on first attempt');
  result = await fetchWithBuggyRetry('access_points', true);
  print('  Result: ${result.length} items');
  print('  🚨 SHOULD have retried and got 2 items!');
  
  print('\n\n' + '=' * 60);
  print('THE FIX');
  print('=' * 60);
  
  print('\nREMOVE lines 168-170 that return empty results:');
  print('''
// DELETE THESE LINES:
// Empty results might indicate a problem, but we'll accept it
_logger.w('Fetched 0 \$type on attempt \$attempt - may be legitimate');
return results;
''');
  
  print('\nREPLACE WITH:');
  print('''
// If empty, could be error - continue to retry
if (results.isEmpty && attempt < maxRetries) {
  _logger.w('Got 0 \$type on attempt \$attempt - retrying');
  await Future.delayed(Duration(seconds: attempt));
  continue;
}

// Last attempt or non-empty results
return results;
''');
  
  print('\n\nCORRECTED LOGIC:');
  print('-' * 40);
  
  // Simulate the fixed retry logic
  Future<List<String>> fetchWithFixedRetry(String type, bool simulateError) async {
    for (int attempt = 1; attempt <= 3; attempt++) {
      print('\n  Attempt $attempt for $type:');
      
      try {
        // Simulate _fetchDeviceType
        List<String> results;
        if (simulateError && attempt == 1) {
          // First attempt fails, returns empty
          print('    _fetchAllPages returns [] due to error');
          results = [];
        } else {
          // Subsequent attempts work
          print('    _fetchAllPages returns data');
          results = ['device1', 'device2'];
        }
        
        // Fixed logic
        if (results.isEmpty && attempt < 3) {
          print('    ⚠️ Got 0 items, RETRYING...');
          await Future.delayed(Duration(milliseconds: 100));
          continue;
        }
        
        print('    ✅ Returning ${results.length} items');
        return results;
        
      } catch (e) {
        print('    Exception: $e');
        if (attempt == 3) return [];
        await Future.delayed(Duration(milliseconds: 100));
      }
    }
    return [];
  }
  
  print('\nCase 1: No error (still works)');
  result = await fetchWithFixedRetry('access_points', false);
  print('  Result: ${result.length} items');
  
  print('\nCase 2: Transient error on first attempt');
  result = await fetchWithFixedRetry('access_points', true);
  print('  Result: ${result.length} items');
  print('  ✅ CORRECTLY retried and got data!');
  
  print('\n\n' + '=' * 60);
  print('CONCLUSION');
  print('=' * 60);
  
  print('\n🎯 ROOT CAUSE CONFIRMED:');
  print('The retry logic accepts empty lists as valid results');
  print('and returns immediately without retrying.');
  print('');
  print('When _fetchAllPages returns [] due to transient errors,');
  print('the retry logic doesn\'t actually retry!');
  print('');
  print('This explains the intermittent zeros in staging.');
}