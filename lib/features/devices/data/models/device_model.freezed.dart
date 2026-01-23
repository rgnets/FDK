// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DeviceModel _$DeviceModelFromJson(Map<String, dynamic> json) {
  return _DeviceModel.fromJson(json);
}

/// @nodoc
mixin _$DeviceModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
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
  @JsonKey(name: 'signal_strength')
  int? get signalStrength => throw _privateConstructorUsedError;
  int? get uptime => throw _privateConstructorUsedError;
  @JsonKey(name: 'connected_clients')
  int? get connectedClients => throw _privateConstructorUsedError;
  int? get vlan => throw _privateConstructorUsedError;
  String? get ssid => throw _privateConstructorUsedError;
  int? get channel => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_upload')
  int? get totalUpload => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_download')
  int? get totalDownload => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_upload')
  double? get currentUpload => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_download')
  double? get currentDownload => throw _privateConstructorUsedError;
  @JsonKey(name: 'packet_loss')
  double? get packetLoss => throw _privateConstructorUsedError;
  int? get latency => throw _privateConstructorUsedError;
  @JsonKey(name: 'cpu_usage')
  int? get cpuUsage => throw _privateConstructorUsedError;
  @JsonKey(name: 'memory_usage')
  int? get memoryUsage => throw _privateConstructorUsedError;
  int? get temperature => throw _privateConstructorUsedError;
  @JsonKey(name: 'restart_count')
  int? get restartCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'max_clients')
  int? get maxClients => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  List<String>? get images => throw _privateConstructorUsedError;

  /// Signed IDs for images - used for API operations (upload/delete).
  /// When updating images, the server expects signed IDs for existing images.
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<String>? get imageSignedIds => throw _privateConstructorUsedError;
  @JsonKey(name: 'health_notices')
  List<HealthNoticeModel>? get healthNotices =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'hn_counts')
  HealthCountsModel? get hnCounts => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String name,
            String type,
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
            @JsonKey(name: 'signal_strength') int? signalStrength,
            int? uptime,
            @JsonKey(name: 'connected_clients') int? connectedClients,
            int? vlan,
            String? ssid,
            int? channel,
            @JsonKey(name: 'total_upload') int? totalUpload,
            @JsonKey(name: 'total_download') int? totalDownload,
            @JsonKey(name: 'current_upload') double? currentUpload,
            @JsonKey(name: 'current_download') double? currentDownload,
            @JsonKey(name: 'packet_loss') double? packetLoss,
            int? latency,
            @JsonKey(name: 'cpu_usage') int? cpuUsage,
            @JsonKey(name: 'memory_usage') int? memoryUsage,
            int? temperature,
            @JsonKey(name: 'restart_count') int? restartCount,
            @JsonKey(name: 'max_clients') int? maxClients,
            String? note,
            List<String>? images,
            @JsonKey(includeFromJson: false, includeToJson: false)
            List<String>? imageSignedIds,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts)
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String name,
            String type,
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
            @JsonKey(name: 'signal_strength') int? signalStrength,
            int? uptime,
            @JsonKey(name: 'connected_clients') int? connectedClients,
            int? vlan,
            String? ssid,
            int? channel,
            @JsonKey(name: 'total_upload') int? totalUpload,
            @JsonKey(name: 'total_download') int? totalDownload,
            @JsonKey(name: 'current_upload') double? currentUpload,
            @JsonKey(name: 'current_download') double? currentDownload,
            @JsonKey(name: 'packet_loss') double? packetLoss,
            int? latency,
            @JsonKey(name: 'cpu_usage') int? cpuUsage,
            @JsonKey(name: 'memory_usage') int? memoryUsage,
            int? temperature,
            @JsonKey(name: 'restart_count') int? restartCount,
            @JsonKey(name: 'max_clients') int? maxClients,
            String? note,
            List<String>? images,
            @JsonKey(includeFromJson: false, includeToJson: false)
            List<String>? imageSignedIds,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts)?
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String name,
            String type,
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
            @JsonKey(name: 'signal_strength') int? signalStrength,
            int? uptime,
            @JsonKey(name: 'connected_clients') int? connectedClients,
            int? vlan,
            String? ssid,
            int? channel,
            @JsonKey(name: 'total_upload') int? totalUpload,
            @JsonKey(name: 'total_download') int? totalDownload,
            @JsonKey(name: 'current_upload') double? currentUpload,
            @JsonKey(name: 'current_download') double? currentDownload,
            @JsonKey(name: 'packet_loss') double? packetLoss,
            int? latency,
            @JsonKey(name: 'cpu_usage') int? cpuUsage,
            @JsonKey(name: 'memory_usage') int? memoryUsage,
            int? temperature,
            @JsonKey(name: 'restart_count') int? restartCount,
            @JsonKey(name: 'max_clients') int? maxClients,
            String? note,
            List<String>? images,
            @JsonKey(includeFromJson: false, includeToJson: false)
            List<String>? imageSignedIds,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts)?
        $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_DeviceModel value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_DeviceModel value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_DeviceModel value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DeviceModelCopyWith<DeviceModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeviceModelCopyWith<$Res> {
  factory $DeviceModelCopyWith(
          DeviceModel value, $Res Function(DeviceModel) then) =
      _$DeviceModelCopyWithImpl<$Res, DeviceModel>;
  @useResult
  $Res call(
      {String id,
      String name,
      String type,
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
      @JsonKey(name: 'signal_strength') int? signalStrength,
      int? uptime,
      @JsonKey(name: 'connected_clients') int? connectedClients,
      int? vlan,
      String? ssid,
      int? channel,
      @JsonKey(name: 'total_upload') int? totalUpload,
      @JsonKey(name: 'total_download') int? totalDownload,
      @JsonKey(name: 'current_upload') double? currentUpload,
      @JsonKey(name: 'current_download') double? currentDownload,
      @JsonKey(name: 'packet_loss') double? packetLoss,
      int? latency,
      @JsonKey(name: 'cpu_usage') int? cpuUsage,
      @JsonKey(name: 'memory_usage') int? memoryUsage,
      int? temperature,
      @JsonKey(name: 'restart_count') int? restartCount,
      @JsonKey(name: 'max_clients') int? maxClients,
      String? note,
      List<String>? images,
      @JsonKey(includeFromJson: false, includeToJson: false)
      List<String>? imageSignedIds,
      @JsonKey(name: 'health_notices') List<HealthNoticeModel>? healthNotices,
      @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts});

  $RoomModelCopyWith<$Res>? get pmsRoom;
  $HealthCountsModelCopyWith<$Res>? get hnCounts;
}

