import '../../../../core/result/result.dart';
import '../user.dart';

abstract interface class AuthRepository {
  Future<Result<User>> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  Future<Result<User>> login({
    required String email,
    required String password,
  });

  Future<Result<User?>> getUserById(String userId);

  Future<bool> hasUsers();

  Future<Result<User>> signInWithGoogle(String idToken);
}
