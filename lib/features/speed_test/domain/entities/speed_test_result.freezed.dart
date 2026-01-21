// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'speed_test_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SpeedTestResult _$SpeedTestResultFromJson(Map<String, dynamic> json) {
  return _SpeedTestResult.fromJson(json);
}

/// @nodoc
mixin _$SpeedTestResult {
  @JsonKey(fromJson: _toInt)
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'speed_test_id', fromJson: _toInt)
  int? get speedTestId => throw _privateConstructorUsedError;
  @JsonKey(name: 'test_type')
  String? get testType => throw _privateConstructorUsedError;
  String? get source => throw _privateConstructorUsedError;
  String? get destination => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _toInt)
  int? get port => throw _privateConstructorUsedError;
  @JsonKey(name: 'iperf_protocol')
  String? get iperfProtocol => throw _privateConstructorUsedError;
  @JsonKey(name: 'download_mbps', fromJson: _toDouble)
  double? get downloadMbps => throw _privateConstructorUsedError;
  @JsonKey(name: 'upload_mbps', fromJson: _toDouble)
  double? get uploadMbps => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _toDouble)
  double? get rtt => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _toDouble)
  double? get jitter => throw _privateConstructorUsedError;
  @JsonKey(name: 'packet_loss', fromJson: _toDouble)
  double? get packetLoss => throw _privateConstructorUsedError;
  bool get passed => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_applicable')
  bool get isApplicable => throw _privateConstructorUsedError;
  @JsonKey(name: 'initiated_at')
  DateTime? get initiatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'completed_at')
  DateTime? get completedAt => throw _privateConstructorUsedError;
  String? get raw => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'access_point_id', fromJson: _toInt)
  int? get accessPointId => throw _privateConstructorUsedError;
  @JsonKey(name: 'tested_via_access_point_id', fromJson: _toInt)
  int? get testedViaAccessPointId => throw _privateConstructorUsedError;
  @JsonKey(name: 'tested_via_access_point_radio_id', fromJson: _toInt)
  int? get testedViaAccessPointRadioId => throw _privateConstructorUsedError;
  @JsonKey(name: 'tested_via_media_converter_id', fromJson: _toInt)
  int? get testedViaMediaConverterId => throw _privateConstructorUsedError;
  @JsonKey(name: 'uplink_id', fromJson: _toInt)
  int? get uplinkId => throw _privateConstructorUsedError;
  @JsonKey(name: 'wlan_id', fromJson: _toInt)
  int? get wlanId => throw _privateConstructorUsedError;
  @JsonKey(name: 'pms_room_id', fromJson: _toInt)
  int? get pmsRoomId => throw _privateConstructorUsedError;
  @JsonKey(name: 'room_type')
  String? get roomType => throw _privateConstructorUsedError;
  @JsonKey(name: 'admin_id', fromJson: _toInt)
  int? get adminId => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  String? get scratch => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_by')
  String? get createdBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_by')
  String? get updatedBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt =>
      throw _privateConstructorUsedError; // Legacy fields for backwards compatibility (not sent to server)
  @JsonKey(includeToJson: false)
  bool get hasError => throw _privateConstructorUsedError;
  @JsonKey(name: 'error_message', includeToJson: false)
  String? get errorMessage => throw _privateConstructorUsedError;
  @JsonKey(name: 'local_ip_address')
  String? get localIpAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'server_host')
  String? get serverHost => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            @JsonKey(fromJson: _toInt) int? id,
            @JsonKey(name: 'speed_test_id', fromJson: _toInt) int? speedTestId,
            @JsonKey(name: 'test_type') String? testType,
            String? source,
            String? destination,
            @JsonKey(fromJson: _toInt) int? port,
            @JsonKey(name: 'iperf_protocol') String? iperfProtocol,
            @JsonKey(name: 'download_mbps', fromJson: _toDouble)
            double? downloadMbps,
            @JsonKey(name: 'upload_mbps', fromJson: _toDouble)
            double? uploadMbps,
            @JsonKey(fromJson: _toDouble) double? rtt,
            @JsonKey(fromJson: _toDouble) double? jitter,
            @JsonKey(name: 'packet_loss', fromJson: _toDouble)
            double? packetLoss,
            bool passed,
            @JsonKey(name: 'is_applicable') bool isApplicable,
            @JsonKey(name: 'initiated_at') DateTime? initiatedAt,
            @JsonKey(name: 'completed_at') DateTime? completedAt,
            String? raw,
            @JsonKey(name: 'image_url') String? imageUrl,
            @JsonKey(name: 'access_point_id', fromJson: _toInt)
            int? accessPointId,
            @JsonKey(name: 'tested_via_access_point_id', fromJson: _toInt)
            int? testedViaAccessPointId,
            @JsonKey(name: 'tested_via_access_point_radio_id', fromJson: _toInt)
            int? testedViaAccessPointRadioId,
            @JsonKey(name: 'tested_via_media_converter_id', fromJson: _toInt)
            int? testedViaMediaConverterId,
            @JsonKey(name: 'uplink_id', fromJson: _toInt) int? uplinkId,
            @JsonKey(name: 'wlan_id', fromJson: _toInt) int? wlanId,
            @JsonKey(name: 'pms_room_id', fromJson: _toInt) int? pmsRoomId,
            @JsonKey(name: 'room_type') String? roomType,
            @JsonKey(name: 'admin_id', fromJson: _toInt) int? adminId,
            String? note,
            String? scratch,
            @JsonKey(name: 'created_by') String? createdBy,
            @JsonKey(name: 'updated_by') String? updatedBy,
            @JsonKey(name: 'created_at') DateTime? createdAt,
            @JsonKey(name: 'updated_at') DateTime? updatedAt,
            @JsonKey(includeToJson: false) bool hasError,
            @JsonKey(name: 'error_message', includeToJson: false)
            String? errorMessage,
            @JsonKey(name: 'local_ip_address') String? localIpAddress,
            @JsonKey(name: 'server_host') String? serverHost)
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            @JsonKey(fromJson: _toInt) int? id,
            @JsonKey(name: 'speed_test_id', fromJson: _toInt) int? speedTestId,
            @JsonKey(name: 'test_type') String? testType,
            String? source,
            String? destination,
            @JsonKey(fromJson: _toInt) int? port,
            @JsonKey(name: 'iperf_protocol') String? iperfProtocol,
            @JsonKey(name: 'download_mbps', fromJson: _toDouble)
            double? downloadMbps,
            @JsonKey(name: 'upload_mbps', fromJson: _toDouble)
            double? uploadMbps,
            @JsonKey(fromJson: _toDouble) double? rtt,
            @JsonKey(fromJson: _toDouble) double? jitter,
            @JsonKey(name: 'packet_loss', fromJson: _toDouble)
            double? packetLoss,
            bool passed,
            @JsonKey(name: 'is_applicable') bool isApplicable,
            @JsonKey(name: 'initiated_at') DateTime? initiatedAt,
            @JsonKey(name: 'completed_at') DateTime? completedAt,
            String? raw,
            @JsonKey(name: 'image_url') String? imageUrl,
            @JsonKey(name: 'access_point_id', fromJson: _toInt)
            int? accessPointId,
            @JsonKey(name: 'tested_via_access_point_id', fromJson: _toInt)
            int? testedViaAccessPointId,
            @JsonKey(name: 'tested_via_access_point_radio_id', fromJson: _toInt)
            int? testedViaAccessPointRadioId,
            @JsonKey(name: 'tested_via_media_converter_id', fromJson: _toInt)
            int? testedViaMediaConverterId,
            @JsonKey(name: 'uplink_id', fromJson: _toInt) int? uplinkId,
            @JsonKey(name: 'wlan_id', fromJson: _toInt) int? wlanId,
            @JsonKey(name: 'pms_room_id', fromJson: _toInt) int? pmsRoomId,
            @JsonKey(name: 'room_type') String? roomType,
            @JsonKey(name: 'admin_id', fromJson: _toInt) int? adminId,
            String? note,
            String? scratch,
            @JsonKey(name: 'created_by') String? createdBy,
            @JsonKey(name: 'updated_by') String? updatedBy,
            @JsonKey(name: 'created_at') DateTime? createdAt,
            @JsonKey(name: 'updated_at') DateTime? updatedAt,
            @JsonKey(includeToJson: false) bool hasError,
            @JsonKey(name: 'error_message', includeToJson: false)
            String? errorMessage,
            @JsonKey(name: 'local_ip_address') String? localIpAddress,
            @JsonKey(name: 'server_host') String? serverHost)?
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            @JsonKey(fromJson: _toInt) int? id,
            @JsonKey(name: 'speed_test_id', fromJson: _toInt) int? speedTestId,
            @JsonKey(name: 'test_type') String? testType,
            String? source,
            String? destination,
            @JsonKey(fromJson: _toInt) int? port,
            @JsonKey(name: 'iperf_protocol') String? iperfProtocol,
            @JsonKey(name: 'download_mbps', fromJson: _toDouble)
            double? downloadMbps,
            @JsonKey(name: 'upload_mbps', fromJson: _toDouble)
            double? uploadMbps,
            @JsonKey(fromJson: _toDouble) double? rtt,
            @JsonKey(fromJson: _toDouble) double? jitter,
            @JsonKey(name: 'packet_loss', fromJson: _toDouble)
            double? packetLoss,
            bool passed,
            @JsonKey(name: 'is_applicable') bool isApplicable,
            @JsonKey(name: 'initiated_at') DateTime? initiatedAt,
            @JsonKey(name: 'completed_at') DateTime? completedAt,
            String? raw,
            @JsonKey(name: 'image_url') String? imageUrl,
            @JsonKey(name: 'access_point_id', fromJson: _toInt)
            int? accessPointId,
            @JsonKey(name: 'tested_via_access_point_id', fromJson: _toInt)
            int? testedViaAccessPointId,
            @JsonKey(name: 'tested_via_access_point_radio_id', fromJson: _toInt)
            int? testedViaAccessPointRadioId,
            @JsonKey(name: 'tested_via_media_converter_id', fromJson: _toInt)
            int? testedViaMediaConverterId,
            @JsonKey(name: 'uplink_id', fromJson: _toInt) int? uplinkId,
            @JsonKey(name: 'wlan_id', fromJson: _toInt) int? wlanId,
            @JsonKey(name: 'pms_room_id', fromJson: _toInt) int? pmsRoomId,
            @JsonKey(name: 'room_type') String? roomType,
            @JsonKey(name: 'admin_id', fromJson: _toInt) int? adminId,
            String? note,
            String? scratch,
            @JsonKey(name: 'created_by') String? createdBy,
            @JsonKey(name: 'updated_by') String? updatedBy,
            @JsonKey(name: 'created_at') DateTime? createdAt,
            @JsonKey(name: 'updated_at') DateTime? updatedAt,
            @JsonKey(includeToJson: false) bool hasError,
            @JsonKey(name: 'error_message', includeToJson: false)
            String? errorMessage,
            @JsonKey(name: 'local_ip_address') String? localIpAddress,
            @JsonKey(name: 'server_host') String? serverHost)?
        $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_SpeedTestResult value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_SpeedTestResult value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_SpeedTestResult value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SpeedTestResultCopyWith<SpeedTestResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SpeedTestResultCopyWith<$Res> {
  factory $SpeedTestResultCopyWith(
          SpeedTestResult value, $Res Function(SpeedTestResult) then) =
      _$SpeedTestResultCopyWithImpl<$Res, SpeedTestResult>;
  @useResult
  $Res call(
      {@JsonKey(fromJson: _toInt) int? id,
      @JsonKey(name: 'speed_test_id', fromJson: _toInt) int? speedTestId,
      @JsonKey(name: 'test_type') String? testType,
      String? source,
      String? destination,
      @JsonKey(fromJson: _toInt) int? port,
      @JsonKey(name: 'iperf_protocol') String? iperfProtocol,
      @JsonKey(name: 'download_mbps', fromJson: _toDouble) double? downloadMbps,
      @JsonKey(name: 'upload_mbps', fromJson: _toDouble) double? uploadMbps,
      @JsonKey(fromJson: _toDouble) double? rtt,
      @JsonKey(fromJson: _toDouble) double? jitter,
      @JsonKey(name: 'packet_loss', fromJson: _toDouble) double? packetLoss,
      bool passed,
      @JsonKey(name: 'is_applicable') bool isApplicable,
      @JsonKey(name: 'initiated_at') DateTime? initiatedAt,
      @JsonKey(name: 'completed_at') DateTime? completedAt,
      String? raw,
      @JsonKey(name: 'image_url') String? imageUrl,
      @JsonKey(name: 'access_point_id', fromJson: _toInt) int? accessPointId,
      @JsonKey(name: 'tested_via_access_point_id', fromJson: _toInt)
      int? testedViaAccessPointId,
      @JsonKey(name: 'tested_via_access_point_radio_id', fromJson: _toInt)
      int? testedViaAccessPointRadioId,
      @JsonKey(name: 'tested_via_media_converter_id', fromJson: _toInt)
      int? testedViaMediaConverterId,
      @JsonKey(name: 'uplink_id', fromJson: _toInt) int? uplinkId,
      @JsonKey(name: 'wlan_id', fromJson: _toInt) int? wlanId,
      @JsonKey(name: 'pms_room_id', fromJson: _toInt) int? pmsRoomId,
      @JsonKey(name: 'room_type') String? roomType,
      @JsonKey(name: 'admin_id', fromJson: _toInt) int? adminId,
      String? note,
      String? scratch,
      @JsonKey(name: 'created_by') String? createdBy,
      @JsonKey(name: 'updated_by') String? updatedBy,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      @JsonKey(includeToJson: false) bool hasError,
      @JsonKey(name: 'error_message', includeToJson: false)
      String? errorMessage,
      @JsonKey(name: 'local_ip_address') String? localIpAddress,
      @JsonKey(name: 'server_host') String? serverHost});
}

