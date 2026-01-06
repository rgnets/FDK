import 'package:freezed_annotation/freezed_annotation.dart';

part 'network_device_model.freezed.dart';
part 'network_device_model.g.dart';

@Freezed(unionKey: 'device_type')
sealed class NetworkDevice with _$NetworkDevice {
  @FreezedUnionValue('ont')
  const factory NetworkDevice.ont({
    required int id,
    required String name,
    required bool online,
    String? note,
    String? model,
    String? version,
    @JsonKey(name: 'serial_number') String? serialNumber,
    String? phase,
    String? mac,
    String? ip,
    @JsonKey(name: 'is_registered') bool? isRegistered,
    @JsonKey(name: 'pms_room') Map<String, dynamic>? pmsRoom,
    String? uptime,
    @JsonKey(name: 'switch_port') Map<String, dynamic>? switchPort,
    @JsonKey(name: 'ont_onboarding_status') Map<String, dynamic>? onboardingStatus,
    @JsonKey(name: 'ont_ports') @Default([]) List<Map<String, dynamic>> ports,
    @Default([]) List<dynamic> images,
  }) = ONTDevice;

  @FreezedUnionValue('ap')
  const factory NetworkDevice.ap({
    required int id,
    required String name,
    required bool online,
    String? note,
    String? model,
    String? version,
    @JsonKey(name: 'serial_number') String? serialNumber,
    String? phase,
    String? mac,
    String? ip,
    String? uptime,
    @JsonKey(name: 'connection_state') String? connectionState,
    @JsonKey(name: 'pms_room') Map<String, dynamic>? pmsRoom,
    @JsonKey(name: 'ap_onboarding_status') Map<String, dynamic>? onboardingStatus,
    @Default([]) List<dynamic> images,
  }) = APDevice;

  @FreezedUnionValue('switch')
  const factory NetworkDevice.switchDevice({
    required int id,
    required String name,
    required bool online,
    String? note,
    String? model,
    String? version,
    @JsonKey(name: 'serial_number') String? serialNumber,
    String? phase,
    String? mac,
    String? host,
    @JsonKey(name: 'ip_address') String? ipAddress,
    @JsonKey(name: 'switch_ports') @Default([]) List<Map<String, dynamic>> ports,
    @JsonKey(name: 'last_config_sync_at') DateTime? lastConfigSync,
    @JsonKey(name: 'last_config_sync_attempt_at') DateTime? lastConfigSyncAttempt,
    @Default([]) List<dynamic> images,
  }) = SwitchDevice;

  factory NetworkDevice.fromJson(Map<String, dynamic> json) =>
      _$NetworkDeviceFromJson(json);
}
