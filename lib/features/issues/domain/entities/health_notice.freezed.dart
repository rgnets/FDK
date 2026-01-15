// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health_notice.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$HealthNotice {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  HealthNoticeSeverity get severity => throw _privateConstructorUsedError;
  String get shortMessage => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get longMessage => throw _privateConstructorUsedError;
  DateTime? get curedAt => throw _privateConstructorUsedError;
  String? get deviceId => throw _privateConstructorUsedError;
  String? get deviceName => throw _privateConstructorUsedError;
  String? get roomName => throw _privateConstructorUsedError;
  String? get deviceType => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            int id,
            String name,
            HealthNoticeSeverity severity,
            String shortMessage,
            DateTime createdAt,
            String? longMessage,
            DateTime? curedAt,
            String? deviceId,
            String? deviceName,
            String? roomName,
            String? deviceType)
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            int id,
            String name,
            HealthNoticeSeverity severity,
            String shortMessage,
            DateTime createdAt,
            String? longMessage,
            DateTime? curedAt,
            String? deviceId,
            String? deviceName,
            String? roomName,
            String? deviceType)?
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            int id,
            String name,
            HealthNoticeSeverity severity,
            String shortMessage,
            DateTime createdAt,
            String? longMessage,
            DateTime? curedAt,
            String? deviceId,
            String? deviceName,
            String? roomName,
            String? deviceType)?
        $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_HealthNotice value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_HealthNotice value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_HealthNotice value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $HealthNoticeCopyWith<HealthNotice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HealthNoticeCopyWith<$Res> {
  factory $HealthNoticeCopyWith(
          HealthNotice value, $Res Function(HealthNotice) then) =
      _$HealthNoticeCopyWithImpl<$Res, HealthNotice>;
  @useResult
  $Res call(
      {int id,
      String name,
      HealthNoticeSeverity severity,
      String shortMessage,
      DateTime createdAt,
      String? longMessage,
      DateTime? curedAt,
      String? deviceId,
      String? deviceName,
      String? roomName,
      String? deviceType});
}

/// @nodoc
class _$HealthNoticeCopyWithImpl<$Res, $Val extends HealthNotice>
    implements $HealthNoticeCopyWith<$Res> {
  _$HealthNoticeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? severity = null,
    Object? shortMessage = null,
    Object? createdAt = null,
    Object? longMessage = freezed,
    Object? curedAt = freezed,
    Object? deviceId = freezed,
    Object? deviceName = freezed,
    Object? roomName = freezed,
    Object? deviceType = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as HealthNoticeSeverity,
      shortMessage: null == shortMessage
          ? _value.shortMessage
          : shortMessage // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      longMessage: freezed == longMessage
          ? _value.longMessage
          : longMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      curedAt: freezed == curedAt
          ? _value.curedAt
          : curedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deviceId: freezed == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String?,
      deviceName: freezed == deviceName
          ? _value.deviceName
          : deviceName // ignore: cast_nullable_to_non_nullable
              as String?,
      roomName: freezed == roomName
          ? _value.roomName
          : roomName // ignore: cast_nullable_to_non_nullable
              as String?,
      deviceType: freezed == deviceType
          ? _value.deviceType
          : deviceType // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HealthNoticeImplCopyWith<$Res>
    implements $HealthNoticeCopyWith<$Res> {
  factory _$$HealthNoticeImplCopyWith(
          _$HealthNoticeImpl value, $Res Function(_$HealthNoticeImpl) then) =
      __$$HealthNoticeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      HealthNoticeSeverity severity,
      String shortMessage,
      DateTime createdAt,
      String? longMessage,
      DateTime? curedAt,
      String? deviceId,
      String? deviceName,
      String? roomName,
      String? deviceType});
}

