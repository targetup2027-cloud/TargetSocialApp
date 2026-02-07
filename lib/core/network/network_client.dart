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

  DioNetworkClient({Dio? dio, Interceptor? authInterceptor})
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
          if (kDebugMode) debugPrint(obj.toString());
        },
      ),
    );
    
    if (authInterceptor != null) {
      _dio.interceptors.add(authInterceptor);
    }
  }

  Future<T> _retryOperation<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(milliseconds: 500),
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (true) {
      try {
        return await operation();
      } on DioException catch (e) {
        attempt++;
        
        final isRetryable = e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError ||
            (e.response?.statusCode == 503) ||
            (e.response?.statusCode == 429);

        if (!isRetryable || attempt >= maxRetries) {
          throw _handleDioError(e);
        }

        await Future.delayed(delay);
        delay *= 2;
      }
    }
  }

  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return _retryOperation(() async {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data;
    });
  }

  @override
  Future<dynamic> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return _retryOperation(() async {
      final response = await _dio.post(path, data: data, queryParameters: queryParameters);
      return response.data;
    });
  }

  @override
  Future<dynamic> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return _retryOperation(() async {
      final response = await _dio.put(path, data: data, queryParameters: queryParameters);
      return response.data;
    });
  }

  @override
  Future<dynamic> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return _retryOperation(() async {
      final response = await _dio.delete(path, data: data, queryParameters: queryParameters);
      return response.data;
    });
  }

  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return const NetworkFailure(
          message: 'انتهت مهلة الاتصال. تحقق من اتصالك بالإنترنت',
        );
      
      case DioExceptionType.sendTimeout:
        return const NetworkFailure(
          message: 'انتهت مهلة إرسال البيانات. حاول مرة أخرى',
        );
      
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(
          message: 'انتهت مهلة استقبال البيانات. حاول مرة أخرى',
        );
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        
        String message = 'حدث خطأ في الخادم';
        
        if (responseData is Map<String, dynamic>) {
          message = responseData['message'] ?? 
                   responseData['error'] ?? 
                   responseData['title'] ??
                   message;
        }
        
        switch (statusCode) {
          case 400:
            message = responseData is Map ? 
                     (responseData['message'] ?? 'البيانات المُدخلة غير صحيحة') :
                     'البيانات المُدخلة غير صحيحة';
            break;
          case 401:
            message = 'يجب تسجيل الدخول للمتابعة';
            break;
          case 403:
            message = 'ليس لديك صلاحية للقيام بهذا الإجراء';
            break;
          case 404:
            message = 'المورد المطلوب غير موجود';
            break;
          case 422:
            message = responseData is Map ? 
                     (responseData['message'] ?? 'البيانات غير صالحة') :
                     'البيانات غير صالحة';
            break;
          case 429:
            message = 'تم تجاوز عدد المحاولات المسموح بها. حاول لاحقاً';
            break;
          case 500:
            message = 'خطأ في الخادم. حاول مرة أخرى لاحقاً';
            break;
          case 503:
            message = 'الخدمة غير متاحة حالياً. حاول لاحقاً';
            break;
        }
        
        return ServerFailure(message: message, statusCode: statusCode);
      
      case DioExceptionType.cancel:
        return const UnknownFailure(message: 'تم إلغاء الطلب');
      
      case DioExceptionType.connectionError:
        return const NetworkFailure(
          message: 'فشل الاتصال. تحقق من اتصالك بالإنترنت',
        );
      
      case DioExceptionType.badCertificate:
        return const NetworkFailure(
          message: 'خطأ في شهادة الأمان',
        );
      
      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') ?? false) {
          return const NetworkFailure(
            message: 'لا يوجد اتصال بالإنترنت',
          );
        }
        return UnknownFailure(
          message: error.message ?? 'حدث خطأ غير متوقع',
        );
    }
  }
}
