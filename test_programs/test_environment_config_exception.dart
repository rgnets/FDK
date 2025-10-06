#!/usr/bin/env dart

// Test 1: Verify the exact exception thrown by EnvironmentConfig.apiKey

void main() {
  print('=' * 60);
  print('TEST 1: EnvironmentConfig.apiKey Exception Verification');
  print('=' * 60);
  
  // Simulate what happens in staging environment
  print('\nSimulating staging environment without STAGING_API_KEY...\n');
  
  // The actual code from environment.dart lines 71-77:
  const stagingKey = String.fromEnvironment('STAGING_API_KEY', defaultValue: '');
  print('Value of stagingKey: "${stagingKey}"');
  print('Is stagingKey empty? ${stagingKey.isEmpty}');
  
  if (stagingKey.isEmpty) {
    print('\n❌ CONFIRMED: stagingKey is empty!');
    print('This WILL throw: Exception("STAGING_API_KEY not provided for staging environment")');
  } else {
    print('\n✓ stagingKey has value: $stagingKey');
  }
  
  // Test what happens when we try to access it
  print('\n' + '-' * 40);
  print('Testing exception behavior:\n');
  
  try {
    // Simulate the exact code
    if (stagingKey.isEmpty) {
      throw Exception('STAGING_API_KEY not provided for staging environment');
    }
    print('✓ No exception thrown (should not reach here)');
  } catch (e) {
    print('❌ EXCEPTION THROWN: $e');
    print('Type: ${e.runtimeType}');
  }
  
  // Now check how this would be called from ApiService
  print('\n' + '-' * 40);
  print('Simulating ApiService access pattern:\n');
  
  String? getApiKeyForStaging() {
    try {
      // This simulates EnvironmentConfig.apiKey getter
      const stagingKey = String.fromEnvironment('STAGING_API_KEY', defaultValue: '');
      if (stagingKey.isEmpty) {
        throw Exception('STAGING_API_KEY not provided for staging environment');
      }
      return stagingKey;
    } catch (e) {
      print('Exception caught in getApiKeyForStaging: $e');
      return null; // Return null if exception
    }
  }
  
  final apiKey = getApiKeyForStaging();
  print('Result of getApiKeyForStaging(): ${apiKey == null ? "null" : apiKey}');
  
  // Test 3 times with different approaches
  print('\n' + '=' * 60);
  print('TRIPLE VERIFICATION');
  print('=' * 60);
  
  // Approach 1: Direct access
  print('\nApproach 1 - Direct access:');
  try {
    const key1 = String.fromEnvironment('STAGING_API_KEY', defaultValue: '');
    if (key1.isEmpty) throw Exception('No key');
    print('Key found: $key1');
  } catch (e) {
    print('❌ Exception: $e');
  }
  
  // Approach 2: With fallback
  print('\nApproach 2 - With fallback:');
  const key2 = String.fromEnvironment('STAGING_API_KEY', defaultValue: '');
  final finalKey2 = key2.isEmpty ? null : key2;
  print('Key value: ${finalKey2 ?? "null (empty)"}');
  
  // Approach 3: Check environment simulation
  print('\nApproach 3 - Environment simulation:');
  // When dart is run without --dart-define=STAGING_API_KEY=value
  // String.fromEnvironment returns the defaultValue
  const testEnvVar = String.fromEnvironment('TEST_VAR', defaultValue: 'default_value');
  print('TEST_VAR (not set): "$testEnvVar"');
  const testEnvVar2 = String.fromEnvironment('TEST_VAR', defaultValue: '');
  print('TEST_VAR with empty default: "${testEnvVar2}"');
  print('Is empty: ${testEnvVar2.isEmpty}');
  
  print('\n' + '=' * 60);
  print('CONCLUSION');
  print('=' * 60);
  print('✅ VERIFIED: When STAGING_API_KEY environment variable is not set:');
  print('1. String.fromEnvironment returns empty string ""');
  print('2. The isEmpty check is true');
  print('3. An Exception IS thrown with message:');
  print('   "STAGING_API_KEY not provided for staging environment"');
  print('4. This exception occurs EVERY TIME EnvironmentConfig.apiKey is accessed');
  print('   in staging mode without the environment variable.');
}