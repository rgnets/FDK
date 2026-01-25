// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stage_tracking_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StageTrackingData _$StageTrackingDataFromJson(Map<String, dynamic> json) {
  return _StageTrackingData.fromJson(json);
}

/// @nodoc
mixin _$StageTrackingData {
  /// Current stage number
  int get stage => throw _privateConstructorUsedError;

  /// Maximum stages for this device type
  int get maxStages => throw _privateConstructorUsedError;

  /// When the device entered this stage
  @JsonKey(name: 'entered_at')
  DateTime get enteredAt => throw _privateConstructorUsedError;

  /// Last time this record was updated
  @JsonKey(name: 'last_updated')
  DateTime get lastUpdated => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            int stage,
            int maxStages,
            @JsonKey(name: 'entered_at') DateTime enteredAt,
            @JsonKey(name: 'last_updated') DateTime lastUpdated)
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            int stage,
            int maxStages,
            @JsonKey(name: 'entered_at') DateTime enteredAt,
            @JsonKey(name: 'last_updated') DateTime lastUpdated)?
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            int stage,
            int maxStages,
            @JsonKey(name: 'entered_at') DateTime enteredAt,
            @JsonKey(name: 'last_updated') DateTime lastUpdated)?
        $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_StageTrackingData value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_StageTrackingData value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_StageTrackingData value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $StageTrackingDataCopyWith<StageTrackingData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StageTrackingDataCopyWith<$Res> {
  factory $StageTrackingDataCopyWith(
          StageTrackingData value, $Res Function(StageTrackingData) then) =
      _$StageTrackingDataCopyWithImpl<$Res, StageTrackingData>;
  @useResult
  $Res call(
      {int stage,
      int maxStages,
      @JsonKey(name: 'entered_at') DateTime enteredAt,
      @JsonKey(name: 'last_updated') DateTime lastUpdated});
}

/// @nodoc
class _$StageTrackingDataCopyWithImpl<$Res, $Val extends StageTrackingData>
    implements $StageTrackingDataCopyWith<$Res> {
  _$StageTrackingDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stage = null,
    Object? maxStages = null,
    Object? enteredAt = null,
    Object? lastUpdated = null,
  }) {
    return _then(_value.copyWith(
      stage: null == stage
          ? _value.stage
          : stage // ignore: cast_nullable_to_non_nullable
              as int,
      maxStages: null == maxStages
          ? _value.maxStages
          : maxStages // ignore: cast_nullable_to_non_nullable
              as int,
      enteredAt: null == enteredAt
          ? _value.enteredAt
          : enteredAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StageTrackingDataImplCopyWith<$Res>
    implements $StageTrackingDataCopyWith<$Res> {
  factory _$$StageTrackingDataImplCopyWith(_$StageTrackingDataImpl value,
          $Res Function(_$StageTrackingDataImpl) then) =
      __$$StageTrackingDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int stage,
      int maxStages,
      @JsonKey(name: 'entered_at') DateTime enteredAt,
      @JsonKey(name: 'last_updated') DateTime lastUpdated});
}

/// @nodoc
class __$$StageTrackingDataImplCopyWithImpl<$Res>
    extends _$StageTrackingDataCopyWithImpl<$Res, _$StageTrackingDataImpl>
    implements _$$StageTrackingDataImplCopyWith<$Res> {
  __$$StageTrackingDataImplCopyWithImpl(_$StageTrackingDataImpl _value,
      $Res Function(_$StageTrackingDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stage = null,
    Object? maxStages = null,
    Object? enteredAt = null,
    Object? lastUpdated = null,
  }) {
    return _then(_$StageTrackingDataImpl(
      stage: null == stage
          ? _value.stage
          : stage // ignore: cast_nullable_to_non_nullable
              as int,
      maxStages: null == maxStages
          ? _value.maxStages
          : maxStages // ignore: cast_nullable_to_non_nullable
              as int,
      enteredAt: null == enteredAt
          ? _value.enteredAt
          : enteredAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StageTrackingDataImpl extends _StageTrackingData {
  const _$StageTrackingDataImpl(
      {required this.stage,
      required this.maxStages,
      @JsonKey(name: 'entered_at') required this.enteredAt,
      @JsonKey(name: 'last_updated') required this.lastUpdated})
      : super._();

  factory _$StageTrackingDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$StageTrackingDataImplFromJson(json);

  /// Current stage number
  @override
  final int stage;

  /// Maximum stages for this device type
  @override
  final int maxStages;

  /// When the device entered this stage
  @override
  @JsonKey(name: 'entered_at')
  final DateTime enteredAt;

  /// Last time this record was updated
  @override
  @JsonKey(name: 'last_updated')
  final DateTime lastUpdated;

  @override
  String toString() {
    return 'StageTrackingData(stage: $stage, maxStages: $maxStages, enteredAt: $enteredAt, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StageTrackingDataImpl &&
            (identical(other.stage, stage) || other.stage == stage) &&
            (identical(other.maxStages, maxStages) ||
                other.maxStages == maxStages) &&
            (identical(other.enteredAt, enteredAt) ||
                other.enteredAt == enteredAt) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, stage, maxStages, enteredAt, lastUpdated);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StageTrackingDataImplCopyWith<_$StageTrackingDataImpl> get copyWith =>
      __$$StageTrackingDataImplCopyWithImpl<_$StageTrackingDataImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            int stage,
            int maxStages,
            @JsonKey(name: 'entered_at') DateTime enteredAt,
            @JsonKey(name: 'last_updated') DateTime lastUpdated)
        $default,
  ) {
    return $default(stage, maxStages, enteredAt, lastUpdated);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            int stage,
            int maxStages,
            @JsonKey(name: 'entered_at') DateTime enteredAt,
            @JsonKey(name: 'last_updated') DateTime lastUpdated)?
        $default,
  ) {
    return $default?.call(stage, maxStages, enteredAt, lastUpdated);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            int stage,
            int maxStages,
            @JsonKey(name: 'entered_at') DateTime enteredAt,
            @JsonKey(name: 'last_updated') DateTime lastUpdated)?
        $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(stage, maxStages, enteredAt, lastUpdated);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_StageTrackingData value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_StageTrackingData value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_StageTrackingData value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$StageTrackingDataImplToJson(
      this,
    );
  }
}

abstract class _StageTrackingData extends StageTrackingData {
  const factory _StageTrackingData(
          {required final int stage,
          required final int maxStages,
          @JsonKey(name: 'entered_at') required final DateTime enteredAt,
          @JsonKey(name: 'last_updated') required final DateTime lastUpdated}) =
      _$StageTrackingDataImpl;
  const _StageTrackingData._() : super._();

  factory _StageTrackingData.fromJson(Map<String, dynamic> json) =
      _$StageTrackingDataImpl.fromJson;

  @override

  /// Current stage number
  int get stage;
  @override

  /// Maximum stages for this device type
  int get maxStages;
  @override

  /// When the device entered this stage
  @JsonKey(name: 'entered_at')
  DateTime get enteredAt;
  @override

  /// Last time this record was updated
  @JsonKey(name: 'last_updated')
  DateTime get lastUpdated;
  @override
  @JsonKey(ignore: true)
  _$$StageTrackingDataImplCopyWith<_$StageTrackingDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
