// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'websocket_events.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DeviceEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Device device) created,
    required TResult Function(Device device) updated,
    required TResult Function(String id) deleted,
    required TResult Function(
            String id, String status, bool? online, DateTime? lastSeen)
        statusChanged,
    required TResult Function(List<Device> devices) batchUpdate,
    required TResult Function(List<Device> devices) snapshot,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Device device)? created,
    TResult? Function(Device device)? updated,
    TResult? Function(String id)? deleted,
    TResult? Function(
            String id, String status, bool? online, DateTime? lastSeen)?
        statusChanged,
    TResult? Function(List<Device> devices)? batchUpdate,
    TResult? Function(List<Device> devices)? snapshot,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Device device)? created,
    TResult Function(Device device)? updated,
    TResult Function(String id)? deleted,
    TResult Function(
            String id, String status, bool? online, DateTime? lastSeen)?
        statusChanged,
    TResult Function(List<Device> devices)? batchUpdate,
    TResult Function(List<Device> devices)? snapshot,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DeviceCreated value) created,
    required TResult Function(DeviceUpdated value) updated,
    required TResult Function(DeviceDeleted value) deleted,
    required TResult Function(DeviceStatusChanged value) statusChanged,
    required TResult Function(DeviceBatchUpdate value) batchUpdate,
    required TResult Function(DeviceSnapshot value) snapshot,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DeviceCreated value)? created,
    TResult? Function(DeviceUpdated value)? updated,
    TResult? Function(DeviceDeleted value)? deleted,
    TResult? Function(DeviceStatusChanged value)? statusChanged,
    TResult? Function(DeviceBatchUpdate value)? batchUpdate,
    TResult? Function(DeviceSnapshot value)? snapshot,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DeviceCreated value)? created,
    TResult Function(DeviceUpdated value)? updated,
    TResult Function(DeviceDeleted value)? deleted,
    TResult Function(DeviceStatusChanged value)? statusChanged,
    TResult Function(DeviceBatchUpdate value)? batchUpdate,
    TResult Function(DeviceSnapshot value)? snapshot,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeviceEventCopyWith<$Res> {
  factory $DeviceEventCopyWith(
          DeviceEvent value, $Res Function(DeviceEvent) then) =
      _$DeviceEventCopyWithImpl<$Res, DeviceEvent>;
}

/// @nodoc
class _$DeviceEventCopyWithImpl<$Res, $Val extends DeviceEvent>
    implements $DeviceEventCopyWith<$Res> {
  _$DeviceEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$DeviceCreatedImplCopyWith<$Res> {
  factory _$$DeviceCreatedImplCopyWith(
          _$DeviceCreatedImpl value, $Res Function(_$DeviceCreatedImpl) then) =
      __$$DeviceCreatedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Device device});

  $DeviceCopyWith<$Res> get device;
}

/// @nodoc
class __$$DeviceCreatedImplCopyWithImpl<$Res>
    extends _$DeviceEventCopyWithImpl<$Res, _$DeviceCreatedImpl>
    implements _$$DeviceCreatedImplCopyWith<$Res> {
  __$$DeviceCreatedImplCopyWithImpl(
      _$DeviceCreatedImpl _value, $Res Function(_$DeviceCreatedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? device = null,
  }) {
    return _then(_$DeviceCreatedImpl(
      null == device
          ? _value.device
          : device // ignore: cast_nullable_to_non_nullable
              as Device,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $DeviceCopyWith<$Res> get device {
    return $DeviceCopyWith<$Res>(_value.device, (value) {
      return _then(_value.copyWith(device: value));
    });
  }
}

/// @nodoc

class _$DeviceCreatedImpl implements DeviceCreated {
  const _$DeviceCreatedImpl(this.device);

  @override
  final Device device;

  @override
  String toString() {
    return 'DeviceEvent.created(device: $device)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceCreatedImpl &&
            (identical(other.device, device) || other.device == device));
  }

  @override
  int get hashCode => Object.hash(runtimeType, device);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceCreatedImplCopyWith<_$DeviceCreatedImpl> get copyWith =>
      __$$DeviceCreatedImplCopyWithImpl<_$DeviceCreatedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Device device) created,
    required TResult Function(Device device) updated,
    required TResult Function(String id) deleted,
    required TResult Function(
            String id, String status, bool? online, DateTime? lastSeen)
        statusChanged,
    required TResult Function(List<Device> devices) batchUpdate,
    required TResult Function(List<Device> devices) snapshot,
  }) {
    return created(device);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Device device)? created,
    TResult? Function(Device device)? updated,
    TResult? Function(String id)? deleted,
    TResult? Function(
            String id, String status, bool? online, DateTime? lastSeen)?
        statusChanged,
    TResult? Function(List<Device> devices)? batchUpdate,
    TResult? Function(List<Device> devices)? snapshot,
  }) {
    return created?.call(device);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Device device)? created,
    TResult Function(Device device)? updated,
    TResult Function(String id)? deleted,
    TResult Function(
            String id, String status, bool? online, DateTime? lastSeen)?
        statusChanged,
    TResult Function(List<Device> devices)? batchUpdate,
    TResult Function(List<Device> devices)? snapshot,
    required TResult orElse(),
  }) {
    if (created != null) {
      return created(device);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DeviceCreated value) created,
    required TResult Function(DeviceUpdated value) updated,
    required TResult Function(DeviceDeleted value) deleted,
    required TResult Function(DeviceStatusChanged value) statusChanged,
    required TResult Function(DeviceBatchUpdate value) batchUpdate,
    required TResult Function(DeviceSnapshot value) snapshot,
  }) {
    return created(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DeviceCreated value)? created,
    TResult? Function(DeviceUpdated value)? updated,
    TResult? Function(DeviceDeleted value)? deleted,
    TResult? Function(DeviceStatusChanged value)? statusChanged,
    TResult? Function(DeviceBatchUpdate value)? batchUpdate,
    TResult? Function(DeviceSnapshot value)? snapshot,
  }) {
    return created?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DeviceCreated value)? created,
    TResult Function(DeviceUpdated value)? updated,
    TResult Function(DeviceDeleted value)? deleted,
    TResult Function(DeviceStatusChanged value)? statusChanged,
    TResult Function(DeviceBatchUpdate value)? batchUpdate,
    TResult Function(DeviceSnapshot value)? snapshot,
    required TResult orElse(),
  }) {
    if (created != null) {
      return created(this);
    }
    return orElse();
  }
}

abstract class DeviceCreated implements DeviceEvent {
  const factory DeviceCreated(final Device device) = _$DeviceCreatedImpl;

  Device get device;
  @JsonKey(ignore: true)
  _$$DeviceCreatedImplCopyWith<_$DeviceCreatedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DeviceUpdatedImplCopyWith<$Res> {
  factory _$$DeviceUpdatedImplCopyWith(
          _$DeviceUpdatedImpl value, $Res Function(_$DeviceUpdatedImpl) then) =
      __$$DeviceUpdatedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Device device});

  $DeviceCopyWith<$Res> get device;
}

/// @nodoc
class __$$DeviceUpdatedImplCopyWithImpl<$Res>
    extends _$DeviceEventCopyWithImpl<$Res, _$DeviceUpdatedImpl>
    implements _$$DeviceUpdatedImplCopyWith<$Res> {
  __$$DeviceUpdatedImplCopyWithImpl(
      _$DeviceUpdatedImpl _value, $Res Function(_$DeviceUpdatedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? device = null,
  }) {
    return _then(_$DeviceUpdatedImpl(
      null == device
          ? _value.device
          : device // ignore: cast_nullable_to_non_nullable
              as Device,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $DeviceCopyWith<$Res> get device {
    return $DeviceCopyWith<$Res>(_value.device, (value) {
      return _then(_value.copyWith(device: value));
    });
  }
}

/// @nodoc

class _$DeviceUpdatedImpl implements DeviceUpdated {
  const _$DeviceUpdatedImpl(this.device);

  @override
  final Device device;

  @override
  String toString() {
    return 'DeviceEvent.updated(device: $device)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceUpdatedImpl &&
            (identical(other.device, device) || other.device == device));
  }

  @override
  int get hashCode => Object.hash(runtimeType, device);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceUpdatedImplCopyWith<_$DeviceUpdatedImpl> get copyWith =>
      __$$DeviceUpdatedImplCopyWithImpl<_$DeviceUpdatedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Device device) created,
    required TResult Function(Device device) updated,
    required TResult Function(String id) deleted,
    required TResult Function(
            String id, String status, bool? online, DateTime? lastSeen)
        statusChanged,
    required TResult Function(List<Device> devices) batchUpdate,
    required TResult Function(List<Device> devices) snapshot,
  }) {
    return updated(device);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Device device)? created,
    TResult? Function(Device device)? updated,
    TResult? Function(String id)? deleted,
    TResult? Function(
            String id, String status, bool? online, DateTime? lastSeen)?
        statusChanged,
    TResult? Function(List<Device> devices)? batchUpdate,
    TResult? Function(List<Device> devices)? snapshot,
  }) {
    return updated?.call(device);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Device device)? created,
    TResult Function(Device device)? updated,
    TResult Function(String id)? deleted,
    TResult Function(
            String id, String status, bool? online, DateTime? lastSeen)?
        statusChanged,
    TResult Function(List<Device> devices)? batchUpdate,
    TResult Function(List<Device> devices)? snapshot,
    required TResult orElse(),
  }) {
    if (updated != null) {
      return updated(device);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DeviceCreated value) created,
    required TResult Function(DeviceUpdated value) updated,
    required TResult Function(DeviceDeleted value) deleted,
    required TResult Function(DeviceStatusChanged value) statusChanged,
    required TResult Function(DeviceBatchUpdate value) batchUpdate,
    required TResult Function(DeviceSnapshot value) snapshot,
  }) {
    return updated(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DeviceCreated value)? created,
    TResult? Function(DeviceUpdated value)? updated,
    TResult? Function(DeviceDeleted value)? deleted,
    TResult? Function(DeviceStatusChanged value)? statusChanged,
    TResult? Function(DeviceBatchUpdate value)? batchUpdate,
    TResult? Function(DeviceSnapshot value)? snapshot,
  }) {
    return updated?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DeviceCreated value)? created,
    TResult Function(DeviceUpdated value)? updated,
    TResult Function(DeviceDeleted value)? deleted,
    TResult Function(DeviceStatusChanged value)? statusChanged,
    TResult Function(DeviceBatchUpdate value)? batchUpdate,
    TResult Function(DeviceSnapshot value)? snapshot,
    required TResult orElse(),
  }) {
    if (updated != null) {
      return updated(this);
    }
    return orElse();
  }
}

abstract class DeviceUpdated implements DeviceEvent {
  const factory DeviceUpdated(final Device device) = _$DeviceUpdatedImpl;

  Device get device;
  @JsonKey(ignore: true)
  _$$DeviceUpdatedImplCopyWith<_$DeviceUpdatedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DeviceDeletedImplCopyWith<$Res> {
  factory _$$DeviceDeletedImplCopyWith(
          _$DeviceDeletedImpl value, $Res Function(_$DeviceDeletedImpl) then) =
      __$$DeviceDeletedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String id});
}

/// @nodoc
class __$$DeviceDeletedImplCopyWithImpl<$Res>
    extends _$DeviceEventCopyWithImpl<$Res, _$DeviceDeletedImpl>
    implements _$$DeviceDeletedImplCopyWith<$Res> {
  __$$DeviceDeletedImplCopyWithImpl(
      _$DeviceDeletedImpl _value, $Res Function(_$DeviceDeletedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_$DeviceDeletedImpl(
      null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$DeviceDeletedImpl implements DeviceDeleted {
  const _$DeviceDeletedImpl(this.id);

  @override
  final String id;

  @override
  String toString() {
    return 'DeviceEvent.deleted(id: $id)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceDeletedImpl &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceDeletedImplCopyWith<_$DeviceDeletedImpl> get copyWith =>
      __$$DeviceDeletedImplCopyWithImpl<_$DeviceDeletedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Device device) created,
    required TResult Function(Device device) updated,
    required TResult Function(String id) deleted,
    required TResult Function(
            String id, String status, bool? online, DateTime? lastSeen)
        statusChanged,
    required TResult Function(List<Device> devices) batchUpdate,
    required TResult Function(List<Device> devices) snapshot,
  }) {
    return deleted(id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Device device)? created,
    TResult? Function(Device device)? updated,
    TResult? Function(String id)? deleted,
    TResult? Function(
            String id, String status, bool? online, DateTime? lastSeen)?
        statusChanged,
    TResult? Function(List<Device> devices)? batchUpdate,
    TResult? Function(List<Device> devices)? snapshot,
  }) {
    return deleted?.call(id);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Device device)? created,
    TResult Function(Device device)? updated,
    TResult Function(String id)? deleted,
    TResult Function(
            String id, String status, bool? online, DateTime? lastSeen)?
        statusChanged,
    TResult Function(List<Device> devices)? batchUpdate,
    TResult Function(List<Device> devices)? snapshot,
    required TResult orElse(),
  }) {
    if (deleted != null) {
      return deleted(id);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DeviceCreated value) created,
    required TResult Function(DeviceUpdated value) updated,
    required TResult Function(DeviceDeleted value) deleted,
    required TResult Function(DeviceStatusChanged value) statusChanged,
    required TResult Function(DeviceBatchUpdate value) batchUpdate,
    required TResult Function(DeviceSnapshot value) snapshot,
  }) {
    return deleted(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DeviceCreated value)? created,
    TResult? Function(DeviceUpdated value)? updated,
    TResult? Function(DeviceDeleted value)? deleted,
    TResult? Function(DeviceStatusChanged value)? statusChanged,
    TResult? Function(DeviceBatchUpdate value)? batchUpdate,
    TResult? Function(DeviceSnapshot value)? snapshot,
  }) {
    return deleted?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DeviceCreated value)? created,
    TResult Function(DeviceUpdated value)? updated,
    TResult Function(DeviceDeleted value)? deleted,
    TResult Function(DeviceStatusChanged value)? statusChanged,
    TResult Function(DeviceBatchUpdate value)? batchUpdate,
    TResult Function(DeviceSnapshot value)? snapshot,
    required TResult orElse(),
  }) {
    if (deleted != null) {
      return deleted(this);
    }
    return orElse();
  }
}

abstract class DeviceDeleted implements DeviceEvent {
  const factory DeviceDeleted(final String id) = _$DeviceDeletedImpl;

  String get id;
  @JsonKey(ignore: true)
  _$$DeviceDeletedImplCopyWith<_$DeviceDeletedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DeviceStatusChangedImplCopyWith<$Res> {
  factory _$$DeviceStatusChangedImplCopyWith(_$DeviceStatusChangedImpl value,
          $Res Function(_$DeviceStatusChangedImpl) then) =
      __$$DeviceStatusChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String id, String status, bool? online, DateTime? lastSeen});
}

