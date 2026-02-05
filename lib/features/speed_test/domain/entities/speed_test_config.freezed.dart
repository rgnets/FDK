// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'speed_test_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SpeedTestConfig _$SpeedTestConfigFromJson(Map<String, dynamic> json) {
  return _SpeedTestConfig.fromJson(json);
}

/// @nodoc
mixin _$SpeedTestConfig {
  @JsonKey(fromJson: _toInt)
  int? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'test_type')
  String? get testType => throw _privateConstructorUsedError;
  String? get target => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _toInt)
  int? get port => throw _privateConstructorUsedError;
  @JsonKey(name: 'iperf_protocol')
  String? get iperfProtocol => throw _privateConstructorUsedError;
  @JsonKey(name: 'min_download_mbps', fromJson: _toDouble)
  double? get minDownloadMbps => throw _privateConstructorUsedError;
  @JsonKey(name: 'min_upload_mbps', fromJson: _toDouble)
  double? get minUploadMbps => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _toInt)
  int? get period => throw _privateConstructorUsedError;
  @JsonKey(name: 'period_unit')
  String? get periodUnit => throw _privateConstructorUsedError;
  @JsonKey(name: 'starts_at')
  DateTime? get startsAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'next_check_at')
  DateTime? get nextCheckAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_checked_at')
  DateTime? get lastCheckedAt => throw _privateConstructorUsedError;
  bool get passing => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_result')
  String? get lastResult => throw _privateConstructorUsedError;
  @JsonKey(name: 'max_failures', fromJson: _toInt)
  int? get maxFailures => throw _privateConstructorUsedError;
  @JsonKey(name: 'disable_uplink_on_failure')
  bool get disableUplinkOnFailure => throw _privateConstructorUsedError;
  @JsonKey(name: 'sample_size_pct', fromJson: _toInt)
  int? get sampleSizePct => throw _privateConstructorUsedError;
  @JsonKey(name: 'psk_override')
  String? get pskOverride => throw _privateConstructorUsedError;
  @JsonKey(name: 'wlan_id', fromJson: _toInt)
  int? get wlanId => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  String? get scratch => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_by')
  String? get createdBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_by')
  String? get updatedBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            @JsonKey(fromJson: _toInt) int? id,
            String? name,
            @JsonKey(name: 'test_type') String? testType,
            String? target,
            @JsonKey(fromJson: _toInt) int? port,
            @JsonKey(name: 'iperf_protocol') String? iperfProtocol,
            @JsonKey(name: 'min_download_mbps', fromJson: _toDouble)
            double? minDownloadMbps,
            @JsonKey(name: 'min_upload_mbps', fromJson: _toDouble)
            double? minUploadMbps,
            @JsonKey(fromJson: _toInt) int? period,
            @JsonKey(name: 'period_unit') String? periodUnit,
            @JsonKey(name: 'starts_at') DateTime? startsAt,
            @JsonKey(name: 'next_check_at') DateTime? nextCheckAt,
            @JsonKey(name: 'last_checked_at') DateTime? lastCheckedAt,
            bool passing,
            @JsonKey(name: 'last_result') String? lastResult,
            @JsonKey(name: 'max_failures', fromJson: _toInt) int? maxFailures,
            @JsonKey(name: 'disable_uplink_on_failure')
            bool disableUplinkOnFailure,
            @JsonKey(name: 'sample_size_pct', fromJson: _toInt)
            int? sampleSizePct,
            @JsonKey(name: 'psk_override') String? pskOverride,
            @JsonKey(name: 'wlan_id', fromJson: _toInt) int? wlanId,
            String? note,
            String? scratch,
            @JsonKey(name: 'created_by') String? createdBy,
            @JsonKey(name: 'updated_by') String? updatedBy,
            @JsonKey(name: 'created_at') DateTime? createdAt,
            @JsonKey(name: 'updated_at') DateTime? updatedAt)
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            @JsonKey(fromJson: _toInt) int? id,
            String? name,
            @JsonKey(name: 'test_type') String? testType,
            String? target,
            @JsonKey(fromJson: _toInt) int? port,
            @JsonKey(name: 'iperf_protocol') String? iperfProtocol,
            @JsonKey(name: 'min_download_mbps', fromJson: _toDouble)
            double? minDownloadMbps,
            @JsonKey(name: 'min_upload_mbps', fromJson: _toDouble)
            double? minUploadMbps,
            @JsonKey(fromJson: _toInt) int? period,
            @JsonKey(name: 'period_unit') String? periodUnit,
            @JsonKey(name: 'starts_at') DateTime? startsAt,
            @JsonKey(name: 'next_check_at') DateTime? nextCheckAt,
            @JsonKey(name: 'last_checked_at') DateTime? lastCheckedAt,
            bool passing,
            @JsonKey(name: 'last_result') String? lastResult,
            @JsonKey(name: 'max_failures', fromJson: _toInt) int? maxFailures,
            @JsonKey(name: 'disable_uplink_on_failure')
            bool disableUplinkOnFailure,
            @JsonKey(name: 'sample_size_pct', fromJson: _toInt)
            int? sampleSizePct,
            @JsonKey(name: 'psk_override') String? pskOverride,
            @JsonKey(name: 'wlan_id', fromJson: _toInt) int? wlanId,
            String? note,
            String? scratch,
            @JsonKey(name: 'created_by') String? createdBy,
            @JsonKey(name: 'updated_by') String? updatedBy,
            @JsonKey(name: 'created_at') DateTime? createdAt,
            @JsonKey(name: 'updated_at') DateTime? updatedAt)?
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            @JsonKey(fromJson: _toInt) int? id,
            String? name,
            @JsonKey(name: 'test_type') String? testType,
            String? target,
            @JsonKey(fromJson: _toInt) int? port,
            @JsonKey(name: 'iperf_protocol') String? iperfProtocol,
            @JsonKey(name: 'min_download_mbps', fromJson: _toDouble)
            double? minDownloadMbps,
            @JsonKey(name: 'min_upload_mbps', fromJson: _toDouble)
            double? minUploadMbps,
            @JsonKey(fromJson: _toInt) int? period,
            @JsonKey(name: 'period_unit') String? periodUnit,
            @JsonKey(name: 'starts_at') DateTime? startsAt,
            @JsonKey(name: 'next_check_at') DateTime? nextCheckAt,
            @JsonKey(name: 'last_checked_at') DateTime? lastCheckedAt,
            bool passing,
            @JsonKey(name: 'last_result') String? lastResult,
            @JsonKey(name: 'max_failures', fromJson: _toInt) int? maxFailures,
            @JsonKey(name: 'disable_uplink_on_failure')
            bool disableUplinkOnFailure,
            @JsonKey(name: 'sample_size_pct', fromJson: _toInt)
            int? sampleSizePct,
            @JsonKey(name: 'psk_override') String? pskOverride,
            @JsonKey(name: 'wlan_id', fromJson: _toInt) int? wlanId,
            String? note,
            String? scratch,
            @JsonKey(name: 'created_by') String? createdBy,
            @JsonKey(name: 'updated_by') String? updatedBy,
            @JsonKey(name: 'created_at') DateTime? createdAt,
            @JsonKey(name: 'updated_at') DateTime? updatedAt)?
        $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_SpeedTestConfig value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_SpeedTestConfig value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_SpeedTestConfig value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SpeedTestConfigCopyWith<SpeedTestConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SpeedTestConfigCopyWith<$Res> {
  factory $SpeedTestConfigCopyWith(
          SpeedTestConfig value, $Res Function(SpeedTestConfig) then) =
      _$SpeedTestConfigCopyWithImpl<$Res, SpeedTestConfig>;
  @useResult
  $Res call(
      {@JsonKey(fromJson: _toInt) int? id,
      String? name,
      @JsonKey(name: 'test_type') String? testType,
      String? target,
      @JsonKey(fromJson: _toInt) int? port,
      @JsonKey(name: 'iperf_protocol') String? iperfProtocol,
      @JsonKey(name: 'min_download_mbps', fromJson: _toDouble)
      double? minDownloadMbps,
      @JsonKey(name: 'min_upload_mbps', fromJson: _toDouble)
      double? minUploadMbps,
      @JsonKey(fromJson: _toInt) int? period,
      @JsonKey(name: 'period_unit') String? periodUnit,
      @JsonKey(name: 'starts_at') DateTime? startsAt,
      @JsonKey(name: 'next_check_at') DateTime? nextCheckAt,
      @JsonKey(name: 'last_checked_at') DateTime? lastCheckedAt,
      bool passing,
      @JsonKey(name: 'last_result') String? lastResult,
      @JsonKey(name: 'max_failures', fromJson: _toInt) int? maxFailures,
      @JsonKey(name: 'disable_uplink_on_failure') bool disableUplinkOnFailure,
      @JsonKey(name: 'sample_size_pct', fromJson: _toInt) int? sampleSizePct,
      @JsonKey(name: 'psk_override') String? pskOverride,
      @JsonKey(name: 'wlan_id', fromJson: _toInt) int? wlanId,
      String? note,
      String? scratch,
      @JsonKey(name: 'created_by') String? createdBy,
      @JsonKey(name: 'updated_by') String? updatedBy,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$SpeedTestConfigCopyWithImpl<$Res, $Val extends SpeedTestConfig>
    implements $SpeedTestConfigCopyWith<$Res> {
  _$SpeedTestConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? testType = freezed,
    Object? target = freezed,
    Object? port = freezed,
    Object? iperfProtocol = freezed,
    Object? minDownloadMbps = freezed,
    Object? minUploadMbps = freezed,
    Object? period = freezed,
    Object? periodUnit = freezed,
    Object? startsAt = freezed,
    Object? nextCheckAt = freezed,
    Object? lastCheckedAt = freezed,
    Object? passing = null,
    Object? lastResult = freezed,
    Object? maxFailures = freezed,
    Object? disableUplinkOnFailure = null,
    Object? sampleSizePct = freezed,
    Object? pskOverride = freezed,
    Object? wlanId = freezed,
    Object? note = freezed,
    Object? scratch = freezed,
    Object? createdBy = freezed,
    Object? updatedBy = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      testType: freezed == testType
          ? _value.testType
          : testType // ignore: cast_nullable_to_non_nullable
              as String?,
      target: freezed == target
          ? _value.target
          : target // ignore: cast_nullable_to_non_nullable
              as String?,
      port: freezed == port
          ? _value.port
          : port // ignore: cast_nullable_to_non_nullable
              as int?,
      iperfProtocol: freezed == iperfProtocol
          ? _value.iperfProtocol
          : iperfProtocol // ignore: cast_nullable_to_non_nullable
              as String?,
      minDownloadMbps: freezed == minDownloadMbps
          ? _value.minDownloadMbps
          : minDownloadMbps // ignore: cast_nullable_to_non_nullable
              as double?,
      minUploadMbps: freezed == minUploadMbps
          ? _value.minUploadMbps
          : minUploadMbps // ignore: cast_nullable_to_non_nullable
              as double?,
      period: freezed == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as int?,
      periodUnit: freezed == periodUnit
          ? _value.periodUnit
          : periodUnit // ignore: cast_nullable_to_non_nullable
              as String?,
      startsAt: freezed == startsAt
          ? _value.startsAt
          : startsAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextCheckAt: freezed == nextCheckAt
          ? _value.nextCheckAt
          : nextCheckAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastCheckedAt: freezed == lastCheckedAt
          ? _value.lastCheckedAt
          : lastCheckedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      passing: null == passing
          ? _value.passing
          : passing // ignore: cast_nullable_to_non_nullable
              as bool,
      lastResult: freezed == lastResult
          ? _value.lastResult
          : lastResult // ignore: cast_nullable_to_non_nullable
              as String?,
      maxFailures: freezed == maxFailures
          ? _value.maxFailures
          : maxFailures // ignore: cast_nullable_to_non_nullable
              as int?,
      disableUplinkOnFailure: null == disableUplinkOnFailure
          ? _value.disableUplinkOnFailure
          : disableUplinkOnFailure // ignore: cast_nullable_to_non_nullable
              as bool,
      sampleSizePct: freezed == sampleSizePct
          ? _value.sampleSizePct
          : sampleSizePct // ignore: cast_nullable_to_non_nullable
              as int?,
      pskOverride: freezed == pskOverride
          ? _value.pskOverride
          : pskOverride // ignore: cast_nullable_to_non_nullable
              as String?,
      wlanId: freezed == wlanId
          ? _value.wlanId
          : wlanId // ignore: cast_nullable_to_non_nullable
              as int?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      scratch: freezed == scratch
          ? _value.scratch
          : scratch // ignore: cast_nullable_to_non_nullable
              as String?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedBy: freezed == updatedBy
          ? _value.updatedBy
          : updatedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SpeedTestConfigImplCopyWith<$Res>
    implements $SpeedTestConfigCopyWith<$Res> {
  factory _$$SpeedTestConfigImplCopyWith(_$SpeedTestConfigImpl value,
          $Res Function(_$SpeedTestConfigImpl) then) =
      __$$SpeedTestConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(fromJson: _toInt) int? id,
      String? name,
      @JsonKey(name: 'test_type') String? testType,
      String? target,
      @JsonKey(fromJson: _toInt) int? port,
      @JsonKey(name: 'iperf_protocol') String? iperfProtocol,
      @JsonKey(name: 'min_download_mbps', fromJson: _toDouble)
      double? minDownloadMbps,
      @JsonKey(name: 'min_upload_mbps', fromJson: _toDouble)
      double? minUploadMbps,
      @JsonKey(fromJson: _toInt) int? period,
      @JsonKey(name: 'period_unit') String? periodUnit,
      @JsonKey(name: 'starts_at') DateTime? startsAt,
      @JsonKey(name: 'next_check_at') DateTime? nextCheckAt,
      @JsonKey(name: 'last_checked_at') DateTime? lastCheckedAt,
      bool passing,
      @JsonKey(name: 'last_result') String? lastResult,
      @JsonKey(name: 'max_failures', fromJson: _toInt) int? maxFailures,
      @JsonKey(name: 'disable_uplink_on_failure') bool disableUplinkOnFailure,
      @JsonKey(name: 'sample_size_pct', fromJson: _toInt) int? sampleSizePct,
      @JsonKey(name: 'psk_override') String? pskOverride,
      @JsonKey(name: 'wlan_id', fromJson: _toInt) int? wlanId,
      String? note,
      String? scratch,
      @JsonKey(name: 'created_by') String? createdBy,
      @JsonKey(name: 'updated_by') String? updatedBy,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$SpeedTestConfigImplCopyWithImpl<$Res>
    extends _$SpeedTestConfigCopyWithImpl<$Res, _$SpeedTestConfigImpl>
    implements _$$SpeedTestConfigImplCopyWith<$Res> {
  __$$SpeedTestConfigImplCopyWithImpl(
      _$SpeedTestConfigImpl _value, $Res Function(_$SpeedTestConfigImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? testType = freezed,
    Object? target = freezed,
    Object? port = freezed,
    Object? iperfProtocol = freezed,
    Object? minDownloadMbps = freezed,
    Object? minUploadMbps = freezed,
    Object? period = freezed,
    Object? periodUnit = freezed,
    Object? startsAt = freezed,
    Object? nextCheckAt = freezed,
    Object? lastCheckedAt = freezed,
    Object? passing = null,
    Object? lastResult = freezed,
    Object? maxFailures = freezed,
    Object? disableUplinkOnFailure = null,
    Object? sampleSizePct = freezed,
    Object? pskOverride = freezed,
    Object? wlanId = freezed,
    Object? note = freezed,
    Object? scratch = freezed,
    Object? createdBy = freezed,
    Object? updatedBy = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$SpeedTestConfigImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      testType: freezed == testType
          ? _value.testType
          : testType // ignore: cast_nullable_to_non_nullable
              as String?,
      target: freezed == target
          ? _value.target
          : target // ignore: cast_nullable_to_non_nullable
              as String?,
      port: freezed == port
          ? _value.port
          : port // ignore: cast_nullable_to_non_nullable
              as int?,
      iperfProtocol: freezed == iperfProtocol
          ? _value.iperfProtocol
          : iperfProtocol // ignore: cast_nullable_to_non_nullable
              as String?,
      minDownloadMbps: freezed == minDownloadMbps
          ? _value.minDownloadMbps
          : minDownloadMbps // ignore: cast_nullable_to_non_nullable
              as double?,
      minUploadMbps: freezed == minUploadMbps
          ? _value.minUploadMbps
          : minUploadMbps // ignore: cast_nullable_to_non_nullable
              as double?,
      period: freezed == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as int?,
      periodUnit: freezed == periodUnit
          ? _value.periodUnit
          : periodUnit // ignore: cast_nullable_to_non_nullable
              as String?,
      startsAt: freezed == startsAt
          ? _value.startsAt
          : startsAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextCheckAt: freezed == nextCheckAt
          ? _value.nextCheckAt
          : nextCheckAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastCheckedAt: freezed == lastCheckedAt
          ? _value.lastCheckedAt
          : lastCheckedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      passing: null == passing
          ? _value.passing
          : passing // ignore: cast_nullable_to_non_nullable
              as bool,
      lastResult: freezed == lastResult
          ? _value.lastResult
          : lastResult // ignore: cast_nullable_to_non_nullable
              as String?,
      maxFailures: freezed == maxFailures
          ? _value.maxFailures
          : maxFailures // ignore: cast_nullable_to_non_nullable
              as int?,
      disableUplinkOnFailure: null == disableUplinkOnFailure
          ? _value.disableUplinkOnFailure
          : disableUplinkOnFailure // ignore: cast_nullable_to_non_nullable
              as bool,
      sampleSizePct: freezed == sampleSizePct
          ? _value.sampleSizePct
          : sampleSizePct // ignore: cast_nullable_to_non_nullable
              as int?,
      pskOverride: freezed == pskOverride
          ? _value.pskOverride
          : pskOverride // ignore: cast_nullable_to_non_nullable
              as String?,
      wlanId: freezed == wlanId
          ? _value.wlanId
          : wlanId // ignore: cast_nullable_to_non_nullable
              as int?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      scratch: freezed == scratch
          ? _value.scratch
          : scratch // ignore: cast_nullable_to_non_nullable
              as String?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedBy: freezed == updatedBy
          ? _value.updatedBy
          : updatedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SpeedTestConfigImpl extends _SpeedTestConfig {
  const _$SpeedTestConfigImpl(
      {@JsonKey(fromJson: _toInt) this.id,
      this.name,
      @JsonKey(name: 'test_type') this.testType,
      this.target,
      @JsonKey(fromJson: _toInt) this.port,
      @JsonKey(name: 'iperf_protocol') this.iperfProtocol,
      @JsonKey(name: 'min_download_mbps', fromJson: _toDouble)
      this.minDownloadMbps,
      @JsonKey(name: 'min_upload_mbps', fromJson: _toDouble) this.minUploadMbps,
      @JsonKey(fromJson: _toInt) this.period,
      @JsonKey(name: 'period_unit') this.periodUnit,
      @JsonKey(name: 'starts_at') this.startsAt,
      @JsonKey(name: 'next_check_at') this.nextCheckAt,
      @JsonKey(name: 'last_checked_at') this.lastCheckedAt,
      this.passing = false,
      @JsonKey(name: 'last_result') this.lastResult,
      @JsonKey(name: 'max_failures', fromJson: _toInt) this.maxFailures,
      @JsonKey(name: 'disable_uplink_on_failure')
      this.disableUplinkOnFailure = false,
      @JsonKey(name: 'sample_size_pct', fromJson: _toInt) this.sampleSizePct,
      @JsonKey(name: 'psk_override') this.pskOverride,
      @JsonKey(name: 'wlan_id', fromJson: _toInt) this.wlanId,
      this.note,
      this.scratch,
      @JsonKey(name: 'created_by') this.createdBy,
      @JsonKey(name: 'updated_by') this.updatedBy,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : super._();

  factory _$SpeedTestConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$SpeedTestConfigImplFromJson(json);

  @override
  @JsonKey(fromJson: _toInt)
  final int? id;
  @override
  final String? name;
  @override
  @JsonKey(name: 'test_type')
  final String? testType;
  @override
  final String? target;
  @override
  @JsonKey(fromJson: _toInt)
  final int? port;
  @override
  @JsonKey(name: 'iperf_protocol')
  final String? iperfProtocol;
  @override
  @JsonKey(name: 'min_download_mbps', fromJson: _toDouble)
  final double? minDownloadMbps;
  @override
  @JsonKey(name: 'min_upload_mbps', fromJson: _toDouble)
  final double? minUploadMbps;
  @override
  @JsonKey(fromJson: _toInt)
  final int? period;
  @override
  @JsonKey(name: 'period_unit')
  final String? periodUnit;
  @override
  @JsonKey(name: 'starts_at')
  final DateTime? startsAt;
  @override
  @JsonKey(name: 'next_check_at')
  final DateTime? nextCheckAt;
  @override
  @JsonKey(name: 'last_checked_at')
  final DateTime? lastCheckedAt;
  @override
  @JsonKey()
  final bool passing;
  @override
  @JsonKey(name: 'last_result')
  final String? lastResult;
  @override
  @JsonKey(name: 'max_failures', fromJson: _toInt)
  final int? maxFailures;
  @override
  @JsonKey(name: 'disable_uplink_on_failure')
  final bool disableUplinkOnFailure;
  @override
  @JsonKey(name: 'sample_size_pct', fromJson: _toInt)
  final int? sampleSizePct;
  @override
  @JsonKey(name: 'psk_override')
  final String? pskOverride;
  @override
  @JsonKey(name: 'wlan_id', fromJson: _toInt)
  final int? wlanId;
  @override
  final String? note;
  @override
  final String? scratch;
  @override
  @JsonKey(name: 'created_by')
  final String? createdBy;
  @override
  @JsonKey(name: 'updated_by')
  final String? updatedBy;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'SpeedTestConfig(id: $id, name: $name, testType: $testType, target: $target, port: $port, iperfProtocol: $iperfProtocol, minDownloadMbps: $minDownloadMbps, minUploadMbps: $minUploadMbps, period: $period, periodUnit: $periodUnit, startsAt: $startsAt, nextCheckAt: $nextCheckAt, lastCheckedAt: $lastCheckedAt, passing: $passing, lastResult: $lastResult, maxFailures: $maxFailures, disableUplinkOnFailure: $disableUplinkOnFailure, sampleSizePct: $sampleSizePct, pskOverride: $pskOverride, wlanId: $wlanId, note: $note, scratch: $scratch, createdBy: $createdBy, updatedBy: $updatedBy, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SpeedTestConfigImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.testType, testType) ||
                other.testType == testType) &&
            (identical(other.target, target) || other.target == target) &&
            (identical(other.port, port) || other.port == port) &&
            (identical(other.iperfProtocol, iperfProtocol) ||
                other.iperfProtocol == iperfProtocol) &&
            (identical(other.minDownloadMbps, minDownloadMbps) ||
                other.minDownloadMbps == minDownloadMbps) &&
            (identical(other.minUploadMbps, minUploadMbps) ||
                other.minUploadMbps == minUploadMbps) &&
            (identical(other.period, period) || other.period == period) &&
            (identical(other.periodUnit, periodUnit) ||
                other.periodUnit == periodUnit) &&
            (identical(other.startsAt, startsAt) ||
                other.startsAt == startsAt) &&
            (identical(other.nextCheckAt, nextCheckAt) ||
                other.nextCheckAt == nextCheckAt) &&
            (identical(other.lastCheckedAt, lastCheckedAt) ||
                other.lastCheckedAt == lastCheckedAt) &&
            (identical(other.passing, passing) || other.passing == passing) &&
            (identical(other.lastResult, lastResult) ||
                other.lastResult == lastResult) &&
            (identical(other.maxFailures, maxFailures) ||
                other.maxFailures == maxFailures) &&
            (identical(other.disableUplinkOnFailure, disableUplinkOnFailure) ||
                other.disableUplinkOnFailure == disableUplinkOnFailure) &&
            (identical(other.sampleSizePct, sampleSizePct) ||
                other.sampleSizePct == sampleSizePct) &&
            (identical(other.pskOverride, pskOverride) ||
                other.pskOverride == pskOverride) &&
            (identical(other.wlanId, wlanId) || other.wlanId == wlanId) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.scratch, scratch) || other.scratch == scratch) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.updatedBy, updatedBy) ||
                other.updatedBy == updatedBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        testType,
        target,
        port,
        iperfProtocol,
        minDownloadMbps,
        minUploadMbps,
        period,
        periodUnit,
        startsAt,
        nextCheckAt,
        lastCheckedAt,
        passing,
        lastResult,
        maxFailures,
        disableUplinkOnFailure,
        sampleSizePct,
        pskOverride,
        wlanId,
        note,
        scratch,
        createdBy,
        updatedBy,
        createdAt,
        updatedAt
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SpeedTestConfigImplCopyWith<_$SpeedTestConfigImpl> get copyWith =>
      __$$SpeedTestConfigImplCopyWithImpl<_$SpeedTestConfigImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            @JsonKey(fromJson: _toInt) int? id,
            String? name,
            @JsonKey(name: 'test_type') String? testType,
            String? target,
            @JsonKey(fromJson: _toInt) int? port,
            @JsonKey(name: 'iperf_protocol') String? iperfProtocol,
            @JsonKey(name: 'min_download_mbps', fromJson: _toDouble)
            double? minDownloadMbps,
            @JsonKey(name: 'min_upload_mbps', fromJson: _toDouble)
            double? minUploadMbps,
            @JsonKey(fromJson: _toInt) int? period,
            @JsonKey(name: 'period_unit') String? periodUnit,
            @JsonKey(name: 'starts_at') DateTime? startsAt,
            @JsonKey(name: 'next_check_at') DateTime? nextCheckAt,
            @JsonKey(name: 'last_checked_at') DateTime? lastCheckedAt,
            bool passing,
            @JsonKey(name: 'last_result') String? lastResult,
            @JsonKey(name: 'max_failures', fromJson: _toInt) int? maxFailures,
            @JsonKey(name: 'disable_uplink_on_failure')
            bool disableUplinkOnFailure,
            @JsonKey(name: 'sample_size_pct', fromJson: _toInt)
            int? sampleSizePct,
            @JsonKey(name: 'psk_override') String? pskOverride,
            @JsonKey(name: 'wlan_id', fromJson: _toInt) int? wlanId,
            String? note,
            String? scratch,
            @JsonKey(name: 'created_by') String? createdBy,
            @JsonKey(name: 'updated_by') String? updatedBy,
            @JsonKey(name: 'created_at') DateTime? createdAt,
            @JsonKey(name: 'updated_at') DateTime? updatedAt)
        $default,
  ) {
    return $default(
        id,
        name,
        testType,
        target,
        port,
        iperfProtocol,
        minDownloadMbps,
        minUploadMbps,
        period,
        periodUnit,
        startsAt,
        nextCheckAt,
        lastCheckedAt,
        passing,
        lastResult,
        maxFailures,
        disableUplinkOnFailure,
        sampleSizePct,
        pskOverride,
        wlanId,
        note,
        scratch,
        createdBy,
        updatedBy,
        createdAt,
        updatedAt);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            @JsonKey(fromJson: _toInt) int? id,
            String? name,
            @JsonKey(name: 'test_type') String? testType,
            String? target,
            @JsonKey(fromJson: _toInt) int? port,
            @JsonKey(name: 'iperf_protocol') String? iperfProtocol,
            @JsonKey(name: 'min_download_mbps', fromJson: _toDouble)
            double? minDownloadMbps,
            @JsonKey(name: 'min_upload_mbps', fromJson: _toDouble)
            double? minUploadMbps,
            @JsonKey(fromJson: _toInt) int? period,
            @JsonKey(name: 'period_unit') String? periodUnit,
            @JsonKey(name: 'starts_at') DateTime? startsAt,
            @JsonKey(name: 'next_check_at') DateTime? nextCheckAt,
            @JsonKey(name: 'last_checked_at') DateTime? lastCheckedAt,
            bool passing,
            @JsonKey(name: 'last_result') String? lastResult,
            @JsonKey(name: 'max_failures', fromJson: _toInt) int? maxFailures,
            @JsonKey(name: 'disable_uplink_on_failure')
            bool disableUplinkOnFailure,
            @JsonKey(name: 'sample_size_pct', fromJson: _toInt)
            int? sampleSizePct,
            @JsonKey(name: 'psk_override') String? pskOverride,
            @JsonKey(name: 'wlan_id', fromJson: _toInt) int? wlanId,
            String? note,
            String? scratch,
            @JsonKey(name: 'created_by') String? createdBy,
            @JsonKey(name: 'updated_by') String? updatedBy,
            @JsonKey(name: 'created_at') DateTime? createdAt,
            @JsonKey(name: 'updated_at') DateTime? updatedAt)?
        $default,
  ) {
    return $default?.call(
        id,
        name,
        testType,
        target,
        port,
        iperfProtocol,
        minDownloadMbps,
        minUploadMbps,
        period,
        periodUnit,
        startsAt,
        nextCheckAt,
        lastCheckedAt,
        passing,
        lastResult,
        maxFailures,
        disableUplinkOnFailure,
        sampleSizePct,
        pskOverride,
        wlanId,
        note,
        scratch,
        createdBy,
        updatedBy,
        createdAt,
        updatedAt);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            @JsonKey(fromJson: _toInt) int? id,
            String? name,
            @JsonKey(name: 'test_type') String? testType,
            String? target,
            @JsonKey(fromJson: _toInt) int? port,
            @JsonKey(name: 'iperf_protocol') String? iperfProtocol,
            @JsonKey(name: 'min_download_mbps', fromJson: _toDouble)
            double? minDownloadMbps,
            @JsonKey(name: 'min_upload_mbps', fromJson: _toDouble)
            double? minUploadMbps,
            @JsonKey(fromJson: _toInt) int? period,
            @JsonKey(name: 'period_unit') String? periodUnit,
            @JsonKey(name: 'starts_at') DateTime? startsAt,
            @JsonKey(name: 'next_check_at') DateTime? nextCheckAt,
            @JsonKey(name: 'last_checked_at') DateTime? lastCheckedAt,
            bool passing,
            @JsonKey(name: 'last_result') String? lastResult,
            @JsonKey(name: 'max_failures', fromJson: _toInt) int? maxFailures,
            @JsonKey(name: 'disable_uplink_on_failure')
            bool disableUplinkOnFailure,
            @JsonKey(name: 'sample_size_pct', fromJson: _toInt)
            int? sampleSizePct,
            @JsonKey(name: 'psk_override') String? pskOverride,
            @JsonKey(name: 'wlan_id', fromJson: _toInt) int? wlanId,
            String? note,
            String? scratch,
            @JsonKey(name: 'created_by') String? createdBy,
            @JsonKey(name: 'updated_by') String? updatedBy,
            @JsonKey(name: 'created_at') DateTime? createdAt,
            @JsonKey(name: 'updated_at') DateTime? updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(
          id,
          name,
          testType,
          target,
          port,
          iperfProtocol,
          minDownloadMbps,
          minUploadMbps,
          period,
          periodUnit,
          startsAt,
          nextCheckAt,
          lastCheckedAt,
          passing,
          lastResult,
          maxFailures,
          disableUplinkOnFailure,
          sampleSizePct,
          pskOverride,
          wlanId,
          note,
          scratch,
          createdBy,
          updatedBy,
          createdAt,
          updatedAt);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_SpeedTestConfig value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_SpeedTestConfig value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_SpeedTestConfig value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$SpeedTestConfigImplToJson(
      this,
    );
  }
}

abstract class _SpeedTestConfig extends SpeedTestConfig {
  const factory _SpeedTestConfig(
      {@JsonKey(fromJson: _toInt) final int? id,
      final String? name,
      @JsonKey(name: 'test_type') final String? testType,
      final String? target,
      @JsonKey(fromJson: _toInt) final int? port,
      @JsonKey(name: 'iperf_protocol') final String? iperfProtocol,
      @JsonKey(name: 'min_download_mbps', fromJson: _toDouble)
      final double? minDownloadMbps,
      @JsonKey(name: 'min_upload_mbps', fromJson: _toDouble)
      final double? minUploadMbps,
      @JsonKey(fromJson: _toInt) final int? period,
      @JsonKey(name: 'period_unit') final String? periodUnit,
      @JsonKey(name: 'starts_at') final DateTime? startsAt,
      @JsonKey(name: 'next_check_at') final DateTime? nextCheckAt,
      @JsonKey(name: 'last_checked_at') final DateTime? lastCheckedAt,
      final bool passing,
      @JsonKey(name: 'last_result') final String? lastResult,
      @JsonKey(name: 'max_failures', fromJson: _toInt) final int? maxFailures,
      @JsonKey(name: 'disable_uplink_on_failure')
      final bool disableUplinkOnFailure,
      @JsonKey(name: 'sample_size_pct', fromJson: _toInt)
      final int? sampleSizePct,
      @JsonKey(name: 'psk_override') final String? pskOverride,
      @JsonKey(name: 'wlan_id', fromJson: _toInt) final int? wlanId,
      final String? note,
      final String? scratch,
      @JsonKey(name: 'created_by') final String? createdBy,
      @JsonKey(name: 'updated_by') final String? updatedBy,
      @JsonKey(name: 'created_at') final DateTime? createdAt,
      @JsonKey(name: 'updated_at')
      final DateTime? updatedAt}) = _$SpeedTestConfigImpl;
  const _SpeedTestConfig._() : super._();

  factory _SpeedTestConfig.fromJson(Map<String, dynamic> json) =
      _$SpeedTestConfigImpl.fromJson;

  @override
  @JsonKey(fromJson: _toInt)
  int? get id;
  @override
  String? get name;
  @override
  @JsonKey(name: 'test_type')
  String? get testType;
  @override
  String? get target;
  @override
  @JsonKey(fromJson: _toInt)
  int? get port;
  @override
  @JsonKey(name: 'iperf_protocol')
  String? get iperfProtocol;
  @override
  @JsonKey(name: 'min_download_mbps', fromJson: _toDouble)
  double? get minDownloadMbps;
  @override
  @JsonKey(name: 'min_upload_mbps', fromJson: _toDouble)
  double? get minUploadMbps;
  @override
  @JsonKey(fromJson: _toInt)
  int? get period;
  @override
  @JsonKey(name: 'period_unit')
  String? get periodUnit;
  @override
  @JsonKey(name: 'starts_at')
  DateTime? get startsAt;
  @override
  @JsonKey(name: 'next_check_at')
  DateTime? get nextCheckAt;
  @override
  @JsonKey(name: 'last_checked_at')
  DateTime? get lastCheckedAt;
  @override
  bool get passing;
  @override
  @JsonKey(name: 'last_result')
  String? get lastResult;
  @override
  @JsonKey(name: 'max_failures', fromJson: _toInt)
  int? get maxFailures;
  @override
  @JsonKey(name: 'disable_uplink_on_failure')
  bool get disableUplinkOnFailure;
  @override
  @JsonKey(name: 'sample_size_pct', fromJson: _toInt)
  int? get sampleSizePct;
  @override
  @JsonKey(name: 'psk_override')
  String? get pskOverride;
  @override
  @JsonKey(name: 'wlan_id', fromJson: _toInt)
  int? get wlanId;
  @override
  String? get note;
  @override
  String? get scratch;
  @override
  @JsonKey(name: 'created_by')
  String? get createdBy;
  @override
  @JsonKey(name: 'updated_by')
  String? get updatedBy;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$SpeedTestConfigImplCopyWith<_$SpeedTestConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
