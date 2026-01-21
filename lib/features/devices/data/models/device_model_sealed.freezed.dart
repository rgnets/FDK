// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_model_sealed.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DeviceModelSealed _$DeviceModelSealedFromJson(Map<String, dynamic> json) {
  switch (json['device_type']) {
    case 'access_point':
      return APModel.fromJson(json);
    case 'ont':
      return ONTModel.fromJson(json);
    case 'switch':
      return SwitchModel.fromJson(json);
    case 'wlan_controller':
      return WLANModel.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'device_type', 'DeviceModelSealed',
          'Invalid union type "${json['device_type']}"!');
  }
}

/// @nodoc
mixin _$DeviceModelSealed {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'pms_room')
  RoomModel? get pmsRoom => throw _privateConstructorUsedError;
  @JsonKey(name: 'pms_room_id')
  int? get pmsRoomId => throw _privateConstructorUsedError;
  @JsonKey(name: 'ip_address')
  String? get ipAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'mac_address')
  String? get macAddress => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_seen')
  DateTime? get lastSeen => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  String? get model => throw _privateConstructorUsedError;
  @JsonKey(name: 'serial_number')
  String? get serialNumber => throw _privateConstructorUsedError;
  String? get firmware => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  List<String>? get images => throw _privateConstructorUsedError;
  @JsonKey(name: 'health_notices')
  List<HealthNoticeModel>? get healthNotices =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'hn_counts')
  HealthCountsModel? get hnCounts => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'infrastructure_link_id') int? infrastructureLinkId,
            @JsonKey(name: 'connection_state') String? connectionState,
            @JsonKey(name: 'signal_strength') int? signalStrength,
            @JsonKey(name: 'connected_clients') int? connectedClients,
            String? ssid,
            int? channel,
            @JsonKey(name: 'max_clients') int? maxClients,
            @JsonKey(name: 'current_upload') double? currentUpload,
            @JsonKey(name: 'current_download') double? currentDownload,
            @JsonKey(name: 'ap_onboarding_status')
            Map<String, dynamic>? onboardingStatus)
        ap,
    required TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'is_registered') bool? isRegistered,
            @JsonKey(name: 'switch_port') Map<String, dynamic>? switchPort,
            @JsonKey(name: 'ont_onboarding_status')
            Map<String, dynamic>? onboardingStatus,
            @JsonKey(name: 'ont_ports') List<Map<String, dynamic>>? ports,
            String? uptime,
            String? phase)
        ont,
    required TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            String? host,
            @JsonKey(name: 'switch_ports') List<Map<String, dynamic>>? ports,
            @JsonKey(name: 'last_config_sync_at') DateTime? lastConfigSync,
            @JsonKey(name: 'last_config_sync_attempt_at')
            DateTime? lastConfigSyncAttempt,
            @JsonKey(name: 'cpu_usage') int? cpuUsage,
            @JsonKey(name: 'memory_usage') int? memoryUsage,
            int? temperature)
        switchDevice,
    required TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'controller_type') String? controllerType,
            @JsonKey(name: 'managed_aps') int? managedAPs,
            int? vlan,
            @JsonKey(name: 'total_upload') int? totalUpload,
            @JsonKey(name: 'total_download') int? totalDownload,
            @JsonKey(name: 'packet_loss') double? packetLoss,
            int? latency,
            @JsonKey(name: 'restart_count') int? restartCount)
        wlan,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'infrastructure_link_id') int? infrastructureLinkId,
            @JsonKey(name: 'connection_state') String? connectionState,
            @JsonKey(name: 'signal_strength') int? signalStrength,
            @JsonKey(name: 'connected_clients') int? connectedClients,
            String? ssid,
            int? channel,
            @JsonKey(name: 'max_clients') int? maxClients,
            @JsonKey(name: 'current_upload') double? currentUpload,
            @JsonKey(name: 'current_download') double? currentDownload,
            @JsonKey(name: 'ap_onboarding_status')
            Map<String, dynamic>? onboardingStatus)?
        ap,
    TResult? Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'is_registered') bool? isRegistered,
            @JsonKey(name: 'switch_port') Map<String, dynamic>? switchPort,
            @JsonKey(name: 'ont_onboarding_status')
            Map<String, dynamic>? onboardingStatus,
            @JsonKey(name: 'ont_ports') List<Map<String, dynamic>>? ports,
            String? uptime,
            String? phase)?
        ont,
    TResult? Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            String? host,
            @JsonKey(name: 'switch_ports') List<Map<String, dynamic>>? ports,
            @JsonKey(name: 'last_config_sync_at') DateTime? lastConfigSync,
            @JsonKey(name: 'last_config_sync_attempt_at')
            DateTime? lastConfigSyncAttempt,
            @JsonKey(name: 'cpu_usage') int? cpuUsage,
            @JsonKey(name: 'memory_usage') int? memoryUsage,
            int? temperature)?
        switchDevice,
    TResult? Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'controller_type') String? controllerType,
            @JsonKey(name: 'managed_aps') int? managedAPs,
            int? vlan,
            @JsonKey(name: 'total_upload') int? totalUpload,
            @JsonKey(name: 'total_download') int? totalDownload,
            @JsonKey(name: 'packet_loss') double? packetLoss,
            int? latency,
            @JsonKey(name: 'restart_count') int? restartCount)?
        wlan,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'infrastructure_link_id') int? infrastructureLinkId,
            @JsonKey(name: 'connection_state') String? connectionState,
            @JsonKey(name: 'signal_strength') int? signalStrength,
            @JsonKey(name: 'connected_clients') int? connectedClients,
            String? ssid,
            int? channel,
            @JsonKey(name: 'max_clients') int? maxClients,
            @JsonKey(name: 'current_upload') double? currentUpload,
            @JsonKey(name: 'current_download') double? currentDownload,
            @JsonKey(name: 'ap_onboarding_status')
            Map<String, dynamic>? onboardingStatus)?
        ap,
    TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'is_registered') bool? isRegistered,
            @JsonKey(name: 'switch_port') Map<String, dynamic>? switchPort,
            @JsonKey(name: 'ont_onboarding_status')
            Map<String, dynamic>? onboardingStatus,
            @JsonKey(name: 'ont_ports') List<Map<String, dynamic>>? ports,
            String? uptime,
            String? phase)?
        ont,
    TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            String? host,
            @JsonKey(name: 'switch_ports') List<Map<String, dynamic>>? ports,
            @JsonKey(name: 'last_config_sync_at') DateTime? lastConfigSync,
            @JsonKey(name: 'last_config_sync_attempt_at')
            DateTime? lastConfigSyncAttempt,
            @JsonKey(name: 'cpu_usage') int? cpuUsage,
            @JsonKey(name: 'memory_usage') int? memoryUsage,
            int? temperature)?
        switchDevice,
    TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'controller_type') String? controllerType,
            @JsonKey(name: 'managed_aps') int? managedAPs,
            int? vlan,
            @JsonKey(name: 'total_upload') int? totalUpload,
            @JsonKey(name: 'total_download') int? totalDownload,
            @JsonKey(name: 'packet_loss') double? packetLoss,
            int? latency,
            @JsonKey(name: 'restart_count') int? restartCount)?
        wlan,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(APModel value) ap,
    required TResult Function(ONTModel value) ont,
    required TResult Function(SwitchModel value) switchDevice,
    required TResult Function(WLANModel value) wlan,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(APModel value)? ap,
    TResult? Function(ONTModel value)? ont,
    TResult? Function(SwitchModel value)? switchDevice,
    TResult? Function(WLANModel value)? wlan,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(APModel value)? ap,
    TResult Function(ONTModel value)? ont,
    TResult Function(SwitchModel value)? switchDevice,
    TResult Function(WLANModel value)? wlan,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DeviceModelSealedCopyWith<DeviceModelSealed> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeviceModelSealedCopyWith<$Res> {
  factory $DeviceModelSealedCopyWith(
          DeviceModelSealed value, $Res Function(DeviceModelSealed) then) =
      _$DeviceModelSealedCopyWithImpl<$Res, DeviceModelSealed>;
  @useResult
  $Res call(
      {String id,
      String name,
      String status,
      @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
      @JsonKey(name: 'pms_room_id') int? pmsRoomId,
      @JsonKey(name: 'ip_address') String? ipAddress,
      @JsonKey(name: 'mac_address') String? macAddress,
      String? location,
      @JsonKey(name: 'last_seen') DateTime? lastSeen,
      Map<String, dynamic>? metadata,
      String? model,
      @JsonKey(name: 'serial_number') String? serialNumber,
      String? firmware,
      String? note,
      List<String>? images,
      @JsonKey(name: 'health_notices') List<HealthNoticeModel>? healthNotices,
      @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts});

  $RoomModelCopyWith<$Res>? get pmsRoom;
  $HealthCountsModelCopyWith<$Res>? get hnCounts;
}

