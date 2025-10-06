// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scan_session_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ScanSessionModel _$ScanSessionModelFromJson(Map<String, dynamic> json) {
  return _ScanSessionModel.fromJson(json);
}

/// @nodoc
mixin _$ScanSessionModel {
  String get id => throw _privateConstructorUsedError;
  String get deviceType => throw _privateConstructorUsedError;
  DateTime get startedAt => throw _privateConstructorUsedError;
  List<ScanResultModel> get scannedBarcodes =>
      throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
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
            String deviceType,
            DateTime startedAt,
            List<ScanResultModel> scannedBarcodes,
            String status,
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
            String deviceType,
            DateTime startedAt,
            List<ScanResultModel> scannedBarcodes,
            String status,
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
            String deviceType,
            DateTime startedAt,
            List<ScanResultModel> scannedBarcodes,
            String status,
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
    TResult Function(_ScanSessionModel value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ScanSessionModel value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ScanSessionModel value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ScanSessionModelCopyWith<ScanSessionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScanSessionModelCopyWith<$Res> {
  factory $ScanSessionModelCopyWith(
          ScanSessionModel value, $Res Function(ScanSessionModel) then) =
      _$ScanSessionModelCopyWithImpl<$Res, ScanSessionModel>;
  @useResult
  $Res call(
      {String id,
      String deviceType,
      DateTime startedAt,
      List<ScanResultModel> scannedBarcodes,
      String status,
      DateTime? completedAt,
      String? serialNumber,
      String? macAddress,
      String? partNumber,
      String? assetTag,
      Map<String, String>? additionalData});
}

/// @nodoc
class _$ScanSessionModelCopyWithImpl<$Res, $Val extends ScanSessionModel>
    implements $ScanSessionModelCopyWith<$Res> {
  _$ScanSessionModelCopyWithImpl(this._value, this._then);

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
              as String,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      scannedBarcodes: null == scannedBarcodes
          ? _value.scannedBarcodes
          : scannedBarcodes // ignore: cast_nullable_to_non_nullable
              as List<ScanResultModel>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
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
abstract class _$$ScanSessionModelImplCopyWith<$Res>
    implements $ScanSessionModelCopyWith<$Res> {
  factory _$$ScanSessionModelImplCopyWith(_$ScanSessionModelImpl value,
          $Res Function(_$ScanSessionModelImpl) then) =
      __$$ScanSessionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String deviceType,
      DateTime startedAt,
      List<ScanResultModel> scannedBarcodes,
      String status,
      DateTime? completedAt,
      String? serialNumber,
      String? macAddress,
      String? partNumber,
      String? assetTag,
      Map<String, String>? additionalData});
}

/// @nodoc
class __$$ScanSessionModelImplCopyWithImpl<$Res>
    extends _$ScanSessionModelCopyWithImpl<$Res, _$ScanSessionModelImpl>
    implements _$$ScanSessionModelImplCopyWith<$Res> {
  __$$ScanSessionModelImplCopyWithImpl(_$ScanSessionModelImpl _value,
      $Res Function(_$ScanSessionModelImpl) _then)
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
    return _then(_$ScanSessionModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      deviceType: null == deviceType
          ? _value.deviceType
          : deviceType // ignore: cast_nullable_to_non_nullable
              as String,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      scannedBarcodes: null == scannedBarcodes
          ? _value._scannedBarcodes
          : scannedBarcodes // ignore: cast_nullable_to_non_nullable
              as List<ScanResultModel>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
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
@JsonSerializable()
class _$ScanSessionModelImpl extends _ScanSessionModel {
  const _$ScanSessionModelImpl(
      {required this.id,
      required this.deviceType,
      required this.startedAt,
      required final List<ScanResultModel> scannedBarcodes,
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

  factory _$ScanSessionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScanSessionModelImplFromJson(json);

  @override
  final String id;
  @override
  final String deviceType;
  @override
  final DateTime startedAt;
  final List<ScanResultModel> _scannedBarcodes;
  @override
  List<ScanResultModel> get scannedBarcodes {
    if (_scannedBarcodes is EqualUnmodifiableListView) return _scannedBarcodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_scannedBarcodes);
  }

  @override
  final String status;
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
    return 'ScanSessionModel(id: $id, deviceType: $deviceType, startedAt: $startedAt, scannedBarcodes: $scannedBarcodes, status: $status, completedAt: $completedAt, serialNumber: $serialNumber, macAddress: $macAddress, partNumber: $partNumber, assetTag: $assetTag, additionalData: $additionalData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScanSessionModelImpl &&
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

  @JsonKey(ignore: true)
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
  _$$ScanSessionModelImplCopyWith<_$ScanSessionModelImpl> get copyWith =>
      __$$ScanSessionModelImplCopyWithImpl<_$ScanSessionModelImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String deviceType,
            DateTime startedAt,
            List<ScanResultModel> scannedBarcodes,
            String status,
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
            String deviceType,
            DateTime startedAt,
            List<ScanResultModel> scannedBarcodes,
            String status,
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
            String deviceType,
            DateTime startedAt,
            List<ScanResultModel> scannedBarcodes,
            String status,
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
    TResult Function(_ScanSessionModel value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ScanSessionModel value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ScanSessionModel value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ScanSessionModelImplToJson(
      this,
    );
  }
}

abstract class _ScanSessionModel extends ScanSessionModel {
  const factory _ScanSessionModel(
      {required final String id,
      required final String deviceType,
      required final DateTime startedAt,
      required final List<ScanResultModel> scannedBarcodes,
      required final String status,
      final DateTime? completedAt,
      final String? serialNumber,
      final String? macAddress,
      final String? partNumber,
      final String? assetTag,
      final Map<String, String>? additionalData}) = _$ScanSessionModelImpl;
  const _ScanSessionModel._() : super._();

  factory _ScanSessionModel.fromJson(Map<String, dynamic> json) =
      _$ScanSessionModelImpl.fromJson;

  @override
  String get id;
  @override
  String get deviceType;
  @override
  DateTime get startedAt;
  @override
  List<ScanResultModel> get scannedBarcodes;
  @override
  String get status;
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
  _$$ScanSessionModelImplCopyWith<_$ScanSessionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScanResultModel _$ScanResultModelFromJson(Map<String, dynamic> json) {
  return _ScanResultModel.fromJson(json);
}

/// @nodoc
mixin _$ScanResultModel {
  String get id => throw _privateConstructorUsedError;
  String get barcode => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get value => throw _privateConstructorUsedError;
  DateTime get scannedAt => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String id, String barcode, String type, String value,
            DateTime scannedAt)
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String id, String barcode, String type, String value,
            DateTime scannedAt)?
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String id, String barcode, String type, String value,
            DateTime scannedAt)?
        $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ScanResultModel value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ScanResultModel value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ScanResultModel value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ScanResultModelCopyWith<ScanResultModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScanResultModelCopyWith<$Res> {
  factory $ScanResultModelCopyWith(
          ScanResultModel value, $Res Function(ScanResultModel) then) =
      _$ScanResultModelCopyWithImpl<$Res, ScanResultModel>;
  @useResult
  $Res call(
      {String id,
      String barcode,
      String type,
      String value,
      DateTime scannedAt});
}

/// @nodoc
class _$ScanResultModelCopyWithImpl<$Res, $Val extends ScanResultModel>
    implements $ScanResultModelCopyWith<$Res> {
  _$ScanResultModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? barcode = null,
    Object? type = null,
    Object? value = null,
    Object? scannedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      barcode: null == barcode
          ? _value.barcode
          : barcode // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      scannedAt: null == scannedAt
          ? _value.scannedAt
          : scannedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScanResultModelImplCopyWith<$Res>
    implements $ScanResultModelCopyWith<$Res> {
  factory _$$ScanResultModelImplCopyWith(_$ScanResultModelImpl value,
          $Res Function(_$ScanResultModelImpl) then) =
      __$$ScanResultModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String barcode,
      String type,
      String value,
      DateTime scannedAt});
}

/// @nodoc
class __$$ScanResultModelImplCopyWithImpl<$Res>
    extends _$ScanResultModelCopyWithImpl<$Res, _$ScanResultModelImpl>
    implements _$$ScanResultModelImplCopyWith<$Res> {
  __$$ScanResultModelImplCopyWithImpl(
      _$ScanResultModelImpl _value, $Res Function(_$ScanResultModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? barcode = null,
    Object? type = null,
    Object? value = null,
    Object? scannedAt = null,
  }) {
    return _then(_$ScanResultModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      barcode: null == barcode
          ? _value.barcode
          : barcode // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      scannedAt: null == scannedAt
          ? _value.scannedAt
          : scannedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScanResultModelImpl extends _ScanResultModel {
  const _$ScanResultModelImpl(
      {required this.id,
      required this.barcode,
      required this.type,
      required this.value,
      required this.scannedAt})
      : super._();

  factory _$ScanResultModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScanResultModelImplFromJson(json);

  @override
  final String id;
  @override
  final String barcode;
  @override
  final String type;
  @override
  final String value;
  @override
  final DateTime scannedAt;

  @override
  String toString() {
    return 'ScanResultModel(id: $id, barcode: $barcode, type: $type, value: $value, scannedAt: $scannedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScanResultModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.barcode, barcode) || other.barcode == barcode) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.scannedAt, scannedAt) ||
                other.scannedAt == scannedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, barcode, type, value, scannedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ScanResultModelImplCopyWith<_$ScanResultModelImpl> get copyWith =>
      __$$ScanResultModelImplCopyWithImpl<_$ScanResultModelImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String id, String barcode, String type, String value,
            DateTime scannedAt)
        $default,
  ) {
    return $default(id, barcode, type, value, scannedAt);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String id, String barcode, String type, String value,
            DateTime scannedAt)?
        $default,
  ) {
    return $default?.call(id, barcode, type, value, scannedAt);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String id, String barcode, String type, String value,
            DateTime scannedAt)?
        $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(id, barcode, type, value, scannedAt);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ScanResultModel value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ScanResultModel value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ScanResultModel value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ScanResultModelImplToJson(
      this,
    );
  }
}

abstract class _ScanResultModel extends ScanResultModel {
  const factory _ScanResultModel(
      {required final String id,
      required final String barcode,
      required final String type,
      required final String value,
      required final DateTime scannedAt}) = _$ScanResultModelImpl;
  const _ScanResultModel._() : super._();

  factory _ScanResultModel.fromJson(Map<String, dynamic> json) =
      _$ScanResultModelImpl.fromJson;

  @override
  String get id;
  @override
  String get barcode;
  @override
  String get type;
  @override
  String get value;
  @override
  DateTime get scannedAt;
  @override
  @JsonKey(ignore: true)
  _$$ScanResultModelImplCopyWith<_$ScanResultModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
