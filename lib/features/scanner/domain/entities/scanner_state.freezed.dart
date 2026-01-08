// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scanner_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ScanRecord {
  String get value => throw _privateConstructorUsedError;
  DateTime get scannedAt => throw _privateConstructorUsedError;
  String? get fieldType => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String value, DateTime scannedAt, String? fieldType)
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String value, DateTime scannedAt, String? fieldType)?
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String value, DateTime scannedAt, String? fieldType)?
        $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ScanRecord value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ScanRecord value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ScanRecord value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ScanRecordCopyWith<ScanRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScanRecordCopyWith<$Res> {
  factory $ScanRecordCopyWith(
          ScanRecord value, $Res Function(ScanRecord) then) =
      _$ScanRecordCopyWithImpl<$Res, ScanRecord>;
  @useResult
  $Res call({String value, DateTime scannedAt, String? fieldType});
}

/// @nodoc
class _$ScanRecordCopyWithImpl<$Res, $Val extends ScanRecord>
    implements $ScanRecordCopyWith<$Res> {
  _$ScanRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
    Object? scannedAt = null,
    Object? fieldType = freezed,
  }) {
    return _then(_value.copyWith(
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      scannedAt: null == scannedAt
          ? _value.scannedAt
          : scannedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      fieldType: freezed == fieldType
          ? _value.fieldType
          : fieldType // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScanRecordImplCopyWith<$Res>
    implements $ScanRecordCopyWith<$Res> {
  factory _$$ScanRecordImplCopyWith(
          _$ScanRecordImpl value, $Res Function(_$ScanRecordImpl) then) =
      __$$ScanRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String value, DateTime scannedAt, String? fieldType});
}

/// @nodoc
class __$$ScanRecordImplCopyWithImpl<$Res>
    extends _$ScanRecordCopyWithImpl<$Res, _$ScanRecordImpl>
    implements _$$ScanRecordImplCopyWith<$Res> {
  __$$ScanRecordImplCopyWithImpl(
      _$ScanRecordImpl _value, $Res Function(_$ScanRecordImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
    Object? scannedAt = null,
    Object? fieldType = freezed,
  }) {
    return _then(_$ScanRecordImpl(
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      scannedAt: null == scannedAt
          ? _value.scannedAt
          : scannedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      fieldType: freezed == fieldType
          ? _value.fieldType
          : fieldType // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ScanRecordImpl extends _ScanRecord {
  const _$ScanRecordImpl(
      {required this.value, required this.scannedAt, this.fieldType})
      : super._();

  @override
  final String value;
  @override
  final DateTime scannedAt;
  @override
  final String? fieldType;

  @override
  String toString() {
    return 'ScanRecord(value: $value, scannedAt: $scannedAt, fieldType: $fieldType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScanRecordImpl &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.scannedAt, scannedAt) ||
                other.scannedAt == scannedAt) &&
            (identical(other.fieldType, fieldType) ||
                other.fieldType == fieldType));
  }

  @override
  int get hashCode => Object.hash(runtimeType, value, scannedAt, fieldType);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ScanRecordImplCopyWith<_$ScanRecordImpl> get copyWith =>
      __$$ScanRecordImplCopyWithImpl<_$ScanRecordImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String value, DateTime scannedAt, String? fieldType)
        $default,
  ) {
    return $default(value, scannedAt, fieldType);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String value, DateTime scannedAt, String? fieldType)?
        $default,
  ) {
    return $default?.call(value, scannedAt, fieldType);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String value, DateTime scannedAt, String? fieldType)?
        $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(value, scannedAt, fieldType);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ScanRecord value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ScanRecord value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ScanRecord value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _ScanRecord extends ScanRecord {
  const factory _ScanRecord(
      {required final String value,
      required final DateTime scannedAt,
      final String? fieldType}) = _$ScanRecordImpl;
  const _ScanRecord._() : super._();

  @override
  String get value;
  @override
  DateTime get scannedAt;
  @override
  String? get fieldType;
  @override
  @JsonKey(ignore: true)
  _$$ScanRecordImplCopyWith<_$ScanRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AccumulatedScanData {
  String get mac => throw _privateConstructorUsedError;
  String get serialNumber => throw _privateConstructorUsedError;
  String get partNumber => throw _privateConstructorUsedError;
  String get model => throw _privateConstructorUsedError;
  bool get hasValidSerial => throw _privateConstructorUsedError;
  List<ScanRecord> get scanHistory => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String mac, String serialNumber, String partNumber,
            String model, bool hasValidSerial, List<ScanRecord> scanHistory)
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String mac, String serialNumber, String partNumber,
            String model, bool hasValidSerial, List<ScanRecord> scanHistory)?
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String mac, String serialNumber, String partNumber,
            String model, bool hasValidSerial, List<ScanRecord> scanHistory)?
        $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_AccumulatedScanData value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_AccumulatedScanData value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_AccumulatedScanData value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AccumulatedScanDataCopyWith<AccumulatedScanData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AccumulatedScanDataCopyWith<$Res> {
  factory $AccumulatedScanDataCopyWith(
          AccumulatedScanData value, $Res Function(AccumulatedScanData) then) =
      _$AccumulatedScanDataCopyWithImpl<$Res, AccumulatedScanData>;
  @useResult
  $Res call(
      {String mac,
      String serialNumber,
      String partNumber,
      String model,
      bool hasValidSerial,
      List<ScanRecord> scanHistory});
}

