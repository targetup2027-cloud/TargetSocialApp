import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth_providers.dart';
import '../../../data/db/app_db.dart';
import 'auth_guard.dart';
import '../../../../core/result/result.dart';
import '../data/session_store.dart';
import '../domain/user.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final bool isLoading;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.errorMessage,
    this.isLoading = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    bool? isLoading,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authControllerProvider).user;
});

class AuthController extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthController(this._ref) : super(const AuthState());

  SessionStore get _sessionStore => _ref.read(sessionStoreProvider);
  dynamic get _authRepo => _ref.read(authRepoProvider);

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final userId = await _sessionStore.getUserId();

      if (userId == null || userId.isEmpty) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          isLoading: false,
          clearUser: true,
        );
        return;
      }

      final result = await _authRepo.getUserById(userId);

      if (result case Success(value: final user?)) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          isLoading: false,
        );
      } else {
        await _sessionStore.clearSession();
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          isLoading: false,
          clearUser: true,
        );
      }
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        clearUser: true,
      );
    }
  }

  void setAuthenticatedMock() {
    state = state.copyWith(
      status: AuthStatus.authenticated,
      isLoading: false,
    );
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String confirmPassword,
    String? firstName,
    String? lastName,
    String? displayName,
    DateTime? dateOfBirth,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _authRepo.signUp(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        firstName: firstName,
        lastName: lastName,
        displayName: displayName,
        dateOfBirth: dateOfBirth,
      );

      switch (result) {
        case Success(value: final user):
          await _sessionStore.saveSession(user.id);
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            isLoading: false,
          );
          return true;
        case Err(failure: final f):
          state = state.copyWith(
            isLoading: false,
            errorMessage: f.message,
          );
          return false;
        default:
          return false;
      }
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to create account. Please try again.',
      );
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _authRepo.login(
        email: email,
        password: password,
      );

      switch (result) {
        case Success(value: final user):
          await _sessionStore.saveSession(user.id);
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            isLoading: false,
          );
          return true;
        case Err(failure: final f):
          state = state.copyWith(
            isLoading: false,
            errorMessage: f.message,
          );
          return false;
        default:
          return false;
      }
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to sign in. Please try again.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final userId = await _sessionStore.getUserId();
      await _sessionStore.clearSession();
      
      final dbAsync = _ref.read(dbProvider);
      if (dbAsync.hasValue && userId != null) {
        await clearUserData(dbAsync.value!, userId);
      }
      
      _ref.read(authGuardProvider.notifier).setUnauthenticated();
    } finally {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        clearUser: true,
      );
    }
  }

  Future<bool> signInWithGoogle(String idToken) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _authRepo.signInWithGoogle(idToken);

      switch (result) {
        case Success(value: final user):
          await _sessionStore.saveSession(user.id);
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            isLoading: false,
          );
          return true;
        case Err(failure: final f):
          state = state.copyWith(
            isLoading: false,
            errorMessage: f.message,
          );
          return false;
        default:
          return false;
      }
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to sign in with Google. Please try again.',
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
