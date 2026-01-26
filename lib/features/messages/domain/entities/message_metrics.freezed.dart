// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_metrics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MessageMetrics {
  /// Total messages shown
  int get totalShown => throw _privateConstructorUsedError;

  /// Total messages deduplicated
  int get totalDeduplicated => throw _privateConstructorUsedError;

  /// Total messages dropped
  int get totalDropped => throw _privateConstructorUsedError;

  /// Total errors
  int get totalErrors => throw _privateConstructorUsedError;

  /// Current queue size
  int get queueSize => throw _privateConstructorUsedError;

  /// Maximum queue size
  int get maxQueueSize => throw _privateConstructorUsedError;

  /// Messages by type count
  Map<String, int> get byType => throw _privateConstructorUsedError;

  /// Messages by category count
  Map<String, int> get byCategory => throw _privateConstructorUsedError;

  /// Messages by source count
  Map<String, int> get bySource => throw _privateConstructorUsedError;

  /// Session start time
  DateTime? get sessionStart => throw _privateConstructorUsedError;

  /// Last message time
  DateTime? get lastMessageTime => throw _privateConstructorUsedError;

  /// Health score (0-100)
  int get healthScore => throw _privateConstructorUsedError;

  /// Issues identified
  List<String> get issues => throw _privateConstructorUsedError;

  /// Recommendations
  List<String> get recommendations => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            int totalShown,
            int totalDeduplicated,
            int totalDropped,
            int totalErrors,
            int queueSize,
            int maxQueueSize,
            Map<String, int> byType,
            Map<String, int> byCategory,
            Map<String, int> bySource,
            DateTime? sessionStart,
            DateTime? lastMessageTime,
            int healthScore,
            List<String> issues,
            List<String> recommendations)
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            int totalShown,
            int totalDeduplicated,
            int totalDropped,
            int totalErrors,
            int queueSize,
            int maxQueueSize,
            Map<String, int> byType,
            Map<String, int> byCategory,
            Map<String, int> bySource,
            DateTime? sessionStart,
            DateTime? lastMessageTime,
            int healthScore,
            List<String> issues,
            List<String> recommendations)?
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            int totalShown,
            int totalDeduplicated,
            int totalDropped,
            int totalErrors,
            int queueSize,
            int maxQueueSize,
            Map<String, int> byType,
            Map<String, int> byCategory,
            Map<String, int> bySource,
            DateTime? sessionStart,
            DateTime? lastMessageTime,
            int healthScore,
            List<String> issues,
            List<String> recommendations)?
        $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MessageMetrics value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MessageMetrics value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MessageMetrics value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MessageMetricsCopyWith<MessageMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageMetricsCopyWith<$Res> {
  factory $MessageMetricsCopyWith(
          MessageMetrics value, $Res Function(MessageMetrics) then) =
      _$MessageMetricsCopyWithImpl<$Res, MessageMetrics>;
  @useResult
  $Res call(
      {int totalShown,
      int totalDeduplicated,
      int totalDropped,
      int totalErrors,
      int queueSize,
      int maxQueueSize,
      Map<String, int> byType,
      Map<String, int> byCategory,
      Map<String, int> bySource,
      DateTime? sessionStart,
      DateTime? lastMessageTime,
      int healthScore,
      List<String> issues,
      List<String> recommendations});
}

