import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class GoogleSignInService {
  static final GoogleSignInService _instance = GoogleSignInService._internal();
  factory GoogleSignInService() => _instance;
  GoogleSignInService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  Future<GoogleSignInAccount?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      return account;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[GoogleSignInService] Sign in error: $error');
      }
      return null;
    }
  }

  Future<String?> getIdToken() async {
    try {
      final currentUser = _googleSignIn.currentUser;
      if (currentUser == null) {
        if (kDebugMode) {
          debugPrint('[GoogleSignInService] No current user');
        }
        return null;
      }

      final auth = await currentUser.authentication;
      return auth.idToken;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[GoogleSignInService] Get token error: $error');
      }
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[GoogleSignInService] Sign out error: $error');
      }
    }
  }

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
  
  bool get isSignedIn => _googleSignIn.currentUser != null;
}
