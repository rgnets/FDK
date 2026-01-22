// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

OnboardingMessage _$OnboardingMessageFromJson(Map<String, dynamic> json) {
  return _OnboardingMessage.fromJson(json);
}

/// @nodoc
mixin _$OnboardingMessage {
  /// Stage number (1-based)
  int get stage => throw _privateConstructorUsedError;

  /// Human-readable title for this stage
  String get title => throw _privateConstructorUsedError;

  /// Detailed description of what happens in this stage
  String get description => throw _privateConstructorUsedError;

  /// Resolution text - what to do if stuck in this stage
  String get resolution => throw _privateConstructorUsedError;

  /// Typical duration in minutes for this stage (null for success stages)
  int? get typicalDurationMinutes => throw _privateConstructorUsedError;

  /// Whether this stage represents successful completion
  bool get isSuccess => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(int stage, String title, String description,
            String resolution, int? typicalDurationMinutes, bool isSuccess)
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(int stage, String title, String description,
            String resolution, int? typicalDurationMinutes, bool isSuccess)?
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(int stage, String title, String description,
            String resolution, int? typicalDurationMinutes, bool isSuccess)?
        $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_OnboardingMessage value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_OnboardingMessage value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_OnboardingMessage value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $OnboardingMessageCopyWith<OnboardingMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnboardingMessageCopyWith<$Res> {
  factory $OnboardingMessageCopyWith(
          OnboardingMessage value, $Res Function(OnboardingMessage) then) =
      _$OnboardingMessageCopyWithImpl<$Res, OnboardingMessage>;
  @useResult
  $Res call(
      {int stage,
      String title,
      String description,
      String resolution,
      int? typicalDurationMinutes,
      bool isSuccess});
}

/// @nodoc
class _$OnboardingMessageCopyWithImpl<$Res, $Val extends OnboardingMessage>
    implements $OnboardingMessageCopyWith<$Res> {
  _$OnboardingMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stage = null,
    Object? title = null,
    Object? description = null,
    Object? resolution = null,
    Object? typicalDurationMinutes = freezed,
    Object? isSuccess = null,
  }) {
    return _then(_value.copyWith(
      stage: null == stage
          ? _value.stage
          : stage // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      resolution: null == resolution
          ? _value.resolution
          : resolution // ignore: cast_nullable_to_non_nullable
              as String,
      typicalDurationMinutes: freezed == typicalDurationMinutes
          ? _value.typicalDurationMinutes
          : typicalDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      isSuccess: null == isSuccess
          ? _value.isSuccess
          : isSuccess // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OnboardingMessageImplCopyWith<$Res>
    implements $OnboardingMessageCopyWith<$Res> {
  factory _$$OnboardingMessageImplCopyWith(_$OnboardingMessageImpl value,
          $Res Function(_$OnboardingMessageImpl) then) =
      __$$OnboardingMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int stage,
      String title,
      String description,
      String resolution,
      int? typicalDurationMinutes,
      bool isSuccess});
}

/// @nodoc
class __$$OnboardingMessageImplCopyWithImpl<$Res>
    extends _$OnboardingMessageCopyWithImpl<$Res, _$OnboardingMessageImpl>
    implements _$$OnboardingMessageImplCopyWith<$Res> {
  __$$OnboardingMessageImplCopyWithImpl(_$OnboardingMessageImpl _value,
      $Res Function(_$OnboardingMessageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stage = null,
    Object? title = null,
    Object? description = null,
    Object? resolution = null,
    Object? typicalDurationMinutes = freezed,
    Object? isSuccess = null,
  }) {
    return _then(_$OnboardingMessageImpl(
      stage: null == stage
          ? _value.stage
          : stage // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      resolution: null == resolution
          ? _value.resolution
          : resolution // ignore: cast_nullable_to_non_nullable
              as String,
      typicalDurationMinutes: freezed == typicalDurationMinutes
          ? _value.typicalDurationMinutes
          : typicalDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      isSuccess: null == isSuccess
          ? _value.isSuccess
          : isSuccess // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OnboardingMessageImpl extends _OnboardingMessage {
  const _$OnboardingMessageImpl(
      {required this.stage,
      required this.title,
      required this.description,
      required this.resolution,
      this.typicalDurationMinutes,
      this.isSuccess = false})
      : super._();

  factory _$OnboardingMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$OnboardingMessageImplFromJson(json);

  /// Stage number (1-based)
  @override
  final int stage;

  /// Human-readable title for this stage
  @override
  final String title;

  /// Detailed description of what happens in this stage
  @override
  final String description;

  /// Resolution text - what to do if stuck in this stage
  @override
  final String resolution;

  /// Typical duration in minutes for this stage (null for success stages)
  @override
  final int? typicalDurationMinutes;

  /// Whether this stage represents successful completion
  @override
  @JsonKey()
  final bool isSuccess;

  @override
  String toString() {
    return 'OnboardingMessage(stage: $stage, title: $title, description: $description, resolution: $resolution, typicalDurationMinutes: $typicalDurationMinutes, isSuccess: $isSuccess)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OnboardingMessageImpl &&
            (identical(other.stage, stage) || other.stage == stage) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.resolution, resolution) ||
                other.resolution == resolution) &&
            (identical(other.typicalDurationMinutes, typicalDurationMinutes) ||
                other.typicalDurationMinutes == typicalDurationMinutes) &&
            (identical(other.isSuccess, isSuccess) ||
                other.isSuccess == isSuccess));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, stage, title, description,
      resolution, typicalDurationMinutes, isSuccess);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OnboardingMessageImplCopyWith<_$OnboardingMessageImpl> get copyWith =>
      __$$OnboardingMessageImplCopyWithImpl<_$OnboardingMessageImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(int stage, String title, String description,
            String resolution, int? typicalDurationMinutes, bool isSuccess)
        $default,
  ) {
    return $default(stage, title, description, resolution,
        typicalDurationMinutes, isSuccess);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(int stage, String title, String description,
            String resolution, int? typicalDurationMinutes, bool isSuccess)?
        $default,
  ) {
    return $default?.call(stage, title, description, resolution,
        typicalDurationMinutes, isSuccess);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(int stage, String title, String description,
            String resolution, int? typicalDurationMinutes, bool isSuccess)?
        $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(stage, title, description, resolution,
          typicalDurationMinutes, isSuccess);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_OnboardingMessage value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_OnboardingMessage value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_OnboardingMessage value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$OnboardingMessageImplToJson(
      this,
    );
  }
}

abstract class _OnboardingMessage extends OnboardingMessage {
  const factory _OnboardingMessage(
      {required final int stage,
      required final String title,
      required final String description,
      required final String resolution,
      final int? typicalDurationMinutes,
      final bool isSuccess}) = _$OnboardingMessageImpl;
  const _OnboardingMessage._() : super._();

  factory _OnboardingMessage.fromJson(Map<String, dynamic> json) =
      _$OnboardingMessageImpl.fromJson;

  @override

  /// Stage number (1-based)
  int get stage;
  @override

  /// Human-readable title for this stage
  String get title;
  @override

  /// Detailed description of what happens in this stage
  String get description;
  @override

  /// Resolution text - what to do if stuck in this stage
  String get resolution;
  @override

  /// Typical duration in minutes for this stage (null for success stages)
  int? get typicalDurationMinutes;
  @override

  /// Whether this stage represents successful completion
  bool get isSuccess;
  @override
  @JsonKey(ignore: true)
  _$$OnboardingMessageImplCopyWith<_$OnboardingMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
