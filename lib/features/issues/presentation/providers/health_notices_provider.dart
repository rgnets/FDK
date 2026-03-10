import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/providers/websocket_sync_providers.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/features/issues/domain/entities/health_counts.dart';
import 'package:rgnets_fdk/features/issues/domain/entities/health_notice.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'health_notices_provider.g.dart';

/// Device type filter options for health notices
enum DeviceTypeFilter {
  all,
  accessPoint,
  networkSwitch, // 'switch' is a reserved keyword
  ont;

  String? get filterValue => switch (this) {
        DeviceTypeFilter.all => null,
        DeviceTypeFilter.accessPoint => 'access_point',
        DeviceTypeFilter.networkSwitch => 'switch',
        DeviceTypeFilter.ont => 'ont',
      };

  String get displayLabel => switch (this) {
        DeviceTypeFilter.all => 'All',
        DeviceTypeFilter.accessPoint => 'AP',
        DeviceTypeFilter.networkSwitch => 'Switch',
        DeviceTypeFilter.ont => 'ONT',
      };
}

void _watchDeviceCacheUpdates(Ref ref) {
  ref.watch(webSocketDeviceLastUpdateProvider);
}

/// Provider that aggregates health counts from cached device data
/// This uses device data that's already received via WebSocket
@Riverpod(keepAlive: true)
class AggregateHealthCountsNotifier extends _$AggregateHealthCountsNotifier {
  @override
  Future<HealthCounts> build() async {
    _watchDeviceCacheUpdates(ref);
    final cacheIntegration = ref.watch(webSocketCacheIntegrationProvider);

    // Get cached devices with health notice data from in-memory WebSocket cache
    final devices = cacheIntegration.getAllCachedDevices();

    // Aggregate health counts from all devices
    var totalFatal = 0;
    var totalCritical = 0;
    var totalWarning = 0;
    var totalNotice = 0;
    var devicesWithHnCounts = 0;

    for (final device in devices) {
      final counts = device.hnCounts;
      if (counts != null) {
        devicesWithHnCounts++;
        totalFatal += counts.fatal;
        totalCritical += counts.critical;
        totalWarning += counts.warning;
        totalNotice += counts.notice;
      }
    }

    final total = totalFatal + totalCritical + totalWarning + totalNotice;

    LoggerService.debug(
      'AggregateHealthCountsNotifier: $devicesWithHnCounts/${devices.length} devices, counts: total=$total, fatal=$totalFatal, critical=$totalCritical, warning=$totalWarning, notice=$totalNotice',
      tag: 'HealthNotices',
    );

    return HealthCounts(
      total: total,
      fatal: totalFatal,
      critical: totalCritical,
      warning: totalWarning,
      notice: totalNotice,
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

/// Provider that returns health counts (sync version for UI)
/// Uses the actual notices list instead of hn_counts for accurate counts
@Riverpod(keepAlive: true)
HealthCounts aggregateHealthCounts(AggregateHealthCountsRef ref) {
  final notices = ref.watch(healthNoticesListProvider);

  return HealthCounts(
    total: notices.length,
    fatal: notices.countBySeverity(HealthNoticeSeverity.fatal),
    critical: notices.countBySeverity(HealthNoticeSeverity.critical),
    warning: notices.countBySeverity(HealthNoticeSeverity.warning),
    notice: notices.countBySeverity(HealthNoticeSeverity.notice),
  );
}

/// Provider that returns the count of critical issues (fatal + critical)
@Riverpod(keepAlive: true)
int criticalIssueCount(CriticalIssueCountRef ref) {
  final notices = ref.watch(healthNoticesListProvider);
  return notices.criticalCount;
}

/// Provider that extracts health notices from cached device data
@Riverpod(keepAlive: true)
class HealthNoticesNotifier extends _$HealthNoticesNotifier {
  @override
  Future<List<HealthNotice>> build() async {
    _watchDeviceCacheUpdates(ref);
    final cacheIntegration = ref.watch(webSocketCacheIntegrationProvider);

    // Get cached devices with health notice data from in-memory WebSocket cache
    final devices = cacheIntegration.getAllCachedDevices();

    LoggerService.debug(
      'HEALTH: Found ${devices.length} cached devices',
      tag: 'HealthNotices',
    );

    // Collect all health notices from devices (server-side only)
    final notices = <HealthNotice>[];
    var devicesWithNotices = 0;

    for (final device in devices) {
      final deviceNotices = device.healthNotices;
      if (deviceNotices != null && deviceNotices.isNotEmpty) {
        devicesWithNotices++;
        for (final notice in deviceNotices) {
          notices.add(notice.copyWith(
            deviceId: device.id,
            deviceName: device.name,
            deviceType: device.type,
          ));
        }
      }
    }

    LoggerService.debug(
      'HEALTH: Extracted ${notices.length} total notices from $devicesWithNotices devices with notices',
      tag: 'HealthNotices',
    );

    // Sort by severity (highest first), then by creation time (newest first)
    notices.sort((a, b) {
      final severityCompare = b.severity.weight.compareTo(a.severity.weight);
      if (severityCompare != 0) {
        return severityCompare;
      }
      return b.createdAt.compareTo(a.createdAt);
    });

    return notices;
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

/// Provider that returns health notices list (sync version for UI)
@Riverpod(keepAlive: true)
List<HealthNotice> healthNoticesList(HealthNoticesListRef ref) {
  final noticesAsync = ref.watch(healthNoticesNotifierProvider);

  return noticesAsync.when(
    data: (notices) => notices,
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Filter for health notices
class HealthNoticeFilter {
  const HealthNoticeFilter({
    this.severities = const {},
    this.deviceType = DeviceTypeFilter.all,
    this.searchQuery = '',
    this.sortBy = HealthNoticeSortBy.severity,
  });

  final Set<HealthNoticeSeverity> severities;
  final DeviceTypeFilter deviceType;
  final String searchQuery;
  final HealthNoticeSortBy sortBy;

  HealthNoticeFilter copyWith({
    Set<HealthNoticeSeverity>? severities,
    DeviceTypeFilter? deviceType,
    String? searchQuery,
    HealthNoticeSortBy? sortBy,
  }) {
    return HealthNoticeFilter(
      severities: severities ?? this.severities,
      deviceType: deviceType ?? this.deviceType,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

enum HealthNoticeSortBy {
  severity,
  time,
  device,
}

/// Provider for filter state
@Riverpod(keepAlive: true)
class HealthNoticeFilterState extends _$HealthNoticeFilterState {
  @override
  HealthNoticeFilter build() {
    return const HealthNoticeFilter();
  }

  void updateSeverities(Set<HealthNoticeSeverity> severities) {
    state = state.copyWith(severities: severities);
  }

  void toggleSeverity(HealthNoticeSeverity severity) {
    final newSeverities = Set<HealthNoticeSeverity>.from(state.severities);
    if (newSeverities.contains(severity)) {
      newSeverities.remove(severity);
    } else {
      newSeverities.add(severity);
    }
    state = state.copyWith(severities: newSeverities);
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void updateSortBy(HealthNoticeSortBy sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void setDeviceType(DeviceTypeFilter deviceType) {
    state = state.copyWith(deviceType: deviceType);
  }

  void clearFilters() {
    state = const HealthNoticeFilter();
  }
}

/// Provider for filtered and sorted health notices
@Riverpod(keepAlive: true)
List<HealthNotice> filteredHealthNotices(FilteredHealthNoticesRef ref) {
  final notices = ref.watch(healthNoticesListProvider);
  final filter = ref.watch(healthNoticeFilterStateProvider);

  final filtered = notices.where((n) {
    // Filter by severity if any are selected
    if (filter.severities.isNotEmpty && !filter.severities.contains(n.severity)) {
      return false;
    }

    // Filter by device type if not "all"
    if (filter.deviceType != DeviceTypeFilter.all) {
      final filterValue = filter.deviceType.filterValue;
      if (n.deviceType != filterValue) {
        return false;
      }
    }

    // Filter by search query
    if (filter.searchQuery.isNotEmpty) {
      final query = filter.searchQuery.toLowerCase();
      if (!n.shortMessage.toLowerCase().contains(query) &&
          !n.name.toLowerCase().contains(query) &&
          !(n.deviceName?.toLowerCase().contains(query) ?? false)) {
        return false;
      }
    }

    return true;
  }).toList();

  // Sort based on selected sort option
  switch (filter.sortBy) {
    case HealthNoticeSortBy.severity:
      filtered.sort((a, b) {
        final severityCompare = b.severity.weight.compareTo(a.severity.weight);
        if (severityCompare != 0) {
          return severityCompare;
        }
        return b.createdAt.compareTo(a.createdAt);
      });
    case HealthNoticeSortBy.time:
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    case HealthNoticeSortBy.device:
      filtered.sort((a, b) {
        final deviceCompare = (a.deviceName ?? '').compareTo(b.deviceName ?? '');
        if (deviceCompare != 0) {
          return deviceCompare;
        }
        return b.severity.weight.compareTo(a.severity.weight);
      });
  }

  return filtered;
}