/// @nodoc
class _$AccumulatedScanDataCopyWithImpl<$Res, $Val extends AccumulatedScanData>
    implements $AccumulatedScanDataCopyWith<$Res> {
  _$AccumulatedScanDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mac = null,
    Object? serialNumber = null,
    Object? partNumber = null,
    Object? model = null,
    Object? hasValidSerial = null,
    Object? scanHistory = null,
  }) {
    return _then(_value.copyWith(
      mac: null == mac
          ? _value.mac
          : mac // ignore: cast_nullable_to_non_nullable
              as String,
      serialNumber: null == serialNumber
          ? _value.serialNumber
          : serialNumber // ignore: cast_nullable_to_non_nullable
              as String,
      partNumber: null == partNumber
          ? _value.partNumber
          : partNumber // ignore: cast_nullable_to_non_nullable
              as String,
      model: null == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String,
      hasValidSerial: null == hasValidSerial
          ? _value.hasValidSerial
          : hasValidSerial // ignore: cast_nullable_to_non_nullable
              as bool,
      scanHistory: null == scanHistory
          ? _value.scanHistory
          : scanHistory // ignore: cast_nullable_to_non_nullable
              as List<ScanRecord>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AccumulatedScanDataImplCopyWith<$Res>
    implements $AccumulatedScanDataCopyWith<$Res> {
  factory _$$AccumulatedScanDataImplCopyWith(_$AccumulatedScanDataImpl value,
          $Res Function(_$AccumulatedScanDataImpl) then) =
      __$$AccumulatedScanDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String mac,
      String serialNumber,
      String partNumber,
      String model,
      bool hasValidSerial,
      List<ScanRecord> scanHistory});
}

/// @nodoc
class __$$AccumulatedScanDataImplCopyWithImpl<$Res>
    extends _$AccumulatedScanDataCopyWithImpl<$Res, _$AccumulatedScanDataImpl>
    implements _$$AccumulatedScanDataImplCopyWith<$Res> {
  __$$AccumulatedScanDataImplCopyWithImpl(_$AccumulatedScanDataImpl _value,
      $Res Function(_$AccumulatedScanDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mac = null,
    Object? serialNumber = null,
    Object? partNumber = null,
    Object? model = null,
    Object? hasValidSerial = null,
    Object? scanHistory = null,
  }) {
    return _then(_$AccumulatedScanDataImpl(
      mac: null == mac
          ? _value.mac
          : mac // ignore: cast_nullable_to_non_nullable
              as String,
      serialNumber: null == serialNumber
          ? _value.serialNumber
          : serialNumber // ignore: cast_nullable_to_non_nullable
              as String,
      partNumber: null == partNumber
          ? _value.partNumber
          : partNumber // ignore: cast_nullable_to_non_nullable
              as String,
      model: null == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String,
      hasValidSerial: null == hasValidSerial
          ? _value.hasValidSerial
          : hasValidSerial // ignore: cast_nullable_to_non_nullable
              as bool,
      scanHistory: null == scanHistory
          ? _value._scanHistory
          : scanHistory // ignore: cast_nullable_to_non_nullable
              as List<ScanRecord>,
    ));
  }
}

/// @nodoc

class _$AccumulatedScanDataImpl extends _AccumulatedScanData {
  const _$AccumulatedScanDataImpl(
      {this.mac = '',
      this.serialNumber = '',
      this.partNumber = '',
      this.model = '',
      this.hasValidSerial = false,
      final List<ScanRecord> scanHistory = const []})
      : _scanHistory = scanHistory,
        super._();

  @override
  @JsonKey()
  final String mac;
  @override
  @JsonKey()
  final String serialNumber;
  @override
  @JsonKey()
  final String partNumber;
  @override
  @JsonKey()
  final String model;
  @override
  @JsonKey()
  final bool hasValidSerial;
  final List<ScanRecord> _scanHistory;
  @override
  @JsonKey()
  List<ScanRecord> get scanHistory {
    if (_scanHistory is EqualUnmodifiableListView) return _scanHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_scanHistory);
  }

  @override
  String toString() {
    return 'AccumulatedScanData(mac: $mac, serialNumber: $serialNumber, partNumber: $partNumber, model: $model, hasValidSerial: $hasValidSerial, scanHistory: $scanHistory)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AccumulatedScanDataImpl &&
            (identical(other.mac, mac) || other.mac == mac) &&
            (identical(other.serialNumber, serialNumber) ||
                other.serialNumber == serialNumber) &&
            (identical(other.partNumber, partNumber) ||
                other.partNumber == partNumber) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.hasValidSerial, hasValidSerial) ||
                other.hasValidSerial == hasValidSerial) &&
            const DeepCollectionEquality()
                .equals(other._scanHistory, _scanHistory));
  }

  @override
  int get hashCode => Object.hash(runtimeType, mac, serialNumber, partNumber,
      model, hasValidSerial, const DeepCollectionEquality().hash(_scanHistory));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AccumulatedScanDataImplCopyWith<_$AccumulatedScanDataImpl> get copyWith =>
      __$$AccumulatedScanDataImplCopyWithImpl<_$AccumulatedScanDataImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String mac, String serialNumber, String partNumber,
            String model, bool hasValidSerial, List<ScanRecord> scanHistory)
        $default,
  ) {
    return $default(
        mac, serialNumber, partNumber, model, hasValidSerial, scanHistory);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String mac, String serialNumber, String partNumber,
            String model, bool hasValidSerial, List<ScanRecord> scanHistory)?
        $default,
  ) {
    return $default?.call(
        mac, serialNumber, partNumber, model, hasValidSerial, scanHistory);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String mac, String serialNumber, String partNumber,
            String model, bool hasValidSerial, List<ScanRecord> scanHistory)?
        $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(
          mac, serialNumber, partNumber, model, hasValidSerial, scanHistory);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_AccumulatedScanData value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_AccumulatedScanData value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_AccumulatedScanData value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _AccumulatedScanData extends AccumulatedScanData {
  const factory _AccumulatedScanData(
      {final String mac,
      final String serialNumber,
      final String partNumber,
      final String model,
      final bool hasValidSerial,
      final List<ScanRecord> scanHistory}) = _$AccumulatedScanDataImpl;
  const _AccumulatedScanData._() : super._();

  @override
  String get mac;
  @override
  String get serialNumber;
  @override
  String get partNumber;
  @override
  String get model;
  @override
  bool get hasValidSerial;
  @override
  List<ScanRecord> get scanHistory;
  @override
  @JsonKey(ignore: true)
  _$$AccumulatedScanDataImplCopyWith<_$AccumulatedScanDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RxgCredentials {
  String get fqdn => throw _privateConstructorUsedError;
  String get login => throw _privateConstructorUsedError;
  String get apiKey => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String fqdn, String login, String apiKey) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String fqdn, String login, String apiKey)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String fqdn, String login, String apiKey)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_RxgCredentials value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_RxgCredentials value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_RxgCredentials value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $RxgCredentialsCopyWith<RxgCredentials> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RxgCredentialsCopyWith<$Res> {
  factory $RxgCredentialsCopyWith(
          RxgCredentials value, $Res Function(RxgCredentials) then) =
      _$RxgCredentialsCopyWithImpl<$Res, RxgCredentials>;
  @useResult
  $Res call({String fqdn, String login, String apiKey});
}

