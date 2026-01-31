import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_providers.dart';
import '../../features/auth/data/password_hasher.dart';
import '../db/app_db.dart';

final authSeedProvider = FutureProvider<void>((ref) async {
  final authRepo = ref.read(authRepoProvider);
  await ref.read(dbProvider.future);

  final hasUsers = await authRepo.hasUsers();
  if (hasUsers) {
    return;
  }

  final hasher = PasswordHasher();
  final hashResult = await hasher.hashPassword('UAXIS@12345');
  final createdAtMs = DateTime.now().millisecondsSinceEpoch;

  final demoRecord = UserRecord(
    id: '00000000-0000-0000-0000-000000000001',
    email: 'demo@u-axis.local',
    displayName: 'Demo User',
    passwordSalt: hashResult.salt,
    passwordHash: hashResult.hash,
    createdAtMs: createdAtMs,
  );

  await (authRepo as dynamic).insertUserRecord(demoRecord);
});
