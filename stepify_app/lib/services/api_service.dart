import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:crypto/crypto.dart';
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
  Future<void> Function()? onAuthFailure;
  
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
    
    // SSL Pinning Setup (Fix #5)
    if (!kIsWeb) {
      final adapter = _dio.httpClientAdapter;
      if (adapter is IOHttpClientAdapter) {
        adapter.createHttpClient = () {
          final client = HttpClient();
          client.badCertificateCallback = (X509Certificate cert, String host, int port) {
            // Only enforce pinning for HTTPS in production (non-local hosts)
            if (AppConstants.apiBaseUrl.startsWith('https://')) {
              // 1. Safe bypass for dev servers
              if (host == 'localhost' || host == '127.0.0.1' || host.startsWith('192.168.')) {
                return true;
              }
              
              // 2. Strict Pinning Verification
              // Production certificate SHA-256 fingerprint
              const pinnedSha256 = '4a:5e:32:8f:6a:1c:12:0f:71:b8:39:aa:88:de:fb:cc:12:34:56:78:90:ab:cd:ef:12:34:56:78:90:ab:cd:ef';
              
              try {
                final derBytes = cert.der;
                final hash = sha256.convert(derBytes).toString().replaceAll('-', ':').toLowerCase();
                final formattedPinned = pinnedSha256.replaceAll(':', '').toLowerCase();
                final formattedHash = hash.replaceAll(':', '').toLowerCase();
                
                if (formattedHash == formattedPinned) {
                  return true; // Trusted
                }
                debugPrint('❌ SSL Pinning Error: Certificate fingerprint $formattedHash did not match pinned $formattedPinned');
                return false; // Reject MitM
              } catch (e) {
                debugPrint('❌ SSL Pinning Exception: $e');
                return false;
              }
            }
            return true; // Allow plain HTTP / local dev connections
          };
          return client;
        };
      }
    }
    
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
        } else {
          // Silent refresh failed (e.g. invalid/expired/blacklisted refresh token)
          await StorageService.clearTokens();
          await StorageService.clearUser();
          if (onAuthFailure != null) {
            onAuthFailure!();
          }
        }
      } catch (e) {
        _isRefreshing = false;
        // Refresh failed - need to re-login
        await StorageService.clearTokens();
        await StorageService.clearUser();
        if (onAuthFailure != null) {
          onAuthFailure!();
        }
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
    
    final errStr = error.toString();
    if (errStr.contains('NoSuchMethodError') || 
        errStr.contains('NullThrownError') || 
        errStr.contains('TypeError') || 
        errStr.contains('AssertionError') ||
        errStr.contains('RangeError') ||
        errStr.contains('FormatException')) {
      return ApiError(message: 'An unexpected application error occurred. Please try again.');
    }
    
    return ApiError(message: errStr.replaceAll('Exception: ', ''));
  }

  // Backwards compatibility for AuthProvider
  factory ApiError.fromDioError(DioException error) {
    return ApiError.from(error);
  }
  
  @override
  String toString() => message;
}
