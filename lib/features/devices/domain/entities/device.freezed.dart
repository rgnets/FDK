// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Device {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  Room? get pmsRoom => throw _privateConstructorUsedError;
  int? get pmsRoomId => throw _privateConstructorUsedError;
  String? get ipAddress => throw _privateConstructorUsedError;
  String? get macAddress => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  DateTime? get lastSeen => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  String? get model => throw _privateConstructorUsedError;
  String? get serialNumber => throw _privateConstructorUsedError;
  String? get firmware => throw _privateConstructorUsedError;
  int? get signalStrength => throw _privateConstructorUsedError;
  int? get uptime => throw _privateConstructorUsedError;
  int? get connectedClients => throw _privateConstructorUsedError;
  int? get vlan => throw _privateConstructorUsedError;
  String? get ssid => throw _privateConstructorUsedError;
  int? get channel => throw _privateConstructorUsedError;
  int? get totalUpload => throw _privateConstructorUsedError;
  int? get totalDownload => throw _privateConstructorUsedError;
  double? get currentUpload => throw _privateConstructorUsedError;
  double? get currentDownload => throw _privateConstructorUsedError;
  double? get packetLoss => throw _privateConstructorUsedError;
  int? get latency => throw _privateConstructorUsedError;
  int? get cpuUsage => throw _privateConstructorUsedError;
  int? get memoryUsage => throw _privateConstructorUsedError;
  int? get temperature => throw _privateConstructorUsedError;
  int? get restartCount => throw _privateConstructorUsedError;
  int? get maxClients => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  List<String>? get images => throw _privateConstructorUsedError;

  /// Signed IDs for images - used for API operations (upload/delete).
  /// When updating images, the server expects signed IDs for existing images.
  List<String>? get imageSignedIds => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String name,
            String type,
            String status,
            Room? pmsRoom,
            int? pmsRoomId,
            String? ipAddress,
            String? macAddress,
            String? location,
            DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            String? serialNumber,
            String? firmware,
            int? signalStrength,
            int? uptime,
            int? connectedClients,
            int? vlan,
            String? ssid,
            int? channel,
            int? totalUpload,
            int? totalDownload,
            double? currentUpload,
            double? currentDownload,
            double? packetLoss,
            int? latency,
            int? cpuUsage,
            int? memoryUsage,
            int? temperature,
            int? restartCount,
            int? maxClients,
            String? note,
            List<String>? images,
            List<String>? imageSignedIds)
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
            Room? pmsRoom,
            int? pmsRoomId,
            String? ipAddress,
            String? macAddress,
            String? location,
            DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            String? serialNumber,
            String? firmware,
            int? signalStrength,
            int? uptime,
            int? connectedClients,
            int? vlan,
            String? ssid,
            int? channel,
            int? totalUpload,
            int? totalDownload,
            double? currentUpload,
            double? currentDownload,
            double? packetLoss,
            int? latency,
            int? cpuUsage,
            int? memoryUsage,
            int? temperature,
            int? restartCount,
            int? maxClients,
            String? note,
            List<String>? images,
            List<String>? imageSignedIds)?
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
            Room? pmsRoom,
            int? pmsRoomId,
            String? ipAddress,
            String? macAddress,
            String? location,
            DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            String? serialNumber,
            String? firmware,
            int? signalStrength,
            int? uptime,
            int? connectedClients,
            int? vlan,
            String? ssid,
            int? channel,
            int? totalUpload,
            int? totalDownload,
            double? currentUpload,
            double? currentDownload,
            double? packetLoss,
            int? latency,
            int? cpuUsage,
            int? memoryUsage,
            int? temperature,
            int? restartCount,
            int? maxClients,
            String? note,
            List<String>? images,
            List<String>? imageSignedIds)?
        $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Device value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Device value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Device value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DeviceCopyWith<Device> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeviceCopyWith<$Res> {
  factory $DeviceCopyWith(Device value, $Res Function(Device) then) =
      _$DeviceCopyWithImpl<$Res, Device>;
  @useResult
  $Res call(
      {String id,
      String name,
      String type,
      String status,
      Room? pmsRoom,
      int? pmsRoomId,
      String? ipAddress,
      String? macAddress,
      String? location,
      DateTime? lastSeen,
      Map<String, dynamic>? metadata,
      String? model,
      String? serialNumber,
      String? firmware,
      int? signalStrength,
      int? uptime,
      int? connectedClients,
      int? vlan,
      String? ssid,
      int? channel,
      int? totalUpload,
      int? totalDownload,
      double? currentUpload,
      double? currentDownload,
      double? packetLoss,
      int? latency,
      int? cpuUsage,
      int? memoryUsage,
      int? temperature,
      int? restartCount,
      int? maxClients,
      String? note,
      List<String>? images,
      List<String>? imageSignedIds});

  $RoomCopyWith<$Res>? get pmsRoom;
}

