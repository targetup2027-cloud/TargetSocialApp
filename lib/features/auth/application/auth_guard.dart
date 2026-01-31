import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/session_store.dart';

enum AuthGuardStatus { unknown, authenticated, unauthenticated }

final authGuardProvider = StateNotifierProvider<AuthGuardNotifier, AuthGuardStatus>((ref) {
  return AuthGuardNotifier(ref.watch(sessionStoreProvider));
});

class AuthGuardNotifier extends StateNotifier<AuthGuardStatus> {
  final SessionStore _sessionStore;

  AuthGuardNotifier(this._sessionStore) : super(AuthGuardStatus.unknown) {
    _checkSession();
  }

  Future<void> _checkSession() async {
    final hasSession = await _sessionStore.hasSession();
    state = hasSession ? AuthGuardStatus.authenticated : AuthGuardStatus.unauthenticated;
  }

  Future<void> refresh() async {
    await _checkSession();
  }

  void setAuthenticated() {
    state = AuthGuardStatus.authenticated;
  }

  void setUnauthenticated() {
    state = AuthGuardStatus.unauthenticated;
  }
}
