// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_status_payload.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

OnboardingStatusPayload _$OnboardingStatusPayloadFromJson(
    Map<String, dynamic> json) {
  return _OnboardingStatusPayload.fromJson(json);
}

/// @nodoc
mixin _$OnboardingStatusPayload {
  /// Current onboarding stage (1-5 for ONT, 1-6 for AP, 0 = not started)
  int? get stage => throw _privateConstructorUsedError;

  /// Maximum number of stages (5 for ONT, 6 for AP)
  @JsonKey(name: 'max_stages')
  int? get maxStages => throw _privateConstructorUsedError;

  /// Human-readable status text
  String? get status => throw _privateConstructorUsedError;

  /// Display text for current stage
  @JsonKey(name: 'stage_display')
  String? get stageDisplay => throw _privateConstructorUsedError;

  /// Suggested next action
  @JsonKey(name: 'next_action')
  String? get nextAction => throw _privateConstructorUsedError;

  /// Error message if any
  String? get error => throw _privateConstructorUsedError;

  /// Last update timestamp
  @JsonKey(name: 'last_update')
  DateTime? get lastUpdate => throw _privateConstructorUsedError;

  /// Last seen timestamp (AP only)
  @JsonKey(name: 'last_seen_at')
  DateTime? get lastSeenAt => throw _privateConstructorUsedError;

  /// Seconds since last update (from backend)
  @JsonKey(name: 'last_update_age_secs')
  int? get lastUpdateAgeSecs => throw _privateConstructorUsedError;

  /// Explicit completion flag
  @JsonKey(name: 'onboarding_complete')
  bool? get onboardingComplete => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            int? stage,
            @JsonKey(name: 'max_stages') int? maxStages,
            String? status,
            @JsonKey(name: 'stage_display') String? stageDisplay,
            @JsonKey(name: 'next_action') String? nextAction,
            String? error,
            @JsonKey(name: 'last_update') DateTime? lastUpdate,
            @JsonKey(name: 'last_seen_at') DateTime? lastSeenAt,
            @JsonKey(name: 'last_update_age_secs') int? lastUpdateAgeSecs,
            @JsonKey(name: 'onboarding_complete') bool? onboardingComplete)
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            int? stage,
            @JsonKey(name: 'max_stages') int? maxStages,
            String? status,
            @JsonKey(name: 'stage_display') String? stageDisplay,
            @JsonKey(name: 'next_action') String? nextAction,
            String? error,
            @JsonKey(name: 'last_update') DateTime? lastUpdate,
            @JsonKey(name: 'last_seen_at') DateTime? lastSeenAt,
            @JsonKey(name: 'last_update_age_secs') int? lastUpdateAgeSecs,
            @JsonKey(name: 'onboarding_complete') bool? onboardingComplete)?
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            int? stage,
            @JsonKey(name: 'max_stages') int? maxStages,
            String? status,
            @JsonKey(name: 'stage_display') String? stageDisplay,
            @JsonKey(name: 'next_action') String? nextAction,
            String? error,
            @JsonKey(name: 'last_update') DateTime? lastUpdate,
            @JsonKey(name: 'last_seen_at') DateTime? lastSeenAt,
            @JsonKey(name: 'last_update_age_secs') int? lastUpdateAgeSecs,
            @JsonKey(name: 'onboarding_complete') bool? onboardingComplete)?
        $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_OnboardingStatusPayload value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_OnboardingStatusPayload value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_OnboardingStatusPayload value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $OnboardingStatusPayloadCopyWith<OnboardingStatusPayload> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnboardingStatusPayloadCopyWith<$Res> {
  factory $OnboardingStatusPayloadCopyWith(OnboardingStatusPayload value,
          $Res Function(OnboardingStatusPayload) then) =
      _$OnboardingStatusPayloadCopyWithImpl<$Res, OnboardingStatusPayload>;
  @useResult
  $Res call(
      {int? stage,
      @JsonKey(name: 'max_stages') int? maxStages,
      String? status,
      @JsonKey(name: 'stage_display') String? stageDisplay,
      @JsonKey(name: 'next_action') String? nextAction,
      String? error,
      @JsonKey(name: 'last_update') DateTime? lastUpdate,
      @JsonKey(name: 'last_seen_at') DateTime? lastSeenAt,
      @JsonKey(name: 'last_update_age_secs') int? lastUpdateAgeSecs,
      @JsonKey(name: 'onboarding_complete') bool? onboardingComplete});
}