/// @nodoc
class _$DeviceModelCopyWithImpl<$Res, $Val extends DeviceModel>
    implements $DeviceModelCopyWith<$Res> {
  _$DeviceModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
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
    Object? signalStrength = freezed,
    Object? uptime = freezed,
    Object? connectedClients = freezed,
    Object? vlan = freezed,
    Object? ssid = freezed,
    Object? channel = freezed,
    Object? totalUpload = freezed,
    Object? totalDownload = freezed,
    Object? currentUpload = freezed,
    Object? currentDownload = freezed,
    Object? packetLoss = freezed,
    Object? latency = freezed,
    Object? cpuUsage = freezed,
    Object? memoryUsage = freezed,
    Object? temperature = freezed,
    Object? restartCount = freezed,
    Object? maxClients = freezed,
    Object? note = freezed,
    Object? images = freezed,
    Object? imageSignedIds = freezed,
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
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
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
      signalStrength: freezed == signalStrength
          ? _value.signalStrength
          : signalStrength // ignore: cast_nullable_to_non_nullable
              as int?,
      uptime: freezed == uptime
          ? _value.uptime
          : uptime // ignore: cast_nullable_to_non_nullable
              as int?,
      connectedClients: freezed == connectedClients
          ? _value.connectedClients
          : connectedClients // ignore: cast_nullable_to_non_nullable
              as int?,
      vlan: freezed == vlan
          ? _value.vlan
          : vlan // ignore: cast_nullable_to_non_nullable
              as int?,
      ssid: freezed == ssid
          ? _value.ssid
          : ssid // ignore: cast_nullable_to_non_nullable
              as String?,
      channel: freezed == channel
          ? _value.channel
          : channel // ignore: cast_nullable_to_non_nullable
              as int?,
      totalUpload: freezed == totalUpload
          ? _value.totalUpload
          : totalUpload // ignore: cast_nullable_to_non_nullable
              as int?,
      totalDownload: freezed == totalDownload
          ? _value.totalDownload
          : totalDownload // ignore: cast_nullable_to_non_nullable
              as int?,
      currentUpload: freezed == currentUpload
          ? _value.currentUpload
          : currentUpload // ignore: cast_nullable_to_non_nullable
              as double?,
      currentDownload: freezed == currentDownload
          ? _value.currentDownload
          : currentDownload // ignore: cast_nullable_to_non_nullable
              as double?,
      packetLoss: freezed == packetLoss
          ? _value.packetLoss
          : packetLoss // ignore: cast_nullable_to_non_nullable
              as double?,
      latency: freezed == latency
          ? _value.latency
          : latency // ignore: cast_nullable_to_non_nullable
              as int?,
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
      restartCount: freezed == restartCount
          ? _value.restartCount
          : restartCount // ignore: cast_nullable_to_non_nullable
              as int?,
      maxClients: freezed == maxClients
          ? _value.maxClients
          : maxClients // ignore: cast_nullable_to_non_nullable
              as int?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      images: freezed == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      imageSignedIds: freezed == imageSignedIds
          ? _value.imageSignedIds
          : imageSignedIds // ignore: cast_nullable_to_non_nullable
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
abstract class _$$DeviceModelImplCopyWith<$Res>
    implements $DeviceModelCopyWith<$Res> {
  factory _$$DeviceModelImplCopyWith(
          _$DeviceModelImpl value, $Res Function(_$DeviceModelImpl) then) =
      __$$DeviceModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String type,
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
      @JsonKey(name: 'signal_strength') int? signalStrength,
      int? uptime,
      @JsonKey(name: 'connected_clients') int? connectedClients,
      int? vlan,
      String? ssid,
      int? channel,
      @JsonKey(name: 'total_upload') int? totalUpload,
      @JsonKey(name: 'total_download') int? totalDownload,
      @JsonKey(name: 'current_upload') double? currentUpload,
      @JsonKey(name: 'current_download') double? currentDownload,
      @JsonKey(name: 'packet_loss') double? packetLoss,
      int? latency,
      @JsonKey(name: 'cpu_usage') int? cpuUsage,
      @JsonKey(name: 'memory_usage') int? memoryUsage,
      int? temperature,
      @JsonKey(name: 'restart_count') int? restartCount,
      @JsonKey(name: 'max_clients') int? maxClients,
      String? note,
      List<String>? images,
      @JsonKey(includeFromJson: false, includeToJson: false)
      List<String>? imageSignedIds,
      @JsonKey(name: 'health_notices') List<HealthNoticeModel>? healthNotices,
      @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts});

  @override
  $RoomModelCopyWith<$Res>? get pmsRoom;
  @override
  $HealthCountsModelCopyWith<$Res>? get hnCounts;
}

