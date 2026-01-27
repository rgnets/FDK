// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'speed_test_with_results.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SpeedTestWithResults {
  SpeedTestConfig get config => throw _privateConstructorUsedError;
  List<SpeedTestResult> get results => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(SpeedTestConfig config, List<SpeedTestResult> results)
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(SpeedTestConfig config, List<SpeedTestResult> results)?
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(SpeedTestConfig config, List<SpeedTestResult> results)?
        $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_SpeedTestWithResults value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_SpeedTestWithResults value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_SpeedTestWithResults value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SpeedTestWithResultsCopyWith<SpeedTestWithResults> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SpeedTestWithResultsCopyWith<$Res> {
  factory $SpeedTestWithResultsCopyWith(SpeedTestWithResults value,
          $Res Function(SpeedTestWithResults) then) =
      _$SpeedTestWithResultsCopyWithImpl<$Res, SpeedTestWithResults>;
  @useResult
  $Res call({SpeedTestConfig config, List<SpeedTestResult> results});

  $SpeedTestConfigCopyWith<$Res> get config;
}

/// @nodoc
class _$SpeedTestWithResultsCopyWithImpl<$Res,
        $Val extends SpeedTestWithResults>
    implements $SpeedTestWithResultsCopyWith<$Res> {
  _$SpeedTestWithResultsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? config = null,
    Object? results = null,
  }) {
    return _then(_value.copyWith(
      config: null == config
          ? _value.config
          : config // ignore: cast_nullable_to_non_nullable
              as SpeedTestConfig,
      results: null == results
          ? _value.results
          : results // ignore: cast_nullable_to_non_nullable
              as List<SpeedTestResult>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $SpeedTestConfigCopyWith<$Res> get config {
    return $SpeedTestConfigCopyWith<$Res>(_value.config, (value) {
      return _then(_value.copyWith(config: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SpeedTestWithResultsImplCopyWith<$Res>
    implements $SpeedTestWithResultsCopyWith<$Res> {
  factory _$$SpeedTestWithResultsImplCopyWith(_$SpeedTestWithResultsImpl value,
          $Res Function(_$SpeedTestWithResultsImpl) then) =
      __$$SpeedTestWithResultsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({SpeedTestConfig config, List<SpeedTestResult> results});

  @override
  $SpeedTestConfigCopyWith<$Res> get config;
}

/// @nodoc
class __$$SpeedTestWithResultsImplCopyWithImpl<$Res>
    extends _$SpeedTestWithResultsCopyWithImpl<$Res, _$SpeedTestWithResultsImpl>
    implements _$$SpeedTestWithResultsImplCopyWith<$Res> {
  __$$SpeedTestWithResultsImplCopyWithImpl(_$SpeedTestWithResultsImpl _value,
      $Res Function(_$SpeedTestWithResultsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? config = null,
    Object? results = null,
  }) {
    return _then(_$SpeedTestWithResultsImpl(
      config: null == config
          ? _value.config
          : config // ignore: cast_nullable_to_non_nullable
              as SpeedTestConfig,
      results: null == results
          ? _value._results
          : results // ignore: cast_nullable_to_non_nullable
              as List<SpeedTestResult>,
    ));
  }
}

/// @nodoc

class _$SpeedTestWithResultsImpl extends _SpeedTestWithResults {
  const _$SpeedTestWithResultsImpl(
      {required this.config, final List<SpeedTestResult> results = const []})
      : _results = results,
        super._();

  @override
  final SpeedTestConfig config;
  final List<SpeedTestResult> _results;
  @override
  @JsonKey()
  List<SpeedTestResult> get results {
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_results);
  }

  @override
  String toString() {
    return 'SpeedTestWithResults(config: $config, results: $results)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SpeedTestWithResultsImpl &&
            (identical(other.config, config) || other.config == config) &&
            const DeepCollectionEquality().equals(other._results, _results));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, config, const DeepCollectionEquality().hash(_results));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SpeedTestWithResultsImplCopyWith<_$SpeedTestWithResultsImpl>
      get copyWith =>
          __$$SpeedTestWithResultsImplCopyWithImpl<_$SpeedTestWithResultsImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(SpeedTestConfig config, List<SpeedTestResult> results)
        $default,
  ) {
    return $default(config, results);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(SpeedTestConfig config, List<SpeedTestResult> results)?
        $default,
  ) {
    return $default?.call(config, results);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(SpeedTestConfig config, List<SpeedTestResult> results)?
        $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(config, results);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_SpeedTestWithResults value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_SpeedTestWithResults value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_SpeedTestWithResults value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _SpeedTestWithResults extends SpeedTestWithResults {
  const factory _SpeedTestWithResults(
      {required final SpeedTestConfig config,
      final List<SpeedTestResult> results}) = _$SpeedTestWithResultsImpl;
  const _SpeedTestWithResults._() : super._();

  @override
  SpeedTestConfig get config;
  @override
  List<SpeedTestResult> get results;
  @override
  @JsonKey(ignore: true)
  _$$SpeedTestWithResultsImplCopyWith<_$SpeedTestWithResultsImpl>
      get copyWith => throw _privateConstructorUsedError;
}
