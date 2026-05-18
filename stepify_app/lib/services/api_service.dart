import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import 'storage_service.dart';

/// API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

/// API Service for making HTTP requests
class ApiService {
  late final Dio _dio;
  bool _isRefreshing = false;
  
  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }
  
  // Add auth token to requests
  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await StorageService.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
  
  void _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    handler.next(response);
  }
  
  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    // Log error
    try {
      print('🔴 API Error: [${error.response?.statusCode}] ${error.requestOptions.path}');
      print('   Message: ${error.message}');
      if (error.response?.data != null) {
        print('   Data: ${error.response?.data}');
      }
    } catch (e) {
      // Ignore logging errors
    }

    // Handle 401 - Try to refresh token (but not if already refreshing or if it's the refresh endpoint itself)
    if (error.response?.statusCode == 401 && 
        !_isRefreshing && 
        !error.requestOptions.path.contains('/auth/refresh')) {
      try {
        _isRefreshing = true;
        final refreshed = await _refreshToken();
        _isRefreshing = false;
        
        if (refreshed) {
          // Retry the original request
          final options = error.requestOptions;
          final token = await StorageService.getAccessToken();
          options.headers['Authorization'] = 'Bearer $token';
          
          final response = await _dio.fetch(options);
          handler.resolve(response);
          return;
        }
      } catch (e) {
        _isRefreshing = false;
        // Refresh failed - need to re-login
      }
    }
    handler.next(error);
  }
  
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken == null) return false;
      
      // Use a separate Dio instance without interceptors to avoid infinite loop
      final refreshDio = Dio(BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ));
      
      final response = await refreshDio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      
      final tokens = response.data;
      await StorageService.saveTokens(
        accessToken: tokens['accessToken'],
        refreshToken: tokens['refreshToken'],
      );
      
      return true;
    } catch (e) {
      await StorageService.clearTokens();
      return false;
    }
  }
  
  // ============================================
  // HTTP METHODS
  // ============================================
  
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.get(path, queryParameters: queryParameters);
  }
  
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.post(path, data: data, queryParameters: queryParameters);
  }
  
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.put(path, data: data, queryParameters: queryParameters);
  }
  
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.patch(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.delete(path, data: data, queryParameters: queryParameters);
  }
}

/// API Error class
class ApiError implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;
  
  ApiError({
    required this.message,
    this.statusCode,
    this.data,
  });
  
  factory ApiError.from(dynamic error) {
    if (error is ApiError) return error;
    
    if (error is DioException) {
      String message = 'Something went wrong. Please try again.';
      
      if (error.response != null) {
        final data = error.response?.data;
        if (data is Map && data['message'] != null) {
          message = data['message'].toString();
        } else if (data is String) {
          message = data;
        }
      } else {
        switch (error.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            message = 'Connection timed out. Please check your internet.';
            break;
          case DioExceptionType.connectionError:
            message = 'No internet connection. Please retry.';
            break;
          case DioExceptionType.cancel:
            message = 'Request cancelled.';
            break;
          default:
            message = 'Network error occurred.';
        }
      }
      
      return ApiError(
        message: message,
        statusCode: error.response?.statusCode,
        data: error.response?.data,
      );
    }
    
    return ApiError(message: error.toString().replaceAll('Exception: ', ''));
  }

  // Backwards compatibility for AuthProvider
  factory ApiError.fromDioError(DioException error) {
    return ApiError.from(error);
  }
  
  @override
  String toString() => message;
}
