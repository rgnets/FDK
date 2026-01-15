// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health_counts.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$HealthCounts {
  int get total => throw _privateConstructorUsedError;
  int get fatal => throw _privateConstructorUsedError;
  int get critical => throw _privateConstructorUsedError;
  int get warning => throw _privateConstructorUsedError;
  int get notice => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            int total, int fatal, int critical, int warning, int notice)
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            int total, int fatal, int critical, int warning, int notice)?
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            int total, int fatal, int critical, int warning, int notice)?
        $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_HealthCounts value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_HealthCounts value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_HealthCounts value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $HealthCountsCopyWith<HealthCounts> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HealthCountsCopyWith<$Res> {
  factory $HealthCountsCopyWith(
          HealthCounts value, $Res Function(HealthCounts) then) =
      _$HealthCountsCopyWithImpl<$Res, HealthCounts>;
  @useResult
  $Res call({int total, int fatal, int critical, int warning, int notice});
}

/// @nodoc
class _$HealthCountsCopyWithImpl<$Res, $Val extends HealthCounts>
    implements $HealthCountsCopyWith<$Res> {
  _$HealthCountsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? fatal = null,
    Object? critical = null,
    Object? warning = null,
    Object? notice = null,
  }) {
    return _then(_value.copyWith(
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      fatal: null == fatal
          ? _value.fatal
          : fatal // ignore: cast_nullable_to_non_nullable
              as int,
      critical: null == critical
          ? _value.critical
          : critical // ignore: cast_nullable_to_non_nullable
              as int,
      warning: null == warning
          ? _value.warning
          : warning // ignore: cast_nullable_to_non_nullable
              as int,
      notice: null == notice
          ? _value.notice
          : notice // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HealthCountsImplCopyWith<$Res>
    implements $HealthCountsCopyWith<$Res> {
  factory _$$HealthCountsImplCopyWith(
          _$HealthCountsImpl value, $Res Function(_$HealthCountsImpl) then) =
      __$$HealthCountsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int total, int fatal, int critical, int warning, int notice});
}

/// @nodoc
class __$$HealthCountsImplCopyWithImpl<$Res>
    extends _$HealthCountsCopyWithImpl<$Res, _$HealthCountsImpl>
    implements _$$HealthCountsImplCopyWith<$Res> {
  __$$HealthCountsImplCopyWithImpl(
      _$HealthCountsImpl _value, $Res Function(_$HealthCountsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? fatal = null,
    Object? critical = null,
    Object? warning = null,
    Object? notice = null,
  }) {
    return _then(_$HealthCountsImpl(
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      fatal: null == fatal
          ? _value.fatal
          : fatal // ignore: cast_nullable_to_non_nullable
              as int,
      critical: null == critical
          ? _value.critical
          : critical // ignore: cast_nullable_to_non_nullable
              as int,
      warning: null == warning
          ? _value.warning
          : warning // ignore: cast_nullable_to_non_nullable
              as int,
      notice: null == notice
          ? _value.notice
          : notice // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$HealthCountsImpl extends _HealthCounts {
  const _$HealthCountsImpl(
      {this.total = 0,
      this.fatal = 0,
      this.critical = 0,
      this.warning = 0,
      this.notice = 0})
      : super._();

  @override
  @JsonKey()
  final int total;
  @override
  @JsonKey()
  final int fatal;
  @override
  @JsonKey()
  final int critical;
  @override
  @JsonKey()
  final int warning;
  @override
  @JsonKey()
  final int notice;

  @override
  String toString() {
    return 'HealthCounts(total: $total, fatal: $fatal, critical: $critical, warning: $warning, notice: $notice)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HealthCountsImpl &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.fatal, fatal) || other.fatal == fatal) &&
            (identical(other.critical, critical) ||
                other.critical == critical) &&
            (identical(other.warning, warning) || other.warning == warning) &&
            (identical(other.notice, notice) || other.notice == notice));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, total, fatal, critical, warning, notice);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HealthCountsImplCopyWith<_$HealthCountsImpl> get copyWith =>
      __$$HealthCountsImplCopyWithImpl<_$HealthCountsImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            int total, int fatal, int critical, int warning, int notice)
        $default,
  ) {
    return $default(total, fatal, critical, warning, notice);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            int total, int fatal, int critical, int warning, int notice)?
        $default,
  ) {
    return $default?.call(total, fatal, critical, warning, notice);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            int total, int fatal, int critical, int warning, int notice)?
        $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(total, fatal, critical, warning, notice);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_HealthCounts value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_HealthCounts value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_HealthCounts value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _HealthCounts extends HealthCounts {
  const factory _HealthCounts(
      {final int total,
      final int fatal,
      final int critical,
      final int warning,
      final int notice}) = _$HealthCountsImpl;
  const _HealthCounts._() : super._();

  @override
  int get total;
  @override
  int get fatal;
  @override
  int get critical;
  @override
  int get warning;
  @override
  int get notice;
  @override
  @JsonKey(ignore: true)
  _$$HealthCountsImplCopyWith<_$HealthCountsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
