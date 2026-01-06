// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'network_device_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NetworkDevice _$NetworkDeviceFromJson(Map<String, dynamic> json) {
  switch (json['device_type']) {
    case 'ont':
      return ONTDevice.fromJson(json);
    case 'ap':
      return APDevice.fromJson(json);
    case 'switch':
      return SwitchDevice.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'device_type', 'NetworkDevice',
          'Invalid union type "${json['device_type']}"!');
  }
}

/// @nodoc
mixin _$NetworkDevice {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  bool get online => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  String? get model => throw _privateConstructorUsedError;
  String? get version => throw _privateConstructorUsedError;
  @JsonKey(name: 'serial_number')
  String? get serialNumber => throw _privateConstructorUsedError;
  String? get phase => throw _privateConstructorUsedError;
  String? get mac => throw _privateConstructorUsedError;
  List<dynamic> get images => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            int id,
            String name,
            bool online,
            String? note,
            String? model,
            String? version,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? phase,
            String? mac,
            String? ip,
            @JsonKey(name: 'is_registered') bool? isRegistered,
            @JsonKey(name: 'pms_room') Map<String, dynamic>? pmsRoom,
            String? uptime,
            @JsonKey(name: 'switch_port') Map<String, dynamic>? switchPort,
            @JsonKey(name: 'ont_onboarding_status')
            Map<String, dynamic>? onboardingStatus,
            @JsonKey(name: 'ont_ports') List<Map<String, dynamic>> ports,
            List<dynamic> images)
        ont,
    required TResult Function(
            int id,
            String name,
            bool online,
            String? note,
            String? model,
            String? version,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? phase,
            String? mac,
            String? ip,
            String? uptime,
            @JsonKey(name: 'connection_state') String? connectionState,
            @JsonKey(name: 'pms_room') Map<String, dynamic>? pmsRoom,
            @JsonKey(name: 'ap_onboarding_status')
            Map<String, dynamic>? onboardingStatus,
            List<dynamic> images)
        ap,
    required TResult Function(
            int id,
            String name,
            bool online,
            String? note,
            String? model,
            String? version,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? phase,
            String? mac,
            String? host,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'switch_ports') List<Map<String, dynamic>> ports,
            @JsonKey(name: 'last_config_sync_at') DateTime? lastConfigSync,
            @JsonKey(name: 'last_config_sync_attempt_at')
            DateTime? lastConfigSyncAttempt,
            List<dynamic> images)
        switchDevice,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            int id,
            String name,
            bool online,
            String? note,
            String? model,
            String? version,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? phase,
            String? mac,
            String? ip,
            @JsonKey(name: 'is_registered') bool? isRegistered,
            @JsonKey(name: 'pms_room') Map<String, dynamic>? pmsRoom,
            String? uptime,
            @JsonKey(name: 'switch_port') Map<String, dynamic>? switchPort,
            @JsonKey(name: 'ont_onboarding_status')
            Map<String, dynamic>? onboardingStatus,
            @JsonKey(name: 'ont_ports') List<Map<String, dynamic>> ports,
            List<dynamic> images)?
        ont,
    TResult? Function(
            int id,
            String name,
            bool online,
            String? note,
            String? model,
            String? version,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? phase,
            String? mac,
            String? ip,
            String? uptime,
            @JsonKey(name: 'connection_state') String? connectionState,
            @JsonKey(name: 'pms_room') Map<String, dynamic>? pmsRoom,
            @JsonKey(name: 'ap_onboarding_status')
            Map<String, dynamic>? onboardingStatus,
            List<dynamic> images)?
        ap,
    TResult? Function(
            int id,
            String name,
            bool online,
            String? note,
            String? model,
            String? version,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? phase,
            String? mac,
            String? host,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'switch_ports') List<Map<String, dynamic>> ports,
            @JsonKey(name: 'last_config_sync_at') DateTime? lastConfigSync,
            @JsonKey(name: 'last_config_sync_attempt_at')
            DateTime? lastConfigSyncAttempt,
            List<dynamic> images)?
        switchDevice,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            int id,
            String name,
            bool online,
            String? note,
            String? model,
            String? version,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? phase,
            String? mac,
            String? ip,
            @JsonKey(name: 'is_registered') bool? isRegistered,
            @JsonKey(name: 'pms_room') Map<String, dynamic>? pmsRoom,
            String? uptime,
            @JsonKey(name: 'switch_port') Map<String, dynamic>? switchPort,
            @JsonKey(name: 'ont_onboarding_status')
            Map<String, dynamic>? onboardingStatus,
            @JsonKey(name: 'ont_ports') List<Map<String, dynamic>> ports,
            List<dynamic> images)?
        ont,
    TResult Function(
            int id,
            String name,
            bool online,
            String? note,
            String? model,
            String? version,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? phase,
            String? mac,
            String? ip,
            String? uptime,
            @JsonKey(name: 'connection_state') String? connectionState,
            @JsonKey(name: 'pms_room') Map<String, dynamic>? pmsRoom,
            @JsonKey(name: 'ap_onboarding_status')
            Map<String, dynamic>? onboardingStatus,
            List<dynamic> images)?
        ap,
    TResult Function(
            int id,
            String name,
            bool online,
            String? note,
            String? model,
            String? version,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? phase,
            String? mac,
            String? host,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'switch_ports') List<Map<String, dynamic>> ports,
            @JsonKey(name: 'last_config_sync_at') DateTime? lastConfigSync,
            @JsonKey(name: 'last_config_sync_attempt_at')
            DateTime? lastConfigSyncAttempt,
            List<dynamic> images)?
        switchDevice,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ONTDevice value) ont,
    required TResult Function(APDevice value) ap,
    required TResult Function(SwitchDevice value) switchDevice,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ONTDevice value)? ont,
    TResult? Function(APDevice value)? ap,
    TResult? Function(SwitchDevice value)? switchDevice,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ONTDevice value)? ont,
    TResult Function(APDevice value)? ap,
    TResult Function(SwitchDevice value)? switchDevice,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $NetworkDeviceCopyWith<NetworkDevice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NetworkDeviceCopyWith<$Res> {
  factory $NetworkDeviceCopyWith(
          NetworkDevice value, $Res Function(NetworkDevice) then) =
      _$NetworkDeviceCopyWithImpl<$Res, NetworkDevice>;
  @useResult
  $Res call(
      {int id,
      String name,
      bool online,
      String? note,
      String? model,
      String? version,
      @JsonKey(name: 'serial_number') String? serialNumber,
      String? phase,
      String? mac,
      List<dynamic> images});
}