/// @nodoc
class __$$DeviceStatusChangedImplCopyWithImpl<$Res>
    extends _$DeviceEventCopyWithImpl<$Res, _$DeviceStatusChangedImpl>
    implements _$$DeviceStatusChangedImplCopyWith<$Res> {
  __$$DeviceStatusChangedImplCopyWithImpl(_$DeviceStatusChangedImpl _value,
      $Res Function(_$DeviceStatusChangedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? online = freezed,
    Object? lastSeen = freezed,
  }) {
    return _then(_$DeviceStatusChangedImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      online: freezed == online
          ? _value.online
          : online // ignore: cast_nullable_to_non_nullable
              as bool?,
      lastSeen: freezed == lastSeen
          ? _value.lastSeen
          : lastSeen // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$DeviceStatusChangedImpl implements DeviceStatusChanged {
  const _$DeviceStatusChangedImpl(
      {required this.id, required this.status, this.online, this.lastSeen});

  @override
  final String id;
  @override
  final String status;
  @override
  final bool? online;
  @override
  final DateTime? lastSeen;

  @override
  String toString() {
    return 'DeviceEvent.statusChanged(id: $id, status: $status, online: $online, lastSeen: $lastSeen)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceStatusChangedImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.online, online) || other.online == online) &&
            (identical(other.lastSeen, lastSeen) ||
                other.lastSeen == lastSeen));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, status, online, lastSeen);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceStatusChangedImplCopyWith<_$DeviceStatusChangedImpl> get copyWith =>
      __$$DeviceStatusChangedImplCopyWithImpl<_$DeviceStatusChangedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Device device) created,
    required TResult Function(Device device) updated,
    required TResult Function(String id) deleted,
    required TResult Function(
            String id, String status, bool? online, DateTime? lastSeen)
        statusChanged,
    required TResult Function(List<Device> devices) batchUpdate,
    required TResult Function(List<Device> devices) snapshot,
  }) {
    return statusChanged(id, status, online, lastSeen);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Device device)? created,
    TResult? Function(Device device)? updated,
    TResult? Function(String id)? deleted,
    TResult? Function(
            String id, String status, bool? online, DateTime? lastSeen)?
        statusChanged,
    TResult? Function(List<Device> devices)? batchUpdate,
    TResult? Function(List<Device> devices)? snapshot,
  }) {
    return statusChanged?.call(id, status, online, lastSeen);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Device device)? created,
    TResult Function(Device device)? updated,
    TResult Function(String id)? deleted,
    TResult Function(
            String id, String status, bool? online, DateTime? lastSeen)?
        statusChanged,
    TResult Function(List<Device> devices)? batchUpdate,
    TResult Function(List<Device> devices)? snapshot,
    required TResult orElse(),
  }) {
    if (statusChanged != null) {
      return statusChanged(id, status, online, lastSeen);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DeviceCreated value) created,
    required TResult Function(DeviceUpdated value) updated,
    required TResult Function(DeviceDeleted value) deleted,
    required TResult Function(DeviceStatusChanged value) statusChanged,
    required TResult Function(DeviceBatchUpdate value) batchUpdate,
    required TResult Function(DeviceSnapshot value) snapshot,
  }) {
    return statusChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DeviceCreated value)? created,
    TResult? Function(DeviceUpdated value)? updated,
    TResult? Function(DeviceDeleted value)? deleted,
    TResult? Function(DeviceStatusChanged value)? statusChanged,
    TResult? Function(DeviceBatchUpdate value)? batchUpdate,
    TResult? Function(DeviceSnapshot value)? snapshot,
  }) {
    return statusChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DeviceCreated value)? created,
    TResult Function(DeviceUpdated value)? updated,
    TResult Function(DeviceDeleted value)? deleted,
    TResult Function(DeviceStatusChanged value)? statusChanged,
    TResult Function(DeviceBatchUpdate value)? batchUpdate,
    TResult Function(DeviceSnapshot value)? snapshot,
    required TResult orElse(),
  }) {
    if (statusChanged != null) {
      return statusChanged(this);
    }
    return orElse();
  }
}

abstract class DeviceStatusChanged implements DeviceEvent {
  const factory DeviceStatusChanged(
      {required final String id,
      required final String status,
      final bool? online,
      final DateTime? lastSeen}) = _$DeviceStatusChangedImpl;

  String get id;
  String get status;
  bool? get online;
  DateTime? get lastSeen;
  @JsonKey(ignore: true)
  _$$DeviceStatusChangedImplCopyWith<_$DeviceStatusChangedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DeviceBatchUpdateImplCopyWith<$Res> {
  factory _$$DeviceBatchUpdateImplCopyWith(_$DeviceBatchUpdateImpl value,
          $Res Function(_$DeviceBatchUpdateImpl) then) =
      __$$DeviceBatchUpdateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<Device> devices});
}

/// @nodoc
class __$$DeviceBatchUpdateImplCopyWithImpl<$Res>
    extends _$DeviceEventCopyWithImpl<$Res, _$DeviceBatchUpdateImpl>
    implements _$$DeviceBatchUpdateImplCopyWith<$Res> {
  __$$DeviceBatchUpdateImplCopyWithImpl(_$DeviceBatchUpdateImpl _value,
      $Res Function(_$DeviceBatchUpdateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? devices = null,
  }) {
    return _then(_$DeviceBatchUpdateImpl(
      null == devices
          ? _value._devices
          : devices // ignore: cast_nullable_to_non_nullable
              as List<Device>,
    ));
  }
}

/// @nodoc

class _$DeviceBatchUpdateImpl implements DeviceBatchUpdate {
  const _$DeviceBatchUpdateImpl(final List<Device> devices)
      : _devices = devices;

  final List<Device> _devices;
  @override
  List<Device> get devices {
    if (_devices is EqualUnmodifiableListView) return _devices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_devices);
  }

  @override
  String toString() {
    return 'DeviceEvent.batchUpdate(devices: $devices)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceBatchUpdateImpl &&
            const DeepCollectionEquality().equals(other._devices, _devices));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_devices));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceBatchUpdateImplCopyWith<_$DeviceBatchUpdateImpl> get copyWith =>
      __$$DeviceBatchUpdateImplCopyWithImpl<_$DeviceBatchUpdateImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Device device) created,
    required TResult Function(Device device) updated,
    required TResult Function(String id) deleted,
    required TResult Function(
            String id, String status, bool? online, DateTime? lastSeen)
        statusChanged,
    required TResult Function(List<Device> devices) batchUpdate,
    required TResult Function(List<Device> devices) snapshot,
  }) {
    return batchUpdate(devices);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Device device)? created,
    TResult? Function(Device device)? updated,
    TResult? Function(String id)? deleted,
    TResult? Function(
            String id, String status, bool? online, DateTime? lastSeen)?
        statusChanged,
    TResult? Function(List<Device> devices)? batchUpdate,
    TResult? Function(List<Device> devices)? snapshot,
  }) {
    return batchUpdate?.call(devices);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Device device)? created,
    TResult Function(Device device)? updated,
    TResult Function(String id)? deleted,
    TResult Function(
            String id, String status, bool? online, DateTime? lastSeen)?
        statusChanged,
    TResult Function(List<Device> devices)? batchUpdate,
    TResult Function(List<Device> devices)? snapshot,
    required TResult orElse(),
  }) {
    if (batchUpdate != null) {
      return batchUpdate(devices);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DeviceCreated value) created,
    required TResult Function(DeviceUpdated value) updated,
    required TResult Function(DeviceDeleted value) deleted,
    required TResult Function(DeviceStatusChanged value) statusChanged,
    required TResult Function(DeviceBatchUpdate value) batchUpdate,
    required TResult Function(DeviceSnapshot value) snapshot,
  }) {
    return batchUpdate(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DeviceCreated value)? created,
    TResult? Function(DeviceUpdated value)? updated,
    TResult? Function(DeviceDeleted value)? deleted,
    TResult? Function(DeviceStatusChanged value)? statusChanged,
    TResult? Function(DeviceBatchUpdate value)? batchUpdate,
    TResult? Function(DeviceSnapshot value)? snapshot,
  }) {
    return batchUpdate?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DeviceCreated value)? created,
    TResult Function(DeviceUpdated value)? updated,
    TResult Function(DeviceDeleted value)? deleted,
    TResult Function(DeviceStatusChanged value)? statusChanged,
    TResult Function(DeviceBatchUpdate value)? batchUpdate,
    TResult Function(DeviceSnapshot value)? snapshot,
    required TResult orElse(),
  }) {
    if (batchUpdate != null) {
      return batchUpdate(this);
    }
    return orElse();
  }
}

abstract class DeviceBatchUpdate implements DeviceEvent {
  const factory DeviceBatchUpdate(final List<Device> devices) =
      _$DeviceBatchUpdateImpl;

  List<Device> get devices;
  @JsonKey(ignore: true)
  _$$DeviceBatchUpdateImplCopyWith<_$DeviceBatchUpdateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DeviceSnapshotImplCopyWith<$Res> {
  factory _$$DeviceSnapshotImplCopyWith(_$DeviceSnapshotImpl value,
          $Res Function(_$DeviceSnapshotImpl) then) =
      __$$DeviceSnapshotImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<Device> devices});
}

/// @nodoc
class __$$DeviceSnapshotImplCopyWithImpl<$Res>
    extends _$DeviceEventCopyWithImpl<$Res, _$DeviceSnapshotImpl>
    implements _$$DeviceSnapshotImplCopyWith<$Res> {
  __$$DeviceSnapshotImplCopyWithImpl(
      _$DeviceSnapshotImpl _value, $Res Function(_$DeviceSnapshotImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? devices = null,
  }) {
    return _then(_$DeviceSnapshotImpl(
      null == devices
          ? _value._devices
          : devices // ignore: cast_nullable_to_non_nullable
              as List<Device>,
    ));
  }
}

/// @nodoc

class _$DeviceSnapshotImpl implements DeviceSnapshot {
  const _$DeviceSnapshotImpl(final List<Device> devices) : _devices = devices;

  final List<Device> _devices;
  @override
  List<Device> get devices {
    if (_devices is EqualUnmodifiableListView) return _devices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_devices);
  }

  @override
  String toString() {
    return 'DeviceEvent.snapshot(devices: $devices)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceSnapshotImpl &&
            const DeepCollectionEquality().equals(other._devices, _devices));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_devices));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceSnapshotImplCopyWith<_$DeviceSnapshotImpl> get copyWith =>
      __$$DeviceSnapshotImplCopyWithImpl<_$DeviceSnapshotImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Device device) created,
    required TResult Function(Device device) updated,
    required TResult Function(String id) deleted,
    required TResult Function(
            String id, String status, bool? online, DateTime? lastSeen)
        statusChanged,
    required TResult Function(List<Device> devices) batchUpdate,
    required TResult Function(List<Device> devices) snapshot,
  }) {
    return snapshot(devices);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Device device)? created,
    TResult? Function(Device device)? updated,
    TResult? Function(String id)? deleted,
    TResult? Function(
            String id, String status, bool? online, DateTime? lastSeen)?
        statusChanged,
    TResult? Function(List<Device> devices)? batchUpdate,
    TResult? Function(List<Device> devices)? snapshot,
  }) {
    return snapshot?.call(devices);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Device device)? created,
    TResult Function(Device device)? updated,
    TResult Function(String id)? deleted,
    TResult Function(
            String id, String status, bool? online, DateTime? lastSeen)?
        statusChanged,
    TResult Function(List<Device> devices)? batchUpdate,
    TResult Function(List<Device> devices)? snapshot,
    required TResult orElse(),
  }) {
    if (snapshot != null) {
      return snapshot(devices);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DeviceCreated value) created,
    required TResult Function(DeviceUpdated value) updated,
    required TResult Function(DeviceDeleted value) deleted,
    required TResult Function(DeviceStatusChanged value) statusChanged,
    required TResult Function(DeviceBatchUpdate value) batchUpdate,
    required TResult Function(DeviceSnapshot value) snapshot,
  }) {
    return snapshot(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DeviceCreated value)? created,
    TResult? Function(DeviceUpdated value)? updated,
    TResult? Function(DeviceDeleted value)? deleted,
    TResult? Function(DeviceStatusChanged value)? statusChanged,
    TResult? Function(DeviceBatchUpdate value)? batchUpdate,
    TResult? Function(DeviceSnapshot value)? snapshot,
  }) {
    return snapshot?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DeviceCreated value)? created,
    TResult Function(DeviceUpdated value)? updated,
    TResult Function(DeviceDeleted value)? deleted,
    TResult Function(DeviceStatusChanged value)? statusChanged,
    TResult Function(DeviceBatchUpdate value)? batchUpdate,
    TResult Function(DeviceSnapshot value)? snapshot,
    required TResult orElse(),
  }) {
    if (snapshot != null) {
      return snapshot(this);
    }
    return orElse();
  }
}

abstract class DeviceSnapshot implements DeviceEvent {
  const factory DeviceSnapshot(final List<Device> devices) =
      _$DeviceSnapshotImpl;

  List<Device> get devices;
  @JsonKey(ignore: true)
  _$$DeviceSnapshotImplCopyWith<_$DeviceSnapshotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RoomEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Room room) created,
    required TResult Function(Room room) updated,
    required TResult Function(String id) deleted,
    required TResult Function(List<Room> rooms) batchUpdate,
    required TResult Function(List<Room> rooms) snapshot,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Room room)? created,
    TResult? Function(Room room)? updated,
    TResult? Function(String id)? deleted,
    TResult? Function(List<Room> rooms)? batchUpdate,
    TResult? Function(List<Room> rooms)? snapshot,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Room room)? created,
    TResult Function(Room room)? updated,
    TResult Function(String id)? deleted,
    TResult Function(List<Room> rooms)? batchUpdate,
    TResult Function(List<Room> rooms)? snapshot,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RoomCreated value) created,
    required TResult Function(RoomUpdated value) updated,
    required TResult Function(RoomDeleted value) deleted,
    required TResult Function(RoomBatchUpdate value) batchUpdate,
    required TResult Function(RoomSnapshot value) snapshot,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RoomCreated value)? created,
    TResult? Function(RoomUpdated value)? updated,
    TResult? Function(RoomDeleted value)? deleted,
    TResult? Function(RoomBatchUpdate value)? batchUpdate,
    TResult? Function(RoomSnapshot value)? snapshot,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RoomCreated value)? created,
    TResult Function(RoomUpdated value)? updated,
    TResult Function(RoomDeleted value)? deleted,
    TResult Function(RoomBatchUpdate value)? batchUpdate,
    TResult Function(RoomSnapshot value)? snapshot,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoomEventCopyWith<$Res> {
  factory $RoomEventCopyWith(RoomEvent value, $Res Function(RoomEvent) then) =
      _$RoomEventCopyWithImpl<$Res, RoomEvent>;
}