/// @nodoc
class _$OnboardingStatusPayloadCopyWithImpl<$Res,
        $Val extends OnboardingStatusPayload>
    implements $OnboardingStatusPayloadCopyWith<$Res> {
  _$OnboardingStatusPayloadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stage = freezed,
    Object? maxStages = freezed,
    Object? status = freezed,
    Object? stageDisplay = freezed,
    Object? nextAction = freezed,
    Object? error = freezed,
    Object? lastUpdate = freezed,
    Object? lastSeenAt = freezed,
    Object? lastUpdateAgeSecs = freezed,
    Object? onboardingComplete = freezed,
  }) {
    return _then(_value.copyWith(
      stage: freezed == stage
          ? _value.stage
          : stage // ignore: cast_nullable_to_non_nullable
              as int?,
      maxStages: freezed == maxStages
          ? _value.maxStages
          : maxStages // ignore: cast_nullable_to_non_nullable
              as int?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      stageDisplay: freezed == stageDisplay
          ? _value.stageDisplay
          : stageDisplay // ignore: cast_nullable_to_non_nullable
              as String?,
      nextAction: freezed == nextAction
          ? _value.nextAction
          : nextAction // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      lastUpdate: freezed == lastUpdate
          ? _value.lastUpdate
          : lastUpdate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastSeenAt: freezed == lastSeenAt
          ? _value.lastSeenAt
          : lastSeenAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastUpdateAgeSecs: freezed == lastUpdateAgeSecs
          ? _value.lastUpdateAgeSecs
          : lastUpdateAgeSecs // ignore: cast_nullable_to_non_nullable
              as int?,
      onboardingComplete: freezed == onboardingComplete
          ? _value.onboardingComplete
          : onboardingComplete // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OnboardingStatusPayloadImplCopyWith<$Res>
    implements $OnboardingStatusPayloadCopyWith<$Res> {
  factory _$$OnboardingStatusPayloadImplCopyWith(
          _$OnboardingStatusPayloadImpl value,
          $Res Function(_$OnboardingStatusPayloadImpl) then) =
      __$$OnboardingStatusPayloadImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? stage,
      @JsonKey(name: 'max_stages') int? maxStages,
      String? status,
      @JsonKey(name: 'stage_display') String? stageDisplay,
      @JsonKey(name: 'next_action') String? nextAction,
      String? error,
      @JsonKey(name: 'last_update') DateTime? lastUpdate,
      @JsonKey(name: 'last_seen_at') DateTime? lastSeenAt,
      @JsonKey(name: 'last_update_age_secs') int? lastUpdateAgeSecs,
      @JsonKey(name: 'onboarding_complete') bool? onboardingComplete});
}

/// @nodoc
class __$$OnboardingStatusPayloadImplCopyWithImpl<$Res>
    extends _$OnboardingStatusPayloadCopyWithImpl<$Res,
        _$OnboardingStatusPayloadImpl>
    implements _$$OnboardingStatusPayloadImplCopyWith<$Res> {
  __$$OnboardingStatusPayloadImplCopyWithImpl(
      _$OnboardingStatusPayloadImpl _value,
      $Res Function(_$OnboardingStatusPayloadImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stage = freezed,
    Object? maxStages = freezed,
    Object? status = freezed,
    Object? stageDisplay = freezed,
    Object? nextAction = freezed,
    Object? error = freezed,
    Object? lastUpdate = freezed,
    Object? lastSeenAt = freezed,
    Object? lastUpdateAgeSecs = freezed,
    Object? onboardingComplete = freezed,
  }) {
    return _then(_$OnboardingStatusPayloadImpl(
      stage: freezed == stage
          ? _value.stage
          : stage // ignore: cast_nullable_to_non_nullable
              as int?,
      maxStages: freezed == maxStages
          ? _value.maxStages
          : maxStages // ignore: cast_nullable_to_non_nullable
              as int?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      stageDisplay: freezed == stageDisplay
          ? _value.stageDisplay
          : stageDisplay // ignore: cast_nullable_to_non_nullable
              as String?,
      nextAction: freezed == nextAction
          ? _value.nextAction
          : nextAction // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      lastUpdate: freezed == lastUpdate
          ? _value.lastUpdate
          : lastUpdate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastSeenAt: freezed == lastSeenAt
          ? _value.lastSeenAt
          : lastSeenAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastUpdateAgeSecs: freezed == lastUpdateAgeSecs
          ? _value.lastUpdateAgeSecs
          : lastUpdateAgeSecs // ignore: cast_nullable_to_non_nullable
              as int?,
      onboardingComplete: freezed == onboardingComplete
          ? _value.onboardingComplete
          : onboardingComplete // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OnboardingStatusPayloadImpl extends _OnboardingStatusPayload {
  const _$OnboardingStatusPayloadImpl(
      {this.stage,
      @JsonKey(name: 'max_stages') this.maxStages,
      this.status,
      @JsonKey(name: 'stage_display') this.stageDisplay,
      @JsonKey(name: 'next_action') this.nextAction,
      this.error,
      @JsonKey(name: 'last_update') this.lastUpdate,
      @JsonKey(name: 'last_seen_at') this.lastSeenAt,
      @JsonKey(name: 'last_update_age_secs') this.lastUpdateAgeSecs,
      @JsonKey(name: 'onboarding_complete') this.onboardingComplete})
      : super._();

  factory _$OnboardingStatusPayloadImpl.fromJson(Map<String, dynamic> json) =>
      _$$OnboardingStatusPayloadImplFromJson(json);

  /// Current onboarding stage (1-5 for ONT, 1-6 for AP, 0 = not started)
  @override
  final int? stage;

  /// Maximum number of stages (5 for ONT, 6 for AP)
  @override
  @JsonKey(name: 'max_stages')
  final int? maxStages;

  /// Human-readable status text
  @override
  final String? status;

  /// Display text for current stage
  @override
  @JsonKey(name: 'stage_display')
  final String? stageDisplay;

  /// Suggested next action
  @override
  @JsonKey(name: 'next_action')
  final String? nextAction;

  /// Error message if any
  @override
  final String? error;

  /// Last update timestamp
  @override
  @JsonKey(name: 'last_update')
  final DateTime? lastUpdate;

  /// Last seen timestamp (AP only)
  @override
  @JsonKey(name: 'last_seen_at')
  final DateTime? lastSeenAt;

  /// Seconds since last update (from backend)
  @override
  @JsonKey(name: 'last_update_age_secs')
  final int? lastUpdateAgeSecs;

  /// Explicit completion flag
  @override
  @JsonKey(name: 'onboarding_complete')
  final bool? onboardingComplete;

  @override
  String toString() {
    return 'OnboardingStatusPayload(stage: $stage, maxStages: $maxStages, status: $status, stageDisplay: $stageDisplay, nextAction: $nextAction, error: $error, lastUpdate: $lastUpdate, lastSeenAt: $lastSeenAt, lastUpdateAgeSecs: $lastUpdateAgeSecs, onboardingComplete: $onboardingComplete)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OnboardingStatusPayloadImpl &&
            (identical(other.stage, stage) || other.stage == stage) &&
            (identical(other.maxStages, maxStages) ||
                other.maxStages == maxStages) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.stageDisplay, stageDisplay) ||
                other.stageDisplay == stageDisplay) &&
            (identical(other.nextAction, nextAction) ||
                other.nextAction == nextAction) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.lastUpdate, lastUpdate) ||
                other.lastUpdate == lastUpdate) &&
            (identical(other.lastSeenAt, lastSeenAt) ||
                other.lastSeenAt == lastSeenAt) &&
            (identical(other.lastUpdateAgeSecs, lastUpdateAgeSecs) ||
                other.lastUpdateAgeSecs == lastUpdateAgeSecs) &&
            (identical(other.onboardingComplete, onboardingComplete) ||
                other.onboardingComplete == onboardingComplete));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      stage,
      maxStages,
      status,
      stageDisplay,
      nextAction,
      error,
      lastUpdate,
      lastSeenAt,
      lastUpdateAgeSecs,
      onboardingComplete);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OnboardingStatusPayloadImplCopyWith<_$OnboardingStatusPayloadImpl>
      get copyWith => __$$OnboardingStatusPayloadImplCopyWithImpl<
          _$OnboardingStatusPayloadImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            int? stage,
            @JsonKey(name: 'max_stages') int? maxStages,
            String? status,
            @JsonKey(name: 'stage_display') String? stageDisplay,
            @JsonKey(name: 'next_action') String? nextAction,
            String? error,
            @JsonKey(name: 'last_update') DateTime? lastUpdate,
            @JsonKey(name: 'last_seen_at') DateTime? lastSeenAt,
            @JsonKey(name: 'last_update_age_secs') int? lastUpdateAgeSecs,
            @JsonKey(name: 'onboarding_complete') bool? onboardingComplete)
        $default,
  ) {
    return $default(stage, maxStages, status, stageDisplay, nextAction, error,
        lastUpdate, lastSeenAt, lastUpdateAgeSecs, onboardingComplete);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            int? stage,
            @JsonKey(name: 'max_stages') int? maxStages,
            String? status,
            @JsonKey(name: 'stage_display') String? stageDisplay,
            @JsonKey(name: 'next_action') String? nextAction,
            String? error,
            @JsonKey(name: 'last_update') DateTime? lastUpdate,
            @JsonKey(name: 'last_seen_at') DateTime? lastSeenAt,
            @JsonKey(name: 'last_update_age_secs') int? lastUpdateAgeSecs,
            @JsonKey(name: 'onboarding_complete') bool? onboardingComplete)?
        $default,
  ) {
    return $default?.call(stage, maxStages, status, stageDisplay, nextAction,
        error, lastUpdate, lastSeenAt, lastUpdateAgeSecs, onboardingComplete);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            int? stage,
            @JsonKey(name: 'max_stages') int? maxStages,
            String? status,
            @JsonKey(name: 'stage_display') String? stageDisplay,
            @JsonKey(name: 'next_action') String? nextAction,
            String? error,
            @JsonKey(name: 'last_update') DateTime? lastUpdate,
            @JsonKey(name: 'last_seen_at') DateTime? lastSeenAt,
            @JsonKey(name: 'last_update_age_secs') int? lastUpdateAgeSecs,
            @JsonKey(name: 'onboarding_complete') bool? onboardingComplete)?
        $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(stage, maxStages, status, stageDisplay, nextAction, error,
          lastUpdate, lastSeenAt, lastUpdateAgeSecs, onboardingComplete);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_OnboardingStatusPayload value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_OnboardingStatusPayload value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_OnboardingStatusPayload value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$OnboardingStatusPayloadImplToJson(
      this,
    );
  }
}