/// @nodoc
class _$DeviceModelSealedCopyWithImpl<$Res, $Val extends DeviceModelSealed>
    implements $DeviceModelSealedCopyWith<$Res> {
  _$DeviceModelSealedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? status = null,
    Object? pmsRoom = freezed,
    Object? pmsRoomId = freezed,
    Object? ipAddress = freezed,
    Object? macAddress = freezed,
    Object? location = freezed,
    Object? lastSeen = freezed,
    Object? metadata = freezed,
    Object? model = freezed,
    Object? serialNumber = freezed,
    Object? firmware = freezed,
    Object? note = freezed,
    Object? images = freezed,
    Object? healthNotices = freezed,
    Object? hnCounts = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      pmsRoom: freezed == pmsRoom
          ? _value.pmsRoom
          : pmsRoom // ignore: cast_nullable_to_non_nullable
              as RoomModel?,
      pmsRoomId: freezed == pmsRoomId
          ? _value.pmsRoomId
          : pmsRoomId // ignore: cast_nullable_to_non_nullable
              as int?,
      ipAddress: freezed == ipAddress
          ? _value.ipAddress
          : ipAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      macAddress: freezed == macAddress
          ? _value.macAddress
          : macAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      lastSeen: freezed == lastSeen
          ? _value.lastSeen
          : lastSeen // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      model: freezed == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String?,
      serialNumber: freezed == serialNumber
          ? _value.serialNumber
          : serialNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      firmware: freezed == firmware
          ? _value.firmware
          : firmware // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      images: freezed == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      healthNotices: freezed == healthNotices
          ? _value.healthNotices
          : healthNotices // ignore: cast_nullable_to_non_nullable
              as List<HealthNoticeModel>?,
      hnCounts: freezed == hnCounts
          ? _value.hnCounts
          : hnCounts // ignore: cast_nullable_to_non_nullable
              as HealthCountsModel?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $RoomModelCopyWith<$Res>? get pmsRoom {
    if (_value.pmsRoom == null) {
      return null;
    }

    return $RoomModelCopyWith<$Res>(_value.pmsRoom!, (value) {
      return _then(_value.copyWith(pmsRoom: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $HealthCountsModelCopyWith<$Res>? get hnCounts {
    if (_value.hnCounts == null) {
      return null;
    }

    return $HealthCountsModelCopyWith<$Res>(_value.hnCounts!, (value) {
      return _then(_value.copyWith(hnCounts: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$APModelImplCopyWith<$Res>
    implements $DeviceModelSealedCopyWith<$Res> {
  factory _$$APModelImplCopyWith(
          _$APModelImpl value, $Res Function(_$APModelImpl) then) =
      __$$APModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String status,
      @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
      @JsonKey(name: 'pms_room_id') int? pmsRoomId,
      @JsonKey(name: 'ip_address') String? ipAddress,
      @JsonKey(name: 'mac_address') String? macAddress,
      String? location,
      @JsonKey(name: 'last_seen') DateTime? lastSeen,
      Map<String, dynamic>? metadata,
      String? model,
      @JsonKey(name: 'serial_number') String? serialNumber,
      String? firmware,
      String? note,
      List<String>? images,
      @JsonKey(name: 'health_notices') List<HealthNoticeModel>? healthNotices,
      @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
      @JsonKey(name: 'infrastructure_link_id') int? infrastructureLinkId,
      @JsonKey(name: 'connection_state') String? connectionState,
      @JsonKey(name: 'signal_strength') int? signalStrength,
      @JsonKey(name: 'connected_clients') int? connectedClients,
      String? ssid,
      int? channel,
      @JsonKey(name: 'max_clients') int? maxClients,
      @JsonKey(name: 'current_upload') double? currentUpload,
      @JsonKey(name: 'current_download') double? currentDownload,
      @JsonKey(name: 'ap_onboarding_status')
      Map<String, dynamic>? onboardingStatus});

  @override
  $RoomModelCopyWith<$Res>? get pmsRoom;
  @override
  $HealthCountsModelCopyWith<$Res>? get hnCounts;
}

/// @nodoc
class __$$APModelImplCopyWithImpl<$Res>
    extends _$DeviceModelSealedCopyWithImpl<$Res, _$APModelImpl>
    implements _$$APModelImplCopyWith<$Res> {
  __$$APModelImplCopyWithImpl(
      _$APModelImpl _value, $Res Function(_$APModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? status = null,
    Object? pmsRoom = freezed,
    Object? pmsRoomId = freezed,
    Object? ipAddress = freezed,
    Object? macAddress = freezed,
    Object? location = freezed,
    Object? lastSeen = freezed,
    Object? metadata = freezed,
    Object? model = freezed,
    Object? serialNumber = freezed,
    Object? firmware = freezed,
    Object? note = freezed,
    Object? images = freezed,
    Object? healthNotices = freezed,
    Object? hnCounts = freezed,
    Object? infrastructureLinkId = freezed,
    Object? connectionState = freezed,
    Object? signalStrength = freezed,
    Object? connectedClients = freezed,
    Object? ssid = freezed,
    Object? channel = freezed,
    Object? maxClients = freezed,
    Object? currentUpload = freezed,
    Object? currentDownload = freezed,
    Object? onboardingStatus = freezed,
  }) {
    return _then(_$APModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      pmsRoom: freezed == pmsRoom
          ? _value.pmsRoom
          : pmsRoom // ignore: cast_nullable_to_non_nullable
              as RoomModel?,
      pmsRoomId: freezed == pmsRoomId
          ? _value.pmsRoomId
          : pmsRoomId // ignore: cast_nullable_to_non_nullable
              as int?,
      ipAddress: freezed == ipAddress
          ? _value.ipAddress
          : ipAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      macAddress: freezed == macAddress
          ? _value.macAddress
          : macAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      lastSeen: freezed == lastSeen
          ? _value.lastSeen
          : lastSeen // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      model: freezed == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String?,
      serialNumber: freezed == serialNumber
          ? _value.serialNumber
          : serialNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      firmware: freezed == firmware
          ? _value.firmware
          : firmware // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      images: freezed == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      healthNotices: freezed == healthNotices
          ? _value._healthNotices
          : healthNotices // ignore: cast_nullable_to_non_nullable
              as List<HealthNoticeModel>?,
      hnCounts: freezed == hnCounts
          ? _value.hnCounts
          : hnCounts // ignore: cast_nullable_to_non_nullable
              as HealthCountsModel?,
      infrastructureLinkId: freezed == infrastructureLinkId
          ? _value.infrastructureLinkId
          : infrastructureLinkId // ignore: cast_nullable_to_non_nullable
              as int?,
      connectionState: freezed == connectionState
          ? _value.connectionState
          : connectionState // ignore: cast_nullable_to_non_nullable
              as String?,
      signalStrength: freezed == signalStrength
          ? _value.signalStrength
          : signalStrength // ignore: cast_nullable_to_non_nullable
              as int?,
      connectedClients: freezed == connectedClients
          ? _value.connectedClients
          : connectedClients // ignore: cast_nullable_to_non_nullable
              as int?,
      ssid: freezed == ssid
          ? _value.ssid
          : ssid // ignore: cast_nullable_to_non_nullable
              as String?,
      channel: freezed == channel
          ? _value.channel
          : channel // ignore: cast_nullable_to_non_nullable
              as int?,
      maxClients: freezed == maxClients
          ? _value.maxClients
          : maxClients // ignore: cast_nullable_to_non_nullable
              as int?,
      currentUpload: freezed == currentUpload
          ? _value.currentUpload
          : currentUpload // ignore: cast_nullable_to_non_nullable
              as double?,
      currentDownload: freezed == currentDownload
          ? _value.currentDownload
          : currentDownload // ignore: cast_nullable_to_non_nullable
              as double?,
      onboardingStatus: freezed == onboardingStatus
          ? _value._onboardingStatus
          : onboardingStatus // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$APModelImpl extends APModel {
  const _$APModelImpl(
      {required this.id,
      required this.name,
      required this.status,
      @JsonKey(name: 'pms_room') this.pmsRoom,
      @JsonKey(name: 'pms_room_id') this.pmsRoomId,
      @JsonKey(name: 'ip_address') this.ipAddress,
      @JsonKey(name: 'mac_address') this.macAddress,
      this.location,
      @JsonKey(name: 'last_seen') this.lastSeen,
      final Map<String, dynamic>? metadata,
      this.model,
      @JsonKey(name: 'serial_number') this.serialNumber,
      this.firmware,
      this.note,
      final List<String>? images,
      @JsonKey(name: 'health_notices')
      final List<HealthNoticeModel>? healthNotices,
      @JsonKey(name: 'hn_counts') this.hnCounts,
      @JsonKey(name: 'infrastructure_link_id') this.infrastructureLinkId,
      @JsonKey(name: 'connection_state') this.connectionState,
      @JsonKey(name: 'signal_strength') this.signalStrength,
      @JsonKey(name: 'connected_clients') this.connectedClients,
      this.ssid,
      this.channel,
      @JsonKey(name: 'max_clients') this.maxClients,
      @JsonKey(name: 'current_upload') this.currentUpload,
      @JsonKey(name: 'current_download') this.currentDownload,
      @JsonKey(name: 'ap_onboarding_status')
      final Map<String, dynamic>? onboardingStatus,
      final String? $type})
      : _metadata = metadata,
        _images = images,
        _healthNotices = healthNotices,
        _onboardingStatus = onboardingStatus,
        $type = $type ?? 'access_point',
        super._();

  factory _$APModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$APModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String status;
  @override
  @JsonKey(name: 'pms_room')
  final RoomModel? pmsRoom;
  @override
  @JsonKey(name: 'pms_room_id')
  final int? pmsRoomId;
  @override
  @JsonKey(name: 'ip_address')
  final String? ipAddress;
  @override
  @JsonKey(name: 'mac_address')
  final String? macAddress;
  @override
  final String? location;
  @override
  @JsonKey(name: 'last_seen')
  final DateTime? lastSeen;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? model;
  @override
  @JsonKey(name: 'serial_number')
  final String? serialNumber;
  @override
  final String? firmware;
  @override
  final String? note;
  final List<String>? _images;
  @override
  List<String>? get images {
    final value = _images;
    if (value == null) return null;
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<HealthNoticeModel>? _healthNotices;
  @override
  @JsonKey(name: 'health_notices')
  List<HealthNoticeModel>? get healthNotices {
    final value = _healthNotices;
    if (value == null) return null;
    if (_healthNotices is EqualUnmodifiableListView) return _healthNotices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'hn_counts')
  final HealthCountsModel? hnCounts;
  @override
  @JsonKey(name: 'infrastructure_link_id')
  final int? infrastructureLinkId;
  @override
  @JsonKey(name: 'connection_state')
  final String? connectionState;
  @override
  @JsonKey(name: 'signal_strength')
  final int? signalStrength;
  @override
  @JsonKey(name: 'connected_clients')
  final int? connectedClients;
  @override
  final String? ssid;
  @override
  final int? channel;
  @override
  @JsonKey(name: 'max_clients')
  final int? maxClients;
  @override
  @JsonKey(name: 'current_upload')
  final double? currentUpload;
  @override
  @JsonKey(name: 'current_download')
  final double? currentDownload;
  final Map<String, dynamic>? _onboardingStatus;
  @override
  @JsonKey(name: 'ap_onboarding_status')
  Map<String, dynamic>? get onboardingStatus {
    final value = _onboardingStatus;
    if (value == null) return null;
    if (_onboardingStatus is EqualUnmodifiableMapView) return _onboardingStatus;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @JsonKey(name: 'device_type')
  final String $type;

  @override
  String toString() {
    return 'DeviceModelSealed.ap(id: $id, name: $name, status: $status, pmsRoom: $pmsRoom, pmsRoomId: $pmsRoomId, ipAddress: $ipAddress, macAddress: $macAddress, location: $location, lastSeen: $lastSeen, metadata: $metadata, model: $model, serialNumber: $serialNumber, firmware: $firmware, note: $note, images: $images, healthNotices: $healthNotices, hnCounts: $hnCounts, infrastructureLinkId: $infrastructureLinkId, connectionState: $connectionState, signalStrength: $signalStrength, connectedClients: $connectedClients, ssid: $ssid, channel: $channel, maxClients: $maxClients, currentUpload: $currentUpload, currentDownload: $currentDownload, onboardingStatus: $onboardingStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$APModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.pmsRoom, pmsRoom) || other.pmsRoom == pmsRoom) &&
            (identical(other.pmsRoomId, pmsRoomId) ||
                other.pmsRoomId == pmsRoomId) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            (identical(other.macAddress, macAddress) ||
                other.macAddress == macAddress) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.lastSeen, lastSeen) ||
                other.lastSeen == lastSeen) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.serialNumber, serialNumber) ||
                other.serialNumber == serialNumber) &&
            (identical(other.firmware, firmware) ||
                other.firmware == firmware) &&
            (identical(other.note, note) || other.note == note) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            const DeepCollectionEquality()
                .equals(other._healthNotices, _healthNotices) &&
            (identical(other.hnCounts, hnCounts) ||
                other.hnCounts == hnCounts) &&
            (identical(other.infrastructureLinkId, infrastructureLinkId) ||
                other.infrastructureLinkId == infrastructureLinkId) &&
            (identical(other.connectionState, connectionState) ||
                other.connectionState == connectionState) &&
            (identical(other.signalStrength, signalStrength) ||
                other.signalStrength == signalStrength) &&
            (identical(other.connectedClients, connectedClients) ||
                other.connectedClients == connectedClients) &&
            (identical(other.ssid, ssid) || other.ssid == ssid) &&
            (identical(other.channel, channel) || other.channel == channel) &&
            (identical(other.maxClients, maxClients) ||
                other.maxClients == maxClients) &&
            (identical(other.currentUpload, currentUpload) ||
                other.currentUpload == currentUpload) &&
            (identical(other.currentDownload, currentDownload) ||
                other.currentDownload == currentDownload) &&
            const DeepCollectionEquality()
                .equals(other._onboardingStatus, _onboardingStatus));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        status,
        pmsRoom,
        pmsRoomId,
        ipAddress,
        macAddress,
        location,
        lastSeen,
        const DeepCollectionEquality().hash(_metadata),
        model,
        serialNumber,
        firmware,
        note,
        const DeepCollectionEquality().hash(_images),
        const DeepCollectionEquality().hash(_healthNotices),
        hnCounts,
        infrastructureLinkId,
        connectionState,
        signalStrength,
        connectedClients,
        ssid,
        channel,
        maxClients,
        currentUpload,
        currentDownload,
        const DeepCollectionEquality().hash(_onboardingStatus)
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$APModelImplCopyWith<_$APModelImpl> get copyWith =>
      __$$APModelImplCopyWithImpl<_$APModelImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'infrastructure_link_id') int? infrastructureLinkId,
            @JsonKey(name: 'connection_state') String? connectionState,
            @JsonKey(name: 'signal_strength') int? signalStrength,
            @JsonKey(name: 'connected_clients') int? connectedClients,
            String? ssid,
            int? channel,
            @JsonKey(name: 'max_clients') int? maxClients,
            @JsonKey(name: 'current_upload') double? currentUpload,
            @JsonKey(name: 'current_download') double? currentDownload,
            @JsonKey(name: 'ap_onboarding_status')
            Map<String, dynamic>? onboardingStatus)
        ap,
    required TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'is_registered') bool? isRegistered,
            @JsonKey(name: 'switch_port') Map<String, dynamic>? switchPort,
            @JsonKey(name: 'ont_onboarding_status')
            Map<String, dynamic>? onboardingStatus,
            @JsonKey(name: 'ont_ports') List<Map<String, dynamic>>? ports,
            String? uptime,
            String? phase)
        ont,
    required TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            String? host,
            @JsonKey(name: 'switch_ports') List<Map<String, dynamic>>? ports,
            @JsonKey(name: 'last_config_sync_at') DateTime? lastConfigSync,
            @JsonKey(name: 'last_config_sync_attempt_at')
            DateTime? lastConfigSyncAttempt,
            @JsonKey(name: 'cpu_usage') int? cpuUsage,
            @JsonKey(name: 'memory_usage') int? memoryUsage,
            int? temperature)
        switchDevice,
    required TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'controller_type') String? controllerType,
            @JsonKey(name: 'managed_aps') int? managedAPs,
            int? vlan,
            @JsonKey(name: 'total_upload') int? totalUpload,
            @JsonKey(name: 'total_download') int? totalDownload,
            @JsonKey(name: 'packet_loss') double? packetLoss,
            int? latency,
            @JsonKey(name: 'restart_count') int? restartCount)
        wlan,
  }) {
    return ap(
        id,
        name,
        status,
        pmsRoom,
        pmsRoomId,
        ipAddress,
        macAddress,
        location,
        lastSeen,
        metadata,
        model,
        serialNumber,
        firmware,
        note,
        images,
        healthNotices,
        hnCounts,
        infrastructureLinkId,
        connectionState,
        signalStrength,
        connectedClients,
        ssid,
        channel,
        maxClients,
        currentUpload,
        currentDownload,
        onboardingStatus);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'infrastructure_link_id') int? infrastructureLinkId,
            @JsonKey(name: 'connection_state') String? connectionState,
            @JsonKey(name: 'signal_strength') int? signalStrength,
            @JsonKey(name: 'connected_clients') int? connectedClients,
            String? ssid,
            int? channel,
            @JsonKey(name: 'max_clients') int? maxClients,
            @JsonKey(name: 'current_upload') double? currentUpload,
            @JsonKey(name: 'current_download') double? currentDownload,
            @JsonKey(name: 'ap_onboarding_status')
            Map<String, dynamic>? onboardingStatus)?
        ap,
    TResult? Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'is_registered') bool? isRegistered,
            @JsonKey(name: 'switch_port') Map<String, dynamic>? switchPort,
            @JsonKey(name: 'ont_onboarding_status')
            Map<String, dynamic>? onboardingStatus,
            @JsonKey(name: 'ont_ports') List<Map<String, dynamic>>? ports,
            String? uptime,
            String? phase)?
        ont,
    TResult? Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            String? host,
            @JsonKey(name: 'switch_ports') List<Map<String, dynamic>>? ports,
            @JsonKey(name: 'last_config_sync_at') DateTime? lastConfigSync,
            @JsonKey(name: 'last_config_sync_attempt_at')
            DateTime? lastConfigSyncAttempt,
            @JsonKey(name: 'cpu_usage') int? cpuUsage,
            @JsonKey(name: 'memory_usage') int? memoryUsage,
            int? temperature)?
        switchDevice,
    TResult? Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'controller_type') String? controllerType,
            @JsonKey(name: 'managed_aps') int? managedAPs,
            int? vlan,
            @JsonKey(name: 'total_upload') int? totalUpload,
            @JsonKey(name: 'total_download') int? totalDownload,
            @JsonKey(name: 'packet_loss') double? packetLoss,
            int? latency,
            @JsonKey(name: 'restart_count') int? restartCount)?
        wlan,
  }) {
    return ap?.call(
        id,
        name,
        status,
        pmsRoom,
        pmsRoomId,
        ipAddress,
        macAddress,
        location,
        lastSeen,
        metadata,
        model,
        serialNumber,
        firmware,
        note,
        images,
        healthNotices,
        hnCounts,
        infrastructureLinkId,
        connectionState,
        signalStrength,
        connectedClients,
        ssid,
        channel,
        maxClients,
        currentUpload,
        currentDownload,
        onboardingStatus);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'infrastructure_link_id') int? infrastructureLinkId,
            @JsonKey(name: 'connection_state') String? connectionState,
            @JsonKey(name: 'signal_strength') int? signalStrength,
            @JsonKey(name: 'connected_clients') int? connectedClients,
            String? ssid,
            int? channel,
            @JsonKey(name: 'max_clients') int? maxClients,
            @JsonKey(name: 'current_upload') double? currentUpload,
            @JsonKey(name: 'current_download') double? currentDownload,
            @JsonKey(name: 'ap_onboarding_status')
            Map<String, dynamic>? onboardingStatus)?
        ap,
    TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'is_registered') bool? isRegistered,
            @JsonKey(name: 'switch_port') Map<String, dynamic>? switchPort,
            @JsonKey(name: 'ont_onboarding_status')
            Map<String, dynamic>? onboardingStatus,
            @JsonKey(name: 'ont_ports') List<Map<String, dynamic>>? ports,
            String? uptime,
            String? phase)?
        ont,
    TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            String? host,
            @JsonKey(name: 'switch_ports') List<Map<String, dynamic>>? ports,
            @JsonKey(name: 'last_config_sync_at') DateTime? lastConfigSync,
            @JsonKey(name: 'last_config_sync_attempt_at')
            DateTime? lastConfigSyncAttempt,
            @JsonKey(name: 'cpu_usage') int? cpuUsage,
            @JsonKey(name: 'memory_usage') int? memoryUsage,
            int? temperature)?
        switchDevice,
    TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'controller_type') String? controllerType,
            @JsonKey(name: 'managed_aps') int? managedAPs,
            int? vlan,
            @JsonKey(name: 'total_upload') int? totalUpload,
            @JsonKey(name: 'total_download') int? totalDownload,
            @JsonKey(name: 'packet_loss') double? packetLoss,
            int? latency,
            @JsonKey(name: 'restart_count') int? restartCount)?
        wlan,
    required TResult orElse(),
  }) {
    if (ap != null) {
      return ap(
          id,
          name,
          status,
          pmsRoom,
          pmsRoomId,
          ipAddress,
          macAddress,
          location,
          lastSeen,
          metadata,
          model,
          serialNumber,
          firmware,
          note,
          images,
          healthNotices,
          hnCounts,
          infrastructureLinkId,
          connectionState,
          signalStrength,
          connectedClients,
          ssid,
          channel,
          maxClients,
          currentUpload,
          currentDownload,
          onboardingStatus);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(APModel value) ap,
    required TResult Function(ONTModel value) ont,
    required TResult Function(SwitchModel value) switchDevice,
    required TResult Function(WLANModel value) wlan,
  }) {
    return ap(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(APModel value)? ap,
    TResult? Function(ONTModel value)? ont,
    TResult? Function(SwitchModel value)? switchDevice,
    TResult? Function(WLANModel value)? wlan,
  }) {
    return ap?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(APModel value)? ap,
    TResult Function(ONTModel value)? ont,
    TResult Function(SwitchModel value)? switchDevice,
    TResult Function(WLANModel value)? wlan,
    required TResult orElse(),
  }) {
    if (ap != null) {
      return ap(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$APModelImplToJson(
      this,
    );
  }
}

abstract class APModel extends DeviceModelSealed {
  const factory APModel(
      {required final String id,
      required final String name,
      required final String status,
      @JsonKey(name: 'pms_room') final RoomModel? pmsRoom,
      @JsonKey(name: 'pms_room_id') final int? pmsRoomId,
      @JsonKey(name: 'ip_address') final String? ipAddress,
      @JsonKey(name: 'mac_address') final String? macAddress,
      final String? location,
      @JsonKey(name: 'last_seen') final DateTime? lastSeen,
      final Map<String, dynamic>? metadata,
      final String? model,
      @JsonKey(name: 'serial_number') final String? serialNumber,
      final String? firmware,
      final String? note,
      final List<String>? images,
      @JsonKey(name: 'health_notices')
      final List<HealthNoticeModel>? healthNotices,
      @JsonKey(name: 'hn_counts') final HealthCountsModel? hnCounts,
      @JsonKey(name: 'infrastructure_link_id') final int? infrastructureLinkId,
      @JsonKey(name: 'connection_state') final String? connectionState,
      @JsonKey(name: 'signal_strength') final int? signalStrength,
      @JsonKey(name: 'connected_clients') final int? connectedClients,
      final String? ssid,
      final int? channel,
      @JsonKey(name: 'max_clients') final int? maxClients,
      @JsonKey(name: 'current_upload') final double? currentUpload,
      @JsonKey(name: 'current_download') final double? currentDownload,
      @JsonKey(name: 'ap_onboarding_status')
      final Map<String, dynamic>? onboardingStatus}) = _$APModelImpl;
  const APModel._() : super._();

  factory APModel.fromJson(Map<String, dynamic> json) = _$APModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get status;
  @override
  @JsonKey(name: 'pms_room')
  RoomModel? get pmsRoom;
  @override
  @JsonKey(name: 'pms_room_id')
  int? get pmsRoomId;
  @override
  @JsonKey(name: 'ip_address')
  String? get ipAddress;
  @override
  @JsonKey(name: 'mac_address')
  String? get macAddress;
  @override
  String? get location;
  @override
  @JsonKey(name: 'last_seen')
  DateTime? get lastSeen;
  @override
  Map<String, dynamic>? get metadata;
  @override
  String? get model;
  @override
  @JsonKey(name: 'serial_number')
  String? get serialNumber;
  @override
  String? get firmware;
  @override
  String? get note;
  @override
  List<String>? get images;
  @override
  @JsonKey(name: 'health_notices')
  List<HealthNoticeModel>? get healthNotices;
  @override
  @JsonKey(name: 'hn_counts')
  HealthCountsModel? get hnCounts;
  @JsonKey(name: 'infrastructure_link_id')
  int? get infrastructureLinkId;
  @JsonKey(name: 'connection_state')
  String? get connectionState;
  @JsonKey(name: 'signal_strength')
  int? get signalStrength;
  @JsonKey(name: 'connected_clients')
  int? get connectedClients;
  String? get ssid;
  int? get channel;
  @JsonKey(name: 'max_clients')
  int? get maxClients;
  @JsonKey(name: 'current_upload')
  double? get currentUpload;
  @JsonKey(name: 'current_download')
  double? get currentDownload;
  @JsonKey(name: 'ap_onboarding_status')
  Map<String, dynamic>? get onboardingStatus;
  @override
  @JsonKey(ignore: true)
  _$$APModelImplCopyWith<_$APModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ONTModelImplCopyWith<$Res>
    implements $DeviceModelSealedCopyWith<$Res> {
  factory _$$ONTModelImplCopyWith(
          _$ONTModelImpl value, $Res Function(_$ONTModelImpl) then) =
      __$$ONTModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String status,
      @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
      @JsonKey(name: 'pms_room_id') int? pmsRoomId,
      @JsonKey(name: 'ip_address') String? ipAddress,
      @JsonKey(name: 'mac_address') String? macAddress,
      String? location,
      @JsonKey(name: 'last_seen') DateTime? lastSeen,
      Map<String, dynamic>? metadata,
      String? model,
      @JsonKey(name: 'serial_number') String? serialNumber,
      String? firmware,
      String? note,
      List<String>? images,
      @JsonKey(name: 'health_notices') List<HealthNoticeModel>? healthNotices,
      @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
      @JsonKey(name: 'is_registered') bool? isRegistered,
      @JsonKey(name: 'switch_port') Map<String, dynamic>? switchPort,
      @JsonKey(name: 'ont_onboarding_status')
      Map<String, dynamic>? onboardingStatus,
      @JsonKey(name: 'ont_ports') List<Map<String, dynamic>>? ports,
      String? uptime,
      String? phase});

  @override
  $RoomModelCopyWith<$Res>? get pmsRoom;
  @override
  $HealthCountsModelCopyWith<$Res>? get hnCounts;
}

