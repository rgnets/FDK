import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rgnets_fdk/features/speed_test/data/services/iperf3_service.dart';
import 'package:rgnets_fdk/features/speed_test/data/services/speed_test_debug_logger.dart';

/// Calculates gateway as network_address + 1 (e.g., 192.168.1.0 + 1 = 192.168.1.1)
class NetworkGatewayService {
  final NetworkInfo _networkInfo = NetworkInfo();
  final Iperf3Service _iperf3Service = Iperf3Service();

  /// Get the WiFi gateway address (network address + 1)
  ///
  /// For iOS: Uses native getDefaultGateway() method (no permission needed)
  /// For Android: Calculates from IP & subnet mask
  Future<String?> getWifiGateway({String? runId}) async {
    try {
      SpeedTestDebugLogger.debug('gateway_start', {
        if (runId != null) 'run_id': runId,
        'platform': Platform.operatingSystem,
      });
      // For iOS, use native gateway detection (more reliable)
      if (Platform.isIOS) {
        SpeedTestDebugLogger.debug('gateway_request', {
          if (runId != null) 'run_id': runId,
          'strategy': 'native_ios',
        });
        final gateway = await _iperf3Service.getDefaultGateway(runId: runId);

        if (gateway != null && gateway.isNotEmpty) {
          SpeedTestDebugLogger.debug('gateway_result', {
            if (runId != null) 'run_id': runId,
            'strategy': 'native_ios',
            'gateway': gateway,
          });
          return gateway;
        } else {
          SpeedTestDebugLogger.warning('error', {
            if (runId != null) 'run_id': runId,
            'stage': 'gateway_detection',
            'strategy': 'native_ios',
            'reason': 'iOS native gateway detection failed',
          });
          return null;
        }
      }

      // For Android, calculate from WiFi IP and subnet mask
      SpeedTestDebugLogger.debug('gateway_request', {
        if (runId != null) 'run_id': runId,
        'strategy': 'android_subnet_calculation',
      });

      // Get WiFi IP address
      final wifiIP = await _networkInfo.getWifiIP();

      if (wifiIP == null || wifiIP.isEmpty) {
        SpeedTestDebugLogger.warning('error', {
          if (runId != null) 'run_id': runId,
          'stage': 'gateway_detection',
          'strategy': 'android_subnet_calculation',
          'reason': 'Unable to get WiFi IP address',
        });
        return null;
      }

      // Get subnet mask
      final subnetMask = await _networkInfo.getWifiSubmask();

      if (subnetMask == null || subnetMask.isEmpty) {
        SpeedTestDebugLogger.warning('gateway_fallback', {
          if (runId != null) 'run_id': runId,
          'reason': 'Unable to get subnet mask, using default /24',
          'wifi_ip': wifiIP,
        });
        // Default to /24 network (255.255.255.0)
        return _calculateGatewayWithDefaultMask(wifiIP);
      }

      // Calculate gateway as network_address + 1
      final gateway = _calculateGateway(wifiIP, subnetMask);

      if (gateway != null) {
        SpeedTestDebugLogger.debug('gateway_result', {
          if (runId != null) 'run_id': runId,
          'strategy': 'android_subnet_calculation',
          'wifi_ip': wifiIP,
          'subnet_mask': subnetMask,
          'gateway': gateway,
        });
      } else {
        SpeedTestDebugLogger.warning('error', {
          if (runId != null) 'run_id': runId,
          'stage': 'gateway_detection',
          'reason': 'Failed to calculate gateway',
          'wifi_ip': wifiIP,
          'subnet_mask': subnetMask,
        });
      }

      return gateway;
    } on Exception catch (e, stack) {
      SpeedTestDebugLogger.error(
        'error',
        {
          if (runId != null) 'run_id': runId,
          'stage': 'gateway_detection',
          'reason': e.toString(),
        },
        error: e,
        stackTrace: stack,
      );
      return null;
    }
  }

  /// Request location permission on iOS
  /// Returns true if permission granted
  Future<bool> _requestLocationPermission({String? runId}) async {
    if (!Platform.isIOS) return true;

    try {
      final status = await Permission.locationWhenInUse.status;
      SpeedTestDebugLogger.debug('permission_status', {
        if (runId != null) 'run_id': runId,
        'permission': 'locationWhenInUse',
        'status': status.toString(),
      });

      if (status.isGranted) {
        return true;
      }

      if (status.isPermanentlyDenied) {
        SpeedTestDebugLogger.warning('error', {
          if (runId != null) 'run_id': runId,
          'stage': 'location_permission',
          'reason': 'Location permission permanently denied',
        });
        return false;
      }

      // Request permission
      SpeedTestDebugLogger.debug('permission_request', {
        if (runId != null) 'run_id': runId,
        'permission': 'locationWhenInUse',
      });
      final result = await Permission.locationWhenInUse.request();
      SpeedTestDebugLogger.debug('permission_result', {
        if (runId != null) 'run_id': runId,
        'permission': 'locationWhenInUse',
        'status': result.toString(),
      });

      if (result.isGranted) {
        return true;
      } else if (result.isPermanentlyDenied) {
        return false;
      } else {
        return false;
      }
    } on Exception catch (e, stack) {
      SpeedTestDebugLogger.error(
        'error',
        {
          if (runId != null) 'run_id': runId,
          'stage': 'location_permission',
          'reason': e.toString(),
        },
        error: e,
        stackTrace: stack,
      );
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
      final networkParts = List<int>.generate(
        4,
        (i) => ipParts[i] & maskParts[i],
      );

      // Add 1 to get gateway
      networkParts[3] += 1;

      // Handle overflow
      if (networkParts[3] > 255) {
        return null;
      }

      return networkParts.join('.');
    } catch (e) {
      SpeedTestDebugLogger.warning('error', {
        'stage': 'gateway_calculation',
        'reason': e.toString(),
      });
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
      SpeedTestDebugLogger.warning('error', {
        'stage': 'gateway_default_mask',
        'reason': e.toString(),
      });
      return null;
    }
  }

  /// Get WiFi SSID (network name)
  /// On iOS, requires location permission
  Future<String?> getWifiSSID({String? runId}) async {
    try {
      if (Platform.isIOS) {
        final permitted = await _requestLocationPermission(runId: runId);
        if (!permitted) return null;
      }

      final ssid = await _networkInfo.getWifiName();
      return ssid?.replaceAll('"', '');
    } on Exception catch (e, stack) {
      SpeedTestDebugLogger.error(
        'error',
        {
          if (runId != null) 'run_id': runId,
          'stage': 'wifi_ssid',
          'reason': e.toString(),
        },
        error: e,
        stackTrace: stack,
      );
      return null;
    }
  }

  /// Get WiFi IP address
  /// On iOS, requires location permission
  Future<String?> getWifiIP({String? runId}) async {
    try {
      if (Platform.isIOS) {
        final permitted = await _requestLocationPermission(runId: runId);
        if (!permitted) return null;
      }

      return await _networkInfo.getWifiIP();
    } on Exception catch (e, stack) {
      SpeedTestDebugLogger.error(
        'error',
        {
          if (runId != null) 'run_id': runId,
          'stage': 'wifi_ip',
          'reason': e.toString(),
        },
        error: e,
        stackTrace: stack,
      );
      return null;
    }
  }
}
