// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'barcode_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$BarcodeData {
  String get rawValue => throw _privateConstructorUsedError;
  String get format => throw _privateConstructorUsedError;
  DateTime get scannedAt => throw _privateConstructorUsedError;
  Map<String, String>? get extractedFields =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String rawValue, String format, DateTime scannedAt,
            Map<String, String>? extractedFields)
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String rawValue, String format, DateTime scannedAt,
            Map<String, String>? extractedFields)?
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String rawValue, String format, DateTime scannedAt,
            Map<String, String>? extractedFields)?
        $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_BarcodeData value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_BarcodeData value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_BarcodeData value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $BarcodeDataCopyWith<BarcodeData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BarcodeDataCopyWith<$Res> {
  factory $BarcodeDataCopyWith(
          BarcodeData value, $Res Function(BarcodeData) then) =
      _$BarcodeDataCopyWithImpl<$Res, BarcodeData>;
  @useResult
  $Res call(
      {String rawValue,
      String format,
      DateTime scannedAt,
      Map<String, String>? extractedFields});
}

/// @nodoc
class _$BarcodeDataCopyWithImpl<$Res, $Val extends BarcodeData>
    implements $BarcodeDataCopyWith<$Res> {
  _$BarcodeDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rawValue = null,
    Object? format = null,
    Object? scannedAt = null,
    Object? extractedFields = freezed,
  }) {
    return _then(_value.copyWith(
      rawValue: null == rawValue
          ? _value.rawValue
          : rawValue // ignore: cast_nullable_to_non_nullable
              as String,
      format: null == format
          ? _value.format
          : format // ignore: cast_nullable_to_non_nullable
              as String,
      scannedAt: null == scannedAt
          ? _value.scannedAt
          : scannedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      extractedFields: freezed == extractedFields
          ? _value.extractedFields
          : extractedFields // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BarcodeDataImplCopyWith<$Res>
    implements $BarcodeDataCopyWith<$Res> {
  factory _$$BarcodeDataImplCopyWith(
          _$BarcodeDataImpl value, $Res Function(_$BarcodeDataImpl) then) =
      __$$BarcodeDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String rawValue,
      String format,
      DateTime scannedAt,
      Map<String, String>? extractedFields});
}

/// @nodoc
class __$$BarcodeDataImplCopyWithImpl<$Res>
    extends _$BarcodeDataCopyWithImpl<$Res, _$BarcodeDataImpl>
    implements _$$BarcodeDataImplCopyWith<$Res> {
  __$$BarcodeDataImplCopyWithImpl(
      _$BarcodeDataImpl _value, $Res Function(_$BarcodeDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rawValue = null,
    Object? format = null,
    Object? scannedAt = null,
    Object? extractedFields = freezed,
  }) {
    return _then(_$BarcodeDataImpl(
      rawValue: null == rawValue
          ? _value.rawValue
          : rawValue // ignore: cast_nullable_to_non_nullable
              as String,
      format: null == format
          ? _value.format
          : format // ignore: cast_nullable_to_non_nullable
              as String,
      scannedAt: null == scannedAt
          ? _value.scannedAt
          : scannedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      extractedFields: freezed == extractedFields
          ? _value._extractedFields
          : extractedFields // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
    ));
  }
}

/// @nodoc

class _$BarcodeDataImpl extends _BarcodeData {
  const _$BarcodeDataImpl(
      {required this.rawValue,
      required this.format,
      required this.scannedAt,
      final Map<String, String>? extractedFields})
      : _extractedFields = extractedFields,
        super._();

  @override
  final String rawValue;
  @override
  final String format;
  @override
  final DateTime scannedAt;
  final Map<String, String>? _extractedFields;
  @override
  Map<String, String>? get extractedFields {
    final value = _extractedFields;
    if (value == null) return null;
    if (_extractedFields is EqualUnmodifiableMapView) return _extractedFields;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'BarcodeData(rawValue: $rawValue, format: $format, scannedAt: $scannedAt, extractedFields: $extractedFields)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BarcodeDataImpl &&
            (identical(other.rawValue, rawValue) ||
                other.rawValue == rawValue) &&
            (identical(other.format, format) || other.format == format) &&
            (identical(other.scannedAt, scannedAt) ||
                other.scannedAt == scannedAt) &&
            const DeepCollectionEquality()
                .equals(other._extractedFields, _extractedFields));
  }

  @override
  int get hashCode => Object.hash(runtimeType, rawValue, format, scannedAt,
      const DeepCollectionEquality().hash(_extractedFields));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BarcodeDataImplCopyWith<_$BarcodeDataImpl> get copyWith =>
      __$$BarcodeDataImplCopyWithImpl<_$BarcodeDataImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String rawValue, String format, DateTime scannedAt,
            Map<String, String>? extractedFields)
        $default,
  ) {
    return $default(rawValue, format, scannedAt, extractedFields);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String rawValue, String format, DateTime scannedAt,
            Map<String, String>? extractedFields)?
        $default,
  ) {
    return $default?.call(rawValue, format, scannedAt, extractedFields);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String rawValue, String format, DateTime scannedAt,
            Map<String, String>? extractedFields)?
        $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(rawValue, format, scannedAt, extractedFields);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_BarcodeData value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_BarcodeData value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_BarcodeData value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _BarcodeData extends BarcodeData {
  const factory _BarcodeData(
      {required final String rawValue,
      required final String format,
      required final DateTime scannedAt,
      final Map<String, String>? extractedFields}) = _$BarcodeDataImpl;
  const _BarcodeData._() : super._();

  @override
  String get rawValue;
  @override
  String get format;
  @override
  DateTime get scannedAt;
  @override
  Map<String, String>? get extractedFields;
  @override
  @JsonKey(ignore: true)
  _$$BarcodeDataImplCopyWith<_$BarcodeDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