/// @nodoc
class __$$ONTModelImplCopyWithImpl<$Res>
    extends _$DeviceModelSealedCopyWithImpl<$Res, _$ONTModelImpl>
    implements _$$ONTModelImplCopyWith<$Res> {
  __$$ONTModelImplCopyWithImpl(
      _$ONTModelImpl _value, $Res Function(_$ONTModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? status = null,
    Object? pmsRoom = freezed,
    Object? pmsRoomId = freezed,
    Object? ipAddress = freezed,
    Object? macAddress = freezed,
    Object? location = freezed,
    Object? lastSeen = freezed,
    Object? metadata = freezed,
    Object? model = freezed,
    Object? serialNumber = freezed,
    Object? firmware = freezed,
    Object? note = freezed,
    Object? images = freezed,
    Object? healthNotices = freezed,
    Object? hnCounts = freezed,
    Object? isRegistered = freezed,
    Object? switchPort = freezed,
    Object? onboardingStatus = freezed,
    Object? ports = freezed,
    Object? uptime = freezed,
    Object? phase = freezed,
  }) {
    return _then(_$ONTModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      pmsRoom: freezed == pmsRoom
          ? _value.pmsRoom
          : pmsRoom // ignore: cast_nullable_to_non_nullable
              as RoomModel?,
      pmsRoomId: freezed == pmsRoomId
          ? _value.pmsRoomId
          : pmsRoomId // ignore: cast_nullable_to_non_nullable
              as int?,
      ipAddress: freezed == ipAddress
          ? _value.ipAddress
          : ipAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      macAddress: freezed == macAddress
          ? _value.macAddress
          : macAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      lastSeen: freezed == lastSeen
          ? _value.lastSeen
          : lastSeen // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      model: freezed == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String?,
      serialNumber: freezed == serialNumber
          ? _value.serialNumber
          : serialNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      firmware: freezed == firmware
          ? _value.firmware
          : firmware // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      images: freezed == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      healthNotices: freezed == healthNotices
          ? _value._healthNotices
          : healthNotices // ignore: cast_nullable_to_non_nullable
              as List<HealthNoticeModel>?,
      hnCounts: freezed == hnCounts
          ? _value.hnCounts
          : hnCounts // ignore: cast_nullable_to_non_nullable
              as HealthCountsModel?,
      isRegistered: freezed == isRegistered
          ? _value.isRegistered
          : isRegistered // ignore: cast_nullable_to_non_nullable
              as bool?,
      switchPort: freezed == switchPort
          ? _value._switchPort
          : switchPort // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      onboardingStatus: freezed == onboardingStatus
          ? _value._onboardingStatus
          : onboardingStatus // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      ports: freezed == ports
          ? _value._ports
          : ports // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>?,
      uptime: freezed == uptime
          ? _value.uptime
          : uptime // ignore: cast_nullable_to_non_nullable
              as String?,
      phase: freezed == phase
          ? _value.phase
          : phase // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ONTModelImpl extends ONTModel {
  const _$ONTModelImpl(
      {required this.id,
      required this.name,
      required this.status,
      @JsonKey(name: 'pms_room') this.pmsRoom,
      @JsonKey(name: 'pms_room_id') this.pmsRoomId,
      @JsonKey(name: 'ip_address') this.ipAddress,
      @JsonKey(name: 'mac_address') this.macAddress,
      this.location,
      @JsonKey(name: 'last_seen') this.lastSeen,
      final Map<String, dynamic>? metadata,
      this.model,
      @JsonKey(name: 'serial_number') this.serialNumber,
      this.firmware,
      this.note,
      final List<String>? images,
      @JsonKey(name: 'health_notices')
      final List<HealthNoticeModel>? healthNotices,
      @JsonKey(name: 'hn_counts') this.hnCounts,
      @JsonKey(name: 'is_registered') this.isRegistered,
      @JsonKey(name: 'switch_port') final Map<String, dynamic>? switchPort,
      @JsonKey(name: 'ont_onboarding_status')
      final Map<String, dynamic>? onboardingStatus,
      @JsonKey(name: 'ont_ports') final List<Map<String, dynamic>>? ports,
      this.uptime,
      this.phase,
      final String? $type})
      : _metadata = metadata,
        _images = images,
        _healthNotices = healthNotices,
        _switchPort = switchPort,
        _onboardingStatus = onboardingStatus,
        _ports = ports,
        $type = $type ?? 'ont',
        super._();

  factory _$ONTModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ONTModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String status;
  @override
  @JsonKey(name: 'pms_room')
  final RoomModel? pmsRoom;
  @override
  @JsonKey(name: 'pms_room_id')
  final int? pmsRoomId;
  @override
  @JsonKey(name: 'ip_address')
  final String? ipAddress;
  @override
  @JsonKey(name: 'mac_address')
  final String? macAddress;
  @override
  final String? location;
  @override
  @JsonKey(name: 'last_seen')
  final DateTime? lastSeen;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? model;
  @override
  @JsonKey(name: 'serial_number')
  final String? serialNumber;
  @override
  final String? firmware;
  @override
  final String? note;
  final List<String>? _images;
  @override
  List<String>? get images {
    final value = _images;
    if (value == null) return null;
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<HealthNoticeModel>? _healthNotices;
  @override
  @JsonKey(name: 'health_notices')
  List<HealthNoticeModel>? get healthNotices {
    final value = _healthNotices;
    if (value == null) return null;
    if (_healthNotices is EqualUnmodifiableListView) return _healthNotices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'hn_counts')
  final HealthCountsModel? hnCounts;
  @override
  @JsonKey(name: 'is_registered')
  final bool? isRegistered;
  final Map<String, dynamic>? _switchPort;
  @override
  @JsonKey(name: 'switch_port')
  Map<String, dynamic>? get switchPort {
    final value = _switchPort;
    if (value == null) return null;
    if (_switchPort is EqualUnmodifiableMapView) return _switchPort;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _onboardingStatus;
  @override
  @JsonKey(name: 'ont_onboarding_status')
  Map<String, dynamic>? get onboardingStatus {
    final value = _onboardingStatus;
    if (value == null) return null;
    if (_onboardingStatus is EqualUnmodifiableMapView) return _onboardingStatus;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final List<Map<String, dynamic>>? _ports;
  @override
  @JsonKey(name: 'ont_ports')
  List<Map<String, dynamic>>? get ports {
    final value = _ports;
    if (value == null) return null;
    if (_ports is EqualUnmodifiableListView) return _ports;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? uptime;
  @override
  final String? phase;

  @JsonKey(name: 'device_type')
  final String $type;

  @override
  String toString() {
    return 'DeviceModelSealed.ont(id: $id, name: $name, status: $status, pmsRoom: $pmsRoom, pmsRoomId: $pmsRoomId, ipAddress: $ipAddress, macAddress: $macAddress, location: $location, lastSeen: $lastSeen, metadata: $metadata, model: $model, serialNumber: $serialNumber, firmware: $firmware, note: $note, images: $images, healthNotices: $healthNotices, hnCounts: $hnCounts, isRegistered: $isRegistered, switchPort: $switchPort, onboardingStatus: $onboardingStatus, ports: $ports, uptime: $uptime, phase: $phase)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ONTModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.pmsRoom, pmsRoom) || other.pmsRoom == pmsRoom) &&
            (identical(other.pmsRoomId, pmsRoomId) ||
                other.pmsRoomId == pmsRoomId) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            (identical(other.macAddress, macAddress) ||
                other.macAddress == macAddress) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.lastSeen, lastSeen) ||
                other.lastSeen == lastSeen) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.serialNumber, serialNumber) ||
                other.serialNumber == serialNumber) &&
            (identical(other.firmware, firmware) ||
                other.firmware == firmware) &&
            (identical(other.note, note) || other.note == note) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            const DeepCollectionEquality()
                .equals(other._healthNotices, _healthNotices) &&
            (identical(other.hnCounts, hnCounts) ||
                other.hnCounts == hnCounts) &&
            (identical(other.isRegistered, isRegistered) ||
                other.isRegistered == isRegistered) &&
            const DeepCollectionEquality()
                .equals(other._switchPort, _switchPort) &&
            const DeepCollectionEquality()
                .equals(other._onboardingStatus, _onboardingStatus) &&
            const DeepCollectionEquality().equals(other._ports, _ports) &&
            (identical(other.uptime, uptime) || other.uptime == uptime) &&
            (identical(other.phase, phase) || other.phase == phase));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        status,
        pmsRoom,
        pmsRoomId,
        ipAddress,
        macAddress,
        location,
        lastSeen,
        const DeepCollectionEquality().hash(_metadata),
        model,
        serialNumber,
        firmware,
        note,
        const DeepCollectionEquality().hash(_images),
        const DeepCollectionEquality().hash(_healthNotices),
        hnCounts,
        isRegistered,
        const DeepCollectionEquality().hash(_switchPort),
        const DeepCollectionEquality().hash(_onboardingStatus),
        const DeepCollectionEquality().hash(_ports),
        uptime,
        phase
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ONTModelImplCopyWith<_$ONTModelImpl> get copyWith =>
      __$$ONTModelImplCopyWithImpl<_$ONTModelImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'infrastructure_link_id') int? infrastructureLinkId,
            @JsonKey(name: 'connection_state') String? connectionState,
            @JsonKey(name: 'signal_strength') int? signalStrength,
            @JsonKey(name: 'connected_clients') int? connectedClients,
            String? ssid,
            int? channel,
            @JsonKey(name: 'max_clients') int? maxClients,
            @JsonKey(name: 'current_upload') double? currentUpload,
            @JsonKey(name: 'current_download') double? currentDownload,
            @JsonKey(name: 'ap_onboarding_status')
            Map<String, dynamic>? onboardingStatus)
        ap,
    required TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'is_registered') bool? isRegistered,
            @JsonKey(name: 'switch_port') Map<String, dynamic>? switchPort,
            @JsonKey(name: 'ont_onboarding_status')
            Map<String, dynamic>? onboardingStatus,
            @JsonKey(name: 'ont_ports') List<Map<String, dynamic>>? ports,
            String? uptime,
            String? phase)
        ont,
    required TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            String? host,
            @JsonKey(name: 'switch_ports') List<Map<String, dynamic>>? ports,
            @JsonKey(name: 'last_config_sync_at') DateTime? lastConfigSync,
            @JsonKey(name: 'last_config_sync_attempt_at')
            DateTime? lastConfigSyncAttempt,
            @JsonKey(name: 'cpu_usage') int? cpuUsage,
            @JsonKey(name: 'memory_usage') int? memoryUsage,
            int? temperature)
        switchDevice,
    required TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'controller_type') String? controllerType,
            @JsonKey(name: 'managed_aps') int? managedAPs,
            int? vlan,
            @JsonKey(name: 'total_upload') int? totalUpload,
            @JsonKey(name: 'total_download') int? totalDownload,
            @JsonKey(name: 'packet_loss') double? packetLoss,
            int? latency,
            @JsonKey(name: 'restart_count') int? restartCount)
        wlan,
  }) {
    return ont(
        id,
        name,
        status,
        pmsRoom,
        pmsRoomId,
        ipAddress,
        macAddress,
        location,
        lastSeen,
        metadata,
        model,
        serialNumber,
        firmware,
        note,
        images,
        healthNotices,
        hnCounts,
        isRegistered,
        switchPort,
        onboardingStatus,
        ports,
        uptime,
        phase);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'infrastructure_link_id') int? infrastructureLinkId,
            @JsonKey(name: 'connection_state') String? connectionState,
            @JsonKey(name: 'signal_strength') int? signalStrength,
            @JsonKey(name: 'connected_clients') int? connectedClients,
            String? ssid,
            int? channel,
            @JsonKey(name: 'max_clients') int? maxClients,
            @JsonKey(name: 'current_upload') double? currentUpload,
            @JsonKey(name: 'current_download') double? currentDownload,
            @JsonKey(name: 'ap_onboarding_status')
            Map<String, dynamic>? onboardingStatus)?
        ap,
    TResult? Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'is_registered') bool? isRegistered,
            @JsonKey(name: 'switch_port') Map<String, dynamic>? switchPort,
            @JsonKey(name: 'ont_onboarding_status')
            Map<String, dynamic>? onboardingStatus,
            @JsonKey(name: 'ont_ports') List<Map<String, dynamic>>? ports,
            String? uptime,
            String? phase)?
        ont,
    TResult? Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            String? host,
            @JsonKey(name: 'switch_ports') List<Map<String, dynamic>>? ports,
            @JsonKey(name: 'last_config_sync_at') DateTime? lastConfigSync,
            @JsonKey(name: 'last_config_sync_attempt_at')
            DateTime? lastConfigSyncAttempt,
            @JsonKey(name: 'cpu_usage') int? cpuUsage,
            @JsonKey(name: 'memory_usage') int? memoryUsage,
            int? temperature)?
        switchDevice,
    TResult? Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'controller_type') String? controllerType,
            @JsonKey(name: 'managed_aps') int? managedAPs,
            int? vlan,
            @JsonKey(name: 'total_upload') int? totalUpload,
            @JsonKey(name: 'total_download') int? totalDownload,
            @JsonKey(name: 'packet_loss') double? packetLoss,
            int? latency,
            @JsonKey(name: 'restart_count') int? restartCount)?
        wlan,
  }) {
    return ont?.call(
        id,
        name,
        status,
        pmsRoom,
        pmsRoomId,
        ipAddress,
        macAddress,
        location,
        lastSeen,
        metadata,
        model,
        serialNumber,
        firmware,
        note,
        images,
        healthNotices,
        hnCounts,
        isRegistered,
        switchPort,
        onboardingStatus,
        ports,
        uptime,
        phase);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'infrastructure_link_id') int? infrastructureLinkId,
            @JsonKey(name: 'connection_state') String? connectionState,
            @JsonKey(name: 'signal_strength') int? signalStrength,
            @JsonKey(name: 'connected_clients') int? connectedClients,
            String? ssid,
            int? channel,
            @JsonKey(name: 'max_clients') int? maxClients,
            @JsonKey(name: 'current_upload') double? currentUpload,
            @JsonKey(name: 'current_download') double? currentDownload,
            @JsonKey(name: 'ap_onboarding_status')
            Map<String, dynamic>? onboardingStatus)?
        ap,
    TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'is_registered') bool? isRegistered,
            @JsonKey(name: 'switch_port') Map<String, dynamic>? switchPort,
            @JsonKey(name: 'ont_onboarding_status')
            Map<String, dynamic>? onboardingStatus,
            @JsonKey(name: 'ont_ports') List<Map<String, dynamic>>? ports,
            String? uptime,
            String? phase)?
        ont,
    TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            String? host,
            @JsonKey(name: 'switch_ports') List<Map<String, dynamic>>? ports,
            @JsonKey(name: 'last_config_sync_at') DateTime? lastConfigSync,
            @JsonKey(name: 'last_config_sync_attempt_at')
            DateTime? lastConfigSyncAttempt,
            @JsonKey(name: 'cpu_usage') int? cpuUsage,
            @JsonKey(name: 'memory_usage') int? memoryUsage,
            int? temperature)?
        switchDevice,
    TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'controller_type') String? controllerType,
            @JsonKey(name: 'managed_aps') int? managedAPs,
            int? vlan,
            @JsonKey(name: 'total_upload') int? totalUpload,
            @JsonKey(name: 'total_download') int? totalDownload,
            @JsonKey(name: 'packet_loss') double? packetLoss,
            int? latency,
            @JsonKey(name: 'restart_count') int? restartCount)?
        wlan,
    required TResult orElse(),
  }) {
    if (ont != null) {
      return ont(
          id,
          name,
          status,
          pmsRoom,
          pmsRoomId,
          ipAddress,
          macAddress,
          location,
          lastSeen,
          metadata,
          model,
          serialNumber,
          firmware,
          note,
          images,
          healthNotices,
          hnCounts,
          isRegistered,
          switchPort,
          onboardingStatus,
          ports,
          uptime,
          phase);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(APModel value) ap,
    required TResult Function(ONTModel value) ont,
    required TResult Function(SwitchModel value) switchDevice,
    required TResult Function(WLANModel value) wlan,
  }) {
    return ont(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(APModel value)? ap,
    TResult? Function(ONTModel value)? ont,
    TResult? Function(SwitchModel value)? switchDevice,
    TResult? Function(WLANModel value)? wlan,
  }) {
    return ont?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(APModel value)? ap,
    TResult Function(ONTModel value)? ont,
    TResult Function(SwitchModel value)? switchDevice,
    TResult Function(WLANModel value)? wlan,
    required TResult orElse(),
  }) {
    if (ont != null) {
      return ont(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ONTModelImplToJson(
      this,
    );
  }
}

abstract class ONTModel extends DeviceModelSealed {
  const factory ONTModel(
      {required final String id,
      required final String name,
      required final String status,
      @JsonKey(name: 'pms_room') final RoomModel? pmsRoom,
      @JsonKey(name: 'pms_room_id') final int? pmsRoomId,
      @JsonKey(name: 'ip_address') final String? ipAddress,
      @JsonKey(name: 'mac_address') final String? macAddress,
      final String? location,
      @JsonKey(name: 'last_seen') final DateTime? lastSeen,
      final Map<String, dynamic>? metadata,
      final String? model,
      @JsonKey(name: 'serial_number') final String? serialNumber,
      final String? firmware,
      final String? note,
      final List<String>? images,
      @JsonKey(name: 'health_notices')
      final List<HealthNoticeModel>? healthNotices,
      @JsonKey(name: 'hn_counts') final HealthCountsModel? hnCounts,
      @JsonKey(name: 'is_registered') final bool? isRegistered,
      @JsonKey(name: 'switch_port') final Map<String, dynamic>? switchPort,
      @JsonKey(name: 'ont_onboarding_status')
      final Map<String, dynamic>? onboardingStatus,
      @JsonKey(name: 'ont_ports') final List<Map<String, dynamic>>? ports,
      final String? uptime,
      final String? phase}) = _$ONTModelImpl;
  const ONTModel._() : super._();

  factory ONTModel.fromJson(Map<String, dynamic> json) =
      _$ONTModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get status;
  @override
  @JsonKey(name: 'pms_room')
  RoomModel? get pmsRoom;
  @override
  @JsonKey(name: 'pms_room_id')
  int? get pmsRoomId;
  @override
  @JsonKey(name: 'ip_address')
  String? get ipAddress;
  @override
  @JsonKey(name: 'mac_address')
  String? get macAddress;
  @override
  String? get location;
  @override
  @JsonKey(name: 'last_seen')
  DateTime? get lastSeen;
  @override
  Map<String, dynamic>? get metadata;
  @override
  String? get model;
  @override
  @JsonKey(name: 'serial_number')
  String? get serialNumber;
  @override
  String? get firmware;
  @override
  String? get note;
  @override
  List<String>? get images;
  @override
  @JsonKey(name: 'health_notices')
  List<HealthNoticeModel>? get healthNotices;
  @override
  @JsonKey(name: 'hn_counts')
  HealthCountsModel? get hnCounts;
  @JsonKey(name: 'is_registered')
  bool? get isRegistered;
  @JsonKey(name: 'switch_port')
  Map<String, dynamic>? get switchPort;
  @JsonKey(name: 'ont_onboarding_status')
  Map<String, dynamic>? get onboardingStatus;
  @JsonKey(name: 'ont_ports')
  List<Map<String, dynamic>>? get ports;
  String? get uptime;
  String? get phase;
  @override
  @JsonKey(ignore: true)
  _$$ONTModelImplCopyWith<_$ONTModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SwitchModelImplCopyWith<$Res>
    implements $DeviceModelSealedCopyWith<$Res> {
  factory _$$SwitchModelImplCopyWith(
          _$SwitchModelImpl value, $Res Function(_$SwitchModelImpl) then) =
      __$$SwitchModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String status,
      @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
      @JsonKey(name: 'pms_room_id') int? pmsRoomId,
      @JsonKey(name: 'ip_address') String? ipAddress,
      @JsonKey(name: 'mac_address') String? macAddress,
      String? location,
      @JsonKey(name: 'last_seen') DateTime? lastSeen,
      Map<String, dynamic>? metadata,
      String? model,
      @JsonKey(name: 'serial_number') String? serialNumber,
      String? firmware,
      String? note,
      List<String>? images,
      @JsonKey(name: 'health_notices') List<HealthNoticeModel>? healthNotices,
      @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
      String? host,
      @JsonKey(name: 'switch_ports') List<Map<String, dynamic>>? ports,
      @JsonKey(name: 'last_config_sync_at') DateTime? lastConfigSync,
      @JsonKey(name: 'last_config_sync_attempt_at')
      DateTime? lastConfigSyncAttempt,
      @JsonKey(name: 'cpu_usage') int? cpuUsage,
      @JsonKey(name: 'memory_usage') int? memoryUsage,
      int? temperature});

  @override
  $RoomModelCopyWith<$Res>? get pmsRoom;
  @override
  $HealthCountsModelCopyWith<$Res>? get hnCounts;
}

