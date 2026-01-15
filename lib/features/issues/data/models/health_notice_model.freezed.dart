// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health_notice_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

HealthNoticeModel _$HealthNoticeModelFromJson(Map<String, dynamic> json) {
  return _HealthNoticeModel.fromJson(json);
}

/// @nodoc
mixin _$HealthNoticeModel {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get severity => throw _privateConstructorUsedError;
  @JsonKey(name: 'short_message')
  String get shortMessage => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'long_message')
  String? get longMessage => throw _privateConstructorUsedError;
  @JsonKey(name: 'cured_at')
  DateTime? get curedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'device_id')
  String? get deviceId => throw _privateConstructorUsedError;
  @JsonKey(name: 'device_name')
  String? get deviceName => throw _privateConstructorUsedError;
  @JsonKey(name: 'room_name')
  String? get roomName => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            int id,
            String name,
            String severity,
            @JsonKey(name: 'short_message') String shortMessage,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'long_message') String? longMessage,
            @JsonKey(name: 'cured_at') DateTime? curedAt,
            @JsonKey(name: 'device_id') String? deviceId,
            @JsonKey(name: 'device_name') String? deviceName,
            @JsonKey(name: 'room_name') String? roomName)
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            int id,
            String name,
            String severity,
            @JsonKey(name: 'short_message') String shortMessage,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'long_message') String? longMessage,
            @JsonKey(name: 'cured_at') DateTime? curedAt,
            @JsonKey(name: 'device_id') String? deviceId,
            @JsonKey(name: 'device_name') String? deviceName,
            @JsonKey(name: 'room_name') String? roomName)?
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            int id,
            String name,
            String severity,
            @JsonKey(name: 'short_message') String shortMessage,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'long_message') String? longMessage,
            @JsonKey(name: 'cured_at') DateTime? curedAt,
            @JsonKey(name: 'device_id') String? deviceId,
            @JsonKey(name: 'device_name') String? deviceName,
            @JsonKey(name: 'room_name') String? roomName)?
        $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_HealthNoticeModel value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_HealthNoticeModel value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_HealthNoticeModel value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HealthNoticeModelCopyWith<HealthNoticeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HealthNoticeModelCopyWith<$Res> {
  factory $HealthNoticeModelCopyWith(
          HealthNoticeModel value, $Res Function(HealthNoticeModel) then) =
      _$HealthNoticeModelCopyWithImpl<$Res, HealthNoticeModel>;
  @useResult
  $Res call(
      {int id,
      String name,
      String severity,
      @JsonKey(name: 'short_message') String shortMessage,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'long_message') String? longMessage,
      @JsonKey(name: 'cured_at') DateTime? curedAt,
      @JsonKey(name: 'device_id') String? deviceId,
      @JsonKey(name: 'device_name') String? deviceName,
      @JsonKey(name: 'room_name') String? roomName});
}

/// @nodoc
class _$HealthNoticeModelCopyWithImpl<$Res, $Val extends HealthNoticeModel>
    implements $HealthNoticeModelCopyWith<$Res> {
  _$HealthNoticeModelCopyWithImpl(this._value, this._then);

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
              as String,
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HealthNoticeModelImplCopyWith<$Res>
    implements $HealthNoticeModelCopyWith<$Res> {
  factory _$$HealthNoticeModelImplCopyWith(_$HealthNoticeModelImpl value,
          $Res Function(_$HealthNoticeModelImpl) then) =
      __$$HealthNoticeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String severity,
      @JsonKey(name: 'short_message') String shortMessage,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'long_message') String? longMessage,
      @JsonKey(name: 'cured_at') DateTime? curedAt,
      @JsonKey(name: 'device_id') String? deviceId,
      @JsonKey(name: 'device_name') String? deviceName,
      @JsonKey(name: 'room_name') String? roomName});
}

