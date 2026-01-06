import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/providers/repository_providers.dart';
import 'package:rgnets_fdk/core/services/background_refresh_service.dart';
import 'package:rgnets_fdk/core/services/mock_data_service.dart';
import 'package:rgnets_fdk/core/services/performance_monitor_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_provider.g.dart';

@riverpod
class DashboardStats extends _$DashboardStats {
  late final BackgroundRefreshService _backgroundRefreshService;
  late final PerformanceMonitorService _performanceMonitor;
  
  @override
  Future<Map<String, dynamic>> build() async {
    // Initialize services from providers
    _backgroundRefreshService = ref.watch(backgroundRefreshServiceProvider);
    _performanceMonitor = ref.watch(performanceMonitorProvider);
    final storage = ref.watch(storageServiceProvider);
    
    // Start background refresh service
    if (storage.isAuthenticated || EnvironmentConfig.isDevelopment) {
      _backgroundRefreshService.startBackgroundRefresh();
    }
    
    // Track dashboard loading performance
    return _performanceMonitor.trackFuture(
      'dashboard_stats_load',
      () async {
        // Development mode: use mock data
        if (EnvironmentConfig.isDevelopment) {
          // Simulate loading delay for realistic testing
          await Future<void>.delayed(const Duration(milliseconds: 500));
          return MockDataService().getMockDashboardStats();
        }
        
        // Staging/Production: would fetch from real API
        // For now, return mock data as fallback
        return MockDataService().getMockDashboardStats();
      },
    );
  }
  
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    
    // Manually trigger background refresh and update stats
    await _backgroundRefreshService.refreshNow();
    
    state = await AsyncValue.guard(() => _performanceMonitor.trackFuture(
      'dashboard_stats_refresh',
      () async {
        if (EnvironmentConfig.isDevelopment) {
          await Future<void>.delayed(const Duration(milliseconds: 300));
          return MockDataService().getMockDashboardStats();
        }
        return MockDataService().getMockDashboardStats();
      },
    ));
  }
  
  /// Get background refresh status streams
  Stream<RefreshStatus> get deviceRefreshStream => 
      _backgroundRefreshService.deviceRefreshStream;
      
  Stream<RefreshStatus> get roomRefreshStream => 
      _backgroundRefreshService.roomRefreshStream;
      
  /// Get performance statistics for dashboard operations
  Map<String, dynamic> getPerformanceStats() {
    final allStats = _performanceMonitor.getAllStats();
    return {
      'dashboard_load_stats': allStats['dashboard_stats_load']?.averageMs ?? 0,
      'dashboard_refresh_stats': allStats['dashboard_stats_refresh']?.averageMs ?? 0,
      'total_operations': allStats.length,
      'performance_report': _performanceMonitor.generateReport(),
    };
  }
}
