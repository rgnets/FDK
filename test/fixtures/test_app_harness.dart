import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/providers/repository_providers.dart';
import 'package:rgnets_fdk/core/providers/websocket_providers.dart';
import 'package:rgnets_fdk/core/services/background_refresh_service.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:rgnets_fdk/features/auth/domain/entities/auth_status.dart';
import 'package:rgnets_fdk/features/auth/domain/entities/user.dart';
import 'package:rgnets_fdk/features/auth/presentation/providers/auth_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mock user for development mode testing
const mockDevUser = User(
  username: 'dev_user',
  siteUrl: 'https://dev.example.com',
  email: 'dev@example.com',
);

/// Test auth notifier that returns pre-configured auth status
class MockAuthNotifier extends Auth {
  MockAuthNotifier({
    required this.initialStatus,
    this.authenticateStatus,
  });

  final AuthStatus initialStatus;
  final AuthStatus? authenticateStatus;

  @override
  Future<AuthStatus> build() async => initialStatus;

  @override
  Future<void> authenticate({
    required String fqdn,
    required String login,
    required String token,
    String? siteName,
    DateTime? issuedAt,
    String? signature,
  }) async {
    final nextStatus = authenticateStatus ?? initialStatus;
    state = AsyncValue.data(nextStatus);
  }

  @override
  Future<void> logout() async {
    state = const AsyncValue.data(AuthStatus.unauthenticated());
  }
}

/// Override auth provider for testing
Override overrideMockAuth({
  AuthStatus? initialStatus,
  AuthStatus? authenticateStatus,
}) {
  final status = initialStatus ??
      (EnvironmentConfig.isDevelopment
          ? const AuthStatus.authenticated(mockDevUser)
          : const AuthStatus.unauthenticated());

  return authProvider.overrideWith(
    () => MockAuthNotifier(
      initialStatus: status,
      authenticateStatus: authenticateStatus ?? status,
    ),
  );
}

/// A no-op WebSocket service for testing that doesn't create any timers.
/// This prevents pending timer issues in widget tests.
class NoopWebSocketService extends WebSocketService {
  NoopWebSocketService()
      : super(
          config: WebSocketConfig(
            baseUri: Uri.parse('wss://test.example.com'),
            autoReconnect: false,
            sendClientPing: false,
          ),
        );

  final _stateController = StreamController<SocketConnectionState>.broadcast();
  final _messageController = StreamController<SocketMessage>.broadcast();

  @override
  Stream<SocketConnectionState> get connectionState => _stateController.stream;

  @override
  Stream<SocketMessage> get messages => _messageController.stream;

  @override
  SocketConnectionState get currentState => SocketConnectionState.disconnected;

  @override
  bool get isConnected => false;

  @override
  Future<void> connect(WebSocketConnectionParams params) async {}

  @override
  Future<void> disconnect({int? code, String? reason}) async {}

  @override
  void send(Map<String, dynamic> message) {}

  @override
  void sendType(String type, {Map<String, dynamic>? payload, Map<String, dynamic>? headers}) {}

  @override
  Future<SocketMessage> request(Map<String, dynamic> message, {Duration timeout = const Duration(seconds: 30)}) {
    return Future.error(StateError('NoopWebSocketService: not connected'));
  }

  @override
  Future<void> dispose() async {
    await _stateController.close();
    await _messageController.close();
  }
}

class NoopBackgroundRefreshService extends BackgroundRefreshService {
  NoopBackgroundRefreshService({
    required super.deviceDataSource,
    required super.apLocalDataSource,
    required super.ontLocalDataSource,
    required super.switchLocalDataSource,
    required super.wlanLocalDataSource,
    required super.roomRepository,
    required super.notificationGenerationService,
    required super.storageService,
    required super.webSocketService,
    required super.webSocketDataSyncService,
  });

  @override
  void startBackgroundRefresh() {}

  @override
  Future<void> refreshNow() async {}
}

ProviderContainer createTestContainer({
  required SharedPreferences sharedPreferences,
  List<Override> overrides = const [],
  bool autoAuthInDev = true,
}) {
  // Create a shared NoopWebSocketService instance for the container
  final noopWebSocketService = NoopWebSocketService();

  // Build the list of overrides
  final allOverrides = <Override>[
    sharedPreferencesProvider.overrideWithValue(sharedPreferences),
    // Override WebSocket service to prevent timer creation
    webSocketServiceProvider.overrideWith((ref) {
      ref.onDispose(noopWebSocketService.dispose);
      return noopWebSocketService;
    }),
    backgroundRefreshServiceProvider.overrideWith((ref) {
      final service = NoopBackgroundRefreshService(
        deviceDataSource: ref.watch(deviceDataSourceProvider),
        apLocalDataSource: ref.watch(apLocalDataSourceProvider),
        ontLocalDataSource: ref.watch(ontLocalDataSourceProvider),
        switchLocalDataSource: ref.watch(switchLocalDataSourceProvider),
        wlanLocalDataSource: ref.watch(wlanLocalDataSourceProvider),
        roomRepository: ref.watch(roomRepositoryProvider),
        notificationGenerationService:
            ref.watch(notificationGenerationServiceProvider),
        storageService: ref.watch(storageServiceProvider),
        webSocketService: ref.watch(webSocketServiceProvider),
        webSocketDataSyncService: ref.watch(webSocketDataSyncServiceProvider),
      );

      ref.onDispose(service.dispose);
      return service;
    }),
  ];

  // Auto-authenticate in development mode if requested
  if (autoAuthInDev && EnvironmentConfig.isDevelopment) {
    allOverrides.add(overrideMockAuth());
  }

  // Add user-provided overrides last so they can override defaults
  allOverrides.addAll(overrides);

  final container = ProviderContainer(overrides: allOverrides);

  addTearDown(container.dispose);
  return container;
}

Widget wrapWithContainer({
  required ProviderContainer container,
  required Widget child,
}) {
  return UncontrolledProviderScope(
    container: container,
    child: child,
  );
}
