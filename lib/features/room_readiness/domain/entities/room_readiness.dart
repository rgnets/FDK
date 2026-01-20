import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'issue.dart';

part 'room_readiness.freezed.dart';
part 'room_readiness.g.dart';

/// Room status based on issue presence
enum RoomStatus {
  ready, // No issues at all
  partial, // Has non-critical issues
  down, // Has critical issues or all offline
  empty // No devices configured
}

/// Complete room readiness metrics
@freezed
class RoomReadinessMetrics with _$RoomReadinessMetrics {
  const factory RoomReadinessMetrics({
    required int roomId,
    required String roomName,
    required RoomStatus status,
    required int totalDevices,
    required int onlineDevices,
    required int offlineDevices,
    required List<Issue> issues,
    required DateTime lastUpdated,
  }) = _RoomReadinessMetrics;

  const RoomReadinessMetrics._();

  factory RoomReadinessMetrics.fromJson(Map<String, dynamic> json) =>
      _$RoomReadinessMetricsFromJson(json);

  // Computed properties
  int get criticalIssueCount =>
      issues.where((i) => i.severity == IssueSeverity.critical).length;

  int get warningIssueCount =>
      issues.where((i) => i.severity == IssueSeverity.warning).length;

  int get infoIssueCount =>
      issues.where((i) => i.severity == IssueSeverity.info).length;

  int get totalIssueCount => issues.length;

  bool get isReady => status == RoomStatus.ready;

  bool get isEmpty => status == RoomStatus.empty;

  bool get hasIssues => issues.isNotEmpty;

  String get statusText {
    switch (status) {
      case RoomStatus.ready:
        return 'Ready';
      case RoomStatus.partial:
        return 'Partial';
      case RoomStatus.down:
        return 'Down';
      case RoomStatus.empty:
        return 'Empty';
    }
  }

  Color get statusColor {
    switch (status) {
      case RoomStatus.ready:
        return Colors.green;
      case RoomStatus.partial:
        return Colors.orange;
      case RoomStatus.down:
        return Colors.red;
      case RoomStatus.empty:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case RoomStatus.ready:
        return Icons.check_circle;
      case RoomStatus.partial:
        return Icons.warning;
      case RoomStatus.down:
        return Icons.cancel;
      case RoomStatus.empty:
        return Icons.settings;
    }
  }
}

/// Type of room readiness update
enum RoomReadinessUpdateType {
  deviceStatusChanged,
  issueDetected,
  issueResolved,
  fullRefresh,
}

/// Room readiness update event
@freezed
class RoomReadinessUpdate with _$RoomReadinessUpdate {
  const factory RoomReadinessUpdate({
    required int roomId,
    required RoomReadinessMetrics metrics,
    required RoomReadinessUpdateType type,
    required DateTime timestamp,
  }) = _RoomReadinessUpdate;

  const RoomReadinessUpdate._();

  factory RoomReadinessUpdate.fromJson(Map<String, dynamic> json) =>
      _$RoomReadinessUpdateFromJson(json);

  factory RoomReadinessUpdate.create({
    required int roomId,
    required RoomReadinessMetrics metrics,
    required RoomReadinessUpdateType type,
    DateTime? timestamp,
  }) {
    return RoomReadinessUpdate(
      roomId: roomId,
      metrics: metrics,
      type: type,
      timestamp: timestamp ?? DateTime.now(),
    );
  }
}

/// Summary statistics for room readiness across all rooms
@freezed
class RoomReadinessSummary with _$RoomReadinessSummary {
  const factory RoomReadinessSummary({
    required int totalRooms,
    required int readyRooms,
    required int partialRooms,
    required int downRooms,
    required int emptyRooms,
    required double overallReadinessPercentage,
    required DateTime lastUpdated,
  }) = _RoomReadinessSummary;

  const RoomReadinessSummary._();

  factory RoomReadinessSummary.fromJson(Map<String, dynamic> json) =>
      _$RoomReadinessSummaryFromJson(json);

  int get nonEmptyRooms => totalRooms - emptyRooms;

  int get notReadyRooms => partialRooms + downRooms;

  bool get allReady => readyRooms == nonEmptyRooms && nonEmptyRooms > 0;
}