/// @nodoc
class __$$HealthNoticeModelImplCopyWithImpl<$Res>
    extends _$HealthNoticeModelCopyWithImpl<$Res, _$HealthNoticeModelImpl>
    implements _$$HealthNoticeModelImplCopyWith<$Res> {
  __$$HealthNoticeModelImplCopyWithImpl(_$HealthNoticeModelImpl _value,
      $Res Function(_$HealthNoticeModelImpl) _then)
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
  }) {
    return _then(_$HealthNoticeModelImpl(
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
              as String,
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HealthNoticeModelImpl implements _HealthNoticeModel {
  const _$HealthNoticeModelImpl(
      {required this.id,
      required this.name,
      required this.severity,
      @JsonKey(name: 'short_message') required this.shortMessage,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'long_message') this.longMessage,
      @JsonKey(name: 'cured_at') this.curedAt,
      @JsonKey(name: 'device_id') this.deviceId,
      @JsonKey(name: 'device_name') this.deviceName,
      @JsonKey(name: 'room_name') this.roomName});

  factory _$HealthNoticeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$HealthNoticeModelImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String severity;
  @override
  @JsonKey(name: 'short_message')
  final String shortMessage;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'long_message')
  final String? longMessage;
  @override
  @JsonKey(name: 'cured_at')
  final DateTime? curedAt;
  @override
  @JsonKey(name: 'device_id')
  final String? deviceId;
  @override
  @JsonKey(name: 'device_name')
  final String? deviceName;
  @override
  @JsonKey(name: 'room_name')
  final String? roomName;

  @override
  String toString() {
    return 'HealthNoticeModel(id: $id, name: $name, severity: $severity, shortMessage: $shortMessage, createdAt: $createdAt, longMessage: $longMessage, curedAt: $curedAt, deviceId: $deviceId, deviceName: $deviceName, roomName: $roomName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HealthNoticeModelImpl &&
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
                other.roomName == roomName));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, severity, shortMessage,
      createdAt, longMessage, curedAt, deviceId, deviceName, roomName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HealthNoticeModelImplCopyWith<_$HealthNoticeModelImpl> get copyWith =>
      __$$HealthNoticeModelImplCopyWithImpl<_$HealthNoticeModelImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            int id,
            String name,
            String severity,
            @JsonKey(name: 'short_message') String shortMessage,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'long_message') String? longMessage,
            @JsonKey(name: 'cured_at') DateTime? curedAt,
            @JsonKey(name: 'device_id') String? deviceId,
            @JsonKey(name: 'device_name') String? deviceName,
            @JsonKey(name: 'room_name') String? roomName)
        $default,
  ) {
    return $default(id, name, severity, shortMessage, createdAt, longMessage,
        curedAt, deviceId, deviceName, roomName);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            int id,
            String name,
            String severity,
            @JsonKey(name: 'short_message') String shortMessage,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'long_message') String? longMessage,
            @JsonKey(name: 'cured_at') DateTime? curedAt,
            @JsonKey(name: 'device_id') String? deviceId,
            @JsonKey(name: 'device_name') String? deviceName,
            @JsonKey(name: 'room_name') String? roomName)?
        $default,
  ) {
    return $default?.call(id, name, severity, shortMessage, createdAt,
        longMessage, curedAt, deviceId, deviceName, roomName);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            int id,
            String name,
            String severity,
            @JsonKey(name: 'short_message') String shortMessage,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'long_message') String? longMessage,
            @JsonKey(name: 'cured_at') DateTime? curedAt,
            @JsonKey(name: 'device_id') String? deviceId,
            @JsonKey(name: 'device_name') String? deviceName,
            @JsonKey(name: 'room_name') String? roomName)?
        $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(id, name, severity, shortMessage, createdAt, longMessage,
          curedAt, deviceId, deviceName, roomName);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_HealthNoticeModel value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_HealthNoticeModel value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_HealthNoticeModel value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$HealthNoticeModelImplToJson(
      this,
    );
  }
}

abstract class _HealthNoticeModel implements HealthNoticeModel {
  const factory _HealthNoticeModel(
          {required final int id,
          required final String name,
          required final String severity,
          @JsonKey(name: 'short_message') required final String shortMessage,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'long_message') final String? longMessage,
          @JsonKey(name: 'cured_at') final DateTime? curedAt,
          @JsonKey(name: 'device_id') final String? deviceId,
          @JsonKey(name: 'device_name') final String? deviceName,
          @JsonKey(name: 'room_name') final String? roomName}) =
      _$HealthNoticeModelImpl;

  factory _HealthNoticeModel.fromJson(Map<String, dynamic> json) =
      _$HealthNoticeModelImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get severity;
  @override
  @JsonKey(name: 'short_message')
  String get shortMessage;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'long_message')
  String? get longMessage;
  @override
  @JsonKey(name: 'cured_at')
  DateTime? get curedAt;
  @override
  @JsonKey(name: 'device_id')
  String? get deviceId;
  @override
  @JsonKey(name: 'device_name')
  String? get deviceName;
  @override
  @JsonKey(name: 'room_name')
  String? get roomName;
  @override
  @JsonKey(ignore: true)
  _$$HealthNoticeModelImplCopyWith<_$HealthNoticeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
