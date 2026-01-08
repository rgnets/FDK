// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_registration_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DeviceRegistrationState {
  RegistrationStatus get status => throw _privateConstructorUsedError;
  DeviceMatchStatus get matchStatus => throw _privateConstructorUsedError;
  String? get scannedMac => throw _privateConstructorUsedError;
  String? get scannedSerial => throw _privateConstructorUsedError;
  String? get deviceType => throw _privateConstructorUsedError;
  int? get matchedDeviceId => throw _privateConstructorUsedError;
  String? get matchedDeviceName => throw _privateConstructorUsedError;

  /// Current room ID of matched device (for move/reset detection)
  int? get matchedDeviceRoomId => throw _privateConstructorUsedError;

  /// Current room name of matched device (for display)
  String? get matchedDeviceRoomName => throw _privateConstructorUsedError;
  MatchMismatchInfo? get mismatchInfo => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  DateTime? get registeredAt => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            RegistrationStatus status,
            DeviceMatchStatus matchStatus,
            String? scannedMac,
            String? scannedSerial,
            String? deviceType,
            int? matchedDeviceId,
            String? matchedDeviceName,
            int? matchedDeviceRoomId,
            String? matchedDeviceRoomName,
            MatchMismatchInfo? mismatchInfo,
            String? errorMessage,
            DateTime? registeredAt)
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            RegistrationStatus status,
            DeviceMatchStatus matchStatus,
            String? scannedMac,
            String? scannedSerial,
            String? deviceType,
            int? matchedDeviceId,
            String? matchedDeviceName,
            int? matchedDeviceRoomId,
            String? matchedDeviceRoomName,
            MatchMismatchInfo? mismatchInfo,
            String? errorMessage,
            DateTime? registeredAt)?
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            RegistrationStatus status,
            DeviceMatchStatus matchStatus,
            String? scannedMac,
            String? scannedSerial,
            String? deviceType,
            int? matchedDeviceId,
            String? matchedDeviceName,
            int? matchedDeviceRoomId,
            String? matchedDeviceRoomName,
            MatchMismatchInfo? mismatchInfo,
            String? errorMessage,
            DateTime? registeredAt)?
        $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_DeviceRegistrationState value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_DeviceRegistrationState value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_DeviceRegistrationState value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DeviceRegistrationStateCopyWith<DeviceRegistrationState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeviceRegistrationStateCopyWith<$Res> {
  factory $DeviceRegistrationStateCopyWith(DeviceRegistrationState value,
          $Res Function(DeviceRegistrationState) then) =
      _$DeviceRegistrationStateCopyWithImpl<$Res, DeviceRegistrationState>;
  @useResult
  $Res call(
      {RegistrationStatus status,
      DeviceMatchStatus matchStatus,
      String? scannedMac,
      String? scannedSerial,
      String? deviceType,
      int? matchedDeviceId,
      String? matchedDeviceName,
      int? matchedDeviceRoomId,
      String? matchedDeviceRoomName,
      MatchMismatchInfo? mismatchInfo,
      String? errorMessage,
      DateTime? registeredAt});

  $MatchMismatchInfoCopyWith<$Res>? get mismatchInfo;
}