/// @nodoc
class _$RoomEventCopyWithImpl<$Res, $Val extends RoomEvent>
    implements $RoomEventCopyWith<$Res> {
  _$RoomEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$RoomCreatedImplCopyWith<$Res> {
  factory _$$RoomCreatedImplCopyWith(
          _$RoomCreatedImpl value, $Res Function(_$RoomCreatedImpl) then) =
      __$$RoomCreatedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Room room});
}

/// @nodoc
class __$$RoomCreatedImplCopyWithImpl<$Res>
    extends _$RoomEventCopyWithImpl<$Res, _$RoomCreatedImpl>
    implements _$$RoomCreatedImplCopyWith<$Res> {
  __$$RoomCreatedImplCopyWithImpl(
      _$RoomCreatedImpl _value, $Res Function(_$RoomCreatedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? room = freezed,
  }) {
    return _then(_$RoomCreatedImpl(
      freezed == room
          ? _value.room
          : room // ignore: cast_nullable_to_non_nullable
              as Room,
    ));
  }
}

/// @nodoc

class _$RoomCreatedImpl implements RoomCreated {
  const _$RoomCreatedImpl(this.room);

  @override
  final Room room;

  @override
  String toString() {
    return 'RoomEvent.created(room: $room)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoomCreatedImpl &&
            const DeepCollectionEquality().equals(other.room, room));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(room));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RoomCreatedImplCopyWith<_$RoomCreatedImpl> get copyWith =>
      __$$RoomCreatedImplCopyWithImpl<_$RoomCreatedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Room room) created,
    required TResult Function(Room room) updated,
    required TResult Function(String id) deleted,
    required TResult Function(List<Room> rooms) batchUpdate,
    required TResult Function(List<Room> rooms) snapshot,
  }) {
    return created(room);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Room room)? created,
    TResult? Function(Room room)? updated,
    TResult? Function(String id)? deleted,
    TResult? Function(List<Room> rooms)? batchUpdate,
    TResult? Function(List<Room> rooms)? snapshot,
  }) {
    return created?.call(room);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Room room)? created,
    TResult Function(Room room)? updated,
    TResult Function(String id)? deleted,
    TResult Function(List<Room> rooms)? batchUpdate,
    TResult Function(List<Room> rooms)? snapshot,
    required TResult orElse(),
  }) {
    if (created != null) {
      return created(room);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RoomCreated value) created,
    required TResult Function(RoomUpdated value) updated,
    required TResult Function(RoomDeleted value) deleted,
    required TResult Function(RoomBatchUpdate value) batchUpdate,
    required TResult Function(RoomSnapshot value) snapshot,
  }) {
    return created(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RoomCreated value)? created,
    TResult? Function(RoomUpdated value)? updated,
    TResult? Function(RoomDeleted value)? deleted,
    TResult? Function(RoomBatchUpdate value)? batchUpdate,
    TResult? Function(RoomSnapshot value)? snapshot,
  }) {
    return created?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RoomCreated value)? created,
    TResult Function(RoomUpdated value)? updated,
    TResult Function(RoomDeleted value)? deleted,
    TResult Function(RoomBatchUpdate value)? batchUpdate,
    TResult Function(RoomSnapshot value)? snapshot,
    required TResult orElse(),
  }) {
    if (created != null) {
      return created(this);
    }
    return orElse();
  }
}

abstract class RoomCreated implements RoomEvent {
  const factory RoomCreated(final Room room) = _$RoomCreatedImpl;

  Room get room;
  @JsonKey(ignore: true)
  _$$RoomCreatedImplCopyWith<_$RoomCreatedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RoomUpdatedImplCopyWith<$Res> {
  factory _$$RoomUpdatedImplCopyWith(
          _$RoomUpdatedImpl value, $Res Function(_$RoomUpdatedImpl) then) =
      __$$RoomUpdatedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Room room});
}

/// @nodoc
class __$$RoomUpdatedImplCopyWithImpl<$Res>
    extends _$RoomEventCopyWithImpl<$Res, _$RoomUpdatedImpl>
    implements _$$RoomUpdatedImplCopyWith<$Res> {
  __$$RoomUpdatedImplCopyWithImpl(
      _$RoomUpdatedImpl _value, $Res Function(_$RoomUpdatedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? room = freezed,
  }) {
    return _then(_$RoomUpdatedImpl(
      freezed == room
          ? _value.room
          : room // ignore: cast_nullable_to_non_nullable
              as Room,
    ));
  }
}

/// @nodoc

class _$RoomUpdatedImpl implements RoomUpdated {
  const _$RoomUpdatedImpl(this.room);

  @override
  final Room room;

  @override
  String toString() {
    return 'RoomEvent.updated(room: $room)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoomUpdatedImpl &&
            const DeepCollectionEquality().equals(other.room, room));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(room));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RoomUpdatedImplCopyWith<_$RoomUpdatedImpl> get copyWith =>
      __$$RoomUpdatedImplCopyWithImpl<_$RoomUpdatedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Room room) created,
    required TResult Function(Room room) updated,
    required TResult Function(String id) deleted,
    required TResult Function(List<Room> rooms) batchUpdate,
    required TResult Function(List<Room> rooms) snapshot,
  }) {
    return updated(room);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Room room)? created,
    TResult? Function(Room room)? updated,
    TResult? Function(String id)? deleted,
    TResult? Function(List<Room> rooms)? batchUpdate,
    TResult? Function(List<Room> rooms)? snapshot,
  }) {
    return updated?.call(room);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Room room)? created,
    TResult Function(Room room)? updated,
    TResult Function(String id)? deleted,
    TResult Function(List<Room> rooms)? batchUpdate,
    TResult Function(List<Room> rooms)? snapshot,
    required TResult orElse(),
  }) {
    if (updated != null) {
      return updated(room);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RoomCreated value) created,
    required TResult Function(RoomUpdated value) updated,
    required TResult Function(RoomDeleted value) deleted,
    required TResult Function(RoomBatchUpdate value) batchUpdate,
    required TResult Function(RoomSnapshot value) snapshot,
  }) {
    return updated(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RoomCreated value)? created,
    TResult? Function(RoomUpdated value)? updated,
    TResult? Function(RoomDeleted value)? deleted,
    TResult? Function(RoomBatchUpdate value)? batchUpdate,
    TResult? Function(RoomSnapshot value)? snapshot,
  }) {
    return updated?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RoomCreated value)? created,
    TResult Function(RoomUpdated value)? updated,
    TResult Function(RoomDeleted value)? deleted,
    TResult Function(RoomBatchUpdate value)? batchUpdate,
    TResult Function(RoomSnapshot value)? snapshot,
    required TResult orElse(),
  }) {
    if (updated != null) {
      return updated(this);
    }
    return orElse();
  }
}

abstract class RoomUpdated implements RoomEvent {
  const factory RoomUpdated(final Room room) = _$RoomUpdatedImpl;

  Room get room;
  @JsonKey(ignore: true)
  _$$RoomUpdatedImplCopyWith<_$RoomUpdatedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RoomDeletedImplCopyWith<$Res> {
  factory _$$RoomDeletedImplCopyWith(
          _$RoomDeletedImpl value, $Res Function(_$RoomDeletedImpl) then) =
      __$$RoomDeletedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String id});
}

/// @nodoc
class __$$RoomDeletedImplCopyWithImpl<$Res>
    extends _$RoomEventCopyWithImpl<$Res, _$RoomDeletedImpl>
    implements _$$RoomDeletedImplCopyWith<$Res> {
  __$$RoomDeletedImplCopyWithImpl(
      _$RoomDeletedImpl _value, $Res Function(_$RoomDeletedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_$RoomDeletedImpl(
      null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$RoomDeletedImpl implements RoomDeleted {
  const _$RoomDeletedImpl(this.id);

  @override
  final String id;

  @override
  String toString() {
    return 'RoomEvent.deleted(id: $id)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoomDeletedImpl &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RoomDeletedImplCopyWith<_$RoomDeletedImpl> get copyWith =>
      __$$RoomDeletedImplCopyWithImpl<_$RoomDeletedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Room room) created,
    required TResult Function(Room room) updated,
    required TResult Function(String id) deleted,
    required TResult Function(List<Room> rooms) batchUpdate,
    required TResult Function(List<Room> rooms) snapshot,
  }) {
    return deleted(id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Room room)? created,
    TResult? Function(Room room)? updated,
    TResult? Function(String id)? deleted,
    TResult? Function(List<Room> rooms)? batchUpdate,
    TResult? Function(List<Room> rooms)? snapshot,
  }) {
    return deleted?.call(id);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Room room)? created,
    TResult Function(Room room)? updated,
    TResult Function(String id)? deleted,
    TResult Function(List<Room> rooms)? batchUpdate,
    TResult Function(List<Room> rooms)? snapshot,
    required TResult orElse(),
  }) {
    if (deleted != null) {
      return deleted(id);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RoomCreated value) created,
    required TResult Function(RoomUpdated value) updated,
    required TResult Function(RoomDeleted value) deleted,
    required TResult Function(RoomBatchUpdate value) batchUpdate,
    required TResult Function(RoomSnapshot value) snapshot,
  }) {
    return deleted(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RoomCreated value)? created,
    TResult? Function(RoomUpdated value)? updated,
    TResult? Function(RoomDeleted value)? deleted,
    TResult? Function(RoomBatchUpdate value)? batchUpdate,
    TResult? Function(RoomSnapshot value)? snapshot,
  }) {
    return deleted?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RoomCreated value)? created,
    TResult Function(RoomUpdated value)? updated,
    TResult Function(RoomDeleted value)? deleted,
    TResult Function(RoomBatchUpdate value)? batchUpdate,
    TResult Function(RoomSnapshot value)? snapshot,
    required TResult orElse(),
  }) {
    if (deleted != null) {
      return deleted(this);
    }
    return orElse();
  }
}

abstract class RoomDeleted implements RoomEvent {
  const factory RoomDeleted(final String id) = _$RoomDeletedImpl;

  String get id;
  @JsonKey(ignore: true)
  _$$RoomDeletedImplCopyWith<_$RoomDeletedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RoomBatchUpdateImplCopyWith<$Res> {
  factory _$$RoomBatchUpdateImplCopyWith(_$RoomBatchUpdateImpl value,
          $Res Function(_$RoomBatchUpdateImpl) then) =
      __$$RoomBatchUpdateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<Room> rooms});
}

/// @nodoc
class __$$RoomBatchUpdateImplCopyWithImpl<$Res>
    extends _$RoomEventCopyWithImpl<$Res, _$RoomBatchUpdateImpl>
    implements _$$RoomBatchUpdateImplCopyWith<$Res> {
  __$$RoomBatchUpdateImplCopyWithImpl(
      _$RoomBatchUpdateImpl _value, $Res Function(_$RoomBatchUpdateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rooms = null,
  }) {
    return _then(_$RoomBatchUpdateImpl(
      null == rooms
          ? _value._rooms
          : rooms // ignore: cast_nullable_to_non_nullable
              as List<Room>,
    ));
  }
}

/// @nodoc

class _$RoomBatchUpdateImpl implements RoomBatchUpdate {
  const _$RoomBatchUpdateImpl(final List<Room> rooms) : _rooms = rooms;

  final List<Room> _rooms;
  @override
  List<Room> get rooms {
    if (_rooms is EqualUnmodifiableListView) return _rooms;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rooms);
  }

  @override
  String toString() {
    return 'RoomEvent.batchUpdate(rooms: $rooms)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoomBatchUpdateImpl &&
            const DeepCollectionEquality().equals(other._rooms, _rooms));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_rooms));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RoomBatchUpdateImplCopyWith<_$RoomBatchUpdateImpl> get copyWith =>
      __$$RoomBatchUpdateImplCopyWithImpl<_$RoomBatchUpdateImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Room room) created,
    required TResult Function(Room room) updated,
    required TResult Function(String id) deleted,
    required TResult Function(List<Room> rooms) batchUpdate,
    required TResult Function(List<Room> rooms) snapshot,
  }) {
    return batchUpdate(rooms);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Room room)? created,
    TResult? Function(Room room)? updated,
    TResult? Function(String id)? deleted,
    TResult? Function(List<Room> rooms)? batchUpdate,
    TResult? Function(List<Room> rooms)? snapshot,
  }) {
    return batchUpdate?.call(rooms);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Room room)? created,
    TResult Function(Room room)? updated,
    TResult Function(String id)? deleted,
    TResult Function(List<Room> rooms)? batchUpdate,
    TResult Function(List<Room> rooms)? snapshot,
    required TResult orElse(),
  }) {
    if (batchUpdate != null) {
      return batchUpdate(rooms);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RoomCreated value) created,
    required TResult Function(RoomUpdated value) updated,
    required TResult Function(RoomDeleted value) deleted,
    required TResult Function(RoomBatchUpdate value) batchUpdate,
    required TResult Function(RoomSnapshot value) snapshot,
  }) {
    return batchUpdate(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RoomCreated value)? created,
    TResult? Function(RoomUpdated value)? updated,
    TResult? Function(RoomDeleted value)? deleted,
    TResult? Function(RoomBatchUpdate value)? batchUpdate,
    TResult? Function(RoomSnapshot value)? snapshot,
  }) {
    return batchUpdate?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RoomCreated value)? created,
    TResult Function(RoomUpdated value)? updated,
    TResult Function(RoomDeleted value)? deleted,
    TResult Function(RoomBatchUpdate value)? batchUpdate,
    TResult Function(RoomSnapshot value)? snapshot,
    required TResult orElse(),
  }) {
    if (batchUpdate != null) {
      return batchUpdate(this);
    }
    return orElse();
  }
}

abstract class RoomBatchUpdate implements RoomEvent {
  const factory RoomBatchUpdate(final List<Room> rooms) = _$RoomBatchUpdateImpl;

  List<Room> get rooms;
  @JsonKey(ignore: true)
  _$$RoomBatchUpdateImplCopyWith<_$RoomBatchUpdateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RoomSnapshotImplCopyWith<$Res> {
  factory _$$RoomSnapshotImplCopyWith(
          _$RoomSnapshotImpl value, $Res Function(_$RoomSnapshotImpl) then) =
      __$$RoomSnapshotImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<Room> rooms});
}

/// @nodoc
class __$$RoomSnapshotImplCopyWithImpl<$Res>
    extends _$RoomEventCopyWithImpl<$Res, _$RoomSnapshotImpl>
    implements _$$RoomSnapshotImplCopyWith<$Res> {
  __$$RoomSnapshotImplCopyWithImpl(
      _$RoomSnapshotImpl _value, $Res Function(_$RoomSnapshotImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rooms = null,
  }) {
    return _then(_$RoomSnapshotImpl(
      null == rooms
          ? _value._rooms
          : rooms // ignore: cast_nullable_to_non_nullable
              as List<Room>,
    ));
  }
}

