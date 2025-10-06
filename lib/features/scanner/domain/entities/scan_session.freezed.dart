// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scan_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ScanSession {
  String get id => throw _privateConstructorUsedError;
  DeviceType get deviceType => throw _privateConstructorUsedError;
  DateTime get startedAt => throw _privateConstructorUsedError;
  List<ScanResult> get scannedBarcodes => throw _privateConstructorUsedError;
  ScanSessionStatus get status => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  String? get serialNumber => throw _privateConstructorUsedError;
  String? get macAddress => throw _privateConstructorUsedError;
  String? get partNumber => throw _privateConstructorUsedError;
  String? get assetTag => throw _privateConstructorUsedError;
  Map<String, String>? get additionalData => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            DeviceType deviceType,
            DateTime startedAt,
            List<ScanResult> scannedBarcodes,
            ScanSessionStatus status,
            DateTime? completedAt,
            String? serialNumber,
            String? macAddress,
            String? partNumber,
            String? assetTag,
            Map<String, String>? additionalData)
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            DeviceType deviceType,
            DateTime startedAt,
            List<ScanResult> scannedBarcodes,
            ScanSessionStatus status,
            DateTime? completedAt,
            String? serialNumber,
            String? macAddress,
            String? partNumber,
            String? assetTag,
            Map<String, String>? additionalData)?
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            DeviceType deviceType,
            DateTime startedAt,
            List<ScanResult> scannedBarcodes,
            ScanSessionStatus status,
            DateTime? completedAt,
            String? serialNumber,
            String? macAddress,
            String? partNumber,
            String? assetTag,
            Map<String, String>? additionalData)?
        $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ScanSession value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ScanSession value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ScanSession value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ScanSessionCopyWith<ScanSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScanSessionCopyWith<$Res> {
  factory $ScanSessionCopyWith(
          ScanSession value, $Res Function(ScanSession) then) =
      _$ScanSessionCopyWithImpl<$Res, ScanSession>;
  @useResult
  $Res call(
      {String id,
      DeviceType deviceType,
      DateTime startedAt,
      List<ScanResult> scannedBarcodes,
      ScanSessionStatus status,
      DateTime? completedAt,
      String? serialNumber,
      String? macAddress,
      String? partNumber,
      String? assetTag,
      Map<String, String>? additionalData});
}

/// @nodoc
class _$ScanSessionCopyWithImpl<$Res, $Val extends ScanSession>
    implements $ScanSessionCopyWith<$Res> {
  _$ScanSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? deviceType = null,
    Object? startedAt = null,
    Object? scannedBarcodes = null,
    Object? status = null,
    Object? completedAt = freezed,
    Object? serialNumber = freezed,
    Object? macAddress = freezed,
    Object? partNumber = freezed,
    Object? assetTag = freezed,
    Object? additionalData = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      deviceType: null == deviceType
          ? _value.deviceType
          : deviceType // ignore: cast_nullable_to_non_nullable
              as DeviceType,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      scannedBarcodes: null == scannedBarcodes
          ? _value.scannedBarcodes
          : scannedBarcodes // ignore: cast_nullable_to_non_nullable
              as List<ScanResult>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ScanSessionStatus,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      serialNumber: freezed == serialNumber
          ? _value.serialNumber
          : serialNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      macAddress: freezed == macAddress
          ? _value.macAddress
          : macAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      partNumber: freezed == partNumber
          ? _value.partNumber
          : partNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      assetTag: freezed == assetTag
          ? _value.assetTag
          : assetTag // ignore: cast_nullable_to_non_nullable
              as String?,
      additionalData: freezed == additionalData
          ? _value.additionalData
          : additionalData // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScanSessionImplCopyWith<$Res>
    implements $ScanSessionCopyWith<$Res> {
  factory _$$ScanSessionImplCopyWith(
          _$ScanSessionImpl value, $Res Function(_$ScanSessionImpl) then) =
      __$$ScanSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DeviceType deviceType,
      DateTime startedAt,
      List<ScanResult> scannedBarcodes,
      ScanSessionStatus status,
      DateTime? completedAt,
      String? serialNumber,
      String? macAddress,
      String? partNumber,
      String? assetTag,
      Map<String, String>? additionalData});
}

/// @nodoc
class __$$ScanSessionImplCopyWithImpl<$Res>
    extends _$ScanSessionCopyWithImpl<$Res, _$ScanSessionImpl>
    implements _$$ScanSessionImplCopyWith<$Res> {
  __$$ScanSessionImplCopyWithImpl(
      _$ScanSessionImpl _value, $Res Function(_$ScanSessionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? deviceType = null,
    Object? startedAt = null,
    Object? scannedBarcodes = null,
    Object? status = null,
    Object? completedAt = freezed,
    Object? serialNumber = freezed,
    Object? macAddress = freezed,
    Object? partNumber = freezed,
    Object? assetTag = freezed,
    Object? additionalData = freezed,
  }) {
    return _then(_$ScanSessionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      deviceType: null == deviceType
          ? _value.deviceType
          : deviceType // ignore: cast_nullable_to_non_nullable
              as DeviceType,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      scannedBarcodes: null == scannedBarcodes
          ? _value._scannedBarcodes
          : scannedBarcodes // ignore: cast_nullable_to_non_nullable
              as List<ScanResult>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ScanSessionStatus,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      serialNumber: freezed == serialNumber
          ? _value.serialNumber
          : serialNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      macAddress: freezed == macAddress
          ? _value.macAddress
          : macAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      partNumber: freezed == partNumber
          ? _value.partNumber
          : partNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      assetTag: freezed == assetTag
          ? _value.assetTag
          : assetTag // ignore: cast_nullable_to_non_nullable
              as String?,
      additionalData: freezed == additionalData
          ? _value._additionalData
          : additionalData // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
    ));
  }
}