/// @nodoc
class _$RxgCredentialsCopyWithImpl<$Res, $Val extends RxgCredentials>
    implements $RxgCredentialsCopyWith<$Res> {
  _$RxgCredentialsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fqdn = null,
    Object? login = null,
    Object? apiKey = null,
  }) {
    return _then(_value.copyWith(
      fqdn: null == fqdn
          ? _value.fqdn
          : fqdn // ignore: cast_nullable_to_non_nullable
              as String,
      login: null == login
          ? _value.login
          : login // ignore: cast_nullable_to_non_nullable
              as String,
      apiKey: null == apiKey
          ? _value.apiKey
          : apiKey // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RxgCredentialsImplCopyWith<$Res>
    implements $RxgCredentialsCopyWith<$Res> {
  factory _$$RxgCredentialsImplCopyWith(_$RxgCredentialsImpl value,
          $Res Function(_$RxgCredentialsImpl) then) =
      __$$RxgCredentialsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String fqdn, String login, String apiKey});
}

/// @nodoc
class __$$RxgCredentialsImplCopyWithImpl<$Res>
    extends _$RxgCredentialsCopyWithImpl<$Res, _$RxgCredentialsImpl>
    implements _$$RxgCredentialsImplCopyWith<$Res> {
  __$$RxgCredentialsImplCopyWithImpl(
      _$RxgCredentialsImpl _value, $Res Function(_$RxgCredentialsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fqdn = null,
    Object? login = null,
    Object? apiKey = null,
  }) {
    return _then(_$RxgCredentialsImpl(
      fqdn: null == fqdn
          ? _value.fqdn
          : fqdn // ignore: cast_nullable_to_non_nullable
              as String,
      login: null == login
          ? _value.login
          : login // ignore: cast_nullable_to_non_nullable
              as String,
      apiKey: null == apiKey
          ? _value.apiKey
          : apiKey // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$RxgCredentialsImpl extends _RxgCredentials {
  const _$RxgCredentialsImpl(
      {required this.fqdn, required this.login, required this.apiKey})
      : super._();

  @override
  final String fqdn;
  @override
  final String login;
  @override
  final String apiKey;

  @override
  String toString() {
    return 'RxgCredentials(fqdn: $fqdn, login: $login, apiKey: $apiKey)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RxgCredentialsImpl &&
            (identical(other.fqdn, fqdn) || other.fqdn == fqdn) &&
            (identical(other.login, login) || other.login == login) &&
            (identical(other.apiKey, apiKey) || other.apiKey == apiKey));
  }

  @override
  int get hashCode => Object.hash(runtimeType, fqdn, login, apiKey);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RxgCredentialsImplCopyWith<_$RxgCredentialsImpl> get copyWith =>
      __$$RxgCredentialsImplCopyWithImpl<_$RxgCredentialsImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String fqdn, String login, String apiKey) $default,
  ) {
    return $default(fqdn, login, apiKey);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String fqdn, String login, String apiKey)? $default,
  ) {
    return $default?.call(fqdn, login, apiKey);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String fqdn, String login, String apiKey)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(fqdn, login, apiKey);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_RxgCredentials value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_RxgCredentials value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_RxgCredentials value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _RxgCredentials extends RxgCredentials {
  const factory _RxgCredentials(
      {required final String fqdn,
      required final String login,
      required final String apiKey}) = _$RxgCredentialsImpl;
  const _RxgCredentials._() : super._();

  @override
  String get fqdn;
  @override
  String get login;
  @override
  String get apiKey;
  @override
  @JsonKey(ignore: true)
  _$$RxgCredentialsImplCopyWith<_$RxgCredentialsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ScannerState {
  /// Current scan mode.
  ScanMode get scanMode => throw _privateConstructorUsedError;

  /// Current UI state.
  ScannerUIState get uiState => throw _privateConstructorUsedError;

  /// Whether mode was auto-locked from auto mode.
  bool get isAutoLocked => throw _privateConstructorUsedError;

  /// Whether mode was auto-reverted back to auto.
  bool get wasAutoReverted => throw _privateConstructorUsedError;

  /// Accumulated scan data for current session.
  AccumulatedScanData get scanData => throw _privateConstructorUsedError;

  /// Last time a valid serial was detected (for auto-revert).
  DateTime? get lastSerialSeenAt => throw _privateConstructorUsedError;

  /// RxG credentials if scanning RxG QR.
  RxgCredentials? get rxgCredentials => throw _privateConstructorUsedError;

  /// Error message if any.
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Whether registration popup is showing.
  bool get isPopupShowing => throw _privateConstructorUsedError;

  /// Whether registration is in progress.
  bool get isRegistrationInProgress => throw _privateConstructorUsedError;

  /// Selected room ID for registration.
  int? get selectedRoomId => throw _privateConstructorUsedError;

  /// Selected room number/name for display.
  String? get selectedRoomNumber => throw _privateConstructorUsedError;

  /// Matched device ID if existing device found.
  int? get matchedDeviceId => throw _privateConstructorUsedError;

  /// Matched device name.
  String? get matchedDeviceName => throw _privateConstructorUsedError;

  /// Matched device's current room ID (for move/reset detection).
  int? get matchedDeviceRoomId => throw _privateConstructorUsedError;

  /// Matched device's current room name (for display).
  String? get matchedDeviceRoomName => throw _privateConstructorUsedError;

  /// Device match status.
  DeviceMatchStatus get matchStatus => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            ScanMode scanMode,
            ScannerUIState uiState,
            bool isAutoLocked,
            bool wasAutoReverted,
            AccumulatedScanData scanData,
            DateTime? lastSerialSeenAt,
            RxgCredentials? rxgCredentials,
            String? errorMessage,
            bool isPopupShowing,
            bool isRegistrationInProgress,
            int? selectedRoomId,
            String? selectedRoomNumber,
            int? matchedDeviceId,
            String? matchedDeviceName,
            int? matchedDeviceRoomId,
            String? matchedDeviceRoomName,
            DeviceMatchStatus matchStatus)
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            ScanMode scanMode,
            ScannerUIState uiState,
            bool isAutoLocked,
            bool wasAutoReverted,
            AccumulatedScanData scanData,
            DateTime? lastSerialSeenAt,
            RxgCredentials? rxgCredentials,
            String? errorMessage,
            bool isPopupShowing,
            bool isRegistrationInProgress,
            int? selectedRoomId,
            String? selectedRoomNumber,
            int? matchedDeviceId,
            String? matchedDeviceName,
            int? matchedDeviceRoomId,
            String? matchedDeviceRoomName,
            DeviceMatchStatus matchStatus)?
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            ScanMode scanMode,
            ScannerUIState uiState,
            bool isAutoLocked,
            bool wasAutoReverted,
            AccumulatedScanData scanData,
            DateTime? lastSerialSeenAt,
            RxgCredentials? rxgCredentials,
            String? errorMessage,
            bool isPopupShowing,
            bool isRegistrationInProgress,
            int? selectedRoomId,
            String? selectedRoomNumber,
            int? matchedDeviceId,
            String? matchedDeviceName,
            int? matchedDeviceRoomId,
            String? matchedDeviceRoomName,
            DeviceMatchStatus matchStatus)?
        $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ScannerState value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ScannerState value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ScannerState value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ScannerStateCopyWith<ScannerState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScannerStateCopyWith<$Res> {
  factory $ScannerStateCopyWith(
          ScannerState value, $Res Function(ScannerState) then) =
      _$ScannerStateCopyWithImpl<$Res, ScannerState>;
  @useResult
  $Res call(
      {ScanMode scanMode,
      ScannerUIState uiState,
      bool isAutoLocked,
      bool wasAutoReverted,
      AccumulatedScanData scanData,
      DateTime? lastSerialSeenAt,
      RxgCredentials? rxgCredentials,
      String? errorMessage,
      bool isPopupShowing,
      bool isRegistrationInProgress,
      int? selectedRoomId,
      String? selectedRoomNumber,
      int? matchedDeviceId,
      String? matchedDeviceName,
      int? matchedDeviceRoomId,
      String? matchedDeviceRoomName,
      DeviceMatchStatus matchStatus});

  $AccumulatedScanDataCopyWith<$Res> get scanData;
  $RxgCredentialsCopyWith<$Res>? get rxgCredentials;
}

