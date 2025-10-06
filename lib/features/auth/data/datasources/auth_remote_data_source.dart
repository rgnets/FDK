import 'package:rgnets_fdk/core/services/api_service.dart';
import 'package:rgnets_fdk/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<bool> testConnection({
    required String fqdn,
    required String login,
    required String apiKey,
  });
  
  Future<UserModel> getUserInfo({
    required String fqdn,
    required String login,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({
    required this.apiService,
  });

  final ApiService apiService;

  @override
  Future<bool> testConnection({
    required String fqdn,
    required String login,
    required String apiKey,
  }) async {
    try {
      return await apiService.testConnection(
        fqdn: fqdn,
        login: login,
        apiKey: apiKey,
      );
    } on Exception catch (e) {
      throw Exception('Failed to test connection: $e');
    }
  }

  @override
  Future<UserModel> getUserInfo({
    required String fqdn,
    required String login,
  }) async {
    try {
      // For now, return basic user info
      // In a real implementation, this would fetch from the API
      return UserModel(
        username: login,
        apiUrl: 'https://$fqdn',
        displayName: login,
        email: null,
      );
    } on Exception catch (e) {
      throw Exception('Failed to get user info: $e');
    }
  }
}