/// @nodoc

class _$ScanSessionImpl extends _ScanSession {
  const _$ScanSessionImpl(
      {required this.id,
      required this.deviceType,
      required this.startedAt,
      required final List<ScanResult> scannedBarcodes,
      required this.status,
      this.completedAt,
      this.serialNumber,
      this.macAddress,
      this.partNumber,
      this.assetTag,
      final Map<String, String>? additionalData})
      : _scannedBarcodes = scannedBarcodes,
        _additionalData = additionalData,
        super._();

  @override
  final String id;
  @override
  final DeviceType deviceType;
  @override
  final DateTime startedAt;
  final List<ScanResult> _scannedBarcodes;
  @override
  List<ScanResult> get scannedBarcodes {
    if (_scannedBarcodes is EqualUnmodifiableListView) return _scannedBarcodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_scannedBarcodes);
  }

  @override
  final ScanSessionStatus status;
  @override
  final DateTime? completedAt;
  @override
  final String? serialNumber;
  @override
  final String? macAddress;
  @override
  final String? partNumber;
  @override
  final String? assetTag;
  final Map<String, String>? _additionalData;
  @override
  Map<String, String>? get additionalData {
    final value = _additionalData;
    if (value == null) return null;
    if (_additionalData is EqualUnmodifiableMapView) return _additionalData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'ScanSession(id: $id, deviceType: $deviceType, startedAt: $startedAt, scannedBarcodes: $scannedBarcodes, status: $status, completedAt: $completedAt, serialNumber: $serialNumber, macAddress: $macAddress, partNumber: $partNumber, assetTag: $assetTag, additionalData: $additionalData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScanSessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.deviceType, deviceType) ||
                other.deviceType == deviceType) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            const DeepCollectionEquality()
                .equals(other._scannedBarcodes, _scannedBarcodes) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.serialNumber, serialNumber) ||
                other.serialNumber == serialNumber) &&
            (identical(other.macAddress, macAddress) ||
                other.macAddress == macAddress) &&
            (identical(other.partNumber, partNumber) ||
                other.partNumber == partNumber) &&
            (identical(other.assetTag, assetTag) ||
                other.assetTag == assetTag) &&
            const DeepCollectionEquality()
                .equals(other._additionalData, _additionalData));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      deviceType,
      startedAt,
      const DeepCollectionEquality().hash(_scannedBarcodes),
      status,
      completedAt,
      serialNumber,
      macAddress,
      partNumber,
      assetTag,
      const DeepCollectionEquality().hash(_additionalData));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ScanSessionImplCopyWith<_$ScanSessionImpl> get copyWith =>
      __$$ScanSessionImplCopyWithImpl<_$ScanSessionImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            DeviceType deviceType,
            DateTime startedAt,
            List<ScanResult> scannedBarcodes,
            ScanSessionStatus status,
            DateTime? completedAt,
            String? serialNumber,
            String? macAddress,
            String? partNumber,
            String? assetTag,
            Map<String, String>? additionalData)
        $default,
  ) {
    return $default(
        id,
        deviceType,
        startedAt,
        scannedBarcodes,
        status,
        completedAt,
        serialNumber,
        macAddress,
        partNumber,
        assetTag,
        additionalData);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            DeviceType deviceType,
            DateTime startedAt,
            List<ScanResult> scannedBarcodes,
            ScanSessionStatus status,
            DateTime? completedAt,
            String? serialNumber,
            String? macAddress,
            String? partNumber,
            String? assetTag,
            Map<String, String>? additionalData)?
        $default,
  ) {
    return $default?.call(
        id,
        deviceType,
        startedAt,
        scannedBarcodes,
        status,
        completedAt,
        serialNumber,
        macAddress,
        partNumber,
        assetTag,
        additionalData);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            DeviceType deviceType,
            DateTime startedAt,
            List<ScanResult> scannedBarcodes,
            ScanSessionStatus status,
            DateTime? completedAt,
            String? serialNumber,
            String? macAddress,
            String? partNumber,
            String? assetTag,
            Map<String, String>? additionalData)?
        $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(
          id,
          deviceType,
          startedAt,
          scannedBarcodes,
          status,
          completedAt,
          serialNumber,
          macAddress,
          partNumber,
          assetTag,
          additionalData);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ScanSession value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ScanSession value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ScanSession value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _ScanSession extends ScanSession {
  const factory _ScanSession(
      {required final String id,
      required final DeviceType deviceType,
      required final DateTime startedAt,
      required final List<ScanResult> scannedBarcodes,
      required final ScanSessionStatus status,
      final DateTime? completedAt,
      final String? serialNumber,
      final String? macAddress,
      final String? partNumber,
      final String? assetTag,
      final Map<String, String>? additionalData}) = _$ScanSessionImpl;
  const _ScanSession._() : super._();

  @override
  String get id;
  @override
  DeviceType get deviceType;
  @override
  DateTime get startedAt;
  @override
  List<ScanResult> get scannedBarcodes;
  @override
  ScanSessionStatus get status;
  @override
  DateTime? get completedAt;
  @override
  String? get serialNumber;
  @override
  String? get macAddress;
  @override
  String? get partNumber;
  @override
  String? get assetTag;
  @override
  Map<String, String>? get additionalData;
  @override
  @JsonKey(ignore: true)
  _$$ScanSessionImplCopyWith<_$ScanSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
