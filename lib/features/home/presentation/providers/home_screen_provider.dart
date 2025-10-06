import 'package:rgnets_fdk/features/devices/presentation/providers/devices_provider.dart';
import 'package:rgnets_fdk/features/home/domain/entities/home_statistics.dart';
import 'package:rgnets_fdk/features/home/domain/usecases/calculate_home_statistics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_screen_provider.g.dart';

/// Provider for home statistics calculation use case
@riverpod
CalculateHomeStatistics calculateHomeStatistics(CalculateHomeStatisticsRef ref) {
  return CalculateHomeStatistics();
}

/// Home screen statistics provider using clean architecture
@riverpod
class HomeScreenStatistics extends _$HomeScreenStatistics {
  @override
  Future<HomeStatistics> build() async {
    final devicesAsync = ref.watch(devicesNotifierProvider);
    final calculateStatistics = ref.read(calculateHomeStatisticsProvider);
    
    return devicesAsync.when(
      data: (devices) async {
        final result = await calculateStatistics.call(
          CalculateHomeStatisticsParams(devices: devices),
        );
        
        return result.fold(
          (failure) => HomeStatistics.error(failure.message),
          (statistics) => statistics,
        );
      },
      loading: HomeStatistics.loading,
      error: (error, _) => HomeStatistics.error(error.toString()),
    );
  }
}