/// Configuration for mock network data generation
/// Centralizes all network-related constants used in mock data
class MockNetworkConfig {
  // Private constructor to prevent instantiation
  MockNetworkConfig._();
  
  /// Core infrastructure IP address for primary distribution switch
  static const String coreDistributionSwitchIp = '10.0.0.10';
  
  /// Base subnet for VLAN IP generation (10.x.x.x range)
  static const int baseSubnet = 10;
  
  /// Management VLAN subnet offset
  static const int mgmtVlanOffset = 0;
  
  /// Guest access IP range
  static const String guestIpPrefix = '192.168.100';
  
  /// IoT device IP range  
  static const String iotIpPrefix = '192.168.200';
  
  /// Default gateway suffixes for various VLANs
  static const Map<String, String> vlanGateways = {
    'MGMT-VLAN': '10.0.0.1',
    'CORP-DATA': '10.1.0.1',
    'CORP-VOICE': '10.2.0.1',
    'GUEST-ACCESS': '192.168.100.1',
    'IOT-DEVICES': '192.168.200.1',
  };
  
  /// Generate IP address for a specific VLAN and host
  static String generateIpForVlan(int vlanId, int hostId) {
    // Different VLANs use different subnets
    final subnet = baseSubnet + vlanId;
    final octet3 = (hostId ~/ 255) % 255;
    final octet4 = (hostId % 255) + 1;
    return '$baseSubnet.$subnet.$octet3.$octet4';
  }
  
  /// Get default gateway for a VLAN
  static String getGatewayForVlan(String vlanName) {
    return vlanGateways[vlanName] ?? '10.0.0.1';
  }
}