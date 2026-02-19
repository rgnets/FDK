import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rgnets_fdk/features/devices/data/models/room_model.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/onboarding/data/models/onboarding_status_payload.dart'; // Assuming this path
import 'package:rgnets_fdk/features/issues/data/models/health_counts_model.dart';
import 'package:rgnets_fdk/features/issues/data/models/health_notice_model.dart';

part 'device_model_sealed.freezed.dart';
part 'device_model_sealed.g.dart';

/// Sealed class representing different device types with type-specific fields.
/// Uses Freezed union types for compile-time type safety and exhaustive pattern matching.
///
/// Device type routing is handled via a central ID-to-Type index (stored separately),
/// rather than embedding type information in device IDs.
@Freezed(unionKey: 'device_type')
sealed class DeviceModelSealed with _$DeviceModelSealed {
  const DeviceModelSealed._();

  // ============================================================================
  // Device Type Constants
  // ============================================================================

  /// Device type identifier for Access Points
  static const String typeAccessPoint = 'access_point';

  /// Device type identifier for ONT (Optical Network Terminal)
  static const String typeONT = 'ont';

  /// Device type identifier for Network Switches
  static const String typeSwitch = 'switch';

  /// Device type identifier for WLAN Controllers
  static const String typeWLAN = 'wlan_controller';

  /// All supported device types
  static const List<String> allTypes = [
    typeAccessPoint,
    typeONT,
    typeSwitch,
    typeWLAN,
  ];

  /// Maps WebSocket resource types to device type constants
  static const Map<String, String> resourceTypeToDeviceType = {
    'access_points': typeAccessPoint,
    'media_converters': typeONT,
    'switch_devices': typeSwitch,
    'wlan_devices': typeWLAN,
  };

  /// Maps device type constants to WebSocket resource types
  static const Map<String, String> deviceTypeToResourceType = {
    typeAccessPoint: 'access_points',
    typeONT: 'media_converters',
    typeSwitch: 'switch_devices',
    typeWLAN: 'wlan_devices',
  };

  /// Storage key for the ID-to-Type index
  static const String idTypeIndexKey = 'device_id_to_type_index';

  /// Returns the device type for a given resource type, or null if unknown
  static String? getDeviceTypeFromResourceType(String resourceType) {
    return resourceTypeToDeviceType[resourceType];
  }

  /// Returns the resource type for a given device type, or null if unknown
  static String? getResourceTypeFromDeviceType(String deviceType) {
    return deviceTypeToResourceType[deviceType];
  }

  // ============================================================================
  // Access Point Model
  // ============================================================================

  @FreezedUnionValue('access_point')
  const factory DeviceModelSealed.ap({
    // Common fields
    required String id,
    required String name,
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
    String? note,
    List<String>? images,
    @JsonKey(name: 'image_signed_ids') List<String>? imageSignedIds,
    @JsonKey(name: 'health_notices') List<HealthNoticeModel>? healthNotices,
    @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,

    // AP-specific fields
    @JsonKey(name: 'connection_state') String? connectionState,
    @JsonKey(name: 'signal_strength') int? signalStrength,
    @JsonKey(name: 'connected_clients') int? connectedClients,
    String? ssid,
    int? channel,
    @JsonKey(name: 'max_clients') int? maxClients,
    @JsonKey(name: 'current_upload') double? currentUpload,
    @JsonKey(name: 'current_download') double? currentDownload,
    @JsonKey(name: 'ap_onboarding_status') OnboardingStatusPayload? onboardingStatus,
  }) = APModel;

  // ============================================================================
  // ONT (Optical Network Terminal) Model
  // ============================================================================

  @FreezedUnionValue('ont')
  const factory DeviceModelSealed.ont({
    // Common fields
    required String id,
    required String name,
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
    String? note,
    List<String>? images,
    @JsonKey(name: 'image_signed_ids') List<String>? imageSignedIds,
    @JsonKey(name: 'health_notices') List<HealthNoticeModel>? healthNotices,
    @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,

    // ONT-specific fields
    @JsonKey(name: 'is_registered') bool? isRegistered,
    @JsonKey(name: 'switch_port') Map<String, dynamic>? switchPort,
    @JsonKey(name: 'ont_onboarding_status') OnboardingStatusPayload? onboardingStatus,
    @JsonKey(name: 'ont_ports') List<Map<String, dynamic>>? ports,
    String? uptime,
    String? phase,
  }) = ONTModel;