/// @nodoc

class _$RoomSnapshotImpl implements RoomSnapshot {
  const _$RoomSnapshotImpl(final List<Room> rooms) : _rooms = rooms;

  final List<Room> _rooms;
  @override
  List<Room> get rooms {
    if (_rooms is EqualUnmodifiableListView) return _rooms;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rooms);
  }

  @override
  String toString() {
    return 'RoomEvent.snapshot(rooms: $rooms)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoomSnapshotImpl &&
            const DeepCollectionEquality().equals(other._rooms, _rooms));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_rooms));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RoomSnapshotImplCopyWith<_$RoomSnapshotImpl> get copyWith =>
      __$$RoomSnapshotImplCopyWithImpl<_$RoomSnapshotImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Room room) created,
    required TResult Function(Room room) updated,
    required TResult Function(String id) deleted,
    required TResult Function(List<Room> rooms) batchUpdate,
    required TResult Function(List<Room> rooms) snapshot,
  }) {
    return snapshot(rooms);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Room room)? created,
    TResult? Function(Room room)? updated,
    TResult? Function(String id)? deleted,
    TResult? Function(List<Room> rooms)? batchUpdate,
    TResult? Function(List<Room> rooms)? snapshot,
  }) {
    return snapshot?.call(rooms);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Room room)? created,
    TResult Function(Room room)? updated,
    TResult Function(String id)? deleted,
    TResult Function(List<Room> rooms)? batchUpdate,
    TResult Function(List<Room> rooms)? snapshot,
    required TResult orElse(),
  }) {
    if (snapshot != null) {
      return snapshot(rooms);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RoomCreated value) created,
    required TResult Function(RoomUpdated value) updated,
    required TResult Function(RoomDeleted value) deleted,
    required TResult Function(RoomBatchUpdate value) batchUpdate,
    required TResult Function(RoomSnapshot value) snapshot,
  }) {
    return snapshot(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RoomCreated value)? created,
    TResult? Function(RoomUpdated value)? updated,
    TResult? Function(RoomDeleted value)? deleted,
    TResult? Function(RoomBatchUpdate value)? batchUpdate,
    TResult? Function(RoomSnapshot value)? snapshot,
  }) {
    return snapshot?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RoomCreated value)? created,
    TResult Function(RoomUpdated value)? updated,
    TResult Function(RoomDeleted value)? deleted,
    TResult Function(RoomBatchUpdate value)? batchUpdate,
    TResult Function(RoomSnapshot value)? snapshot,
    required TResult orElse(),
  }) {
    if (snapshot != null) {
      return snapshot(this);
    }
    return orElse();
  }
}

abstract class RoomSnapshot implements RoomEvent {
  const factory RoomSnapshot(final List<Room> rooms) = _$RoomSnapshotImpl;

  List<Room> get rooms;
  @JsonKey(ignore: true)
  _$$RoomSnapshotImplCopyWith<_$RoomSnapshotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$NotificationEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String id,
            String title,
            String message,
            String type,
            String priority,
            String? deviceId,
            String? location,
            Map<String, dynamic>? metadata)
        received,
    required TResult Function(String id) read,
    required TResult Function() cleared,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String id,
            String title,
            String message,
            String type,
            String priority,
            String? deviceId,
            String? location,
            Map<String, dynamic>? metadata)?
        received,
    TResult? Function(String id)? read,
    TResult? Function()? cleared,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String id,
            String title,
            String message,
            String type,
            String priority,
            String? deviceId,
            String? location,
            Map<String, dynamic>? metadata)?
        received,
    TResult Function(String id)? read,
    TResult Function()? cleared,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NotificationReceived value) received,
    required TResult Function(NotificationRead value) read,
    required TResult Function(NotificationCleared value) cleared,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NotificationReceived value)? received,
    TResult? Function(NotificationRead value)? read,
    TResult? Function(NotificationCleared value)? cleared,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NotificationReceived value)? received,
    TResult Function(NotificationRead value)? read,
    TResult Function(NotificationCleared value)? cleared,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationEventCopyWith<$Res> {
  factory $NotificationEventCopyWith(
          NotificationEvent value, $Res Function(NotificationEvent) then) =
      _$NotificationEventCopyWithImpl<$Res, NotificationEvent>;
}

/// @nodoc
class _$NotificationEventCopyWithImpl<$Res, $Val extends NotificationEvent>
    implements $NotificationEventCopyWith<$Res> {
  _$NotificationEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$NotificationReceivedImplCopyWith<$Res> {
  factory _$$NotificationReceivedImplCopyWith(_$NotificationReceivedImpl value,
          $Res Function(_$NotificationReceivedImpl) then) =
      __$$NotificationReceivedImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {String id,
      String title,
      String message,
      String type,
      String priority,
      String? deviceId,
      String? location,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$NotificationReceivedImplCopyWithImpl<$Res>
    extends _$NotificationEventCopyWithImpl<$Res, _$NotificationReceivedImpl>
    implements _$$NotificationReceivedImplCopyWith<$Res> {
  __$$NotificationReceivedImplCopyWithImpl(_$NotificationReceivedImpl _value,
      $Res Function(_$NotificationReceivedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? message = null,
    Object? type = null,
    Object? priority = null,
    Object? deviceId = freezed,
    Object? location = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_$NotificationReceivedImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as String,
      deviceId: freezed == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$NotificationReceivedImpl implements NotificationReceived {
  const _$NotificationReceivedImpl(
      {required this.id,
      required this.title,
      required this.message,
      required this.type,
      required this.priority,
      this.deviceId,
      this.location,
      final Map<String, dynamic>? metadata})
      : _metadata = metadata;

  @override
  final String id;
  @override
  final String title;
  @override
  final String message;
  @override
  final String type;
  @override
  final String priority;
  @override
  final String? deviceId;
  @override
  final String? location;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'NotificationEvent.received(id: $id, title: $title, message: $message, type: $type, priority: $priority, deviceId: $deviceId, location: $location, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationReceivedImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.location, location) ||
                other.location == location) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      message,
      type,
      priority,
      deviceId,
      location,
      const DeepCollectionEquality().hash(_metadata));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationReceivedImplCopyWith<_$NotificationReceivedImpl>
      get copyWith =>
          __$$NotificationReceivedImplCopyWithImpl<_$NotificationReceivedImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String id,
            String title,
            String message,
            String type,
            String priority,
            String? deviceId,
            String? location,
            Map<String, dynamic>? metadata)
        received,
    required TResult Function(String id) read,
    required TResult Function() cleared,
  }) {
    return received(
        id, title, message, type, priority, deviceId, location, metadata);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String id,
            String title,
            String message,
            String type,
            String priority,
            String? deviceId,
            String? location,
            Map<String, dynamic>? metadata)?
        received,
    TResult? Function(String id)? read,
    TResult? Function()? cleared,
  }) {
    return received?.call(
        id, title, message, type, priority, deviceId, location, metadata);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String id,
            String title,
            String message,
            String type,
            String priority,
            String? deviceId,
            String? location,
            Map<String, dynamic>? metadata)?
        received,
    TResult Function(String id)? read,
    TResult Function()? cleared,
    required TResult orElse(),
  }) {
    if (received != null) {
      return received(
          id, title, message, type, priority, deviceId, location, metadata);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NotificationReceived value) received,
    required TResult Function(NotificationRead value) read,
    required TResult Function(NotificationCleared value) cleared,
  }) {
    return received(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NotificationReceived value)? received,
    TResult? Function(NotificationRead value)? read,
    TResult? Function(NotificationCleared value)? cleared,
  }) {
    return received?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NotificationReceived value)? received,
    TResult Function(NotificationRead value)? read,
    TResult Function(NotificationCleared value)? cleared,
    required TResult orElse(),
  }) {
    if (received != null) {
      return received(this);
    }
    return orElse();
  }
}

abstract class NotificationReceived implements NotificationEvent {
  const factory NotificationReceived(
      {required final String id,
      required final String title,
      required final String message,
      required final String type,
      required final String priority,
      final String? deviceId,
      final String? location,
      final Map<String, dynamic>? metadata}) = _$NotificationReceivedImpl;

  String get id;
  String get title;
  String get message;
  String get type;
  String get priority;
  String? get deviceId;
  String? get location;
  Map<String, dynamic>? get metadata;
  @JsonKey(ignore: true)
  _$$NotificationReceivedImplCopyWith<_$NotificationReceivedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$NotificationReadImplCopyWith<$Res> {
  factory _$$NotificationReadImplCopyWith(_$NotificationReadImpl value,
          $Res Function(_$NotificationReadImpl) then) =
      __$$NotificationReadImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String id});
}

/// @nodoc
class __$$NotificationReadImplCopyWithImpl<$Res>
    extends _$NotificationEventCopyWithImpl<$Res, _$NotificationReadImpl>
    implements _$$NotificationReadImplCopyWith<$Res> {
  __$$NotificationReadImplCopyWithImpl(_$NotificationReadImpl _value,
      $Res Function(_$NotificationReadImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_$NotificationReadImpl(
      null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$NotificationReadImpl implements NotificationRead {
  const _$NotificationReadImpl(this.id);

  @override
  final String id;

  @override
  String toString() {
    return 'NotificationEvent.read(id: $id)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationReadImpl &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationReadImplCopyWith<_$NotificationReadImpl> get copyWith =>
      __$$NotificationReadImplCopyWithImpl<_$NotificationReadImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String id,
            String title,
            String message,
            String type,
            String priority,
            String? deviceId,
            String? location,
            Map<String, dynamic>? metadata)
        received,
    required TResult Function(String id) read,
    required TResult Function() cleared,
  }) {
    return read(id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String id,
            String title,
            String message,
            String type,
            String priority,
            String? deviceId,
            String? location,
            Map<String, dynamic>? metadata)?
        received,
    TResult? Function(String id)? read,
    TResult? Function()? cleared,
  }) {
    return read?.call(id);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String id,
            String title,
            String message,
            String type,
            String priority,
            String? deviceId,
            String? location,
            Map<String, dynamic>? metadata)?
        received,
    TResult Function(String id)? read,
    TResult Function()? cleared,
    required TResult orElse(),
  }) {
    if (read != null) {
      return read(id);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NotificationReceived value) received,
    required TResult Function(NotificationRead value) read,
    required TResult Function(NotificationCleared value) cleared,
  }) {
    return read(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NotificationReceived value)? received,
    TResult? Function(NotificationRead value)? read,
    TResult? Function(NotificationCleared value)? cleared,
  }) {
    return read?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NotificationReceived value)? received,
    TResult Function(NotificationRead value)? read,
    TResult Function(NotificationCleared value)? cleared,
    required TResult orElse(),
  }) {
    if (read != null) {
      return read(this);
    }
    return orElse();
  }
}

abstract class NotificationRead implements NotificationEvent {
  const factory NotificationRead(final String id) = _$NotificationReadImpl;

  String get id;
  @JsonKey(ignore: true)
  _$$NotificationReadImplCopyWith<_$NotificationReadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$NotificationClearedImplCopyWith<$Res> {
  factory _$$NotificationClearedImplCopyWith(_$NotificationClearedImpl value,
          $Res Function(_$NotificationClearedImpl) then) =
      __$$NotificationClearedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$NotificationClearedImplCopyWithImpl<$Res>
    extends _$NotificationEventCopyWithImpl<$Res, _$NotificationClearedImpl>
    implements _$$NotificationClearedImplCopyWith<$Res> {
  __$$NotificationClearedImplCopyWithImpl(_$NotificationClearedImpl _value,
      $Res Function(_$NotificationClearedImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$NotificationClearedImpl implements NotificationCleared {
  const _$NotificationClearedImpl();

  @override
  String toString() {
    return 'NotificationEvent.cleared()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationClearedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String id,
            String title,
            String message,
            String type,
            String priority,
            String? deviceId,
            String? location,
            Map<String, dynamic>? metadata)
        received,
    required TResult Function(String id) read,
    required TResult Function() cleared,
  }) {
    return cleared();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String id,
            String title,
            String message,
            String type,
            String priority,
            String? deviceId,
            String? location,
            Map<String, dynamic>? metadata)?
        received,
    TResult? Function(String id)? read,
    TResult? Function()? cleared,
  }) {
    return cleared?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String id,
            String title,
            String message,
            String type,
            String priority,
            String? deviceId,
            String? location,
            Map<String, dynamic>? metadata)?
        received,
    TResult Function(String id)? read,
    TResult Function()? cleared,
    required TResult orElse(),
  }) {
    if (cleared != null) {
      return cleared();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NotificationReceived value) received,
    required TResult Function(NotificationRead value) read,
    required TResult Function(NotificationCleared value) cleared,
  }) {
    return cleared(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NotificationReceived value)? received,
    TResult? Function(NotificationRead value)? read,
    TResult? Function(NotificationCleared value)? cleared,
  }) {
    return cleared?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NotificationReceived value)? received,
    TResult Function(NotificationRead value)? read,
    TResult Function(NotificationCleared value)? cleared,
    required TResult orElse(),
  }) {
    if (cleared != null) {
      return cleared(this);
    }
    return orElse();
  }
}

abstract class NotificationCleared implements NotificationEvent {
  const factory NotificationCleared() = _$NotificationClearedImpl;
}

/// @nodoc
mixin _$SyncEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(int deviceCount, int roomCount) completed,
    required TResult Function(String error) failed,
    required TResult Function(
            List<Device>? updatedDevices,
            List<Room>? updatedRooms,
            List<String>? deletedDeviceIds,
            List<String>? deletedRoomIds)
        delta,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(int deviceCount, int roomCount)? completed,
    TResult? Function(String error)? failed,
    TResult? Function(List<Device>? updatedDevices, List<Room>? updatedRooms,
            List<String>? deletedDeviceIds, List<String>? deletedRoomIds)?
        delta,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(int deviceCount, int roomCount)? completed,
    TResult Function(String error)? failed,
    TResult Function(List<Device>? updatedDevices, List<Room>? updatedRooms,
            List<String>? deletedDeviceIds, List<String>? deletedRoomIds)?
        delta,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SyncStarted value) started,
    required TResult Function(SyncCompleted value) completed,
    required TResult Function(SyncFailed value) failed,
    required TResult Function(SyncDelta value) delta,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SyncStarted value)? started,
    TResult? Function(SyncCompleted value)? completed,
    TResult? Function(SyncFailed value)? failed,
    TResult? Function(SyncDelta value)? delta,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SyncStarted value)? started,
    TResult Function(SyncCompleted value)? completed,
    TResult Function(SyncFailed value)? failed,
    TResult Function(SyncDelta value)? delta,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SyncEventCopyWith<$Res> {
  factory $SyncEventCopyWith(SyncEvent value, $Res Function(SyncEvent) then) =
      _$SyncEventCopyWithImpl<$Res, SyncEvent>;
}