/// @nodoc
class _$SpeedTestResultCopyWithImpl<$Res, $Val extends SpeedTestResult>
    implements $SpeedTestResultCopyWith<$Res> {
  _$SpeedTestResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? speedTestId = freezed,
    Object? testType = freezed,
    Object? source = freezed,
    Object? destination = freezed,
    Object? port = freezed,
    Object? iperfProtocol = freezed,
    Object? downloadMbps = freezed,
    Object? uploadMbps = freezed,
    Object? rtt = freezed,
    Object? jitter = freezed,
    Object? packetLoss = freezed,
    Object? passed = null,
    Object? isApplicable = null,
    Object? initiatedAt = freezed,
    Object? completedAt = freezed,
    Object? raw = freezed,
    Object? imageUrl = freezed,
    Object? accessPointId = freezed,
    Object? testedViaAccessPointId = freezed,
    Object? testedViaAccessPointRadioId = freezed,
    Object? testedViaMediaConverterId = freezed,
    Object? uplinkId = freezed,
    Object? wlanId = freezed,
    Object? pmsRoomId = freezed,
    Object? roomType = freezed,
    Object? adminId = freezed,
    Object? note = freezed,
    Object? scratch = freezed,
    Object? createdBy = freezed,
    Object? updatedBy = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? hasError = null,
    Object? errorMessage = freezed,
    Object? localIpAddress = freezed,
    Object? serverHost = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      speedTestId: freezed == speedTestId
          ? _value.speedTestId
          : speedTestId // ignore: cast_nullable_to_non_nullable
              as int?,
      testType: freezed == testType
          ? _value.testType
          : testType // ignore: cast_nullable_to_non_nullable
              as String?,
      source: freezed == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String?,
      destination: freezed == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as String?,
      port: freezed == port
          ? _value.port
          : port // ignore: cast_nullable_to_non_nullable
              as int?,
      iperfProtocol: freezed == iperfProtocol
          ? _value.iperfProtocol
          : iperfProtocol // ignore: cast_nullable_to_non_nullable
              as String?,
      downloadMbps: freezed == downloadMbps
          ? _value.downloadMbps
          : downloadMbps // ignore: cast_nullable_to_non_nullable
              as double?,
      uploadMbps: freezed == uploadMbps
          ? _value.uploadMbps
          : uploadMbps // ignore: cast_nullable_to_non_nullable
              as double?,
      rtt: freezed == rtt
          ? _value.rtt
          : rtt // ignore: cast_nullable_to_non_nullable
              as double?,
      jitter: freezed == jitter
          ? _value.jitter
          : jitter // ignore: cast_nullable_to_non_nullable
              as double?,
      packetLoss: freezed == packetLoss
          ? _value.packetLoss
          : packetLoss // ignore: cast_nullable_to_non_nullable
              as double?,
      passed: null == passed
          ? _value.passed
          : passed // ignore: cast_nullable_to_non_nullable
              as bool,
      isApplicable: null == isApplicable
          ? _value.isApplicable
          : isApplicable // ignore: cast_nullable_to_non_nullable
              as bool,
      initiatedAt: freezed == initiatedAt
          ? _value.initiatedAt
          : initiatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      raw: freezed == raw
          ? _value.raw
          : raw // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      accessPointId: freezed == accessPointId
          ? _value.accessPointId
          : accessPointId // ignore: cast_nullable_to_non_nullable
              as int?,
      testedViaAccessPointId: freezed == testedViaAccessPointId
          ? _value.testedViaAccessPointId
          : testedViaAccessPointId // ignore: cast_nullable_to_non_nullable
              as int?,
      testedViaAccessPointRadioId: freezed == testedViaAccessPointRadioId
          ? _value.testedViaAccessPointRadioId
          : testedViaAccessPointRadioId // ignore: cast_nullable_to_non_nullable
              as int?,
      testedViaMediaConverterId: freezed == testedViaMediaConverterId
          ? _value.testedViaMediaConverterId
          : testedViaMediaConverterId // ignore: cast_nullable_to_non_nullable
              as int?,
      uplinkId: freezed == uplinkId
          ? _value.uplinkId
          : uplinkId // ignore: cast_nullable_to_non_nullable
              as int?,
      wlanId: freezed == wlanId
          ? _value.wlanId
          : wlanId // ignore: cast_nullable_to_non_nullable
              as int?,
      pmsRoomId: freezed == pmsRoomId
          ? _value.pmsRoomId
          : pmsRoomId // ignore: cast_nullable_to_non_nullable
              as int?,
      roomType: freezed == roomType
          ? _value.roomType
          : roomType // ignore: cast_nullable_to_non_nullable
              as String?,
      adminId: freezed == adminId
          ? _value.adminId
          : adminId // ignore: cast_nullable_to_non_nullable
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
      hasError: null == hasError
          ? _value.hasError
          : hasError // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      localIpAddress: freezed == localIpAddress
          ? _value.localIpAddress
          : localIpAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      serverHost: freezed == serverHost
          ? _value.serverHost
          : serverHost // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SpeedTestResultImplCopyWith<$Res>
    implements $SpeedTestResultCopyWith<$Res> {
  factory _$$SpeedTestResultImplCopyWith(_$SpeedTestResultImpl value,
          $Res Function(_$SpeedTestResultImpl) then) =
      __$$SpeedTestResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(fromJson: _toInt) int? id,
      @JsonKey(name: 'speed_test_id', fromJson: _toInt) int? speedTestId,
      @JsonKey(name: 'test_type') String? testType,
      String? source,
      String? destination,
      @JsonKey(fromJson: _toInt) int? port,
      @JsonKey(name: 'iperf_protocol') String? iperfProtocol,
      @JsonKey(name: 'download_mbps', fromJson: _toDouble) double? downloadMbps,
      @JsonKey(name: 'upload_mbps', fromJson: _toDouble) double? uploadMbps,
      @JsonKey(fromJson: _toDouble) double? rtt,
      @JsonKey(fromJson: _toDouble) double? jitter,
      @JsonKey(name: 'packet_loss', fromJson: _toDouble) double? packetLoss,
      bool passed,
      @JsonKey(name: 'is_applicable') bool isApplicable,
      @JsonKey(name: 'initiated_at') DateTime? initiatedAt,
      @JsonKey(name: 'completed_at') DateTime? completedAt,
      String? raw,
      @JsonKey(name: 'image_url') String? imageUrl,
      @JsonKey(name: 'access_point_id', fromJson: _toInt) int? accessPointId,
      @JsonKey(name: 'tested_via_access_point_id', fromJson: _toInt)
      int? testedViaAccessPointId,
      @JsonKey(name: 'tested_via_access_point_radio_id', fromJson: _toInt)
      int? testedViaAccessPointRadioId,
      @JsonKey(name: 'tested_via_media_converter_id', fromJson: _toInt)
      int? testedViaMediaConverterId,
      @JsonKey(name: 'uplink_id', fromJson: _toInt) int? uplinkId,
      @JsonKey(name: 'wlan_id', fromJson: _toInt) int? wlanId,
      @JsonKey(name: 'pms_room_id', fromJson: _toInt) int? pmsRoomId,
      @JsonKey(name: 'room_type') String? roomType,
      @JsonKey(name: 'admin_id', fromJson: _toInt) int? adminId,
      String? note,
      String? scratch,
      @JsonKey(name: 'created_by') String? createdBy,
      @JsonKey(name: 'updated_by') String? updatedBy,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      @JsonKey(includeToJson: false) bool hasError,
      @JsonKey(name: 'error_message', includeToJson: false)
      String? errorMessage,
      @JsonKey(name: 'local_ip_address') String? localIpAddress,
      @JsonKey(name: 'server_host') String? serverHost});
}