  // ============================================================================
  // Switch Model
  // ============================================================================

  @FreezedUnionValue('switch')
  const factory DeviceModelSealed.switchDevice({
    // Common fields
    required String id,
    required String name,
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
    String? note,
    List<String>? images,
    @JsonKey(name: 'image_signed_ids') List<String>? imageSignedIds,
    @JsonKey(name: 'health_notices') List<HealthNoticeModel>? healthNotices,
    @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,

    // Switch-specific fields
    String? host,
    @JsonKey(name: 'switch_ports') List<Map<String, dynamic>>? ports,
    @JsonKey(name: 'last_config_sync_at') DateTime? lastConfigSync,
    @JsonKey(name: 'last_config_sync_attempt_at') DateTime? lastConfigSyncAttempt,
    @JsonKey(name: 'cpu_usage') int? cpuUsage,
    @JsonKey(name: 'memory_usage') int? memoryUsage,
    int? temperature,
  }) = SwitchModel;

  // ============================================================================
  // WLAN Controller Model
  // ============================================================================

  @FreezedUnionValue('wlan_controller')
  const factory DeviceModelSealed.wlan({
    // Common fields
    required String id,
    required String name,
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
    String? note,
    List<String>? images,
    @JsonKey(name: 'image_signed_ids') List<String>? imageSignedIds,
    @JsonKey(name: 'health_notices') List<HealthNoticeModel>? healthNotices,
    @JsonKey(name: 'hn_counts') HealthCountsModel? hnCounts,

    // WLAN-specific fields
    @JsonKey(name: 'controller_type') String? controllerType,
    @JsonKey(name: 'managed_aps') int? managedAPs,
    int? vlan,
    @JsonKey(name: 'total_upload') int? totalUpload,
    @JsonKey(name: 'total_download') int? totalDownload,
    @JsonKey(name: 'packet_loss') double? packetLoss,
    int? latency,
    @JsonKey(name: 'restart_count') int? restartCount,
  }) = WLANModel;

  factory DeviceModelSealed.fromJson(Map<String, dynamic> json) =>
      _$DeviceModelSealedFromJson(json);
}

// ============================================================================
// Extension for converting to Domain Entity
// ============================================================================

