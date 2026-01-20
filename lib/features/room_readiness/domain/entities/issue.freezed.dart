// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'issue.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Issue _$IssueFromJson(Map<String, dynamic> json) {
  return _Issue.fromJson(json);
}

/// @nodoc
mixin _$Issue {
  String get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  IssueSeverity get severity => throw _privateConstructorUsedError;
  IssueCategory get category => throw _privateConstructorUsedError;
  DateTime get detectedAt => throw _privateConstructorUsedError;
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;
  String? get resolution => throw _privateConstructorUsedError;
  bool get isAutoDismissible => throw _privateConstructorUsedError;
  Duration? get autoDismissAfter => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String code,
            String title,
            String description,
            IssueSeverity severity,
            IssueCategory category,
            DateTime detectedAt,
            Map<String, dynamic> metadata,
            String? resolution,
            bool isAutoDismissible,
            Duration? autoDismissAfter)
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String code,
            String title,
            String description,
            IssueSeverity severity,
            IssueCategory category,
            DateTime detectedAt,
            Map<String, dynamic> metadata,
            String? resolution,
            bool isAutoDismissible,
            Duration? autoDismissAfter)?
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String code,
            String title,
            String description,
            IssueSeverity severity,
            IssueCategory category,
            DateTime detectedAt,
            Map<String, dynamic> metadata,
            String? resolution,
            bool isAutoDismissible,
            Duration? autoDismissAfter)?
        $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Issue value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Issue value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Issue value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $IssueCopyWith<Issue> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IssueCopyWith<$Res> {
  factory $IssueCopyWith(Issue value, $Res Function(Issue) then) =
      _$IssueCopyWithImpl<$Res, Issue>;
  @useResult
  $Res call(
      {String id,
      String code,
      String title,
      String description,
      IssueSeverity severity,
      IssueCategory category,
      DateTime detectedAt,
      Map<String, dynamic> metadata,
      String? resolution,
      bool isAutoDismissible,
      Duration? autoDismissAfter});
}

/// @nodoc
class _$IssueCopyWithImpl<$Res, $Val extends Issue>
    implements $IssueCopyWith<$Res> {
  _$IssueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? title = null,
    Object? description = null,
    Object? severity = null,
    Object? category = null,
    Object? detectedAt = null,
    Object? metadata = null,
    Object? resolution = freezed,
    Object? isAutoDismissible = null,
    Object? autoDismissAfter = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as IssueSeverity,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as IssueCategory,
      detectedAt: null == detectedAt
          ? _value.detectedAt
          : detectedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      resolution: freezed == resolution
          ? _value.resolution
          : resolution // ignore: cast_nullable_to_non_nullable
              as String?,
      isAutoDismissible: null == isAutoDismissible
          ? _value.isAutoDismissible
          : isAutoDismissible // ignore: cast_nullable_to_non_nullable
              as bool,
      autoDismissAfter: freezed == autoDismissAfter
          ? _value.autoDismissAfter
          : autoDismissAfter // ignore: cast_nullable_to_non_nullable
              as Duration?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IssueImplCopyWith<$Res> implements $IssueCopyWith<$Res> {
  factory _$$IssueImplCopyWith(
          _$IssueImpl value, $Res Function(_$IssueImpl) then) =
      __$$IssueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String code,
      String title,
      String description,
      IssueSeverity severity,
      IssueCategory category,
      DateTime detectedAt,
      Map<String, dynamic> metadata,
      String? resolution,
      bool isAutoDismissible,
      Duration? autoDismissAfter});
}