/// @nodoc
class _$ScannerStateCopyWithImpl<$Res, $Val extends ScannerState>
    implements $ScannerStateCopyWith<$Res> {
  _$ScannerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scanMode = null,
    Object? uiState = null,
    Object? isAutoLocked = null,
    Object? wasAutoReverted = null,
    Object? scanData = null,
    Object? lastSerialSeenAt = freezed,
    Object? rxgCredentials = freezed,
    Object? errorMessage = freezed,
    Object? isPopupShowing = null,
    Object? isRegistrationInProgress = null,
    Object? selectedRoomId = freezed,
    Object? selectedRoomNumber = freezed,
    Object? matchedDeviceId = freezed,
    Object? matchedDeviceName = freezed,
    Object? matchedDeviceRoomId = freezed,
    Object? matchedDeviceRoomName = freezed,
    Object? matchStatus = null,
  }) {
    return _then(_value.copyWith(
      scanMode: null == scanMode
          ? _value.scanMode
          : scanMode // ignore: cast_nullable_to_non_nullable
              as ScanMode,
      uiState: null == uiState
          ? _value.uiState
          : uiState // ignore: cast_nullable_to_non_nullable
              as ScannerUIState,
      isAutoLocked: null == isAutoLocked
          ? _value.isAutoLocked
          : isAutoLocked // ignore: cast_nullable_to_non_nullable
              as bool,
      wasAutoReverted: null == wasAutoReverted
          ? _value.wasAutoReverted
          : wasAutoReverted // ignore: cast_nullable_to_non_nullable
              as bool,
      scanData: null == scanData
          ? _value.scanData
          : scanData // ignore: cast_nullable_to_non_nullable
              as AccumulatedScanData,
      lastSerialSeenAt: freezed == lastSerialSeenAt
          ? _value.lastSerialSeenAt
          : lastSerialSeenAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      rxgCredentials: freezed == rxgCredentials
          ? _value.rxgCredentials
          : rxgCredentials // ignore: cast_nullable_to_non_nullable
              as RxgCredentials?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      isPopupShowing: null == isPopupShowing
          ? _value.isPopupShowing
          : isPopupShowing // ignore: cast_nullable_to_non_nullable
              as bool,
      isRegistrationInProgress: null == isRegistrationInProgress
          ? _value.isRegistrationInProgress
          : isRegistrationInProgress // ignore: cast_nullable_to_non_nullable
              as bool,
      selectedRoomId: freezed == selectedRoomId
          ? _value.selectedRoomId
          : selectedRoomId // ignore: cast_nullable_to_non_nullable
              as int?,
      selectedRoomNumber: freezed == selectedRoomNumber
          ? _value.selectedRoomNumber
          : selectedRoomNumber // ignore: cast_nullable_to_non_nullable
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
      matchStatus: null == matchStatus
          ? _value.matchStatus
          : matchStatus // ignore: cast_nullable_to_non_nullable
              as DeviceMatchStatus,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $AccumulatedScanDataCopyWith<$Res> get scanData {
    return $AccumulatedScanDataCopyWith<$Res>(_value.scanData, (value) {
      return _then(_value.copyWith(scanData: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $RxgCredentialsCopyWith<$Res>? get rxgCredentials {
    if (_value.rxgCredentials == null) {
      return null;
    }

    return $RxgCredentialsCopyWith<$Res>(_value.rxgCredentials!, (value) {
      return _then(_value.copyWith(rxgCredentials: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ScannerStateImplCopyWith<$Res>
    implements $ScannerStateCopyWith<$Res> {
  factory _$$ScannerStateImplCopyWith(
          _$ScannerStateImpl value, $Res Function(_$ScannerStateImpl) then) =
      __$$ScannerStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ScanMode scanMode,
      ScannerUIState uiState,
      bool isAutoLocked,
      bool wasAutoReverted,
      AccumulatedScanData scanData,
      DateTime? lastSerialSeenAt,
      RxgCredentials? rxgCredentials,
      String? errorMessage,
      bool isPopupShowing,
      bool isRegistrationInProgress,
      int? selectedRoomId,
      String? selectedRoomNumber,
      int? matchedDeviceId,
      String? matchedDeviceName,
      int? matchedDeviceRoomId,
      String? matchedDeviceRoomName,
      DeviceMatchStatus matchStatus});

  @override
  $AccumulatedScanDataCopyWith<$Res> get scanData;
  @override
  $RxgCredentialsCopyWith<$Res>? get rxgCredentials;
}

/// @nodoc
class __$$ScannerStateImplCopyWithImpl<$Res>
    extends _$ScannerStateCopyWithImpl<$Res, _$ScannerStateImpl>
    implements _$$ScannerStateImplCopyWith<$Res> {
  __$$ScannerStateImplCopyWithImpl(
      _$ScannerStateImpl _value, $Res Function(_$ScannerStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scanMode = null,
    Object? uiState = null,
    Object? isAutoLocked = null,
    Object? wasAutoReverted = null,
    Object? scanData = null,
    Object? lastSerialSeenAt = freezed,
    Object? rxgCredentials = freezed,
    Object? errorMessage = freezed,
    Object? isPopupShowing = null,
    Object? isRegistrationInProgress = null,
    Object? selectedRoomId = freezed,
    Object? selectedRoomNumber = freezed,
    Object? matchedDeviceId = freezed,
    Object? matchedDeviceName = freezed,
    Object? matchedDeviceRoomId = freezed,
    Object? matchedDeviceRoomName = freezed,
    Object? matchStatus = null,
  }) {
    return _then(_$ScannerStateImpl(
      scanMode: null == scanMode
          ? _value.scanMode
          : scanMode // ignore: cast_nullable_to_non_nullable
              as ScanMode,
      uiState: null == uiState
          ? _value.uiState
          : uiState // ignore: cast_nullable_to_non_nullable
              as ScannerUIState,
      isAutoLocked: null == isAutoLocked
          ? _value.isAutoLocked
          : isAutoLocked // ignore: cast_nullable_to_non_nullable
              as bool,
      wasAutoReverted: null == wasAutoReverted
          ? _value.wasAutoReverted
          : wasAutoReverted // ignore: cast_nullable_to_non_nullable
              as bool,
      scanData: null == scanData
          ? _value.scanData
          : scanData // ignore: cast_nullable_to_non_nullable
              as AccumulatedScanData,
      lastSerialSeenAt: freezed == lastSerialSeenAt
          ? _value.lastSerialSeenAt
          : lastSerialSeenAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      rxgCredentials: freezed == rxgCredentials
          ? _value.rxgCredentials
          : rxgCredentials // ignore: cast_nullable_to_non_nullable
              as RxgCredentials?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      isPopupShowing: null == isPopupShowing
          ? _value.isPopupShowing
          : isPopupShowing // ignore: cast_nullable_to_non_nullable
              as bool,
      isRegistrationInProgress: null == isRegistrationInProgress
          ? _value.isRegistrationInProgress
          : isRegistrationInProgress // ignore: cast_nullable_to_non_nullable
              as bool,
      selectedRoomId: freezed == selectedRoomId
          ? _value.selectedRoomId
          : selectedRoomId // ignore: cast_nullable_to_non_nullable
              as int?,
      selectedRoomNumber: freezed == selectedRoomNumber
          ? _value.selectedRoomNumber
          : selectedRoomNumber // ignore: cast_nullable_to_non_nullable
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
      matchStatus: null == matchStatus
          ? _value.matchStatus
          : matchStatus // ignore: cast_nullable_to_non_nullable
              as DeviceMatchStatus,
    ));
  }
}

/// @nodoc

class _$ScannerStateImpl extends _ScannerState {
  const _$ScannerStateImpl(
      {this.scanMode = ScanMode.auto,
      this.uiState = ScannerUIState.idle,
      this.isAutoLocked = false,
      this.wasAutoReverted = false,
      this.scanData = const AccumulatedScanData(),
      this.lastSerialSeenAt,
      this.rxgCredentials,
      this.errorMessage,
      this.isPopupShowing = false,
      this.isRegistrationInProgress = false,
      this.selectedRoomId,
      this.selectedRoomNumber,
      this.matchedDeviceId,
      this.matchedDeviceName,
      this.matchedDeviceRoomId,
      this.matchedDeviceRoomName,
      this.matchStatus = DeviceMatchStatus.unchecked})
      : super._();

  /// Current scan mode.
  @override
  @JsonKey()
  final ScanMode scanMode;

  /// Current UI state.
  @override
  @JsonKey()
  final ScannerUIState uiState;

  /// Whether mode was auto-locked from auto mode.
  @override
  @JsonKey()
  final bool isAutoLocked;

  /// Whether mode was auto-reverted back to auto.
  @override
  @JsonKey()
  final bool wasAutoReverted;

  /// Accumulated scan data for current session.
  @override
  @JsonKey()
  final AccumulatedScanData scanData;

  /// Last time a valid serial was detected (for auto-revert).
  @override
  final DateTime? lastSerialSeenAt;

  /// RxG credentials if scanning RxG QR.
  @override
  final RxgCredentials? rxgCredentials;

  /// Error message if any.
  @override
  final String? errorMessage;

  /// Whether registration popup is showing.
  @override
  @JsonKey()
  final bool isPopupShowing;

  /// Whether registration is in progress.
  @override
  @JsonKey()
  final bool isRegistrationInProgress;

  /// Selected room ID for registration.
  @override
  final int? selectedRoomId;

  /// Selected room number/name for display.
  @override
  final String? selectedRoomNumber;

  /// Matched device ID if existing device found.
  @override
  final int? matchedDeviceId;

  /// Matched device name.
  @override
  final String? matchedDeviceName;

  /// Matched device's current room ID (for move/reset detection).
  @override
  final int? matchedDeviceRoomId;

  /// Matched device's current room name (for display).
  @override
  final String? matchedDeviceRoomName;

  /// Device match status.
  @override
  @JsonKey()
  final DeviceMatchStatus matchStatus;

  @override
  String toString() {
    return 'ScannerState(scanMode: $scanMode, uiState: $uiState, isAutoLocked: $isAutoLocked, wasAutoReverted: $wasAutoReverted, scanData: $scanData, lastSerialSeenAt: $lastSerialSeenAt, rxgCredentials: $rxgCredentials, errorMessage: $errorMessage, isPopupShowing: $isPopupShowing, isRegistrationInProgress: $isRegistrationInProgress, selectedRoomId: $selectedRoomId, selectedRoomNumber: $selectedRoomNumber, matchedDeviceId: $matchedDeviceId, matchedDeviceName: $matchedDeviceName, matchedDeviceRoomId: $matchedDeviceRoomId, matchedDeviceRoomName: $matchedDeviceRoomName, matchStatus: $matchStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScannerStateImpl &&
            (identical(other.scanMode, scanMode) ||
                other.scanMode == scanMode) &&
            (identical(other.uiState, uiState) || other.uiState == uiState) &&
            (identical(other.isAutoLocked, isAutoLocked) ||
                other.isAutoLocked == isAutoLocked) &&
            (identical(other.wasAutoReverted, wasAutoReverted) ||
                other.wasAutoReverted == wasAutoReverted) &&
            (identical(other.scanData, scanData) ||
                other.scanData == scanData) &&
            (identical(other.lastSerialSeenAt, lastSerialSeenAt) ||
                other.lastSerialSeenAt == lastSerialSeenAt) &&
            (identical(other.rxgCredentials, rxgCredentials) ||
                other.rxgCredentials == rxgCredentials) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.isPopupShowing, isPopupShowing) ||
                other.isPopupShowing == isPopupShowing) &&
            (identical(
                    other.isRegistrationInProgress, isRegistrationInProgress) ||
                other.isRegistrationInProgress == isRegistrationInProgress) &&
            (identical(other.selectedRoomId, selectedRoomId) ||
                other.selectedRoomId == selectedRoomId) &&
            (identical(other.selectedRoomNumber, selectedRoomNumber) ||
                other.selectedRoomNumber == selectedRoomNumber) &&
            (identical(other.matchedDeviceId, matchedDeviceId) ||
                other.matchedDeviceId == matchedDeviceId) &&
            (identical(other.matchedDeviceName, matchedDeviceName) ||
                other.matchedDeviceName == matchedDeviceName) &&
            (identical(other.matchedDeviceRoomId, matchedDeviceRoomId) ||
                other.matchedDeviceRoomId == matchedDeviceRoomId) &&
            (identical(other.matchedDeviceRoomName, matchedDeviceRoomName) ||
                other.matchedDeviceRoomName == matchedDeviceRoomName) &&
            (identical(other.matchStatus, matchStatus) ||
                other.matchStatus == matchStatus));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      scanMode,
      uiState,
      isAutoLocked,
      wasAutoReverted,
      scanData,
      lastSerialSeenAt,
      rxgCredentials,
      errorMessage,
      isPopupShowing,
      isRegistrationInProgress,
      selectedRoomId,
      selectedRoomNumber,
      matchedDeviceId,
      matchedDeviceName,
      matchedDeviceRoomId,
      matchedDeviceRoomName,
      matchStatus);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ScannerStateImplCopyWith<_$ScannerStateImpl> get copyWith =>
      __$$ScannerStateImplCopyWithImpl<_$ScannerStateImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            ScanMode scanMode,
            ScannerUIState uiState,
            bool isAutoLocked,
            bool wasAutoReverted,
            AccumulatedScanData scanData,
            DateTime? lastSerialSeenAt,
            RxgCredentials? rxgCredentials,
            String? errorMessage,
            bool isPopupShowing,
            bool isRegistrationInProgress,
            int? selectedRoomId,
            String? selectedRoomNumber,
            int? matchedDeviceId,
            String? matchedDeviceName,
            int? matchedDeviceRoomId,
            String? matchedDeviceRoomName,
            DeviceMatchStatus matchStatus)
        $default,
  ) {
    return $default(
        scanMode,
        uiState,
        isAutoLocked,
        wasAutoReverted,
        scanData,
        lastSerialSeenAt,
        rxgCredentials,
        errorMessage,
        isPopupShowing,
        isRegistrationInProgress,
        selectedRoomId,
        selectedRoomNumber,
        matchedDeviceId,
        matchedDeviceName,
        matchedDeviceRoomId,
        matchedDeviceRoomName,
        matchStatus);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            ScanMode scanMode,
            ScannerUIState uiState,
            bool isAutoLocked,
            bool wasAutoReverted,
            AccumulatedScanData scanData,
            DateTime? lastSerialSeenAt,
            RxgCredentials? rxgCredentials,
            String? errorMessage,
            bool isPopupShowing,
            bool isRegistrationInProgress,
            int? selectedRoomId,
            String? selectedRoomNumber,
            int? matchedDeviceId,
            String? matchedDeviceName,
            int? matchedDeviceRoomId,
            String? matchedDeviceRoomName,
            DeviceMatchStatus matchStatus)?
        $default,
  ) {
    return $default?.call(
        scanMode,
        uiState,
        isAutoLocked,
        wasAutoReverted,
        scanData,
        lastSerialSeenAt,
        rxgCredentials,
        errorMessage,
        isPopupShowing,
        isRegistrationInProgress,
        selectedRoomId,
        selectedRoomNumber,
        matchedDeviceId,
        matchedDeviceName,
        matchedDeviceRoomId,
        matchedDeviceRoomName,
        matchStatus);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            ScanMode scanMode,
            ScannerUIState uiState,
            bool isAutoLocked,
            bool wasAutoReverted,
            AccumulatedScanData scanData,
            DateTime? lastSerialSeenAt,
            RxgCredentials? rxgCredentials,
            String? errorMessage,
            bool isPopupShowing,
            bool isRegistrationInProgress,
            int? selectedRoomId,
            String? selectedRoomNumber,
            int? matchedDeviceId,
            String? matchedDeviceName,
            int? matchedDeviceRoomId,
            String? matchedDeviceRoomName,
            DeviceMatchStatus matchStatus)?
        $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(
          scanMode,
          uiState,
          isAutoLocked,
          wasAutoReverted,
          scanData,
          lastSerialSeenAt,
          rxgCredentials,
          errorMessage,
          isPopupShowing,
          isRegistrationInProgress,
          selectedRoomId,
          selectedRoomNumber,
          matchedDeviceId,
          matchedDeviceName,
          matchedDeviceRoomId,
          matchedDeviceRoomName,
          matchStatus);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ScannerState value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ScannerState value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ScannerState value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _ScannerState extends ScannerState {
  const factory _ScannerState(
      {final ScanMode scanMode,
      final ScannerUIState uiState,
      final bool isAutoLocked,
      final bool wasAutoReverted,
      final AccumulatedScanData scanData,
      final DateTime? lastSerialSeenAt,
      final RxgCredentials? rxgCredentials,
      final String? errorMessage,
      final bool isPopupShowing,
      final bool isRegistrationInProgress,
      final int? selectedRoomId,
      final String? selectedRoomNumber,
      final int? matchedDeviceId,
      final String? matchedDeviceName,
      final int? matchedDeviceRoomId,
      final String? matchedDeviceRoomName,
      final DeviceMatchStatus matchStatus}) = _$ScannerStateImpl;
  const _ScannerState._() : super._();

  @override

  /// Current scan mode.
  ScanMode get scanMode;
  @override

  /// Current UI state.
  ScannerUIState get uiState;
  @override

  /// Whether mode was auto-locked from auto mode.
  bool get isAutoLocked;
  @override

  /// Whether mode was auto-reverted back to auto.
  bool get wasAutoReverted;
  @override

  /// Accumulated scan data for current session.
  AccumulatedScanData get scanData;
  @override

  /// Last time a valid serial was detected (for auto-revert).
  DateTime? get lastSerialSeenAt;
  @override

  /// RxG credentials if scanning RxG QR.
  RxgCredentials? get rxgCredentials;
  @override

  /// Error message if any.
  String? get errorMessage;
  @override

  /// Whether registration popup is showing.
  bool get isPopupShowing;
  @override

  /// Whether registration is in progress.
  bool get isRegistrationInProgress;
  @override

  /// Selected room ID for registration.
  int? get selectedRoomId;
  @override

  /// Selected room number/name for display.
  String? get selectedRoomNumber;
  @override

  /// Matched device ID if existing device found.
  int? get matchedDeviceId;
  @override

  /// Matched device name.
  String? get matchedDeviceName;
  @override

  /// Matched device's current room ID (for move/reset detection).
  int? get matchedDeviceRoomId;
  @override

  /// Matched device's current room name (for display).
  String? get matchedDeviceRoomName;
  @override

  /// Device match status.
  DeviceMatchStatus get matchStatus;
  @override
  @JsonKey(ignore: true)
  _$$ScannerStateImplCopyWith<_$ScannerStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
