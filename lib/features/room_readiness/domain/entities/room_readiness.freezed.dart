// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'room_readiness.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RoomReadinessMetrics _$RoomReadinessMetricsFromJson(Map<String, dynamic> json) {
  return _RoomReadinessMetrics.fromJson(json);
}

/// @nodoc
mixin _$RoomReadinessMetrics {
  int get roomId => throw _privateConstructorUsedError;
  String get roomName => throw _privateConstructorUsedError;
  RoomStatus get status => throw _privateConstructorUsedError;
  int get totalDevices => throw _privateConstructorUsedError;
  int get onlineDevices => throw _privateConstructorUsedError;
  int get offlineDevices => throw _privateConstructorUsedError;
  List<Issue> get issues => throw _privateConstructorUsedError;
  DateTime get lastUpdated => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            int roomId,
            String roomName,
            RoomStatus status,
            int totalDevices,
            int onlineDevices,
            int offlineDevices,
            List<Issue> issues,
            DateTime lastUpdated)
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            int roomId,
            String roomName,
            RoomStatus status,
            int totalDevices,
            int onlineDevices,
            int offlineDevices,
            List<Issue> issues,
            DateTime lastUpdated)?
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            int roomId,
            String roomName,
            RoomStatus status,
            int totalDevices,
            int onlineDevices,
            int offlineDevices,
            List<Issue> issues,
            DateTime lastUpdated)?
        $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_RoomReadinessMetrics value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_RoomReadinessMetrics value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_RoomReadinessMetrics value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RoomReadinessMetricsCopyWith<RoomReadinessMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoomReadinessMetricsCopyWith<$Res> {
  factory $RoomReadinessMetricsCopyWith(RoomReadinessMetrics value,
          $Res Function(RoomReadinessMetrics) then) =
      _$RoomReadinessMetricsCopyWithImpl<$Res, RoomReadinessMetrics>;
  @useResult
  $Res call(
      {int roomId,
      String roomName,
      RoomStatus status,
      int totalDevices,
      int onlineDevices,
      int offlineDevices,
      List<Issue> issues,
      DateTime lastUpdated});
}