/// @nodoc
class _$SyncEventCopyWithImpl<$Res, $Val extends SyncEvent>
    implements $SyncEventCopyWith<$Res> {
  _$SyncEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$SyncStartedImplCopyWith<$Res> {
  factory _$$SyncStartedImplCopyWith(
          _$SyncStartedImpl value, $Res Function(_$SyncStartedImpl) then) =
      __$$SyncStartedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SyncStartedImplCopyWithImpl<$Res>
    extends _$SyncEventCopyWithImpl<$Res, _$SyncStartedImpl>
    implements _$$SyncStartedImplCopyWith<$Res> {
  __$$SyncStartedImplCopyWithImpl(
      _$SyncStartedImpl _value, $Res Function(_$SyncStartedImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$SyncStartedImpl implements SyncStarted {
  const _$SyncStartedImpl();

  @override
  String toString() {
    return 'SyncEvent.started()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SyncStartedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(int deviceCount, int roomCount) completed,
    required TResult Function(String error) failed,
    required TResult Function(
            List<Device>? updatedDevices,
            List<Room>? updatedRooms,
            List<String>? deletedDeviceIds,
            List<String>? deletedRoomIds)
        delta,
  }) {
    return started();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(int deviceCount, int roomCount)? completed,
    TResult? Function(String error)? failed,
    TResult? Function(List<Device>? updatedDevices, List<Room>? updatedRooms,
            List<String>? deletedDeviceIds, List<String>? deletedRoomIds)?
        delta,
  }) {
    return started?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(int deviceCount, int roomCount)? completed,
    TResult Function(String error)? failed,
    TResult Function(List<Device>? updatedDevices, List<Room>? updatedRooms,
            List<String>? deletedDeviceIds, List<String>? deletedRoomIds)?
        delta,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SyncStarted value) started,
    required TResult Function(SyncCompleted value) completed,
    required TResult Function(SyncFailed value) failed,
    required TResult Function(SyncDelta value) delta,
  }) {
    return started(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SyncStarted value)? started,
    TResult? Function(SyncCompleted value)? completed,
    TResult? Function(SyncFailed value)? failed,
    TResult? Function(SyncDelta value)? delta,
  }) {
    return started?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SyncStarted value)? started,
    TResult Function(SyncCompleted value)? completed,
    TResult Function(SyncFailed value)? failed,
    TResult Function(SyncDelta value)? delta,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started(this);
    }
    return orElse();
  }
}

abstract class SyncStarted implements SyncEvent {
  const factory SyncStarted() = _$SyncStartedImpl;
}

/// @nodoc
abstract class _$$SyncCompletedImplCopyWith<$Res> {
  factory _$$SyncCompletedImplCopyWith(
          _$SyncCompletedImpl value, $Res Function(_$SyncCompletedImpl) then) =
      __$$SyncCompletedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int deviceCount, int roomCount});
}

/// @nodoc
class __$$SyncCompletedImplCopyWithImpl<$Res>
    extends _$SyncEventCopyWithImpl<$Res, _$SyncCompletedImpl>
    implements _$$SyncCompletedImplCopyWith<$Res> {
  __$$SyncCompletedImplCopyWithImpl(
      _$SyncCompletedImpl _value, $Res Function(_$SyncCompletedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceCount = null,
    Object? roomCount = null,
  }) {
    return _then(_$SyncCompletedImpl(
      deviceCount: null == deviceCount
          ? _value.deviceCount
          : deviceCount // ignore: cast_nullable_to_non_nullable
              as int,
      roomCount: null == roomCount
          ? _value.roomCount
          : roomCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$SyncCompletedImpl implements SyncCompleted {
  const _$SyncCompletedImpl(
      {required this.deviceCount, required this.roomCount});

  @override
  final int deviceCount;
  @override
  final int roomCount;

  @override
  String toString() {
    return 'SyncEvent.completed(deviceCount: $deviceCount, roomCount: $roomCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SyncCompletedImpl &&
            (identical(other.deviceCount, deviceCount) ||
                other.deviceCount == deviceCount) &&
            (identical(other.roomCount, roomCount) ||
                other.roomCount == roomCount));
  }

  @override
  int get hashCode => Object.hash(runtimeType, deviceCount, roomCount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SyncCompletedImplCopyWith<_$SyncCompletedImpl> get copyWith =>
      __$$SyncCompletedImplCopyWithImpl<_$SyncCompletedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(int deviceCount, int roomCount) completed,
    required TResult Function(String error) failed,
    required TResult Function(
            List<Device>? updatedDevices,
            List<Room>? updatedRooms,
            List<String>? deletedDeviceIds,
            List<String>? deletedRoomIds)
        delta,
  }) {
    return completed(deviceCount, roomCount);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(int deviceCount, int roomCount)? completed,
    TResult? Function(String error)? failed,
    TResult? Function(List<Device>? updatedDevices, List<Room>? updatedRooms,
            List<String>? deletedDeviceIds, List<String>? deletedRoomIds)?
        delta,
  }) {
    return completed?.call(deviceCount, roomCount);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(int deviceCount, int roomCount)? completed,
    TResult Function(String error)? failed,
    TResult Function(List<Device>? updatedDevices, List<Room>? updatedRooms,
            List<String>? deletedDeviceIds, List<String>? deletedRoomIds)?
        delta,
    required TResult orElse(),
  }) {
    if (completed != null) {
      return completed(deviceCount, roomCount);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SyncStarted value) started,
    required TResult Function(SyncCompleted value) completed,
    required TResult Function(SyncFailed value) failed,
    required TResult Function(SyncDelta value) delta,
  }) {
    return completed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SyncStarted value)? started,
    TResult? Function(SyncCompleted value)? completed,
    TResult? Function(SyncFailed value)? failed,
    TResult? Function(SyncDelta value)? delta,
  }) {
    return completed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SyncStarted value)? started,
    TResult Function(SyncCompleted value)? completed,
    TResult Function(SyncFailed value)? failed,
    TResult Function(SyncDelta value)? delta,
    required TResult orElse(),
  }) {
    if (completed != null) {
      return completed(this);
    }
    return orElse();
  }
}

abstract class SyncCompleted implements SyncEvent {
  const factory SyncCompleted(
      {required final int deviceCount,
      required final int roomCount}) = _$SyncCompletedImpl;

  int get deviceCount;
  int get roomCount;
  @JsonKey(ignore: true)
  _$$SyncCompletedImplCopyWith<_$SyncCompletedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SyncFailedImplCopyWith<$Res> {
  factory _$$SyncFailedImplCopyWith(
          _$SyncFailedImpl value, $Res Function(_$SyncFailedImpl) then) =
      __$$SyncFailedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String error});
}

/// @nodoc
class __$$SyncFailedImplCopyWithImpl<$Res>
    extends _$SyncEventCopyWithImpl<$Res, _$SyncFailedImpl>
    implements _$$SyncFailedImplCopyWith<$Res> {
  __$$SyncFailedImplCopyWithImpl(
      _$SyncFailedImpl _value, $Res Function(_$SyncFailedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
  }) {
    return _then(_$SyncFailedImpl(
      null == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$SyncFailedImpl implements SyncFailed {
  const _$SyncFailedImpl(this.error);

  @override
  final String error;

  @override
  String toString() {
    return 'SyncEvent.failed(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SyncFailedImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SyncFailedImplCopyWith<_$SyncFailedImpl> get copyWith =>
      __$$SyncFailedImplCopyWithImpl<_$SyncFailedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(int deviceCount, int roomCount) completed,
    required TResult Function(String error) failed,
    required TResult Function(
            List<Device>? updatedDevices,
            List<Room>? updatedRooms,
            List<String>? deletedDeviceIds,
            List<String>? deletedRoomIds)
        delta,
  }) {
    return failed(error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(int deviceCount, int roomCount)? completed,
    TResult? Function(String error)? failed,
    TResult? Function(List<Device>? updatedDevices, List<Room>? updatedRooms,
            List<String>? deletedDeviceIds, List<String>? deletedRoomIds)?
        delta,
  }) {
    return failed?.call(error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(int deviceCount, int roomCount)? completed,
    TResult Function(String error)? failed,
    TResult Function(List<Device>? updatedDevices, List<Room>? updatedRooms,
            List<String>? deletedDeviceIds, List<String>? deletedRoomIds)?
        delta,
    required TResult orElse(),
  }) {
    if (failed != null) {
      return failed(error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SyncStarted value) started,
    required TResult Function(SyncCompleted value) completed,
    required TResult Function(SyncFailed value) failed,
    required TResult Function(SyncDelta value) delta,
  }) {
    return failed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SyncStarted value)? started,
    TResult? Function(SyncCompleted value)? completed,
    TResult? Function(SyncFailed value)? failed,
    TResult? Function(SyncDelta value)? delta,
  }) {
    return failed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SyncStarted value)? started,
    TResult Function(SyncCompleted value)? completed,
    TResult Function(SyncFailed value)? failed,
    TResult Function(SyncDelta value)? delta,
    required TResult orElse(),
  }) {
    if (failed != null) {
      return failed(this);
    }
    return orElse();
  }
}

abstract class SyncFailed implements SyncEvent {
  const factory SyncFailed(final String error) = _$SyncFailedImpl;

  String get error;
  @JsonKey(ignore: true)
  _$$SyncFailedImplCopyWith<_$SyncFailedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SyncDeltaImplCopyWith<$Res> {
  factory _$$SyncDeltaImplCopyWith(
          _$SyncDeltaImpl value, $Res Function(_$SyncDeltaImpl) then) =
      __$$SyncDeltaImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {List<Device>? updatedDevices,
      List<Room>? updatedRooms,
      List<String>? deletedDeviceIds,
      List<String>? deletedRoomIds});
}

/// @nodoc
class __$$SyncDeltaImplCopyWithImpl<$Res>
    extends _$SyncEventCopyWithImpl<$Res, _$SyncDeltaImpl>
    implements _$$SyncDeltaImplCopyWith<$Res> {
  __$$SyncDeltaImplCopyWithImpl(
      _$SyncDeltaImpl _value, $Res Function(_$SyncDeltaImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? updatedDevices = freezed,
    Object? updatedRooms = freezed,
    Object? deletedDeviceIds = freezed,
    Object? deletedRoomIds = freezed,
  }) {
    return _then(_$SyncDeltaImpl(
      updatedDevices: freezed == updatedDevices
          ? _value._updatedDevices
          : updatedDevices // ignore: cast_nullable_to_non_nullable
              as List<Device>?,
      updatedRooms: freezed == updatedRooms
          ? _value._updatedRooms
          : updatedRooms // ignore: cast_nullable_to_non_nullable
              as List<Room>?,
      deletedDeviceIds: freezed == deletedDeviceIds
          ? _value._deletedDeviceIds
          : deletedDeviceIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      deletedRoomIds: freezed == deletedRoomIds
          ? _value._deletedRoomIds
          : deletedRoomIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc

class _$SyncDeltaImpl implements SyncDelta {
  const _$SyncDeltaImpl(
      {final List<Device>? updatedDevices,
      final List<Room>? updatedRooms,
      final List<String>? deletedDeviceIds,
      final List<String>? deletedRoomIds})
      : _updatedDevices = updatedDevices,
        _updatedRooms = updatedRooms,
        _deletedDeviceIds = deletedDeviceIds,
        _deletedRoomIds = deletedRoomIds;

  final List<Device>? _updatedDevices;
  @override
  List<Device>? get updatedDevices {
    final value = _updatedDevices;
    if (value == null) return null;
    if (_updatedDevices is EqualUnmodifiableListView) return _updatedDevices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<Room>? _updatedRooms;
  @override
  List<Room>? get updatedRooms {
    final value = _updatedRooms;
    if (value == null) return null;
    if (_updatedRooms is EqualUnmodifiableListView) return _updatedRooms;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _deletedDeviceIds;
  @override
  List<String>? get deletedDeviceIds {
    final value = _deletedDeviceIds;
    if (value == null) return null;
    if (_deletedDeviceIds is EqualUnmodifiableListView)
      return _deletedDeviceIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _deletedRoomIds;
  @override
  List<String>? get deletedRoomIds {
    final value = _deletedRoomIds;
    if (value == null) return null;
    if (_deletedRoomIds is EqualUnmodifiableListView) return _deletedRoomIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'SyncEvent.delta(updatedDevices: $updatedDevices, updatedRooms: $updatedRooms, deletedDeviceIds: $deletedDeviceIds, deletedRoomIds: $deletedRoomIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SyncDeltaImpl &&
            const DeepCollectionEquality()
                .equals(other._updatedDevices, _updatedDevices) &&
            const DeepCollectionEquality()
                .equals(other._updatedRooms, _updatedRooms) &&
            const DeepCollectionEquality()
                .equals(other._deletedDeviceIds, _deletedDeviceIds) &&
            const DeepCollectionEquality()
                .equals(other._deletedRoomIds, _deletedRoomIds));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_updatedDevices),
      const DeepCollectionEquality().hash(_updatedRooms),
      const DeepCollectionEquality().hash(_deletedDeviceIds),
      const DeepCollectionEquality().hash(_deletedRoomIds));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SyncDeltaImplCopyWith<_$SyncDeltaImpl> get copyWith =>
      __$$SyncDeltaImplCopyWithImpl<_$SyncDeltaImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(int deviceCount, int roomCount) completed,
    required TResult Function(String error) failed,
    required TResult Function(
            List<Device>? updatedDevices,
            List<Room>? updatedRooms,
            List<String>? deletedDeviceIds,
            List<String>? deletedRoomIds)
        delta,
  }) {
    return delta(
        updatedDevices, updatedRooms, deletedDeviceIds, deletedRoomIds);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(int deviceCount, int roomCount)? completed,
    TResult? Function(String error)? failed,
    TResult? Function(List<Device>? updatedDevices, List<Room>? updatedRooms,
            List<String>? deletedDeviceIds, List<String>? deletedRoomIds)?
        delta,
  }) {
    return delta?.call(
        updatedDevices, updatedRooms, deletedDeviceIds, deletedRoomIds);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(int deviceCount, int roomCount)? completed,
    TResult Function(String error)? failed,
    TResult Function(List<Device>? updatedDevices, List<Room>? updatedRooms,
            List<String>? deletedDeviceIds, List<String>? deletedRoomIds)?
        delta,
    required TResult orElse(),
  }) {
    if (delta != null) {
      return delta(
          updatedDevices, updatedRooms, deletedDeviceIds, deletedRoomIds);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SyncStarted value) started,
    required TResult Function(SyncCompleted value) completed,
    required TResult Function(SyncFailed value) failed,
    required TResult Function(SyncDelta value) delta,
  }) {
    return delta(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SyncStarted value)? started,
    TResult? Function(SyncCompleted value)? completed,
    TResult? Function(SyncFailed value)? failed,
    TResult? Function(SyncDelta value)? delta,
  }) {
    return delta?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SyncStarted value)? started,
    TResult Function(SyncCompleted value)? completed,
    TResult Function(SyncFailed value)? failed,
    TResult Function(SyncDelta value)? delta,
    required TResult orElse(),
  }) {
    if (delta != null) {
      return delta(this);
    }
    return orElse();
  }
}

