// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'speed_test_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SpeedTestConfigImpl _$$SpeedTestConfigImplFromJson(
        Map<String, dynamic> json) =>
    _$SpeedTestConfigImpl(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      testType: json['test_type'] as String?,
      target: json['target'] as String?,
      port: (json['port'] as num?)?.toInt(),
      iperfProtocol: json['iperf_protocol'] as String?,
      minDownloadMbps: (json['min_download_mbps'] as num?)?.toDouble(),
      minUploadMbps: (json['min_upload_mbps'] as num?)?.toDouble(),
      period: (json['period'] as num?)?.toInt(),
      periodUnit: json['period_unit'] as String?,
      startsAt: json['starts_at'] == null
          ? null
          : DateTime.parse(json['starts_at'] as String),
      nextCheckAt: json['next_check_at'] == null
          ? null
          : DateTime.parse(json['next_check_at'] as String),
      lastCheckedAt: json['last_checked_at'] == null
          ? null
          : DateTime.parse(json['last_checked_at'] as String),
      passing: json['passing'] as bool? ?? false,
      lastResult: json['last_result'] as String?,
      maxFailures: (json['max_failures'] as num?)?.toInt(),
      disableUplinkOnFailure:
          json['disable_uplink_on_failure'] as bool? ?? false,
      sampleSizePct: (json['sample_size_pct'] as num?)?.toInt(),
      pskOverride: json['psk_override'] as String?,
      wlanId: (json['wlan_id'] as num?)?.toInt(),
      note: json['note'] as String?,
      scratch: json['scratch'] as String?,
      createdBy: json['created_by'] as String?,
      updatedBy: json['updated_by'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$SpeedTestConfigImplToJson(
    _$SpeedTestConfigImpl instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('name', instance.name);
  writeNotNull('test_type', instance.testType);
  writeNotNull('target', instance.target);
  writeNotNull('port', instance.port);
  writeNotNull('iperf_protocol', instance.iperfProtocol);
  writeNotNull('min_download_mbps', instance.minDownloadMbps);
  writeNotNull('min_upload_mbps', instance.minUploadMbps);
  writeNotNull('period', instance.period);
  writeNotNull('period_unit', instance.periodUnit);
  writeNotNull('starts_at', instance.startsAt?.toIso8601String());
  writeNotNull('next_check_at', instance.nextCheckAt?.toIso8601String());
  writeNotNull('last_checked_at', instance.lastCheckedAt?.toIso8601String());
  val['passing'] = instance.passing;
  writeNotNull('last_result', instance.lastResult);
  writeNotNull('max_failures', instance.maxFailures);
  val['disable_uplink_on_failure'] = instance.disableUplinkOnFailure;
  writeNotNull('sample_size_pct', instance.sampleSizePct);
  writeNotNull('psk_override', instance.pskOverride);
  writeNotNull('wlan_id', instance.wlanId);
  writeNotNull('note', instance.note);
  writeNotNull('scratch', instance.scratch);
  writeNotNull('created_by', instance.createdBy);
  writeNotNull('updated_by', instance.updatedBy);
  writeNotNull('created_at', instance.createdAt?.toIso8601String());
  writeNotNull('updated_at', instance.updatedAt?.toIso8601String());
  return val;
}