/// @nodoc
class _$RoomReadinessMetricsCopyWithImpl<$Res,
        $Val extends RoomReadinessMetrics>
    implements $RoomReadinessMetricsCopyWith<$Res> {
  _$RoomReadinessMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roomId = null,
    Object? roomName = null,
    Object? status = null,
    Object? totalDevices = null,
    Object? onlineDevices = null,
    Object? offlineDevices = null,
    Object? issues = null,
    Object? lastUpdated = null,
  }) {
    return _then(_value.copyWith(
      roomId: null == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as int,
      roomName: null == roomName
          ? _value.roomName
          : roomName // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as RoomStatus,
      totalDevices: null == totalDevices
          ? _value.totalDevices
          : totalDevices // ignore: cast_nullable_to_non_nullable
              as int,
      onlineDevices: null == onlineDevices
          ? _value.onlineDevices
          : onlineDevices // ignore: cast_nullable_to_non_nullable
              as int,
      offlineDevices: null == offlineDevices
          ? _value.offlineDevices
          : offlineDevices // ignore: cast_nullable_to_non_nullable
              as int,
      issues: null == issues
          ? _value.issues
          : issues // ignore: cast_nullable_to_non_nullable
              as List<Issue>,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RoomReadinessMetricsImplCopyWith<$Res>
    implements $RoomReadinessMetricsCopyWith<$Res> {
  factory _$$RoomReadinessMetricsImplCopyWith(_$RoomReadinessMetricsImpl value,
          $Res Function(_$RoomReadinessMetricsImpl) then) =
      __$$RoomReadinessMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int roomId,
      String roomName,
      RoomStatus status,
      int totalDevices,
      int onlineDevices,
      int offlineDevices,
      List<Issue> issues,
      DateTime lastUpdated});
}

/// @nodoc
class __$$RoomReadinessMetricsImplCopyWithImpl<$Res>
    extends _$RoomReadinessMetricsCopyWithImpl<$Res, _$RoomReadinessMetricsImpl>
    implements _$$RoomReadinessMetricsImplCopyWith<$Res> {
  __$$RoomReadinessMetricsImplCopyWithImpl(_$RoomReadinessMetricsImpl _value,
      $Res Function(_$RoomReadinessMetricsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roomId = null,
    Object? roomName = null,
    Object? status = null,
    Object? totalDevices = null,
    Object? onlineDevices = null,
    Object? offlineDevices = null,
    Object? issues = null,
    Object? lastUpdated = null,
  }) {
    return _then(_$RoomReadinessMetricsImpl(
      roomId: null == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as int,
      roomName: null == roomName
          ? _value.roomName
          : roomName // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as RoomStatus,
      totalDevices: null == totalDevices
          ? _value.totalDevices
          : totalDevices // ignore: cast_nullable_to_non_nullable
              as int,
      onlineDevices: null == onlineDevices
          ? _value.onlineDevices
          : onlineDevices // ignore: cast_nullable_to_non_nullable
              as int,
      offlineDevices: null == offlineDevices
          ? _value.offlineDevices
          : offlineDevices // ignore: cast_nullable_to_non_nullable
              as int,
      issues: null == issues
          ? _value._issues
          : issues // ignore: cast_nullable_to_non_nullable
              as List<Issue>,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RoomReadinessMetricsImpl extends _RoomReadinessMetrics {
  const _$RoomReadinessMetricsImpl(
      {required this.roomId,
      required this.roomName,
      required this.status,
      required this.totalDevices,
      required this.onlineDevices,
      required this.offlineDevices,
      required final List<Issue> issues,
      required this.lastUpdated})
      : _issues = issues,
        super._();

  factory _$RoomReadinessMetricsImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoomReadinessMetricsImplFromJson(json);

  @override
  final int roomId;
  @override
  final String roomName;
  @override
  final RoomStatus status;
  @override
  final int totalDevices;
  @override
  final int onlineDevices;
  @override
  final int offlineDevices;
  final List<Issue> _issues;
  @override
  List<Issue> get issues {
    if (_issues is EqualUnmodifiableListView) return _issues;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_issues);
  }

  @override
  final DateTime lastUpdated;

  @override
  String toString() {
    return 'RoomReadinessMetrics(roomId: $roomId, roomName: $roomName, status: $status, totalDevices: $totalDevices, onlineDevices: $onlineDevices, offlineDevices: $offlineDevices, issues: $issues, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoomReadinessMetricsImpl &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.roomName, roomName) ||
                other.roomName == roomName) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.totalDevices, totalDevices) ||
                other.totalDevices == totalDevices) &&
            (identical(other.onlineDevices, onlineDevices) ||
                other.onlineDevices == onlineDevices) &&
            (identical(other.offlineDevices, offlineDevices) ||
                other.offlineDevices == offlineDevices) &&
            const DeepCollectionEquality().equals(other._issues, _issues) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      roomId,
      roomName,
      status,
      totalDevices,
      onlineDevices,
      offlineDevices,
      const DeepCollectionEquality().hash(_issues),
      lastUpdated);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RoomReadinessMetricsImplCopyWith<_$RoomReadinessMetricsImpl>
      get copyWith =>
          __$$RoomReadinessMetricsImplCopyWithImpl<_$RoomReadinessMetricsImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            int roomId,
            String roomName,
            RoomStatus status,
            int totalDevices,
            int onlineDevices,
            int offlineDevices,
            List<Issue> issues,
            DateTime lastUpdated)
        $default,
  ) {
    return $default(roomId, roomName, status, totalDevices, onlineDevices,
        offlineDevices, issues, lastUpdated);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            int roomId,
            String roomName,
            RoomStatus status,
            int totalDevices,
            int onlineDevices,
            int offlineDevices,
            List<Issue> issues,
            DateTime lastUpdated)?
        $default,
  ) {
    return $default?.call(roomId, roomName, status, totalDevices, onlineDevices,
        offlineDevices, issues, lastUpdated);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            int roomId,
            String roomName,
            RoomStatus status,
            int totalDevices,
            int onlineDevices,
            int offlineDevices,
            List<Issue> issues,
            DateTime lastUpdated)?
        $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(roomId, roomName, status, totalDevices, onlineDevices,
          offlineDevices, issues, lastUpdated);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_RoomReadinessMetrics value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_RoomReadinessMetrics value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_RoomReadinessMetrics value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$RoomReadinessMetricsImplToJson(
      this,
    );
  }
}