extension DeviceModelSealedX on DeviceModelSealed {
  /// Converts this model to the unified [Device] domain entity
  Device toEntity() {
    return map(
      ap: (ap) => Device(
        id: ap.id,
        name: ap.name,
        type: DeviceModelSealed.typeAccessPoint,
        status: ap.status,
        pmsRoom: ap.pmsRoom?.toEntity(),
        pmsRoomId: ap.pmsRoomId ?? ap.pmsRoom?.id,
        ipAddress: ap.ipAddress,
        macAddress: ap.macAddress,
        location: ap.location ?? ap.pmsRoom?.name,
        lastSeen: ap.lastSeen,
        metadata: ap.metadata,
        model: ap.model,
        serialNumber: ap.serialNumber,
        firmware: ap.firmware,
        note: ap.note,
        images: ap.images,
        imageSignedIds: ap.imageSignedIds,
        signalStrength: ap.signalStrength,
        connectedClients: ap.connectedClients,
        ssid: ap.ssid,
        channel: ap.channel,
        maxClients: ap.maxClients,
        currentUpload: ap.currentUpload,
        currentDownload: ap.currentDownload,
        healthNotices: ap.healthNotices?.map((m) => m.toEntity()).toList(),
        hnCounts: ap.hnCounts?.toEntity(),
      ),
      ont: (ont) => Device(
        id: ont.id,
        name: ont.name,
        type: DeviceModelSealed.typeONT,
        status: ont.status,
        pmsRoom: ont.pmsRoom?.toEntity(),
        pmsRoomId: ont.pmsRoomId ?? ont.pmsRoom?.id,
        ipAddress: ont.ipAddress,
        macAddress: ont.macAddress,
        location: ont.location ?? ont.pmsRoom?.name,
        lastSeen: ont.lastSeen,
        metadata: ont.metadata,
        model: ont.model,
        serialNumber: ont.serialNumber,
        firmware: ont.firmware,
        note: ont.note,
        images: ont.images,
        imageSignedIds: ont.imageSignedIds,
        healthNotices: ont.healthNotices?.map((m) => m.toEntity()).toList(),
        hnCounts: ont.hnCounts?.toEntity(),
      ),
      switchDevice: (sw) => Device(
        id: sw.id,
        name: sw.name,
        type: DeviceModelSealed.typeSwitch,
        status: sw.status,
        pmsRoom: sw.pmsRoom?.toEntity(),
        pmsRoomId: sw.pmsRoomId ?? sw.pmsRoom?.id,
        ipAddress: sw.ipAddress ?? sw.host,
        macAddress: sw.macAddress,
        location: sw.location ?? sw.pmsRoom?.name,
        lastSeen: sw.lastSeen,
        metadata: sw.metadata,
        model: sw.model,
        serialNumber: sw.serialNumber,
        firmware: sw.firmware,
        note: sw.note,
        images: sw.images,
        imageSignedIds: sw.imageSignedIds,
        cpuUsage: sw.cpuUsage,
        memoryUsage: sw.memoryUsage,
        temperature: sw.temperature,
        healthNotices: sw.healthNotices?.map((m) => m.toEntity()).toList(),
        hnCounts: sw.hnCounts?.toEntity(),
      ),
      wlan: (wlan) => Device(
        id: wlan.id,
        name: wlan.name,
        type: DeviceModelSealed.typeWLAN,
        status: wlan.status,
        pmsRoom: wlan.pmsRoom?.toEntity(),
        pmsRoomId: wlan.pmsRoomId ?? wlan.pmsRoom?.id,
        ipAddress: wlan.ipAddress,
        macAddress: wlan.macAddress,
        location: wlan.location ?? wlan.pmsRoom?.name,
        lastSeen: wlan.lastSeen,
        metadata: wlan.metadata,
        model: wlan.model,
        serialNumber: wlan.serialNumber,
        firmware: wlan.firmware,
        note: wlan.note,
        images: wlan.images,
        imageSignedIds: wlan.imageSignedIds,
        vlan: wlan.vlan,
        totalUpload: wlan.totalUpload,
        totalDownload: wlan.totalDownload,
        packetLoss: wlan.packetLoss,
        latency: wlan.latency,
        restartCount: wlan.restartCount,
        healthNotices: wlan.healthNotices?.map((m) => m.toEntity()).toList(),
        hnCounts: wlan.hnCounts?.toEntity(),
      ),
    );
  }

  /// Returns the device type string for this model
  String get deviceType => map(
        ap: (_) => DeviceModelSealed.typeAccessPoint,
        ont: (_) => DeviceModelSealed.typeONT,
        switchDevice: (_) => DeviceModelSealed.typeSwitch,
        wlan: (_) => DeviceModelSealed.typeWLAN,
      );

  /// Common accessor for device ID (available on all types)
  String get deviceId => map(
        ap: (d) => d.id,
        ont: (d) => d.id,
        switchDevice: (d) => d.id,
        wlan: (d) => d.id,
      );

  /// Common accessor for device name (available on all types)
  String get deviceName => map(
        ap: (d) => d.name,
        ont: (d) => d.name,
        switchDevice: (d) => d.name,
        wlan: (d) => d.name,
      );

  /// Common accessor for device status (available on all types)
  String get deviceStatus => map(
        ap: (d) => d.status,
        ont: (d) => d.status,
        switchDevice: (d) => d.status,
        wlan: (d) => d.status,
      );

  /// Returns true if the device is online
  bool get isOnline => deviceStatus.toLowerCase() == 'online';

  /// Returns true if the device is offline
  bool get isOffline => deviceStatus.toLowerCase() == 'offline';

  /// Returns true if the device has an issue (warning or error status)
  bool get hasIssue {
    final status = deviceStatus.toLowerCase();
    return status == 'warning' || status == 'error';
  }
}
