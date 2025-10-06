// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_screen_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$calculateHomeStatisticsHash() =>
    r'1e1250430fa80d309fe7c57b2e5bce835235c66c';

/// Provider for home statistics calculation use case
///
/// Copied from [calculateHomeStatistics].
@ProviderFor(calculateHomeStatistics)
final calculateHomeStatisticsProvider =
    AutoDisposeProvider<CalculateHomeStatistics>.internal(
  calculateHomeStatistics,
  name: r'calculateHomeStatisticsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$calculateHomeStatisticsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CalculateHomeStatisticsRef
    = AutoDisposeProviderRef<CalculateHomeStatistics>;
String _$homeScreenStatisticsHash() =>
    r'56ef79c4c6378aa8d30f1f56b6d72656c9425a53';

/// Home screen statistics provider using clean architecture
///
/// Copied from [HomeScreenStatistics].
@ProviderFor(HomeScreenStatistics)
final homeScreenStatisticsProvider = AutoDisposeAsyncNotifierProvider<
    HomeScreenStatistics, HomeStatistics>.internal(
  HomeScreenStatistics.new,
  name: r'homeScreenStatisticsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$homeScreenStatisticsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HomeScreenStatistics = AutoDisposeAsyncNotifier<HomeStatistics>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