/// @nodoc
class __$$SpeedTestResultImplCopyWithImpl<$Res>
    extends _$SpeedTestResultCopyWithImpl<$Res, _$SpeedTestResultImpl>
    implements _$$SpeedTestResultImplCopyWith<$Res> {
  __$$SpeedTestResultImplCopyWithImpl(
      _$SpeedTestResultImpl _value, $Res Function(_$SpeedTestResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? speedTestId = freezed,
    Object? testType = freezed,
    Object? source = freezed,
    Object? destination = freezed,
    Object? port = freezed,
    Object? iperfProtocol = freezed,
    Object? downloadMbps = freezed,
    Object? uploadMbps = freezed,
    Object? rtt = freezed,
    Object? jitter = freezed,
    Object? packetLoss = freezed,
    Object? passed = null,
    Object? isApplicable = null,
    Object? initiatedAt = freezed,
    Object? completedAt = freezed,
    Object? raw = freezed,
    Object? imageUrl = freezed,
    Object? accessPointId = freezed,
    Object? testedViaAccessPointId = freezed,
    Object? testedViaAccessPointRadioId = freezed,
    Object? testedViaMediaConverterId = freezed,
    Object? uplinkId = freezed,
    Object? wlanId = freezed,
    Object? pmsRoomId = freezed,
    Object? roomType = freezed,
    Object? adminId = freezed,
    Object? note = freezed,
    Object? scratch = freezed,
    Object? createdBy = freezed,
    Object? updatedBy = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? hasError = null,
    Object? errorMessage = freezed,
    Object? localIpAddress = freezed,
    Object? serverHost = freezed,
  }) {
    return _then(_$SpeedTestResultImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      speedTestId: freezed == speedTestId
          ? _value.speedTestId
          : speedTestId // ignore: cast_nullable_to_non_nullable
              as int?,
      testType: freezed == testType
          ? _value.testType
          : testType // ignore: cast_nullable_to_non_nullable
              as String?,
      source: freezed == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String?,
      destination: freezed == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as String?,
      port: freezed == port
          ? _value.port
          : port // ignore: cast_nullable_to_non_nullable
              as int?,
      iperfProtocol: freezed == iperfProtocol
          ? _value.iperfProtocol
          : iperfProtocol // ignore: cast_nullable_to_non_nullable
              as String?,
      downloadMbps: freezed == downloadMbps
          ? _value.downloadMbps
          : downloadMbps // ignore: cast_nullable_to_non_nullable
              as double?,
      uploadMbps: freezed == uploadMbps
          ? _value.uploadMbps
          : uploadMbps // ignore: cast_nullable_to_non_nullable
              as double?,
      rtt: freezed == rtt
          ? _value.rtt
          : rtt // ignore: cast_nullable_to_non_nullable
              as double?,
      jitter: freezed == jitter
          ? _value.jitter
          : jitter // ignore: cast_nullable_to_non_nullable
              as double?,
      packetLoss: freezed == packetLoss
          ? _value.packetLoss
          : packetLoss // ignore: cast_nullable_to_non_nullable
              as double?,
      passed: null == passed
          ? _value.passed
          : passed // ignore: cast_nullable_to_non_nullable
              as bool,
      isApplicable: null == isApplicable
          ? _value.isApplicable
          : isApplicable // ignore: cast_nullable_to_non_nullable
              as bool,
      initiatedAt: freezed == initiatedAt
          ? _value.initiatedAt
          : initiatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      raw: freezed == raw
          ? _value.raw
          : raw // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      accessPointId: freezed == accessPointId
          ? _value.accessPointId
          : accessPointId // ignore: cast_nullable_to_non_nullable
              as int?,
      testedViaAccessPointId: freezed == testedViaAccessPointId
          ? _value.testedViaAccessPointId
          : testedViaAccessPointId // ignore: cast_nullable_to_non_nullable
              as int?,
      testedViaAccessPointRadioId: freezed == testedViaAccessPointRadioId
          ? _value.testedViaAccessPointRadioId
          : testedViaAccessPointRadioId // ignore: cast_nullable_to_non_nullable
              as int?,
      testedViaMediaConverterId: freezed == testedViaMediaConverterId
          ? _value.testedViaMediaConverterId
          : testedViaMediaConverterId // ignore: cast_nullable_to_non_nullable
              as int?,
      uplinkId: freezed == uplinkId
          ? _value.uplinkId
          : uplinkId // ignore: cast_nullable_to_non_nullable
              as int?,
      wlanId: freezed == wlanId
          ? _value.wlanId
          : wlanId // ignore: cast_nullable_to_non_nullable
              as int?,
      pmsRoomId: freezed == pmsRoomId
          ? _value.pmsRoomId
          : pmsRoomId // ignore: cast_nullable_to_non_nullable
              as int?,
      roomType: freezed == roomType
          ? _value.roomType
          : roomType // ignore: cast_nullable_to_non_nullable
              as String?,
      adminId: freezed == adminId
          ? _value.adminId
          : adminId // ignore: cast_nullable_to_non_nullable
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
      hasError: null == hasError
          ? _value.hasError
          : hasError // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      localIpAddress: freezed == localIpAddress
          ? _value.localIpAddress
          : localIpAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      serverHost: freezed == serverHost
          ? _value.serverHost
          : serverHost // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SpeedTestResultImpl extends _SpeedTestResult {
  const _$SpeedTestResultImpl(
      {@JsonKey(fromJson: _toInt) this.id,
      @JsonKey(name: 'speed_test_id', fromJson: _toInt) this.speedTestId,
      @JsonKey(name: 'test_type') this.testType,
      this.source,
      this.destination,
      @JsonKey(fromJson: _toInt) this.port,
      @JsonKey(name: 'iperf_protocol') this.iperfProtocol,
      @JsonKey(name: 'download_mbps', fromJson: _toDouble) this.downloadMbps,
      @JsonKey(name: 'upload_mbps', fromJson: _toDouble) this.uploadMbps,
      @JsonKey(fromJson: _toDouble) this.rtt,
      @JsonKey(fromJson: _toDouble) this.jitter,
      @JsonKey(name: 'packet_loss', fromJson: _toDouble) this.packetLoss,
      this.passed = false,
      @JsonKey(name: 'is_applicable') this.isApplicable = true,
      @JsonKey(name: 'initiated_at') this.initiatedAt,
      @JsonKey(name: 'completed_at') this.completedAt,
      this.raw,
      @JsonKey(name: 'image_url') this.imageUrl,
      @JsonKey(name: 'access_point_id', fromJson: _toInt) this.accessPointId,
      @JsonKey(name: 'tested_via_access_point_id', fromJson: _toInt)
      this.testedViaAccessPointId,
      @JsonKey(name: 'tested_via_access_point_radio_id', fromJson: _toInt)
      this.testedViaAccessPointRadioId,
      @JsonKey(name: 'tested_via_media_converter_id', fromJson: _toInt)
      this.testedViaMediaConverterId,
      @JsonKey(name: 'uplink_id', fromJson: _toInt) this.uplinkId,
      @JsonKey(name: 'wlan_id', fromJson: _toInt) this.wlanId,
      @JsonKey(name: 'pms_room_id', fromJson: _toInt) this.pmsRoomId,
      @JsonKey(name: 'room_type') this.roomType,
      @JsonKey(name: 'admin_id', fromJson: _toInt) this.adminId,
      this.note,
      this.scratch,
      @JsonKey(name: 'created_by') this.createdBy,
      @JsonKey(name: 'updated_by') this.updatedBy,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt,
      @JsonKey(includeToJson: false) this.hasError = false,
      @JsonKey(name: 'error_message', includeToJson: false) this.errorMessage,
      @JsonKey(name: 'local_ip_address') this.localIpAddress,
      @JsonKey(name: 'server_host') this.serverHost})
      : super._();

  factory _$SpeedTestResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$SpeedTestResultImplFromJson(json);

  @override
  @JsonKey(fromJson: _toInt)
  final int? id;
  @override
  @JsonKey(name: 'speed_test_id', fromJson: _toInt)
  final int? speedTestId;
  @override
  @JsonKey(name: 'test_type')
  final String? testType;
  @override
  final String? source;
  @override
  final String? destination;
  @override
  @JsonKey(fromJson: _toInt)
  final int? port;
  @override
  @JsonKey(name: 'iperf_protocol')
  final String? iperfProtocol;
  @override
  @JsonKey(name: 'download_mbps', fromJson: _toDouble)
  final double? downloadMbps;
  @override
  @JsonKey(name: 'upload_mbps', fromJson: _toDouble)
  final double? uploadMbps;
  @override
  @JsonKey(fromJson: _toDouble)
  final double? rtt;
  @override
  @JsonKey(fromJson: _toDouble)
  final double? jitter;
  @override
  @JsonKey(name: 'packet_loss', fromJson: _toDouble)
  final double? packetLoss;
  @override
  @JsonKey()
  final bool passed;
  @override
  @JsonKey(name: 'is_applicable')
  final bool isApplicable;
  @override
  @JsonKey(name: 'initiated_at')
  final DateTime? initiatedAt;
  @override
  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;
  @override
  final String? raw;
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @override
  @JsonKey(name: 'access_point_id', fromJson: _toInt)
  final int? accessPointId;
  @override
  @JsonKey(name: 'tested_via_access_point_id', fromJson: _toInt)
  final int? testedViaAccessPointId;
  @override
  @JsonKey(name: 'tested_via_access_point_radio_id', fromJson: _toInt)
  final int? testedViaAccessPointRadioId;
  @override
  @JsonKey(name: 'tested_via_media_converter_id', fromJson: _toInt)
  final int? testedViaMediaConverterId;
  @override
  @JsonKey(name: 'uplink_id', fromJson: _toInt)
  final int? uplinkId;
  @override
  @JsonKey(name: 'wlan_id', fromJson: _toInt)
  final int? wlanId;
  @override
  @JsonKey(name: 'pms_room_id', fromJson: _toInt)
  final int? pmsRoomId;
  @override
  @JsonKey(name: 'room_type')
  final String? roomType;
  @override
  @JsonKey(name: 'admin_id', fromJson: _toInt)
  final int? adminId;
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
// Legacy fields for backwards compatibility (not sent to server)
  @override
  @JsonKey(includeToJson: false)
  final bool hasError;
  @override
  @JsonKey(name: 'error_message', includeToJson: false)
  final String? errorMessage;
  @override
  @JsonKey(name: 'local_ip_address')
  final String? localIpAddress;
  @override
  @JsonKey(name: 'server_host')
  final String? serverHost;

  @override
  String toString() {
    return 'SpeedTestResult(id: $id, speedTestId: $speedTestId, testType: $testType, source: $source, destination: $destination, port: $port, iperfProtocol: $iperfProtocol, downloadMbps: $downloadMbps, uploadMbps: $uploadMbps, rtt: $rtt, jitter: $jitter, packetLoss: $packetLoss, passed: $passed, isApplicable: $isApplicable, initiatedAt: $initiatedAt, completedAt: $completedAt, raw: $raw, imageUrl: $imageUrl, accessPointId: $accessPointId, testedViaAccessPointId: $testedViaAccessPointId, testedViaAccessPointRadioId: $testedViaAccessPointRadioId, testedViaMediaConverterId: $testedViaMediaConverterId, uplinkId: $uplinkId, wlanId: $wlanId, pmsRoomId: $pmsRoomId, roomType: $roomType, adminId: $adminId, note: $note, scratch: $scratch, createdBy: $createdBy, updatedBy: $updatedBy, createdAt: $createdAt, updatedAt: $updatedAt, hasError: $hasError, errorMessage: $errorMessage, localIpAddress: $localIpAddress, serverHost: $serverHost)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SpeedTestResultImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.speedTestId, speedTestId) ||
                other.speedTestId == speedTestId) &&
            (identical(other.testType, testType) ||
                other.testType == testType) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.destination, destination) ||
                other.destination == destination) &&
            (identical(other.port, port) || other.port == port) &&
            (identical(other.iperfProtocol, iperfProtocol) ||
                other.iperfProtocol == iperfProtocol) &&
            (identical(other.downloadMbps, downloadMbps) ||
                other.downloadMbps == downloadMbps) &&
            (identical(other.uploadMbps, uploadMbps) ||
                other.uploadMbps == uploadMbps) &&
            (identical(other.rtt, rtt) || other.rtt == rtt) &&
            (identical(other.jitter, jitter) || other.jitter == jitter) &&
            (identical(other.packetLoss, packetLoss) ||
                other.packetLoss == packetLoss) &&
            (identical(other.passed, passed) || other.passed == passed) &&
            (identical(other.isApplicable, isApplicable) ||
                other.isApplicable == isApplicable) &&
            (identical(other.initiatedAt, initiatedAt) ||
                other.initiatedAt == initiatedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.raw, raw) || other.raw == raw) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.accessPointId, accessPointId) ||
                other.accessPointId == accessPointId) &&
            (identical(other.testedViaAccessPointId, testedViaAccessPointId) ||
                other.testedViaAccessPointId == testedViaAccessPointId) &&
            (identical(other.testedViaAccessPointRadioId,
                    testedViaAccessPointRadioId) ||
                other.testedViaAccessPointRadioId ==
                    testedViaAccessPointRadioId) &&
            (identical(other.testedViaMediaConverterId,
                    testedViaMediaConverterId) ||
                other.testedViaMediaConverterId == testedViaMediaConverterId) &&
            (identical(other.uplinkId, uplinkId) ||
                other.uplinkId == uplinkId) &&
            (identical(other.wlanId, wlanId) || other.wlanId == wlanId) &&
            (identical(other.pmsRoomId, pmsRoomId) ||
                other.pmsRoomId == pmsRoomId) &&
            (identical(other.roomType, roomType) ||
                other.roomType == roomType) &&
            (identical(other.adminId, adminId) || other.adminId == adminId) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.scratch, scratch) || other.scratch == scratch) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.updatedBy, updatedBy) ||
                other.updatedBy == updatedBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.hasError, hasError) ||
                other.hasError == hasError) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.localIpAddress, localIpAddress) ||
                other.localIpAddress == localIpAddress) &&
            (identical(other.serverHost, serverHost) ||
                other.serverHost == serverHost));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        speedTestId,
        testType,
        source,
        destination,
        port,
        iperfProtocol,
        downloadMbps,
        uploadMbps,
        rtt,
        jitter,
        packetLoss,
        passed,
        isApplicable,
        initiatedAt,
        completedAt,
        raw,
        imageUrl,
        accessPointId,
        testedViaAccessPointId,
        testedViaAccessPointRadioId,
        testedViaMediaConverterId,
        uplinkId,
        wlanId,
        pmsRoomId,
        roomType,
        adminId,
        note,
        scratch,
        createdBy,
        updatedBy,
        createdAt,
        updatedAt,
        hasError,
        errorMessage,
        localIpAddress,
        serverHost
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SpeedTestResultImplCopyWith<_$SpeedTestResultImpl> get copyWith =>
      __$$SpeedTestResultImplCopyWithImpl<_$SpeedTestResultImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            @JsonKey(fromJson: _toInt) int? id,
            @JsonKey(name: 'speed_test_id', fromJson: _toInt) int? speedTestId,
            @JsonKey(name: 'test_type') String? testType,
            String? source,
            String? destination,
            @JsonKey(fromJson: _toInt) int? port,
            @JsonKey(name: 'iperf_protocol') String? iperfProtocol,
            @JsonKey(name: 'download_mbps', fromJson: _toDouble)
            double? downloadMbps,
            @JsonKey(name: 'upload_mbps', fromJson: _toDouble)
            double? uploadMbps,
            @JsonKey(fromJson: _toDouble) double? rtt,
            @JsonKey(fromJson: _toDouble) double? jitter,
            @JsonKey(name: 'packet_loss', fromJson: _toDouble)
            double? packetLoss,
            bool passed,
            @JsonKey(name: 'is_applicable') bool isApplicable,
            @JsonKey(name: 'initiated_at') DateTime? initiatedAt,
            @JsonKey(name: 'completed_at') DateTime? completedAt,
            String? raw,
            @JsonKey(name: 'image_url') String? imageUrl,
            @JsonKey(name: 'access_point_id', fromJson: _toInt)
            int? accessPointId,
            @JsonKey(name: 'tested_via_access_point_id', fromJson: _toInt)
            int? testedViaAccessPointId,
            @JsonKey(name: 'tested_via_access_point_radio_id', fromJson: _toInt)
            int? testedViaAccessPointRadioId,
            @JsonKey(name: 'tested_via_media_converter_id', fromJson: _toInt)
            int? testedViaMediaConverterId,
            @JsonKey(name: 'uplink_id', fromJson: _toInt) int? uplinkId,
            @JsonKey(name: 'wlan_id', fromJson: _toInt) int? wlanId,
            @JsonKey(name: 'pms_room_id', fromJson: _toInt) int? pmsRoomId,
            @JsonKey(name: 'room_type') String? roomType,
            @JsonKey(name: 'admin_id', fromJson: _toInt) int? adminId,
            String? note,
            String? scratch,
            @JsonKey(name: 'created_by') String? createdBy,
            @JsonKey(name: 'updated_by') String? updatedBy,
            @JsonKey(name: 'created_at') DateTime? createdAt,
            @JsonKey(name: 'updated_at') DateTime? updatedAt,
            @JsonKey(includeToJson: false) bool hasError,
            @JsonKey(name: 'error_message', includeToJson: false)
            String? errorMessage,
            @JsonKey(name: 'local_ip_address') String? localIpAddress,
            @JsonKey(name: 'server_host') String? serverHost)
        $default,
  ) {
    return $default(
        id,
        speedTestId,
        testType,
        source,
        destination,
        port,
        iperfProtocol,
        downloadMbps,
        uploadMbps,
        rtt,
        jitter,
        packetLoss,
        passed,
        isApplicable,
        initiatedAt,
        completedAt,
        raw,
        imageUrl,
        accessPointId,
        testedViaAccessPointId,
        testedViaAccessPointRadioId,
        testedViaMediaConverterId,
        uplinkId,
        wlanId,
        pmsRoomId,
        roomType,
        adminId,
        note,
        scratch,
        createdBy,
        updatedBy,
        createdAt,
        updatedAt,
        hasError,
        errorMessage,
        localIpAddress,
        serverHost);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            @JsonKey(fromJson: _toInt) int? id,
            @JsonKey(name: 'speed_test_id', fromJson: _toInt) int? speedTestId,
            @JsonKey(name: 'test_type') String? testType,
            String? source,
            String? destination,
            @JsonKey(fromJson: _toInt) int? port,
            @JsonKey(name: 'iperf_protocol') String? iperfProtocol,
            @JsonKey(name: 'download_mbps', fromJson: _toDouble)
            double? downloadMbps,
            @JsonKey(name: 'upload_mbps', fromJson: _toDouble)
            double? uploadMbps,
            @JsonKey(fromJson: _toDouble) double? rtt,
            @JsonKey(fromJson: _toDouble) double? jitter,
            @JsonKey(name: 'packet_loss', fromJson: _toDouble)
            double? packetLoss,
            bool passed,
            @JsonKey(name: 'is_applicable') bool isApplicable,
            @JsonKey(name: 'initiated_at') DateTime? initiatedAt,
            @JsonKey(name: 'completed_at') DateTime? completedAt,
            String? raw,
            @JsonKey(name: 'image_url') String? imageUrl,
            @JsonKey(name: 'access_point_id', fromJson: _toInt)
            int? accessPointId,
            @JsonKey(name: 'tested_via_access_point_id', fromJson: _toInt)
            int? testedViaAccessPointId,
            @JsonKey(name: 'tested_via_access_point_radio_id', fromJson: _toInt)
            int? testedViaAccessPointRadioId,
            @JsonKey(name: 'tested_via_media_converter_id', fromJson: _toInt)
            int? testedViaMediaConverterId,
            @JsonKey(name: 'uplink_id', fromJson: _toInt) int? uplinkId,
            @JsonKey(name: 'wlan_id', fromJson: _toInt) int? wlanId,
            @JsonKey(name: 'pms_room_id', fromJson: _toInt) int? pmsRoomId,
            @JsonKey(name: 'room_type') String? roomType,
            @JsonKey(name: 'admin_id', fromJson: _toInt) int? adminId,
            String? note,
            String? scratch,
            @JsonKey(name: 'created_by') String? createdBy,
            @JsonKey(name: 'updated_by') String? updatedBy,
            @JsonKey(name: 'created_at') DateTime? createdAt,
            @JsonKey(name: 'updated_at') DateTime? updatedAt,
            @JsonKey(includeToJson: false) bool hasError,
            @JsonKey(name: 'error_message', includeToJson: false)
            String? errorMessage,
            @JsonKey(name: 'local_ip_address') String? localIpAddress,
            @JsonKey(name: 'server_host') String? serverHost)?
        $default,
  ) {
    return $default?.call(
        id,
        speedTestId,
        testType,
        source,
        destination,
        port,
        iperfProtocol,
        downloadMbps,
        uploadMbps,
        rtt,
        jitter,
        packetLoss,
        passed,
        isApplicable,
        initiatedAt,
        completedAt,
        raw,
        imageUrl,
        accessPointId,
        testedViaAccessPointId,
        testedViaAccessPointRadioId,
        testedViaMediaConverterId,
        uplinkId,
        wlanId,
        pmsRoomId,
        roomType,
        adminId,
        note,
        scratch,
        createdBy,
        updatedBy,
        createdAt,
        updatedAt,
        hasError,
        errorMessage,
        localIpAddress,
        serverHost);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            @JsonKey(fromJson: _toInt) int? id,
            @JsonKey(name: 'speed_test_id', fromJson: _toInt) int? speedTestId,
            @JsonKey(name: 'test_type') String? testType,
            String? source,
            String? destination,
            @JsonKey(fromJson: _toInt) int? port,
            @JsonKey(name: 'iperf_protocol') String? iperfProtocol,
            @JsonKey(name: 'download_mbps', fromJson: _toDouble)
            double? downloadMbps,
            @JsonKey(name: 'upload_mbps', fromJson: _toDouble)
            double? uploadMbps,
            @JsonKey(fromJson: _toDouble) double? rtt,
            @JsonKey(fromJson: _toDouble) double? jitter,
            @JsonKey(name: 'packet_loss', fromJson: _toDouble)
            double? packetLoss,
            bool passed,
            @JsonKey(name: 'is_applicable') bool isApplicable,
            @JsonKey(name: 'initiated_at') DateTime? initiatedAt,
            @JsonKey(name: 'completed_at') DateTime? completedAt,
            String? raw,
            @JsonKey(name: 'image_url') String? imageUrl,
            @JsonKey(name: 'access_point_id', fromJson: _toInt)
            int? accessPointId,
            @JsonKey(name: 'tested_via_access_point_id', fromJson: _toInt)
            int? testedViaAccessPointId,
            @JsonKey(name: 'tested_via_access_point_radio_id', fromJson: _toInt)
            int? testedViaAccessPointRadioId,
            @JsonKey(name: 'tested_via_media_converter_id', fromJson: _toInt)
            int? testedViaMediaConverterId,
            @JsonKey(name: 'uplink_id', fromJson: _toInt) int? uplinkId,
            @JsonKey(name: 'wlan_id', fromJson: _toInt) int? wlanId,
            @JsonKey(name: 'pms_room_id', fromJson: _toInt) int? pmsRoomId,
            @JsonKey(name: 'room_type') String? roomType,
            @JsonKey(name: 'admin_id', fromJson: _toInt) int? adminId,
            String? note,
            String? scratch,
            @JsonKey(name: 'created_by') String? createdBy,
            @JsonKey(name: 'updated_by') String? updatedBy,
            @JsonKey(name: 'created_at') DateTime? createdAt,
            @JsonKey(name: 'updated_at') DateTime? updatedAt,
            @JsonKey(includeToJson: false) bool hasError,
            @JsonKey(name: 'error_message', includeToJson: false)
            String? errorMessage,
            @JsonKey(name: 'local_ip_address') String? localIpAddress,
            @JsonKey(name: 'server_host') String? serverHost)?
        $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(
          id,
          speedTestId,
          testType,
          source,
          destination,
          port,
          iperfProtocol,
          downloadMbps,
          uploadMbps,
          rtt,
          jitter,
          packetLoss,
          passed,
          isApplicable,
          initiatedAt,
          completedAt,
          raw,
          imageUrl,
          accessPointId,
          testedViaAccessPointId,
          testedViaAccessPointRadioId,
          testedViaMediaConverterId,
          uplinkId,
          wlanId,
          pmsRoomId,
          roomType,
          adminId,
          note,
          scratch,
          createdBy,
          updatedBy,
          createdAt,
          updatedAt,
          hasError,
          errorMessage,
          localIpAddress,
          serverHost);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_SpeedTestResult value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_SpeedTestResult value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_SpeedTestResult value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$SpeedTestResultImplToJson(
      this,
    );
  }
}

