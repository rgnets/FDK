import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/providers/websocket_providers.dart';
import 'package:rgnets_fdk/core/providers/websocket_sync_providers.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/features/compliance/domain/mappers/compliance_failure_to_health_notice.dart';
import 'package:rgnets_fdk/features/compliance/presentation/providers/compliance_failures_aggregate_provider.dart';
import 'package:rgnets_fdk/features/devices/data/models/device_model_sealed.dart';
import 'package:rgnets_fdk/features/issues/data/datasources/health_notices_remote_data_source.dart';
import 'package:rgnets_fdk/features/issues/data/models/health_notice_model.dart';
import 'package:rgnets_fdk/features/issues/domain/entities/health_counts.dart';
import 'package:rgnets_fdk/features/issues/domain/entities/health_notice.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'health_notices_provider.g.dart';

/// Data source for fetching health notices directly from the rxg's
/// `/api/health_notices` table via WebSocket. Created on first read; the
/// `WebSocketService` it depends on is a singleton, so no dispose is needed
/// (the data source's `dispose` is a no-op).
final healthNoticesRemoteDataSourceProvider =
    Provider<HealthNoticesRemoteDataSource>((ref) {
  return HealthNoticesRemoteDataSource(
    socketService: ref.watch(webSocketServiceProvider),
  );
});

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

/// Tracks WS connection state so a rebuild fires the moment WS comes up.
/// Without this, `HealthNoticesRemoteDataSource.fetchSummary` early-returns
/// empty on first build (before WS handshakes), and the alerts view stays
/// stale until something else triggers a rebuild.
void _watchWebSocketConnection(Ref ref) {
  ref.watch(webSocketConnectionStateProvider);
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
    final devices = cacheIntegration.getAllCachedDeviceModels();

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

/// Provider that returns the total notice count regardless of severity.
/// Drives the secondary (blue) badge on the Alerts tab when no critical
/// notices are present — keeps the bottom-nav count consistent with the
/// "Health Notices (N)" header on the alerts screen.
@Riverpod(keepAlive: true)
int totalIssueCount(TotalIssueCountRef ref) {
  return ref.watch(healthNoticesListProvider).length;
}

/// Provider that extracts health notices from cached device data
@Riverpod(keepAlive: true)
class HealthNoticesNotifier extends _$HealthNoticesNotifier {
  @override
  Future<List<HealthNotice>> build() async {
    // Three refresh signals:
    //   - Device cache updates: catches the snapshot arrival after WS
    //     connect (otherwise the view stays blank for ~5s until the next
    //     rebuild trigger fires) and picks up `device.healthNotices` on
    //     legacy rxgs (<16.621). Each rebuild is bounded by the in-flight
    //     memoization on `fetchSummary` and the cached compliance lookups,
    //     so even on 767-device sites the cascade no longer triggers the
    //     rxg's rate limiter.
    //   - WS connection state: fetchSummary needs WS up; rebuild when it
    //     transitions so the summary retry fires the moment WS is alive.
    //   - Compliance feed changes: synthetic notices change as failures
    //     come and go (watched via complianceFailuresAggregateProvider).
    _watchDeviceCacheUpdates(ref);
    _watchWebSocketConnection(ref);
    final cacheIntegration = ref.watch(webSocketCacheIntegrationProvider);

    // Get cached devices with health notice data from in-memory WebSocket cache
    final devices = cacheIntegration.getAllCachedDeviceModels();

    LoggerService.debug(
      'HEALTH: Found ${devices.length} cached devices',
      tag: 'HealthNotices',
    );

    // Collect all health notices from devices (server-side only)
    final notices = <HealthNotice>[];
    var devicesWithNotices = 0;

    final seenIds = <int>{};
    for (final device in devices) {
      final deviceNotices = device.healthNotices;
      if (deviceNotices != null && deviceNotices.isNotEmpty) {
        devicesWithNotices++;
        for (final notice in deviceNotices) {
          if (!seenIds.add(notice.id)) continue;
          notices.add(notice.toEntity().copyWith(
            deviceId: device.id,
            deviceName: device.name,
            deviceType: device.deviceType,
          ));
        }
      }
    }

    // Pull from the dedicated `health_notices` table too. After rxg commit
    // 44e3bedd2e (May 2026) stripped `:health_notices` from the device
    // serializers, device payloads stopped carrying notices — but the
    // notices themselves still live in the table (e.g. `access_point_offline`
    // CRITICAL notices). Reading the table directly keeps the alerts view
    // populated regardless of which device-controller serializer happens to
    // include the association.
    final remote = ref.watch(healthNoticesRemoteDataSourceProvider);
    var tableNoticesAdded = 0;
    try {
      final summary = await remote.fetchSummary();
      LoggerService.debug(
        'health_notices table summary returned ${summary.notices.length} '
        'entries: ${summary.notices.map((n) => "id=${n.id} sev=${n.severity} "
            "name=${n.name} msg=${n.shortMessage}").join(" | ")}',
        tag: 'HealthNotices',
      );
      for (final entity in summary.toNoticeEntities()) {
        if (!seenIds.add(entity.id)) continue;
        notices.add(entity);
        tableNoticesAdded++;
      }
    } on Exception catch (e) {
      LoggerService.warning(
        'health_notices table fetch failed: $e',
        tag: 'HealthNotices',
      );
    }

    // Compliance failures land in the alerts view as per-AP synthetic
    // notices so users see specific reasons ("missing installation images",
    // "speed test failed") instead of an empty list. The same failures also
    // feed the room readiness Issues via complianceFailuresAggregateProvider —
    // both surfaces share one source. Synthetic ids are negative (see the
    // mapper), so they can't collide with rxg-side ids in `seenIds`.
    final complianceFailures = ref.watch(complianceFailuresAggregateProvider);
    notices.addAll(complianceFailuresToHealthNotices(complianceFailures));

    LoggerService.debug(
      'HEALTH: Extracted ${notices.length} notices '
      '($devicesWithNotices devices with notices, '
      '$tableNoticesAdded from health_notices table, '
      '${complianceFailures.length} compliance failures)',
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