/// @nodoc
class __$$DeviceModelImplCopyWithImpl<$Res>
    extends _$DeviceModelCopyWithImpl<$Res, _$DeviceModelImpl>
    implements _$$DeviceModelImplCopyWith<$Res> {
  __$$DeviceModelImplCopyWithImpl(
      _$DeviceModelImpl _value, $Res Function(_$DeviceModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
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
    Object? signalStrength = freezed,
    Object? uptime = freezed,
    Object? connectedClients = freezed,
    Object? vlan = freezed,
    Object? ssid = freezed,
    Object? channel = freezed,
    Object? totalUpload = freezed,
    Object? totalDownload = freezed,
    Object? currentUpload = freezed,
    Object? currentDownload = freezed,
    Object? packetLoss = freezed,
    Object? latency = freezed,
    Object? cpuUsage = freezed,
    Object? memoryUsage = freezed,
    Object? temperature = freezed,
    Object? restartCount = freezed,
    Object? maxClients = freezed,
    Object? note = freezed,
    Object? images = freezed,
    Object? imageSignedIds = freezed,
    Object? healthNotices = freezed,
    Object? hnCounts = freezed,
  }) {
    return _then(_$DeviceModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
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
      signalStrength: freezed == signalStrength
          ? _value.signalStrength
          : signalStrength // ignore: cast_nullable_to_non_nullable
              as int?,
      uptime: freezed == uptime
          ? _value.uptime
          : uptime // ignore: cast_nullable_to_non_nullable
              as int?,
      connectedClients: freezed == connectedClients
          ? _value.connectedClients
          : connectedClients // ignore: cast_nullable_to_non_nullable
              as int?,
      vlan: freezed == vlan
          ? _value.vlan
          : vlan // ignore: cast_nullable_to_non_nullable
              as int?,
      ssid: freezed == ssid
          ? _value.ssid
          : ssid // ignore: cast_nullable_to_non_nullable
              as String?,
      channel: freezed == channel
          ? _value.channel
          : channel // ignore: cast_nullable_to_non_nullable
              as int?,
      totalUpload: freezed == totalUpload
          ? _value.totalUpload
          : totalUpload // ignore: cast_nullable_to_non_nullable
              as int?,
      totalDownload: freezed == totalDownload
          ? _value.totalDownload
          : totalDownload // ignore: cast_nullable_to_non_nullable
              as int?,
      currentUpload: freezed == currentUpload
          ? _value.currentUpload
          : currentUpload // ignore: cast_nullable_to_non_nullable
              as double?,
      currentDownload: freezed == currentDownload
          ? _value.currentDownload
          : currentDownload // ignore: cast_nullable_to_non_nullable
              as double?,
      packetLoss: freezed == packetLoss
          ? _value.packetLoss
          : packetLoss // ignore: cast_nullable_to_non_nullable
              as double?,
      latency: freezed == latency
          ? _value.latency
          : latency // ignore: cast_nullable_to_non_nullable
              as int?,
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
      restartCount: freezed == restartCount
          ? _value.restartCount
          : restartCount // ignore: cast_nullable_to_non_nullable
              as int?,
      maxClients: freezed == maxClients
          ? _value.maxClients
          : maxClients // ignore: cast_nullable_to_non_nullable
              as int?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      images: freezed == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      imageSignedIds: freezed == imageSignedIds
          ? _value._imageSignedIds
          : imageSignedIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      healthNotices: freezed == healthNotices
          ? _value._healthNotices
          : healthNotices // ignore: cast_nullable_to_non_nullable
              as List<HealthNoticeModel>?,
      hnCounts: freezed == hnCounts
          ? _value.hnCounts
          : hnCounts // ignore: cast_nullable_to_non_nullable
              as HealthCountsModel?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DeviceModelImpl implements _DeviceModel {
  const _$DeviceModelImpl(
      {required this.id,
      required this.name,
      required this.type,
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
      @JsonKey(name: 'signal_strength') this.signalStrength,
      this.uptime,
      @JsonKey(name: 'connected_clients') this.connectedClients,
      this.vlan,
      this.ssid,
      this.channel,
      @JsonKey(name: 'total_upload') this.totalUpload,
      @JsonKey(name: 'total_download') this.totalDownload,
      @JsonKey(name: 'current_upload') this.currentUpload,
      @JsonKey(name: 'current_download') this.currentDownload,
      @JsonKey(name: 'packet_loss') this.packetLoss,
      this.latency,
      @JsonKey(name: 'cpu_usage') this.cpuUsage,
      @JsonKey(name: 'memory_usage') this.memoryUsage,
      this.temperature,
      @JsonKey(name: 'restart_count') this.restartCount,
      @JsonKey(name: 'max_clients') this.maxClients,
      this.note,
      final List<String>? images,
      @JsonKey(includeFromJson: false, includeToJson: false)
      final List<String>? imageSignedIds,
      @JsonKey(name: 'health_notices')
      final List<HealthNoticeModel>? healthNotices,
      @JsonKey(name: 'hn_counts') this.hnCounts})
      : _metadata = metadata,
        _images = images,
        _imageSignedIds = imageSignedIds,
        _healthNotices = healthNotices;

  factory _$DeviceModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeviceModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String type;
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
  @JsonKey(name: 'signal_strength')
  final int? signalStrength;
  @override
  final int? uptime;
  @override
  @JsonKey(name: 'connected_clients')
  final int? connectedClients;
  @override
  final int? vlan;
  @override
  final String? ssid;
  @override
  final int? channel;
  @override
  @JsonKey(name: 'total_upload')
  final int? totalUpload;
  @override
  @JsonKey(name: 'total_download')
  final int? totalDownload;
  @override
  @JsonKey(name: 'current_upload')
  final double? currentUpload;
  @override
  @JsonKey(name: 'current_download')
  final double? currentDownload;
  @override
  @JsonKey(name: 'packet_loss')
  final double? packetLoss;
  @override
  final int? latency;
  @override
  @JsonKey(name: 'cpu_usage')
  final int? cpuUsage;
  @override
  @JsonKey(name: 'memory_usage')
  final int? memoryUsage;
  @override
  final int? temperature;
  @override
  @JsonKey(name: 'restart_count')
  final int? restartCount;
  @override
  @JsonKey(name: 'max_clients')
  final int? maxClients;
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

  /// Signed IDs for images - used for API operations (upload/delete).
  /// When updating images, the server expects signed IDs for existing images.
  final List<String>? _imageSignedIds;

  /// Signed IDs for images - used for API operations (upload/delete).
  /// When updating images, the server expects signed IDs for existing images.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<String>? get imageSignedIds {
    final value = _imageSignedIds;
    if (value == null) return null;
    if (_imageSignedIds is EqualUnmodifiableListView) return _imageSignedIds;
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
  String toString() {
    return 'DeviceModel(id: $id, name: $name, type: $type, status: $status, pmsRoom: $pmsRoom, pmsRoomId: $pmsRoomId, ipAddress: $ipAddress, macAddress: $macAddress, location: $location, lastSeen: $lastSeen, metadata: $metadata, model: $model, serialNumber: $serialNumber, firmware: $firmware, signalStrength: $signalStrength, uptime: $uptime, connectedClients: $connectedClients, vlan: $vlan, ssid: $ssid, channel: $channel, totalUpload: $totalUpload, totalDownload: $totalDownload, currentUpload: $currentUpload, currentDownload: $currentDownload, packetLoss: $packetLoss, latency: $latency, cpuUsage: $cpuUsage, memoryUsage: $memoryUsage, temperature: $temperature, restartCount: $restartCount, maxClients: $maxClients, note: $note, images: $images, imageSignedIds: $imageSignedIds, healthNotices: $healthNotices, hnCounts: $hnCounts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
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
            (identical(other.signalStrength, signalStrength) ||
                other.signalStrength == signalStrength) &&
            (identical(other.uptime, uptime) || other.uptime == uptime) &&
            (identical(other.connectedClients, connectedClients) ||
                other.connectedClients == connectedClients) &&
            (identical(other.vlan, vlan) || other.vlan == vlan) &&
            (identical(other.ssid, ssid) || other.ssid == ssid) &&
            (identical(other.channel, channel) || other.channel == channel) &&
            (identical(other.totalUpload, totalUpload) ||
                other.totalUpload == totalUpload) &&
            (identical(other.totalDownload, totalDownload) ||
                other.totalDownload == totalDownload) &&
            (identical(other.currentUpload, currentUpload) ||
                other.currentUpload == currentUpload) &&
            (identical(other.currentDownload, currentDownload) ||
                other.currentDownload == currentDownload) &&
            (identical(other.packetLoss, packetLoss) ||
                other.packetLoss == packetLoss) &&
            (identical(other.latency, latency) || other.latency == latency) &&
            (identical(other.cpuUsage, cpuUsage) ||
                other.cpuUsage == cpuUsage) &&
            (identical(other.memoryUsage, memoryUsage) ||
                other.memoryUsage == memoryUsage) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.restartCount, restartCount) ||
                other.restartCount == restartCount) &&
            (identical(other.maxClients, maxClients) ||
                other.maxClients == maxClients) &&
            (identical(other.note, note) || other.note == note) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            const DeepCollectionEquality()
                .equals(other._imageSignedIds, _imageSignedIds) &&
            const DeepCollectionEquality()
                .equals(other._healthNotices, _healthNotices) &&
            (identical(other.hnCounts, hnCounts) ||
                other.hnCounts == hnCounts));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        type,
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
        signalStrength,
        uptime,
        connectedClients,
        vlan,
        ssid,
        channel,
        totalUpload,
        totalDownload,
        currentUpload,
        currentDownload,
        packetLoss,
        latency,
        cpuUsage,
        memoryUsage,
        temperature,
        restartCount,
        maxClients,
        note,
        const DeepCollectionEquality().hash(_images),
        const DeepCollectionEquality().hash(_imageSignedIds),
        const DeepCollectionEquality().hash(_healthNotices),
        hnCounts
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceModelImplCopyWith<_$DeviceModelImpl> get copyWith =>
      __$$DeviceModelImplCopyWithImpl<_$DeviceModelImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String name,
            String type,
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
            @JsonKey(name: 'signal_strength') int? signalStrength,
            int? uptime,
            @JsonKey(name: 'connected_clients') int? connectedClients,
            int? vlan,
            String? ssid,
            int? channel,
            @JsonKey(name: 'total_upload') int? totalUpload,
            @JsonKey(name: 'total_download') int? totalDownload,
            @JsonKey(name: 'current_upload') double? currentUpload,
            @JsonKey(name: 'current_download') double? currentDownload,
            @JsonKey(name: 'packet_loss') double? packetLoss,
            int? latency,
            @JsonKey(name: 'cpu_usage') int? cpuUsage,
            @JsonKey(name: 'memory_usage') int? memoryUsage,
            int? temperature,
            @JsonKey(name: 'restart_count') int? restartCount,
            @JsonKey(name: 'max_clients') int? maxClients,
            String? note,
            List<String>? images,
            @JsonKey(includeFromJson: false, includeToJson: false)
            List<String>? imageSignedIds,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts)
        $default,
  ) {
    return $default(
        id,
        name,
        type,
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
        signalStrength,
        uptime,
        connectedClients,
        vlan,
        ssid,
        channel,
        totalUpload,
        totalDownload,
        currentUpload,
        currentDownload,
        packetLoss,
        latency,
        cpuUsage,
        memoryUsage,
        temperature,
        restartCount,
        maxClients,
        note,
        images,
        imageSignedIds,
        healthNotices,
        hnCounts);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String name,
            String type,
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
            @JsonKey(name: 'signal_strength') int? signalStrength,
            int? uptime,
            @JsonKey(name: 'connected_clients') int? connectedClients,
            int? vlan,
            String? ssid,
            int? channel,
            @JsonKey(name: 'total_upload') int? totalUpload,
            @JsonKey(name: 'total_download') int? totalDownload,
            @JsonKey(name: 'current_upload') double? currentUpload,
            @JsonKey(name: 'current_download') double? currentDownload,
            @JsonKey(name: 'packet_loss') double? packetLoss,
            int? latency,
            @JsonKey(name: 'cpu_usage') int? cpuUsage,
            @JsonKey(name: 'memory_usage') int? memoryUsage,
            int? temperature,
            @JsonKey(name: 'restart_count') int? restartCount,
            @JsonKey(name: 'max_clients') int? maxClients,
            String? note,
            List<String>? images,
            @JsonKey(includeFromJson: false, includeToJson: false)
            List<String>? imageSignedIds,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts)?
        $default,
  ) {
    return $default?.call(
        id,
        name,
        type,
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
        signalStrength,
        uptime,
        connectedClients,
        vlan,
        ssid,
        channel,
        totalUpload,
        totalDownload,
        currentUpload,
        currentDownload,
        packetLoss,
        latency,
        cpuUsage,
        memoryUsage,
        temperature,
        restartCount,
        maxClients,
        note,
        images,
        imageSignedIds,
        healthNotices,
        hnCounts);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String name,
            String type,
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
            @JsonKey(name: 'signal_strength') int? signalStrength,
            int? uptime,
            @JsonKey(name: 'connected_clients') int? connectedClients,
            int? vlan,
            String? ssid,
            int? channel,
            @JsonKey(name: 'total_upload') int? totalUpload,
            @JsonKey(name: 'total_download') int? totalDownload,
            @JsonKey(name: 'current_upload') double? currentUpload,
            @JsonKey(name: 'current_download') double? currentDownload,
            @JsonKey(name: 'packet_loss') double? packetLoss,
            int? latency,
            @JsonKey(name: 'cpu_usage') int? cpuUsage,
            @JsonKey(name: 'memory_usage') int? memoryUsage,
            int? temperature,
            @JsonKey(name: 'restart_count') int? restartCount,
            @JsonKey(name: 'max_clients') int? maxClients,
            String? note,
            List<String>? images,
            @JsonKey(includeFromJson: false, includeToJson: false)
            List<String>? imageSignedIds,
            @JsonKey(name: 'health_notices')
            List<HealthNoticeModel>? healthNotices,
            @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts)?
        $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(
          id,
          name,
          type,
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
          signalStrength,
          uptime,
          connectedClients,
          vlan,
          ssid,
          channel,
          totalUpload,
          totalDownload,
          currentUpload,
          currentDownload,
          packetLoss,
          latency,
          cpuUsage,
          memoryUsage,
          temperature,
          restartCount,
          maxClients,
          note,
          images,
          imageSignedIds,
          healthNotices,
          hnCounts);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_DeviceModel value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_DeviceModel value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_DeviceModel value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$DeviceModelImplToJson(
      this,
    );
  }
}

