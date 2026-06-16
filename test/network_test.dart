import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prm_project/core/network/auth_interceptor.dart';
import 'package:prm_project/core/network/secure_storage_service.dart';

// Fake class to mock secure storage behavior without real platform channels
class FakeSecureStorageService implements SecureStorageService {
  String? mockToken;
  bool isCleared = false;

  @override
  Future<String?> getToken() async => mockToken;

  @override
  Future<void> clearAuthData() async {
    isCleared = true;
    mockToken = null;
  }

  @override
  Future<void> saveAuthData({
    required String token,
    required String userId,
    required String role,
    required String username,
  }) async {
    mockToken = token;
  }

  @override
  Future<String?> getUserId() async => '1';

  @override
  Future<String?> getRole() async => 'USER';

  @override
  Future<String?> getUsername() async => 'techlead';
}

// Fake handler to verify handler.next() was called
class FakeRequestInterceptorHandler extends RequestInterceptorHandler {
  RequestOptions? nextOptions;

  @override
  void next(RequestOptions requestOptions) {
    nextOptions = requestOptions;
  }
}

class FakeErrorInterceptorHandler extends ErrorInterceptorHandler {
  DioException? nextError;

  @override
  void next(DioException err) {
    nextError = err;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthInterceptor Tests', () {
    late FakeSecureStorageService fakeStorage;
    late GlobalKey<NavigatorState> mockNavigatorKey;
    late AuthInterceptor interceptor;

    setUp(() {
      fakeStorage = FakeSecureStorageService();
      mockNavigatorKey = GlobalKey<NavigatorState>();
      interceptor = AuthInterceptor(mockNavigatorKey, storageService: fakeStorage);
    });

    test('should add Authorization header when token is present', () async {
      // Arrange
      fakeStorage.mockToken = 'test_jwt_token';
      final options = RequestOptions(path: '/api/data');
      final handler = FakeRequestInterceptorHandler();

      // Act
      await interceptor.onRequest(options, handler);

      // Assert
      expect(handler.nextOptions, isNotNull);
      expect(handler.nextOptions!.headers['Authorization'], 'Bearer test_jwt_token');
    });

    test('should NOT add Authorization header when token is null', () async {
      // Arrange
      fakeStorage.mockToken = null;
      final options = RequestOptions(path: '/api/data');
      final handler = FakeRequestInterceptorHandler();

      // Act
      await interceptor.onRequest(options, handler);

      // Assert
      expect(handler.nextOptions, isNotNull);
      expect(handler.nextOptions!.headers.containsKey('Authorization'), isFalse);
    });

    test('should clear storage when 401 Unauthorized occurs', () async {
      // Arrange
      final options = RequestOptions(path: '/api/data');
      final response = Response(
        requestOptions: options,
        statusCode: 401,
      );
      final exception = DioException(
        requestOptions: options,
        response: response,
      );
      final handler = FakeErrorInterceptorHandler();

      // Act
      await interceptor.onError(exception, handler);

      // Assert
      expect(fakeStorage.isCleared, isTrue);
      expect(handler.nextError, isNotNull);
    });
  });
}
