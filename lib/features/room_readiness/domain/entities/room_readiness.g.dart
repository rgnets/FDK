// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_readiness.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoomReadinessMetricsImpl _$$RoomReadinessMetricsImplFromJson(
        Map<String, dynamic> json) =>
    _$RoomReadinessMetricsImpl(
      roomId: (json['room_id'] as num).toInt(),
      roomName: json['room_name'] as String,
      status: $enumDecode(_$RoomStatusEnumMap, json['status']),
      totalDevices: (json['total_devices'] as num).toInt(),
      onlineDevices: (json['online_devices'] as num).toInt(),
      offlineDevices: (json['offline_devices'] as num).toInt(),
      issues: (json['issues'] as List<dynamic>)
          .map((e) => Issue.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastUpdated: DateTime.parse(json['last_updated'] as String),
    );

Map<String, dynamic> _$$RoomReadinessMetricsImplToJson(
        _$RoomReadinessMetricsImpl instance) =>
    <String, dynamic>{
      'room_id': instance.roomId,
      'room_name': instance.roomName,
      'status': _$RoomStatusEnumMap[instance.status]!,
      'total_devices': instance.totalDevices,
      'online_devices': instance.onlineDevices,
      'offline_devices': instance.offlineDevices,
      'issues': instance.issues.map((e) => e.toJson()).toList(),
      'last_updated': instance.lastUpdated.toIso8601String(),
    };

const _$RoomStatusEnumMap = {
  RoomStatus.ready: 'ready',
  RoomStatus.partial: 'partial',
  RoomStatus.down: 'down',
  RoomStatus.empty: 'empty',
};

_$RoomReadinessUpdateImpl _$$RoomReadinessUpdateImplFromJson(
        Map<String, dynamic> json) =>
    _$RoomReadinessUpdateImpl(
      roomId: (json['room_id'] as num).toInt(),
      metrics: RoomReadinessMetrics.fromJson(
          json['metrics'] as Map<String, dynamic>),
      type: $enumDecode(_$RoomReadinessUpdateTypeEnumMap, json['type']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      allMetrics: (json['all_metrics'] as List<dynamic>?)
          ?.map((e) => RoomReadinessMetrics.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$RoomReadinessUpdateImplToJson(
    _$RoomReadinessUpdateImpl instance) {
  final val = <String, dynamic>{
    'room_id': instance.roomId,
    'metrics': instance.metrics.toJson(),
    'type': _$RoomReadinessUpdateTypeEnumMap[instance.type]!,
    'timestamp': instance.timestamp.toIso8601String(),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull(
      'all_metrics', instance.allMetrics?.map((e) => e.toJson()).toList());
  return val;
}

const _$RoomReadinessUpdateTypeEnumMap = {
  RoomReadinessUpdateType.deviceStatusChanged: 'deviceStatusChanged',
  RoomReadinessUpdateType.issueDetected: 'issueDetected',
  RoomReadinessUpdateType.issueResolved: 'issueResolved',
  RoomReadinessUpdateType.fullRefresh: 'fullRefresh',
};

_$RoomReadinessSummaryImpl _$$RoomReadinessSummaryImplFromJson(
        Map<String, dynamic> json) =>
    _$RoomReadinessSummaryImpl(
      totalRooms: (json['total_rooms'] as num).toInt(),
      readyRooms: (json['ready_rooms'] as num).toInt(),
      partialRooms: (json['partial_rooms'] as num).toInt(),
      downRooms: (json['down_rooms'] as num).toInt(),
      emptyRooms: (json['empty_rooms'] as num).toInt(),
      overallReadinessPercentage:
          (json['overall_readiness_percentage'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['last_updated'] as String),
    );

Map<String, dynamic> _$$RoomReadinessSummaryImplToJson(
        _$RoomReadinessSummaryImpl instance) =>
    <String, dynamic>{
      'total_rooms': instance.totalRooms,
      'ready_rooms': instance.readyRooms,
      'partial_rooms': instance.partialRooms,
      'down_rooms': instance.downRooms,
      'empty_rooms': instance.emptyRooms,
      'overall_readiness_percentage': instance.overallReadinessPercentage,
      'last_updated': instance.lastUpdated.toIso8601String(),
    };