abstract class _DeviceModel implements DeviceModel {
  const factory _DeviceModel(
          {required final String id,
          required final String name,
          required final String type,
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
          @JsonKey(name: 'signal_strength') final int? signalStrength,
          final int? uptime,
          @JsonKey(name: 'connected_clients') final int? connectedClients,
          final int? vlan,
          final String? ssid,
          final int? channel,
          @JsonKey(name: 'total_upload') final int? totalUpload,
          @JsonKey(name: 'total_download') final int? totalDownload,
          @JsonKey(name: 'current_upload') final double? currentUpload,
          @JsonKey(name: 'current_download') final double? currentDownload,
          @JsonKey(name: 'packet_loss') final double? packetLoss,
          final int? latency,
          @JsonKey(name: 'cpu_usage') final int? cpuUsage,
          @JsonKey(name: 'memory_usage') final int? memoryUsage,
          final int? temperature,
          @JsonKey(name: 'restart_count') final int? restartCount,
          @JsonKey(name: 'max_clients') final int? maxClients,
          final String? note,
          final List<String>? images,
          @JsonKey(includeFromJson: false, includeToJson: false)
          final List<String>? imageSignedIds,
          @JsonKey(name: 'health_notices')
          final List<HealthNoticeModel>? healthNotices,
          @JsonKey(name: 'hn_counts') final HealthCountsModel? hnCounts}) =
      _$DeviceModelImpl;

