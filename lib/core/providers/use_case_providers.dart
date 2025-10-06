import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/providers/repository_providers.dart';
import 'package:rgnets_fdk/features/auth/domain/usecases/authenticate_user.dart';
import 'package:rgnets_fdk/features/auth/domain/usecases/check_auth_status.dart';
import 'package:rgnets_fdk/features/auth/domain/usecases/get_current_user.dart';
import 'package:rgnets_fdk/features/auth/domain/usecases/sign_out_user.dart';
import 'package:rgnets_fdk/features/devices/domain/usecases/get_device.dart';
import 'package:rgnets_fdk/features/devices/domain/usecases/get_devices.dart';
import 'package:rgnets_fdk/features/devices/domain/usecases/reboot_device.dart';
import 'package:rgnets_fdk/features/devices/domain/usecases/search_devices.dart';
import 'package:rgnets_fdk/features/notifications/domain/usecases/clear_notifications.dart';
import 'package:rgnets_fdk/features/notifications/domain/usecases/get_notifications.dart';
import 'package:rgnets_fdk/features/notifications/domain/usecases/get_unread_count.dart';
import 'package:rgnets_fdk/features/notifications/domain/usecases/mark_all_as_read.dart';
import 'package:rgnets_fdk/features/notifications/domain/usecases/mark_as_read.dart';
import 'package:rgnets_fdk/features/rooms/domain/usecases/get_rooms.dart';
import 'package:rgnets_fdk/features/scanner/domain/usecases/complete_scan_session.dart';
import 'package:rgnets_fdk/features/scanner/domain/usecases/get_current_session.dart';
import 'package:rgnets_fdk/features/scanner/domain/usecases/process_barcode.dart';
import 'package:rgnets_fdk/features/scanner/domain/usecases/start_scan_session.dart';
import 'package:rgnets_fdk/features/scanner/domain/usecases/validate_device_scan.dart';
import 'package:rgnets_fdk/features/settings/domain/usecases/clear_cache.dart';
import 'package:rgnets_fdk/features/settings/domain/usecases/export_settings.dart';
import 'package:rgnets_fdk/features/settings/domain/usecases/get_settings.dart';
import 'package:rgnets_fdk/features/settings/domain/usecases/import_settings.dart';
import 'package:rgnets_fdk/features/settings/domain/usecases/reset_settings.dart';
import 'package:rgnets_fdk/features/settings/domain/usecases/update_settings.dart';

// ============================================================================
// Auth Use Cases
// ============================================================================

final authenticateUserProvider = Provider<AuthenticateUser>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthenticateUser(repository);
});

final checkAuthStatusProvider = Provider<CheckAuthStatus>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return CheckAuthStatus(repository);
});

final getCurrentUserProvider = Provider<GetCurrentUser>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUser(repository);
});

final signOutUserProvider = Provider<SignOutUser>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignOutUser(repository);
});

// ============================================================================
// Device Use Cases
// ============================================================================

final getDevicesProvider = Provider<GetDevices>((ref) {
  final repository = ref.watch(deviceRepositoryProvider);
  return GetDevices(repository);
});

final getDeviceProvider = Provider<GetDevice>((ref) {
  final repository = ref.watch(deviceRepositoryProvider);
  return GetDevice(repository);
});

final searchDevicesProvider = Provider<SearchDevices>((ref) {
  final repository = ref.watch(deviceRepositoryProvider);
  return SearchDevices(repository);
});

final rebootDeviceProvider = Provider<RebootDevice>((ref) {
  final repository = ref.watch(deviceRepositoryProvider);
  return RebootDevice(repository);
});

// ============================================================================
// Room Use Cases
// ============================================================================

final getRoomsProvider = Provider<GetRooms>((ref) {
  final repository = ref.watch(roomRepositoryProvider);
  return GetRooms(repository);
});

// ============================================================================
// Notification Use Cases
// ============================================================================

final getNotificationsProvider = Provider<GetNotifications>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return GetNotifications(repository);
});

final markAsReadProvider = Provider<MarkAsRead>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return MarkAsRead(repository);
});

final markAllAsReadProvider = Provider<MarkAllAsRead>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return MarkAllAsRead(repository);
});

final getUnreadCountProvider = Provider<GetUnreadCount>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return GetUnreadCount(repository);
});

final clearNotificationsProvider = Provider<ClearNotifications>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return ClearNotifications(repository);
});

// ============================================================================
// Scanner Use Cases
// ============================================================================

final startScanSessionProvider = Provider<StartScanSession>((ref) {
  final repository = ref.watch(scannerRepositoryProvider);
  return StartScanSession(repository);
});

final processBarcodeProvider = Provider<ProcessBarcode>((ref) {
  final repository = ref.watch(scannerRepositoryProvider);
  return ProcessBarcode(repository);
});

final completeScanSessionProvider = Provider<CompleteScanSession>((ref) {
  final repository = ref.watch(scannerRepositoryProvider);
  return CompleteScanSession(repository);
});

final getCurrentSessionProvider = Provider<GetCurrentSession>((ref) {
  final repository = ref.watch(scannerRepositoryProvider);
  return GetCurrentSession(repository);
});

final validateDeviceScanProvider = Provider<ValidateDeviceScan>((ref) {
  return ValidateDeviceScan();
});

// ============================================================================
// Settings Use Cases
// ============================================================================

final getSettingsProvider = Provider<GetSettings>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return GetSettings(repository);
});

final updateSettingsProvider = Provider<UpdateSettings>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return UpdateSettings(repository);
});

final resetSettingsProvider = Provider<ResetSettings>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return ResetSettings(repository);
});

final clearCacheProvider = Provider<ClearCache>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return ClearCache(repository);
});

final exportSettingsProvider = Provider<ExportSettings>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return ExportSettings(repository);
});

final importSettingsProvider = Provider<ImportSettings>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return ImportSettings(repository);
});