abstract class _RoomReadinessMetrics extends RoomReadinessMetrics {
  const factory _RoomReadinessMetrics(
      {required final int roomId,
      required final String roomName,
      required final RoomStatus status,
      required final int totalDevices,
      required final int onlineDevices,
      required final int offlineDevices,
      required final List<Issue> issues,
      required final DateTime lastUpdated}) = _$RoomReadinessMetricsImpl;
  const _RoomReadinessMetrics._() : super._();

  factory _RoomReadinessMetrics.fromJson(Map<String, dynamic> json) =
      _$RoomReadinessMetricsImpl.fromJson;

  @override
  int get roomId;
  @override
  String get roomName;
  @override
  RoomStatus get status;
  @override
  int get totalDevices;
  @override
  int get onlineDevices;
  @override
  int get offlineDevices;
  @override
  List<Issue> get issues;
  @override
  DateTime get lastUpdated;
  @override
  @JsonKey(ignore: true)
  _$$RoomReadinessMetricsImplCopyWith<_$RoomReadinessMetricsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

RoomReadinessUpdate _$RoomReadinessUpdateFromJson(Map<String, dynamic> json) {
  return _RoomReadinessUpdate.fromJson(json);
}

/// @nodoc
mixin _$RoomReadinessUpdate {
  int get roomId => throw _privateConstructorUsedError;
  RoomReadinessMetrics get metrics => throw _privateConstructorUsedError;
  RoomReadinessUpdateType get type => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// All room metrics for fullRefresh updates.
  /// Only populated when type is [RoomReadinessUpdateType.fullRefresh].
  List<RoomReadinessMetrics>? get allMetrics =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            int roomId,
            RoomReadinessMetrics metrics,
            RoomReadinessUpdateType type,
            DateTime timestamp,
            List<RoomReadinessMetrics>? allMetrics)
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            int roomId,
            RoomReadinessMetrics metrics,
            RoomReadinessUpdateType type,
            DateTime timestamp,
            List<RoomReadinessMetrics>? allMetrics)?
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            int roomId,
            RoomReadinessMetrics metrics,
            RoomReadinessUpdateType type,
            DateTime timestamp,
            List<RoomReadinessMetrics>? allMetrics)?
        $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_RoomReadinessUpdate value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_RoomReadinessUpdate value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_RoomReadinessUpdate value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RoomReadinessUpdateCopyWith<RoomReadinessUpdate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoomReadinessUpdateCopyWith<$Res> {
  factory $RoomReadinessUpdateCopyWith(
          RoomReadinessUpdate value, $Res Function(RoomReadinessUpdate) then) =
      _$RoomReadinessUpdateCopyWithImpl<$Res, RoomReadinessUpdate>;
  @useResult
  $Res call(
      {int roomId,
      RoomReadinessMetrics metrics,
      RoomReadinessUpdateType type,
      DateTime timestamp,
      List<RoomReadinessMetrics>? allMetrics});

  $RoomReadinessMetricsCopyWith<$Res> get metrics;
}

