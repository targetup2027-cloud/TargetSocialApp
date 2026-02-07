import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/features/profile/application/profile_controller.dart';
import 'package:social_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:social_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:social_app/features/profile/domain/entities/user_profile.dart';
import 'package:social_app/core/network/network_client.dart';

void main() {
  late ProviderContainer container;
  late ProfileController controller;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        profileRepositoryProvider.overrideWithValue(
          ProfileRepositoryImpl(
            remoteDataSource: ProfileRemoteDataSourceImpl(client: DioNetworkClient()),
            useMockData: true,
          ),
        ),
      ],
    );
    controller = container.read(profileControllerProvider.notifier);
  });

  tearDown(() {
    container.dispose();
  });

  group('ProfileController Functional Tests', () {
    test('Initial state is loading then data', () async {
      expect(container.read(profileControllerProvider), const AsyncValue<UserProfile>.loading());
      
      await Future.delayed(const Duration(milliseconds: 500)); // Wait for mock delay
      
      final state = container.read(profileControllerProvider);
      expect(state.hasValue, true);
      expect(state.value!.username, 'johndoe'); // From MockData
    });

    test('updateProfile updates state', () async {
      // Wait for init
      await Future.delayed(const Duration(milliseconds: 500));
      
      await controller.updateProfile(displayName: 'Updated Name');
      
      final state = container.read(profileControllerProvider);
      expect(state.value!.displayName, 'Updated Name');
    });

    test('updateProfile throws exception on validation error', () async {
      await Future.delayed(const Duration(milliseconds: 500));
      
      try {
        await controller.updateProfile(displayName: 'A'); // Too short
        fail('Should trigger validation error');
      } catch (e) {
        expect(e.toString(), contains('Display Name'));
      }
    });

    test('updateAvatar updates state', () async {
      await Future.delayed(const Duration(milliseconds: 500));
      
      await controller.updateAvatar('path/to/image.jpg');
      
      final state = container.read(profileControllerProvider);
      expect(state.value!.avatarUrl, isNotNull);
      // Mock repo returns a hardcoded URL, check for that or strict mock behavior
      expect(state.value!.avatarUrl, contains('http')); 
    });

    test('updateIdDocumentType updates state', () async {
      await Future.delayed(const Duration(milliseconds: 500));

      await controller.updateIdDocumentType(IdDocumentType.passport);

      final state = container.read(profileControllerProvider);
      expect(state.value!.idDocumentType, IdDocumentType.passport);
    });
  });
}
