// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$OnboardingState {
  /// Device ID this state belongs to
  String get deviceId => throw _privateConstructorUsedError;

  /// Device type ('AP' or 'ONT')
  String get deviceType => throw _privateConstructorUsedError;

  /// Current onboarding stage (1-based, defaults to 1)
  int get currentStage => throw _privateConstructorUsedError;

  /// Maximum stages for this device type
  int get maxStages => throw _privateConstructorUsedError;

  /// Human-readable status text from backend
  String? get statusText => throw _privateConstructorUsedError;

  /// Display text for current stage from backend
  String? get stageDisplay => throw _privateConstructorUsedError;

  /// Suggested next action from backend
  String? get nextAction => throw _privateConstructorUsedError;

  /// Error message if any
  String? get errorText => throw _privateConstructorUsedError;

  /// When this stage was entered (from local tracking)
  DateTime? get stageEnteredAt => throw _privateConstructorUsedError;

  /// Last update timestamp from backend
  DateTime? get lastUpdate => throw _privateConstructorUsedError;

  /// Seconds since last update (from backend)
  int? get lastUpdateAgeSecs => throw _privateConstructorUsedError;

  /// Whether onboarding is complete
  bool get isComplete => throw _privateConstructorUsedError;

  /// Whether the current stage is overdue
  bool get isOverdue => throw _privateConstructorUsedError;

  /// Typical duration for current stage in minutes
  int? get typicalDurationMinutes => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String deviceId,
            String deviceType,
            int currentStage,
            int maxStages,
            String? statusText,
            String? stageDisplay,
            String? nextAction,
            String? errorText,
            DateTime? stageEnteredAt,
            DateTime? lastUpdate,
            int? lastUpdateAgeSecs,
            bool isComplete,
            bool isOverdue,
            int? typicalDurationMinutes)
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String deviceId,
            String deviceType,
            int currentStage,
            int maxStages,
            String? statusText,
            String? stageDisplay,
            String? nextAction,
            String? errorText,
            DateTime? stageEnteredAt,
            DateTime? lastUpdate,
            int? lastUpdateAgeSecs,
            bool isComplete,
            bool isOverdue,
            int? typicalDurationMinutes)?
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String deviceId,
            String deviceType,
            int currentStage,
            int maxStages,
            String? statusText,
            String? stageDisplay,
            String? nextAction,
            String? errorText,
            DateTime? stageEnteredAt,
            DateTime? lastUpdate,
            int? lastUpdateAgeSecs,
            bool isComplete,
            bool isOverdue,
            int? typicalDurationMinutes)?
        $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_OnboardingState value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_OnboardingState value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_OnboardingState value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $OnboardingStateCopyWith<OnboardingState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnboardingStateCopyWith<$Res> {
  factory $OnboardingStateCopyWith(
          OnboardingState value, $Res Function(OnboardingState) then) =
      _$OnboardingStateCopyWithImpl<$Res, OnboardingState>;
  @useResult
  $Res call(
      {String deviceId,
      String deviceType,
      int currentStage,
      int maxStages,
      String? statusText,
      String? stageDisplay,
      String? nextAction,
      String? errorText,
      DateTime? stageEnteredAt,
      DateTime? lastUpdate,
      int? lastUpdateAgeSecs,
      bool isComplete,
      bool isOverdue,
      int? typicalDurationMinutes});
}