/// @nodoc
class __$$HealthNoticeImplCopyWithImpl<$Res>
    extends _$HealthNoticeCopyWithImpl<$Res, _$HealthNoticeImpl>
    implements _$$HealthNoticeImplCopyWith<$Res> {
  __$$HealthNoticeImplCopyWithImpl(
      _$HealthNoticeImpl _value, $Res Function(_$HealthNoticeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? severity = null,
    Object? shortMessage = null,
    Object? createdAt = null,
    Object? longMessage = freezed,
    Object? curedAt = freezed,
    Object? deviceId = freezed,
    Object? deviceName = freezed,
    Object? roomName = freezed,
    Object? deviceType = freezed,
  }) {
    return _then(_$HealthNoticeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as HealthNoticeSeverity,
      shortMessage: null == shortMessage
          ? _value.shortMessage
          : shortMessage // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      longMessage: freezed == longMessage
          ? _value.longMessage
          : longMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      curedAt: freezed == curedAt
          ? _value.curedAt
          : curedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deviceId: freezed == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String?,
      deviceName: freezed == deviceName
          ? _value.deviceName
          : deviceName // ignore: cast_nullable_to_non_nullable
              as String?,
      roomName: freezed == roomName
          ? _value.roomName
          : roomName // ignore: cast_nullable_to_non_nullable
              as String?,
      deviceType: freezed == deviceType
          ? _value.deviceType
          : deviceType // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$HealthNoticeImpl extends _HealthNotice {
  const _$HealthNoticeImpl(
      {required this.id,
      required this.name,
      required this.severity,
      required this.shortMessage,
      required this.createdAt,
      this.longMessage,
      this.curedAt,
      this.deviceId,
      this.deviceName,
      this.roomName,
      this.deviceType})
      : super._();

  @override
  final int id;
  @override
  final String name;
  @override
  final HealthNoticeSeverity severity;
  @override
  final String shortMessage;
  @override
  final DateTime createdAt;
  @override
  final String? longMessage;
  @override
  final DateTime? curedAt;
  @override
  final String? deviceId;
  @override
  final String? deviceName;
  @override
  final String? roomName;
  @override
  final String? deviceType;

  @override
  String toString() {
    return 'HealthNotice(id: $id, name: $name, severity: $severity, shortMessage: $shortMessage, createdAt: $createdAt, longMessage: $longMessage, curedAt: $curedAt, deviceId: $deviceId, deviceName: $deviceName, roomName: $roomName, deviceType: $deviceType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HealthNoticeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.shortMessage, shortMessage) ||
                other.shortMessage == shortMessage) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.longMessage, longMessage) ||
                other.longMessage == longMessage) &&
            (identical(other.curedAt, curedAt) || other.curedAt == curedAt) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.deviceName, deviceName) ||
                other.deviceName == deviceName) &&
            (identical(other.roomName, roomName) ||
                other.roomName == roomName) &&
            (identical(other.deviceType, deviceType) ||
                other.deviceType == deviceType));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      severity,
      shortMessage,
      createdAt,
      longMessage,
      curedAt,
      deviceId,
      deviceName,
      roomName,
      deviceType);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HealthNoticeImplCopyWith<_$HealthNoticeImpl> get copyWith =>
      __$$HealthNoticeImplCopyWithImpl<_$HealthNoticeImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            int id,
            String name,
            HealthNoticeSeverity severity,
            String shortMessage,
            DateTime createdAt,
            String? longMessage,
            DateTime? curedAt,
            String? deviceId,
            String? deviceName,
            String? roomName,
            String? deviceType)
        $default,
  ) {
    return $default(id, name, severity, shortMessage, createdAt, longMessage,
        curedAt, deviceId, deviceName, roomName, deviceType);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            int id,
            String name,
            HealthNoticeSeverity severity,
            String shortMessage,
            DateTime createdAt,
            String? longMessage,
            DateTime? curedAt,
            String? deviceId,
            String? deviceName,
            String? roomName,
            String? deviceType)?
        $default,
  ) {
    return $default?.call(id, name, severity, shortMessage, createdAt,
        longMessage, curedAt, deviceId, deviceName, roomName, deviceType);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            int id,
            String name,
            HealthNoticeSeverity severity,
            String shortMessage,
            DateTime createdAt,
            String? longMessage,
            DateTime? curedAt,
            String? deviceId,
            String? deviceName,
            String? roomName,
            String? deviceType)?
        $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(id, name, severity, shortMessage, createdAt, longMessage,
          curedAt, deviceId, deviceName, roomName, deviceType);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_HealthNotice value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_HealthNotice value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_HealthNotice value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _HealthNotice extends HealthNotice {
  const factory _HealthNotice(
      {required final int id,
      required final String name,
      required final HealthNoticeSeverity severity,
      required final String shortMessage,
      required final DateTime createdAt,
      final String? longMessage,
      final DateTime? curedAt,
      final String? deviceId,
      final String? deviceName,
      final String? roomName,
      final String? deviceType}) = _$HealthNoticeImpl;
  const _HealthNotice._() : super._();

  @override
  int get id;
  @override
  String get name;
  @override
  HealthNoticeSeverity get severity;
  @override
  String get shortMessage;
  @override
  DateTime get createdAt;
  @override
  String? get longMessage;
  @override
  DateTime? get curedAt;
  @override
  String? get deviceId;
  @override
  String? get deviceName;
  @override
  String? get roomName;
  @override
  String? get deviceType;
  @override
  @JsonKey(ignore: true)
  _$$HealthNoticeImplCopyWith<_$HealthNoticeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