/// @nodoc
class __$$IssueImplCopyWithImpl<$Res>
    extends _$IssueCopyWithImpl<$Res, _$IssueImpl>
    implements _$$IssueImplCopyWith<$Res> {
  __$$IssueImplCopyWithImpl(
      _$IssueImpl _value, $Res Function(_$IssueImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? title = null,
    Object? description = null,
    Object? severity = null,
    Object? category = null,
    Object? detectedAt = null,
    Object? metadata = null,
    Object? resolution = freezed,
    Object? isAutoDismissible = null,
    Object? autoDismissAfter = freezed,
  }) {
    return _then(_$IssueImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as IssueSeverity,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as IssueCategory,
      detectedAt: null == detectedAt
          ? _value.detectedAt
          : detectedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      resolution: freezed == resolution
          ? _value.resolution
          : resolution // ignore: cast_nullable_to_non_nullable
              as String?,
      isAutoDismissible: null == isAutoDismissible
          ? _value.isAutoDismissible
          : isAutoDismissible // ignore: cast_nullable_to_non_nullable
              as bool,
      autoDismissAfter: freezed == autoDismissAfter
          ? _value.autoDismissAfter
          : autoDismissAfter // ignore: cast_nullable_to_non_nullable
              as Duration?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$IssueImpl extends _Issue {
  const _$IssueImpl(
      {required this.id,
      required this.code,
      required this.title,
      required this.description,
      required this.severity,
      required this.category,
      required this.detectedAt,
      final Map<String, dynamic> metadata = const {},
      this.resolution,
      this.isAutoDismissible = false,
      this.autoDismissAfter})
      : _metadata = metadata,
        super._();

  factory _$IssueImpl.fromJson(Map<String, dynamic> json) =>
      _$$IssueImplFromJson(json);

  @override
  final String id;
  @override
  final String code;
  @override
  final String title;
  @override
  final String description;
  @override
  final IssueSeverity severity;
  @override
  final IssueCategory category;
  @override
  final DateTime detectedAt;
  final Map<String, dynamic> _metadata;
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  final String? resolution;
  @override
  @JsonKey()
  final bool isAutoDismissible;
  @override
  final Duration? autoDismissAfter;

  @override
  String toString() {
    return 'Issue(id: $id, code: $code, title: $title, description: $description, severity: $severity, category: $category, detectedAt: $detectedAt, metadata: $metadata, resolution: $resolution, isAutoDismissible: $isAutoDismissible, autoDismissAfter: $autoDismissAfter)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IssueImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.detectedAt, detectedAt) ||
                other.detectedAt == detectedAt) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.resolution, resolution) ||
                other.resolution == resolution) &&
            (identical(other.isAutoDismissible, isAutoDismissible) ||
                other.isAutoDismissible == isAutoDismissible) &&
            (identical(other.autoDismissAfter, autoDismissAfter) ||
                other.autoDismissAfter == autoDismissAfter));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      code,
      title,
      description,
      severity,
      category,
      detectedAt,
      const DeepCollectionEquality().hash(_metadata),
      resolution,
      isAutoDismissible,
      autoDismissAfter);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$IssueImplCopyWith<_$IssueImpl> get copyWith =>
      __$$IssueImplCopyWithImpl<_$IssueImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String code,
            String title,
            String description,
            IssueSeverity severity,
            IssueCategory category,
            DateTime detectedAt,
            Map<String, dynamic> metadata,
            String? resolution,
            bool isAutoDismissible,
            Duration? autoDismissAfter)
        $default,
  ) {
    return $default(id, code, title, description, severity, category,
        detectedAt, metadata, resolution, isAutoDismissible, autoDismissAfter);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String code,
            String title,
            String description,
            IssueSeverity severity,
            IssueCategory category,
            DateTime detectedAt,
            Map<String, dynamic> metadata,
            String? resolution,
            bool isAutoDismissible,
            Duration? autoDismissAfter)?
        $default,
  ) {
    return $default?.call(id, code, title, description, severity, category,
        detectedAt, metadata, resolution, isAutoDismissible, autoDismissAfter);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String code,
            String title,
            String description,
            IssueSeverity severity,
            IssueCategory category,
            DateTime detectedAt,
            Map<String, dynamic> metadata,
            String? resolution,
            bool isAutoDismissible,
            Duration? autoDismissAfter)?
        $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(
          id,
          code,
          title,
          description,
          severity,
          category,
          detectedAt,
          metadata,
          resolution,
          isAutoDismissible,
          autoDismissAfter);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Issue value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Issue value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Issue value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$IssueImplToJson(
      this,
    );
  }
}

abstract class _Issue extends Issue {
  const factory _Issue(
      {required final String id,
      required final String code,
      required final String title,
      required final String description,
      required final IssueSeverity severity,
      required final IssueCategory category,
      required final DateTime detectedAt,
      final Map<String, dynamic> metadata,
      final String? resolution,
      final bool isAutoDismissible,
      final Duration? autoDismissAfter}) = _$IssueImpl;
  const _Issue._() : super._();

  factory _Issue.fromJson(Map<String, dynamic> json) = _$IssueImpl.fromJson;

  @override
  String get id;
  @override
  String get code;
  @override
  String get title;
  @override
  String get description;
  @override
  IssueSeverity get severity;
  @override
  IssueCategory get category;
  @override
  DateTime get detectedAt;
  @override
  Map<String, dynamic> get metadata;
  @override
  String? get resolution;
  @override
  bool get isAutoDismissible;
  @override
  Duration? get autoDismissAfter;
  @override
  @JsonKey(ignore: true)
  _$$IssueImplCopyWith<_$IssueImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