abstract class _SpeedTestResult extends SpeedTestResult {
  const factory _SpeedTestResult(
      {@JsonKey(fromJson: _toInt) final int? id,
      @JsonKey(name: 'speed_test_id', fromJson: _toInt) final int? speedTestId,
      @JsonKey(name: 'test_type') final String? testType,
      final String? source,
      final String? destination,
      @JsonKey(fromJson: _toInt) final int? port,
      @JsonKey(name: 'iperf_protocol') final String? iperfProtocol,
      @JsonKey(name: 'download_mbps', fromJson: _toDouble)
      final double? downloadMbps,
      @JsonKey(name: 'upload_mbps', fromJson: _toDouble)
      final double? uploadMbps,
      @JsonKey(fromJson: _toDouble) final double? rtt,
      @JsonKey(fromJson: _toDouble) final double? jitter,
      @JsonKey(name: 'packet_loss', fromJson: _toDouble)
      final double? packetLoss,
      final bool passed,
      @JsonKey(name: 'is_applicable') final bool isApplicable,
      @JsonKey(name: 'initiated_at') final DateTime? initiatedAt,
      @JsonKey(name: 'completed_at') final DateTime? completedAt,
      final String? raw,
      @JsonKey(name: 'image_url') final String? imageUrl,
      @JsonKey(name: 'access_point_id', fromJson: _toInt)
      final int? accessPointId,
      @JsonKey(name: 'tested_via_access_point_id', fromJson: _toInt)
      final int? testedViaAccessPointId,
      @JsonKey(name: 'tested_via_access_point_radio_id', fromJson: _toInt)
      final int? testedViaAccessPointRadioId,
      @JsonKey(name: 'tested_via_media_converter_id', fromJson: _toInt)
      final int? testedViaMediaConverterId,
      @JsonKey(name: 'uplink_id', fromJson: _toInt) final int? uplinkId,
      @JsonKey(name: 'wlan_id', fromJson: _toInt) final int? wlanId,
      @JsonKey(name: 'pms_room_id', fromJson: _toInt) final int? pmsRoomId,
      @JsonKey(name: 'room_type') final String? roomType,
      @JsonKey(name: 'admin_id', fromJson: _toInt) final int? adminId,
      final String? note,
      final String? scratch,
      @JsonKey(name: 'created_by') final String? createdBy,
      @JsonKey(name: 'updated_by') final String? updatedBy,
      @JsonKey(name: 'created_at') final DateTime? createdAt,
      @JsonKey(name: 'updated_at') final DateTime? updatedAt,
      @JsonKey(includeToJson: false) final bool hasError,
      @JsonKey(name: 'error_message', includeToJson: false)
      final String? errorMessage,
      @JsonKey(name: 'local_ip_address') final String? localIpAddress,
      @JsonKey(name: 'server_host')
      final String? serverHost}) = _$SpeedTestResultImpl;
  const _SpeedTestResult._() : super._();

