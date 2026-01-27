// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_notices_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$aggregateHealthCountsHash() =>
    r'2b50537d386a36c95aff87d27ed85fdb371c0cb7';

/// Provider that returns health counts (sync version for UI)
/// Uses the actual notices list instead of hn_counts for accurate counts
///
/// Copied from [aggregateHealthCounts].
@ProviderFor(aggregateHealthCounts)
final aggregateHealthCountsProvider = Provider<HealthCounts>.internal(
  aggregateHealthCounts,
  name: r'aggregateHealthCountsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$aggregateHealthCountsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AggregateHealthCountsRef = ProviderRef<HealthCounts>;
String _$criticalIssueCountHash() =>
    r'4932300bb1c0c4ebff301cd6f4dd3707bfb042cb';

/// Provider that returns the count of critical issues (fatal + critical)
///
/// Copied from [criticalIssueCount].
@ProviderFor(criticalIssueCount)
final criticalIssueCountProvider = Provider<int>.internal(
  criticalIssueCount,
  name: r'criticalIssueCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$criticalIssueCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CriticalIssueCountRef = ProviderRef<int>;
String _$healthNoticesListHash() => r'57d5737283a3e099d3471058cdfbd4417f6e5992';

/// Provider that returns health notices list (sync version for UI)
///
/// Copied from [healthNoticesList].
@ProviderFor(healthNoticesList)
final healthNoticesListProvider = Provider<List<HealthNotice>>.internal(
  healthNoticesList,
  name: r'healthNoticesListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$healthNoticesListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef HealthNoticesListRef = ProviderRef<List<HealthNotice>>;
String _$filteredHealthNoticesHash() =>
    r'29bda8b2b38389d165906cd56f3dd4a7f16dc7d9';

/// Provider for filtered and sorted health notices
///
/// Copied from [filteredHealthNotices].
@ProviderFor(filteredHealthNotices)
final filteredHealthNoticesProvider = Provider<List<HealthNotice>>.internal(
  filteredHealthNotices,
  name: r'filteredHealthNoticesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredHealthNoticesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FilteredHealthNoticesRef = ProviderRef<List<HealthNotice>>;
String _$aggregateHealthCountsNotifierHash() =>
    r'846525b9a40c26861f9caa3e7f9d48e0a0f71f9c';

/// Provider that aggregates health counts from cached device data
/// This uses device data that's already received via WebSocket
///
/// Copied from [AggregateHealthCountsNotifier].
@ProviderFor(AggregateHealthCountsNotifier)
final aggregateHealthCountsNotifierProvider =
    AsyncNotifierProvider<AggregateHealthCountsNotifier, HealthCounts>.internal(
  AggregateHealthCountsNotifier.new,
  name: r'aggregateHealthCountsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$aggregateHealthCountsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AggregateHealthCountsNotifier = AsyncNotifier<HealthCounts>;
String _$healthNoticesNotifierHash() =>
<<<<<<< HEAD
    r'249e101081f539d2eceef8523c67a68998788c67';
=======
    r'ff0e1e399bb3a0c928b3639131f1b83dc6d53a5e';
>>>>>>> 3bdf0aa (Uplink added)

/// Provider that extracts health notices from cached device data
///
/// Copied from [HealthNoticesNotifier].
@ProviderFor(HealthNoticesNotifier)
final healthNoticesNotifierProvider =
    AsyncNotifierProvider<HealthNoticesNotifier, List<HealthNotice>>.internal(
  HealthNoticesNotifier.new,
  name: r'healthNoticesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$healthNoticesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HealthNoticesNotifier = AsyncNotifier<List<HealthNotice>>;
String _$healthNoticeFilterStateHash() =>
    r'8bd5625c9d029dc55d9f8a070d0e55bba1a65e38';

/// Provider for filter state
///
/// Copied from [HealthNoticeFilterState].
@ProviderFor(HealthNoticeFilterState)
final healthNoticeFilterStateProvider =
    NotifierProvider<HealthNoticeFilterState, HealthNoticeFilter>.internal(
  HealthNoticeFilterState.new,
  name: r'healthNoticeFilterStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$healthNoticeFilterStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HealthNoticeFilterState = Notifier<HealthNoticeFilter>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
