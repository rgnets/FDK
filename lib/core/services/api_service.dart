import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/config/app_config.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/services/storage_service.dart';

/// Core API service for making HTTP requests to rXg system
class ApiService {
  ApiService({
    required Dio dio,
    required StorageService storageService,
  }) : _dio = dio,
       _storageService = storageService {
    _logger
      ..i('API_SERVICE: Constructor called')
      ..i('API_SERVICE: Environment is ${EnvironmentConfig.name}')
      ..i('API_SERVICE: apiBaseUrl=${EnvironmentConfig.apiBaseUrl}');
    _configureDio();
  }

  static final _logger = Logger();
  
  final Dio _dio;
  final StorageService _storageService;
  
  void _configureDio() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (EnvironmentConfig.isDevelopment) {
            _logger.d('📤 API_SERVICE: ${options.method} ${options.path}');
          }
          if (options.data != null) {
            _logger.d('API_SERVICE: Request body: ${options.data}');
          }
          // Handle authentication based on environment
          if (EnvironmentConfig.isStaging) {
            // Staging uses Bearer token authentication
            final testApiKey = AppConfig.testCredentials['apiKey'] ?? '';
            
            if (testApiKey.isNotEmpty) {
              // Create Bearer token header
              options.headers['Authorization'] = 'Bearer $testApiKey';
              _logger.d('API_SERVICE: Using Bearer token for staging');
            } else {
              _logger.w('API_SERVICE: Staging API key not available');
            }
          } else if (EnvironmentConfig.isProduction) {
            // Production uses Bearer token authentication
            final apiKey = _storageService.apiToken;
            
            if (apiKey != null && apiKey.isNotEmpty) {
              // Create Bearer token header
              options.headers['Authorization'] = 'Bearer $apiKey';
              _logger.d('API_SERVICE: Using Bearer token for production');
            } else {
              _logger.w('API_SERVICE: No API token available for production');
            }
          }
          // Development mode uses mock data, no auth needed
          
          // Add content type headers
          options.headers['Content-Type'] = 'application/json';
          options.headers['Accept'] = 'application/json';
          
          // Add base URL
          final apiUrl = _storageService.apiUrl;
          if (apiUrl != null && EnvironmentConfig.isProduction) {
            // Production uses stored URL
            options.baseUrl = apiUrl;
            _logger.d('API_SERVICE: Using stored API URL: $apiUrl');
          } else {
            // Use environment-specific URL
            options.baseUrl = EnvironmentConfig.apiBaseUrl;
            _logger.d('API_SERVICE: Using environment API URL: ${options.baseUrl}');
          }
          
          // Note: Staging uses Basic Auth, not api_key parameter
          // Production may need api_key parameter depending on configuration
          if (EnvironmentConfig.isProduction) {
            final apiKeyValue = _storageService.apiToken ?? '';
            if (apiKeyValue.isNotEmpty && !options.path.contains('api_key=')) {
              // Add api_key as query parameter for production
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
        },
        onError: (error, handler) {
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
            // Token expired or invalid
            _storageService.clearCredentials();
          }
          handler.next(error);
        },
        onResponse: (response, handler) {
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
              _logger.d('API_SERVICE: Response data: $response.data');
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
        },
      ),
    );
  }
  
  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    _logger
      ..i('🔍 API_SERVICE.get(): Starting GET request')
      ..d('API_SERVICE.get(): Path: $path')
      ..d('API_SERVICE.get(): Query params: $queryParameters')
      ..d('API_SERVICE.get(): Type parameter T: $T');
    
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    ).then((response) {
      _logger
        ..i('API_SERVICE.get(): ✅ GET request completed successfully')
        ..d('API_SERVICE.get(): Response type: ${response.data.runtimeType}');
      return response;
    }).catchError((Object error) {
      _logger.e('API_SERVICE.get(): ❌ GET request failed: $error');
      throw Exception('GET request failed: $error');
    });
  }
  
  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    _logger
      ..i('📮 API_SERVICE.post(): Starting POST request')
      ..d('API_SERVICE.post(): Path: $path')
      ..d('API_SERVICE.post(): Data: $data')
      ..d('API_SERVICE.post(): Query params: $queryParameters');
    
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    ).then((response) {
      _logger
        ..i('API_SERVICE.post(): ✅ POST request completed successfully')
        ..d('API_SERVICE.post(): Response: ${response.data}');
      return response;
    }).catchError((Object error) {
      _logger.e('API_SERVICE.post(): ❌ POST request failed: $error');
      throw Exception('POST request failed: $error');
    });
  }
  
  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
  
  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
  
  /// Test connection with provided credentials
  Future<bool> testConnection({
    required String fqdn,
    required String login,
    required String apiKey,
  }) async {
    try {
      final keyLength = apiKey.length > 4 ? 4 : apiKey.length;
      _logger
        ..i('🔌 API_SERVICE.testConnection(): Testing connection')
        ..d('API_SERVICE.testConnection(): FQDN: $fqdn')
        ..d('API_SERVICE.testConnection(): Login: $login')
        ..d('API_SERVICE.testConnection(): API Key: ${apiKey.substring(0, keyLength)}...');
      
      if (kIsWeb) {
        _logger.d('Testing connection to $fqdn');
      }
      
      final testDio = Dio(
        BaseOptions(
          baseUrl: 'https://$fqdn',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            // Use Bearer token authentication
            'Authorization': 'Bearer $apiKey',
            'Accept': 'application/json',
          },
          // Don't validate SSL certificates for staging/test environments
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      
      // Add interceptor to handle SSL issues for test environments (non-web only)
      if (!kIsWeb && EnvironmentConfig.isDevelopment) {
        (testDio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
          return HttpClient()
            ..badCertificateCallback = (cert, host, port) {
              // Only accept self-signed certificates in development mode
              _logger.w('SSL certificate validation bypassed for development: $host');
              return true;
            };
        };
      }
      
      // Try to connect to a simple endpoint that should always exist
      // Using /rest/v1/test or just /rest/v1 for basic connectivity
      _logger.i('API_SERVICE.testConnection(): Sending test request to /rest/v1/test');
      final response = await testDio.get<dynamic>('/rest/v1/test');
      
      _logger
        ..i('API_SERVICE.testConnection(): Response received')
        ..d('API_SERVICE.testConnection(): Status code: ${response.statusCode}')
        ..d('API_SERVICE.testConnection(): Response data: ${response.data}');
      
      if (kIsWeb) {
        _logger.d('Response status: ${response.statusCode}');
      }
      
      // Consider 200-299 and 401 (needs auth) as successful connection
      // 401 means the server is reachable but auth might be wrong
      final success = response.statusCode == 200 || response.statusCode == 401;
      _logger.i('API_SERVICE.testConnection(): Test ${success ? '✅ PASSED' : '❌ FAILED'}');
      return success;
    } on DioException catch (e) {
      _logger
        ..e('Connection test failed: ${e.message}')
        ..e('Response: ${e.response?.statusCode} - ${e.response?.data}');
      
      // If we get a 401, the connection is good but auth failed
      if (e.response?.statusCode == 401) {
        _logger.w('Server reachable but authentication failed');
        return false; // Auth failed
      }
      
      return false;
    } on Exception catch (e) {
      _logger.e('Unexpected error testing connection: $e');
      return false;
    }
  }
  
  /// Configure API with test credentials (for development)
  void useTestCredentials() {
    final testCreds = AppConfig.testCredentials;
    _dio.options.baseUrl = 'https://${testCreds['fqdn']}';
    _dio.options.headers['Authorization'] = 'Bearer ${testCreds['apiKey']}';
  }
}