abstract class _OnboardingStatusPayload extends OnboardingStatusPayload {
  const factory _OnboardingStatusPayload(
      {final int? stage,
      @JsonKey(name: 'max_stages') final int? maxStages,
      final String? status,
      @JsonKey(name: 'stage_display') final String? stageDisplay,
      @JsonKey(name: 'next_action') final String? nextAction,
      final String? error,
      @JsonKey(name: 'last_update') final DateTime? lastUpdate,
      @JsonKey(name: 'last_seen_at') final DateTime? lastSeenAt,
      @JsonKey(name: 'last_update_age_secs') final int? lastUpdateAgeSecs,
      @JsonKey(name: 'onboarding_complete')
      final bool? onboardingComplete}) = _$OnboardingStatusPayloadImpl;
  const _OnboardingStatusPayload._() : super._();

  factory _OnboardingStatusPayload.fromJson(Map<String, dynamic> json) =
      _$OnboardingStatusPayloadImpl.fromJson;

  @override

  /// Current onboarding stage (1-5 for ONT, 1-6 for AP, 0 = not started)
  int? get stage;
  @override

  /// Maximum number of stages (5 for ONT, 6 for AP)
  @JsonKey(name: 'max_stages')
  int? get maxStages;
  @override

  /// Human-readable status text
  String? get status;
  @override

  /// Display text for current stage
  @JsonKey(name: 'stage_display')
  String? get stageDisplay;
  @override

  /// Suggested next action
  @JsonKey(name: 'next_action')
  String? get nextAction;
  @override

  /// Error message if any
  String? get error;
  @override

  /// Last update timestamp
  @JsonKey(name: 'last_update')
  DateTime? get lastUpdate;
  @override

  /// Last seen timestamp (AP only)
  @JsonKey(name: 'last_seen_at')
  DateTime? get lastSeenAt;
  @override

  /// Seconds since last update (from backend)
  @JsonKey(name: 'last_update_age_secs')
  int? get lastUpdateAgeSecs;
  @override

  /// Explicit completion flag
  @JsonKey(name: 'onboarding_complete')
  bool? get onboardingComplete;
  @override
  @JsonKey(ignore: true)
  _$$OnboardingStatusPayloadImplCopyWith<_$OnboardingStatusPayloadImpl>
      get copyWith => throw _privateConstructorUsedError;
}