/// @nodoc
class _$DeviceRegistrationStateCopyWithImpl<$Res,
        $Val extends DeviceRegistrationState>
    implements $DeviceRegistrationStateCopyWith<$Res> {
  _$DeviceRegistrationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? matchStatus = null,
    Object? scannedMac = freezed,
    Object? scannedSerial = freezed,
    Object? deviceType = freezed,
    Object? matchedDeviceId = freezed,
    Object? matchedDeviceName = freezed,
    Object? matchedDeviceRoomId = freezed,
    Object? matchedDeviceRoomName = freezed,
    Object? mismatchInfo = freezed,
    Object? errorMessage = freezed,
    Object? registeredAt = freezed,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as RegistrationStatus,
      matchStatus: null == matchStatus
          ? _value.matchStatus
          : matchStatus // ignore: cast_nullable_to_non_nullable
              as DeviceMatchStatus,
      scannedMac: freezed == scannedMac
          ? _value.scannedMac
          : scannedMac // ignore: cast_nullable_to_non_nullable
              as String?,
      scannedSerial: freezed == scannedSerial
          ? _value.scannedSerial
          : scannedSerial // ignore: cast_nullable_to_non_nullable
              as String?,
      deviceType: freezed == deviceType
          ? _value.deviceType
          : deviceType // ignore: cast_nullable_to_non_nullable
              as String?,
      matchedDeviceId: freezed == matchedDeviceId
          ? _value.matchedDeviceId
          : matchedDeviceId // ignore: cast_nullable_to_non_nullable
              as int?,
      matchedDeviceName: freezed == matchedDeviceName
          ? _value.matchedDeviceName
          : matchedDeviceName // ignore: cast_nullable_to_non_nullable
              as String?,
      matchedDeviceRoomId: freezed == matchedDeviceRoomId
          ? _value.matchedDeviceRoomId
          : matchedDeviceRoomId // ignore: cast_nullable_to_non_nullable
              as int?,
      matchedDeviceRoomName: freezed == matchedDeviceRoomName
          ? _value.matchedDeviceRoomName
          : matchedDeviceRoomName // ignore: cast_nullable_to_non_nullable
              as String?,
      mismatchInfo: freezed == mismatchInfo
          ? _value.mismatchInfo
          : mismatchInfo // ignore: cast_nullable_to_non_nullable
              as MatchMismatchInfo?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      registeredAt: freezed == registeredAt
          ? _value.registeredAt
          : registeredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $MatchMismatchInfoCopyWith<$Res>? get mismatchInfo {
    if (_value.mismatchInfo == null) {
      return null;
    }

    return $MatchMismatchInfoCopyWith<$Res>(_value.mismatchInfo!, (value) {
      return _then(_value.copyWith(mismatchInfo: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DeviceRegistrationStateImplCopyWith<$Res>
    implements $DeviceRegistrationStateCopyWith<$Res> {
  factory _$$DeviceRegistrationStateImplCopyWith(
          _$DeviceRegistrationStateImpl value,
          $Res Function(_$DeviceRegistrationStateImpl) then) =
      __$$DeviceRegistrationStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {RegistrationStatus status,
      DeviceMatchStatus matchStatus,
      String? scannedMac,
      String? scannedSerial,
      String? deviceType,
      int? matchedDeviceId,
      String? matchedDeviceName,
      int? matchedDeviceRoomId,
      String? matchedDeviceRoomName,
      MatchMismatchInfo? mismatchInfo,
      String? errorMessage,
      DateTime? registeredAt});

  @override
  $MatchMismatchInfoCopyWith<$Res>? get mismatchInfo;
}

/// @nodoc
class __$$DeviceRegistrationStateImplCopyWithImpl<$Res>
    extends _$DeviceRegistrationStateCopyWithImpl<$Res,
        _$DeviceRegistrationStateImpl>
    implements _$$DeviceRegistrationStateImplCopyWith<$Res> {
  __$$DeviceRegistrationStateImplCopyWithImpl(
      _$DeviceRegistrationStateImpl _value,
      $Res Function(_$DeviceRegistrationStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? matchStatus = null,
    Object? scannedMac = freezed,
    Object? scannedSerial = freezed,
    Object? deviceType = freezed,
    Object? matchedDeviceId = freezed,
    Object? matchedDeviceName = freezed,
    Object? matchedDeviceRoomId = freezed,
    Object? matchedDeviceRoomName = freezed,
    Object? mismatchInfo = freezed,
    Object? errorMessage = freezed,
    Object? registeredAt = freezed,
  }) {
    return _then(_$DeviceRegistrationStateImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as RegistrationStatus,
      matchStatus: null == matchStatus
          ? _value.matchStatus
          : matchStatus // ignore: cast_nullable_to_non_nullable
              as DeviceMatchStatus,
      scannedMac: freezed == scannedMac
          ? _value.scannedMac
          : scannedMac // ignore: cast_nullable_to_non_nullable
              as String?,
      scannedSerial: freezed == scannedSerial
          ? _value.scannedSerial
          : scannedSerial // ignore: cast_nullable_to_non_nullable
              as String?,
      deviceType: freezed == deviceType
          ? _value.deviceType
          : deviceType // ignore: cast_nullable_to_non_nullable
              as String?,
      matchedDeviceId: freezed == matchedDeviceId
          ? _value.matchedDeviceId
          : matchedDeviceId // ignore: cast_nullable_to_non_nullable
              as int?,
      matchedDeviceName: freezed == matchedDeviceName
          ? _value.matchedDeviceName
          : matchedDeviceName // ignore: cast_nullable_to_non_nullable
              as String?,
      matchedDeviceRoomId: freezed == matchedDeviceRoomId
          ? _value.matchedDeviceRoomId
          : matchedDeviceRoomId // ignore: cast_nullable_to_non_nullable
              as int?,
      matchedDeviceRoomName: freezed == matchedDeviceRoomName
          ? _value.matchedDeviceRoomName
          : matchedDeviceRoomName // ignore: cast_nullable_to_non_nullable
              as String?,
      mismatchInfo: freezed == mismatchInfo
          ? _value.mismatchInfo
          : mismatchInfo // ignore: cast_nullable_to_non_nullable
              as MatchMismatchInfo?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      registeredAt: freezed == registeredAt
          ? _value.registeredAt
          : registeredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$DeviceRegistrationStateImpl extends _DeviceRegistrationState {
  const _$DeviceRegistrationStateImpl(
      {this.status = RegistrationStatus.idle,
      this.matchStatus = DeviceMatchStatus.unchecked,
      this.scannedMac,
      this.scannedSerial,
      this.deviceType,
      this.matchedDeviceId,
      this.matchedDeviceName,
      this.matchedDeviceRoomId,
      this.matchedDeviceRoomName,
      this.mismatchInfo,
      this.errorMessage,
      this.registeredAt})
      : super._();

  @override
  @JsonKey()
  final RegistrationStatus status;
  @override
  @JsonKey()
  final DeviceMatchStatus matchStatus;
  @override
  final String? scannedMac;
  @override
  final String? scannedSerial;
  @override
  final String? deviceType;
  @override
  final int? matchedDeviceId;
  @override
  final String? matchedDeviceName;

  /// Current room ID of matched device (for move/reset detection)
  @override
  final int? matchedDeviceRoomId;

  /// Current room name of matched device (for display)
  @override
  final String? matchedDeviceRoomName;
  @override
  final MatchMismatchInfo? mismatchInfo;
  @override
  final String? errorMessage;
  @override
  final DateTime? registeredAt;

  @override
  String toString() {
    return 'DeviceRegistrationState(status: $status, matchStatus: $matchStatus, scannedMac: $scannedMac, scannedSerial: $scannedSerial, deviceType: $deviceType, matchedDeviceId: $matchedDeviceId, matchedDeviceName: $matchedDeviceName, matchedDeviceRoomId: $matchedDeviceRoomId, matchedDeviceRoomName: $matchedDeviceRoomName, mismatchInfo: $mismatchInfo, errorMessage: $errorMessage, registeredAt: $registeredAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceRegistrationStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.matchStatus, matchStatus) ||
                other.matchStatus == matchStatus) &&
            (identical(other.scannedMac, scannedMac) ||
                other.scannedMac == scannedMac) &&
            (identical(other.scannedSerial, scannedSerial) ||
                other.scannedSerial == scannedSerial) &&
            (identical(other.deviceType, deviceType) ||
                other.deviceType == deviceType) &&
            (identical(other.matchedDeviceId, matchedDeviceId) ||
                other.matchedDeviceId == matchedDeviceId) &&
            (identical(other.matchedDeviceName, matchedDeviceName) ||
                other.matchedDeviceName == matchedDeviceName) &&
            (identical(other.matchedDeviceRoomId, matchedDeviceRoomId) ||
                other.matchedDeviceRoomId == matchedDeviceRoomId) &&
            (identical(other.matchedDeviceRoomName, matchedDeviceRoomName) ||
                other.matchedDeviceRoomName == matchedDeviceRoomName) &&
            (identical(other.mismatchInfo, mismatchInfo) ||
                other.mismatchInfo == mismatchInfo) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.registeredAt, registeredAt) ||
                other.registeredAt == registeredAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      status,
      matchStatus,
      scannedMac,
      scannedSerial,
      deviceType,
      matchedDeviceId,
      matchedDeviceName,
      matchedDeviceRoomId,
      matchedDeviceRoomName,
      mismatchInfo,
      errorMessage,
      registeredAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceRegistrationStateImplCopyWith<_$DeviceRegistrationStateImpl>
      get copyWith => __$$DeviceRegistrationStateImplCopyWithImpl<
          _$DeviceRegistrationStateImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            RegistrationStatus status,
            DeviceMatchStatus matchStatus,
            String? scannedMac,
            String? scannedSerial,
            String? deviceType,
            int? matchedDeviceId,
            String? matchedDeviceName,
            int? matchedDeviceRoomId,
            String? matchedDeviceRoomName,
            MatchMismatchInfo? mismatchInfo,
            String? errorMessage,
            DateTime? registeredAt)
        $default,
  ) {
    return $default(
        status,
        matchStatus,
        scannedMac,
        scannedSerial,
        deviceType,
        matchedDeviceId,
        matchedDeviceName,
        matchedDeviceRoomId,
        matchedDeviceRoomName,
        mismatchInfo,
        errorMessage,
        registeredAt);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            RegistrationStatus status,
            DeviceMatchStatus matchStatus,
            String? scannedMac,
            String? scannedSerial,
            String? deviceType,
            int? matchedDeviceId,
            String? matchedDeviceName,
            int? matchedDeviceRoomId,
            String? matchedDeviceRoomName,
            MatchMismatchInfo? mismatchInfo,
            String? errorMessage,
            DateTime? registeredAt)?
        $default,
  ) {
    return $default?.call(
        status,
        matchStatus,
        scannedMac,
        scannedSerial,
        deviceType,
        matchedDeviceId,
        matchedDeviceName,
        matchedDeviceRoomId,
        matchedDeviceRoomName,
        mismatchInfo,
        errorMessage,
        registeredAt);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            RegistrationStatus status,
            DeviceMatchStatus matchStatus,
            String? scannedMac,
            String? scannedSerial,
            String? deviceType,
            int? matchedDeviceId,
            String? matchedDeviceName,
            int? matchedDeviceRoomId,
            String? matchedDeviceRoomName,
            MatchMismatchInfo? mismatchInfo,
            String? errorMessage,
            DateTime? registeredAt)?
        $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(
          status,
          matchStatus,
          scannedMac,
          scannedSerial,
          deviceType,
          matchedDeviceId,
          matchedDeviceName,
          matchedDeviceRoomId,
          matchedDeviceRoomName,
          mismatchInfo,
          errorMessage,
          registeredAt);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_DeviceRegistrationState value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_DeviceRegistrationState value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_DeviceRegistrationState value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _DeviceRegistrationState extends DeviceRegistrationState {
  const factory _DeviceRegistrationState(
      {final RegistrationStatus status,
      final DeviceMatchStatus matchStatus,
      final String? scannedMac,
      final String? scannedSerial,
      final String? deviceType,
      final int? matchedDeviceId,
      final String? matchedDeviceName,
      final int? matchedDeviceRoomId,
      final String? matchedDeviceRoomName,
      final MatchMismatchInfo? mismatchInfo,
      final String? errorMessage,
      final DateTime? registeredAt}) = _$DeviceRegistrationStateImpl;
  const _DeviceRegistrationState._() : super._();

  @override
  RegistrationStatus get status;
  @override
  DeviceMatchStatus get matchStatus;
  @override
  String? get scannedMac;
  @override
  String? get scannedSerial;
  @override
  String? get deviceType;
  @override
  int? get matchedDeviceId;
  @override
  String? get matchedDeviceName;
  @override

  /// Current room ID of matched device (for move/reset detection)
  int? get matchedDeviceRoomId;
  @override

  /// Current room name of matched device (for display)
  String? get matchedDeviceRoomName;
  @override
  MatchMismatchInfo? get mismatchInfo;
  @override
  String? get errorMessage;
  @override
  DateTime? get registeredAt;
  @override
  @JsonKey(ignore: true)
  _$$DeviceRegistrationStateImplCopyWith<_$DeviceRegistrationStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MatchMismatchInfo {
  List<String> get mismatchedFields => throw _privateConstructorUsedError;
  Map<String, String> get expected => throw _privateConstructorUsedError;
  Map<String, String> get scanned => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(List<String> mismatchedFields,
            Map<String, String> expected, Map<String, String> scanned)
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(List<String> mismatchedFields,
            Map<String, String> expected, Map<String, String> scanned)?
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(List<String> mismatchedFields,
            Map<String, String> expected, Map<String, String> scanned)?
        $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MatchMismatchInfo value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MatchMismatchInfo value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MatchMismatchInfo value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MatchMismatchInfoCopyWith<MatchMismatchInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchMismatchInfoCopyWith<$Res> {
  factory $MatchMismatchInfoCopyWith(
          MatchMismatchInfo value, $Res Function(MatchMismatchInfo) then) =
      _$MatchMismatchInfoCopyWithImpl<$Res, MatchMismatchInfo>;
  @useResult
  $Res call(
      {List<String> mismatchedFields,
      Map<String, String> expected,
      Map<String, String> scanned});
}

/// @nodoc
class _$MatchMismatchInfoCopyWithImpl<$Res, $Val extends MatchMismatchInfo>
    implements $MatchMismatchInfoCopyWith<$Res> {
  _$MatchMismatchInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mismatchedFields = null,
    Object? expected = null,
    Object? scanned = null,
  }) {
    return _then(_value.copyWith(
      mismatchedFields: null == mismatchedFields
          ? _value.mismatchedFields
          : mismatchedFields // ignore: cast_nullable_to_non_nullable
              as List<String>,
      expected: null == expected
          ? _value.expected
          : expected // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      scanned: null == scanned
          ? _value.scanned
          : scanned // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MatchMismatchInfoImplCopyWith<$Res>
    implements $MatchMismatchInfoCopyWith<$Res> {
  factory _$$MatchMismatchInfoImplCopyWith(_$MatchMismatchInfoImpl value,
          $Res Function(_$MatchMismatchInfoImpl) then) =
      __$$MatchMismatchInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<String> mismatchedFields,
      Map<String, String> expected,
      Map<String, String> scanned});
}

/// @nodoc
class __$$MatchMismatchInfoImplCopyWithImpl<$Res>
    extends _$MatchMismatchInfoCopyWithImpl<$Res, _$MatchMismatchInfoImpl>
    implements _$$MatchMismatchInfoImplCopyWith<$Res> {
  __$$MatchMismatchInfoImplCopyWithImpl(_$MatchMismatchInfoImpl _value,
      $Res Function(_$MatchMismatchInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mismatchedFields = null,
    Object? expected = null,
    Object? scanned = null,
  }) {
    return _then(_$MatchMismatchInfoImpl(
      mismatchedFields: null == mismatchedFields
          ? _value._mismatchedFields
          : mismatchedFields // ignore: cast_nullable_to_non_nullable
              as List<String>,
      expected: null == expected
          ? _value._expected
          : expected // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      scanned: null == scanned
          ? _value._scanned
          : scanned // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
    ));
  }
}

/// @nodoc

class _$MatchMismatchInfoImpl extends _MatchMismatchInfo {
  const _$MatchMismatchInfoImpl(
      {required final List<String> mismatchedFields,
      required final Map<String, String> expected,
      required final Map<String, String> scanned})
      : _mismatchedFields = mismatchedFields,
        _expected = expected,
        _scanned = scanned,
        super._();

  final List<String> _mismatchedFields;
  @override
  List<String> get mismatchedFields {
    if (_mismatchedFields is EqualUnmodifiableListView)
      return _mismatchedFields;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mismatchedFields);
  }

  final Map<String, String> _expected;
  @override
  Map<String, String> get expected {
    if (_expected is EqualUnmodifiableMapView) return _expected;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_expected);
  }

  final Map<String, String> _scanned;
  @override
  Map<String, String> get scanned {
    if (_scanned is EqualUnmodifiableMapView) return _scanned;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_scanned);
  }

  @override
  String toString() {
    return 'MatchMismatchInfo(mismatchedFields: $mismatchedFields, expected: $expected, scanned: $scanned)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchMismatchInfoImpl &&
            const DeepCollectionEquality()
                .equals(other._mismatchedFields, _mismatchedFields) &&
            const DeepCollectionEquality().equals(other._expected, _expected) &&
            const DeepCollectionEquality().equals(other._scanned, _scanned));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_mismatchedFields),
      const DeepCollectionEquality().hash(_expected),
      const DeepCollectionEquality().hash(_scanned));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchMismatchInfoImplCopyWith<_$MatchMismatchInfoImpl> get copyWith =>
      __$$MatchMismatchInfoImplCopyWithImpl<_$MatchMismatchInfoImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(List<String> mismatchedFields,
            Map<String, String> expected, Map<String, String> scanned)
        $default,
  ) {
    return $default(mismatchedFields, expected, scanned);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(List<String> mismatchedFields,
            Map<String, String> expected, Map<String, String> scanned)?
        $default,
  ) {
    return $default?.call(mismatchedFields, expected, scanned);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(List<String> mismatchedFields,
            Map<String, String> expected, Map<String, String> scanned)?
        $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(mismatchedFields, expected, scanned);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MatchMismatchInfo value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MatchMismatchInfo value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MatchMismatchInfo value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _MatchMismatchInfo extends MatchMismatchInfo {
  const factory _MatchMismatchInfo(
      {required final List<String> mismatchedFields,
      required final Map<String, String> expected,
      required final Map<String, String> scanned}) = _$MatchMismatchInfoImpl;
  const _MatchMismatchInfo._() : super._();

  @override
  List<String> get mismatchedFields;
  @override
  Map<String, String> get expected;
  @override
  Map<String, String> get scanned;
  @override
  @JsonKey(ignore: true)
  _$$MatchMismatchInfoImplCopyWith<_$MatchMismatchInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RegistrationResult {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            int deviceId, String deviceType, String? deviceName)
        success,
    required TResult Function(int deviceId, String deviceType)
        alreadyRegistered,
    required TResult Function(String message, int? httpStatus) failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int deviceId, String deviceType, String? deviceName)?
        success,
    TResult? Function(int deviceId, String deviceType)? alreadyRegistered,
    TResult? Function(String message, int? httpStatus)? failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int deviceId, String deviceType, String? deviceName)?
        success,
    TResult Function(int deviceId, String deviceType)? alreadyRegistered,
    TResult Function(String message, int? httpStatus)? failure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RegistrationSuccess value) success,
    required TResult Function(AlreadyRegistered value) alreadyRegistered,
    required TResult Function(RegistrationFailure value) failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RegistrationSuccess value)? success,
    TResult? Function(AlreadyRegistered value)? alreadyRegistered,
    TResult? Function(RegistrationFailure value)? failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RegistrationSuccess value)? success,
    TResult Function(AlreadyRegistered value)? alreadyRegistered,
    TResult Function(RegistrationFailure value)? failure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RegistrationResultCopyWith<$Res> {
  factory $RegistrationResultCopyWith(
          RegistrationResult value, $Res Function(RegistrationResult) then) =
      _$RegistrationResultCopyWithImpl<$Res, RegistrationResult>;
}