/// @nodoc
class _$NetworkDeviceCopyWithImpl<$Res, $Val extends NetworkDevice>
    implements $NetworkDeviceCopyWith<$Res> {
  _$NetworkDeviceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? online = null,
    Object? note = freezed,
    Object? model = freezed,
    Object? version = freezed,
    Object? serialNumber = freezed,
    Object? phase = freezed,
    Object? mac = freezed,
    Object? images = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      online: null == online
          ? _value.online
          : online // ignore: cast_nullable_to_non_nullable
              as bool,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      model: freezed == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String?,
      version: freezed == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String?,
      serialNumber: freezed == serialNumber
          ? _value.serialNumber
          : serialNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      phase: freezed == phase
          ? _value.phase
          : phase // ignore: cast_nullable_to_non_nullable
              as String?,
      mac: freezed == mac
          ? _value.mac
          : mac // ignore: cast_nullable_to_non_nullable
              as String?,
      images: null == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ONTDeviceImplCopyWith<$Res>
    implements $NetworkDeviceCopyWith<$Res> {
  factory _$$ONTDeviceImplCopyWith(
          _$ONTDeviceImpl value, $Res Function(_$ONTDeviceImpl) then) =
      __$$ONTDeviceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      bool online,
      String? note,
      String? model,
      String? version,
      @JsonKey(name: 'serial_number') String? serialNumber,
      String? phase,
      String? mac,
      String? ip,
      @JsonKey(name: 'is_registered') bool? isRegistered,
      @JsonKey(name: 'pms_room') Map<String, dynamic>? pmsRoom,
      String? uptime,
      @JsonKey(name: 'switch_port') Map<String, dynamic>? switchPort,
      @JsonKey(name: 'ont_onboarding_status')
      Map<String, dynamic>? onboardingStatus,
      @JsonKey(name: 'ont_ports') List<Map<String, dynamic>> ports,
      List<dynamic> images});
}

