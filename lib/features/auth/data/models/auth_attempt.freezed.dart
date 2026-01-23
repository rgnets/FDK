// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_attempt.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AuthAttempt _$AuthAttemptFromJson(Map<String, dynamic> json) {
  return _AuthAttempt.fromJson(json);
}

/// @nodoc
mixin _$AuthAttempt {
  DateTime get timestamp => throw _privateConstructorUsedError;
  String get fqdn => throw _privateConstructorUsedError;
  String get login => throw _privateConstructorUsedError;
  bool get success => throw _privateConstructorUsedError;
  String? get siteName => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(DateTime timestamp, String fqdn, String login,
            bool success, String? siteName, String? message)
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(DateTime timestamp, String fqdn, String login,
            bool success, String? siteName, String? message)?
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(DateTime timestamp, String fqdn, String login,
            bool success, String? siteName, String? message)?
        $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_AuthAttempt value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_AuthAttempt value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_AuthAttempt value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AuthAttemptCopyWith<AuthAttempt> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthAttemptCopyWith<$Res> {
  factory $AuthAttemptCopyWith(
          AuthAttempt value, $Res Function(AuthAttempt) then) =
      _$AuthAttemptCopyWithImpl<$Res, AuthAttempt>;
  @useResult
  $Res call(
      {DateTime timestamp,
      String fqdn,
      String login,
      bool success,
      String? siteName,
      String? message});
}

/// @nodoc
class _$AuthAttemptCopyWithImpl<$Res, $Val extends AuthAttempt>
    implements $AuthAttemptCopyWith<$Res> {
  _$AuthAttemptCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? fqdn = null,
    Object? login = null,
    Object? success = null,
    Object? siteName = freezed,
    Object? message = freezed,
  }) {
    return _then(_value.copyWith(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      fqdn: null == fqdn
          ? _value.fqdn
          : fqdn // ignore: cast_nullable_to_non_nullable
              as String,
      login: null == login
          ? _value.login
          : login // ignore: cast_nullable_to_non_nullable
              as String,
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      siteName: freezed == siteName
          ? _value.siteName
          : siteName // ignore: cast_nullable_to_non_nullable
              as String?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AuthAttemptImplCopyWith<$Res>
    implements $AuthAttemptCopyWith<$Res> {
  factory _$$AuthAttemptImplCopyWith(
          _$AuthAttemptImpl value, $Res Function(_$AuthAttemptImpl) then) =
      __$$AuthAttemptImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime timestamp,
      String fqdn,
      String login,
      bool success,
      String? siteName,
      String? message});
}

/// @nodoc
class __$$AuthAttemptImplCopyWithImpl<$Res>
    extends _$AuthAttemptCopyWithImpl<$Res, _$AuthAttemptImpl>
    implements _$$AuthAttemptImplCopyWith<$Res> {
  __$$AuthAttemptImplCopyWithImpl(
      _$AuthAttemptImpl _value, $Res Function(_$AuthAttemptImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? fqdn = null,
    Object? login = null,
    Object? success = null,
    Object? siteName = freezed,
    Object? message = freezed,
  }) {
    return _then(_$AuthAttemptImpl(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      fqdn: null == fqdn
          ? _value.fqdn
          : fqdn // ignore: cast_nullable_to_non_nullable
              as String,
      login: null == login
          ? _value.login
          : login // ignore: cast_nullable_to_non_nullable
              as String,
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      siteName: freezed == siteName
          ? _value.siteName
          : siteName // ignore: cast_nullable_to_non_nullable
              as String?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthAttemptImpl implements _AuthAttempt {
  const _$AuthAttemptImpl(
      {required this.timestamp,
      this.fqdn = '',
      this.login = '',
      this.success = false,
      this.siteName,
      this.message});

  factory _$AuthAttemptImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthAttemptImplFromJson(json);

  @override
  final DateTime timestamp;
  @override
  @JsonKey()
  final String fqdn;
  @override
  @JsonKey()
  final String login;
  @override
  @JsonKey()
  final bool success;
  @override
  final String? siteName;
  @override
  final String? message;

  @override
  String toString() {
    return 'AuthAttempt(timestamp: $timestamp, fqdn: $fqdn, login: $login, success: $success, siteName: $siteName, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthAttemptImpl &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.fqdn, fqdn) || other.fqdn == fqdn) &&
            (identical(other.login, login) || other.login == login) &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.siteName, siteName) ||
                other.siteName == siteName) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, timestamp, fqdn, login, success, siteName, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthAttemptImplCopyWith<_$AuthAttemptImpl> get copyWith =>
      __$$AuthAttemptImplCopyWithImpl<_$AuthAttemptImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(DateTime timestamp, String fqdn, String login,
            bool success, String? siteName, String? message)
        $default,
  ) {
    return $default(timestamp, fqdn, login, success, siteName, message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(DateTime timestamp, String fqdn, String login,
            bool success, String? siteName, String? message)?
        $default,
  ) {
    return $default?.call(timestamp, fqdn, login, success, siteName, message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(DateTime timestamp, String fqdn, String login,
            bool success, String? siteName, String? message)?
        $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(timestamp, fqdn, login, success, siteName, message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_AuthAttempt value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_AuthAttempt value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_AuthAttempt value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthAttemptImplToJson(
      this,
    );
  }
}

abstract class _AuthAttempt implements AuthAttempt {
  const factory _AuthAttempt(
      {required final DateTime timestamp,
      final String fqdn,
      final String login,
      final bool success,
      final String? siteName,
      final String? message}) = _$AuthAttemptImpl;

  factory _AuthAttempt.fromJson(Map<String, dynamic> json) =
      _$AuthAttemptImpl.fromJson;

  @override
  DateTime get timestamp;
  @override
  String get fqdn;
  @override
  String get login;
  @override
  bool get success;
  @override
  String? get siteName;
  @override
  String? get message;
  @override
  @JsonKey(ignore: true)
  _$$AuthAttemptImplCopyWith<_$AuthAttemptImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
