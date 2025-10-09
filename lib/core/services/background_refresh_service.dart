import 'dart:async';

import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/services/notification_generation_service.dart';
import 'package:rgnets_fdk/features/devices/data/datasources/device_data_source.dart';
import 'package:rgnets_fdk/features/devices/data/datasources/device_local_data_source.dart';
import 'package:rgnets_fdk/features/devices/data/models/device_model.dart';
import 'package:rgnets_fdk/features/rooms/domain/repositories/room_repository.dart';

/// Service for background data refresh
/// Periodically fetches fresh data without blocking the UI
class BackgroundRefreshService {
  BackgroundRefreshService({
    required this.deviceRemoteDataSource,
    required this.deviceLocalDataSource,
    required this.roomRepository,
    required this.notificationGenerationService,
  });

  static final _logger = Logger();

  final DeviceDataSource deviceRemoteDataSource;
  final DeviceLocalDataSource deviceLocalDataSource;
  final RoomRepository roomRepository;
  final NotificationGenerationService notificationGenerationService;

  Timer? _refreshTimer;
  bool _isRefreshing = false;
  
  // Stream controllers for refresh status
  final _deviceRefreshController = StreamController<RefreshStatus>.broadcast();
  final _roomRefreshController = StreamController<RefreshStatus>.broadcast();
  
  Stream<RefreshStatus> get deviceRefreshStream => _deviceRefreshController.stream;
  Stream<RefreshStatus> get roomRefreshStream => _roomRefreshController.stream;
  
  // Configuration
  static const Duration _refreshInterval = Duration(minutes: 2);
  static const Duration _initialDelay = Duration(seconds: 10);
  
  /// Start background refresh
  void startBackgroundRefresh() {
    _logger.d('BackgroundRefreshService: Starting background refresh');
    
    // Schedule initial refresh after a delay
    Future<void>.delayed(_initialDelay, _performRefresh);
    
    // Setup periodic refresh
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      _performRefresh();
    });
  }
  
  /// Stop background refresh
  void stopBackgroundRefresh() {
    _logger.d('BackgroundRefreshService: Stopping background refresh');
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }
  
  /// Perform refresh in background
  Future<void> _performRefresh() async {
    if (_isRefreshing) {
      _logger.d('BackgroundRefreshService: Refresh already in progress, skipping');
      return;
    }
    
    _isRefreshing = true;
    _logger.d('BackgroundRefreshService: Starting background refresh');
    
    // Refresh devices and rooms in parallel
    await Future.wait([
      _refreshDevices(),
      _refreshRooms(),
    ], eagerError: false);
    
    _isRefreshing = false;
    _logger.d('BackgroundRefreshService: Background refresh completed');
  }
  
  /// Refresh devices in background
  Future<void> _refreshDevices() async {
    try {
      _deviceRefreshController.add(RefreshStatus.refreshing);
      
      // Fetch devices in background using compute for heavy processing
      final stopwatch = Stopwatch()..start();
      
      // Fetch new data
      final devices = await deviceRemoteDataSource.getDevices();
      
      // Cache the new data
      await deviceLocalDataSource.cacheDevices(devices);
      
      // Convert DeviceModel to Device entities and generate notifications
      final deviceEntities = devices.map((deviceModel) => deviceModel.toEntity()).toList();
      final newNotifications = notificationGenerationService.generateFromDevices(deviceEntities);
      if (newNotifications.isNotEmpty) {
        _logger.i('BackgroundRefreshService: Generated ${newNotifications.length} notifications from device status');
      }
      
      stopwatch.stop();
      _logger.d('BackgroundRefreshService: Devices refreshed in ${stopwatch.elapsedMilliseconds}ms');
      
      _deviceRefreshController.add(RefreshStatus.success(
        itemCount: devices.length,
        duration: stopwatch.elapsed,
      ));
    } on Exception catch (e) {
      _logger.e('BackgroundRefreshService: Error refreshing devices: $e');
      _deviceRefreshController.add(RefreshStatus.error(e.toString()));
    }
  }
  
  /// Refresh rooms in background
  Future<void> _refreshRooms() async {
    try {
      _roomRefreshController.add(RefreshStatus.refreshing);
      
      final stopwatch = Stopwatch()..start();
      
      // Fetch new data
      final roomsResult = await roomRepository.getRooms();
      
      stopwatch.stop();
      
      roomsResult.fold(
        (failure) {
          _logger.e('BackgroundRefreshService: Error refreshing rooms: ${failure.message}');
          _roomRefreshController.add(RefreshStatus.error(failure.message));
        },
        (rooms) {
          _logger.d('BackgroundRefreshService: Rooms refreshed in ${stopwatch.elapsedMilliseconds}ms');
          _roomRefreshController.add(RefreshStatus.success(
            itemCount: rooms.length,
            duration: stopwatch.elapsed,
          ));
        },
      );
    } on Exception catch (e) {
      _logger.e('BackgroundRefreshService: Unexpected error refreshing rooms: $e');
      _roomRefreshController.add(RefreshStatus.error(e.toString()));
    }
  }
  
  /// Manually trigger refresh
  Future<void> refreshNow() async {
    _logger.d('BackgroundRefreshService: Manual refresh triggered');
    await _performRefresh();
  }
  
  /// Dispose resources
  void dispose() {
    stopBackgroundRefresh();
    _deviceRefreshController.close();
    _roomRefreshController.close();
  }
}

/// Status of background refresh
class RefreshStatus {
  
  factory RefreshStatus.success({required int itemCount, required Duration duration}) {
    return RefreshStatus._(
      status: RefreshStatusType.success,
      itemCount: itemCount,
      duration: duration,
    );
  }
  
  factory RefreshStatus.error(String error) {
    return RefreshStatus._(
      status: RefreshStatusType.error,
      error: error,
    );
  }
  const RefreshStatus._({
    required this.status,
    this.itemCount,
    this.duration,
    this.error,
  });
  
  final RefreshStatusType status;
  final int? itemCount;
  final Duration? duration;
  final String? error;
  
  static const RefreshStatus idle = RefreshStatus._(status: RefreshStatusType.idle);
  static const RefreshStatus refreshing = RefreshStatus._(status: RefreshStatusType.refreshing);
  
  bool get isRefreshing => status == RefreshStatusType.refreshing;
  bool get isSuccess => status == RefreshStatusType.success;
  bool get isError => status == RefreshStatusType.error;
}

enum RefreshStatusType { idle, refreshing, success, error }
