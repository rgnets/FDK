// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health_notices_summary_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

HealthNoticesSummaryModel _$HealthNoticesSummaryModelFromJson(
    Map<String, dynamic> json) {
  return _HealthNoticesSummaryModel.fromJson(json);
}

/// @nodoc
mixin _$HealthNoticesSummaryModel {
  List<HealthNoticeModel> get notices => throw _privateConstructorUsedError;
  HealthCountsModel get counts => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(List<HealthNoticeModel> notices, HealthCountsModel counts)
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            List<HealthNoticeModel> notices, HealthCountsModel counts)?
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(List<HealthNoticeModel> notices, HealthCountsModel counts)?
        $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_HealthNoticesSummaryModel value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_HealthNoticesSummaryModel value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_HealthNoticesSummaryModel value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HealthNoticesSummaryModelCopyWith<HealthNoticesSummaryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HealthNoticesSummaryModelCopyWith<$Res> {
  factory $HealthNoticesSummaryModelCopyWith(HealthNoticesSummaryModel value,
          $Res Function(HealthNoticesSummaryModel) then) =
      _$HealthNoticesSummaryModelCopyWithImpl<$Res, HealthNoticesSummaryModel>;
  @useResult
  $Res call({List<HealthNoticeModel> notices, HealthCountsModel counts});

  $HealthCountsModelCopyWith<$Res> get counts;
}

/// @nodoc
class _$HealthNoticesSummaryModelCopyWithImpl<$Res,
        $Val extends HealthNoticesSummaryModel>
    implements $HealthNoticesSummaryModelCopyWith<$Res> {
  _$HealthNoticesSummaryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notices = null,
    Object? counts = null,
  }) {
    return _then(_value.copyWith(
      notices: null == notices
          ? _value.notices
          : notices // ignore: cast_nullable_to_non_nullable
              as List<HealthNoticeModel>,
      counts: null == counts
          ? _value.counts
          : counts // ignore: cast_nullable_to_non_nullable
              as HealthCountsModel,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $HealthCountsModelCopyWith<$Res> get counts {
    return $HealthCountsModelCopyWith<$Res>(_value.counts, (value) {
      return _then(_value.copyWith(counts: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$HealthNoticesSummaryModelImplCopyWith<$Res>
    implements $HealthNoticesSummaryModelCopyWith<$Res> {
  factory _$$HealthNoticesSummaryModelImplCopyWith(
          _$HealthNoticesSummaryModelImpl value,
          $Res Function(_$HealthNoticesSummaryModelImpl) then) =
      __$$HealthNoticesSummaryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<HealthNoticeModel> notices, HealthCountsModel counts});

  @override
  $HealthCountsModelCopyWith<$Res> get counts;
}

/// @nodoc
class __$$HealthNoticesSummaryModelImplCopyWithImpl<$Res>
    extends _$HealthNoticesSummaryModelCopyWithImpl<$Res,
        _$HealthNoticesSummaryModelImpl>
    implements _$$HealthNoticesSummaryModelImplCopyWith<$Res> {
  __$$HealthNoticesSummaryModelImplCopyWithImpl(
      _$HealthNoticesSummaryModelImpl _value,
      $Res Function(_$HealthNoticesSummaryModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notices = null,
    Object? counts = null,
  }) {
    return _then(_$HealthNoticesSummaryModelImpl(
      notices: null == notices
          ? _value._notices
          : notices // ignore: cast_nullable_to_non_nullable
              as List<HealthNoticeModel>,
      counts: null == counts
          ? _value.counts
          : counts // ignore: cast_nullable_to_non_nullable
              as HealthCountsModel,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HealthNoticesSummaryModelImpl extends _HealthNoticesSummaryModel {
  const _$HealthNoticesSummaryModelImpl(
      {final List<HealthNoticeModel> notices = const [],
      this.counts = const HealthCountsModel()})
      : _notices = notices,
        super._();

  factory _$HealthNoticesSummaryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$HealthNoticesSummaryModelImplFromJson(json);

  final List<HealthNoticeModel> _notices;
  @override
  @JsonKey()
  List<HealthNoticeModel> get notices {
    if (_notices is EqualUnmodifiableListView) return _notices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notices);
  }

  @override
  @JsonKey()
  final HealthCountsModel counts;

  @override
  String toString() {
    return 'HealthNoticesSummaryModel(notices: $notices, counts: $counts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HealthNoticesSummaryModelImpl &&
            const DeepCollectionEquality().equals(other._notices, _notices) &&
            (identical(other.counts, counts) || other.counts == counts));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_notices), counts);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HealthNoticesSummaryModelImplCopyWith<_$HealthNoticesSummaryModelImpl>
      get copyWith => __$$HealthNoticesSummaryModelImplCopyWithImpl<
          _$HealthNoticesSummaryModelImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(List<HealthNoticeModel> notices, HealthCountsModel counts)
        $default,
  ) {
    return $default(notices, counts);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            List<HealthNoticeModel> notices, HealthCountsModel counts)?
        $default,
  ) {
    return $default?.call(notices, counts);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(List<HealthNoticeModel> notices, HealthCountsModel counts)?
        $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(notices, counts);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_HealthNoticesSummaryModel value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_HealthNoticesSummaryModel value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_HealthNoticesSummaryModel value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$HealthNoticesSummaryModelImplToJson(
      this,
    );
  }
}

abstract class _HealthNoticesSummaryModel extends HealthNoticesSummaryModel {
  const factory _HealthNoticesSummaryModel(
      {final List<HealthNoticeModel> notices,
      final HealthCountsModel counts}) = _$HealthNoticesSummaryModelImpl;
  const _HealthNoticesSummaryModel._() : super._();

  factory _HealthNoticesSummaryModel.fromJson(Map<String, dynamic> json) =
      _$HealthNoticesSummaryModelImpl.fromJson;

  @override
  List<HealthNoticeModel> get notices;
  @override
  HealthCountsModel get counts;
  @override
  @JsonKey(ignore: true)
  _$$HealthNoticesSummaryModelImplCopyWith<_$HealthNoticesSummaryModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