  factory _DeviceModel.fromJson(Map<String, dynamic> json) =
      _$DeviceModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get type;
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
  @JsonKey(name: 'signal_strength')
  int? get signalStrength;
  @override
  int? get uptime;
  @override
  @JsonKey(name: 'connected_clients')
  int? get connectedClients;
  @override
  int? get vlan;
  @override
  String? get ssid;
  @override
  int? get channel;
  @override
  @JsonKey(name: 'total_upload')
  int? get totalUpload;
  @override
  @JsonKey(name: 'total_download')
  int? get totalDownload;
  @override
  @JsonKey(name: 'current_upload')
  double? get currentUpload;
  @override
  @JsonKey(name: 'current_download')
  double? get currentDownload;
  @override
  @JsonKey(name: 'packet_loss')
  double? get packetLoss;
  @override
  int? get latency;
  @override
  @JsonKey(name: 'cpu_usage')
  int? get cpuUsage;
  @override
  @JsonKey(name: 'memory_usage')
  int? get memoryUsage;
  @override
  int? get temperature;
  @override
  @JsonKey(name: 'restart_count')
  int? get restartCount;
  @override
  @JsonKey(name: 'max_clients')
  int? get maxClients;
  @override
  String? get note;
  @override
  List<String>? get images;
  @override

  /// Signed IDs for images - used for API operations (upload/delete).
  /// When updating images, the server expects signed IDs for existing images.
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<String>? get imageSignedIds;
  @override
  @JsonKey(name: 'health_notices')
  List<HealthNoticeModel>? get healthNotices;
  @override
  @JsonKey(name: 'hn_counts')
  HealthCountsModel? get hnCounts;
  @override
  @JsonKey(ignore: true)
  _$$DeviceModelImplCopyWith<_$DeviceModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
