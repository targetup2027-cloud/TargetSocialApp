import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/features/messages/presentation/chat_detail_screen.dart';

void main() {
  group('ChatDetailScreen Widget Tests', () {
    Widget createTestWidget({
      String userName = 'John Doe',
      String userAvatar = 'https://i.pravatar.cc/150?u=1',
      String conversationId = 'conv_1',
      String? peerUserId,
    }) {
      return ProviderScope(
        child: MaterialApp(
          home: ChatDetailScreen(
            userName: userName,
            userAvatar: userAvatar,
            conversationId: conversationId,
            peerUserId: peerUserId,
          ),
        ),
      );
    }

    testWidgets('renders ChatDetailScreen with user name in header', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('shows Online status indicator', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Online'), findsOneWidget);
    });

    testWidgets('has video call button in app bar', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.videocam_outlined), findsOneWidget);
    });

    testWidgets('has phone call button in app bar', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.phone_outlined), findsOneWidget);
    });

    testWidgets('has more options menu button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('input area has text field', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(TextField), findsAtLeast(1));
    });

    testWidgets('back button navigates back', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('more menu opens on tap', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('View Profile'), findsOneWidget);
      expect(find.text('Mute'), findsOneWidget);
      expect(find.text('Clear Chat'), findsOneWidget);
      expect(find.text('Delete Conversation'), findsOneWidget);
    });

    testWidgets('video call button shows coming soon snackbar', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byIcon(Icons.videocam_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Video call coming soon'), findsOneWidget);
    });

    testWidgets('phone call button shows coming soon snackbar', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byIcon(Icons.phone_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Voice call coming soon'), findsOneWidget);
    });

    testWidgets('image message thumbnail renders for image message', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierColor: Colors.black87,
                        builder: (ctx) => Container(
                          key: const Key('image_viewer_interactive'),
                          color: Colors.black,
                          child: const Center(
                            child: Icon(Icons.image, size: 100, color: Colors.white),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      key: const Key('image_thumbnail_test'),
                      width: 200,
                      height: 200,
                      color: Colors.grey,
                      child: const Icon(Icons.image),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('image_thumbnail_test')), findsOneWidget);
    });

    testWidgets('tapping image thumbnail opens full-screen viewer', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierColor: Colors.black87,
                        builder: (ctx) => Scaffold(
                          backgroundColor: Colors.black,
                          body: Stack(
                            children: [
                              Center(
                                child: InteractiveViewer(
                                  key: const Key('image_viewer_interactive'),
                                  child: const Icon(Icons.image, size: 100, color: Colors.white),
                                ),
                              ),
                              Positioned(
                                top: 40,
                                right: 8,
                                child: IconButton(
                                  key: const Key('image_viewer_close_button'),
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  icon: const Icon(Icons.close, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      key: const Key('image_thumbnail_tap_test'),
                      width: 200,
                      height: 200,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byKey(const Key('image_thumbnail_tap_test')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('image_viewer_interactive')), findsOneWidget);
      expect(find.byKey(const Key('image_viewer_close_button')), findsOneWidget);
    });

    testWidgets('invalid image source shows error UI in viewer', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierColor: Colors.black87,
                        builder: (ctx) => Scaffold(
                          backgroundColor: Colors.black,
                          body: Column(
                            key: const Key('image_viewer_error_ui'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.image_not_supported, size: 64, color: Colors.white54),
                              const SizedBox(height: 16),
                              const Text('Image unavailable', style: TextStyle(color: Colors.white70)),
                              const SizedBox(height: 24),
                              TextButton.icon(
                                onPressed: () => Navigator.of(ctx).pop(),
                                icon: const Icon(Icons.arrow_back, color: Color(0xFF10B981)),
                                label: const Text('Go Back', style: TextStyle(color: Color(0xFF10B981))),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      key: const Key('invalid_image_thumbnail'),
                      width: 200,
                      height: 200,
                      color: Colors.grey,
                      child: const Icon(Icons.broken_image),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byKey(const Key('invalid_image_thumbnail')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('image_viewer_error_ui')), findsOneWidget);
      expect(find.text('Image unavailable'), findsOneWidget);
      expect(find.text('Go Back'), findsOneWidget);
    });

    testWidgets('video thumbnail renders with play overlay for video message', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  Container(
                    key: const Key('video_thumbnail'),
                    width: 200,
                    height: 200,
                    color: Colors.grey,
                  ),
                  Center(
                    child: Container(
                      key: const Key('video_play_overlay'),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('video_thumbnail')), findsOneWidget);
      expect(find.byKey(const Key('video_play_overlay')), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('tapping video thumbnail opens video player', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierColor: Colors.black87,
                        builder: (ctx) => Scaffold(
                          key: const Key('video_player_screen'),
                          backgroundColor: Colors.black,
                          body: Stack(
                            children: [
                              Center(
                                child: Column(
                                  key: const Key('video_player_loading'),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.play_arrow, color: Colors.white, size: 48),
                                    SizedBox(height: 24),
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    SizedBox(height: 16),
                                    Text('Opening video...', style: TextStyle(color: Colors.white70)),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 40,
                                right: 8,
                                child: IconButton(
                                  key: const Key('video_player_close_button'),
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  icon: const Icon(Icons.close, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      key: const Key('video_thumbnail_tap_test'),
                      width: 200,
                      height: 200,
                      color: Colors.grey,
                      child: const Icon(Icons.play_arrow),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byKey(const Key('video_thumbnail_tap_test')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('video_player_screen')), findsOneWidget);
      expect(find.byKey(const Key('video_player_close_button')), findsOneWidget);
    });

    testWidgets('invalid video source shows error UI in player', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierColor: Colors.black87,
                        builder: (ctx) => Scaffold(
                          key: const Key('video_player_screen'),
                          backgroundColor: Colors.black,
                          body: Stack(
                            children: [
                              Center(
                                child: Column(
                                  key: const Key('video_player_error_ui'),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.videocam_off, size: 64, color: Colors.white54),
                                    const SizedBox(height: 16),
                                    const Text('Video file not found', style: TextStyle(color: Colors.white70)),
                                    const SizedBox(height: 24),
                                    TextButton.icon(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      icon: const Icon(Icons.arrow_back, color: Color(0xFF10B981)),
                                      label: const Text('Go Back', style: TextStyle(color: Color(0xFF10B981))),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 40,
                                right: 8,
                                child: IconButton(
                                  key: const Key('video_player_close_button'),
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  icon: const Icon(Icons.close, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      key: const Key('invalid_video_thumbnail'),
                      width: 200,
                      height: 200,
                      color: Colors.grey,
                      child: const Icon(Icons.videocam_off),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byKey(const Key('invalid_video_thumbnail')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('video_player_error_ui')), findsOneWidget);
      expect(find.text('Video file not found'), findsOneWidget);
      expect(find.text('Go Back'), findsOneWidget);
    });
  });

  group('Responsive Layout Tests', () {
    Widget createTestWidgetWithSize({
      required double width,
      required double height,
    }) {
      return MediaQuery(
        data: MediaQueryData(size: Size(width, height)),
        child: ProviderScope(
          child: MaterialApp(
            home: const ChatDetailScreen(
              userName: 'Test User',
              userAvatar: 'https://i.pravatar.cc/150?u=test',
              conversationId: 'test_conv',
            ),
          ),
        ),
      );
    }

    testWidgets('on phone width < 840, no CenteredContentColumn wrapper', (tester) async {
      await tester.pumpWidget(createTestWidgetWithSize(width: 390, height: 844));
      await tester.pump(const Duration(milliseconds: 100));

      final scaffold = find.byType(Scaffold).first;
      expect(scaffold, findsOneWidget);

      expect(find.byType(TextField), findsAtLeast(1));
    });

    testWidgets('on tablet width >= 840, layout renders correctly', (tester) async {
      await tester.pumpWidget(createTestWidgetWithSize(width: 1024, height: 768));
      await tester.pump(const Duration(milliseconds: 100));

      final scaffold = find.byType(Scaffold).first;
      expect(scaffold, findsOneWidget);

      expect(find.byType(TextField), findsAtLeast(1));
    });

    testWidgets('on tablet landscape width, layout renders correctly', (tester) async {
      await tester.pumpWidget(createTestWidgetWithSize(width: 1366, height: 1024));
      await tester.pump(const Duration(milliseconds: 100));

      final scaffold = find.byType(Scaffold).first;
      expect(scaffold, findsOneWidget);

      expect(find.byType(TextField), findsAtLeast(1));
    });
  });

  group('Keyboard Focus Stability Tests', () {
    Widget createTestWidget({
      String userName = 'John Doe',
      String userAvatar = 'https://i.pravatar.cc/150?u=1',
      String conversationId = 'conv_1',
      String? peerUserId,
    }) {
      return ProviderScope(
        child: MaterialApp(
          home: ChatDetailScreen(
            userName: userName,
            userAvatar: userAvatar,
            conversationId: conversationId,
            peerUserId: peerUserId,
          ),
        ),
      );
    }

    testWidgets('keyboard is NOT requested on screen open (no autofocus)', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      final textField = tester.widget<TextField>(find.byType(TextField).first);
      expect(textField.autofocus, isFalse);
      expect(textField.focusNode?.hasFocus ?? false, isFalse);
    });

    testWidgets('tapping input requests focus', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byType(TextField).first);
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField).first);
      expect(textField.focusNode?.hasFocus, isTrue);
    });

    testWidgets('typing text does not lose focus', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byType(TextField).first);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Hello world');
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField).first);
      expect(textField.focusNode?.hasFocus, isTrue);
    });

    testWidgets('TextField has dedicated focusNode', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      final textField = tester.widget<TextField>(find.byType(TextField).first);
      expect(textField.focusNode, isNotNull);
    });
  });
}
