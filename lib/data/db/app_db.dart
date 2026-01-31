import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

final dbProvider = FutureProvider<Database>((ref) async {
  final dbPath = await getDatabasesPath();
  final path = p.join(dbPath, 'uaxis.db');

  return await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE users (
          id TEXT PRIMARY KEY,
          email TEXT UNIQUE NOT NULL,
          display_name TEXT NOT NULL,
          password_salt BLOB NOT NULL,
          password_hash BLOB NOT NULL,
          created_at_ms INTEGER NOT NULL
        )
      ''');
      await db.execute('CREATE UNIQUE INDEX IF NOT EXISTS idx_users_email ON users(email)');
    },
  );
});

Future<void> clearUserData(Database db, String userId) async {
  await db.transaction((txn) async {
    await txn.delete('users', where: 'id = ?', whereArgs: [userId]);
  });
}

Future<void> clearAllUserData(Database db) async {
  await db.transaction((txn) async {
    await txn.delete('users');
  });
}

class UserRecord {
  final String id;
  final String email;
  final String displayName;
  final Uint8List passwordSalt;
  final Uint8List passwordHash;
  final int createdAtMs;

  const UserRecord({
    required this.id,
    required this.email,
    required this.displayName,
    required this.passwordSalt,
    required this.passwordHash,
    required this.createdAtMs,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'password_salt': passwordSalt,
      'password_hash': passwordHash,
      'created_at_ms': createdAtMs,
    };
  }

  static UserRecord fromMap(Map<String, dynamic> map) {
    return UserRecord(
      id: map['id'] as String,
      email: map['email'] as String,
      displayName: map['display_name'] as String,
      passwordSalt: map['password_salt'] as Uint8List,
      passwordHash: map['password_hash'] as Uint8List,
      createdAtMs: map['created_at_ms'] as int,
    );
  }
}