/// @nodoc
class _$RegistrationResultCopyWithImpl<$Res, $Val extends RegistrationResult>
    implements $RegistrationResultCopyWith<$Res> {
  _$RegistrationResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$RegistrationSuccessImplCopyWith<$Res> {
  factory _$$RegistrationSuccessImplCopyWith(_$RegistrationSuccessImpl value,
          $Res Function(_$RegistrationSuccessImpl) then) =
      __$$RegistrationSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int deviceId, String deviceType, String? deviceName});
}

/// @nodoc
class __$$RegistrationSuccessImplCopyWithImpl<$Res>
    extends _$RegistrationResultCopyWithImpl<$Res, _$RegistrationSuccessImpl>
    implements _$$RegistrationSuccessImplCopyWith<$Res> {
  __$$RegistrationSuccessImplCopyWithImpl(_$RegistrationSuccessImpl _value,
      $Res Function(_$RegistrationSuccessImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceId = null,
    Object? deviceType = null,
    Object? deviceName = freezed,
  }) {
    return _then(_$RegistrationSuccessImpl(
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as int,
      deviceType: null == deviceType
          ? _value.deviceType
          : deviceType // ignore: cast_nullable_to_non_nullable
              as String,
      deviceName: freezed == deviceName
          ? _value.deviceName
          : deviceName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$RegistrationSuccessImpl implements RegistrationSuccess {
  const _$RegistrationSuccessImpl(
      {required this.deviceId, required this.deviceType, this.deviceName});

  @override
  final int deviceId;
  @override
  final String deviceType;
  @override
  final String? deviceName;

  @override
  String toString() {
    return 'RegistrationResult.success(deviceId: $deviceId, deviceType: $deviceType, deviceName: $deviceName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegistrationSuccessImpl &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.deviceType, deviceType) ||
                other.deviceType == deviceType) &&
            (identical(other.deviceName, deviceName) ||
                other.deviceName == deviceName));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, deviceId, deviceType, deviceName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RegistrationSuccessImplCopyWith<_$RegistrationSuccessImpl> get copyWith =>
      __$$RegistrationSuccessImplCopyWithImpl<_$RegistrationSuccessImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            int deviceId, String deviceType, String? deviceName)
        success,
    required TResult Function(int deviceId, String deviceType)
        alreadyRegistered,
    required TResult Function(String message, int? httpStatus) failure,
  }) {
    return success(deviceId, deviceType, deviceName);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int deviceId, String deviceType, String? deviceName)?
        success,
    TResult? Function(int deviceId, String deviceType)? alreadyRegistered,
    TResult? Function(String message, int? httpStatus)? failure,
  }) {
    return success?.call(deviceId, deviceType, deviceName);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int deviceId, String deviceType, String? deviceName)?
        success,
    TResult Function(int deviceId, String deviceType)? alreadyRegistered,
    TResult Function(String message, int? httpStatus)? failure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(deviceId, deviceType, deviceName);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RegistrationSuccess value) success,
    required TResult Function(AlreadyRegistered value) alreadyRegistered,
    required TResult Function(RegistrationFailure value) failure,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RegistrationSuccess value)? success,
    TResult? Function(AlreadyRegistered value)? alreadyRegistered,
    TResult? Function(RegistrationFailure value)? failure,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RegistrationSuccess value)? success,
    TResult Function(AlreadyRegistered value)? alreadyRegistered,
    TResult Function(RegistrationFailure value)? failure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class RegistrationSuccess implements RegistrationResult {
  const factory RegistrationSuccess(
      {required final int deviceId,
      required final String deviceType,
      final String? deviceName}) = _$RegistrationSuccessImpl;

  int get deviceId;
  String get deviceType;
  String? get deviceName;
  @JsonKey(ignore: true)
  _$$RegistrationSuccessImplCopyWith<_$RegistrationSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AlreadyRegisteredImplCopyWith<$Res> {
  factory _$$AlreadyRegisteredImplCopyWith(_$AlreadyRegisteredImpl value,
          $Res Function(_$AlreadyRegisteredImpl) then) =
      __$$AlreadyRegisteredImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int deviceId, String deviceType});
}

