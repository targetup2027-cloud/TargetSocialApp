import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/app_constants.dart';

final sessionStoreProvider = Provider<SessionStore>((ref) {
  return SessionStore();
});

class SessionStore {
  static const _keyUserId = 'session_user_id';
  static const _keyCreatedAtMs = 'session_created_at_ms';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  Future<void> saveSession(String userId) async {
    final createdAtMs = DateTime.now().millisecondsSinceEpoch.toString();
    await _storage.write(key: _keyUserId, value: userId);
    await _storage.write(key: _keyCreatedAtMs, value: createdAtMs);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _keyUserId);
    await _storage.delete(key: _keyCreatedAtMs);
    await clearTokens();
  }

  Future<bool> hasSession() async {
    final userId = await getUserId();
    return userId != null && userId.isNotEmpty;
  }

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _storage.write(key: StorageKeys.accessToken, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: StorageKeys.refreshToken, value: refreshToken);
    }
  }

  Future<String?> readAccessToken() async {
    return await _storage.read(key: StorageKeys.accessToken);
  }

  Future<String?> readRefreshToken() async {
    return await _storage.read(key: StorageKeys.refreshToken);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: StorageKeys.accessToken);
    await _storage.delete(key: StorageKeys.refreshToken);
  }

  Future<bool> hasValidTokens() async {
    final accessToken = await readAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }
}