abstract class SyncDelta implements SyncEvent {
  const factory SyncDelta(
      {final List<Device>? updatedDevices,
      final List<Room>? updatedRooms,
      final List<String>? deletedDeviceIds,
      final List<String>? deletedRoomIds}) = _$SyncDeltaImpl;

  List<Device>? get updatedDevices;
  List<Room>? get updatedRooms;
  List<String>? get deletedDeviceIds;
  List<String>? get deletedRoomIds;
  @JsonKey(ignore: true)
  _$$SyncDeltaImplCopyWith<_$SyncDeltaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ConnectionEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() connected,
    required TResult Function(String? reason) disconnected,
    required TResult Function(int attempt) reconnecting,
    required TResult Function(String message, StackTrace? stackTrace) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? connected,
    TResult? Function(String? reason)? disconnected,
    TResult? Function(int attempt)? reconnecting,
    TResult? Function(String message, StackTrace? stackTrace)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? connected,
    TResult Function(String? reason)? disconnected,
    TResult Function(int attempt)? reconnecting,
    TResult Function(String message, StackTrace? stackTrace)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ConnectionConnected value) connected,
    required TResult Function(ConnectionDisconnected value) disconnected,
    required TResult Function(ConnectionReconnecting value) reconnecting,
    required TResult Function(ConnectionError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ConnectionConnected value)? connected,
    TResult? Function(ConnectionDisconnected value)? disconnected,
    TResult? Function(ConnectionReconnecting value)? reconnecting,
    TResult? Function(ConnectionError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ConnectionConnected value)? connected,
    TResult Function(ConnectionDisconnected value)? disconnected,
    TResult Function(ConnectionReconnecting value)? reconnecting,
    TResult Function(ConnectionError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConnectionEventCopyWith<$Res> {
  factory $ConnectionEventCopyWith(
          ConnectionEvent value, $Res Function(ConnectionEvent) then) =
      _$ConnectionEventCopyWithImpl<$Res, ConnectionEvent>;
}

/// @nodoc
class _$ConnectionEventCopyWithImpl<$Res, $Val extends ConnectionEvent>
    implements $ConnectionEventCopyWith<$Res> {
  _$ConnectionEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$ConnectionConnectedImplCopyWith<$Res> {
  factory _$$ConnectionConnectedImplCopyWith(_$ConnectionConnectedImpl value,
          $Res Function(_$ConnectionConnectedImpl) then) =
      __$$ConnectionConnectedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ConnectionConnectedImplCopyWithImpl<$Res>
    extends _$ConnectionEventCopyWithImpl<$Res, _$ConnectionConnectedImpl>
    implements _$$ConnectionConnectedImplCopyWith<$Res> {
  __$$ConnectionConnectedImplCopyWithImpl(_$ConnectionConnectedImpl _value,
      $Res Function(_$ConnectionConnectedImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$ConnectionConnectedImpl implements ConnectionConnected {
  const _$ConnectionConnectedImpl();

  @override
  String toString() {
    return 'ConnectionEvent.connected()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConnectionConnectedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() connected,
    required TResult Function(String? reason) disconnected,
    required TResult Function(int attempt) reconnecting,
    required TResult Function(String message, StackTrace? stackTrace) error,
  }) {
    return connected();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? connected,
    TResult? Function(String? reason)? disconnected,
    TResult? Function(int attempt)? reconnecting,
    TResult? Function(String message, StackTrace? stackTrace)? error,
  }) {
    return connected?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? connected,
    TResult Function(String? reason)? disconnected,
    TResult Function(int attempt)? reconnecting,
    TResult Function(String message, StackTrace? stackTrace)? error,
    required TResult orElse(),
  }) {
    if (connected != null) {
      return connected();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ConnectionConnected value) connected,
    required TResult Function(ConnectionDisconnected value) disconnected,
    required TResult Function(ConnectionReconnecting value) reconnecting,
    required TResult Function(ConnectionError value) error,
  }) {
    return connected(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ConnectionConnected value)? connected,
    TResult? Function(ConnectionDisconnected value)? disconnected,
    TResult? Function(ConnectionReconnecting value)? reconnecting,
    TResult? Function(ConnectionError value)? error,
  }) {
    return connected?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ConnectionConnected value)? connected,
    TResult Function(ConnectionDisconnected value)? disconnected,
    TResult Function(ConnectionReconnecting value)? reconnecting,
    TResult Function(ConnectionError value)? error,
    required TResult orElse(),
  }) {
    if (connected != null) {
      return connected(this);
    }
    return orElse();
  }
}

abstract class ConnectionConnected implements ConnectionEvent {
  const factory ConnectionConnected() = _$ConnectionConnectedImpl;
}

/// @nodoc
abstract class _$$ConnectionDisconnectedImplCopyWith<$Res> {
  factory _$$ConnectionDisconnectedImplCopyWith(
          _$ConnectionDisconnectedImpl value,
          $Res Function(_$ConnectionDisconnectedImpl) then) =
      __$$ConnectionDisconnectedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String? reason});
}

/// @nodoc
class __$$ConnectionDisconnectedImplCopyWithImpl<$Res>
    extends _$ConnectionEventCopyWithImpl<$Res, _$ConnectionDisconnectedImpl>
    implements _$$ConnectionDisconnectedImplCopyWith<$Res> {
  __$$ConnectionDisconnectedImplCopyWithImpl(
      _$ConnectionDisconnectedImpl _value,
      $Res Function(_$ConnectionDisconnectedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reason = freezed,
  }) {
    return _then(_$ConnectionDisconnectedImpl(
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ConnectionDisconnectedImpl implements ConnectionDisconnected {
  const _$ConnectionDisconnectedImpl({this.reason});

  @override
  final String? reason;

  @override
  String toString() {
    return 'ConnectionEvent.disconnected(reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConnectionDisconnectedImpl &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @override
  int get hashCode => Object.hash(runtimeType, reason);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ConnectionDisconnectedImplCopyWith<_$ConnectionDisconnectedImpl>
      get copyWith => __$$ConnectionDisconnectedImplCopyWithImpl<
          _$ConnectionDisconnectedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() connected,
    required TResult Function(String? reason) disconnected,
    required TResult Function(int attempt) reconnecting,
    required TResult Function(String message, StackTrace? stackTrace) error,
  }) {
    return disconnected(reason);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? connected,
    TResult? Function(String? reason)? disconnected,
    TResult? Function(int attempt)? reconnecting,
    TResult? Function(String message, StackTrace? stackTrace)? error,
  }) {
    return disconnected?.call(reason);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? connected,
    TResult Function(String? reason)? disconnected,
    TResult Function(int attempt)? reconnecting,
    TResult Function(String message, StackTrace? stackTrace)? error,
    required TResult orElse(),
  }) {
    if (disconnected != null) {
      return disconnected(reason);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ConnectionConnected value) connected,
    required TResult Function(ConnectionDisconnected value) disconnected,
    required TResult Function(ConnectionReconnecting value) reconnecting,
    required TResult Function(ConnectionError value) error,
  }) {
    return disconnected(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ConnectionConnected value)? connected,
    TResult? Function(ConnectionDisconnected value)? disconnected,
    TResult? Function(ConnectionReconnecting value)? reconnecting,
    TResult? Function(ConnectionError value)? error,
  }) {
    return disconnected?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ConnectionConnected value)? connected,
    TResult Function(ConnectionDisconnected value)? disconnected,
    TResult Function(ConnectionReconnecting value)? reconnecting,
    TResult Function(ConnectionError value)? error,
    required TResult orElse(),
  }) {
    if (disconnected != null) {
      return disconnected(this);
    }
    return orElse();
  }
}

abstract class ConnectionDisconnected implements ConnectionEvent {
  const factory ConnectionDisconnected({final String? reason}) =
      _$ConnectionDisconnectedImpl;

  String? get reason;
  @JsonKey(ignore: true)
  _$$ConnectionDisconnectedImplCopyWith<_$ConnectionDisconnectedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ConnectionReconnectingImplCopyWith<$Res> {
  factory _$$ConnectionReconnectingImplCopyWith(
          _$ConnectionReconnectingImpl value,
          $Res Function(_$ConnectionReconnectingImpl) then) =
      __$$ConnectionReconnectingImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int attempt});
}

/// @nodoc
class __$$ConnectionReconnectingImplCopyWithImpl<$Res>
    extends _$ConnectionEventCopyWithImpl<$Res, _$ConnectionReconnectingImpl>
    implements _$$ConnectionReconnectingImplCopyWith<$Res> {
  __$$ConnectionReconnectingImplCopyWithImpl(
      _$ConnectionReconnectingImpl _value,
      $Res Function(_$ConnectionReconnectingImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? attempt = null,
  }) {
    return _then(_$ConnectionReconnectingImpl(
      null == attempt
          ? _value.attempt
          : attempt // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$ConnectionReconnectingImpl implements ConnectionReconnecting {
  const _$ConnectionReconnectingImpl(this.attempt);

  @override
  final int attempt;

  @override
  String toString() {
    return 'ConnectionEvent.reconnecting(attempt: $attempt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConnectionReconnectingImpl &&
            (identical(other.attempt, attempt) || other.attempt == attempt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, attempt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ConnectionReconnectingImplCopyWith<_$ConnectionReconnectingImpl>
      get copyWith => __$$ConnectionReconnectingImplCopyWithImpl<
          _$ConnectionReconnectingImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() connected,
    required TResult Function(String? reason) disconnected,
    required TResult Function(int attempt) reconnecting,
    required TResult Function(String message, StackTrace? stackTrace) error,
  }) {
    return reconnecting(attempt);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? connected,
    TResult? Function(String? reason)? disconnected,
    TResult? Function(int attempt)? reconnecting,
    TResult? Function(String message, StackTrace? stackTrace)? error,
  }) {
    return reconnecting?.call(attempt);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? connected,
    TResult Function(String? reason)? disconnected,
    TResult Function(int attempt)? reconnecting,
    TResult Function(String message, StackTrace? stackTrace)? error,
    required TResult orElse(),
  }) {
    if (reconnecting != null) {
      return reconnecting(attempt);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ConnectionConnected value) connected,
    required TResult Function(ConnectionDisconnected value) disconnected,
    required TResult Function(ConnectionReconnecting value) reconnecting,
    required TResult Function(ConnectionError value) error,
  }) {
    return reconnecting(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ConnectionConnected value)? connected,
    TResult? Function(ConnectionDisconnected value)? disconnected,
    TResult? Function(ConnectionReconnecting value)? reconnecting,
    TResult? Function(ConnectionError value)? error,
  }) {
    return reconnecting?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ConnectionConnected value)? connected,
    TResult Function(ConnectionDisconnected value)? disconnected,
    TResult Function(ConnectionReconnecting value)? reconnecting,
    TResult Function(ConnectionError value)? error,
    required TResult orElse(),
  }) {
    if (reconnecting != null) {
      return reconnecting(this);
    }
    return orElse();
  }
}

abstract class ConnectionReconnecting implements ConnectionEvent {
  const factory ConnectionReconnecting(final int attempt) =
      _$ConnectionReconnectingImpl;

  int get attempt;
  @JsonKey(ignore: true)
  _$$ConnectionReconnectingImplCopyWith<_$ConnectionReconnectingImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ConnectionErrorImplCopyWith<$Res> {
  factory _$$ConnectionErrorImplCopyWith(_$ConnectionErrorImpl value,
          $Res Function(_$ConnectionErrorImpl) then) =
      __$$ConnectionErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message, StackTrace? stackTrace});
}

/// @nodoc
class __$$ConnectionErrorImplCopyWithImpl<$Res>
    extends _$ConnectionEventCopyWithImpl<$Res, _$ConnectionErrorImpl>
    implements _$$ConnectionErrorImplCopyWith<$Res> {
  __$$ConnectionErrorImplCopyWithImpl(
      _$ConnectionErrorImpl _value, $Res Function(_$ConnectionErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? stackTrace = freezed,
  }) {
    return _then(_$ConnectionErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      freezed == stackTrace
          ? _value.stackTrace
          : stackTrace // ignore: cast_nullable_to_non_nullable
              as StackTrace?,
    ));
  }
}

/// @nodoc

class _$ConnectionErrorImpl implements ConnectionError {
  const _$ConnectionErrorImpl(this.message, this.stackTrace);

  @override
  final String message;
  @override
  final StackTrace? stackTrace;