/// @nodoc
class __$$ONTDeviceImplCopyWithImpl<$Res>
    extends _$NetworkDeviceCopyWithImpl<$Res, _$ONTDeviceImpl>
    implements _$$ONTDeviceImplCopyWith<$Res> {
  __$$ONTDeviceImplCopyWithImpl(
      _$ONTDeviceImpl _value, $Res Function(_$ONTDeviceImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? online = null,
    Object? note = freezed,
    Object? model = freezed,
    Object? version = freezed,
    Object? serialNumber = freezed,
    Object? phase = freezed,
    Object? mac = freezed,
    Object? ip = freezed,
    Object? isRegistered = freezed,
    Object? pmsRoom = freezed,
    Object? uptime = freezed,
    Object? switchPort = freezed,
    Object? onboardingStatus = freezed,
    Object? ports = null,
    Object? images = null,
  }) {
    return _then(_$ONTDeviceImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      online: null == online
          ? _value.online
          : online // ignore: cast_nullable_to_non_nullable
              as bool,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      model: freezed == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String?,
      version: freezed == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String?,
      serialNumber: freezed == serialNumber
          ? _value.serialNumber
          : serialNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      phase: freezed == phase
          ? _value.phase
          : phase // ignore: cast_nullable_to_non_nullable
              as String?,
      mac: freezed == mac
          ? _value.mac
          : mac // ignore: cast_nullable_to_non_nullable
              as String?,
      ip: freezed == ip
          ? _value.ip
          : ip // ignore: cast_nullable_to_non_nullable
              as String?,
      isRegistered: freezed == isRegistered
          ? _value.isRegistered
          : isRegistered // ignore: cast_nullable_to_non_nullable
              as bool?,
      pmsRoom: freezed == pmsRoom
          ? _value._pmsRoom
          : pmsRoom // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      uptime: freezed == uptime
          ? _value.uptime
          : uptime // ignore: cast_nullable_to_non_nullable
              as String?,
      switchPort: freezed == switchPort
          ? _value._switchPort
          : switchPort // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      onboardingStatus: freezed == onboardingStatus
          ? _value._onboardingStatus
          : onboardingStatus // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      ports: null == ports
          ? _value._ports
          : ports // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      images: null == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ONTDeviceImpl implements ONTDevice {
  const _$ONTDeviceImpl(
      {required this.id,
      required this.name,
      required this.online,
      this.note,
      this.model,
      this.version,
      @JsonKey(name: 'serial_number') this.serialNumber,
      this.phase,
      this.mac,
      this.ip,
      @JsonKey(name: 'is_registered') this.isRegistered,
      @JsonKey(name: 'pms_room') final Map<String, dynamic>? pmsRoom,
      this.uptime,
      @JsonKey(name: 'switch_port') final Map<String, dynamic>? switchPort,
      @JsonKey(name: 'ont_onboarding_status')
      final Map<String, dynamic>? onboardingStatus,
      @JsonKey(name: 'ont_ports')
      final List<Map<String, dynamic>> ports = const [],
      final List<dynamic> images = const [],
      final String? $type})
      : _pmsRoom = pmsRoom,
        _switchPort = switchPort,
        _onboardingStatus = onboardingStatus,
        _ports = ports,
        _images = images,
        $type = $type ?? 'ont';

  factory _$ONTDeviceImpl.fromJson(Map<String, dynamic> json) =>
      _$$ONTDeviceImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final bool online;
  @override
  final String? note;
  @override
  final String? model;
  @override
  final String? version;
  @override
  @JsonKey(name: 'serial_number')
  final String? serialNumber;
  @override
  final String? phase;
  @override
  final String? mac;
  @override
  final String? ip;
  @override
  @JsonKey(name: 'is_registered')
  final bool? isRegistered;
  final Map<String, dynamic>? _pmsRoom;
  @override
  @JsonKey(name: 'pms_room')
  Map<String, dynamic>? get pmsRoom {
    final value = _pmsRoom;
    if (value == null) return null;
    if (_pmsRoom is EqualUnmodifiableMapView) return _pmsRoom;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? uptime;
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

  final List<Map<String, dynamic>> _ports;
  @override
  @JsonKey(name: 'ont_ports')
  List<Map<String, dynamic>> get ports {
    if (_ports is EqualUnmodifiableListView) return _ports;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ports);
  }

  final List<dynamic> _images;
  @override
  @JsonKey()
  List<dynamic> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @JsonKey(name: 'device_type')
  final String $type;

  @override
  String toString() {
    return 'NetworkDevice.ont(id: $id, name: $name, online: $online, note: $note, model: $model, version: $version, serialNumber: $serialNumber, phase: $phase, mac: $mac, ip: $ip, isRegistered: $isRegistered, pmsRoom: $pmsRoom, uptime: $uptime, switchPort: $switchPort, onboardingStatus: $onboardingStatus, ports: $ports, images: $images)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ONTDeviceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.online, online) || other.online == online) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.serialNumber, serialNumber) ||
                other.serialNumber == serialNumber) &&
            (identical(other.phase, phase) || other.phase == phase) &&
            (identical(other.mac, mac) || other.mac == mac) &&
            (identical(other.ip, ip) || other.ip == ip) &&
            (identical(other.isRegistered, isRegistered) ||
                other.isRegistered == isRegistered) &&
            const DeepCollectionEquality().equals(other._pmsRoom, _pmsRoom) &&
            (identical(other.uptime, uptime) || other.uptime == uptime) &&
            const DeepCollectionEquality()
                .equals(other._switchPort, _switchPort) &&
            const DeepCollectionEquality()
                .equals(other._onboardingStatus, _onboardingStatus) &&
            const DeepCollectionEquality().equals(other._ports, _ports) &&
            const DeepCollectionEquality().equals(other._images, _images));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      online,
      note,
      model,
      version,
      serialNumber,
      phase,
      mac,
      ip,
      isRegistered,
      const DeepCollectionEquality().hash(_pmsRoom),
      uptime,
      const DeepCollectionEquality().hash(_switchPort),
      const DeepCollectionEquality().hash(_onboardingStatus),
      const DeepCollectionEquality().hash(_ports),
      const DeepCollectionEquality().hash(_images));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ONTDeviceImplCopyWith<_$ONTDeviceImpl> get copyWith =>
      __$$ONTDeviceImplCopyWithImpl<_$ONTDeviceImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            int id,
            String name,
            bool online,
            String? note,
            String? model,
            String? version,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? phase,
            String? mac,
            String? ip,
            @JsonKey(name: 'is_registered') bool? isRegistered,
            @JsonKey(name: 'pms_room') Map<String, dynamic>? pmsRoom,
            String? uptime,
            @JsonKey(name: 'switch_port') Map<String, dynamic>? switchPort,
            @JsonKey(name: 'ont_onboarding_status')
            Map<String, dynamic>? onboardingStatus,
            @JsonKey(name: 'ont_ports') List<Map<String, dynamic>> ports,
            List<dynamic> images)
        ont,
    required TResult Function(
            int id,
            String name,
            bool online,
            String? note,
            String? model,
            String? version,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? phase,
            String? mac,
            String? ip,
            String? uptime,
            @JsonKey(name: 'connection_state') String? connectionState,
            @JsonKey(name: 'pms_room') Map<String, dynamic>? pmsRoom,
            @JsonKey(name: 'ap_onboarding_status')
            Map<String, dynamic>? onboardingStatus,
            List<dynamic> images)
        ap,
    required TResult Function(
            int id,
            String name,
            bool online,
            String? note,
            String? model,
            String? version,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? phase,
            String? mac,
            String? host,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'switch_ports') List<Map<String, dynamic>> ports,
            @JsonKey(name: 'last_config_sync_at') DateTime? lastConfigSync,
            @JsonKey(name: 'last_config_sync_attempt_at')
            DateTime? lastConfigSyncAttempt,
            List<dynamic> images)
        switchDevice,
  }) {
    return ont(
        id,
        name,
        online,
        note,
        model,
        version,
        serialNumber,
        phase,
        mac,
        ip,
        isRegistered,
        pmsRoom,
        uptime,
        switchPort,
        onboardingStatus,
        ports,
        images);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            int id,
            String name,
            bool online,
            String? note,
            String? model,
            String? version,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? phase,
            String? mac,
            String? ip,
            @JsonKey(name: 'is_registered') bool? isRegistered,
            @JsonKey(name: 'pms_room') Map<String, dynamic>? pmsRoom,
            String? uptime,
            @JsonKey(name: 'switch_port') Map<String, dynamic>? switchPort,
            @JsonKey(name: 'ont_onboarding_status')
            Map<String, dynamic>? onboardingStatus,
            @JsonKey(name: 'ont_ports') List<Map<String, dynamic>> ports,
            List<dynamic> images)?
        ont,
    TResult? Function(
            int id,
            String name,
            bool online,
            String? note,
            String? model,
            String? version,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? phase,
            String? mac,
            String? ip,
            String? uptime,
            @JsonKey(name: 'connection_state') String? connectionState,
            @JsonKey(name: 'pms_room') Map<String, dynamic>? pmsRoom,
            @JsonKey(name: 'ap_onboarding_status')
            Map<String, dynamic>? onboardingStatus,
            List<dynamic> images)?
        ap,
    TResult? Function(
            int id,
            String name,
            bool online,
            String? note,
            String? model,
            String? version,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? phase,
            String? mac,
            String? host,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'switch_ports') List<Map<String, dynamic>> ports,
            @JsonKey(name: 'last_config_sync_at') DateTime? lastConfigSync,
            @JsonKey(name: 'last_config_sync_attempt_at')
            DateTime? lastConfigSyncAttempt,
            List<dynamic> images)?
        switchDevice,
  }) {
    return ont?.call(
        id,
        name,
        online,
        note,
        model,
        version,
        serialNumber,
        phase,
        mac,
        ip,
        isRegistered,
        pmsRoom,
        uptime,
        switchPort,
        onboardingStatus,
        ports,
        images);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            int id,
            String name,
            bool online,
            String? note,
            String? model,
            String? version,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? phase,
            String? mac,
            String? ip,
            @JsonKey(name: 'is_registered') bool? isRegistered,
            @JsonKey(name: 'pms_room') Map<String, dynamic>? pmsRoom,
            String? uptime,
            @JsonKey(name: 'switch_port') Map<String, dynamic>? switchPort,
            @JsonKey(name: 'ont_onboarding_status')
            Map<String, dynamic>? onboardingStatus,
            @JsonKey(name: 'ont_ports') List<Map<String, dynamic>> ports,
            List<dynamic> images)?
        ont,
    TResult Function(
            int id,
            String name,
            bool online,
            String? note,
            String? model,
            String? version,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? phase,
            String? mac,
            String? ip,
            String? uptime,
            @JsonKey(name: 'connection_state') String? connectionState,
            @JsonKey(name: 'pms_room') Map<String, dynamic>? pmsRoom,
            @JsonKey(name: 'ap_onboarding_status')
            Map<String, dynamic>? onboardingStatus,
            List<dynamic> images)?
        ap,
    TResult Function(
            int id,
            String name,
            bool online,
            String? note,
            String? model,
            String? version,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? phase,
            String? mac,
            String? host,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'switch_ports') List<Map<String, dynamic>> ports,
            @JsonKey(name: 'last_config_sync_at') DateTime? lastConfigSync,
            @JsonKey(name: 'last_config_sync_attempt_at')
            DateTime? lastConfigSyncAttempt,
            List<dynamic> images)?
        switchDevice,
    required TResult orElse(),
  }) {
    if (ont != null) {
      return ont(
          id,
          name,
          online,
          note,
          model,
          version,
          serialNumber,
          phase,
          mac,
          ip,
          isRegistered,
          pmsRoom,
          uptime,
          switchPort,
          onboardingStatus,
          ports,
          images);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ONTDevice value) ont,
    required TResult Function(APDevice value) ap,
    required TResult Function(SwitchDevice value) switchDevice,
  }) {
    return ont(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ONTDevice value)? ont,
    TResult? Function(APDevice value)? ap,
    TResult? Function(SwitchDevice value)? switchDevice,
  }) {
    return ont?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ONTDevice value)? ont,
    TResult Function(APDevice value)? ap,
    TResult Function(SwitchDevice value)? switchDevice,
    required TResult orElse(),
  }) {
    if (ont != null) {
      return ont(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ONTDeviceImplToJson(
      this,
    );
  }
}

abstract class ONTDevice implements NetworkDevice {
  const factory ONTDevice(
      {required final int id,
      required final String name,
      required final bool online,
      final String? note,
      final String? model,
      final String? version,
      @JsonKey(name: 'serial_number') final String? serialNumber,
      final String? phase,
      final String? mac,
      final String? ip,
      @JsonKey(name: 'is_registered') final bool? isRegistered,
      @JsonKey(name: 'pms_room') final Map<String, dynamic>? pmsRoom,
      final String? uptime,
      @JsonKey(name: 'switch_port') final Map<String, dynamic>? switchPort,
      @JsonKey(name: 'ont_onboarding_status')
      final Map<String, dynamic>? onboardingStatus,
      @JsonKey(name: 'ont_ports') final List<Map<String, dynamic>> ports,
      final List<dynamic> images}) = _$ONTDeviceImpl;

  factory ONTDevice.fromJson(Map<String, dynamic> json) =
      _$ONTDeviceImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  bool get online;
  @override
  String? get note;
  @override
  String? get model;
  @override
  String? get version;
  @override
  @JsonKey(name: 'serial_number')
  String? get serialNumber;
  @override
  String? get phase;
  @override
  String? get mac;
  String? get ip;
  @JsonKey(name: 'is_registered')
  bool? get isRegistered;
  @JsonKey(name: 'pms_room')
  Map<String, dynamic>? get pmsRoom;
  String? get uptime;
  @JsonKey(name: 'switch_port')
  Map<String, dynamic>? get switchPort;
  @JsonKey(name: 'ont_onboarding_status')
  Map<String, dynamic>? get onboardingStatus;
  @JsonKey(name: 'ont_ports')
  List<Map<String, dynamic>> get ports;
  @override
  List<dynamic> get images;
  @override
  @JsonKey(ignore: true)
  _$$ONTDeviceImplCopyWith<_$ONTDeviceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$APDeviceImplCopyWith<$Res>
    implements $NetworkDeviceCopyWith<$Res> {
  factory _$$APDeviceImplCopyWith(
          _$APDeviceImpl value, $Res Function(_$APDeviceImpl) then) =
      __$$APDeviceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      bool online,
      String? note,
      String? model,
      String? version,
      @JsonKey(name: 'serial_number') String? serialNumber,
      String? phase,
      String? mac,
      String? ip,
      String? uptime,
      @JsonKey(name: 'connection_state') String? connectionState,
      @JsonKey(name: 'pms_room') Map<String, dynamic>? pmsRoom,
      @JsonKey(name: 'ap_onboarding_status')
      Map<String, dynamic>? onboardingStatus,
      List<dynamic> images});
}