/// @nodoc
class __$$AlreadyRegisteredImplCopyWithImpl<$Res>
    extends _$RegistrationResultCopyWithImpl<$Res, _$AlreadyRegisteredImpl>
    implements _$$AlreadyRegisteredImplCopyWith<$Res> {
  __$$AlreadyRegisteredImplCopyWithImpl(_$AlreadyRegisteredImpl _value,
      $Res Function(_$AlreadyRegisteredImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceId = null,
    Object? deviceType = null,
  }) {
    return _then(_$AlreadyRegisteredImpl(
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as int,
      deviceType: null == deviceType
          ? _value.deviceType
          : deviceType // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$AlreadyRegisteredImpl implements AlreadyRegistered {
  const _$AlreadyRegisteredImpl(
      {required this.deviceId, required this.deviceType});

  @override
  final int deviceId;
  @override
  final String deviceType;

  @override
  String toString() {
    return 'RegistrationResult.alreadyRegistered(deviceId: $deviceId, deviceType: $deviceType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AlreadyRegisteredImpl &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.deviceType, deviceType) ||
                other.deviceType == deviceType));
  }

  @override
  int get hashCode => Object.hash(runtimeType, deviceId, deviceType);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AlreadyRegisteredImplCopyWith<_$AlreadyRegisteredImpl> get copyWith =>
      __$$AlreadyRegisteredImplCopyWithImpl<_$AlreadyRegisteredImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            int deviceId, String deviceType, String? deviceName)
        success,
    required TResult Function(int deviceId, String deviceType)
        alreadyRegistered,
    required TResult Function(String message, int? httpStatus) failure,
  }) {
    return alreadyRegistered(deviceId, deviceType);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int deviceId, String deviceType, String? deviceName)?
        success,
    TResult? Function(int deviceId, String deviceType)? alreadyRegistered,
    TResult? Function(String message, int? httpStatus)? failure,
  }) {
    return alreadyRegistered?.call(deviceId, deviceType);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int deviceId, String deviceType, String? deviceName)?
        success,
    TResult Function(int deviceId, String deviceType)? alreadyRegistered,
    TResult Function(String message, int? httpStatus)? failure,
    required TResult orElse(),
  }) {
    if (alreadyRegistered != null) {
      return alreadyRegistered(deviceId, deviceType);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RegistrationSuccess value) success,
    required TResult Function(AlreadyRegistered value) alreadyRegistered,
    required TResult Function(RegistrationFailure value) failure,
  }) {
    return alreadyRegistered(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RegistrationSuccess value)? success,
    TResult? Function(AlreadyRegistered value)? alreadyRegistered,
    TResult? Function(RegistrationFailure value)? failure,
  }) {
    return alreadyRegistered?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RegistrationSuccess value)? success,
    TResult Function(AlreadyRegistered value)? alreadyRegistered,
    TResult Function(RegistrationFailure value)? failure,
    required TResult orElse(),
  }) {
    if (alreadyRegistered != null) {
      return alreadyRegistered(this);
    }
    return orElse();
  }
}