/// @nodoc
class __$$SwitchModelImplCopyWithImpl<$Res>
    extends _$DeviceModelSealedCopyWithImpl<$Res, _$SwitchModelImpl>
    implements _$$SwitchModelImplCopyWith<$Res> {
  __$$SwitchModelImplCopyWithImpl(
      _$SwitchModelImpl _value, $Res Function(_$SwitchModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? status = null,
    Object? pmsRoom = freezed,
    Object? pmsRoomId = freezed,
    Object? ipAddress = freezed,
    Object? macAddress = freezed,
    Object? location = freezed,
    Object? lastSeen = freezed,
    Object? metadata = freezed,
    Object? model = freezed,
    Object? serialNumber = freezed,
    Object? firmware = freezed,
    Object? note = freezed,
    Object? images = freezed,
    Object? healthNotices = freezed,
    Object? hnCounts = freezed,
    Object? host = freezed,
    Object? ports = freezed,
    Object? lastConfigSync = freezed,
    Object? lastConfigSyncAttempt = freezed,
    Object? cpuUsage = freezed,
    Object? memoryUsage = freezed,
    Object? temperature = freezed,
  }) {
    return _then(_$SwitchModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      pmsRoom: freezed == pmsRoom
          ? _value.pmsRoom
          : pmsRoom // ignore: cast_nullable_to_non_nullable
              as RoomModel?,
      pmsRoomId: freezed == pmsRoomId
          ? _value.pmsRoomId
          : pmsRoomId // ignore: cast_nullable_to_non_nullable
              as int?,
      ipAddress: freezed == ipAddress
          ? _value.ipAddress
          : ipAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      macAddress: freezed == macAddress
          ? _value.macAddress
          : macAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      lastSeen: freezed == lastSeen
          ? _value.lastSeen
          : lastSeen // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      model: freezed == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String?,
      serialNumber: freezed == serialNumber
          ? _value.serialNumber
          : serialNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      firmware: freezed == firmware
          ? _value.firmware
          : firmware // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      images: freezed == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      healthNotices: freezed == healthNotices
          ? _value._healthNotices
          : healthNotices // ignore: cast_nullable_to_non_nullable
              as List<HealthNoticeModel>?,
      hnCounts: freezed == hnCounts
          ? _value.hnCounts
          : hnCounts // ignore: cast_nullable_to_non_nullable
              as HealthCountsModel?,
      host: freezed == host
          ? _value.host
          : host // ignore: cast_nullable_to_non_nullable
              as String?,
      ports: freezed == ports
          ? _value._ports
          : ports // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>?,
      lastConfigSync: freezed == lastConfigSync
          ? _value.lastConfigSync
          : lastConfigSync // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastConfigSyncAttempt: freezed == lastConfigSyncAttempt
          ? _value.lastConfigSyncAttempt
          : lastConfigSyncAttempt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cpuUsage: freezed == cpuUsage
          ? _value.cpuUsage
          : cpuUsage // ignore: cast_nullable_to_non_nullable
              as int?,
      memoryUsage: freezed == memoryUsage
          ? _value.memoryUsage
          : memoryUsage // ignore: cast_nullable_to_non_nullable
              as int?,
      temperature: freezed == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SwitchModelImpl extends SwitchModel {
  const _$SwitchModelImpl(
      {required this.id,
      required this.name,
      required this.status,
      @JsonKey(name: 'pms_room') this.pmsRoom,
      @JsonKey(name: 'pms_room_id') this.pmsRoomId,
      @JsonKey(name: 'ip_address') this.ipAddress,
      @JsonKey(name: 'mac_address') this.macAddress,
      this.location,
      @JsonKey(name: 'last_seen') this.lastSeen,
      final Map<String, dynamic>? metadata,
      this.model,
      @JsonKey(name: 'serial_number') this.serialNumber,
      this.firmware,
      this.note,
      final List<String>? images,
      @JsonKey(name: 'health_notices')
      final List<HealthNoticeModel>? healthNotices,
      @JsonKey(name: 'hn_counts') this.hnCounts,
      this.host,
      @JsonKey(name: 'switch_ports') final List<Map<String, dynamic>>? ports,
      @JsonKey(name: 'last_config_sync_at') this.lastConfigSync,
      @JsonKey(name: 'last_config_sync_attempt_at') this.lastConfigSyncAttempt,
      @JsonKey(name: 'cpu_usage') this.cpuUsage,
      @JsonKey(name: 'memory_usage') this.memoryUsage,
      this.temperature,
      final String? $type})
      : _metadata = metadata,
        _images = images,
        _healthNotices = healthNotices,
        _ports = ports,
        $type = $type ?? 'switch',
        super._();

  factory _$SwitchModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SwitchModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String status;
  @override
  @JsonKey(name: 'pms_room')
  final RoomModel? pmsRoom;
  @override
  @JsonKey(name: 'pms_room_id')
  final int? pmsRoomId;
  @override
  @JsonKey(name: 'ip_address')
  final String? ipAddress;
  @override
  @JsonKey(name: 'mac_address')
  final String? macAddress;
  @override
  final String? location;
  @override
  @JsonKey(name: 'last_seen')
  final DateTime? lastSeen;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? model;
  @override
  @JsonKey(name: 'serial_number')
  final String? serialNumber;
  @override
  final String? firmware;
  @override
  final String? note;
  final List<String>? _images;
  @override
  List<String>? get images {
    final value = _images;
    if (value == null) return null;
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<HealthNoticeModel>? _healthNotices;
  @override
  @JsonKey(name: 'health_notices')
  List<HealthNoticeModel>? get healthNotices {
    final value = _healthNotices;
    if (value == null) return null;
    if (_healthNotices is EqualUnmodifiableListView) return _healthNotices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'hn_counts')
  final HealthCountsModel? hnCounts;
  @override
  final String? host;
  final List<Map<String, dynamic>>? _ports;
  @override
  @JsonKey(name: 'switch_ports')
  List<Map<String, dynamic>>? get ports {
    final value = _ports;
    if (value == null) return null;
    if (_ports is EqualUnmodifiableListView) return _ports;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'last_config_sync_at')
  final DateTime? lastConfigSync;
  @override
  @JsonKey(name: 'last_config_sync_attempt_at')
  final DateTime? lastConfigSyncAttempt;
  @override
  @JsonKey(name: 'cpu_usage')
  final int? cpuUsage;
  @override
  @JsonKey(name: 'memory_usage')
  final int? memoryUsage;
  @override
  final int? temperature;

  @JsonKey(name: 'device_type')
  final String $type;

  @override
  String toString() {
    return 'DeviceModelSealed.switchDevice(id: $id, name: $name, status: $status, pmsRoom: $pmsRoom, pmsRoomId: $pmsRoomId, ipAddress: $ipAddress, macAddress: $macAddress, location: $location, lastSeen: $lastSeen, metadata: $metadata, model: $model, serialNumber: $serialNumber, firmware: $firmware, note: $note, images: $images, healthNotices: $healthNotices, hnCounts: $hnCounts, host: $host, ports: $ports, lastConfigSync: $lastConfigSync, lastConfigSyncAttempt: $lastConfigSyncAttempt, cpuUsage: $cpuUsage, memoryUsage: $memoryUsage, temperature: $temperature)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SwitchModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.pmsRoom, pmsRoom) || other.pmsRoom == pmsRoom) &&
            (identical(other.pmsRoomId, pmsRoomId) ||
                other.pmsRoomId == pmsRoomId) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            (identical(other.macAddress, macAddress) ||
                other.macAddress == macAddress) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.lastSeen, lastSeen) ||
                other.lastSeen == lastSeen) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.serialNumber, serialNumber) ||
                other.serialNumber == serialNumber) &&
            (identical(other.firmware, firmware) ||
                other.firmware == firmware) &&
            (identical(other.note, note) || other.note == note) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            const DeepCollectionEquality()
                .equals(other._healthNotices, _healthNotices) &&
            (identical(other.hnCounts, hnCounts) ||
                other.hnCounts == hnCounts) &&
            (identical(other.host, host) || other.host == host) &&
            const DeepCollectionEquality().equals(other._ports, _ports) &&
            (identical(other.lastConfigSync, lastConfigSync) ||
                other.lastConfigSync == lastConfigSync) &&
            (identical(other.lastConfigSyncAttempt, lastConfigSyncAttempt) ||
                other.lastConfigSyncAttempt == lastConfigSyncAttempt) &&
            (identical(other.cpuUsage, cpuUsage) ||
                other.cpuUsage == cpuUsage) &&
            (identical(other.memoryUsage, memoryUsage) ||
                other.memoryUsage == memoryUsage) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        status,
        pmsRoom,
        pmsRoomId,
        ipAddress,
        macAddress,
        location,
        lastSeen,
        const DeepCollectionEquality().hash(_metadata),
        model,
        serialNumber,
        firmware,
        note,
        const DeepCollectionEquality().hash(_images),
        const DeepCollectionEquality().hash(_healthNotices),
        hnCounts,
        host,
        const DeepCollectionEquality().hash(_ports),
        lastConfigSync,
        lastConfigSyncAttempt,
        cpuUsage,
        memoryUsage,
        temperature
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SwitchModelImplCopyWith<_$SwitchModelImpl> get copyWith =>
      __$$SwitchModelImplCopyWithImpl<_$SwitchModelImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'infrastructure_link_id') int? infrastructureLinkId,
            @JsonKey(name: 'connection_state') String? connectionState,
            @JsonKey(name: 'signal_strength') int? signalStrength,
            @JsonKey(name: 'connected_clients') int? connectedClients,
            String? ssid,
            int? channel,
            @JsonKey(name: 'max_clients') int? maxClients,
            @JsonKey(name: 'current_upload') double? currentUpload,
            @JsonKey(name: 'current_download') double? currentDownload,
            @JsonKey(name: 'ap_onboarding_status')
            Map<String, dynamic>? onboardingStatus)
        ap,
    required TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'is_registered') bool? isRegistered,
            @JsonKey(name: 'switch_port') Map<String, dynamic>? switchPort,
            @JsonKey(name: 'ont_onboarding_status')
            Map<String, dynamic>? onboardingStatus,
            @JsonKey(name: 'ont_ports') List<Map<String, dynamic>>? ports,
            String? uptime,
            String? phase)
        ont,
    required TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            String? host,
            @JsonKey(name: 'switch_ports') List<Map<String, dynamic>>? ports,
            @JsonKey(name: 'last_config_sync_at') DateTime? lastConfigSync,
            @JsonKey(name: 'last_config_sync_attempt_at')
            DateTime? lastConfigSyncAttempt,
            @JsonKey(name: 'cpu_usage') int? cpuUsage,
            @JsonKey(name: 'memory_usage') int? memoryUsage,
            int? temperature)
        switchDevice,
    required TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'controller_type') String? controllerType,
            @JsonKey(name: 'managed_aps') int? managedAPs,
            int? vlan,
            @JsonKey(name: 'total_upload') int? totalUpload,
            @JsonKey(name: 'total_download') int? totalDownload,
            @JsonKey(name: 'packet_loss') double? packetLoss,
            int? latency,
            @JsonKey(name: 'restart_count') int? restartCount)
        wlan,
  }) {
    return switchDevice(
        id,
        name,
        status,
        pmsRoom,
        pmsRoomId,
        ipAddress,
        macAddress,
        location,
        lastSeen,
        metadata,
        model,
        serialNumber,
        firmware,
        note,
        images,
        healthNotices,
        hnCounts,
        host,
        ports,
        lastConfigSync,
        lastConfigSyncAttempt,
        cpuUsage,
        memoryUsage,
        temperature);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'infrastructure_link_id') int? infrastructureLinkId,
            @JsonKey(name: 'connection_state') String? connectionState,
            @JsonKey(name: 'signal_strength') int? signalStrength,
            @JsonKey(name: 'connected_clients') int? connectedClients,
            String? ssid,
            int? channel,
            @JsonKey(name: 'max_clients') int? maxClients,
            @JsonKey(name: 'current_upload') double? currentUpload,
            @JsonKey(name: 'current_download') double? currentDownload,
            @JsonKey(name: 'ap_onboarding_status')
            Map<String, dynamic>? onboardingStatus)?
        ap,
    TResult? Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'is_registered') bool? isRegistered,
            @JsonKey(name: 'switch_port') Map<String, dynamic>? switchPort,
            @JsonKey(name: 'ont_onboarding_status')
            Map<String, dynamic>? onboardingStatus,
            @JsonKey(name: 'ont_ports') List<Map<String, dynamic>>? ports,
            String? uptime,
            String? phase)?
        ont,
    TResult? Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            String? host,
            @JsonKey(name: 'switch_ports') List<Map<String, dynamic>>? ports,
            @JsonKey(name: 'last_config_sync_at') DateTime? lastConfigSync,
            @JsonKey(name: 'last_config_sync_attempt_at')
            DateTime? lastConfigSyncAttempt,
            @JsonKey(name: 'cpu_usage') int? cpuUsage,
            @JsonKey(name: 'memory_usage') int? memoryUsage,
            int? temperature)?
        switchDevice,
    TResult? Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'controller_type') String? controllerType,
            @JsonKey(name: 'managed_aps') int? managedAPs,
            int? vlan,
            @JsonKey(name: 'total_upload') int? totalUpload,
            @JsonKey(name: 'total_download') int? totalDownload,
            @JsonKey(name: 'packet_loss') double? packetLoss,
            int? latency,
            @JsonKey(name: 'restart_count') int? restartCount)?
        wlan,
  }) {
    return switchDevice?.call(
        id,
        name,
        status,
        pmsRoom,
        pmsRoomId,
        ipAddress,
        macAddress,
        location,
        lastSeen,
        metadata,
        model,
        serialNumber,
        firmware,
        note,
        images,
        healthNotices,
        hnCounts,
        host,
        ports,
        lastConfigSync,
        lastConfigSyncAttempt,
        cpuUsage,
        memoryUsage,
        temperature);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'infrastructure_link_id') int? infrastructureLinkId,
            @JsonKey(name: 'connection_state') String? connectionState,
            @JsonKey(name: 'signal_strength') int? signalStrength,
            @JsonKey(name: 'connected_clients') int? connectedClients,
            String? ssid,
            int? channel,
            @JsonKey(name: 'max_clients') int? maxClients,
            @JsonKey(name: 'current_upload') double? currentUpload,
            @JsonKey(name: 'current_download') double? currentDownload,
            @JsonKey(name: 'ap_onboarding_status')
            Map<String, dynamic>? onboardingStatus)?
        ap,
    TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'is_registered') bool? isRegistered,
            @JsonKey(name: 'switch_port') Map<String, dynamic>? switchPort,
            @JsonKey(name: 'ont_onboarding_status')
            Map<String, dynamic>? onboardingStatus,
            @JsonKey(name: 'ont_ports') List<Map<String, dynamic>>? ports,
            String? uptime,
            String? phase)?
        ont,
    TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            String? host,
            @JsonKey(name: 'switch_ports') List<Map<String, dynamic>>? ports,
            @JsonKey(name: 'last_config_sync_at') DateTime? lastConfigSync,
            @JsonKey(name: 'last_config_sync_attempt_at')
            DateTime? lastConfigSyncAttempt,
            @JsonKey(name: 'cpu_usage') int? cpuUsage,
            @JsonKey(name: 'memory_usage') int? memoryUsage,
            int? temperature)?
        switchDevice,
    TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'controller_type') String? controllerType,
            @JsonKey(name: 'managed_aps') int? managedAPs,
            int? vlan,
            @JsonKey(name: 'total_upload') int? totalUpload,
            @JsonKey(name: 'total_download') int? totalDownload,
            @JsonKey(name: 'packet_loss') double? packetLoss,
            int? latency,
            @JsonKey(name: 'restart_count') int? restartCount)?
        wlan,
    required TResult orElse(),
  }) {
    if (switchDevice != null) {
      return switchDevice(
          id,
          name,
          status,
          pmsRoom,
          pmsRoomId,
          ipAddress,
          macAddress,
          location,
          lastSeen,
          metadata,
          model,
          serialNumber,
          firmware,
          note,
          images,
          healthNotices,
          hnCounts,
          host,
          ports,
          lastConfigSync,
          lastConfigSyncAttempt,
          cpuUsage,
          memoryUsage,
          temperature);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(APModel value) ap,
    required TResult Function(ONTModel value) ont,
    required TResult Function(SwitchModel value) switchDevice,
    required TResult Function(WLANModel value) wlan,
  }) {
    return switchDevice(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(APModel value)? ap,
    TResult? Function(ONTModel value)? ont,
    TResult? Function(SwitchModel value)? switchDevice,
    TResult? Function(WLANModel value)? wlan,
  }) {
    return switchDevice?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(APModel value)? ap,
    TResult Function(ONTModel value)? ont,
    TResult Function(SwitchModel value)? switchDevice,
    TResult Function(WLANModel value)? wlan,
    required TResult orElse(),
  }) {
    if (switchDevice != null) {
      return switchDevice(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$SwitchModelImplToJson(
      this,
    );
  }
}

abstract class SwitchModel extends DeviceModelSealed {
  const factory SwitchModel(
      {required final String id,
      required final String name,
      required final String status,
      @JsonKey(name: 'pms_room') final RoomModel? pmsRoom,
      @JsonKey(name: 'pms_room_id') final int? pmsRoomId,
      @JsonKey(name: 'ip_address') final String? ipAddress,
      @JsonKey(name: 'mac_address') final String? macAddress,
      final String? location,
      @JsonKey(name: 'last_seen') final DateTime? lastSeen,
      final Map<String, dynamic>? metadata,
      final String? model,
      @JsonKey(name: 'serial_number') final String? serialNumber,
      final String? firmware,
      final String? note,
      final List<String>? images,
      @JsonKey(name: 'health_notices')
      final List<HealthNoticeModel>? healthNotices,
      @JsonKey(name: 'hn_counts') final HealthCountsModel? hnCounts,
      final String? host,
      @JsonKey(name: 'switch_ports') final List<Map<String, dynamic>>? ports,
      @JsonKey(name: 'last_config_sync_at') final DateTime? lastConfigSync,
      @JsonKey(name: 'last_config_sync_attempt_at')
      final DateTime? lastConfigSyncAttempt,
      @JsonKey(name: 'cpu_usage') final int? cpuUsage,
      @JsonKey(name: 'memory_usage') final int? memoryUsage,
      final int? temperature}) = _$SwitchModelImpl;
  const SwitchModel._() : super._();

  factory SwitchModel.fromJson(Map<String, dynamic> json) =
      _$SwitchModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get status;
  @override
  @JsonKey(name: 'pms_room')
  RoomModel? get pmsRoom;
  @override
  @JsonKey(name: 'pms_room_id')
  int? get pmsRoomId;
  @override
  @JsonKey(name: 'ip_address')
  String? get ipAddress;
  @override
  @JsonKey(name: 'mac_address')
  String? get macAddress;
  @override
  String? get location;
  @override
  @JsonKey(name: 'last_seen')
  DateTime? get lastSeen;
  @override
  Map<String, dynamic>? get metadata;
  @override
  String? get model;
  @override
  @JsonKey(name: 'serial_number')
  String? get serialNumber;
  @override
  String? get firmware;
  @override
  String? get note;
  @override
  List<String>? get images;
  @override
  @JsonKey(name: 'health_notices')
  List<HealthNoticeModel>? get healthNotices;
  @override
  @JsonKey(name: 'hn_counts')
  HealthCountsModel? get hnCounts;
  String? get host;
  @JsonKey(name: 'switch_ports')
  List<Map<String, dynamic>>? get ports;
  @JsonKey(name: 'last_config_sync_at')
  DateTime? get lastConfigSync;
  @JsonKey(name: 'last_config_sync_attempt_at')
  DateTime? get lastConfigSyncAttempt;
  @JsonKey(name: 'cpu_usage')
  int? get cpuUsage;
  @JsonKey(name: 'memory_usage')
  int? get memoryUsage;
  int? get temperature;
  @override
  @JsonKey(ignore: true)
  _$$SwitchModelImplCopyWith<_$SwitchModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$WLANModelImplCopyWith<$Res>
    implements $DeviceModelSealedCopyWith<$Res> {
  factory _$$WLANModelImplCopyWith(
          _$WLANModelImpl value, $Res Function(_$WLANModelImpl) then) =
      __$$WLANModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String status,
      @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
      @JsonKey(name: 'pms_room_id') int? pmsRoomId,
      @JsonKey(name: 'ip_address') String? ipAddress,
      @JsonKey(name: 'mac_address') String? macAddress,
      String? location,
      @JsonKey(name: 'last_seen') DateTime? lastSeen,
      Map<String, dynamic>? metadata,
      String? model,
      @JsonKey(name: 'serial_number') String? serialNumber,
      String? firmware,
      String? note,
      List<String>? images,
      @JsonKey(name: 'health_notices') List<HealthNoticeModel>? healthNotices,
      @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
      @JsonKey(name: 'controller_type') String? controllerType,
      @JsonKey(name: 'managed_aps') int? managedAPs,
      int? vlan,
      @JsonKey(name: 'total_upload') int? totalUpload,
      @JsonKey(name: 'total_download') int? totalDownload,
      @JsonKey(name: 'packet_loss') double? packetLoss,
      int? latency,
      @JsonKey(name: 'restart_count') int? restartCount});

  @override
  $RoomModelCopyWith<$Res>? get pmsRoom;
  @override
  $HealthCountsModelCopyWith<$Res>? get hnCounts;
}

