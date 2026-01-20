import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/services/deeplink_service.dart';

/// Provider for the deeplink service.
///
/// The service is lazily initialized and kept alive for the app's lifetime.
/// Call [DeeplinkService.initialize] after reading this provider to set up
/// callbacks and start listening for deeplinks.
final deeplinkServiceProvider = Provider<DeeplinkService>((ref) {
  final service = DeeplinkService();

  ref.onDispose(service.dispose);

  return service;
});