  @override
  String toString() {
    return 'ConnectionEvent.error(message: $message, stackTrace: $stackTrace)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConnectionErrorImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.stackTrace, stackTrace) ||
                other.stackTrace == stackTrace));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, stackTrace);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ConnectionErrorImplCopyWith<_$ConnectionErrorImpl> get copyWith =>
      __$$ConnectionErrorImplCopyWithImpl<_$ConnectionErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() connected,
    required TResult Function(String? reason) disconnected,
    required TResult Function(int attempt) reconnecting,
    required TResult Function(String message, StackTrace? stackTrace) error,
  }) {
    return error(message, stackTrace);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? connected,
    TResult? Function(String? reason)? disconnected,
    TResult? Function(int attempt)? reconnecting,
    TResult? Function(String message, StackTrace? stackTrace)? error,
  }) {
    return error?.call(message, stackTrace);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? connected,
    TResult Function(String? reason)? disconnected,
    TResult Function(int attempt)? reconnecting,
    TResult Function(String message, StackTrace? stackTrace)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message, stackTrace);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ConnectionConnected value) connected,
    required TResult Function(ConnectionDisconnected value) disconnected,
    required TResult Function(ConnectionReconnecting value) reconnecting,
    required TResult Function(ConnectionError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ConnectionConnected value)? connected,
    TResult? Function(ConnectionDisconnected value)? disconnected,
    TResult? Function(ConnectionReconnecting value)? reconnecting,
    TResult? Function(ConnectionError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ConnectionConnected value)? connected,
    TResult Function(ConnectionDisconnected value)? disconnected,
    TResult Function(ConnectionReconnecting value)? reconnecting,
    TResult Function(ConnectionError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class ConnectionError implements ConnectionEvent {
  const factory ConnectionError(
          final String message, final StackTrace? stackTrace) =
      _$ConnectionErrorImpl;

  String get message;
  StackTrace? get stackTrace;
  @JsonKey(ignore: true)
  _$$ConnectionErrorImplCopyWith<_$ConnectionErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$WebSocketEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(DeviceEvent event) device,
    required TResult Function(RoomEvent event) room,
    required TResult Function(NotificationEvent event) notification,
    required TResult Function(SyncEvent event) sync,
    required TResult Function(ConnectionEvent event) connection,
    required TResult Function(String type, Map<String, dynamic> payload)
        unknown,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(DeviceEvent event)? device,
    TResult? Function(RoomEvent event)? room,
    TResult? Function(NotificationEvent event)? notification,
    TResult? Function(SyncEvent event)? sync,
    TResult? Function(ConnectionEvent event)? connection,
    TResult? Function(String type, Map<String, dynamic> payload)? unknown,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(DeviceEvent event)? device,
    TResult Function(RoomEvent event)? room,
    TResult Function(NotificationEvent event)? notification,
    TResult Function(SyncEvent event)? sync,
    TResult Function(ConnectionEvent event)? connection,
    TResult Function(String type, Map<String, dynamic> payload)? unknown,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DeviceWebSocketEvent value) device,
    required TResult Function(RoomWebSocketEvent value) room,
    required TResult Function(NotificationWebSocketEvent value) notification,
    required TResult Function(SyncWebSocketEvent value) sync,
    required TResult Function(ConnectionWebSocketEvent value) connection,
    required TResult Function(UnknownWebSocketEvent value) unknown,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DeviceWebSocketEvent value)? device,
    TResult? Function(RoomWebSocketEvent value)? room,
    TResult? Function(NotificationWebSocketEvent value)? notification,
    TResult? Function(SyncWebSocketEvent value)? sync,
    TResult? Function(ConnectionWebSocketEvent value)? connection,
    TResult? Function(UnknownWebSocketEvent value)? unknown,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DeviceWebSocketEvent value)? device,
    TResult Function(RoomWebSocketEvent value)? room,
    TResult Function(NotificationWebSocketEvent value)? notification,
    TResult Function(SyncWebSocketEvent value)? sync,
    TResult Function(ConnectionWebSocketEvent value)? connection,
    TResult Function(UnknownWebSocketEvent value)? unknown,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WebSocketEventCopyWith<$Res> {
  factory $WebSocketEventCopyWith(
          WebSocketEvent value, $Res Function(WebSocketEvent) then) =
      _$WebSocketEventCopyWithImpl<$Res, WebSocketEvent>;
}

/// @nodoc
class _$WebSocketEventCopyWithImpl<$Res, $Val extends WebSocketEvent>
    implements $WebSocketEventCopyWith<$Res> {
  _$WebSocketEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$DeviceWebSocketEventImplCopyWith<$Res> {
  factory _$$DeviceWebSocketEventImplCopyWith(_$DeviceWebSocketEventImpl value,
          $Res Function(_$DeviceWebSocketEventImpl) then) =
      __$$DeviceWebSocketEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({DeviceEvent event});

  $DeviceEventCopyWith<$Res> get event;
}

/// @nodoc
class __$$DeviceWebSocketEventImplCopyWithImpl<$Res>
    extends _$WebSocketEventCopyWithImpl<$Res, _$DeviceWebSocketEventImpl>
    implements _$$DeviceWebSocketEventImplCopyWith<$Res> {
  __$$DeviceWebSocketEventImplCopyWithImpl(_$DeviceWebSocketEventImpl _value,
      $Res Function(_$DeviceWebSocketEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? event = null,
  }) {
    return _then(_$DeviceWebSocketEventImpl(
      null == event
          ? _value.event
          : event // ignore: cast_nullable_to_non_nullable
              as DeviceEvent,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $DeviceEventCopyWith<$Res> get event {
    return $DeviceEventCopyWith<$Res>(_value.event, (value) {
      return _then(_value.copyWith(event: value));
    });
  }
}

/// @nodoc

class _$DeviceWebSocketEventImpl implements DeviceWebSocketEvent {
  const _$DeviceWebSocketEventImpl(this.event);

  @override
  final DeviceEvent event;

  @override
  String toString() {
    return 'WebSocketEvent.device(event: $event)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceWebSocketEventImpl &&
            (identical(other.event, event) || other.event == event));
  }

  @override
  int get hashCode => Object.hash(runtimeType, event);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceWebSocketEventImplCopyWith<_$DeviceWebSocketEventImpl>
      get copyWith =>
          __$$DeviceWebSocketEventImplCopyWithImpl<_$DeviceWebSocketEventImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(DeviceEvent event) device,
    required TResult Function(RoomEvent event) room,
    required TResult Function(NotificationEvent event) notification,
    required TResult Function(SyncEvent event) sync,
    required TResult Function(ConnectionEvent event) connection,
    required TResult Function(String type, Map<String, dynamic> payload)
        unknown,
  }) {
    return device(event);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(DeviceEvent event)? device,
    TResult? Function(RoomEvent event)? room,
    TResult? Function(NotificationEvent event)? notification,
    TResult? Function(SyncEvent event)? sync,
    TResult? Function(ConnectionEvent event)? connection,
    TResult? Function(String type, Map<String, dynamic> payload)? unknown,
  }) {
    return device?.call(event);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(DeviceEvent event)? device,
    TResult Function(RoomEvent event)? room,
    TResult Function(NotificationEvent event)? notification,
    TResult Function(SyncEvent event)? sync,
    TResult Function(ConnectionEvent event)? connection,
    TResult Function(String type, Map<String, dynamic> payload)? unknown,
    required TResult orElse(),
  }) {
    if (device != null) {
      return device(event);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DeviceWebSocketEvent value) device,
    required TResult Function(RoomWebSocketEvent value) room,
    required TResult Function(NotificationWebSocketEvent value) notification,
    required TResult Function(SyncWebSocketEvent value) sync,
    required TResult Function(ConnectionWebSocketEvent value) connection,
    required TResult Function(UnknownWebSocketEvent value) unknown,
  }) {
    return device(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DeviceWebSocketEvent value)? device,
    TResult? Function(RoomWebSocketEvent value)? room,
    TResult? Function(NotificationWebSocketEvent value)? notification,
    TResult? Function(SyncWebSocketEvent value)? sync,
    TResult? Function(ConnectionWebSocketEvent value)? connection,
    TResult? Function(UnknownWebSocketEvent value)? unknown,
  }) {
    return device?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DeviceWebSocketEvent value)? device,
    TResult Function(RoomWebSocketEvent value)? room,
    TResult Function(NotificationWebSocketEvent value)? notification,
    TResult Function(SyncWebSocketEvent value)? sync,
    TResult Function(ConnectionWebSocketEvent value)? connection,
    TResult Function(UnknownWebSocketEvent value)? unknown,
    required TResult orElse(),
  }) {
    if (device != null) {
      return device(this);
    }
    return orElse();
  }
}

abstract class DeviceWebSocketEvent implements WebSocketEvent {
  const factory DeviceWebSocketEvent(final DeviceEvent event) =
      _$DeviceWebSocketEventImpl;

  DeviceEvent get event;
  @JsonKey(ignore: true)
  _$$DeviceWebSocketEventImplCopyWith<_$DeviceWebSocketEventImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RoomWebSocketEventImplCopyWith<$Res> {
  factory _$$RoomWebSocketEventImplCopyWith(_$RoomWebSocketEventImpl value,
          $Res Function(_$RoomWebSocketEventImpl) then) =
      __$$RoomWebSocketEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({RoomEvent event});

  $RoomEventCopyWith<$Res> get event;
}

/// @nodoc
class __$$RoomWebSocketEventImplCopyWithImpl<$Res>
    extends _$WebSocketEventCopyWithImpl<$Res, _$RoomWebSocketEventImpl>
    implements _$$RoomWebSocketEventImplCopyWith<$Res> {
  __$$RoomWebSocketEventImplCopyWithImpl(_$RoomWebSocketEventImpl _value,
      $Res Function(_$RoomWebSocketEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? event = null,
  }) {
    return _then(_$RoomWebSocketEventImpl(
      null == event
          ? _value.event
          : event // ignore: cast_nullable_to_non_nullable
              as RoomEvent,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $RoomEventCopyWith<$Res> get event {
    return $RoomEventCopyWith<$Res>(_value.event, (value) {
      return _then(_value.copyWith(event: value));
    });
  }
}

/// @nodoc

class _$RoomWebSocketEventImpl implements RoomWebSocketEvent {
  const _$RoomWebSocketEventImpl(this.event);

  @override
  final RoomEvent event;

  @override
  String toString() {
    return 'WebSocketEvent.room(event: $event)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoomWebSocketEventImpl &&
            (identical(other.event, event) || other.event == event));
  }

  @override
  int get hashCode => Object.hash(runtimeType, event);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RoomWebSocketEventImplCopyWith<_$RoomWebSocketEventImpl> get copyWith =>
      __$$RoomWebSocketEventImplCopyWithImpl<_$RoomWebSocketEventImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(DeviceEvent event) device,
    required TResult Function(RoomEvent event) room,
    required TResult Function(NotificationEvent event) notification,
    required TResult Function(SyncEvent event) sync,
    required TResult Function(ConnectionEvent event) connection,
    required TResult Function(String type, Map<String, dynamic> payload)
        unknown,
  }) {
    return room(event);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(DeviceEvent event)? device,
    TResult? Function(RoomEvent event)? room,
    TResult? Function(NotificationEvent event)? notification,
    TResult? Function(SyncEvent event)? sync,
    TResult? Function(ConnectionEvent event)? connection,
    TResult? Function(String type, Map<String, dynamic> payload)? unknown,
  }) {
    return room?.call(event);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(DeviceEvent event)? device,
    TResult Function(RoomEvent event)? room,
    TResult Function(NotificationEvent event)? notification,
    TResult Function(SyncEvent event)? sync,
    TResult Function(ConnectionEvent event)? connection,
    TResult Function(String type, Map<String, dynamic> payload)? unknown,
    required TResult orElse(),
  }) {
    if (room != null) {
      return room(event);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DeviceWebSocketEvent value) device,
    required TResult Function(RoomWebSocketEvent value) room,
    required TResult Function(NotificationWebSocketEvent value) notification,
    required TResult Function(SyncWebSocketEvent value) sync,
    required TResult Function(ConnectionWebSocketEvent value) connection,
    required TResult Function(UnknownWebSocketEvent value) unknown,
  }) {
    return room(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DeviceWebSocketEvent value)? device,
    TResult? Function(RoomWebSocketEvent value)? room,
    TResult? Function(NotificationWebSocketEvent value)? notification,
    TResult? Function(SyncWebSocketEvent value)? sync,
    TResult? Function(ConnectionWebSocketEvent value)? connection,
    TResult? Function(UnknownWebSocketEvent value)? unknown,
  }) {
    return room?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DeviceWebSocketEvent value)? device,
    TResult Function(RoomWebSocketEvent value)? room,
    TResult Function(NotificationWebSocketEvent value)? notification,
    TResult Function(SyncWebSocketEvent value)? sync,
    TResult Function(ConnectionWebSocketEvent value)? connection,
    TResult Function(UnknownWebSocketEvent value)? unknown,
    required TResult orElse(),
  }) {
    if (room != null) {
      return room(this);
    }
    return orElse();
  }
}

abstract class RoomWebSocketEvent implements WebSocketEvent {
  const factory RoomWebSocketEvent(final RoomEvent event) =
      _$RoomWebSocketEventImpl;

  RoomEvent get event;
  @JsonKey(ignore: true)
  _$$RoomWebSocketEventImplCopyWith<_$RoomWebSocketEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$NotificationWebSocketEventImplCopyWith<$Res> {
  factory _$$NotificationWebSocketEventImplCopyWith(
          _$NotificationWebSocketEventImpl value,
          $Res Function(_$NotificationWebSocketEventImpl) then) =
      __$$NotificationWebSocketEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({NotificationEvent event});

  $NotificationEventCopyWith<$Res> get event;
}

/// @nodoc
class __$$NotificationWebSocketEventImplCopyWithImpl<$Res>
    extends _$WebSocketEventCopyWithImpl<$Res, _$NotificationWebSocketEventImpl>
    implements _$$NotificationWebSocketEventImplCopyWith<$Res> {
  __$$NotificationWebSocketEventImplCopyWithImpl(
      _$NotificationWebSocketEventImpl _value,
      $Res Function(_$NotificationWebSocketEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? event = null,
  }) {
    return _then(_$NotificationWebSocketEventImpl(
      null == event
          ? _value.event
          : event // ignore: cast_nullable_to_non_nullable
              as NotificationEvent,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $NotificationEventCopyWith<$Res> get event {
    return $NotificationEventCopyWith<$Res>(_value.event, (value) {
      return _then(_value.copyWith(event: value));
    });
  }
}

/// @nodoc

class _$NotificationWebSocketEventImpl implements NotificationWebSocketEvent {
  const _$NotificationWebSocketEventImpl(this.event);

  @override
  final NotificationEvent event;

  @override
  String toString() {
    return 'WebSocketEvent.notification(event: $event)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationWebSocketEventImpl &&
            (identical(other.event, event) || other.event == event));
  }

  @override
  int get hashCode => Object.hash(runtimeType, event);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationWebSocketEventImplCopyWith<_$NotificationWebSocketEventImpl>
      get copyWith => __$$NotificationWebSocketEventImplCopyWithImpl<
          _$NotificationWebSocketEventImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(DeviceEvent event) device,
    required TResult Function(RoomEvent event) room,
    required TResult Function(NotificationEvent event) notification,
    required TResult Function(SyncEvent event) sync,
    required TResult Function(ConnectionEvent event) connection,
    required TResult Function(String type, Map<String, dynamic> payload)
        unknown,
  }) {
    return notification(event);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(DeviceEvent event)? device,
    TResult? Function(RoomEvent event)? room,
    TResult? Function(NotificationEvent event)? notification,
    TResult? Function(SyncEvent event)? sync,
    TResult? Function(ConnectionEvent event)? connection,
    TResult? Function(String type, Map<String, dynamic> payload)? unknown,
  }) {
    return notification?.call(event);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(DeviceEvent event)? device,
    TResult Function(RoomEvent event)? room,
    TResult Function(NotificationEvent event)? notification,
    TResult Function(SyncEvent event)? sync,
    TResult Function(ConnectionEvent event)? connection,
    TResult Function(String type, Map<String, dynamic> payload)? unknown,
    required TResult orElse(),
  }) {
    if (notification != null) {
      return notification(event);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DeviceWebSocketEvent value) device,
    required TResult Function(RoomWebSocketEvent value) room,
    required TResult Function(NotificationWebSocketEvent value) notification,
    required TResult Function(SyncWebSocketEvent value) sync,
    required TResult Function(ConnectionWebSocketEvent value) connection,
    required TResult Function(UnknownWebSocketEvent value) unknown,
  }) {
    return notification(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DeviceWebSocketEvent value)? device,
    TResult? Function(RoomWebSocketEvent value)? room,
    TResult? Function(NotificationWebSocketEvent value)? notification,
    TResult? Function(SyncWebSocketEvent value)? sync,
    TResult? Function(ConnectionWebSocketEvent value)? connection,
    TResult? Function(UnknownWebSocketEvent value)? unknown,
  }) {
    return notification?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DeviceWebSocketEvent value)? device,
    TResult Function(RoomWebSocketEvent value)? room,
    TResult Function(NotificationWebSocketEvent value)? notification,
    TResult Function(SyncWebSocketEvent value)? sync,
    TResult Function(ConnectionWebSocketEvent value)? connection,
    TResult Function(UnknownWebSocketEvent value)? unknown,
    required TResult orElse(),
  }) {
    if (notification != null) {
      return notification(this);
    }
    return orElse();
  }
}