/// @nodoc
class __$$WLANModelImplCopyWithImpl<$Res>
    extends _$DeviceModelSealedCopyWithImpl<$Res, _$WLANModelImpl>
    implements _$$WLANModelImplCopyWith<$Res> {
  __$$WLANModelImplCopyWithImpl(
      _$WLANModelImpl _value, $Res Function(_$WLANModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? status = null,
    Object? pmsRoom = freezed,
    Object? pmsRoomId = freezed,
    Object? ipAddress = freezed,
    Object? macAddress = freezed,
    Object? location = freezed,
    Object? lastSeen = freezed,
    Object? metadata = freezed,
    Object? model = freezed,
    Object? serialNumber = freezed,
    Object? firmware = freezed,
    Object? note = freezed,
    Object? images = freezed,
    Object? healthNotices = freezed,
    Object? hnCounts = freezed,
    Object? controllerType = freezed,
    Object? managedAPs = freezed,
    Object? vlan = freezed,
    Object? totalUpload = freezed,
    Object? totalDownload = freezed,
    Object? packetLoss = freezed,
    Object? latency = freezed,
    Object? restartCount = freezed,
  }) {
    return _then(_$WLANModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      pmsRoom: freezed == pmsRoom
          ? _value.pmsRoom
          : pmsRoom // ignore: cast_nullable_to_non_nullable
              as RoomModel?,
      pmsRoomId: freezed == pmsRoomId
          ? _value.pmsRoomId
          : pmsRoomId // ignore: cast_nullable_to_non_nullable
              as int?,
      ipAddress: freezed == ipAddress
          ? _value.ipAddress
          : ipAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      macAddress: freezed == macAddress
          ? _value.macAddress
          : macAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      lastSeen: freezed == lastSeen
          ? _value.lastSeen
          : lastSeen // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      model: freezed == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String?,
      serialNumber: freezed == serialNumber
          ? _value.serialNumber
          : serialNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      firmware: freezed == firmware
          ? _value.firmware
          : firmware // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      images: freezed == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      healthNotices: freezed == healthNotices
          ? _value._healthNotices
          : healthNotices // ignore: cast_nullable_to_non_nullable
              as List<HealthNoticeModel>?,
      hnCounts: freezed == hnCounts
          ? _value.hnCounts
          : hnCounts // ignore: cast_nullable_to_non_nullable
              as HealthCountsModel?,
      controllerType: freezed == controllerType
          ? _value.controllerType
          : controllerType // ignore: cast_nullable_to_non_nullable
              as String?,
      managedAPs: freezed == managedAPs
          ? _value.managedAPs
          : managedAPs // ignore: cast_nullable_to_non_nullable
              as int?,
      vlan: freezed == vlan
          ? _value.vlan
          : vlan // ignore: cast_nullable_to_non_nullable
              as int?,
      totalUpload: freezed == totalUpload
          ? _value.totalUpload
          : totalUpload // ignore: cast_nullable_to_non_nullable
              as int?,
      totalDownload: freezed == totalDownload
          ? _value.totalDownload
          : totalDownload // ignore: cast_nullable_to_non_nullable
              as int?,
      packetLoss: freezed == packetLoss
          ? _value.packetLoss
          : packetLoss // ignore: cast_nullable_to_non_nullable
              as double?,
      latency: freezed == latency
          ? _value.latency
          : latency // ignore: cast_nullable_to_non_nullable
              as int?,
      restartCount: freezed == restartCount
          ? _value.restartCount
          : restartCount // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WLANModelImpl extends WLANModel {
  const _$WLANModelImpl(
      {required this.id,
      required this.name,
      required this.status,
      @JsonKey(name: 'pms_room') this.pmsRoom,
      @JsonKey(name: 'pms_room_id') this.pmsRoomId,
      @JsonKey(name: 'ip_address') this.ipAddress,
      @JsonKey(name: 'mac_address') this.macAddress,
      this.location,
      @JsonKey(name: 'last_seen') this.lastSeen,
      final Map<String, dynamic>? metadata,
      this.model,
      @JsonKey(name: 'serial_number') this.serialNumber,
      this.firmware,
      this.note,
      final List<String>? images,
      @JsonKey(name: 'health_notices')
      final List<HealthNoticeModel>? healthNotices,
      @JsonKey(name: 'hn_counts') this.hnCounts,
      @JsonKey(name: 'controller_type') this.controllerType,
      @JsonKey(name: 'managed_aps') this.managedAPs,
      this.vlan,
      @JsonKey(name: 'total_upload') this.totalUpload,
      @JsonKey(name: 'total_download') this.totalDownload,
      @JsonKey(name: 'packet_loss') this.packetLoss,
      this.latency,
      @JsonKey(name: 'restart_count') this.restartCount,
      final String? $type})
      : _metadata = metadata,
        _images = images,
        _healthNotices = healthNotices,
        $type = $type ?? 'wlan_controller',
        super._();

  factory _$WLANModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$WLANModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String status;
  @override
  @JsonKey(name: 'pms_room')
  final RoomModel? pmsRoom;
  @override
  @JsonKey(name: 'pms_room_id')
  final int? pmsRoomId;
  @override
  @JsonKey(name: 'ip_address')
  final String? ipAddress;
  @override
  @JsonKey(name: 'mac_address')
  final String? macAddress;
  @override
  final String? location;
  @override
  @JsonKey(name: 'last_seen')
  final DateTime? lastSeen;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? model;
  @override
  @JsonKey(name: 'serial_number')
  final String? serialNumber;
  @override
  final String? firmware;
  @override
  final String? note;
  final List<String>? _images;
  @override
  List<String>? get images {
    final value = _images;
    if (value == null) return null;
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<HealthNoticeModel>? _healthNotices;
  @override
  @JsonKey(name: 'health_notices')
  List<HealthNoticeModel>? get healthNotices {
    final value = _healthNotices;
    if (value == null) return null;
    if (_healthNotices is EqualUnmodifiableListView) return _healthNotices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'hn_counts')
  final HealthCountsModel? hnCounts;
  @override
  @JsonKey(name: 'controller_type')
  final String? controllerType;
  @override
  @JsonKey(name: 'managed_aps')
  final int? managedAPs;
  @override
  final int? vlan;
  @override
  @JsonKey(name: 'total_upload')
  final int? totalUpload;
  @override
  @JsonKey(name: 'total_download')
  final int? totalDownload;
  @override
  @JsonKey(name: 'packet_loss')
  final double? packetLoss;
  @override
  final int? latency;
  @override
  @JsonKey(name: 'restart_count')
  final int? restartCount;

  @JsonKey(name: 'device_type')
  final String $type;

  @override
  String toString() {
    return 'DeviceModelSealed.wlan(id: $id, name: $name, status: $status, pmsRoom: $pmsRoom, pmsRoomId: $pmsRoomId, ipAddress: $ipAddress, macAddress: $macAddress, location: $location, lastSeen: $lastSeen, metadata: $metadata, model: $model, serialNumber: $serialNumber, firmware: $firmware, note: $note, images: $images, healthNotices: $healthNotices, hnCounts: $hnCounts, controllerType: $controllerType, managedAPs: $managedAPs, vlan: $vlan, totalUpload: $totalUpload, totalDownload: $totalDownload, packetLoss: $packetLoss, latency: $latency, restartCount: $restartCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WLANModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.pmsRoom, pmsRoom) || other.pmsRoom == pmsRoom) &&
            (identical(other.pmsRoomId, pmsRoomId) ||
                other.pmsRoomId == pmsRoomId) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            (identical(other.macAddress, macAddress) ||
                other.macAddress == macAddress) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.lastSeen, lastSeen) ||
                other.lastSeen == lastSeen) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.serialNumber, serialNumber) ||
                other.serialNumber == serialNumber) &&
            (identical(other.firmware, firmware) ||
                other.firmware == firmware) &&
            (identical(other.note, note) || other.note == note) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            const DeepCollectionEquality()
                .equals(other._healthNotices, _healthNotices) &&
            (identical(other.hnCounts, hnCounts) ||
                other.hnCounts == hnCounts) &&
            (identical(other.controllerType, controllerType) ||
                other.controllerType == controllerType) &&
            (identical(other.managedAPs, managedAPs) ||
                other.managedAPs == managedAPs) &&
            (identical(other.vlan, vlan) || other.vlan == vlan) &&
            (identical(other.totalUpload, totalUpload) ||
                other.totalUpload == totalUpload) &&
            (identical(other.totalDownload, totalDownload) ||
                other.totalDownload == totalDownload) &&
            (identical(other.packetLoss, packetLoss) ||
                other.packetLoss == packetLoss) &&
            (identical(other.latency, latency) || other.latency == latency) &&
            (identical(other.restartCount, restartCount) ||
                other.restartCount == restartCount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        status,
        pmsRoom,
        pmsRoomId,
        ipAddress,
        macAddress,
        location,
        lastSeen,
        const DeepCollectionEquality().hash(_metadata),
        model,
        serialNumber,
        firmware,
        note,
        const DeepCollectionEquality().hash(_images),
        const DeepCollectionEquality().hash(_healthNotices),
        hnCounts,
        controllerType,
        managedAPs,
        vlan,
        totalUpload,
        totalDownload,
        packetLoss,
        latency,
        restartCount
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WLANModelImplCopyWith<_$WLANModelImpl> get copyWith =>
      __$$WLANModelImplCopyWithImpl<_$WLANModelImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'infrastructure_link_id') int? infrastructureLinkId,
            @JsonKey(name: 'connection_state') String? connectionState,
            @JsonKey(name: 'signal_strength') int? signalStrength,
            @JsonKey(name: 'connected_clients') int? connectedClients,
            String? ssid,
            int? channel,
            @JsonKey(name: 'max_clients') int? maxClients,
            @JsonKey(name: 'current_upload') double? currentUpload,
            @JsonKey(name: 'current_download') double? currentDownload,
            @JsonKey(name: 'ap_onboarding_status')
            Map<String, dynamic>? onboardingStatus)
        ap,
    required TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'is_registered') bool? isRegistered,
            @JsonKey(name: 'switch_port') Map<String, dynamic>? switchPort,
            @JsonKey(name: 'ont_onboarding_status')
            Map<String, dynamic>? onboardingStatus,
            @JsonKey(name: 'ont_ports') List<Map<String, dynamic>>? ports,
            String? uptime,
            String? phase)
        ont,
    required TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            String? host,
            @JsonKey(name: 'switch_ports') List<Map<String, dynamic>>? ports,
            @JsonKey(name: 'last_config_sync_at') DateTime? lastConfigSync,
            @JsonKey(name: 'last_config_sync_attempt_at')
            DateTime? lastConfigSyncAttempt,
            @JsonKey(name: 'cpu_usage') int? cpuUsage,
            @JsonKey(name: 'memory_usage') int? memoryUsage,
            int? temperature)
        switchDevice,
    required TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'controller_type') String? controllerType,
            @JsonKey(name: 'managed_aps') int? managedAPs,
            int? vlan,
            @JsonKey(name: 'total_upload') int? totalUpload,
            @JsonKey(name: 'total_download') int? totalDownload,
            @JsonKey(name: 'packet_loss') double? packetLoss,
            int? latency,
            @JsonKey(name: 'restart_count') int? restartCount)
        wlan,
  }) {
    return wlan(
        id,
        name,
        status,
        pmsRoom,
        pmsRoomId,
        ipAddress,
        macAddress,
        location,
        lastSeen,
        metadata,
        model,
        serialNumber,
        firmware,
        note,
        images,
        healthNotices,
        hnCounts,
        controllerType,
        managedAPs,
        vlan,
        totalUpload,
        totalDownload,
        packetLoss,
        latency,
        restartCount);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'infrastructure_link_id') int? infrastructureLinkId,
            @JsonKey(name: 'connection_state') String? connectionState,
            @JsonKey(name: 'signal_strength') int? signalStrength,
            @JsonKey(name: 'connected_clients') int? connectedClients,
            String? ssid,
            int? channel,
            @JsonKey(name: 'max_clients') int? maxClients,
            @JsonKey(name: 'current_upload') double? currentUpload,
            @JsonKey(name: 'current_download') double? currentDownload,
            @JsonKey(name: 'ap_onboarding_status')
            Map<String, dynamic>? onboardingStatus)?
        ap,
    TResult? Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'is_registered') bool? isRegistered,
            @JsonKey(name: 'switch_port') Map<String, dynamic>? switchPort,
            @JsonKey(name: 'ont_onboarding_status')
            Map<String, dynamic>? onboardingStatus,
            @JsonKey(name: 'ont_ports') List<Map<String, dynamic>>? ports,
            String? uptime,
            String? phase)?
        ont,
    TResult? Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            String? host,
            @JsonKey(name: 'switch_ports') List<Map<String, dynamic>>? ports,
            @JsonKey(name: 'last_config_sync_at') DateTime? lastConfigSync,
            @JsonKey(name: 'last_config_sync_attempt_at')
            DateTime? lastConfigSyncAttempt,
            @JsonKey(name: 'cpu_usage') int? cpuUsage,
            @JsonKey(name: 'memory_usage') int? memoryUsage,
            int? temperature)?
        switchDevice,
    TResult? Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'controller_type') String? controllerType,
            @JsonKey(name: 'managed_aps') int? managedAPs,
            int? vlan,
            @JsonKey(name: 'total_upload') int? totalUpload,
            @JsonKey(name: 'total_download') int? totalDownload,
            @JsonKey(name: 'packet_loss') double? packetLoss,
            int? latency,
            @JsonKey(name: 'restart_count') int? restartCount)?
        wlan,
  }) {
    return wlan?.call(
        id,
        name,
        status,
        pmsRoom,
        pmsRoomId,
        ipAddress,
        macAddress,
        location,
        lastSeen,
        metadata,
        model,
        serialNumber,
        firmware,
        note,
        images,
        healthNotices,
        hnCounts,
        controllerType,
        managedAPs,
        vlan,
        totalUpload,
        totalDownload,
        packetLoss,
        latency,
        restartCount);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'infrastructure_link_id') int? infrastructureLinkId,
            @JsonKey(name: 'connection_state') String? connectionState,
            @JsonKey(name: 'signal_strength') int? signalStrength,
            @JsonKey(name: 'connected_clients') int? connectedClients,
            String? ssid,
            int? channel,
            @JsonKey(name: 'max_clients') int? maxClients,
            @JsonKey(name: 'current_upload') double? currentUpload,
            @JsonKey(name: 'current_download') double? currentDownload,
            @JsonKey(name: 'ap_onboarding_status')
            Map<String, dynamic>? onboardingStatus)?
        ap,
    TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'is_registered') bool? isRegistered,
            @JsonKey(name: 'switch_port') Map<String, dynamic>? switchPort,
            @JsonKey(name: 'ont_onboarding_status')
            Map<String, dynamic>? onboardingStatus,
            @JsonKey(name: 'ont_ports') List<Map<String, dynamic>>? ports,
            String? uptime,
            String? phase)?
        ont,
    TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            String? host,
            @JsonKey(name: 'switch_ports') List<Map<String, dynamic>>? ports,
            @JsonKey(name: 'last_config_sync_at') DateTime? lastConfigSync,
            @JsonKey(name: 'last_config_sync_attempt_at')
            DateTime? lastConfigSyncAttempt,
            @JsonKey(name: 'cpu_usage') int? cpuUsage,
            @JsonKey(name: 'memory_usage') int? memoryUsage,
            int? temperature)?
        switchDevice,
    TResult Function(
            String id,
            String name,
            String status,
            @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
            @JsonKey(name: 'pms_room_id') int? pmsRoomId,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'mac_address') String? macAddress,
            String? location,
            @JsonKey(name: 'last_seen') DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? firmware,
            String? note,
            List<String>? images,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,
            @JsonKey(name: 'controller_type') String? controllerType,
            @JsonKey(name: 'managed_aps') int? managedAPs,
            int? vlan,
            @JsonKey(name: 'total_upload') int? totalUpload,
            @JsonKey(name: 'total_download') int? totalDownload,
            @JsonKey(name: 'packet_loss') double? packetLoss,
            int? latency,
            @JsonKey(name: 'restart_count') int? restartCount)?
        wlan,
    required TResult orElse(),
  }) {
    if (wlan != null) {
      return wlan(
          id,
          name,
          status,
          pmsRoom,
          pmsRoomId,
          ipAddress,
          macAddress,
          location,
          lastSeen,
          metadata,
          model,
          serialNumber,
          firmware,
          note,
          images,
          healthNotices,
          hnCounts,
          controllerType,
          managedAPs,
          vlan,
          totalUpload,
          totalDownload,
          packetLoss,
          latency,
          restartCount);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(APModel value) ap,
    required TResult Function(ONTModel value) ont,
    required TResult Function(SwitchModel value) switchDevice,
    required TResult Function(WLANModel value) wlan,
  }) {
    return wlan(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(APModel value)? ap,
    TResult? Function(ONTModel value)? ont,
    TResult? Function(SwitchModel value)? switchDevice,
    TResult? Function(WLANModel value)? wlan,
  }) {
    return wlan?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(APModel value)? ap,
    TResult Function(ONTModel value)? ont,
    TResult Function(SwitchModel value)? switchDevice,
    TResult Function(WLANModel value)? wlan,
    required TResult orElse(),
  }) {
    if (wlan != null) {
      return wlan(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$WLANModelImplToJson(
      this,
    );
  }
}

abstract class WLANModel extends DeviceModelSealed {
  const factory WLANModel(
          {required final String id,
          required final String name,
          required final String status,
          @JsonKey(name: 'pms_room') final RoomModel? pmsRoom,
          @JsonKey(name: 'pms_room_id') final int? pmsRoomId,
          @JsonKey(name: 'ip_address') final String? ipAddress,
          @JsonKey(name: 'mac_address') final String? macAddress,
          final String? location,
          @JsonKey(name: 'last_seen') final DateTime? lastSeen,
          final Map<String, dynamic>? metadata,
          final String? model,
          @JsonKey(name: 'serial_number') final String? serialNumber,
          final String? firmware,
          final String? note,
          final List<String>? images,
          @JsonKey(name: 'health_notices')
          final List<HealthNoticeModel>? healthNotices,
          @JsonKey(name: 'hn_counts') final HealthCountsModel? hnCounts,
          @JsonKey(name: 'controller_type') final String? controllerType,
          @JsonKey(name: 'managed_aps') final int? managedAPs,
          final int? vlan,
          @JsonKey(name: 'total_upload') final int? totalUpload,
          @JsonKey(name: 'total_download') final int? totalDownload,
          @JsonKey(name: 'packet_loss') final double? packetLoss,
          final int? latency,
          @JsonKey(name: 'restart_count') final int? restartCount}) =
      _$WLANModelImpl;
  const WLANModel._() : super._();

  factory WLANModel.fromJson(Map<String, dynamic> json) =
      _$WLANModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get status;
  @override
  @JsonKey(name: 'pms_room')
  RoomModel? get pmsRoom;
  @override
  @JsonKey(name: 'pms_room_id')
  int? get pmsRoomId;
  @override
  @JsonKey(name: 'ip_address')
  String? get ipAddress;
  @override
  @JsonKey(name: 'mac_address')
  String? get macAddress;
  @override
  String? get location;
  @override
  @JsonKey(name: 'last_seen')
  DateTime? get lastSeen;
  @override
  Map<String, dynamic>? get metadata;
  @override
  String? get model;
  @override
  @JsonKey(name: 'serial_number')
  String? get serialNumber;
  @override
  String? get firmware;
  @override
  String? get note;
  @override
  List<String>? get images;
  @override
  @JsonKey(name: 'health_notices')
  List<HealthNoticeModel>? get healthNotices;
  @override
  @JsonKey(name: 'hn_counts')
  HealthCountsModel? get hnCounts;
  @JsonKey(name: 'controller_type')
  String? get controllerType;
  @JsonKey(name: 'managed_aps')
  int? get managedAPs;
  int? get vlan;
  @JsonKey(name: 'total_upload')
  int? get totalUpload;
  @JsonKey(name: 'total_download')
  int? get totalDownload;
  @JsonKey(name: 'packet_loss')
  double? get packetLoss;
  int? get latency;
  @JsonKey(name: 'restart_count')
  int? get restartCount;
  @override
  @JsonKey(ignore: true)
  _$$WLANModelImplCopyWith<_$WLANModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
