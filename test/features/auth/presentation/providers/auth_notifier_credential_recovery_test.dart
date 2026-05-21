import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/providers/repository_providers.dart';
import 'package:rgnets_fdk/core/services/secure_storage_service.dart';
import 'package:rgnets_fdk/core/services/storage_service.dart';
import 'package:rgnets_fdk/features/auth/domain/entities/user.dart';
import 'package:rgnets_fdk/features/auth/domain/repositories/auth_repository.dart';
import 'package:rgnets_fdk/features/auth/presentation/providers/auth_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Auth credential recovery — narrow regression coverage.
///
/// History: this file previously tested five sub-scenarios, but three of
/// them asserted only `expect(authState, isA<AuthStatus>())`, which passes
/// for any return value and verifies nothing. The other two — "no creds in
/// storage" and "empty-string creds in storage" — both assert
/// `isUnauthenticated == true`, which is the meaningful guard against an
/// auth provider falsely reporting authenticated when storage is empty or
/// contains sentinel empty strings. Only those two cases remain here.
///
/// The previous version also imported a renamed `StorageService` method
/// (`migrateLegacyCredentialsIfNeeded` → renamed to
/// `migrateToSecureStorageIfNeeded` in commit bb40f45) and used the old
/// single-arg constructor — both compile errors against current code.

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSecureStorageService extends Mock implements SecureStorageService {}

class MockLogger extends Mock implements Logger {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository mockAuthRepository;
  late MockSecureStorageService mockSecureStorage;
  late MockLogger mockLogger;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockSecureStorage = MockSecureStorageService();
    mockLogger = MockLogger();

    // Stubs for the Logger surface used by the auth provider.
    when(() => mockLogger.i(any())).thenReturn(null);
    when(() => mockLogger.d(any())).thenReturn(null);
    when(() => mockLogger.w(any())).thenReturn(null);
    when(() => mockLogger.e(any())).thenReturn(null);

    // The auth provider reads secure-storage during recovery; default it
    // to "no token persisted" so the unauthenticated path is reached
    // deterministically. `migrateToSecureStorageIfNeeded` (called from
    // `Auth.build`) probes `isAvailable` first and bails if it returns
    // false, so we say "no secure storage available" to keep the migration
    // path inert in tests.
    when(() => mockSecureStorage.isAvailable()).thenAnswer((_) async => false);
    when(() => mockSecureStorage.getToken()).thenAnswer((_) async => null);
    when(() => mockSecureStorage.getSessionToken())
        .thenAnswer((_) async => null);
    when(() => mockSecureStorage.getAuthSignature())
        .thenAnswer((_) async => null);
    when(() => mockSecureStorage.getApiKey()).thenAnswer((_) async => null);
  });

  Future<ProviderContainer> makeContainer(
    Map<String, Object> prefsValues,
  ) async {
    SharedPreferences.setMockInitialValues(prefsValues);
    final prefs = await SharedPreferences.getInstance();
    return ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
        storageServiceProvider
            .overrideWithValue(StorageService(prefs, mockSecureStorage)),
        loggerProvider.overrideWithValue(mockLogger),
      ],
    );
  }

  group('Auth credential recovery — unauthenticated guards', () {
    test('returns unauthenticated when no credentials are in storage', () async {
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Right<Failure, User?>(null));

      final container = await makeContainer(<String, Object>{});
      addTearDown(container.dispose);

      final authState = await container.read(authProvider.future);
      expect(authState.isUnauthenticated, isTrue,
          reason:
              'Empty storage must not recover into authenticated state.');
    });

    test('returns unauthenticated when stored credentials are empty strings',
        () async {
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Right<Failure, User?>(null));

      // Storage contains keys but values are empty strings — recovery must
      // treat them as absent, not as valid credentials.
      final container = await makeContainer(<String, Object>{
        'user_token': '',
        'user_site_url': '',
        'username': '',
      });
      addTearDown(container.dispose);

      final authState = await container.read(authProvider.future);
      expect(authState.isUnauthenticated, isTrue,
          reason:
              'Empty-string credentials must be rejected as absent.');
    });
  });
}