/// @nodoc
class _$RoomReadinessUpdateCopyWithImpl<$Res, $Val extends RoomReadinessUpdate>
    implements $RoomReadinessUpdateCopyWith<$Res> {
  _$RoomReadinessUpdateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roomId = null,
    Object? metrics = null,
    Object? type = null,
    Object? timestamp = null,
    Object? allMetrics = freezed,
  }) {
    return _then(_value.copyWith(
      roomId: null == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as int,
      metrics: null == metrics
          ? _value.metrics
          : metrics // ignore: cast_nullable_to_non_nullable
              as RoomReadinessMetrics,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as RoomReadinessUpdateType,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      allMetrics: freezed == allMetrics
          ? _value.allMetrics
          : allMetrics // ignore: cast_nullable_to_non_nullable
              as List<RoomReadinessMetrics>?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $RoomReadinessMetricsCopyWith<$Res> get metrics {
    return $RoomReadinessMetricsCopyWith<$Res>(_value.metrics, (value) {
      return _then(_value.copyWith(metrics: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RoomReadinessUpdateImplCopyWith<$Res>
    implements $RoomReadinessUpdateCopyWith<$Res> {
  factory _$$RoomReadinessUpdateImplCopyWith(_$RoomReadinessUpdateImpl value,
          $Res Function(_$RoomReadinessUpdateImpl) then) =
      __$$RoomReadinessUpdateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int roomId,
      RoomReadinessMetrics metrics,
      RoomReadinessUpdateType type,
      DateTime timestamp,
      List<RoomReadinessMetrics>? allMetrics});

  @override
  $RoomReadinessMetricsCopyWith<$Res> get metrics;
}

/// @nodoc
class __$$RoomReadinessUpdateImplCopyWithImpl<$Res>
    extends _$RoomReadinessUpdateCopyWithImpl<$Res, _$RoomReadinessUpdateImpl>
    implements _$$RoomReadinessUpdateImplCopyWith<$Res> {
  __$$RoomReadinessUpdateImplCopyWithImpl(_$RoomReadinessUpdateImpl _value,
      $Res Function(_$RoomReadinessUpdateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roomId = null,
    Object? metrics = null,
    Object? type = null,
    Object? timestamp = null,
    Object? allMetrics = freezed,
  }) {
    return _then(_$RoomReadinessUpdateImpl(
      roomId: null == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as int,
      metrics: null == metrics
          ? _value.metrics
          : metrics // ignore: cast_nullable_to_non_nullable
              as RoomReadinessMetrics,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as RoomReadinessUpdateType,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      allMetrics: freezed == allMetrics
          ? _value._allMetrics
          : allMetrics // ignore: cast_nullable_to_non_nullable
              as List<RoomReadinessMetrics>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RoomReadinessUpdateImpl extends _RoomReadinessUpdate {
  const _$RoomReadinessUpdateImpl(
      {required this.roomId,
      required this.metrics,
      required this.type,
      required this.timestamp,
      final List<RoomReadinessMetrics>? allMetrics})
      : _allMetrics = allMetrics,
        super._();

  factory _$RoomReadinessUpdateImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoomReadinessUpdateImplFromJson(json);

  @override
  final int roomId;
  @override
  final RoomReadinessMetrics metrics;
  @override
  final RoomReadinessUpdateType type;
  @override
  final DateTime timestamp;

  /// All room metrics for fullRefresh updates.
  /// Only populated when type is [RoomReadinessUpdateType.fullRefresh].
  final List<RoomReadinessMetrics>? _allMetrics;

  /// All room metrics for fullRefresh updates.
  /// Only populated when type is [RoomReadinessUpdateType.fullRefresh].
  @override
  List<RoomReadinessMetrics>? get allMetrics {
    final value = _allMetrics;
    if (value == null) return null;
    if (_allMetrics is EqualUnmodifiableListView) return _allMetrics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'RoomReadinessUpdate(roomId: $roomId, metrics: $metrics, type: $type, timestamp: $timestamp, allMetrics: $allMetrics)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoomReadinessUpdateImpl &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.metrics, metrics) || other.metrics == metrics) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            const DeepCollectionEquality()
                .equals(other._allMetrics, _allMetrics));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, roomId, metrics, type, timestamp,
      const DeepCollectionEquality().hash(_allMetrics));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RoomReadinessUpdateImplCopyWith<_$RoomReadinessUpdateImpl> get copyWith =>
      __$$RoomReadinessUpdateImplCopyWithImpl<_$RoomReadinessUpdateImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            int roomId,
            RoomReadinessMetrics metrics,
            RoomReadinessUpdateType type,
            DateTime timestamp,
            List<RoomReadinessMetrics>? allMetrics)
        $default,
  ) {
    return $default(roomId, metrics, type, timestamp, allMetrics);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            int roomId,
            RoomReadinessMetrics metrics,
            RoomReadinessUpdateType type,
            DateTime timestamp,
            List<RoomReadinessMetrics>? allMetrics)?
        $default,
  ) {
    return $default?.call(roomId, metrics, type, timestamp, allMetrics);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            int roomId,
            RoomReadinessMetrics metrics,
            RoomReadinessUpdateType type,
            DateTime timestamp,
            List<RoomReadinessMetrics>? allMetrics)?
        $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(roomId, metrics, type, timestamp, allMetrics);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_RoomReadinessUpdate value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_RoomReadinessUpdate value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_RoomReadinessUpdate value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$RoomReadinessUpdateImplToJson(
      this,
    );
  }
}

abstract class _RoomReadinessUpdate extends RoomReadinessUpdate {
  const factory _RoomReadinessUpdate(
          {required final int roomId,
          required final RoomReadinessMetrics metrics,
          required final RoomReadinessUpdateType type,
          required final DateTime timestamp,
          final List<RoomReadinessMetrics>? allMetrics}) =
      _$RoomReadinessUpdateImpl;
  const _RoomReadinessUpdate._() : super._();

  factory _RoomReadinessUpdate.fromJson(Map<String, dynamic> json) =
      _$RoomReadinessUpdateImpl.fromJson;

  @override
  int get roomId;
  @override
  RoomReadinessMetrics get metrics;
  @override
  RoomReadinessUpdateType get type;
  @override
  DateTime get timestamp;
  @override

  /// All room metrics for fullRefresh updates.
  /// Only populated when type is [RoomReadinessUpdateType.fullRefresh].
  List<RoomReadinessMetrics>? get allMetrics;
  @override
  @JsonKey(ignore: true)
  _$$RoomReadinessUpdateImplCopyWith<_$RoomReadinessUpdateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RoomReadinessSummary _$RoomReadinessSummaryFromJson(Map<String, dynamic> json) {
  return _RoomReadinessSummary.fromJson(json);
}

/// @nodoc
mixin _$RoomReadinessSummary {
  int get totalRooms => throw _privateConstructorUsedError;
  int get readyRooms => throw _privateConstructorUsedError;
  int get partialRooms => throw _privateConstructorUsedError;
  int get downRooms => throw _privateConstructorUsedError;
  int get emptyRooms => throw _privateConstructorUsedError;
  double get overallReadinessPercentage => throw _privateConstructorUsedError;
  DateTime get lastUpdated => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            int totalRooms,
            int readyRooms,
            int partialRooms,
            int downRooms,
            int emptyRooms,
            double overallReadinessPercentage,
            DateTime lastUpdated)
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            int totalRooms,
            int readyRooms,
            int partialRooms,
            int downRooms,
            int emptyRooms,
            double overallReadinessPercentage,
            DateTime lastUpdated)?
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            int totalRooms,
            int readyRooms,
            int partialRooms,
            int downRooms,
            int emptyRooms,
            double overallReadinessPercentage,
            DateTime lastUpdated)?
        $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_RoomReadinessSummary value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_RoomReadinessSummary value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_RoomReadinessSummary value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RoomReadinessSummaryCopyWith<RoomReadinessSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoomReadinessSummaryCopyWith<$Res> {
  factory $RoomReadinessSummaryCopyWith(RoomReadinessSummary value,
          $Res Function(RoomReadinessSummary) then) =
      _$RoomReadinessSummaryCopyWithImpl<$Res, RoomReadinessSummary>;
  @useResult
  $Res call(
      {int totalRooms,
      int readyRooms,
      int partialRooms,
      int downRooms,
      int emptyRooms,
      double overallReadinessPercentage,
      DateTime lastUpdated});
}

/// @nodoc
class _$RoomReadinessSummaryCopyWithImpl<$Res,
        $Val extends RoomReadinessSummary>
    implements $RoomReadinessSummaryCopyWith<$Res> {
  _$RoomReadinessSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalRooms = null,
    Object? readyRooms = null,
    Object? partialRooms = null,
    Object? downRooms = null,
    Object? emptyRooms = null,
    Object? overallReadinessPercentage = null,
    Object? lastUpdated = null,
  }) {
    return _then(_value.copyWith(
      totalRooms: null == totalRooms
          ? _value.totalRooms
          : totalRooms // ignore: cast_nullable_to_non_nullable
              as int,
      readyRooms: null == readyRooms
          ? _value.readyRooms
          : readyRooms // ignore: cast_nullable_to_non_nullable
              as int,
      partialRooms: null == partialRooms
          ? _value.partialRooms
          : partialRooms // ignore: cast_nullable_to_non_nullable
              as int,
      downRooms: null == downRooms
          ? _value.downRooms
          : downRooms // ignore: cast_nullable_to_non_nullable
              as int,
      emptyRooms: null == emptyRooms
          ? _value.emptyRooms
          : emptyRooms // ignore: cast_nullable_to_non_nullable
              as int,
      overallReadinessPercentage: null == overallReadinessPercentage
          ? _value.overallReadinessPercentage
          : overallReadinessPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RoomReadinessSummaryImplCopyWith<$Res>
    implements $RoomReadinessSummaryCopyWith<$Res> {
  factory _$$RoomReadinessSummaryImplCopyWith(_$RoomReadinessSummaryImpl value,
          $Res Function(_$RoomReadinessSummaryImpl) then) =
      __$$RoomReadinessSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalRooms,
      int readyRooms,
      int partialRooms,
      int downRooms,
      int emptyRooms,
      double overallReadinessPercentage,
      DateTime lastUpdated});
}

/// @nodoc
class __$$RoomReadinessSummaryImplCopyWithImpl<$Res>
    extends _$RoomReadinessSummaryCopyWithImpl<$Res, _$RoomReadinessSummaryImpl>
    implements _$$RoomReadinessSummaryImplCopyWith<$Res> {
  __$$RoomReadinessSummaryImplCopyWithImpl(_$RoomReadinessSummaryImpl _value,
      $Res Function(_$RoomReadinessSummaryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalRooms = null,
    Object? readyRooms = null,
    Object? partialRooms = null,
    Object? downRooms = null,
    Object? emptyRooms = null,
    Object? overallReadinessPercentage = null,
    Object? lastUpdated = null,
  }) {
    return _then(_$RoomReadinessSummaryImpl(
      totalRooms: null == totalRooms
          ? _value.totalRooms
          : totalRooms // ignore: cast_nullable_to_non_nullable
              as int,
      readyRooms: null == readyRooms
          ? _value.readyRooms
          : readyRooms // ignore: cast_nullable_to_non_nullable
              as int,
      partialRooms: null == partialRooms
          ? _value.partialRooms
          : partialRooms // ignore: cast_nullable_to_non_nullable
              as int,
      downRooms: null == downRooms
          ? _value.downRooms
          : downRooms // ignore: cast_nullable_to_non_nullable
              as int,
      emptyRooms: null == emptyRooms
          ? _value.emptyRooms
          : emptyRooms // ignore: cast_nullable_to_non_nullable
              as int,
      overallReadinessPercentage: null == overallReadinessPercentage
          ? _value.overallReadinessPercentage
          : overallReadinessPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RoomReadinessSummaryImpl extends _RoomReadinessSummary {
  const _$RoomReadinessSummaryImpl(
      {required this.totalRooms,
      required this.readyRooms,
      required this.partialRooms,
      required this.downRooms,
      required this.emptyRooms,
      required this.overallReadinessPercentage,
      required this.lastUpdated})
      : super._();

  factory _$RoomReadinessSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoomReadinessSummaryImplFromJson(json);

  @override
  final int totalRooms;
  @override
  final int readyRooms;
  @override
  final int partialRooms;
  @override
  final int downRooms;
  @override
  final int emptyRooms;
  @override
  final double overallReadinessPercentage;
  @override
  final DateTime lastUpdated;

  @override
  String toString() {
    return 'RoomReadinessSummary(totalRooms: $totalRooms, readyRooms: $readyRooms, partialRooms: $partialRooms, downRooms: $downRooms, emptyRooms: $emptyRooms, overallReadinessPercentage: $overallReadinessPercentage, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoomReadinessSummaryImpl &&
            (identical(other.totalRooms, totalRooms) ||
                other.totalRooms == totalRooms) &&
            (identical(other.readyRooms, readyRooms) ||
                other.readyRooms == readyRooms) &&
            (identical(other.partialRooms, partialRooms) ||
                other.partialRooms == partialRooms) &&
            (identical(other.downRooms, downRooms) ||
                other.downRooms == downRooms) &&
            (identical(other.emptyRooms, emptyRooms) ||
                other.emptyRooms == emptyRooms) &&
            (identical(other.overallReadinessPercentage,
                    overallReadinessPercentage) ||
                other.overallReadinessPercentage ==
                    overallReadinessPercentage) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalRooms,
      readyRooms,
      partialRooms,
      downRooms,
      emptyRooms,
      overallReadinessPercentage,
      lastUpdated);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RoomReadinessSummaryImplCopyWith<_$RoomReadinessSummaryImpl>
      get copyWith =>
          __$$RoomReadinessSummaryImplCopyWithImpl<_$RoomReadinessSummaryImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            int totalRooms,
            int readyRooms,
            int partialRooms,
            int downRooms,
            int emptyRooms,
            double overallReadinessPercentage,
            DateTime lastUpdated)
        $default,
  ) {
    return $default(totalRooms, readyRooms, partialRooms, downRooms, emptyRooms,
        overallReadinessPercentage, lastUpdated);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            int totalRooms,
            int readyRooms,
            int partialRooms,
            int downRooms,
            int emptyRooms,
            double overallReadinessPercentage,
            DateTime lastUpdated)?
        $default,
  ) {
    return $default?.call(totalRooms, readyRooms, partialRooms, downRooms,
        emptyRooms, overallReadinessPercentage, lastUpdated);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            int totalRooms,
            int readyRooms,
            int partialRooms,
            int downRooms,
            int emptyRooms,
            double overallReadinessPercentage,
            DateTime lastUpdated)?
        $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(totalRooms, readyRooms, partialRooms, downRooms,
          emptyRooms, overallReadinessPercentage, lastUpdated);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_RoomReadinessSummary value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_RoomReadinessSummary value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_RoomReadinessSummary value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$RoomReadinessSummaryImplToJson(
      this,
    );
  }
}

abstract class _RoomReadinessSummary extends RoomReadinessSummary {
  const factory _RoomReadinessSummary(
      {required final int totalRooms,
      required final int readyRooms,
      required final int partialRooms,
      required final int downRooms,
      required final int emptyRooms,
      required final double overallReadinessPercentage,
      required final DateTime lastUpdated}) = _$RoomReadinessSummaryImpl;
  const _RoomReadinessSummary._() : super._();

  factory _RoomReadinessSummary.fromJson(Map<String, dynamic> json) =
      _$RoomReadinessSummaryImpl.fromJson;

  @override
  int get totalRooms;
  @override
  int get readyRooms;
  @override
  int get partialRooms;
  @override
  int get downRooms;
  @override
  int get emptyRooms;
  @override
  double get overallReadinessPercentage;
  @override
  DateTime get lastUpdated;
  @override
  @JsonKey(ignore: true)
  _$$RoomReadinessSummaryImplCopyWith<_$RoomReadinessSummaryImpl>
      get copyWith => throw _privateConstructorUsedError;
}
