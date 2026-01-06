import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:rgnets_fdk/core/config/app_config.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/config/logger_config.dart';
import 'package:rgnets_fdk/core/services/storage_service.dart';

/// Core API service for making HTTP requests to rXg system
class ApiService {
  ApiService({
    required Dio dio,
    required StorageService storageService,
  }) : _dio = dio,
       _storageService = storageService {
    if (EnvironmentConfig.isDevelopment) {
      _logger.d('API_SERVICE: Initialized for ${EnvironmentConfig.name}');
    }
    _configureDio();
  }

  static final _logger = LoggerConfig.getLogger();
  
  final Dio _dio;
  final StorageService _storageService;
  
  void _configureDio() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Handle authentication based on environment
          if (EnvironmentConfig.isStaging) {
            final testApiKey = AppConfig.testCredentials['apiKey'] ?? '';
            if (testApiKey.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $testApiKey';
            }
          } else if (EnvironmentConfig.isProduction) {
            final apiKey = _storageService.apiToken;
            if (apiKey != null && apiKey.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $apiKey';
            }
          }

          // Add content type headers
          options.headers['Content-Type'] = 'application/json';
          options.headers['Accept'] = 'application/json';

          // Add base URL
          final apiUrl = _storageService.apiUrl;
          if (apiUrl != null && apiUrl.isNotEmpty) {
            options.baseUrl = apiUrl;
          } else {
            options.baseUrl = EnvironmentConfig.apiBaseUrl;
          }

          // Add api_key as query parameter for production
          if (apiUrl != null && apiUrl.isNotEmpty) {
            final apiKeyValue = _storageService.apiToken ?? '';
            if (apiKeyValue.isNotEmpty && !options.path.contains('api_key=')) {
              final separator = options.path.contains('?') ? '&' : '?';
              options.path = '${options.path}${separator}api_key=$apiKeyValue';
            }
          }

          if (EnvironmentConfig.isDevelopment) {
            _logger.d('API: ${options.method} ${options.path}');
          }

          handler.next(options);
        },
        onError: (error, handler) {
          final statusCode = error.response?.statusCode;
          // Only log errors for non-404 responses (404s are expected during device type probing)
          if (statusCode != 404 && statusCode != null) {
            _logger.e('API Error: $statusCode ${error.requestOptions.path}');
          }

          // Handle 401 - token expired or invalid
          if (statusCode == 401) {
            _storageService.clearCredentials();
          }
          handler.next(error);
        },
        onResponse: (response, handler) {
          if (EnvironmentConfig.isDevelopment) {
            _logger.d('API: ${response.statusCode} ${response.requestOptions.path}');
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
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }
  
  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
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
      final testDio = Dio(
        BaseOptions(
          baseUrl: 'https://$fqdn',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Accept': 'application/json',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      // Handle SSL issues for test environments (non-web only)
      if (!kIsWeb && EnvironmentConfig.isDevelopment) {
        (testDio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
          return HttpClient()
            ..badCertificateCallback = (cert, host, port) => true;
        };
      }

      final response = await testDio.get<dynamic>('/rest/v1/test');

      // Consider 200-299 and 401 as successful connection
      return response.statusCode == 200 || response.statusCode == 401;
    } on DioException catch (e) {
      if (EnvironmentConfig.isDevelopment) {
        _logger.e('Connection test failed: ${e.message}');
      }
      return false;
    } on Exception {
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