/// @nodoc
class _$DeviceCopyWithImpl<$Res, $Val extends Device>
    implements $DeviceCopyWith<$Res> {
  _$DeviceCopyWithImpl(this._value, this._then);

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
              as Room?,
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
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $RoomCopyWith<$Res>? get pmsRoom {
    if (_value.pmsRoom == null) {
      return null;
    }

    return $RoomCopyWith<$Res>(_value.pmsRoom!, (value) {
      return _then(_value.copyWith(pmsRoom: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DeviceImplCopyWith<$Res> implements $DeviceCopyWith<$Res> {
  factory _$$DeviceImplCopyWith(
          _$DeviceImpl value, $Res Function(_$DeviceImpl) then) =
      __$$DeviceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String type,
      String status,
      Room? pmsRoom,
      int? pmsRoomId,
      String? ipAddress,
      String? macAddress,
      String? location,
      DateTime? lastSeen,
      Map<String, dynamic>? metadata,
      String? model,
      String? serialNumber,
      String? firmware,
      int? signalStrength,
      int? uptime,
      int? connectedClients,
      int? vlan,
      String? ssid,
      int? channel,
      int? totalUpload,
      int? totalDownload,
      double? currentUpload,
      double? currentDownload,
      double? packetLoss,
      int? latency,
      int? cpuUsage,
      int? memoryUsage,
      int? temperature,
      int? restartCount,
      int? maxClients,
      String? note,
      List<String>? images,
      List<String>? imageSignedIds});

  @override
  $RoomCopyWith<$Res>? get pmsRoom;
}

/// @nodoc
class __$$DeviceImplCopyWithImpl<$Res>
    extends _$DeviceCopyWithImpl<$Res, _$DeviceImpl>
    implements _$$DeviceImplCopyWith<$Res> {
  __$$DeviceImplCopyWithImpl(
      _$DeviceImpl _value, $Res Function(_$DeviceImpl) _then)
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
  }) {
    return _then(_$DeviceImpl(
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
              as Room?,
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
    ));
  }
}

/// @nodoc

class _$DeviceImpl extends _Device {
  const _$DeviceImpl(
      {required this.id,
      required this.name,
      required this.type,
      required this.status,
      this.pmsRoom,
      this.pmsRoomId,
      this.ipAddress,
      this.macAddress,
      this.location,
      this.lastSeen,
      final Map<String, dynamic>? metadata,
      this.model,
      this.serialNumber,
      this.firmware,
      this.signalStrength,
      this.uptime,
      this.connectedClients,
      this.vlan,
      this.ssid,
      this.channel,
      this.totalUpload,
      this.totalDownload,
      this.currentUpload,
      this.currentDownload,
      this.packetLoss,
      this.latency,
      this.cpuUsage,
      this.memoryUsage,
      this.temperature,
      this.restartCount,
      this.maxClients,
      this.note,
      final List<String>? images,
      final List<String>? imageSignedIds})
      : _metadata = metadata,
        _images = images,
        _imageSignedIds = imageSignedIds,
        super._();

  @override
  final String id;
  @override
  final String name;
  @override
  final String type;
  @override
  final String status;
  @override
  final Room? pmsRoom;
  @override
  final int? pmsRoomId;
  @override
  final String? ipAddress;
  @override
  final String? macAddress;
  @override
  final String? location;
  @override
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
  final String? serialNumber;
  @override
  final String? firmware;
  @override
  final int? signalStrength;
  @override
  final int? uptime;
  @override
  final int? connectedClients;
  @override
  final int? vlan;
  @override
  final String? ssid;
  @override
  final int? channel;
  @override
  final int? totalUpload;
  @override
  final int? totalDownload;
  @override
  final double? currentUpload;
  @override
  final double? currentDownload;
  @override
  final double? packetLoss;
  @override
  final int? latency;
  @override
  final int? cpuUsage;
  @override
  final int? memoryUsage;
  @override
  final int? temperature;
  @override
  final int? restartCount;
  @override
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
  List<String>? get imageSignedIds {
    final value = _imageSignedIds;
    if (value == null) return null;
    if (_imageSignedIds is EqualUnmodifiableListView) return _imageSignedIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'Device(id: $id, name: $name, type: $type, status: $status, pmsRoom: $pmsRoom, pmsRoomId: $pmsRoomId, ipAddress: $ipAddress, macAddress: $macAddress, location: $location, lastSeen: $lastSeen, metadata: $metadata, model: $model, serialNumber: $serialNumber, firmware: $firmware, signalStrength: $signalStrength, uptime: $uptime, connectedClients: $connectedClients, vlan: $vlan, ssid: $ssid, channel: $channel, totalUpload: $totalUpload, totalDownload: $totalDownload, currentUpload: $currentUpload, currentDownload: $currentDownload, packetLoss: $packetLoss, latency: $latency, cpuUsage: $cpuUsage, memoryUsage: $memoryUsage, temperature: $temperature, restartCount: $restartCount, maxClients: $maxClients, note: $note, images: $images, imageSignedIds: $imageSignedIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceImpl &&
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
                .equals(other._imageSignedIds, _imageSignedIds));
  }

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
        const DeepCollectionEquality().hash(_imageSignedIds)
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceImplCopyWith<_$DeviceImpl> get copyWith =>
      __$$DeviceImplCopyWithImpl<_$DeviceImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String name,
            String type,
            String status,
            Room? pmsRoom,
            int? pmsRoomId,
            String? ipAddress,
            String? macAddress,
            String? location,
            DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            String? serialNumber,
            String? firmware,
            int? signalStrength,
            int? uptime,
            int? connectedClients,
            int? vlan,
            String? ssid,
            int? channel,
            int? totalUpload,
            int? totalDownload,
            double? currentUpload,
            double? currentDownload,
            double? packetLoss,
            int? latency,
            int? cpuUsage,
            int? memoryUsage,
            int? temperature,
            int? restartCount,
            int? maxClients,
            String? note,
            List<String>? images,
            List<String>? imageSignedIds)
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
        imageSignedIds);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String name,
            String type,
            String status,
            Room? pmsRoom,
            int? pmsRoomId,
            String? ipAddress,
            String? macAddress,
            String? location,
            DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            String? serialNumber,
            String? firmware,
            int? signalStrength,
            int? uptime,
            int? connectedClients,
            int? vlan,
            String? ssid,
            int? channel,
            int? totalUpload,
            int? totalDownload,
            double? currentUpload,
            double? currentDownload,
            double? packetLoss,
            int? latency,
            int? cpuUsage,
            int? memoryUsage,
            int? temperature,
            int? restartCount,
            int? maxClients,
            String? note,
            List<String>? images,
            List<String>? imageSignedIds)?
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
        imageSignedIds);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String name,
            String type,
            String status,
            Room? pmsRoom,
            int? pmsRoomId,
            String? ipAddress,
            String? macAddress,
            String? location,
            DateTime? lastSeen,
            Map<String, dynamic>? metadata,
            String? model,
            String? serialNumber,
            String? firmware,
            int? signalStrength,
            int? uptime,
            int? connectedClients,
            int? vlan,
            String? ssid,
            int? channel,
            int? totalUpload,
            int? totalDownload,
            double? currentUpload,
            double? currentDownload,
            double? packetLoss,
            int? latency,
            int? cpuUsage,
            int? memoryUsage,
            int? temperature,
            int? restartCount,
            int? maxClients,
            String? note,
            List<String>? images,
            List<String>? imageSignedIds)?
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
          imageSignedIds);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Device value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Device value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Device value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _Device extends Device {
  const factory _Device(
      {required final String id,
      required final String name,
      required final String type,
      required final String status,
      final Room? pmsRoom,
      final int? pmsRoomId,
      final String? ipAddress,
      final String? macAddress,
      final String? location,
      final DateTime? lastSeen,
      final Map<String, dynamic>? metadata,
      final String? model,
      final String? serialNumber,
      final String? firmware,
      final int? signalStrength,
      final int? uptime,
      final int? connectedClients,
      final int? vlan,
      final String? ssid,
      final int? channel,
      final int? totalUpload,
      final int? totalDownload,
      final double? currentUpload,
      final double? currentDownload,
      final double? packetLoss,
      final int? latency,
      final int? cpuUsage,
      final int? memoryUsage,
      final int? temperature,
      final int? restartCount,
      final int? maxClients,
      final String? note,
      final List<String>? images,
      final List<String>? imageSignedIds}) = _$DeviceImpl;
  const _Device._() : super._();

  @override
  String get id;
  @override
  String get name;
  @override
  String get type;
  @override
  String get status;
  @override
  Room? get pmsRoom;
  @override
  int? get pmsRoomId;
  @override
  String? get ipAddress;
  @override
  String? get macAddress;
  @override
  String? get location;
  @override
  DateTime? get lastSeen;
  @override
  Map<String, dynamic>? get metadata;
  @override
  String? get model;
  @override
  String? get serialNumber;
  @override
  String? get firmware;
  @override
  int? get signalStrength;
  @override
  int? get uptime;
  @override
  int? get connectedClients;
  @override
  int? get vlan;
  @override
  String? get ssid;
  @override
  int? get channel;
  @override
  int? get totalUpload;
  @override
  int? get totalDownload;
  @override
  double? get currentUpload;
  @override
  double? get currentDownload;
  @override
  double? get packetLoss;
  @override
  int? get latency;
  @override
  int? get cpuUsage;
  @override
  int? get memoryUsage;
  @override
  int? get temperature;
  @override
  int? get restartCount;
  @override
  int? get maxClients;
  @override
  String? get note;
  @override
  List<String>? get images;
  @override

  /// Signed IDs for images - used for API operations (upload/delete).
  /// When updating images, the server expects signed IDs for existing images.
  List<String>? get imageSignedIds;
  @override
  @JsonKey(ignore: true)
  _$$DeviceImplCopyWith<_$DeviceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
