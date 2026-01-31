import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/network_client.dart';
import '../../domain/user.dart';

class TokenPair {
  final String accessToken;
  final String? refreshToken;

  const TokenPair({
    required this.accessToken,
    this.refreshToken,
  });
}

abstract interface class AuthRemoteDataSource {
  Future<User> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  Future<User> login({
    required String email,
    required String password,
  });

  Future<User> getUserById(String userId);

  Future<TokenPair> refresh(String refreshToken);

  Future<User> signInWithGoogle(String idToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final NetworkClient _client;

  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<User> login({required String email, required String password}) async {
    final response = await _client.post('/api/Auth/login', data: {
      'email': email,
      'password': password,
    });

    final data = response['data'];
    return User(
      id: data['userId'].toString(),
      email: data['email'] ?? email,
      displayName: data['email'] ?? email,
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<User> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await _client.post('/api/Auth/register', data: {
      'email': email,
      'password': password,
      'displayName': displayName,
      'username': displayName,
    });

    final data = response['data'];
    return User(
      id: data['userId'].toString(),
      email: data['email'] ?? email,
      displayName: displayName,
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<User> getUserById(String userId) async {
    final response = await _client.get('/api/Users/$userId');
    final data = response['data'];
    return User(
      id: data['id'].toString(),
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? data['username'] ?? '',
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<TokenPair> refresh(String refreshToken) async {
    final response = await _client.post('/api/Auth/refresh-token', data: {
      'refreshToken': refreshToken,
    });

    final data = response['data'];
    return TokenPair(
      accessToken: data['accessToken'],
      refreshToken: data['refreshToken'],
    );
  }

  @override
  Future<User> signInWithGoogle(String idToken) async {
    final response = await _client.post('/api/Auth/google', data: {
      'provider': 'Google',
      'providerToken': idToken,
    });

    final data = response['data'];
    return User(
      id: data['userId'].toString(),
      email: data['email'] ?? '',
      displayName: data['email']?.split('@').first ?? '',
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
    );
  }
}

final networkClientProvider = Provider<NetworkClient>((ref) {
  return DioNetworkClient();
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(networkClientProvider));
});
