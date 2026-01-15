// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health_counts_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

HealthCountsModel _$HealthCountsModelFromJson(Map<String, dynamic> json) {
  return _HealthCountsModel.fromJson(json);
}

/// @nodoc
mixin _$HealthCountsModel {
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
    TResult Function(_HealthCountsModel value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_HealthCountsModel value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_HealthCountsModel value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HealthCountsModelCopyWith<HealthCountsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HealthCountsModelCopyWith<$Res> {
  factory $HealthCountsModelCopyWith(
          HealthCountsModel value, $Res Function(HealthCountsModel) then) =
      _$HealthCountsModelCopyWithImpl<$Res, HealthCountsModel>;
  @useResult
  $Res call({int total, int fatal, int critical, int warning, int notice});
}

/// @nodoc
class _$HealthCountsModelCopyWithImpl<$Res, $Val extends HealthCountsModel>
    implements $HealthCountsModelCopyWith<$Res> {
  _$HealthCountsModelCopyWithImpl(this._value, this._then);

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
abstract class _$$HealthCountsModelImplCopyWith<$Res>
    implements $HealthCountsModelCopyWith<$Res> {
  factory _$$HealthCountsModelImplCopyWith(_$HealthCountsModelImpl value,
          $Res Function(_$HealthCountsModelImpl) then) =
      __$$HealthCountsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int total, int fatal, int critical, int warning, int notice});
}

/// @nodoc
class __$$HealthCountsModelImplCopyWithImpl<$Res>
    extends _$HealthCountsModelCopyWithImpl<$Res, _$HealthCountsModelImpl>
    implements _$$HealthCountsModelImplCopyWith<$Res> {
  __$$HealthCountsModelImplCopyWithImpl(_$HealthCountsModelImpl _value,
      $Res Function(_$HealthCountsModelImpl) _then)
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
    return _then(_$HealthCountsModelImpl(
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
@JsonSerializable()
class _$HealthCountsModelImpl implements _HealthCountsModel {
  const _$HealthCountsModelImpl(
      {this.total = 0,
      this.fatal = 0,
      this.critical = 0,
      this.warning = 0,
      this.notice = 0});

  factory _$HealthCountsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$HealthCountsModelImplFromJson(json);

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
    return 'HealthCountsModel(total: $total, fatal: $fatal, critical: $critical, warning: $warning, notice: $notice)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HealthCountsModelImpl &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.fatal, fatal) || other.fatal == fatal) &&
            (identical(other.critical, critical) ||
                other.critical == critical) &&
            (identical(other.warning, warning) || other.warning == warning) &&
            (identical(other.notice, notice) || other.notice == notice));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, total, fatal, critical, warning, notice);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HealthCountsModelImplCopyWith<_$HealthCountsModelImpl> get copyWith =>
      __$$HealthCountsModelImplCopyWithImpl<_$HealthCountsModelImpl>(
          this, _$identity);

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
    TResult Function(_HealthCountsModel value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_HealthCountsModel value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_HealthCountsModel value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$HealthCountsModelImplToJson(
      this,
    );
  }
}

abstract class _HealthCountsModel implements HealthCountsModel {
  const factory _HealthCountsModel(
      {final int total,
      final int fatal,
      final int critical,
      final int warning,
      final int notice}) = _$HealthCountsModelImpl;

  factory _HealthCountsModel.fromJson(Map<String, dynamic> json) =
      _$HealthCountsModelImpl.fromJson;

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
  _$$HealthCountsModelImplCopyWith<_$HealthCountsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
