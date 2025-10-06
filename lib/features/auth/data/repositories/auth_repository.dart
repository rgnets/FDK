import 'package:fpdart/fpdart.dart';

import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/services/mock_data_service.dart';
import 'package:rgnets_fdk/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:rgnets_fdk/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:rgnets_fdk/features/auth/data/models/user_model.dart';
import 'package:rgnets_fdk/features/auth/domain/entities/user.dart';
import 'package:rgnets_fdk/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.mockDataService,
  });

  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final MockDataService mockDataService;

  @override
  Future<Either<Failure, User>> authenticate({
    required String fqdn,
    required String login,
    required String apiKey,
  }) async {
    try {
      // Development mode: return mock user immediately
      if (EnvironmentConfig.isDevelopment) {
        final mockUser = mockDataService.getMockUser();
        
        // Save mock user locally for consistency
        await localDataSource.saveCredentials(
          apiUrl: 'https://dev.local',
          apiToken: 'dev-api-key',
          username: 'developer',
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
      final isValid = await remoteDataSource.testConnection(
        fqdn: fqdn,
        login: login,
        apiKey: apiKey,
      );

      if (!isValid) {
        return const Left(AuthFailure(message: 'Invalid credentials'));
      }

      // Get user info
      final userModel = await remoteDataSource.getUserInfo(
        fqdn: fqdn,
        login: login,
      );

      // Save credentials and user info locally
      await localDataSource.saveCredentials(
        apiUrl: 'https://$fqdn',
        apiToken: apiKey,
        username: login,
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
      return const Right(null);
    } on Exception catch (e) {
      return Left(AuthFailure(message: 'Sign out failed: $e'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      // Development mode: return mock user
      if (EnvironmentConfig.isDevelopment) {
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
      // Development mode: always authenticated
      if (EnvironmentConfig.isDevelopment) {
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