import 'package:flutter/foundation.dart';
import 'package:rgnets_fdk/core/config/app_config.dart';

/// Logger service for consistent logging throughout the app
class LoggerService {
  static const String _tag = 'RGNets-FDK';
  
  /// Log debug messages (only in debug mode)
  static void debug(String message, {String? tag}) {
    if (kDebugMode && AppConfig.enableLogging) {
      debugPrint('[$_tag${tag != null ? ':$tag' : ''}] DEBUG: $message');
    }
  }
  
  /// Log info messages
  static void info(String message, {String? tag}) {
    if (AppConfig.enableLogging) {
      debugPrint('[$_tag${tag != null ? ':$tag' : ''}] INFO: $message');
    }
  }
  
  /// Log warning messages
  static void warning(String message, {String? tag}) {
    if (AppConfig.enableLogging) {
      debugPrint('[$_tag${tag != null ? ':$tag' : ''}] WARNING: $message');
    }
  }
  
  /// Log error messages
  static void error(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    if (AppConfig.enableLogging) {
      debugPrint('[$_tag${tag != null ? ':$tag' : ''}] ERROR: $message');
      if (error != null) {
        debugPrint('[$_tag${tag != null ? ':$tag' : ''}] ERROR Details: $error');
      }
      if (stackTrace != null && kDebugMode) {
        debugPrint('[$_tag${tag != null ? ':$tag' : ''}] Stack Trace:\n$stackTrace');
      }
    }
  }
  
  /// Log API requests (only in debug mode)
  static void apiRequest(String method, String path, {Map<String, dynamic>? headers, dynamic body}) {
    if (kDebugMode && AppConfig.enableLogging) {
      debugPrint('[$_tag:API] REQUEST: $method $path');
      if (headers != null && headers.isNotEmpty) {
        debugPrint('[$_tag:API] Headers: $headers');
      }
      if (body != null) {
        debugPrint('[$_tag:API] Body: $body');
      }
    }
  }
  
  /// Log API responses (only in debug mode)
  static void apiResponse(int? statusCode, String path, {dynamic data}) {
    if (kDebugMode && AppConfig.enableLogging) {
      debugPrint('[$_tag:API] RESPONSE: ${statusCode ?? 'Unknown'} $path');
      if (data != null && kDebugMode) {
        // Truncate large responses
        final dataStr = data.toString();
        if (dataStr.length > 500) {
          debugPrint('[$_tag:API] Data: ${dataStr.substring(0, 500)}... [truncated]');
        } else {
          debugPrint('[$_tag:API] Data: $dataStr');
        }
      }
    }
  }
  
  /// Log API errors
  static void apiError(String path, Object error, {int? statusCode}) {
    if (AppConfig.enableLogging) {
      debugPrint('[$_tag:API] ERROR: ${statusCode ?? 'Unknown'} $path');
      debugPrint('[$_tag:API] Error: $error');
    }
  }
  
  /// Log room data structure for debugging device extraction
  static void logRoomDataStructure(String roomId, Map<String, dynamic> roomData) {
    if (kDebugMode && AppConfig.enableLogging) {
      debugPrint('[$_tag:ROOM] Analyzing Room $roomId Data Structure:');
      debugPrint('[$_tag:ROOM] Room Keys: ${roomData.keys.toList()}');
      
      // Check access points structure
      if (roomData.containsKey('access_points')) {
        final aps = roomData['access_points'] as List?;
        if (aps != null && aps.isNotEmpty) {
          debugPrint('[$_tag:ROOM] Access Points Count: ${aps.length}');
          if (aps.first is Map) {
            final firstAp = aps.first as Map;
            debugPrint('[$_tag:ROOM]   First AP Keys: ${firstAp.keys.toList()}');
            debugPrint('[$_tag:ROOM]   Has pms_room_id: ${firstAp.containsKey('pms_room_id')}');
            debugPrint('[$_tag:ROOM]   Has room_id: ${firstAp.containsKey('room_id')}');
            if (firstAp.containsKey('pms_room_id')) {
              debugPrint('[$_tag:ROOM]   pms_room_id value: ${firstAp['pms_room_id']}');
            }
          }
        } else {
          debugPrint('[$_tag:ROOM] No access points in response');
        }
      }
      
      // Check media converters structure
      if (roomData.containsKey('media_converters')) {
        final mcs = roomData['media_converters'] as List?;
        if (mcs != null && mcs.isNotEmpty) {
          debugPrint('[$_tag:ROOM] Media Converters Count: ${mcs.length}');
          if (mcs.first is Map) {
            final firstMc = mcs.first as Map;
            debugPrint('[$_tag:ROOM]   First MC Keys: ${firstMc.keys.toList()}');
            debugPrint('[$_tag:ROOM]   Has pms_room_id: ${firstMc.containsKey('pms_room_id')}');
            debugPrint('[$_tag:ROOM]   Has room_id: ${firstMc.containsKey('room_id')}');
            if (firstMc.containsKey('pms_room_id')) {
              debugPrint('[$_tag:ROOM]   pms_room_id value: ${firstMc['pms_room_id']}');
            }
          }
        } else {
          debugPrint('[$_tag:ROOM] No media converters in response');
        }
      }
      
      // Check infrastructure devices structure
      if (roomData.containsKey('infrastructure_devices')) {
        final devices = roomData['infrastructure_devices'] as List?;
        if (devices != null && devices.isNotEmpty) {
          debugPrint('[$_tag:ROOM] Infrastructure Devices Count: ${devices.length}');
          if (devices.first is Map) {
            final firstDevice = devices.first as Map;
            debugPrint('[$_tag:ROOM]   First Device Keys: ${firstDevice.keys.toList()}');
            debugPrint('[$_tag:ROOM]   Has pms_room_id: ${firstDevice.containsKey('pms_room_id')}');
            debugPrint('[$_tag:ROOM]   Has room_id: ${firstDevice.containsKey('room_id')}');
            if (firstDevice.containsKey('pms_room_id')) {
              debugPrint('[$_tag:ROOM]   pms_room_id value: ${firstDevice['pms_room_id']}');
            }
          }
        } else {
          debugPrint('[$_tag:ROOM] No infrastructure devices in response');
        }
      }
    }
  }
  
  /// Log device extraction results
  static void logDeviceExtraction(String roomId, List<String> extractedIds, {int? totalInResponse}) {
    if (AppConfig.enableLogging) {
      debugPrint('[$_tag:EXTRACT] Device Extraction for Room $roomId:');
      debugPrint('[$_tag:EXTRACT]   Extracted ${extractedIds.length} device IDs');
      if (totalInResponse != null) {
        debugPrint('[$_tag:EXTRACT]   Total devices in API response: $totalInResponse');
        if (totalInResponse > extractedIds.length) {
          debugPrint('[$_tag:EXTRACT]   ⚠️ Filtered out ${totalInResponse - extractedIds.length} devices');
        }
      }
      if (extractedIds.isNotEmpty && kDebugMode) {
        debugPrint('[$_tag:EXTRACT]   Device IDs: ${extractedIds.take(5).toList()}${extractedIds.length > 5 ? '... and ${extractedIds.length - 5} more' : ''}');
      }
    }
  }
}