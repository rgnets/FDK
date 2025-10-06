import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/devices/data/models/room_model.dart';

part 'device_model.freezed.dart';
part 'device_model.g.dart';

@freezed
class DeviceModel with _$DeviceModel {
  const factory DeviceModel({
    required String id,
    required String name,
    required String type,
    required String status,
    @JsonKey(name: 'pms_room') RoomModel? pmsRoom,
    @JsonKey(name: 'pms_room_id') int? pmsRoomId,
    @JsonKey(name: 'ip_address') String? ipAddress,
    @JsonKey(name: 'mac_address') String? macAddress,
    String? location,
    @JsonKey(name: 'last_seen') DateTime? lastSeen,
    Map<String, dynamic>? metadata,
    String? model,
    @JsonKey(name: 'serial_number') String? serialNumber,
    String? firmware,
    @JsonKey(name: 'signal_strength') int? signalStrength,
    int? uptime,
    @JsonKey(name: 'connected_clients') int? connectedClients,
    int? vlan,
    String? ssid,
    int? channel,
    @JsonKey(name: 'total_upload') int? totalUpload,
    @JsonKey(name: 'total_download') int? totalDownload,
    @JsonKey(name: 'current_upload') double? currentUpload,
    @JsonKey(name: 'current_download') double? currentDownload,
    @JsonKey(name: 'packet_loss') double? packetLoss,
    int? latency,
    @JsonKey(name: 'cpu_usage') int? cpuUsage,
    @JsonKey(name: 'memory_usage') int? memoryUsage,
    int? temperature,
    @JsonKey(name: 'restart_count') int? restartCount,
    @JsonKey(name: 'max_clients') int? maxClients,
    String? note,
    List<String>? images,
  }) = _DeviceModel;

  factory DeviceModel.fromJson(Map<String, dynamic> json) =>
      _$DeviceModelFromJson(json);
}

extension DeviceModelX on DeviceModel {
  Device toEntity() {
    return Device(
      id: id,
      name: name,
      type: type,
      status: status,
      pmsRoom: pmsRoom?.toEntity(),
      pmsRoomId: pmsRoomId ?? pmsRoom?.id,
      ipAddress: ipAddress,
      macAddress: macAddress,
      location: location ?? pmsRoom?.name,
      lastSeen: lastSeen,
      metadata: metadata,
      model: model,
      serialNumber: serialNumber,
      firmware: firmware,
      signalStrength: signalStrength,
      uptime: uptime,
      connectedClients: connectedClients,
      vlan: vlan,
      ssid: ssid,
      channel: channel,
      totalUpload: totalUpload,
      totalDownload: totalDownload,
      currentUpload: currentUpload,
      currentDownload: currentDownload,
      packetLoss: packetLoss,
      latency: latency,
      cpuUsage: cpuUsage,
      memoryUsage: memoryUsage,
      temperature: temperature,
      restartCount: restartCount,
      maxClients: maxClients,
      note: note,
      images: images,
    );
  }
}

