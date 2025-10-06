/// Test credentials for development and testing
/// These are READ-ONLY credentials for the test rXg system
/// 
/// IMPORTANT: These credentials are for testing only and have read-only access
/// Never use production credentials in test files
class TestCredentials {
  // This QR code is stored in assets/interurban fetoolreadonly flutter test suite json.png
  // It contains the following JSON structure when scanned:
  static const Map<String, String> rxgTestCredentials = {
    'fqdn': 'vgw1-01.dal-interurban.mdu.attwifi.com',
    'login': 'fetoolreadonly',
    'apiKey': 'xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r', // Actual API key from QR code
  };
  
  /// QR code data format expected from the scanner
  static const String qrCodeJson = '''
{
  "fqdn": "vgw1-01.dal-interurban.mdu.attwifi.com",
  "login": "fetoolreadonly",
  "api_key": "xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r"
}
''';

  /// Test API base URL constructed from credentials
  static String get testApiUrl => 'https://${rxgTestCredentials['fqdn']}/api';
  
  /// Path to the QR code image for testing scanner functionality
  static const String qrCodeImagePath = 'assets/interurban fetoolreadonly flutter test suite json.png';
  
  /// Use these credentials for testing API connections
  static Map<String, String> getHeaders() {
    return {
      'X-API-Login': rxgTestCredentials['login']!,
      'X-API-Key': rxgTestCredentials['apiKey']!,
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }
}