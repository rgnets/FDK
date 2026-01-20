// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'speed_test_run_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SpeedTestRunState {
// Execution status (idle, running, completed, error)
  SpeedTestStatus get executionStatus =>
      throw _privateConstructorUsedError; // Progress (0-100)
  double get progress =>
      throw _privateConstructorUsedError; // Status message (for UI display)
  String? get statusMessage =>
      throw _privateConstructorUsedError; // Result data (from result stream)
  double get downloadSpeed => throw _privateConstructorUsedError;
  double get uploadSpeed => throw _privateConstructorUsedError;
  double get latency =>
      throw _privateConstructorUsedError; // Validation status: null = not run, true = passed, false = failed
  bool? get testPassed => throw _privateConstructorUsedError; // Error state
  String? get errorMessage =>
      throw _privateConstructorUsedError; // Network info
  String? get localIpAddress => throw _privateConstructorUsedError;
  String? get gatewayAddress =>
      throw _privateConstructorUsedError; // Server configuration
  String get serverHost => throw _privateConstructorUsedError;
  int get serverPort =>
      throw _privateConstructorUsedError; // Test configuration
  int get testDuration => throw _privateConstructorUsedError;
  int get bandwidthMbps => throw _privateConstructorUsedError;
  int get parallelStreams => throw _privateConstructorUsedError;
  bool get useUdp =>
      throw _privateConstructorUsedError; // Full result object (for submission)
  SpeedTestResult? get completedResult => throw _privateConstructorUsedError;
  SpeedTestConfig? get config =>
      throw _privateConstructorUsedError; // Initialization flag
  bool get isInitialized => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            SpeedTestStatus executionStatus,
            double progress,
            String? statusMessage,
            double downloadSpeed,
            double uploadSpeed,
            double latency,
            bool? testPassed,
            String? errorMessage,
            String? localIpAddress,
            String? gatewayAddress,
            String serverHost,
            int serverPort,
            int testDuration,
            int bandwidthMbps,
            int parallelStreams,
            bool useUdp,
            SpeedTestResult? completedResult,
            SpeedTestConfig? config,
            bool isInitialized)
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            SpeedTestStatus executionStatus,
            double progress,
            String? statusMessage,
            double downloadSpeed,
            double uploadSpeed,
            double latency,
            bool? testPassed,
            String? errorMessage,
            String? localIpAddress,
            String? gatewayAddress,
            String serverHost,
            int serverPort,
            int testDuration,
            int bandwidthMbps,
            int parallelStreams,
            bool useUdp,
            SpeedTestResult? completedResult,
            SpeedTestConfig? config,
            bool isInitialized)?
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            SpeedTestStatus executionStatus,
            double progress,
            String? statusMessage,
            double downloadSpeed,
            double uploadSpeed,
            double latency,
            bool? testPassed,
            String? errorMessage,
            String? localIpAddress,
            String? gatewayAddress,
            String serverHost,
            int serverPort,
            int testDuration,
            int bandwidthMbps,
            int parallelStreams,
            bool useUdp,
            SpeedTestResult? completedResult,
            SpeedTestConfig? config,
            bool isInitialized)?
        $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_SpeedTestRunState value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_SpeedTestRunState value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_SpeedTestRunState value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SpeedTestRunStateCopyWith<SpeedTestRunState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SpeedTestRunStateCopyWith<$Res> {
  factory $SpeedTestRunStateCopyWith(
          SpeedTestRunState value, $Res Function(SpeedTestRunState) then) =
      _$SpeedTestRunStateCopyWithImpl<$Res, SpeedTestRunState>;
  @useResult
  $Res call(
      {SpeedTestStatus executionStatus,
      double progress,
      String? statusMessage,
      double downloadSpeed,
      double uploadSpeed,
      double latency,
      bool? testPassed,
      String? errorMessage,
      String? localIpAddress,
      String? gatewayAddress,
      String serverHost,
      int serverPort,
      int testDuration,
      int bandwidthMbps,
      int parallelStreams,
      bool useUdp,
      SpeedTestResult? completedResult,
      SpeedTestConfig? config,
      bool isInitialized});

  $SpeedTestResultCopyWith<$Res>? get completedResult;
  $SpeedTestConfigCopyWith<$Res>? get config;
}

