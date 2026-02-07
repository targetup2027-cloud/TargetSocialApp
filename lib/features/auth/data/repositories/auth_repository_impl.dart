import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/user.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../session_store.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _localDataSource;
  final AuthRemoteDataSource _remoteDataSource;
  final SessionStore _sessionStore;
  final AppConfig _config;

  AuthRepositoryImpl({
    required AuthLocalDataSource localDataSource,
    required AuthRemoteDataSource remoteDataSource,
    required SessionStore sessionStore,
    required AppConfig config,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _sessionStore = sessionStore,
        _config = config;

  @override
  Future<Result<User>> signUp({
    required String email,
    required String password,
    required String confirmPassword,
    String? firstName,
    String? lastName,
    String? displayName,
    DateTime? dateOfBirth,
  }) async {
    try {
      if (_config.useRemoteData) {
         final authResponse = await _remoteDataSource.signUp(
          firstName: firstName ?? displayName ?? '',
          lastName: lastName ?? '',
          email: email, 
          password: password, 
          confirmPassword: confirmPassword,
          dateOfBirth: dateOfBirth,
        );
        await _sessionStore.saveTokens(
          accessToken: authResponse.tokens.accessToken,
          refreshToken: authResponse.tokens.refreshToken,
        );
        await _sessionStore.saveSession(authResponse.user.id);
        return Success(authResponse.user);
      } else {
        final user = await _localDataSource.signUp(
          email: email,
          password: password,
          displayName: displayName ?? [firstName, lastName]
              .where((s) => s != null && s.isNotEmpty)
              .join(' '),
        );

        if (user == null) {
          return const Err(AuthFailure(message: 'User already exists'));
        }
        return Success(user);
      }
    } catch (e) {
      return Err(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<User>> login({
    required String email,
    required String password,
  }) async {
    try {
      if (_config.useRemoteData) {
         final authResponse = await _remoteDataSource.login(
          email: email, 
          password: password
        );
        await _sessionStore.saveTokens(
          accessToken: authResponse.tokens.accessToken,
          refreshToken: authResponse.tokens.refreshToken,
        );
        return Success(authResponse.user);
      } else{
        final user = await _localDataSource.login(
          email: email,
          password: password,
        );

        if (user == null) {
          return const Err(AuthFailure(message: 'Invalid email or password'));
        }
        return Success(user);
      }
    } catch (e) {
      return Err(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<User?>> getUserById(String userId) async {
    try {
       if (_config.useRemoteData) {
         final user = await _remoteDataSource.getUserById(userId);
         return Success(user);
       } else {
         final user = await _localDataSource.getUserById(userId);
         return Success(user);
       }
    } catch (e) {
      return Err(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<bool> hasUsers() {
    return _localDataSource.hasUsers();
  }

  @override
  Future<Result<User>> signInWithGoogle(String idToken) async {
    try {
      final authResponse = await _remoteDataSource.signInWithGoogle(idToken);
      await _sessionStore.saveTokens(
        accessToken: authResponse.tokens.accessToken,
        refreshToken: authResponse.tokens.refreshToken,
      );
      return Success(authResponse.user);
    } catch (e) {
      return Err(AuthFailure(message: e.toString()));
    }
  }
}

final authRepositoryImplProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    localDataSource: ref.watch(authLocalDataSourceProvider),
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    sessionStore: ref.watch(sessionStoreProvider),
    config: currentConfig,
  );
});
