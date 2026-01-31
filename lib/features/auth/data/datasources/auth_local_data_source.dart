import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../../data/db/app_db.dart';
import '../../domain/user.dart';
import '../password_hasher.dart';

abstract interface class AuthLocalDataSource {
  Future<User?> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  Future<User?> login({
    required String email,
    required String password,
  });

  Future<User?> getUserById(String userId);

  Future<bool> hasUsers();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final Ref _ref;
  final PasswordHasher _hasher;
  final Uuid _uuid;

  AuthLocalDataSourceImpl(this._ref)
      : _hasher = PasswordHasher(),
        _uuid = const Uuid();

  Future<Database> get _db async => await _ref.read(dbProvider.future);

  @override
  Future<User?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final db = await _db;
    final existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase().trim()],
    );

    if (existing.isNotEmpty) {
      return null;
    }

    final hashResult = await _hasher.hashPassword(password);
    final userId = _uuid.v4();
    final createdAtMs = DateTime.now().millisecondsSinceEpoch;

    final record = UserRecord(
      id: userId,
      email: email.toLowerCase().trim(),
      displayName: displayName.trim(),
      passwordSalt: hashResult.salt,
      passwordHash: hashResult.hash,
      createdAtMs: createdAtMs,
    );

    await db.insert('users', record.toMap());

    return User(
      id: userId,
      email: record.email,
      displayName: record.displayName,
      createdAtMs: createdAtMs,
    );
  }

  @override
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    final db = await _db;
    final results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase().trim()],
    );

    if (results.isEmpty) {
      await _hasher.hashPassword(password);
      return null;
    }

    final record = UserRecord.fromMap(results.first);

    final isValid = await _hasher.verifyPassword(
      password,
      record.passwordSalt,
      record.passwordHash,
    );

    if (!isValid) {
      return null;
    }

    return User(
      id: record.id,
      email: record.email,
      displayName: record.displayName,
      createdAtMs: record.createdAtMs,
    );
  }

  @override
  Future<User?> getUserById(String userId) async {
    final db = await _db;
    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (results.isEmpty) {
      return null;
    }

    final record = UserRecord.fromMap(results.first);

    return User(
      id: record.id,
      email: record.email,
      displayName: record.displayName,
      createdAtMs: record.createdAtMs,
    );
  }

  @override
  Future<bool> hasUsers() async {
    final db = await _db;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM users'),
    );
    return (count ?? 0) > 0;
  }
}

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl(ref);
});
