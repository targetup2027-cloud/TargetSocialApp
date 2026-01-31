import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/user.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _localDataSource;
  final AuthRemoteDataSource _remoteDataSource;
  final AppConfig _config;

  AuthRepositoryImpl({
    required AuthLocalDataSource localDataSource,
    required AuthRemoteDataSource remoteDataSource,
    required AppConfig config,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _config = config;

  @override
  Future<Result<User>> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      if (_config.useRemoteData) {
         final user = await _remoteDataSource.signUp(
          email: email, 
          password: password, 
          displayName: displayName
        );
        return Success(user);
      } else {
        final user = await _localDataSource.signUp(
          email: email,
          password: password,
          displayName: displayName,
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
         final user = await _remoteDataSource.login(
          email: email, 
          password: password
        );
        return Success(user);
      } else {
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
         // Should try remote first, if not then local cache? 
         // For now, strict separation based on config as requested.
         return const Success(null);
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
      final user = await _remoteDataSource.signInWithGoogle(idToken);
      return Success(user);
    } catch (e) {
      return Err(AuthFailure(message: e.toString()));
    }
  }
}

// Ensure this provider matches the signature expected by consumers if possible, 
// or I update consumers (which is better).
final authRepositoryImplProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    localDataSource: ref.watch(authLocalDataSourceProvider),
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    config: currentConfig,
  );
});
