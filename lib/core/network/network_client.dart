import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../errors/failure.dart';
import 'package:flutter/foundation.dart';

/// Abstract Network Client to decouple from specific libraries
abstract class NetworkClient {
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters});
  Future<dynamic> post(String path, {dynamic data, Map<String, dynamic>? queryParameters});
  Future<dynamic> put(String path, {dynamic data, Map<String, dynamic>? queryParameters});
  Future<dynamic> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters});
}

/// Dio Implementation
class DioNetworkClient implements NetworkClient {
  final Dio _dio;

  DioNetworkClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: currentConfig.apiBaseUrl,
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
                sendTimeout: const Duration(seconds: 30),
              ),
            ) {
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: kDebugMode,
        responseBody: kDebugMode,
        logPrint: (obj) {
          // Prevent logging sensitive info in production
          if (kDebugMode) debugPrint(obj.toString());
        },
      ),
    );
     // Placeholder for AuthInterceptor
  }

  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<dynamic> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.post(path, data: data, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<dynamic> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.put(path, data: data, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<dynamic> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.delete(path, data: data, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(message: 'Connection timeout');
      case DioExceptionType.badResponse:
         final statusCode = error.response?.statusCode;
         // TODO: Parse backend error schema
         return ServerFailure(message: 'Server error', statusCode: statusCode);
      case DioExceptionType.cancel:
        return const UnknownFailure(message: 'Request cancelled');
      default:
        return UnknownFailure(message: error.message ?? 'Unknown network error');
    }
  }
}