abstract class AlreadyRegistered implements RegistrationResult {
  const factory AlreadyRegistered(
      {required final int deviceId,
      required final String deviceType}) = _$AlreadyRegisteredImpl;

  int get deviceId;
  String get deviceType;
  @JsonKey(ignore: true)
  _$$AlreadyRegisteredImplCopyWith<_$AlreadyRegisteredImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RegistrationFailureImplCopyWith<$Res> {
  factory _$$RegistrationFailureImplCopyWith(_$RegistrationFailureImpl value,
          $Res Function(_$RegistrationFailureImpl) then) =
      __$$RegistrationFailureImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message, int? httpStatus});
}

/// @nodoc
class __$$RegistrationFailureImplCopyWithImpl<$Res>
    extends _$RegistrationResultCopyWithImpl<$Res, _$RegistrationFailureImpl>
    implements _$$RegistrationFailureImplCopyWith<$Res> {
  __$$RegistrationFailureImplCopyWithImpl(_$RegistrationFailureImpl _value,
      $Res Function(_$RegistrationFailureImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? httpStatus = freezed,
  }) {
    return _then(_$RegistrationFailureImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      httpStatus: freezed == httpStatus
          ? _value.httpStatus
          : httpStatus // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$RegistrationFailureImpl implements RegistrationFailure {
  const _$RegistrationFailureImpl({required this.message, this.httpStatus});

  @override
  final String message;
  @override
  final int? httpStatus;

  @override
  String toString() {
    return 'RegistrationResult.failure(message: $message, httpStatus: $httpStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegistrationFailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.httpStatus, httpStatus) ||
                other.httpStatus == httpStatus));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, httpStatus);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RegistrationFailureImplCopyWith<_$RegistrationFailureImpl> get copyWith =>
      __$$RegistrationFailureImplCopyWithImpl<_$RegistrationFailureImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            int deviceId, String deviceType, String? deviceName)
        success,
    required TResult Function(int deviceId, String deviceType)
        alreadyRegistered,
    required TResult Function(String message, int? httpStatus) failure,
  }) {
    return failure(message, httpStatus);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int deviceId, String deviceType, String? deviceName)?
        success,
    TResult? Function(int deviceId, String deviceType)? alreadyRegistered,
    TResult? Function(String message, int? httpStatus)? failure,
  }) {
    return failure?.call(message, httpStatus);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int deviceId, String deviceType, String? deviceName)?
        success,
    TResult Function(int deviceId, String deviceType)? alreadyRegistered,
    TResult Function(String message, int? httpStatus)? failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(message, httpStatus);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RegistrationSuccess value) success,
    required TResult Function(AlreadyRegistered value) alreadyRegistered,
    required TResult Function(RegistrationFailure value) failure,
  }) {
    return failure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RegistrationSuccess value)? success,
    TResult? Function(AlreadyRegistered value)? alreadyRegistered,
    TResult? Function(RegistrationFailure value)? failure,
  }) {
    return failure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RegistrationSuccess value)? success,
    TResult Function(AlreadyRegistered value)? alreadyRegistered,
    TResult Function(RegistrationFailure value)? failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(this);
    }
    return orElse();
  }
}

abstract class RegistrationFailure implements RegistrationResult {
  const factory RegistrationFailure(
      {required final String message,
      final int? httpStatus}) = _$RegistrationFailureImpl;

  String get message;
  int? get httpStatus;
  @JsonKey(ignore: true)
  _$$RegistrationFailureImplCopyWith<_$RegistrationFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
