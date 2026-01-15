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
  double get downloadSpeed => throw _privateConstructorUsedError;
  double get uploadSpeed => throw _privateConstructorUsedError;
  double get latency => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  bool get hasError => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  String? get localIpAddress => throw _privateConstructorUsedError;
  String? get serverHost => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            double downloadSpeed,
            double uploadSpeed,
            double latency,
            DateTime timestamp,
            bool hasError,
            String? errorMessage,
            String? localIpAddress,
            String? serverHost)
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            double downloadSpeed,
            double uploadSpeed,
            double latency,
            DateTime timestamp,
            bool hasError,
            String? errorMessage,
            String? localIpAddress,
            String? serverHost)?
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            double downloadSpeed,
            double uploadSpeed,
            double latency,
            DateTime timestamp,
            bool hasError,
            String? errorMessage,
            String? localIpAddress,
            String? serverHost)?
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
      {double downloadSpeed,
      double uploadSpeed,
      double latency,
      DateTime timestamp,
      bool hasError,
      String? errorMessage,
      String? localIpAddress,
      String? serverHost});
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
    Object? downloadSpeed = null,
    Object? uploadSpeed = null,
    Object? latency = null,
    Object? timestamp = null,
    Object? hasError = null,
    Object? errorMessage = freezed,
    Object? localIpAddress = freezed,
    Object? serverHost = freezed,
  }) {
    return _then(_value.copyWith(
      downloadSpeed: null == downloadSpeed
          ? _value.downloadSpeed
          : downloadSpeed // ignore: cast_nullable_to_non_nullable
              as double,
      uploadSpeed: null == uploadSpeed
          ? _value.uploadSpeed
          : uploadSpeed // ignore: cast_nullable_to_non_nullable
              as double,
      latency: null == latency
          ? _value.latency
          : latency // ignore: cast_nullable_to_non_nullable
              as double,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
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
      {double downloadSpeed,
      double uploadSpeed,
      double latency,
      DateTime timestamp,
      bool hasError,
      String? errorMessage,
      String? localIpAddress,
      String? serverHost});
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
    Object? downloadSpeed = null,
    Object? uploadSpeed = null,
    Object? latency = null,
    Object? timestamp = null,
    Object? hasError = null,
    Object? errorMessage = freezed,
    Object? localIpAddress = freezed,
    Object? serverHost = freezed,
  }) {
    return _then(_$SpeedTestResultImpl(
      downloadSpeed: null == downloadSpeed
          ? _value.downloadSpeed
          : downloadSpeed // ignore: cast_nullable_to_non_nullable
              as double,
      uploadSpeed: null == uploadSpeed
          ? _value.uploadSpeed
          : uploadSpeed // ignore: cast_nullable_to_non_nullable
              as double,
      latency: null == latency
          ? _value.latency
          : latency // ignore: cast_nullable_to_non_nullable
              as double,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
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
      {required this.downloadSpeed,
      required this.uploadSpeed,
      required this.latency,
      required this.timestamp,
      this.hasError = false,
      this.errorMessage,
      this.localIpAddress,
      this.serverHost})
      : super._();

  factory _$SpeedTestResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$SpeedTestResultImplFromJson(json);

  @override
  final double downloadSpeed;
  @override
  final double uploadSpeed;
  @override
  final double latency;
  @override
  final DateTime timestamp;
  @override
  @JsonKey()
  final bool hasError;
  @override
  final String? errorMessage;
  @override
  final String? localIpAddress;
  @override
  final String? serverHost;

  @override
  String toString() {
    return 'SpeedTestResult(downloadSpeed: $downloadSpeed, uploadSpeed: $uploadSpeed, latency: $latency, timestamp: $timestamp, hasError: $hasError, errorMessage: $errorMessage, localIpAddress: $localIpAddress, serverHost: $serverHost)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SpeedTestResultImpl &&
            (identical(other.downloadSpeed, downloadSpeed) ||
                other.downloadSpeed == downloadSpeed) &&
            (identical(other.uploadSpeed, uploadSpeed) ||
                other.uploadSpeed == uploadSpeed) &&
            (identical(other.latency, latency) || other.latency == latency) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
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
  int get hashCode => Object.hash(runtimeType, downloadSpeed, uploadSpeed,
      latency, timestamp, hasError, errorMessage, localIpAddress, serverHost);

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
            double downloadSpeed,
            double uploadSpeed,
            double latency,
            DateTime timestamp,
            bool hasError,
            String? errorMessage,
            String? localIpAddress,
            String? serverHost)
        $default,
  ) {
    return $default(downloadSpeed, uploadSpeed, latency, timestamp, hasError,
        errorMessage, localIpAddress, serverHost);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            double downloadSpeed,
            double uploadSpeed,
            double latency,
            DateTime timestamp,
            bool hasError,
            String? errorMessage,
            String? localIpAddress,
            String? serverHost)?
        $default,
  ) {
    return $default?.call(downloadSpeed, uploadSpeed, latency, timestamp,
        hasError, errorMessage, localIpAddress, serverHost);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            double downloadSpeed,
            double uploadSpeed,
            double latency,
            DateTime timestamp,
            bool hasError,
            String? errorMessage,
            String? localIpAddress,
            String? serverHost)?
        $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(downloadSpeed, uploadSpeed, latency, timestamp, hasError,
          errorMessage, localIpAddress, serverHost);
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
      {required final double downloadSpeed,
      required final double uploadSpeed,
      required final double latency,
      required final DateTime timestamp,
      final bool hasError,
      final String? errorMessage,
      final String? localIpAddress,
      final String? serverHost}) = _$SpeedTestResultImpl;
  const _SpeedTestResult._() : super._();

  factory _SpeedTestResult.fromJson(Map<String, dynamic> json) =
      _$SpeedTestResultImpl.fromJson;

  @override
  double get downloadSpeed;
  @override
  double get uploadSpeed;
  @override
  double get latency;
  @override
  DateTime get timestamp;
  @override
  bool get hasError;
  @override
  String? get errorMessage;
  @override
  String? get localIpAddress;
  @override
  String? get serverHost;
  @override
  @JsonKey(ignore: true)
  _$$SpeedTestResultImplCopyWith<_$SpeedTestResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
