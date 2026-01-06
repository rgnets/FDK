import 'package:fpdart/fpdart.dart';

import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/services/mock_data_service.dart';
import 'package:rgnets_fdk/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:rgnets_fdk/features/auth/data/models/user_model.dart';
import 'package:rgnets_fdk/features/auth/domain/entities/user.dart';
import 'package:rgnets_fdk/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.localDataSource,
    required this.mockDataService,
  });

  final AuthLocalDataSource localDataSource;
  final MockDataService mockDataService;

  @override
  Future<Either<Failure, User>> authenticate({
    required String fqdn,
    required String login,
    required String apiKey,
    String? siteName,
    DateTime? issuedAt,
    String? signature,
  }) async {
    try {
      // Synthetic data mode: return mock user immediately
      if (EnvironmentConfig.useSyntheticData) {
        final mockUser = mockDataService.getMockUser();

        // Save mock user locally for consistency
        await localDataSource.saveCredentials(
          apiUrl: 'https://dev.local',
        apiToken: 'dev-api-key',
        username: 'developer',
        siteName: siteName ?? 'Development',
        issuedAt: issuedAt ?? DateTime.now().toUtc(),
        signature: signature,
        markAuthenticated: true,
      );

        // Convert to UserModel and save
        final userModel = UserModel(
          username: mockUser.username,
          apiUrl: mockUser.apiUrl,
          displayName: mockUser.displayName,
          email: mockUser.email,
        );
        await localDataSource.saveUser(userModel);

        return Right(mockUser);
      }

      // Staging/Production: use real API
      // Save credentials locally; WebSocket handshake will validate and enrich
      await localDataSource.saveCredentials(
        apiUrl: 'https://$fqdn',
        apiToken: apiKey,
        username: login,
        siteName: siteName,
        issuedAt: issuedAt,
        signature: signature,
        markAuthenticated: false,
      );

      final userModel = UserModel(
        username: login,
        apiUrl: 'https://$fqdn',
        displayName: siteName ?? login,
      );

      await localDataSource.saveUser(userModel);

      return Right(userModel.toEntity());
    } on Exception catch (e) {
      return Left(AuthFailure(message: 'Authentication failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await localDataSource.clearCredentials();
      await localDataSource.clearUser();
      await localDataSource.clearSession();
      return const Right(null);
    } on Exception catch (e) {
      return Left(AuthFailure(message: 'Sign out failed: $e'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      // Synthetic data mode: return mock user
      if (EnvironmentConfig.useSyntheticData) {
        return Right(MockDataService().getMockUser());
      }

      // Staging/Production: get from local storage
      final userModel = await localDataSource.getUser();
      return Right(userModel?.toEntity());
    } on Exception catch (e) {
      return Left(AuthFailure(message: 'Failed to get current user: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      // Synthetic data mode: always authenticated
      if (EnvironmentConfig.useSyntheticData) {
        return const Right(true);
      }

      // Staging mode: check if we have the interurban credentials stored
      if (EnvironmentConfig.isStaging) {
        // Auto-authenticate for staging
        return const Right(true);
      }

      // Production: check local storage
      final isAuth = await localDataSource.isAuthenticated();
      return Right(isAuth);
    } on Exception catch (e) {
      return Left(AuthFailure(message: 'Failed to check auth status: $e'));
    }
  }
}