/// @nodoc
class __$$APDeviceImplCopyWithImpl<$Res>
    extends _$NetworkDeviceCopyWithImpl<$Res, _$APDeviceImpl>
    implements _$$APDeviceImplCopyWith<$Res> {
  __$$APDeviceImplCopyWithImpl(
      _$APDeviceImpl _value, $Res Function(_$APDeviceImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? online = null,
    Object? note = freezed,
    Object? model = freezed,
    Object? version = freezed,
    Object? serialNumber = freezed,
    Object? phase = freezed,
    Object? mac = freezed,
    Object? ip = freezed,
    Object? uptime = freezed,
    Object? connectionState = freezed,
    Object? pmsRoom = freezed,
    Object? onboardingStatus = freezed,
    Object? images = null,
  }) {
    return _then(_$APDeviceImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      online: null == online
          ? _value.online
          : online // ignore: cast_nullable_to_non_nullable
              as bool,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      model: freezed == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String?,
      version: freezed == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String?,
      serialNumber: freezed == serialNumber
          ? _value.serialNumber
          : serialNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      phase: freezed == phase
          ? _value.phase
          : phase // ignore: cast_nullable_to_non_nullable
              as String?,
      mac: freezed == mac
          ? _value.mac
          : mac // ignore: cast_nullable_to_non_nullable
              as String?,
      ip: freezed == ip
          ? _value.ip
          : ip // ignore: cast_nullable_to_non_nullable
              as String?,
      uptime: freezed == uptime
          ? _value.uptime
          : uptime // ignore: cast_nullable_to_non_nullable
              as String?,
      connectionState: freezed == connectionState
          ? _value.connectionState
          : connectionState // ignore: cast_nullable_to_non_nullable
              as String?,
      pmsRoom: freezed == pmsRoom
          ? _value._pmsRoom
          : pmsRoom // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      onboardingStatus: freezed == onboardingStatus
          ? _value._onboardingStatus
          : onboardingStatus // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      images: null == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$APDeviceImpl implements APDevice {
  const _$APDeviceImpl(
      {required this.id,
      required this.name,
      required this.online,
      this.note,
      this.model,
      this.version,
      @JsonKey(name: 'serial_number') this.serialNumber,
      this.phase,
      this.mac,
      this.ip,
      this.uptime,
      @JsonKey(name: 'connection_state') this.connectionState,
      @JsonKey(name: 'pms_room') final Map<String, dynamic>? pmsRoom,
      @JsonKey(name: 'ap_onboarding_status')
      final Map<String, dynamic>? onboardingStatus,
      final List<dynamic> images = const [],
      final String? $type})
      : _pmsRoom = pmsRoom,
        _onboardingStatus = onboardingStatus,
        _images = images,
        $type = $type ?? 'ap';

  factory _$APDeviceImpl.fromJson(Map<String, dynamic> json) =>
      _$$APDeviceImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final bool online;
  @override
  final String? note;
  @override
  final String? model;
  @override
  final String? version;
  @override
  @JsonKey(name: 'serial_number')
  final String? serialNumber;
  @override
  final String? phase;
  @override
  final String? mac;
  @override
  final String? ip;
  @override
  final String? uptime;
  @override
  @JsonKey(name: 'connection_state')
  final String? connectionState;
  final Map<String, dynamic>? _pmsRoom;
  @override
  @JsonKey(name: 'pms_room')
  Map<String, dynamic>? get pmsRoom {
    final value = _pmsRoom;
    if (value == null) return null;
    if (_pmsRoom is EqualUnmodifiableMapView) return _pmsRoom;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

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

  final List<dynamic> _images;
  @override
  @JsonKey()
  List<dynamic> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @JsonKey(name: 'device_type')
  final String $type;

  @override
  String toString() {
    return 'NetworkDevice.ap(id: $id, name: $name, online: $online, note: $note, model: $model, version: $version, serialNumber: $serialNumber, phase: $phase, mac: $mac, ip: $ip, uptime: $uptime, connectionState: $connectionState, pmsRoom: $pmsRoom, onboardingStatus: $onboardingStatus, images: $images)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$APDeviceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.online, online) || other.online == online) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.serialNumber, serialNumber) ||
                other.serialNumber == serialNumber) &&
            (identical(other.phase, phase) || other.phase == phase) &&
            (identical(other.mac, mac) || other.mac == mac) &&
            (identical(other.ip, ip) || other.ip == ip) &&
            (identical(other.uptime, uptime) || other.uptime == uptime) &&
            (identical(other.connectionState, connectionState) ||
                other.connectionState == connectionState) &&
            const DeepCollectionEquality().equals(other._pmsRoom, _pmsRoom) &&
            const DeepCollectionEquality()
                .equals(other._onboardingStatus, _onboardingStatus) &&
            const DeepCollectionEquality().equals(other._images, _images));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      online,
      note,
      model,
      version,
      serialNumber,
      phase,
      mac,
      ip,
      uptime,
      connectionState,
      const DeepCollectionEquality().hash(_pmsRoom),
      const DeepCollectionEquality().hash(_onboardingStatus),
      const DeepCollectionEquality().hash(_images));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$APDeviceImplCopyWith<_$APDeviceImpl> get copyWith =>
      __$$APDeviceImplCopyWithImpl<_$APDeviceImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            int id,
            String name,
            bool online,
            String? note,
            String? model,
            String? version,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? phase,
            String? mac,
            String? ip,
            @JsonKey(name: 'is_registered') bool? isRegistered,
            @JsonKey(name: 'pms_room') Map<String, dynamic>? pmsRoom,
            String? uptime,
            @JsonKey(name: 'switch_port') Map<String, dynamic>? switchPort,
            @JsonKey(name: 'ont_onboarding_status')
            Map<String, dynamic>? onboardingStatus,
            @JsonKey(name: 'ont_ports') List<Map<String, dynamic>> ports,
            List<dynamic> images)
        ont,
    required TResult Function(
            int id,
            String name,
            bool online,
            String? note,
            String? model,
            String? version,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? phase,
            String? mac,
            String? ip,
            String? uptime,
            @JsonKey(name: 'connection_state') String? connectionState,
            @JsonKey(name: 'pms_room') Map<String, dynamic>? pmsRoom,
            @JsonKey(name: 'ap_onboarding_status')
            Map<String, dynamic>? onboardingStatus,
            List<dynamic> images)
        ap,
    required TResult Function(
            int id,
            String name,
            bool online,
            String? note,
            String? model,
            String? version,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? phase,
            String? mac,
            String? host,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'switch_ports') List<Map<String, dynamic>> ports,
            @JsonKey(name: 'last_config_sync_at') DateTime? lastConfigSync,
            @JsonKey(name: 'last_config_sync_attempt_at')
            DateTime? lastConfigSyncAttempt,
            List<dynamic> images)
        switchDevice,
  }) {
    return ap(id, name, online, note, model, version, serialNumber, phase, mac,
        ip, uptime, connectionState, pmsRoom, onboardingStatus, images);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            int id,
            String name,
            bool online,
            String? note,
            String? model,
            String? version,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? phase,
            String? mac,
            String? ip,
            @JsonKey(name: 'is_registered') bool? isRegistered,
            @JsonKey(name: 'pms_room') Map<String, dynamic>? pmsRoom,
            String? uptime,
            @JsonKey(name: 'switch_port') Map<String, dynamic>? switchPort,
            @JsonKey(name: 'ont_onboarding_status')
            Map<String, dynamic>? onboardingStatus,
            @JsonKey(name: 'ont_ports') List<Map<String, dynamic>> ports,
            List<dynamic> images)?
        ont,
    TResult? Function(
            int id,
            String name,
            bool online,
            String? note,
            String? model,
            String? version,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? phase,
            String? mac,
            String? ip,
            String? uptime,
            @JsonKey(name: 'connection_state') String? connectionState,
            @JsonKey(name: 'pms_room') Map<String, dynamic>? pmsRoom,
            @JsonKey(name: 'ap_onboarding_status')
            Map<String, dynamic>? onboardingStatus,
            List<dynamic> images)?
        ap,
    TResult? Function(
            int id,
            String name,
            bool online,
            String? note,
            String? model,
            String? version,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? phase,
            String? mac,
            String? host,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'switch_ports') List<Map<String, dynamic>> ports,
            @JsonKey(name: 'last_config_sync_at') DateTime? lastConfigSync,
            @JsonKey(name: 'last_config_sync_attempt_at')
            DateTime? lastConfigSyncAttempt,
            List<dynamic> images)?
        switchDevice,
  }) {
    return ap?.call(id, name, online, note, model, version, serialNumber, phase,
        mac, ip, uptime, connectionState, pmsRoom, onboardingStatus, images);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            int id,
            String name,
            bool online,
            String? note,
            String? model,
            String? version,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? phase,
            String? mac,
            String? ip,
            @JsonKey(name: 'is_registered') bool? isRegistered,
            @JsonKey(name: 'pms_room') Map<String, dynamic>? pmsRoom,
            String? uptime,
            @JsonKey(name: 'switch_port') Map<String, dynamic>? switchPort,
            @JsonKey(name: 'ont_onboarding_status')
            Map<String, dynamic>? onboardingStatus,
            @JsonKey(name: 'ont_ports') List<Map<String, dynamic>> ports,
            List<dynamic> images)?
        ont,
    TResult Function(
            int id,
            String name,
            bool online,
            String? note,
            String? model,
            String? version,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? phase,
            String? mac,
            String? ip,
            String? uptime,
            @JsonKey(name: 'connection_state') String? connectionState,
            @JsonKey(name: 'pms_room') Map<String, dynamic>? pmsRoom,
            @JsonKey(name: 'ap_onboarding_status')
            Map<String, dynamic>? onboardingStatus,
            List<dynamic> images)?
        ap,
    TResult Function(
            int id,
            String name,
            bool online,
            String? note,
            String? model,
            String? version,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? phase,
            String? mac,
            String? host,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'switch_ports') List<Map<String, dynamic>> ports,
            @JsonKey(name: 'last_config_sync_at') DateTime? lastConfigSync,
            @JsonKey(name: 'last_config_sync_attempt_at')
            DateTime? lastConfigSyncAttempt,
            List<dynamic> images)?
        switchDevice,
    required TResult orElse(),
  }) {
    if (ap != null) {
      return ap(id, name, online, note, model, version, serialNumber, phase,
          mac, ip, uptime, connectionState, pmsRoom, onboardingStatus, images);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ONTDevice value) ont,
    required TResult Function(APDevice value) ap,
    required TResult Function(SwitchDevice value) switchDevice,
  }) {
    return ap(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ONTDevice value)? ont,
    TResult? Function(APDevice value)? ap,
    TResult? Function(SwitchDevice value)? switchDevice,
  }) {
    return ap?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ONTDevice value)? ont,
    TResult Function(APDevice value)? ap,
    TResult Function(SwitchDevice value)? switchDevice,
    required TResult orElse(),
  }) {
    if (ap != null) {
      return ap(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$APDeviceImplToJson(
      this,
    );
  }
}

abstract class APDevice implements NetworkDevice {
  const factory APDevice(
      {required final int id,
      required final String name,
      required final bool online,
      final String? note,
      final String? model,
      final String? version,
      @JsonKey(name: 'serial_number') final String? serialNumber,
      final String? phase,
      final String? mac,
      final String? ip,
      final String? uptime,
      @JsonKey(name: 'connection_state') final String? connectionState,
      @JsonKey(name: 'pms_room') final Map<String, dynamic>? pmsRoom,
      @JsonKey(name: 'ap_onboarding_status')
      final Map<String, dynamic>? onboardingStatus,
      final List<dynamic> images}) = _$APDeviceImpl;

  factory APDevice.fromJson(Map<String, dynamic> json) =
      _$APDeviceImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  bool get online;
  @override
  String? get note;
  @override
  String? get model;
  @override
  String? get version;
  @override
  @JsonKey(name: 'serial_number')
  String? get serialNumber;
  @override
  String? get phase;
  @override
  String? get mac;
  String? get ip;
  String? get uptime;
  @JsonKey(name: 'connection_state')
  String? get connectionState;
  @JsonKey(name: 'pms_room')
  Map<String, dynamic>? get pmsRoom;
  @JsonKey(name: 'ap_onboarding_status')
  Map<String, dynamic>? get onboardingStatus;
  @override
  List<dynamic> get images;
  @override
  @JsonKey(ignore: true)
  _$$APDeviceImplCopyWith<_$APDeviceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SwitchDeviceImplCopyWith<$Res>
    implements $NetworkDeviceCopyWith<$Res> {
  factory _$$SwitchDeviceImplCopyWith(
          _$SwitchDeviceImpl value, $Res Function(_$SwitchDeviceImpl) then) =
      __$$SwitchDeviceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      bool online,
      String? note,
      String? model,
      String? version,
      @JsonKey(name: 'serial_number') String? serialNumber,
      String? phase,
      String? mac,
      String? host,
      @JsonKey(name: 'ip_address') String? ipAddress,
      @JsonKey(name: 'switch_ports') List<Map<String, dynamic>> ports,
      @JsonKey(name: 'last_config_sync_at') DateTime? lastConfigSync,
      @JsonKey(name: 'last_config_sync_attempt_at')
      DateTime? lastConfigSyncAttempt,
      List<dynamic> images});
}

