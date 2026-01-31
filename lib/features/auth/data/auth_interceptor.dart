import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'session_store.dart';
import 'datasources/auth_remote_data_source.dart';

class AuthInterceptor extends Interceptor {
  final SessionStore _sessionStore;
  final AuthRemoteDataSource _authRemoteDataSource;
  final void Function() _onSessionExpired;
  
  bool _isRefreshing = false;
  final List<({RequestOptions options, ErrorInterceptorHandler handler})> _pendingRequests = [];

  AuthInterceptor({
    required SessionStore sessionStore,
    required AuthRemoteDataSource authRemoteDataSource,
    required void Function() onSessionExpired,
  })  : _sessionStore = sessionStore,
        _authRemoteDataSource = authRemoteDataSource,
        _onSessionExpired = onSessionExpired;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await _sessionStore.readAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    final refreshToken = await _sessionStore.readRefreshToken();
    
    if (refreshToken == null || refreshToken.isEmpty) {
      await _handleSessionExpired();
      handler.next(err);
      return;
    }

    if (_isRefreshing) {
      _pendingRequests.add((options: err.requestOptions, handler: handler));
      return;
    }

    _isRefreshing = true;

    try {
      final tokenPair = await _authRemoteDataSource.refresh(refreshToken);
      
      await _sessionStore.saveTokens(
        accessToken: tokenPair.accessToken,
        refreshToken: tokenPair.refreshToken,
      );

      final retryResponse = await _retryRequest(err.requestOptions, tokenPair.accessToken);
      handler.resolve(retryResponse);

      for (final pending in _pendingRequests) {
        try {
          final response = await _retryRequest(pending.options, tokenPair.accessToken);
          pending.handler.resolve(response);
        } catch (e) {
          pending.handler.reject(
            DioException(requestOptions: pending.options, error: e),
          );
        }
      }
    } catch (_) {
      await _handleSessionExpired();
      handler.next(err);
      
      for (final pending in _pendingRequests) {
        pending.handler.reject(
          DioException(
            requestOptions: pending.options,
            error: 'Session expired',
          ),
        );
      }
    } finally {
      _isRefreshing = false;
      _pendingRequests.clear();
    }
  }

  Future<Response<dynamic>> _retryRequest(
    RequestOptions options,
    String accessToken,
  ) async {
    final dio = Dio();
    options.headers['Authorization'] = 'Bearer $accessToken';
    return dio.fetch(options);
  }

  Future<void> _handleSessionExpired() async {
    await _sessionStore.clearSession();
    _onSessionExpired();
    if (kDebugMode) {
      debugPrint('[AuthInterceptor] Session expired, triggering logout');
    }
  }
}