/// @nodoc
class _$OnboardingStateCopyWithImpl<$Res, $Val extends OnboardingState>
    implements $OnboardingStateCopyWith<$Res> {
  _$OnboardingStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceId = null,
    Object? deviceType = null,
    Object? currentStage = null,
    Object? maxStages = null,
    Object? statusText = freezed,
    Object? stageDisplay = freezed,
    Object? nextAction = freezed,
    Object? errorText = freezed,
    Object? stageEnteredAt = freezed,
    Object? lastUpdate = freezed,
    Object? lastUpdateAgeSecs = freezed,
    Object? isComplete = null,
    Object? isOverdue = null,
    Object? typicalDurationMinutes = freezed,
  }) {
    return _then(_value.copyWith(
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      deviceType: null == deviceType
          ? _value.deviceType
          : deviceType // ignore: cast_nullable_to_non_nullable
              as String,
      currentStage: null == currentStage
          ? _value.currentStage
          : currentStage // ignore: cast_nullable_to_non_nullable
              as int,
      maxStages: null == maxStages
          ? _value.maxStages
          : maxStages // ignore: cast_nullable_to_non_nullable
              as int,
      statusText: freezed == statusText
          ? _value.statusText
          : statusText // ignore: cast_nullable_to_non_nullable
              as String?,
      stageDisplay: freezed == stageDisplay
          ? _value.stageDisplay
          : stageDisplay // ignore: cast_nullable_to_non_nullable
              as String?,
      nextAction: freezed == nextAction
          ? _value.nextAction
          : nextAction // ignore: cast_nullable_to_non_nullable
              as String?,
      errorText: freezed == errorText
          ? _value.errorText
          : errorText // ignore: cast_nullable_to_non_nullable
              as String?,
      stageEnteredAt: freezed == stageEnteredAt
          ? _value.stageEnteredAt
          : stageEnteredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastUpdate: freezed == lastUpdate
          ? _value.lastUpdate
          : lastUpdate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastUpdateAgeSecs: freezed == lastUpdateAgeSecs
          ? _value.lastUpdateAgeSecs
          : lastUpdateAgeSecs // ignore: cast_nullable_to_non_nullable
              as int?,
      isComplete: null == isComplete
          ? _value.isComplete
          : isComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      isOverdue: null == isOverdue
          ? _value.isOverdue
          : isOverdue // ignore: cast_nullable_to_non_nullable
              as bool,
      typicalDurationMinutes: freezed == typicalDurationMinutes
          ? _value.typicalDurationMinutes
          : typicalDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OnboardingStateImplCopyWith<$Res>
    implements $OnboardingStateCopyWith<$Res> {
  factory _$$OnboardingStateImplCopyWith(_$OnboardingStateImpl value,
          $Res Function(_$OnboardingStateImpl) then) =
      __$$OnboardingStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String deviceId,
      String deviceType,
      int currentStage,
      int maxStages,
      String? statusText,
      String? stageDisplay,
      String? nextAction,
      String? errorText,
      DateTime? stageEnteredAt,
      DateTime? lastUpdate,
      int? lastUpdateAgeSecs,
      bool isComplete,
      bool isOverdue,
      int? typicalDurationMinutes});
}

/// @nodoc
class __$$OnboardingStateImplCopyWithImpl<$Res>
    extends _$OnboardingStateCopyWithImpl<$Res, _$OnboardingStateImpl>
    implements _$$OnboardingStateImplCopyWith<$Res> {
  __$$OnboardingStateImplCopyWithImpl(
      _$OnboardingStateImpl _value, $Res Function(_$OnboardingStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceId = null,
    Object? deviceType = null,
    Object? currentStage = null,
    Object? maxStages = null,
    Object? statusText = freezed,
    Object? stageDisplay = freezed,
    Object? nextAction = freezed,
    Object? errorText = freezed,
    Object? stageEnteredAt = freezed,
    Object? lastUpdate = freezed,
    Object? lastUpdateAgeSecs = freezed,
    Object? isComplete = null,
    Object? isOverdue = null,
    Object? typicalDurationMinutes = freezed,
  }) {
    return _then(_$OnboardingStateImpl(
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      deviceType: null == deviceType
          ? _value.deviceType
          : deviceType // ignore: cast_nullable_to_non_nullable
              as String,
      currentStage: null == currentStage
          ? _value.currentStage
          : currentStage // ignore: cast_nullable_to_non_nullable
              as int,
      maxStages: null == maxStages
          ? _value.maxStages
          : maxStages // ignore: cast_nullable_to_non_nullable
              as int,
      statusText: freezed == statusText
          ? _value.statusText
          : statusText // ignore: cast_nullable_to_non_nullable
              as String?,
      stageDisplay: freezed == stageDisplay
          ? _value.stageDisplay
          : stageDisplay // ignore: cast_nullable_to_non_nullable
              as String?,
      nextAction: freezed == nextAction
          ? _value.nextAction
          : nextAction // ignore: cast_nullable_to_non_nullable
              as String?,
      errorText: freezed == errorText
          ? _value.errorText
          : errorText // ignore: cast_nullable_to_non_nullable
              as String?,
      stageEnteredAt: freezed == stageEnteredAt
          ? _value.stageEnteredAt
          : stageEnteredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastUpdate: freezed == lastUpdate
          ? _value.lastUpdate
          : lastUpdate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastUpdateAgeSecs: freezed == lastUpdateAgeSecs
          ? _value.lastUpdateAgeSecs
          : lastUpdateAgeSecs // ignore: cast_nullable_to_non_nullable
              as int?,
      isComplete: null == isComplete
          ? _value.isComplete
          : isComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      isOverdue: null == isOverdue
          ? _value.isOverdue
          : isOverdue // ignore: cast_nullable_to_non_nullable
              as bool,
      typicalDurationMinutes: freezed == typicalDurationMinutes
          ? _value.typicalDurationMinutes
          : typicalDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$OnboardingStateImpl extends _OnboardingState {
  const _$OnboardingStateImpl(
      {required this.deviceId,
      required this.deviceType,
      required this.currentStage,
      required this.maxStages,
      this.statusText,
      this.stageDisplay,
      this.nextAction,
      this.errorText,
      this.stageEnteredAt,
      this.lastUpdate,
      this.lastUpdateAgeSecs,
      this.isComplete = false,
      this.isOverdue = false,
      this.typicalDurationMinutes})
      : super._();

  /// Device ID this state belongs to
  @override
  final String deviceId;

  /// Device type ('AP' or 'ONT')
  @override
  final String deviceType;

  /// Current onboarding stage (1-based, defaults to 1)
  @override
  final int currentStage;

  /// Maximum stages for this device type
  @override
  final int maxStages;

  /// Human-readable status text from backend
  @override
  final String? statusText;

  /// Display text for current stage from backend
  @override
  final String? stageDisplay;

  /// Suggested next action from backend
  @override
  final String? nextAction;

  /// Error message if any
  @override
  final String? errorText;

  /// When this stage was entered (from local tracking)
  @override
  final DateTime? stageEnteredAt;

  /// Last update timestamp from backend
  @override
  final DateTime? lastUpdate;

  /// Seconds since last update (from backend)
  @override
  final int? lastUpdateAgeSecs;

  /// Whether onboarding is complete
  @override
  @JsonKey()
  final bool isComplete;

  /// Whether the current stage is overdue
  @override
  @JsonKey()
  final bool isOverdue;

  /// Typical duration for current stage in minutes
  @override
  final int? typicalDurationMinutes;

  @override
  String toString() {
    return 'OnboardingState(deviceId: $deviceId, deviceType: $deviceType, currentStage: $currentStage, maxStages: $maxStages, statusText: $statusText, stageDisplay: $stageDisplay, nextAction: $nextAction, errorText: $errorText, stageEnteredAt: $stageEnteredAt, lastUpdate: $lastUpdate, lastUpdateAgeSecs: $lastUpdateAgeSecs, isComplete: $isComplete, isOverdue: $isOverdue, typicalDurationMinutes: $typicalDurationMinutes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OnboardingStateImpl &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.deviceType, deviceType) ||
                other.deviceType == deviceType) &&
            (identical(other.currentStage, currentStage) ||
                other.currentStage == currentStage) &&
            (identical(other.maxStages, maxStages) ||
                other.maxStages == maxStages) &&
            (identical(other.statusText, statusText) ||
                other.statusText == statusText) &&
            (identical(other.stageDisplay, stageDisplay) ||
                other.stageDisplay == stageDisplay) &&
            (identical(other.nextAction, nextAction) ||
                other.nextAction == nextAction) &&
            (identical(other.errorText, errorText) ||
                other.errorText == errorText) &&
            (identical(other.stageEnteredAt, stageEnteredAt) ||
                other.stageEnteredAt == stageEnteredAt) &&
            (identical(other.lastUpdate, lastUpdate) ||
                other.lastUpdate == lastUpdate) &&
            (identical(other.lastUpdateAgeSecs, lastUpdateAgeSecs) ||
                other.lastUpdateAgeSecs == lastUpdateAgeSecs) &&
            (identical(other.isComplete, isComplete) ||
                other.isComplete == isComplete) &&
            (identical(other.isOverdue, isOverdue) ||
                other.isOverdue == isOverdue) &&
            (identical(other.typicalDurationMinutes, typicalDurationMinutes) ||
                other.typicalDurationMinutes == typicalDurationMinutes));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      deviceId,
      deviceType,
      currentStage,
      maxStages,
      statusText,
      stageDisplay,
      nextAction,
      errorText,
      stageEnteredAt,
      lastUpdate,
      lastUpdateAgeSecs,
      isComplete,
      isOverdue,
      typicalDurationMinutes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OnboardingStateImplCopyWith<_$OnboardingStateImpl> get copyWith =>
      __$$OnboardingStateImplCopyWithImpl<_$OnboardingStateImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String deviceId,
            String deviceType,
            int currentStage,
            int maxStages,
            String? statusText,
            String? stageDisplay,
            String? nextAction,
            String? errorText,
            DateTime? stageEnteredAt,
            DateTime? lastUpdate,
            int? lastUpdateAgeSecs,
            bool isComplete,
            bool isOverdue,
            int? typicalDurationMinutes)
        $default,
  ) {
    return $default(
        deviceId,
        deviceType,
        currentStage,
        maxStages,
        statusText,
        stageDisplay,
        nextAction,
        errorText,
        stageEnteredAt,
        lastUpdate,
        lastUpdateAgeSecs,
        isComplete,
        isOverdue,
        typicalDurationMinutes);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String deviceId,
            String deviceType,
            int currentStage,
            int maxStages,
            String? statusText,
            String? stageDisplay,
            String? nextAction,
            String? errorText,
            DateTime? stageEnteredAt,
            DateTime? lastUpdate,
            int? lastUpdateAgeSecs,
            bool isComplete,
            bool isOverdue,
            int? typicalDurationMinutes)?
        $default,
  ) {
    return $default?.call(
        deviceId,
        deviceType,
        currentStage,
        maxStages,
        statusText,
        stageDisplay,
        nextAction,
        errorText,
        stageEnteredAt,
        lastUpdate,
        lastUpdateAgeSecs,
        isComplete,
        isOverdue,
        typicalDurationMinutes);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String deviceId,
            String deviceType,
            int currentStage,
            int maxStages,
            String? statusText,
            String? stageDisplay,
            String? nextAction,
            String? errorText,
            DateTime? stageEnteredAt,
            DateTime? lastUpdate,
            int? lastUpdateAgeSecs,
            bool isComplete,
            bool isOverdue,
            int? typicalDurationMinutes)?
        $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(
          deviceId,
          deviceType,
          currentStage,
          maxStages,
          statusText,
          stageDisplay,
          nextAction,
          errorText,
          stageEnteredAt,
          lastUpdate,
          lastUpdateAgeSecs,
          isComplete,
          isOverdue,
          typicalDurationMinutes);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_OnboardingState value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_OnboardingState value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_OnboardingState value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _OnboardingState extends OnboardingState {
  const factory _OnboardingState(
      {required final String deviceId,
      required final String deviceType,
      required final int currentStage,
      required final int maxStages,
      final String? statusText,
      final String? stageDisplay,
      final String? nextAction,
      final String? errorText,
      final DateTime? stageEnteredAt,
      final DateTime? lastUpdate,
      final int? lastUpdateAgeSecs,
      final bool isComplete,
      final bool isOverdue,
      final int? typicalDurationMinutes}) = _$OnboardingStateImpl;
  const _OnboardingState._() : super._();

  @override

  /// Device ID this state belongs to
  String get deviceId;
  @override

  /// Device type ('AP' or 'ONT')
  String get deviceType;
  @override

  /// Current onboarding stage (1-based, defaults to 1)
  int get currentStage;
  @override

  /// Maximum stages for this device type
  int get maxStages;
  @override

  /// Human-readable status text from backend
  String? get statusText;
  @override

  /// Display text for current stage from backend
  String? get stageDisplay;
  @override

  /// Suggested next action from backend
  String? get nextAction;
  @override

  /// Error message if any
  String? get errorText;
  @override

  /// When this stage was entered (from local tracking)
  DateTime? get stageEnteredAt;
  @override

  /// Last update timestamp from backend
  DateTime? get lastUpdate;
  @override

  /// Seconds since last update (from backend)
  int? get lastUpdateAgeSecs;
  @override

  /// Whether onboarding is complete
  bool get isComplete;
  @override

  /// Whether the current stage is overdue
  bool get isOverdue;
  @override

  /// Typical duration for current stage in minutes
  int? get typicalDurationMinutes;
  @override
  @JsonKey(ignore: true)
  _$$OnboardingStateImplCopyWith<_$OnboardingStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