/// @nodoc
class _$SpeedTestRunStateCopyWithImpl<$Res, $Val extends SpeedTestRunState>
    implements $SpeedTestRunStateCopyWith<$Res> {
  _$SpeedTestRunStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? executionStatus = null,
    Object? progress = null,
    Object? statusMessage = freezed,
    Object? downloadSpeed = null,
    Object? uploadSpeed = null,
    Object? latency = null,
    Object? testPassed = freezed,
    Object? errorMessage = freezed,
    Object? localIpAddress = freezed,
    Object? gatewayAddress = freezed,
    Object? serverHost = null,
    Object? serverPort = null,
    Object? testDuration = null,
    Object? bandwidthMbps = null,
    Object? parallelStreams = null,
    Object? useUdp = null,
    Object? completedResult = freezed,
    Object? config = freezed,
    Object? isInitialized = null,
  }) {
    return _then(_value.copyWith(
      executionStatus: null == executionStatus
          ? _value.executionStatus
          : executionStatus // ignore: cast_nullable_to_non_nullable
              as SpeedTestStatus,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      statusMessage: freezed == statusMessage
          ? _value.statusMessage
          : statusMessage // ignore: cast_nullable_to_non_nullable
              as String?,
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
      testPassed: freezed == testPassed
          ? _value.testPassed
          : testPassed // ignore: cast_nullable_to_non_nullable
              as bool?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      localIpAddress: freezed == localIpAddress
          ? _value.localIpAddress
          : localIpAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      gatewayAddress: freezed == gatewayAddress
          ? _value.gatewayAddress
          : gatewayAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      serverHost: null == serverHost
          ? _value.serverHost
          : serverHost // ignore: cast_nullable_to_non_nullable
              as String,
      serverPort: null == serverPort
          ? _value.serverPort
          : serverPort // ignore: cast_nullable_to_non_nullable
              as int,
      testDuration: null == testDuration
          ? _value.testDuration
          : testDuration // ignore: cast_nullable_to_non_nullable
              as int,
      bandwidthMbps: null == bandwidthMbps
          ? _value.bandwidthMbps
          : bandwidthMbps // ignore: cast_nullable_to_non_nullable
              as int,
      parallelStreams: null == parallelStreams
          ? _value.parallelStreams
          : parallelStreams // ignore: cast_nullable_to_non_nullable
              as int,
      useUdp: null == useUdp
          ? _value.useUdp
          : useUdp // ignore: cast_nullable_to_non_nullable
              as bool,
      completedResult: freezed == completedResult
          ? _value.completedResult
          : completedResult // ignore: cast_nullable_to_non_nullable
              as SpeedTestResult?,
      config: freezed == config
          ? _value.config
          : config // ignore: cast_nullable_to_non_nullable
              as SpeedTestConfig?,
      isInitialized: null == isInitialized
          ? _value.isInitialized
          : isInitialized // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $SpeedTestResultCopyWith<$Res>? get completedResult {
    if (_value.completedResult == null) {
      return null;
    }

    return $SpeedTestResultCopyWith<$Res>(_value.completedResult!, (value) {
      return _then(_value.copyWith(completedResult: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $SpeedTestConfigCopyWith<$Res>? get config {
    if (_value.config == null) {
      return null;
    }

    return $SpeedTestConfigCopyWith<$Res>(_value.config!, (value) {
      return _then(_value.copyWith(config: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SpeedTestRunStateImplCopyWith<$Res>
    implements $SpeedTestRunStateCopyWith<$Res> {
  factory _$$SpeedTestRunStateImplCopyWith(_$SpeedTestRunStateImpl value,
          $Res Function(_$SpeedTestRunStateImpl) then) =
      __$$SpeedTestRunStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {SpeedTestStatus executionStatus,
      double progress,
      String? statusMessage,
      double downloadSpeed,
      double uploadSpeed,
      double latency,
      bool? testPassed,
      String? errorMessage,
      String? localIpAddress,
      String? gatewayAddress,
      String serverHost,
      int serverPort,
      int testDuration,
      int bandwidthMbps,
      int parallelStreams,
      bool useUdp,
      SpeedTestResult? completedResult,
      SpeedTestConfig? config,
      bool isInitialized});

  @override
  $SpeedTestResultCopyWith<$Res>? get completedResult;
  @override
  $SpeedTestConfigCopyWith<$Res>? get config;
}

/// @nodoc
class __$$SpeedTestRunStateImplCopyWithImpl<$Res>
    extends _$SpeedTestRunStateCopyWithImpl<$Res, _$SpeedTestRunStateImpl>
    implements _$$SpeedTestRunStateImplCopyWith<$Res> {
  __$$SpeedTestRunStateImplCopyWithImpl(_$SpeedTestRunStateImpl _value,
      $Res Function(_$SpeedTestRunStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? executionStatus = null,
    Object? progress = null,
    Object? statusMessage = freezed,
    Object? downloadSpeed = null,
    Object? uploadSpeed = null,
    Object? latency = null,
    Object? testPassed = freezed,
    Object? errorMessage = freezed,
    Object? localIpAddress = freezed,
    Object? gatewayAddress = freezed,
    Object? serverHost = null,
    Object? serverPort = null,
    Object? testDuration = null,
    Object? bandwidthMbps = null,
    Object? parallelStreams = null,
    Object? useUdp = null,
    Object? completedResult = freezed,
    Object? config = freezed,
    Object? isInitialized = null,
  }) {
    return _then(_$SpeedTestRunStateImpl(
      executionStatus: null == executionStatus
          ? _value.executionStatus
          : executionStatus // ignore: cast_nullable_to_non_nullable
              as SpeedTestStatus,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      statusMessage: freezed == statusMessage
          ? _value.statusMessage
          : statusMessage // ignore: cast_nullable_to_non_nullable
              as String?,
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
      testPassed: freezed == testPassed
          ? _value.testPassed
          : testPassed // ignore: cast_nullable_to_non_nullable
              as bool?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      localIpAddress: freezed == localIpAddress
          ? _value.localIpAddress
          : localIpAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      gatewayAddress: freezed == gatewayAddress
          ? _value.gatewayAddress
          : gatewayAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      serverHost: null == serverHost
          ? _value.serverHost
          : serverHost // ignore: cast_nullable_to_non_nullable
              as String,
      serverPort: null == serverPort
          ? _value.serverPort
          : serverPort // ignore: cast_nullable_to_non_nullable
              as int,
      testDuration: null == testDuration
          ? _value.testDuration
          : testDuration // ignore: cast_nullable_to_non_nullable
              as int,
      bandwidthMbps: null == bandwidthMbps
          ? _value.bandwidthMbps
          : bandwidthMbps // ignore: cast_nullable_to_non_nullable
              as int,
      parallelStreams: null == parallelStreams
          ? _value.parallelStreams
          : parallelStreams // ignore: cast_nullable_to_non_nullable
              as int,
      useUdp: null == useUdp
          ? _value.useUdp
          : useUdp // ignore: cast_nullable_to_non_nullable
              as bool,
      completedResult: freezed == completedResult
          ? _value.completedResult
          : completedResult // ignore: cast_nullable_to_non_nullable
              as SpeedTestResult?,
      config: freezed == config
          ? _value.config
          : config // ignore: cast_nullable_to_non_nullable
              as SpeedTestConfig?,
      isInitialized: null == isInitialized
          ? _value.isInitialized
          : isInitialized // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$SpeedTestRunStateImpl extends _SpeedTestRunState {
  const _$SpeedTestRunStateImpl(
      {this.executionStatus = SpeedTestStatus.idle,
      this.progress = 0.0,
      this.statusMessage,
      this.downloadSpeed = 0.0,
      this.uploadSpeed = 0.0,
      this.latency = 0.0,
      this.testPassed,
      this.errorMessage,
      this.localIpAddress,
      this.gatewayAddress,
      this.serverHost = '',
      this.serverPort = 5201,
      this.testDuration = 10,
      this.bandwidthMbps = 0,
      this.parallelStreams = 1,
      this.useUdp = false,
      this.completedResult,
      this.config,
      this.isInitialized = false})
      : super._();

// Execution status (idle, running, completed, error)
  @override
  @JsonKey()
  final SpeedTestStatus executionStatus;
// Progress (0-100)
  @override
  @JsonKey()
  final double progress;
// Status message (for UI display)
  @override
  final String? statusMessage;
// Result data (from result stream)
  @override
  @JsonKey()
  final double downloadSpeed;
  @override
  @JsonKey()
  final double uploadSpeed;
  @override
  @JsonKey()
  final double latency;
// Validation status: null = not run, true = passed, false = failed
  @override
  final bool? testPassed;
// Error state
  @override
  final String? errorMessage;
// Network info
  @override
  final String? localIpAddress;
  @override
  final String? gatewayAddress;
// Server configuration
  @override
  @JsonKey()
  final String serverHost;
  @override
  @JsonKey()
  final int serverPort;
// Test configuration
  @override
  @JsonKey()
  final int testDuration;
  @override
  @JsonKey()
  final int bandwidthMbps;
  @override
  @JsonKey()
  final int parallelStreams;
  @override
  @JsonKey()
  final bool useUdp;
// Full result object (for submission)
  @override
  final SpeedTestResult? completedResult;
  @override
  final SpeedTestConfig? config;
// Initialization flag
  @override
  @JsonKey()
  final bool isInitialized;

  @override
  String toString() {
    return 'SpeedTestRunState(executionStatus: $executionStatus, progress: $progress, statusMessage: $statusMessage, downloadSpeed: $downloadSpeed, uploadSpeed: $uploadSpeed, latency: $latency, testPassed: $testPassed, errorMessage: $errorMessage, localIpAddress: $localIpAddress, gatewayAddress: $gatewayAddress, serverHost: $serverHost, serverPort: $serverPort, testDuration: $testDuration, bandwidthMbps: $bandwidthMbps, parallelStreams: $parallelStreams, useUdp: $useUdp, completedResult: $completedResult, config: $config, isInitialized: $isInitialized)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SpeedTestRunStateImpl &&
            (identical(other.executionStatus, executionStatus) ||
                other.executionStatus == executionStatus) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.statusMessage, statusMessage) ||
                other.statusMessage == statusMessage) &&
            (identical(other.downloadSpeed, downloadSpeed) ||
                other.downloadSpeed == downloadSpeed) &&
            (identical(other.uploadSpeed, uploadSpeed) ||
                other.uploadSpeed == uploadSpeed) &&
            (identical(other.latency, latency) || other.latency == latency) &&
            (identical(other.testPassed, testPassed) ||
                other.testPassed == testPassed) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.localIpAddress, localIpAddress) ||
                other.localIpAddress == localIpAddress) &&
            (identical(other.gatewayAddress, gatewayAddress) ||
                other.gatewayAddress == gatewayAddress) &&
            (identical(other.serverHost, serverHost) ||
                other.serverHost == serverHost) &&
            (identical(other.serverPort, serverPort) ||
                other.serverPort == serverPort) &&
            (identical(other.testDuration, testDuration) ||
                other.testDuration == testDuration) &&
            (identical(other.bandwidthMbps, bandwidthMbps) ||
                other.bandwidthMbps == bandwidthMbps) &&
            (identical(other.parallelStreams, parallelStreams) ||
                other.parallelStreams == parallelStreams) &&
            (identical(other.useUdp, useUdp) || other.useUdp == useUdp) &&
            (identical(other.completedResult, completedResult) ||
                other.completedResult == completedResult) &&
            (identical(other.config, config) || other.config == config) &&
            (identical(other.isInitialized, isInitialized) ||
                other.isInitialized == isInitialized));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        executionStatus,
        progress,
        statusMessage,
        downloadSpeed,
        uploadSpeed,
        latency,
        testPassed,
        errorMessage,
        localIpAddress,
        gatewayAddress,
        serverHost,
        serverPort,
        testDuration,
        bandwidthMbps,
        parallelStreams,
        useUdp,
        completedResult,
        config,
        isInitialized
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SpeedTestRunStateImplCopyWith<_$SpeedTestRunStateImpl> get copyWith =>
      __$$SpeedTestRunStateImplCopyWithImpl<_$SpeedTestRunStateImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            SpeedTestStatus executionStatus,
            double progress,
            String? statusMessage,
            double downloadSpeed,
            double uploadSpeed,
            double latency,
            bool? testPassed,
            String? errorMessage,
            String? localIpAddress,
            String? gatewayAddress,
            String serverHost,
            int serverPort,
            int testDuration,
            int bandwidthMbps,
            int parallelStreams,
            bool useUdp,
            SpeedTestResult? completedResult,
            SpeedTestConfig? config,
            bool isInitialized)
        $default,
  ) {
    return $default(
        executionStatus,
        progress,
        statusMessage,
        downloadSpeed,
        uploadSpeed,
        latency,
        testPassed,
        errorMessage,
        localIpAddress,
        gatewayAddress,
        serverHost,
        serverPort,
        testDuration,
        bandwidthMbps,
        parallelStreams,
        useUdp,
        completedResult,
        config,
        isInitialized);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            SpeedTestStatus executionStatus,
            double progress,
            String? statusMessage,
            double downloadSpeed,
            double uploadSpeed,
            double latency,
            bool? testPassed,
            String? errorMessage,
            String? localIpAddress,
            String? gatewayAddress,
            String serverHost,
            int serverPort,
            int testDuration,
            int bandwidthMbps,
            int parallelStreams,
            bool useUdp,
            SpeedTestResult? completedResult,
            SpeedTestConfig? config,
            bool isInitialized)?
        $default,
  ) {
    return $default?.call(
        executionStatus,
        progress,
        statusMessage,
        downloadSpeed,
        uploadSpeed,
        latency,
        testPassed,
        errorMessage,
        localIpAddress,
        gatewayAddress,
        serverHost,
        serverPort,
        testDuration,
        bandwidthMbps,
        parallelStreams,
        useUdp,
        completedResult,
        config,
        isInitialized);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            SpeedTestStatus executionStatus,
            double progress,
            String? statusMessage,
            double downloadSpeed,
            double uploadSpeed,
            double latency,
            bool? testPassed,
            String? errorMessage,
            String? localIpAddress,
            String? gatewayAddress,
            String serverHost,
            int serverPort,
            int testDuration,
            int bandwidthMbps,
            int parallelStreams,
            bool useUdp,
            SpeedTestResult? completedResult,
            SpeedTestConfig? config,
            bool isInitialized)?
        $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(
          executionStatus,
          progress,
          statusMessage,
          downloadSpeed,
          uploadSpeed,
          latency,
          testPassed,
          errorMessage,
          localIpAddress,
          gatewayAddress,
          serverHost,
          serverPort,
          testDuration,
          bandwidthMbps,
          parallelStreams,
          useUdp,
          completedResult,
          config,
          isInitialized);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_SpeedTestRunState value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_SpeedTestRunState value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_SpeedTestRunState value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _SpeedTestRunState extends SpeedTestRunState {
  const factory _SpeedTestRunState(
      {final SpeedTestStatus executionStatus,
      final double progress,
      final String? statusMessage,
      final double downloadSpeed,
      final double uploadSpeed,
      final double latency,
      final bool? testPassed,
      final String? errorMessage,
      final String? localIpAddress,
      final String? gatewayAddress,
      final String serverHost,
      final int serverPort,
      final int testDuration,
      final int bandwidthMbps,
      final int parallelStreams,
      final bool useUdp,
      final SpeedTestResult? completedResult,
      final SpeedTestConfig? config,
      final bool isInitialized}) = _$SpeedTestRunStateImpl;
  const _SpeedTestRunState._() : super._();

  @override // Execution status (idle, running, completed, error)
  SpeedTestStatus get executionStatus;
  @override // Progress (0-100)
  double get progress;
  @override // Status message (for UI display)
  String? get statusMessage;
  @override // Result data (from result stream)
  double get downloadSpeed;
  @override
  double get uploadSpeed;
  @override
  double get latency;
  @override // Validation status: null = not run, true = passed, false = failed
  bool? get testPassed;
  @override // Error state
  String? get errorMessage;
  @override // Network info
  String? get localIpAddress;
  @override
  String? get gatewayAddress;
  @override // Server configuration
  String get serverHost;
  @override
  int get serverPort;
  @override // Test configuration
  int get testDuration;
  @override
  int get bandwidthMbps;
  @override
  int get parallelStreams;
  @override
  bool get useUdp;
  @override // Full result object (for submission)
  SpeedTestResult? get completedResult;
  @override
  SpeedTestConfig? get config;
  @override // Initialization flag
  bool get isInitialized;
  @override
  @JsonKey(ignore: true)
  _$$SpeedTestRunStateImplCopyWith<_$SpeedTestRunStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
