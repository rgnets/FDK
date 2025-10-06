import 'package:rgnets_fdk/core/config/app_config.dart';
import 'package:rgnets_fdk/core/mock/mock_data_generator.dart';
import 'package:rgnets_fdk/core/models/data_response.dart';
import 'package:rgnets_fdk/core/services/api_service.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/features/devices/data/models/device_model.dart';

/// Service for device-related API operations
class DeviceService {
  
  DeviceService({
    required ApiService apiService,
  }) : _apiService = apiService;
  final ApiService _apiService;
  
  /// Get all devices
  Future<DataResponse<List<DeviceModel>>> getDevices() async {
    try {
      // Check if we should use mock data
      if (AppConfig.enableMockData) {
        await Future<void>.delayed(const Duration(milliseconds: 800)); // Simulate network delay
        return DataResponse.fromMock(
          MockDataGenerator.generateDevices(count: 75),
          errorMessage: 'Mock data enabled in configuration',
        );
      }
      
      // Real API implementation - fetch all device types
      final allDevices = <DeviceModel>[];
      
      // Fetch Access Points
      try {
        final apResponse = await _apiService.get<dynamic>('${AppConfig.apiVersion}${AppConfig.accessPointsEndpoint}');
        if (apResponse.data is List) {
          for (final ap in (apResponse.data as List<dynamic>)) {
            if (ap is Map<String, dynamic>) {
              allDevices.add(DeviceModel.fromJson({
                ...ap,
                'type': 'Access Point',
              }));
            }
          }
        }
      } on Exception catch (e) {
        LoggerService.apiError('/access_points', e);
      }
      
      // Fetch ONTs (Media Converters)
      try {
        final ontResponse = await _apiService.get<dynamic>('${AppConfig.apiVersion}${AppConfig.ontsEndpoint}');
        if (ontResponse.data is List) {
          for (final ont in (ontResponse.data as List<dynamic>)) {
            if (ont is Map<String, dynamic>) {
              allDevices.add(DeviceModel.fromJson({
                ...ont,
                'type': 'ONT',
              }));
            }
          }
        }
      } on Exception catch (e) {
        LoggerService.apiError('/media_converters', e);
      }
      
      // Fetch Switches
      try {
        final switchResponse = await _apiService.get<dynamic>('${AppConfig.apiVersion}${AppConfig.switchesEndpoint}');
        if (switchResponse.data is List) {
          for (final sw in (switchResponse.data as List<dynamic>)) {
            if (sw is Map<String, dynamic>) {
              allDevices.add(DeviceModel.fromJson({
                ...sw,
                'type': 'Switch',
              }));
            }
          }
        }
      } on Exception catch (e) {
        LoggerService.apiError('/switch_devices', e);
      }
      
      // If no devices found from API, fall back to mock data
      if (allDevices.isEmpty) {
        LoggerService.warning('No devices from API, using mock data', tag: 'DeviceService');
        return DataResponse.fromMock(
          MockDataGenerator.generateDevices(count: 75),
          errorMessage: 'No devices returned from API',
        );
      }
      
      return DataResponse.fromApi(allDevices);
    } on Exception catch (e) {
      // On error, fall back to mock data
      LoggerService.error('Error fetching devices, using mock data', error: e, tag: 'DeviceService');
      return DataResponse.fromMock(
        MockDataGenerator.generateDevices(count: 75),
        errorMessage: 'API error: $e',
      );
    }
  }
  
  /// Get device by ID
  Future<DeviceModel> getDevice(String id) async {
    try {
      final response = await _apiService.get<dynamic>('/api/v1/devices/$id');
      return DeviceModel.fromJson(response.data as Map<String, dynamic>);
    } on Exception catch (e) {
      throw Exception('Failed to fetch device: $e');
    }
  }
  
  /// Reboot device
  Future<bool> rebootDevice(String id) async {
    try {
      final response = await _apiService.post<dynamic>('/api/v1/devices/$id/reboot');
      return response.statusCode == 200;
    } on Exception catch (e) {
      throw Exception('Failed to reboot device: $e');
    }
  }
  
  /// Update device configuration
  Future<DeviceModel> updateDevice(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put<dynamic>('/api/v1/devices/$id', data: data);
      return DeviceModel.fromJson(response.data as Map<String, dynamic>);
    } on Exception catch (e) {
      throw Exception('Failed to update device: $e');
    }
  }
}