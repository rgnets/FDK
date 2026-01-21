import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/room.dart';

part 'device.freezed.dart';

@freezed
class Device with _$Device {
  const factory Device({
    required String id,
    required String name,
    required String type,
    required String status,
    Room? pmsRoom,
    int? pmsRoomId,
    String? ipAddress,
    String? macAddress,
    String? location,
    DateTime? lastSeen,
    Map<String, dynamic>? metadata,
    String? model,
    String? serialNumber,
    String? firmware,
    int? signalStrength,
    int? uptime,
    int? connectedClients,
    int? vlan,
    String? ssid,
    int? channel,
    int? totalUpload,
    int? totalDownload,
    double? currentUpload,
    double? currentDownload,
    double? packetLoss,
    int? latency,
    int? cpuUsage,
    int? memoryUsage,
    int? temperature,
    int? restartCount,
    int? maxClients,
    String? note,
    List<String>? images,
    String? phase,
  }) = _Device;
  
  const Device._();
}

extension DeviceX on Device {
  bool get isOnline => status.toLowerCase() == 'online';
  bool get isOffline => status.toLowerCase() == 'offline';
  bool get hasIssue => status.toLowerCase() == 'warning' || status.toLowerCase() == 'error';
}