/// @nodoc
class _$MessageMetricsCopyWithImpl<$Res, $Val extends MessageMetrics>
    implements $MessageMetricsCopyWith<$Res> {
  _$MessageMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalShown = null,
    Object? totalDeduplicated = null,
    Object? totalDropped = null,
    Object? totalErrors = null,
    Object? queueSize = null,
    Object? maxQueueSize = null,
    Object? byType = null,
    Object? byCategory = null,
    Object? bySource = null,
    Object? sessionStart = freezed,
    Object? lastMessageTime = freezed,
    Object? healthScore = null,
    Object? issues = null,
    Object? recommendations = null,
  }) {
    return _then(_value.copyWith(
      totalShown: null == totalShown
          ? _value.totalShown
          : totalShown // ignore: cast_nullable_to_non_nullable
              as int,
      totalDeduplicated: null == totalDeduplicated
          ? _value.totalDeduplicated
          : totalDeduplicated // ignore: cast_nullable_to_non_nullable
              as int,
      totalDropped: null == totalDropped
          ? _value.totalDropped
          : totalDropped // ignore: cast_nullable_to_non_nullable
              as int,
      totalErrors: null == totalErrors
          ? _value.totalErrors
          : totalErrors // ignore: cast_nullable_to_non_nullable
              as int,
      queueSize: null == queueSize
          ? _value.queueSize
          : queueSize // ignore: cast_nullable_to_non_nullable
              as int,
      maxQueueSize: null == maxQueueSize
          ? _value.maxQueueSize
          : maxQueueSize // ignore: cast_nullable_to_non_nullable
              as int,
      byType: null == byType
          ? _value.byType
          : byType // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      byCategory: null == byCategory
          ? _value.byCategory
          : byCategory // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      bySource: null == bySource
          ? _value.bySource
          : bySource // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      sessionStart: freezed == sessionStart
          ? _value.sessionStart
          : sessionStart // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastMessageTime: freezed == lastMessageTime
          ? _value.lastMessageTime
          : lastMessageTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      healthScore: null == healthScore
          ? _value.healthScore
          : healthScore // ignore: cast_nullable_to_non_nullable
              as int,
      issues: null == issues
          ? _value.issues
          : issues // ignore: cast_nullable_to_non_nullable
              as List<String>,
      recommendations: null == recommendations
          ? _value.recommendations
          : recommendations // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MessageMetricsImplCopyWith<$Res>
    implements $MessageMetricsCopyWith<$Res> {
  factory _$$MessageMetricsImplCopyWith(_$MessageMetricsImpl value,
          $Res Function(_$MessageMetricsImpl) then) =
      __$$MessageMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalShown,
      int totalDeduplicated,
      int totalDropped,
      int totalErrors,
      int queueSize,
      int maxQueueSize,
      Map<String, int> byType,
      Map<String, int> byCategory,
      Map<String, int> bySource,
      DateTime? sessionStart,
      DateTime? lastMessageTime,
      int healthScore,
      List<String> issues,
      List<String> recommendations});
}

/// @nodoc
class __$$MessageMetricsImplCopyWithImpl<$Res>
    extends _$MessageMetricsCopyWithImpl<$Res, _$MessageMetricsImpl>
    implements _$$MessageMetricsImplCopyWith<$Res> {
  __$$MessageMetricsImplCopyWithImpl(
      _$MessageMetricsImpl _value, $Res Function(_$MessageMetricsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalShown = null,
    Object? totalDeduplicated = null,
    Object? totalDropped = null,
    Object? totalErrors = null,
    Object? queueSize = null,
    Object? maxQueueSize = null,
    Object? byType = null,
    Object? byCategory = null,
    Object? bySource = null,
    Object? sessionStart = freezed,
    Object? lastMessageTime = freezed,
    Object? healthScore = null,
    Object? issues = null,
    Object? recommendations = null,
  }) {
    return _then(_$MessageMetricsImpl(
      totalShown: null == totalShown
          ? _value.totalShown
          : totalShown // ignore: cast_nullable_to_non_nullable
              as int,
      totalDeduplicated: null == totalDeduplicated
          ? _value.totalDeduplicated
          : totalDeduplicated // ignore: cast_nullable_to_non_nullable
              as int,
      totalDropped: null == totalDropped
          ? _value.totalDropped
          : totalDropped // ignore: cast_nullable_to_non_nullable
              as int,
      totalErrors: null == totalErrors
          ? _value.totalErrors
          : totalErrors // ignore: cast_nullable_to_non_nullable
              as int,
      queueSize: null == queueSize
          ? _value.queueSize
          : queueSize // ignore: cast_nullable_to_non_nullable
              as int,
      maxQueueSize: null == maxQueueSize
          ? _value.maxQueueSize
          : maxQueueSize // ignore: cast_nullable_to_non_nullable
              as int,
      byType: null == byType
          ? _value._byType
          : byType // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      byCategory: null == byCategory
          ? _value._byCategory
          : byCategory // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      bySource: null == bySource
          ? _value._bySource
          : bySource // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      sessionStart: freezed == sessionStart
          ? _value.sessionStart
          : sessionStart // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastMessageTime: freezed == lastMessageTime
          ? _value.lastMessageTime
          : lastMessageTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      healthScore: null == healthScore
          ? _value.healthScore
          : healthScore // ignore: cast_nullable_to_non_nullable
              as int,
      issues: null == issues
          ? _value._issues
          : issues // ignore: cast_nullable_to_non_nullable
              as List<String>,
      recommendations: null == recommendations
          ? _value._recommendations
          : recommendations // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc

class _$MessageMetricsImpl extends _MessageMetrics {
  const _$MessageMetricsImpl(
      {this.totalShown = 0,
      this.totalDeduplicated = 0,
      this.totalDropped = 0,
      this.totalErrors = 0,
      this.queueSize = 0,
      this.maxQueueSize = 20,
      final Map<String, int> byType = const {},
      final Map<String, int> byCategory = const {},
      final Map<String, int> bySource = const {},
      this.sessionStart,
      this.lastMessageTime,
      this.healthScore = 100,
      final List<String> issues = const [],
      final List<String> recommendations = const []})
      : _byType = byType,
        _byCategory = byCategory,
        _bySource = bySource,
        _issues = issues,
        _recommendations = recommendations,
        super._();

  /// Total messages shown
  @override
  @JsonKey()
  final int totalShown;

  /// Total messages deduplicated
  @override
  @JsonKey()
  final int totalDeduplicated;

  /// Total messages dropped
  @override
  @JsonKey()
  final int totalDropped;

  /// Total errors
  @override
  @JsonKey()
  final int totalErrors;

  /// Current queue size
  @override
  @JsonKey()
  final int queueSize;

  /// Maximum queue size
  @override
  @JsonKey()
  final int maxQueueSize;

  /// Messages by type count
  final Map<String, int> _byType;

  /// Messages by type count
  @override
  @JsonKey()
  Map<String, int> get byType {
    if (_byType is EqualUnmodifiableMapView) return _byType;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_byType);
  }

  /// Messages by category count
  final Map<String, int> _byCategory;

  /// Messages by category count
  @override
  @JsonKey()
  Map<String, int> get byCategory {
    if (_byCategory is EqualUnmodifiableMapView) return _byCategory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_byCategory);
  }

  /// Messages by source count
  final Map<String, int> _bySource;

  /// Messages by source count
  @override
  @JsonKey()
  Map<String, int> get bySource {
    if (_bySource is EqualUnmodifiableMapView) return _bySource;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_bySource);
  }

  /// Session start time
  @override
  final DateTime? sessionStart;

  /// Last message time
  @override
  final DateTime? lastMessageTime;

  /// Health score (0-100)
  @override
  @JsonKey()
  final int healthScore;

  /// Issues identified
  final List<String> _issues;

  /// Issues identified
  @override
  @JsonKey()
  List<String> get issues {
    if (_issues is EqualUnmodifiableListView) return _issues;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_issues);
  }

  /// Recommendations
  final List<String> _recommendations;

  /// Recommendations
  @override
  @JsonKey()
  List<String> get recommendations {
    if (_recommendations is EqualUnmodifiableListView) return _recommendations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recommendations);
  }

  @override
  String toString() {
    return 'MessageMetrics(totalShown: $totalShown, totalDeduplicated: $totalDeduplicated, totalDropped: $totalDropped, totalErrors: $totalErrors, queueSize: $queueSize, maxQueueSize: $maxQueueSize, byType: $byType, byCategory: $byCategory, bySource: $bySource, sessionStart: $sessionStart, lastMessageTime: $lastMessageTime, healthScore: $healthScore, issues: $issues, recommendations: $recommendations)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageMetricsImpl &&
            (identical(other.totalShown, totalShown) ||
                other.totalShown == totalShown) &&
            (identical(other.totalDeduplicated, totalDeduplicated) ||
                other.totalDeduplicated == totalDeduplicated) &&
            (identical(other.totalDropped, totalDropped) ||
                other.totalDropped == totalDropped) &&
            (identical(other.totalErrors, totalErrors) ||
                other.totalErrors == totalErrors) &&
            (identical(other.queueSize, queueSize) ||
                other.queueSize == queueSize) &&
            (identical(other.maxQueueSize, maxQueueSize) ||
                other.maxQueueSize == maxQueueSize) &&
            const DeepCollectionEquality().equals(other._byType, _byType) &&
            const DeepCollectionEquality()
                .equals(other._byCategory, _byCategory) &&
            const DeepCollectionEquality().equals(other._bySource, _bySource) &&
            (identical(other.sessionStart, sessionStart) ||
                other.sessionStart == sessionStart) &&
            (identical(other.lastMessageTime, lastMessageTime) ||
                other.lastMessageTime == lastMessageTime) &&
            (identical(other.healthScore, healthScore) ||
                other.healthScore == healthScore) &&
            const DeepCollectionEquality().equals(other._issues, _issues) &&
            const DeepCollectionEquality()
                .equals(other._recommendations, _recommendations));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalShown,
      totalDeduplicated,
      totalDropped,
      totalErrors,
      queueSize,
      maxQueueSize,
      const DeepCollectionEquality().hash(_byType),
      const DeepCollectionEquality().hash(_byCategory),
      const DeepCollectionEquality().hash(_bySource),
      sessionStart,
      lastMessageTime,
      healthScore,
      const DeepCollectionEquality().hash(_issues),
      const DeepCollectionEquality().hash(_recommendations));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageMetricsImplCopyWith<_$MessageMetricsImpl> get copyWith =>
      __$$MessageMetricsImplCopyWithImpl<_$MessageMetricsImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            int totalShown,
            int totalDeduplicated,
            int totalDropped,
            int totalErrors,
            int queueSize,
            int maxQueueSize,
            Map<String, int> byType,
            Map<String, int> byCategory,
            Map<String, int> bySource,
            DateTime? sessionStart,
            DateTime? lastMessageTime,
            int healthScore,
            List<String> issues,
            List<String> recommendations)
        $default,
  ) {
    return $default(
        totalShown,
        totalDeduplicated,
        totalDropped,
        totalErrors,
        queueSize,
        maxQueueSize,
        byType,
        byCategory,
        bySource,
        sessionStart,
        lastMessageTime,
        healthScore,
        issues,
        recommendations);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            int totalShown,
            int totalDeduplicated,
            int totalDropped,
            int totalErrors,
            int queueSize,
            int maxQueueSize,
            Map<String, int> byType,
            Map<String, int> byCategory,
            Map<String, int> bySource,
            DateTime? sessionStart,
            DateTime? lastMessageTime,
            int healthScore,
            List<String> issues,
            List<String> recommendations)?
        $default,
  ) {
    return $default?.call(
        totalShown,
        totalDeduplicated,
        totalDropped,
        totalErrors,
        queueSize,
        maxQueueSize,
        byType,
        byCategory,
        bySource,
        sessionStart,
        lastMessageTime,
        healthScore,
        issues,
        recommendations);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            int totalShown,
            int totalDeduplicated,
            int totalDropped,
            int totalErrors,
            int queueSize,
            int maxQueueSize,
            Map<String, int> byType,
            Map<String, int> byCategory,
            Map<String, int> bySource,
            DateTime? sessionStart,
            DateTime? lastMessageTime,
            int healthScore,
            List<String> issues,
            List<String> recommendations)?
        $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(
          totalShown,
          totalDeduplicated,
          totalDropped,
          totalErrors,
          queueSize,
          maxQueueSize,
          byType,
          byCategory,
          bySource,
          sessionStart,
          lastMessageTime,
          healthScore,
          issues,
          recommendations);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MessageMetrics value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MessageMetrics value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MessageMetrics value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _MessageMetrics extends MessageMetrics {
  const factory _MessageMetrics(
      {final int totalShown,
      final int totalDeduplicated,
      final int totalDropped,
      final int totalErrors,
      final int queueSize,
      final int maxQueueSize,
      final Map<String, int> byType,
      final Map<String, int> byCategory,
      final Map<String, int> bySource,
      final DateTime? sessionStart,
      final DateTime? lastMessageTime,
      final int healthScore,
      final List<String> issues,
      final List<String> recommendations}) = _$MessageMetricsImpl;
  const _MessageMetrics._() : super._();

  @override

  /// Total messages shown
  int get totalShown;
  @override

  /// Total messages deduplicated
  int get totalDeduplicated;
  @override

  /// Total messages dropped
  int get totalDropped;
  @override

  /// Total errors
  int get totalErrors;
  @override

  /// Current queue size
  int get queueSize;
  @override

  /// Maximum queue size
  int get maxQueueSize;
  @override

  /// Messages by type count
  Map<String, int> get byType;
  @override

  /// Messages by category count
  Map<String, int> get byCategory;
  @override

  /// Messages by source count
  Map<String, int> get bySource;
  @override

  /// Session start time
  DateTime? get sessionStart;
  @override

  /// Last message time
  DateTime? get lastMessageTime;
  @override

  /// Health score (0-100)
  int get healthScore;
  @override

  /// Issues identified
  List<String> get issues;
  @override

  /// Recommendations
  List<String> get recommendations;
  @override
  @JsonKey(ignore: true)
  _$$MessageMetricsImplCopyWith<_$MessageMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MessageDiagnosticEvent {
  MessageEvent get event => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String? get messageKey => throw _privateConstructorUsedError;
  String? get details => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(MessageEvent event, DateTime timestamp, String? messageKey,
            String? details)
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(MessageEvent event, DateTime timestamp,
            String? messageKey, String? details)?
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(MessageEvent event, DateTime timestamp, String? messageKey,
            String? details)?
        $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MessageDiagnosticEvent value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MessageDiagnosticEvent value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MessageDiagnosticEvent value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MessageDiagnosticEventCopyWith<MessageDiagnosticEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageDiagnosticEventCopyWith<$Res> {
  factory $MessageDiagnosticEventCopyWith(MessageDiagnosticEvent value,
          $Res Function(MessageDiagnosticEvent) then) =
      _$MessageDiagnosticEventCopyWithImpl<$Res, MessageDiagnosticEvent>;
  @useResult
  $Res call(
      {MessageEvent event,
      DateTime timestamp,
      String? messageKey,
      String? details});
}

/// @nodoc
class _$MessageDiagnosticEventCopyWithImpl<$Res,
        $Val extends MessageDiagnosticEvent>
    implements $MessageDiagnosticEventCopyWith<$Res> {
  _$MessageDiagnosticEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? event = null,
    Object? timestamp = null,
    Object? messageKey = freezed,
    Object? details = freezed,
  }) {
    return _then(_value.copyWith(
      event: null == event
          ? _value.event
          : event // ignore: cast_nullable_to_non_nullable
              as MessageEvent,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      messageKey: freezed == messageKey
          ? _value.messageKey
          : messageKey // ignore: cast_nullable_to_non_nullable
              as String?,
      details: freezed == details
          ? _value.details
          : details // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MessageDiagnosticEventImplCopyWith<$Res>
    implements $MessageDiagnosticEventCopyWith<$Res> {
  factory _$$MessageDiagnosticEventImplCopyWith(
          _$MessageDiagnosticEventImpl value,
          $Res Function(_$MessageDiagnosticEventImpl) then) =
      __$$MessageDiagnosticEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {MessageEvent event,
      DateTime timestamp,
      String? messageKey,
      String? details});
}

/// @nodoc
class __$$MessageDiagnosticEventImplCopyWithImpl<$Res>
    extends _$MessageDiagnosticEventCopyWithImpl<$Res,
        _$MessageDiagnosticEventImpl>
    implements _$$MessageDiagnosticEventImplCopyWith<$Res> {
  __$$MessageDiagnosticEventImplCopyWithImpl(
      _$MessageDiagnosticEventImpl _value,
      $Res Function(_$MessageDiagnosticEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? event = null,
    Object? timestamp = null,
    Object? messageKey = freezed,
    Object? details = freezed,
  }) {
    return _then(_$MessageDiagnosticEventImpl(
      event: null == event
          ? _value.event
          : event // ignore: cast_nullable_to_non_nullable
              as MessageEvent,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      messageKey: freezed == messageKey
          ? _value.messageKey
          : messageKey // ignore: cast_nullable_to_non_nullable
              as String?,
      details: freezed == details
          ? _value.details
          : details // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$MessageDiagnosticEventImpl extends _MessageDiagnosticEvent {
  const _$MessageDiagnosticEventImpl(
      {required this.event,
      required this.timestamp,
      this.messageKey,
      this.details})
      : super._();

  @override
  final MessageEvent event;
  @override
  final DateTime timestamp;
  @override
  final String? messageKey;
  @override
  final String? details;

  @override
  String toString() {
    return 'MessageDiagnosticEvent(event: $event, timestamp: $timestamp, messageKey: $messageKey, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageDiagnosticEventImpl &&
            (identical(other.event, event) || other.event == event) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.messageKey, messageKey) ||
                other.messageKey == messageKey) &&
            (identical(other.details, details) || other.details == details));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, event, timestamp, messageKey, details);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageDiagnosticEventImplCopyWith<_$MessageDiagnosticEventImpl>
      get copyWith => __$$MessageDiagnosticEventImplCopyWithImpl<
          _$MessageDiagnosticEventImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(MessageEvent event, DateTime timestamp, String? messageKey,
            String? details)
        $default,
  ) {
    return $default(event, timestamp, messageKey, details);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(MessageEvent event, DateTime timestamp,
            String? messageKey, String? details)?
        $default,
  ) {
    return $default?.call(event, timestamp, messageKey, details);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(MessageEvent event, DateTime timestamp, String? messageKey,
            String? details)?
        $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(event, timestamp, messageKey, details);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MessageDiagnosticEvent value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MessageDiagnosticEvent value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MessageDiagnosticEvent value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _MessageDiagnosticEvent extends MessageDiagnosticEvent {
  const factory _MessageDiagnosticEvent(
      {required final MessageEvent event,
      required final DateTime timestamp,
      final String? messageKey,
      final String? details}) = _$MessageDiagnosticEventImpl;
  const _MessageDiagnosticEvent._() : super._();

  @override
  MessageEvent get event;
  @override
  DateTime get timestamp;
  @override
  String? get messageKey;
  @override
  String? get details;
  @override
  @JsonKey(ignore: true)
  _$$MessageDiagnosticEventImplCopyWith<_$MessageDiagnosticEventImpl>
      get copyWith => throw _privateConstructorUsedError;
}
