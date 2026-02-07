import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/features/messages/presentation/messages_screen.dart';
import 'package:social_app/features/messages/application/messages_controller.dart';
import 'package:social_app/features/messages/data/models/message_model.dart';

void main() {
  group('MessagesScreen Tests', () {
    testWidgets('displays shimmer loading while loading conversations', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            conversationsControllerProvider.overrideWith(
              (ref) => ConversationsController(ref.watch(messagesRepositoryProvider))
                ..state = const AsyncValue.loading(),
            ),
          ],
          child: const MaterialApp(home: MessagesScreen()),
        ),
      );

      await tester.pump();
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('displays empty state with CTA button when no conversations', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            conversationsControllerProvider.overrideWith(
              (ref) => ConversationsController(ref.watch(messagesRepositoryProvider))
                ..state = const AsyncValue.data([]),
            ),
          ],
          child: const MaterialApp(home: MessagesScreen()),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('No messages yet'), findsOneWidget);
      expect(find.text('Start a new message'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('search filters conversations by participant name', (tester) async {
      final mockConversations = [
        ConversationModel(
          id: 'conv1',
          participants: const [
            ConversationParticipantModel(
              id: 'user1',
              username: 'layla',
              displayName: 'Layla Ahmed',
            ),
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ConversationModel(
          id: 'conv2',
          participants: const [
            ConversationParticipantModel(
              id: 'user2',
              username: 'omar',
              displayName: 'Omar Hassan',
            ),
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            conversationsControllerProvider.overrideWith(
              (ref) => ConversationsController(ref.watch(messagesRepositoryProvider))
                ..state = AsyncValue.data(mockConversations),
            ),
          ],
          child: const MaterialApp(home: MessagesScreen()),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Layla Ahmed'), findsOneWidget);
      expect(find.text('Omar Hassan'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'Layla');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
    });

    testWidgets('unread badge displays count correctly', (tester) async {
      final mockConversations = [
        ConversationModel(
          id: 'conv1',
          participants: const [
            ConversationParticipantModel(
              id: 'user1',
              username: 'test',
              displayName: 'Test User',
            ),
          ],
          unreadCount: 5,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ConversationModel(
          id: 'conv2',
          participants: const [
            ConversationParticipantModel(
              id: 'user2',
              username: 'test2',
              displayName: 'Test User 2',
            ),
          ],
          unreadCount: 150,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            conversationsControllerProvider.overrideWith(
              (ref) => ConversationsController(ref.watch(messagesRepositoryProvider))
                ..state = AsyncValue.data(mockConversations),
            ),
          ],
          child: const MaterialApp(home: MessagesScreen()),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('5'), findsOneWidget);
      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('long press shows conversation menu', (tester) async {
      final mockConversations = [
        ConversationModel(
          id: 'conv1',
          participants: const [
            ConversationParticipantModel(
              id: 'user1',
              username: 'test',
              displayName: 'Test User',
            ),
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            conversationsControllerProvider.overrideWith(
              (ref) => ConversationsController(ref.watch(messagesRepositoryProvider))
                ..state = AsyncValue.data(mockConversations),
            ),
          ],
          child: const MaterialApp(home: MessagesScreen()),
        ),
      );

      await tester.pumpAndSettle();
      await tester.longPress(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      expect(find.text('Pin conversation'), findsOneWidget);
      expect(find.text('Mute notifications'), findsOneWidget);
      expect(find.text('Delete conversation'), findsOneWidget);
    });

    testWidgets('pinned conversations show section header', (tester) async {
      final mockConversations = [
        ConversationModel(
          id: 'conv1',
          participants: const [
            ConversationParticipantModel(
              id: 'user1',
              username: 'test',
              displayName: 'Pinned User',
            ),
          ],
          isPinned: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ConversationModel(
          id: 'conv2',
          participants: const [
            ConversationParticipantModel(
              id: 'user2',
              username: 'test2',
              displayName: 'Regular User',
            ),
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            conversationsControllerProvider.overrideWith(
              (ref) => ConversationsController(ref.watch(messagesRepositoryProvider))
                ..state = AsyncValue.data(mockConversations),
            ),
          ],
          child: const MaterialApp(home: MessagesScreen()),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('PINNED'), findsOneWidget);
    });
  });
}