/// @nodoc
class __$$SwitchDeviceImplCopyWithImpl<$Res>
    extends _$NetworkDeviceCopyWithImpl<$Res, _$SwitchDeviceImpl>
    implements _$$SwitchDeviceImplCopyWith<$Res> {
  __$$SwitchDeviceImplCopyWithImpl(
      _$SwitchDeviceImpl _value, $Res Function(_$SwitchDeviceImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? online = null,
    Object? note = freezed,
    Object? model = freezed,
    Object? version = freezed,
    Object? serialNumber = freezed,
    Object? phase = freezed,
    Object? mac = freezed,
    Object? host = freezed,
    Object? ipAddress = freezed,
    Object? ports = null,
    Object? lastConfigSync = freezed,
    Object? lastConfigSyncAttempt = freezed,
    Object? images = null,
  }) {
    return _then(_$SwitchDeviceImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      online: null == online
          ? _value.online
          : online // ignore: cast_nullable_to_non_nullable
              as bool,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      model: freezed == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String?,
      version: freezed == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String?,
      serialNumber: freezed == serialNumber
          ? _value.serialNumber
          : serialNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      phase: freezed == phase
          ? _value.phase
          : phase // ignore: cast_nullable_to_non_nullable
              as String?,
      mac: freezed == mac
          ? _value.mac
          : mac // ignore: cast_nullable_to_non_nullable
              as String?,
      host: freezed == host
          ? _value.host
          : host // ignore: cast_nullable_to_non_nullable
              as String?,
      ipAddress: freezed == ipAddress
          ? _value.ipAddress
          : ipAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      ports: null == ports
          ? _value._ports
          : ports // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      lastConfigSync: freezed == lastConfigSync
          ? _value.lastConfigSync
          : lastConfigSync // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastConfigSyncAttempt: freezed == lastConfigSyncAttempt
          ? _value.lastConfigSyncAttempt
          : lastConfigSyncAttempt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      images: null == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SwitchDeviceImpl implements SwitchDevice {
  const _$SwitchDeviceImpl(
      {required this.id,
      required this.name,
      required this.online,
      this.note,
      this.model,
      this.version,
      @JsonKey(name: 'serial_number') this.serialNumber,
      this.phase,
      this.mac,
      this.host,
      @JsonKey(name: 'ip_address') this.ipAddress,
      @JsonKey(name: 'switch_ports')
      final List<Map<String, dynamic>> ports = const [],
      @JsonKey(name: 'last_config_sync_at') this.lastConfigSync,
      @JsonKey(name: 'last_config_sync_attempt_at') this.lastConfigSyncAttempt,
      final List<dynamic> images = const [],
      final String? $type})
      : _ports = ports,
        _images = images,
        $type = $type ?? 'switch';

  factory _$SwitchDeviceImpl.fromJson(Map<String, dynamic> json) =>
      _$$SwitchDeviceImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final bool online;
  @override
  final String? note;
  @override
  final String? model;
  @override
  final String? version;
  @override
  @JsonKey(name: 'serial_number')
  final String? serialNumber;
  @override
  final String? phase;
  @override
  final String? mac;
  @override
  final String? host;
  @override
  @JsonKey(name: 'ip_address')
  final String? ipAddress;
  final List<Map<String, dynamic>> _ports;
  @override
  @JsonKey(name: 'switch_ports')
  List<Map<String, dynamic>> get ports {
    if (_ports is EqualUnmodifiableListView) return _ports;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ports);
  }

  @override
  @JsonKey(name: 'last_config_sync_at')
  final DateTime? lastConfigSync;
  @override
  @JsonKey(name: 'last_config_sync_attempt_at')
  final DateTime? lastConfigSyncAttempt;
  final List<dynamic> _images;
  @override
  @JsonKey()
  List<dynamic> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @JsonKey(name: 'device_type')
  final String $type;

  @override
  String toString() {
    return 'NetworkDevice.switchDevice(id: $id, name: $name, online: $online, note: $note, model: $model, version: $version, serialNumber: $serialNumber, phase: $phase, mac: $mac, host: $host, ipAddress: $ipAddress, ports: $ports, lastConfigSync: $lastConfigSync, lastConfigSyncAttempt: $lastConfigSyncAttempt, images: $images)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SwitchDeviceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.online, online) || other.online == online) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.serialNumber, serialNumber) ||
                other.serialNumber == serialNumber) &&
            (identical(other.phase, phase) || other.phase == phase) &&
            (identical(other.mac, mac) || other.mac == mac) &&
            (identical(other.host, host) || other.host == host) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            const DeepCollectionEquality().equals(other._ports, _ports) &&
            (identical(other.lastConfigSync, lastConfigSync) ||
                other.lastConfigSync == lastConfigSync) &&
            (identical(other.lastConfigSyncAttempt, lastConfigSyncAttempt) ||
                other.lastConfigSyncAttempt == lastConfigSyncAttempt) &&
            const DeepCollectionEquality().equals(other._images, _images));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      online,
      note,
      model,
      version,
      serialNumber,
      phase,
      mac,
      host,
      ipAddress,
      const DeepCollectionEquality().hash(_ports),
      lastConfigSync,
      lastConfigSyncAttempt,
      const DeepCollectionEquality().hash(_images));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SwitchDeviceImplCopyWith<_$SwitchDeviceImpl> get copyWith =>
      __$$SwitchDeviceImplCopyWithImpl<_$SwitchDeviceImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            int id,
            String name,
            bool online,
            String? note,
            String? model,
            String? version,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? phase,
            String? mac,
            String? ip,
            @JsonKey(name: 'is_registered') bool? isRegistered,
            @JsonKey(name: 'pms_room') Map<String, dynamic>? pmsRoom,
            String? uptime,
            @JsonKey(name: 'switch_port') Map<String, dynamic>? switchPort,
            @JsonKey(name: 'ont_onboarding_status')
            Map<String, dynamic>? onboardingStatus,
            @JsonKey(name: 'ont_ports') List<Map<String, dynamic>> ports,
            List<dynamic> images)
        ont,
    required TResult Function(
            int id,
            String name,
            bool online,
            String? note,
            String? model,
            String? version,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? phase,
            String? mac,
            String? ip,
            String? uptime,
            @JsonKey(name: 'connection_state') String? connectionState,
            @JsonKey(name: 'pms_room') Map<String, dynamic>? pmsRoom,
            @JsonKey(name: 'ap_onboarding_status')
            Map<String, dynamic>? onboardingStatus,
            List<dynamic> images)
        ap,
    required TResult Function(
            int id,
            String name,
            bool online,
            String? note,
            String? model,
            String? version,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? phase,
            String? mac,
            String? host,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'switch_ports') List<Map<String, dynamic>> ports,
            @JsonKey(name: 'last_config_sync_at') DateTime? lastConfigSync,
            @JsonKey(name: 'last_config_sync_attempt_at')
            DateTime? lastConfigSyncAttempt,
            List<dynamic> images)
        switchDevice,
  }) {
    return switchDevice(
        id,
        name,
        online,
        note,
        model,
        version,
        serialNumber,
        phase,
        mac,
        host,
        ipAddress,
        ports,
        lastConfigSync,
        lastConfigSyncAttempt,
        images);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            int id,
            String name,
            bool online,
            String? note,
            String? model,
            String? version,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? phase,
            String? mac,
            String? ip,
            @JsonKey(name: 'is_registered') bool? isRegistered,
            @JsonKey(name: 'pms_room') Map<String, dynamic>? pmsRoom,
            String? uptime,
            @JsonKey(name: 'switch_port') Map<String, dynamic>? switchPort,
            @JsonKey(name: 'ont_onboarding_status')
            Map<String, dynamic>? onboardingStatus,
            @JsonKey(name: 'ont_ports') List<Map<String, dynamic>> ports,
            List<dynamic> images)?
        ont,
    TResult? Function(
            int id,
            String name,
            bool online,
            String? note,
            String? model,
            String? version,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? phase,
            String? mac,
            String? ip,
            String? uptime,
            @JsonKey(name: 'connection_state') String? connectionState,
            @JsonKey(name: 'pms_room') Map<String, dynamic>? pmsRoom,
            @JsonKey(name: 'ap_onboarding_status')
            Map<String, dynamic>? onboardingStatus,
            List<dynamic> images)?
        ap,
    TResult? Function(
            int id,
            String name,
            bool online,
            String? note,
            String? model,
            String? version,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? phase,
            String? mac,
            String? host,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'switch_ports') List<Map<String, dynamic>> ports,
            @JsonKey(name: 'last_config_sync_at') DateTime? lastConfigSync,
            @JsonKey(name: 'last_config_sync_attempt_at')
            DateTime? lastConfigSyncAttempt,
            List<dynamic> images)?
        switchDevice,
  }) {
    return switchDevice?.call(
        id,
        name,
        online,
        note,
        model,
        version,
        serialNumber,
        phase,
        mac,
        host,
        ipAddress,
        ports,
        lastConfigSync,
        lastConfigSyncAttempt,
        images);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            int id,
            String name,
            bool online,
            String? note,
            String? model,
            String? version,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? phase,
            String? mac,
            String? ip,
            @JsonKey(name: 'is_registered') bool? isRegistered,
            @JsonKey(name: 'pms_room') Map<String, dynamic>? pmsRoom,
            String? uptime,
            @JsonKey(name: 'switch_port') Map<String, dynamic>? switchPort,
            @JsonKey(name: 'ont_onboarding_status')
            Map<String, dynamic>? onboardingStatus,
            @JsonKey(name: 'ont_ports') List<Map<String, dynamic>> ports,
            List<dynamic> images)?
        ont,
    TResult Function(
            int id,
            String name,
            bool online,
            String? note,
            String? model,
            String? version,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? phase,
            String? mac,
            String? ip,
            String? uptime,
            @JsonKey(name: 'connection_state') String? connectionState,
            @JsonKey(name: 'pms_room') Map<String, dynamic>? pmsRoom,
            @JsonKey(name: 'ap_onboarding_status')
            Map<String, dynamic>? onboardingStatus,
            List<dynamic> images)?
        ap,
    TResult Function(
            int id,
            String name,
            bool online,
            String? note,
            String? model,
            String? version,
            @JsonKey(name: 'serial_number') String? serialNumber,
            String? phase,
            String? mac,
            String? host,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'switch_ports') List<Map<String, dynamic>> ports,
            @JsonKey(name: 'last_config_sync_at') DateTime? lastConfigSync,
            @JsonKey(name: 'last_config_sync_attempt_at')
            DateTime? lastConfigSyncAttempt,
            List<dynamic> images)?
        switchDevice,
    required TResult orElse(),
  }) {
    if (switchDevice != null) {
      return switchDevice(
          id,
          name,
          online,
          note,
          model,
          version,
          serialNumber,
          phase,
          mac,
          host,
          ipAddress,
          ports,
          lastConfigSync,
          lastConfigSyncAttempt,
          images);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ONTDevice value) ont,
    required TResult Function(APDevice value) ap,
    required TResult Function(SwitchDevice value) switchDevice,
  }) {
    return switchDevice(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ONTDevice value)? ont,
    TResult? Function(APDevice value)? ap,
    TResult? Function(SwitchDevice value)? switchDevice,
  }) {
    return switchDevice?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ONTDevice value)? ont,
    TResult Function(APDevice value)? ap,
    TResult Function(SwitchDevice value)? switchDevice,
    required TResult orElse(),
  }) {
    if (switchDevice != null) {
      return switchDevice(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$SwitchDeviceImplToJson(
      this,
    );
  }
}

abstract class SwitchDevice implements NetworkDevice {
  const factory SwitchDevice(
      {required final int id,
      required final String name,
      required final bool online,
      final String? note,
      final String? model,
      final String? version,
      @JsonKey(name: 'serial_number') final String? serialNumber,
      final String? phase,
      final String? mac,
      final String? host,
      @JsonKey(name: 'ip_address') final String? ipAddress,
      @JsonKey(name: 'switch_ports') final List<Map<String, dynamic>> ports,
      @JsonKey(name: 'last_config_sync_at') final DateTime? lastConfigSync,
      @JsonKey(name: 'last_config_sync_attempt_at')
      final DateTime? lastConfigSyncAttempt,
      final List<dynamic> images}) = _$SwitchDeviceImpl;

  factory SwitchDevice.fromJson(Map<String, dynamic> json) =
      _$SwitchDeviceImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  bool get online;
  @override
  String? get note;
  @override
  String? get model;
  @override
  String? get version;
  @override
  @JsonKey(name: 'serial_number')
  String? get serialNumber;
  @override
  String? get phase;
  @override
  String? get mac;
  String? get host;
  @JsonKey(name: 'ip_address')
  String? get ipAddress;
  @JsonKey(name: 'switch_ports')
  List<Map<String, dynamic>> get ports;
  @JsonKey(name: 'last_config_sync_at')
  DateTime? get lastConfigSync;
  @JsonKey(name: 'last_config_sync_attempt_at')
  DateTime? get lastConfigSyncAttempt;
  @override
  List<dynamic> get images;
  @override
  @JsonKey(ignore: true)
  _$$SwitchDeviceImplCopyWith<_$SwitchDeviceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
