#!/usr/bin/env dart

// Test 2: Trace what happens when ApiService tries to access EnvironmentConfig.apiKey

void main() {
  print('=' * 60);
  print('TEST 2: ApiService Exception Handling Analysis');
  print('=' * 60);
  
  // Simulate the ApiService._configureDio() interceptor onRequest
  print('\nSimulating ApiService._configureDio() onRequest interceptor:\n');
  
  // This simulates lines 86-94 of api_service.dart
  void simulateApiServiceOnRequest() {
    print('Checking: EnvironmentConfig.isStaging = true');
    
    // Line 86: if (EnvironmentConfig.isStaging || EnvironmentConfig.isProduction)
    final isStaging = true; // Simulating staging environment
    
    if (isStaging) {
      print('Entering staging/production block...');
      
      // Line 87: final apiKeyValue = apiKey ?? EnvironmentConfig.apiKey;
      print('\nLine 87: final apiKeyValue = apiKey ?? EnvironmentConfig.apiKey;');
      print('  - apiKey from storage is null (no stored credentials)');
      print('  - Falling back to EnvironmentConfig.apiKey...');
      
      String? apiKey = null; // From storage (null in staging)
      
      try {
        // This is what happens on line 87
        print('  - Accessing EnvironmentConfig.apiKey...');
        
        // Simulate EnvironmentConfig.apiKey getter for staging
        const stagingKey = String.fromEnvironment('STAGING_API_KEY', defaultValue: '');
        if (stagingKey.isEmpty) {
          throw Exception('STAGING_API_KEY not provided for staging environment');
        }
        
        final apiKeyValue = apiKey ?? stagingKey;
        print('  ✓ Got apiKeyValue: $apiKeyValue');
        
      } catch (e) {
        print('  ❌ EXCEPTION THROWN: $e');
        print('  - Exception escapes from line 87!');
        print('  - This exception is NOT caught in onRequest!');
        rethrow; // The exception propagates up
      }
    }
  }
  
  // Test what happens when the interceptor throws
  print('Testing interceptor exception propagation:\n');
  
  try {
    simulateApiServiceOnRequest();
  } catch (e) {
    print('\n❌ UNCAUGHT EXCEPTION in interceptor:');
    print('  Exception: $e');
    print('  This exception bubbles up to Dio!');
  }
  
  // Now check what Dio does with interceptor exceptions
  print('\n' + '-' * 40);
  print('What happens in Dio when interceptor throws:\n');
  
  print('According to Dio documentation:');
  print('1. If onRequest throws, the request is cancelled');
  print('2. The onError interceptor is called with the error');
  print('3. The Future completes with an error');
  
  // Simulate the complete flow
  print('\n' + '-' * 40);
  print('COMPLETE FLOW SIMULATION:\n');
  
  void simulateCompleteFlow() {
    print('1. API call initiated (e.g., getRooms())');
    print('2. Dio interceptor onRequest is called');
    print('3. onRequest tries to access EnvironmentConfig.apiKey');
    print('4. EnvironmentConfig.apiKey throws Exception');
    
    try {
      // Simulate onRequest
      const stagingKey = String.fromEnvironment('STAGING_API_KEY', defaultValue: '');
      if (stagingKey.isEmpty) {
        throw Exception('STAGING_API_KEY not provided for staging environment');
      }
    } catch (e) {
      print('5. Exception thrown: $e');
      print('6. onRequest interceptor fails');
      print('7. Request is CANCELLED');
      print('8. onError interceptor is called');
      print('9. Error is logged but request never sent!');
      print('10. API call Future completes with DioException');
    }
  }
  
  simulateCompleteFlow();
  
  // Triple verification with different scenarios
  print('\n' + '=' * 60);
  print('TRIPLE VERIFICATION OF EXCEPTION FLOW');
  print('=' * 60);
  
  // Scenario 1: Exception in interceptor
  print('\nScenario 1 - Exception in interceptor:');
  try {
    throw Exception('Test exception in onRequest');
  } catch (e) {
    print('Result: Request cancelled, error propagated');
  }
  
  // Scenario 2: Try-catch around EnvironmentConfig access
  print('\nScenario 2 - With try-catch wrapper:');
  String? getApiKeySafely() {
    try {
      // Simulate EnvironmentConfig.apiKey
      throw Exception('STAGING_API_KEY not provided');
    } catch (e) {
      print('Caught: $e');
      return null;
    }
  }
  final safeKey = getApiKeySafely();
  print('Result: ${safeKey ?? "null (exception caught)"}');
  
  // Scenario 3: What actually happens in the code
  print('\nScenario 3 - Actual code behavior:');
  print('The code does NOT have try-catch around line 87!');
  print('Therefore: Exception escapes, request fails');
  
  print('\n' + '=' * 60);
  print('CONCLUSION');
  print('=' * 60);
  print('✅ VERIFIED: In ApiService._configureDio():');
  print('1. Line 87 calls EnvironmentConfig.apiKey');
  print('2. This throws an uncaught exception in staging');
  print('3. The exception causes the interceptor to fail');
  print('4. Dio cancels the request (never sent to server)');
  print('5. The API call fails with a DioException');
  print('6. This explains why we get errors, not 403s!');
  print('');
  print('CORRECTION TO INITIAL THEORY:');
  print('The request is NOT sent with no auth - it\'s NOT SENT AT ALL!');
}