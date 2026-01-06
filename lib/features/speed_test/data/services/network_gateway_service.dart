import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/features/speed_test/data/services/iperf3_service.dart';

/// Calculates gateway as network_address + 1 (e.g., 192.168.1.0 + 1 = 192.168.1.1)
class NetworkGatewayService {
  final NetworkInfo _networkInfo = NetworkInfo();
  final Iperf3Service _iperf3Service = Iperf3Service();

  /// Get the WiFi gateway address (network address + 1)
  ///
  /// For iOS: Uses native getDefaultGateway() method (no permission needed)
  /// For Android: Calculates from IP & subnet mask
  Future<String?> getWifiGateway() async {
    try {
      // For iOS, use native gateway detection (more reliable)
      if (Platform.isIOS) {
        LoggerService.info('Using native iOS gateway detection',
            tag: 'NetworkGatewayService');
        final gateway = await _iperf3Service.getDefaultGateway();

        if (gateway != null && gateway.isNotEmpty) {
          LoggerService.info('iOS native gateway: $gateway',
              tag: 'NetworkGatewayService');
          return gateway;
        } else {
          LoggerService.warning('iOS native gateway detection failed',
              tag: 'NetworkGatewayService');
          return null;
        }
      }

      // For Android, calculate from WiFi IP and subnet mask
      LoggerService.info('Using Android subnet mask calculation',
          tag: 'NetworkGatewayService');

      // Get WiFi IP address
      final wifiIP = await _networkInfo.getWifiIP();

      if (wifiIP == null || wifiIP.isEmpty) {
        LoggerService.warning('Unable to get WiFi IP address',
            tag: 'NetworkGatewayService');
        return null;
      }

      LoggerService.info('WiFi IP address: $wifiIP',
          tag: 'NetworkGatewayService');

      // Get subnet mask
      final subnetMask = await _networkInfo.getWifiSubmask();

      if (subnetMask == null || subnetMask.isEmpty) {
        LoggerService.warning('Unable to get subnet mask, using default /24',
            tag: 'NetworkGatewayService');
        // Default to /24 network (255.255.255.0)
        return _calculateGatewayWithDefaultMask(wifiIP);
      }

      LoggerService.info('Subnet mask: $subnetMask',
          tag: 'NetworkGatewayService');

      // Calculate gateway as network_address + 1
      final gateway = _calculateGateway(wifiIP, subnetMask);

      if (gateway != null) {
        LoggerService.info('Calculated gateway: $gateway',
            tag: 'NetworkGatewayService');
      } else {
        LoggerService.error('Failed to calculate gateway',
            tag: 'NetworkGatewayService');
      }

      return gateway;
    } catch (e) {
      LoggerService.error('Error getting WiFi gateway: $e',
          tag: 'NetworkGatewayService');
      return null;
    }
  }

  /// Request location permission on iOS
  /// Returns true if permission granted
  Future<bool> _requestLocationPermission() async {
    if (!Platform.isIOS) return true;

    try {
      final status = await Permission.locationWhenInUse.status;

      LoggerService.info('Current location permission status: $status',
          tag: 'NetworkGatewayService');

      if (status.isGranted) {
        LoggerService.info('Location permission already granted',
            tag: 'NetworkGatewayService');
        return true;
      }

      if (status.isPermanentlyDenied) {
        LoggerService.warning(
            'Location permission permanently denied - user must enable in Settings app',
            tag: 'NetworkGatewayService');
        return false;
      }

      if (status.isDenied) {
        LoggerService.info(
            'Location permission previously denied, requesting again...',
            tag: 'NetworkGatewayService');
      }

      // Request permission
      LoggerService.info(
          'Requesting location permission (dialog should appear now)...',
          tag: 'NetworkGatewayService');
      final result = await Permission.locationWhenInUse.request();

      LoggerService.info('Permission request result: $result',
          tag: 'NetworkGatewayService');

      if (result.isGranted) {
        LoggerService.info('Location permission granted!',
            tag: 'NetworkGatewayService');
        return true;
      } else if (result.isPermanentlyDenied) {
        LoggerService.warning('Location permission permanently denied',
            tag: 'NetworkGatewayService');
        return false;
      } else {
        LoggerService.warning('Location permission denied',
            tag: 'NetworkGatewayService');
        return false;
      }
    } catch (e) {
      LoggerService.error('Error requesting location permission: $e',
          tag: 'NetworkGatewayService');
      return false;
    }
  }

  /// Calculate gateway address: (IP & SubnetMask) + 1
  ///
  /// Example:
  /// IP: 192.168.1.100
  /// Subnet: 255.255.255.0
  /// Network: 192.168.1.0
  /// Gateway: 192.168.1.1 Network + 1
  String? _calculateGateway(String ipAddress, String subnetMask) {
    try {
      final ipParts = ipAddress.split('.').map(int.parse).toList();
      final maskParts = subnetMask.split('.').map(int.parse).toList();

      if (ipParts.length != 4 || maskParts.length != 4) {
        return null;
      }

      // Calculate network address: IP & SubnetMask
      final networkParts =
          List<int>.generate(4, (i) => ipParts[i] & maskParts[i]);

      // Add 1 to get gateway
      networkParts[3] += 1;

      // Handle overflow
      if (networkParts[3] > 255) {
        return null;
      }

      return networkParts.join('.');
    } catch (e) {
      LoggerService.error('Error calculating gateway: $e',
          tag: 'NetworkGatewayService');
      return null;
    }
  }

  /// Calculate gateway assuming /24 network (255.255.255.0)
  String? _calculateGatewayWithDefaultMask(String ipAddress) {
    try {
      final ipParts = ipAddress.split('.').map(int.parse).toList();

      if (ipParts.length != 4) {
        return null;
      }

      // Assume /24 network: keep first 3 octets, set last to 1
      return '${ipParts[0]}.${ipParts[1]}.${ipParts[2]}.1';
    } catch (e) {
      LoggerService.error('Error calculating gateway with default mask: $e',
          tag: 'NetworkGatewayService');
      return null;
    }
  }

  /// Get WiFi SSID (network name)
  /// On iOS, requires location permission
  Future<String?> getWifiSSID() async {
    try {
      if (Platform.isIOS) {
        final permitted = await _requestLocationPermission();
        if (!permitted) return null;
      }

      final ssid = await _networkInfo.getWifiName();
      return ssid?.replaceAll('"', '');
    } catch (e) {
      LoggerService.error('Error getting WiFi SSID: $e',
          tag: 'NetworkGatewayService');
      return null;
    }
  }

  /// Get WiFi IP address
  /// On iOS, requires location permission
  Future<String?> getWifiIP() async {
    try {
      if (Platform.isIOS) {
        final permitted = await _requestLocationPermission();
        if (!permitted) return null;
      }

      return await _networkInfo.getWifiIP();
    } catch (e) {
      LoggerService.error('Error getting WiFi IP: $e',
          tag: 'NetworkGatewayService');
      return null;
    }
  }
}
