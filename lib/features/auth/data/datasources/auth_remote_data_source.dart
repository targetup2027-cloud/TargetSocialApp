import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/network_client.dart';
import '../../domain/user.dart';
import '../session_store.dart';
import '../auth_interceptor.dart';
import '../../application/auth_guard.dart';

class TokenPair {
  final String accessToken;
  final String? refreshToken;

  const TokenPair({
    required this.accessToken,
    this.refreshToken,
  });
}

class AuthResponse {
  final User user;
  final TokenPair tokens;

  const AuthResponse({
    required this.user,
    required this.tokens,
  });
}

abstract interface class AuthRemoteDataSource {
  Future<AuthResponse> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    DateTime? dateOfBirth,
  });

  Future<AuthResponse> login({
    required String email,
    required String password,
  });

  Future<User> getUserById(String userId);

  Future<TokenPair> refresh({
    required String accessToken,
    required String refreshToken,
  });

  Future<AuthResponse> signInWithGoogle(String idToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final NetworkClient _client;

  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<AuthResponse> login({required String email, required String password}) async {
    final response = await _client.post('/api/Auth/login', data: {
      'email': email,
      'password': password,
    });

    final data = response['data'];
    final user = User(
      id: data['userId'].toString(),
      email: data['email'] ?? email,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
    );

    final tokens = TokenPair(
      accessToken: data['accessToken'] ?? '',
      refreshToken: data['refreshToken'],
    );

    return AuthResponse(user: user, tokens: tokens);
  }

  @override
  Future<AuthResponse> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    DateTime? dateOfBirth,
  }) async {
    await _client.post('/api/Auth/register', data: {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth.toIso8601String(),
    });

    return login(email: email, password: password);
  }

  @override
  Future<User> getUserById(String userId) async {
    final response = await _client.get('/api/Users/$userId');
    final data = response['data'];
    return User(
      id: data['id'].toString(),
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      profileImageUrl: data['profilePictureUrl'] as String?,
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<TokenPair> refresh({
    required String accessToken,
    required String refreshToken,
  }) async {
    final response = await _client.post('/api/Auth/refresh-token', data: {
      'token': accessToken,
      'refreshToken': refreshToken,
    });

    final data = response['data'];
    return TokenPair(
      accessToken: data['accessToken'],
      refreshToken: data['refreshToken'],
    );
  }

  @override
  Future<AuthResponse> signInWithGoogle(String idToken) async {
    final response = await _client.post('/api/Auth/google', data: {
      'provider': 'Google',
      'providerToken': idToken,
    });

    final data = response['data'];
    final user = User(
      id: data['userId'].toString(),
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
    );

    final tokens = TokenPair(
      accessToken: data['accessToken'] ?? '',
      refreshToken: data['refreshToken'],
    );

    return AuthResponse(user: user, tokens: tokens);
  }
}

final baseNetworkClientProvider = Provider<NetworkClient>((ref) {
  return DioNetworkClient();
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(baseNetworkClientProvider));
});

final networkClientProvider = Provider<NetworkClient>((ref) {
  final sessionStore = ref.watch(sessionStoreProvider);
  final authRemoteDataSource = ref.watch(authRemoteDataSourceProvider);
  
  final authInterceptor = AuthInterceptor(
    sessionStore: sessionStore,
    authRemoteDataSource: authRemoteDataSource,
    onSessionExpired: () {
      ref.read(authGuardProvider.notifier).setUnauthenticated();
    },
  );
  
  return DioNetworkClient(authInterceptor: authInterceptor);
});