abstract class NotificationWebSocketEvent implements WebSocketEvent {
  const factory NotificationWebSocketEvent(final NotificationEvent event) =
      _$NotificationWebSocketEventImpl;

  NotificationEvent get event;
  @JsonKey(ignore: true)
  _$$NotificationWebSocketEventImplCopyWith<_$NotificationWebSocketEventImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SyncWebSocketEventImplCopyWith<$Res> {
  factory _$$SyncWebSocketEventImplCopyWith(_$SyncWebSocketEventImpl value,
          $Res Function(_$SyncWebSocketEventImpl) then) =
      __$$SyncWebSocketEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({SyncEvent event});

  $SyncEventCopyWith<$Res> get event;
}

/// @nodoc
class __$$SyncWebSocketEventImplCopyWithImpl<$Res>
    extends _$WebSocketEventCopyWithImpl<$Res, _$SyncWebSocketEventImpl>
    implements _$$SyncWebSocketEventImplCopyWith<$Res> {
  __$$SyncWebSocketEventImplCopyWithImpl(_$SyncWebSocketEventImpl _value,
      $Res Function(_$SyncWebSocketEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? event = null,
  }) {
    return _then(_$SyncWebSocketEventImpl(
      null == event
          ? _value.event
          : event // ignore: cast_nullable_to_non_nullable
              as SyncEvent,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $SyncEventCopyWith<$Res> get event {
    return $SyncEventCopyWith<$Res>(_value.event, (value) {
      return _then(_value.copyWith(event: value));
    });
  }
}

/// @nodoc

class _$SyncWebSocketEventImpl implements SyncWebSocketEvent {
  const _$SyncWebSocketEventImpl(this.event);

  @override
  final SyncEvent event;

  @override
  String toString() {
    return 'WebSocketEvent.sync(event: $event)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SyncWebSocketEventImpl &&
            (identical(other.event, event) || other.event == event));
  }

  @override
  int get hashCode => Object.hash(runtimeType, event);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SyncWebSocketEventImplCopyWith<_$SyncWebSocketEventImpl> get copyWith =>
      __$$SyncWebSocketEventImplCopyWithImpl<_$SyncWebSocketEventImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(DeviceEvent event) device,
    required TResult Function(RoomEvent event) room,
    required TResult Function(NotificationEvent event) notification,
    required TResult Function(SyncEvent event) sync,
    required TResult Function(ConnectionEvent event) connection,
    required TResult Function(String type, Map<String, dynamic> payload)
        unknown,
  }) {
    return sync(event);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(DeviceEvent event)? device,
    TResult? Function(RoomEvent event)? room,
    TResult? Function(NotificationEvent event)? notification,
    TResult? Function(SyncEvent event)? sync,
    TResult? Function(ConnectionEvent event)? connection,
    TResult? Function(String type, Map<String, dynamic> payload)? unknown,
  }) {
    return sync?.call(event);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(DeviceEvent event)? device,
    TResult Function(RoomEvent event)? room,
    TResult Function(NotificationEvent event)? notification,
    TResult Function(SyncEvent event)? sync,
    TResult Function(ConnectionEvent event)? connection,
    TResult Function(String type, Map<String, dynamic> payload)? unknown,
    required TResult orElse(),
  }) {
    if (sync != null) {
      return sync(event);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DeviceWebSocketEvent value) device,
    required TResult Function(RoomWebSocketEvent value) room,
    required TResult Function(NotificationWebSocketEvent value) notification,
    required TResult Function(SyncWebSocketEvent value) sync,
    required TResult Function(ConnectionWebSocketEvent value) connection,
    required TResult Function(UnknownWebSocketEvent value) unknown,
  }) {
    return sync(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DeviceWebSocketEvent value)? device,
    TResult? Function(RoomWebSocketEvent value)? room,
    TResult? Function(NotificationWebSocketEvent value)? notification,
    TResult? Function(SyncWebSocketEvent value)? sync,
    TResult? Function(ConnectionWebSocketEvent value)? connection,
    TResult? Function(UnknownWebSocketEvent value)? unknown,
  }) {
    return sync?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DeviceWebSocketEvent value)? device,
    TResult Function(RoomWebSocketEvent value)? room,
    TResult Function(NotificationWebSocketEvent value)? notification,
    TResult Function(SyncWebSocketEvent value)? sync,
    TResult Function(ConnectionWebSocketEvent value)? connection,
    TResult Function(UnknownWebSocketEvent value)? unknown,
    required TResult orElse(),
  }) {
    if (sync != null) {
      return sync(this);
    }
    return orElse();
  }
}

abstract class SyncWebSocketEvent implements WebSocketEvent {
  const factory SyncWebSocketEvent(final SyncEvent event) =
      _$SyncWebSocketEventImpl;

  SyncEvent get event;
  @JsonKey(ignore: true)
  _$$SyncWebSocketEventImplCopyWith<_$SyncWebSocketEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ConnectionWebSocketEventImplCopyWith<$Res> {
  factory _$$ConnectionWebSocketEventImplCopyWith(
          _$ConnectionWebSocketEventImpl value,
          $Res Function(_$ConnectionWebSocketEventImpl) then) =
      __$$ConnectionWebSocketEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({ConnectionEvent event});

  $ConnectionEventCopyWith<$Res> get event;
}

/// @nodoc
class __$$ConnectionWebSocketEventImplCopyWithImpl<$Res>
    extends _$WebSocketEventCopyWithImpl<$Res, _$ConnectionWebSocketEventImpl>
    implements _$$ConnectionWebSocketEventImplCopyWith<$Res> {
  __$$ConnectionWebSocketEventImplCopyWithImpl(
      _$ConnectionWebSocketEventImpl _value,
      $Res Function(_$ConnectionWebSocketEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? event = null,
  }) {
    return _then(_$ConnectionWebSocketEventImpl(
      null == event
          ? _value.event
          : event // ignore: cast_nullable_to_non_nullable
              as ConnectionEvent,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $ConnectionEventCopyWith<$Res> get event {
    return $ConnectionEventCopyWith<$Res>(_value.event, (value) {
      return _then(_value.copyWith(event: value));
    });
  }
}

/// @nodoc

class _$ConnectionWebSocketEventImpl implements ConnectionWebSocketEvent {
  const _$ConnectionWebSocketEventImpl(this.event);

  @override
  final ConnectionEvent event;

  @override
  String toString() {
    return 'WebSocketEvent.connection(event: $event)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConnectionWebSocketEventImpl &&
            (identical(other.event, event) || other.event == event));
  }

  @override
  int get hashCode => Object.hash(runtimeType, event);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ConnectionWebSocketEventImplCopyWith<_$ConnectionWebSocketEventImpl>
      get copyWith => __$$ConnectionWebSocketEventImplCopyWithImpl<
          _$ConnectionWebSocketEventImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(DeviceEvent event) device,
    required TResult Function(RoomEvent event) room,
    required TResult Function(NotificationEvent event) notification,
    required TResult Function(SyncEvent event) sync,
    required TResult Function(ConnectionEvent event) connection,
    required TResult Function(String type, Map<String, dynamic> payload)
        unknown,
  }) {
    return connection(event);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(DeviceEvent event)? device,
    TResult? Function(RoomEvent event)? room,
    TResult? Function(NotificationEvent event)? notification,
    TResult? Function(SyncEvent event)? sync,
    TResult? Function(ConnectionEvent event)? connection,
    TResult? Function(String type, Map<String, dynamic> payload)? unknown,
  }) {
    return connection?.call(event);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(DeviceEvent event)? device,
    TResult Function(RoomEvent event)? room,
    TResult Function(NotificationEvent event)? notification,
    TResult Function(SyncEvent event)? sync,
    TResult Function(ConnectionEvent event)? connection,
    TResult Function(String type, Map<String, dynamic> payload)? unknown,
    required TResult orElse(),
  }) {
    if (connection != null) {
      return connection(event);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DeviceWebSocketEvent value) device,
    required TResult Function(RoomWebSocketEvent value) room,
    required TResult Function(NotificationWebSocketEvent value) notification,
    required TResult Function(SyncWebSocketEvent value) sync,
    required TResult Function(ConnectionWebSocketEvent value) connection,
    required TResult Function(UnknownWebSocketEvent value) unknown,
  }) {
    return connection(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DeviceWebSocketEvent value)? device,
    TResult? Function(RoomWebSocketEvent value)? room,
    TResult? Function(NotificationWebSocketEvent value)? notification,
    TResult? Function(SyncWebSocketEvent value)? sync,
    TResult? Function(ConnectionWebSocketEvent value)? connection,
    TResult? Function(UnknownWebSocketEvent value)? unknown,
  }) {
    return connection?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DeviceWebSocketEvent value)? device,
    TResult Function(RoomWebSocketEvent value)? room,
    TResult Function(NotificationWebSocketEvent value)? notification,
    TResult Function(SyncWebSocketEvent value)? sync,
    TResult Function(ConnectionWebSocketEvent value)? connection,
    TResult Function(UnknownWebSocketEvent value)? unknown,
    required TResult orElse(),
  }) {
    if (connection != null) {
      return connection(this);
    }
    return orElse();
  }
}

abstract class ConnectionWebSocketEvent implements WebSocketEvent {
  const factory ConnectionWebSocketEvent(final ConnectionEvent event) =
      _$ConnectionWebSocketEventImpl;

  ConnectionEvent get event;
  @JsonKey(ignore: true)
  _$$ConnectionWebSocketEventImplCopyWith<_$ConnectionWebSocketEventImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UnknownWebSocketEventImplCopyWith<$Res> {
  factory _$$UnknownWebSocketEventImplCopyWith(
          _$UnknownWebSocketEventImpl value,
          $Res Function(_$UnknownWebSocketEventImpl) then) =
      __$$UnknownWebSocketEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String type, Map<String, dynamic> payload});
}

/// @nodoc
class __$$UnknownWebSocketEventImplCopyWithImpl<$Res>
    extends _$WebSocketEventCopyWithImpl<$Res, _$UnknownWebSocketEventImpl>
    implements _$$UnknownWebSocketEventImplCopyWith<$Res> {
  __$$UnknownWebSocketEventImplCopyWithImpl(_$UnknownWebSocketEventImpl _value,
      $Res Function(_$UnknownWebSocketEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? payload = null,
  }) {
    return _then(_$UnknownWebSocketEventImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      payload: null == payload
          ? _value._payload
          : payload // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc

class _$UnknownWebSocketEventImpl implements UnknownWebSocketEvent {
  const _$UnknownWebSocketEventImpl(
      {required this.type, required final Map<String, dynamic> payload})
      : _payload = payload;

  @override
  final String type;
  final Map<String, dynamic> _payload;
  @override
  Map<String, dynamic> get payload {
    if (_payload is EqualUnmodifiableMapView) return _payload;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_payload);
  }

  @override
  String toString() {
    return 'WebSocketEvent.unknown(type: $type, payload: $payload)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnknownWebSocketEventImpl &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._payload, _payload));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, type, const DeepCollectionEquality().hash(_payload));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UnknownWebSocketEventImplCopyWith<_$UnknownWebSocketEventImpl>
      get copyWith => __$$UnknownWebSocketEventImplCopyWithImpl<
          _$UnknownWebSocketEventImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(DeviceEvent event) device,
    required TResult Function(RoomEvent event) room,
    required TResult Function(NotificationEvent event) notification,
    required TResult Function(SyncEvent event) sync,
    required TResult Function(ConnectionEvent event) connection,
    required TResult Function(String type, Map<String, dynamic> payload)
        unknown,
  }) {
    return unknown(type, payload);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(DeviceEvent event)? device,
    TResult? Function(RoomEvent event)? room,
    TResult? Function(NotificationEvent event)? notification,
    TResult? Function(SyncEvent event)? sync,
    TResult? Function(ConnectionEvent event)? connection,
    TResult? Function(String type, Map<String, dynamic> payload)? unknown,
  }) {
    return unknown?.call(type, payload);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(DeviceEvent event)? device,
    TResult Function(RoomEvent event)? room,
    TResult Function(NotificationEvent event)? notification,
    TResult Function(SyncEvent event)? sync,
    TResult Function(ConnectionEvent event)? connection,
    TResult Function(String type, Map<String, dynamic> payload)? unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(type, payload);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DeviceWebSocketEvent value) device,
    required TResult Function(RoomWebSocketEvent value) room,
    required TResult Function(NotificationWebSocketEvent value) notification,
    required TResult Function(SyncWebSocketEvent value) sync,
    required TResult Function(ConnectionWebSocketEvent value) connection,
    required TResult Function(UnknownWebSocketEvent value) unknown,
  }) {
    return unknown(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DeviceWebSocketEvent value)? device,
    TResult? Function(RoomWebSocketEvent value)? room,
    TResult? Function(NotificationWebSocketEvent value)? notification,
    TResult? Function(SyncWebSocketEvent value)? sync,
    TResult? Function(ConnectionWebSocketEvent value)? connection,
    TResult? Function(UnknownWebSocketEvent value)? unknown,
  }) {
    return unknown?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DeviceWebSocketEvent value)? device,
    TResult Function(RoomWebSocketEvent value)? room,
    TResult Function(NotificationWebSocketEvent value)? notification,
    TResult Function(SyncWebSocketEvent value)? sync,
    TResult Function(ConnectionWebSocketEvent value)? connection,
    TResult Function(UnknownWebSocketEvent value)? unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(this);
    }
    return orElse();
  }
}

abstract class UnknownWebSocketEvent implements WebSocketEvent {
  const factory UnknownWebSocketEvent(
          {required final String type,
          required final Map<String, dynamic> payload}) =
      _$UnknownWebSocketEventImpl;

  String get type;
  Map<String, dynamic> get payload;
  @JsonKey(ignore: true)
  _$$UnknownWebSocketEventImplCopyWith<_$UnknownWebSocketEventImpl>
      get copyWith => throw _privateConstructorUsedError;
}
