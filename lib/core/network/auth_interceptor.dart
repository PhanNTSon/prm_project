import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _storageService;
  final GlobalKey<NavigatorState> navigatorKey;

  AuthInterceptor(this.navigatorKey, {SecureStorageService? storageService})
      : _storageService = storageService ?? SecureStorageService();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Read token from secure storage
    final token = await _storageService.getToken();

    // If token exists, append it to the Authorization header
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Continue with the request
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 Unauthorized errors (Token expired or invalid)
    if (err.response?.statusCode == 401) {
      // Clear local auth data
      await _storageService.clearAuthData();

      // Redirect to login page using the global navigator key
      final context = navigatorKey.currentContext;
      if (context != null) {
        context.go('/login');
      }
    }

    // Continue with the error
    return handler.next(err);
  }
}