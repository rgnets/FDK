import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/config/app_config.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/services/storage_service.dart';

/// API Interceptor for handling authentication and logging
class ApiInterceptor extends InterceptorsWrapper {
  ApiInterceptor({
    required StorageService storageService,
  }) : super(
         onRequest: (options, handler) => _onRequest(options, handler, storageService),
         onError: _onError,
         onResponse: _onResponse,
       );

  static final _logger = Logger();

  static void _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
    StorageService storageService,
  ) {
    if (EnvironmentConfig.isDevelopment) {
      _logger.d('📤 API_SERVICE: ${options.method} ${options.path}');
    }
    if (options.data != null) {
      _logger.d('API_SERVICE: Request body: ${options.data}');
    }
    
    // RG Nets uses custom headers for authentication
    final apiKey = storageService.apiToken;
    final login = storageService.username;
    
    // Add RG Nets authentication headers
    // RG Nets API uses X-API-Login and X-API-Key headers
    if (apiKey != null && login != null) {
      options.headers['X-API-Login'] = login;
      options.headers['X-API-Key'] = apiKey;
      if (EnvironmentConfig.isDevelopment) {
        _logger.d('API_SERVICE: Using stored credentials');
      }
    } else if (EnvironmentConfig.isStaging) {
      // Use test credentials in staging
      final testLogin = AppConfig.testCredentials['login'];
      final testApiKey = AppConfig.testCredentials['apiKey'];
      options.headers['X-API-Login'] = testLogin;
      options.headers['X-API-Key'] = testApiKey;
      if (EnvironmentConfig.isDevelopment) {
        _logger.d('API_SERVICE: Using authentication headers');
      }
    } else {
      _logger.w('API_SERVICE: WARNING - No credentials available for API requests');
    }
    
    // Add content type headers
    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';
    
    // Add base URL
    final apiUrl = storageService.apiUrl;
    if (apiUrl != null) {
      options.baseUrl = apiUrl;
      _logger.d('API_SERVICE: Using stored API URL: $apiUrl');
    } else if (EnvironmentConfig.isStaging) {
      // Use test URL in staging
      options.baseUrl = 'https://${AppConfig.testCredentials['fqdn']}';
      if (EnvironmentConfig.isDevelopment) {
        _logger.d('API_SERVICE: Using staging API URL');
      }
    } else {
      // Use environment config base URL as fallback
      options.baseUrl = EnvironmentConfig.apiBaseUrl;
      _logger.d('API_SERVICE: Using environment config API URL: ${options.baseUrl}');
    }
    
    // Add api_key as query parameter for RG Nets API
    if (EnvironmentConfig.isStaging || EnvironmentConfig.isProduction) {
      final apiKeyValue = apiKey ?? EnvironmentConfig.apiKey;
      if (!options.path.contains('api_key=')) {
        // Add api_key as query parameter
        final separator = options.path.contains('?') ? '&' : '?';
        options.path = '${options.path}${separator}api_key=$apiKeyValue';
        _logger.d('API_SERVICE: Added api_key query parameter');
      }
    }
    
    if (EnvironmentConfig.isDevelopment) {
      _logger
        ..i('API_SERVICE: Final request: ${options.method} ${options.baseUrl}${options.path}')
        ..d('API_SERVICE: Environment: ${EnvironmentConfig.name}');
    }
    
    if (kIsWeb) {
      _logger
        ..d('${options.method} ${options.baseUrl}${options.path}')
        ..d('Headers count: ${options.headers.length}');
    }
    
    handler.next(options);
  }

  static void _onError(DioException error, ErrorInterceptorHandler handler) {
    _logger
      ..e('❌ API_SERVICE: Request failed!')
      ..e('API_SERVICE: Error type: ${error.type}')
      ..e('API_SERVICE: Error message: ${error.message}')
      ..e('API_SERVICE: Status Code: ${error.response?.statusCode}')
      ..e('API_SERVICE: Response Data: ${error.response?.data}')
      ..e('API_SERVICE: Request path: ${error.requestOptions.path}')
      ..e('API_SERVICE: Request URL: ${error.requestOptions.uri}');
    
    if (kIsWeb) {
      _logger
        ..e('${error.type} - ${error.message}')
        ..e('Status: ${error.response?.statusCode}')
        ..e('Path: ${error.requestOptions.path}');
    }
    
    // Handle common errors
    if (error.response?.statusCode == 401) {
      // Token expired or invalid - handled in API service
      _logger.w('API_SERVICE: Authentication failed (401)');
    }
    handler.next(error);
  }

  static void _onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (EnvironmentConfig.isDevelopment) {
      _logger.d('📥 API_SERVICE: Response ${response.statusCode}');
    }
    
    if (response.data != null && EnvironmentConfig.isDevelopment) {
      if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        
        if (data.containsKey('results') && data['results'] is List) {
          final results = data['results'] as List;
          _logger.d('API_SERVICE: Received ${results.length} items');
        } else if (data.containsKey('data')) {
          _logger.d('API_SERVICE: Response contains data field');
        } else {
          _logger.d('API_SERVICE: Direct response object: ${data.keys.take(5).toList()}...');
        }
      } else if (response.data is List) {
        final list = response.data as List;
        _logger.i('API_SERVICE: ✅ List response with ${list.length} items');
        if (list.isNotEmpty) {
          _logger.d('API_SERVICE: First item: ${list.first}');
        }
      } else if (response.data is String) {
        final str = response.data as String;
        _logger.d('API_SERVICE: String response: ${str.substring(0, str.length > 100 ? 100 : str.length)}...');
      } else {
        _logger.d('API_SERVICE: Response data: ${response.data}');
      }
    } else {
      _logger.w('API_SERVICE: ⚠️ Response data is null');
    }
    
    if (kIsWeb) {
      _logger.d('RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
      if (response.data is Map) {
        _logger.d('RESPONSE: Keys: ${(response.data as Map).keys.toList()}');
      }
    }
    
    handler.next(response);
  }
}