  factory _SpeedTestResult.fromJson(Map<String, dynamic> json) =
      _$SpeedTestResultImpl.fromJson;

  @override
  @JsonKey(fromJson: _toInt)
  int? get id;
  @override
  @JsonKey(name: 'speed_test_id', fromJson: _toInt)
  int? get speedTestId;
  @override
  @JsonKey(name: 'test_type')
  String? get testType;
  @override
  String? get source;
  @override
  String? get destination;
  @override
  @JsonKey(fromJson: _toInt)
  int? get port;
  @override
  @JsonKey(name: 'iperf_protocol')
  String? get iperfProtocol;
  @override
  @JsonKey(name: 'download_mbps', fromJson: _toDouble)
  double? get downloadMbps;
  @override
  @JsonKey(name: 'upload_mbps', fromJson: _toDouble)
  double? get uploadMbps;
  @override
  @JsonKey(fromJson: _toDouble)
  double? get rtt;
  @override
  @JsonKey(fromJson: _toDouble)
  double? get jitter;
  @override
  @JsonKey(name: 'packet_loss', fromJson: _toDouble)
  double? get packetLoss;
  @override
  bool get passed;
  @override
  @JsonKey(name: 'is_applicable')
  bool get isApplicable;
  @override
  @JsonKey(name: 'initiated_at')
  DateTime? get initiatedAt;
  @override
  @JsonKey(name: 'completed_at')
  DateTime? get completedAt;
  @override
  String? get raw;
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl;
  @override
  @JsonKey(name: 'access_point_id', fromJson: _toInt)
  int? get accessPointId;
  @override
  @JsonKey(name: 'tested_via_access_point_id', fromJson: _toInt)
  int? get testedViaAccessPointId;
  @override
  @JsonKey(name: 'tested_via_access_point_radio_id', fromJson: _toInt)
  int? get testedViaAccessPointRadioId;
  @override
  @JsonKey(name: 'tested_via_media_converter_id', fromJson: _toInt)
  int? get testedViaMediaConverterId;
  @override
  @JsonKey(name: 'uplink_id', fromJson: _toInt)
  int? get uplinkId;
  @override
  @JsonKey(name: 'wlan_id', fromJson: _toInt)
  int? get wlanId;
  @override
  @JsonKey(name: 'pms_room_id', fromJson: _toInt)
  int? get pmsRoomId;
  @override
  @JsonKey(name: 'room_type')
  String? get roomType;
  @override
  @JsonKey(name: 'admin_id', fromJson: _toInt)
  int? get adminId;
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
  @override // Legacy fields for backwards compatibility (not sent to server)
  @JsonKey(includeToJson: false)
  bool get hasError;
  @override
  @JsonKey(name: 'error_message', includeToJson: false)
  String? get errorMessage;
  @override
  @JsonKey(name: 'local_ip_address')
  String? get localIpAddress;
  @override
  @JsonKey(name: 'server_host')
  String? get serverHost;
  @override
  @JsonKey(ignore: true)
  _$$SpeedTestResultImplCopyWith<_$SpeedTestResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
