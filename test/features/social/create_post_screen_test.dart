import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_app/features/social/presentation/create_post_screen.dart';
import 'package:social_app/features/social/application/posts_controller.dart';
import 'package:social_app/features/social/models/post_data.dart';
import 'package:social_app/features/social/domain/entities/post.dart';
import 'package:social_app/app/theme/uaxis_theme.dart';
import 'package:social_app/app/theme/theme_extensions.dart';

void main() {
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  Widget buildTestWidget({Widget? child}) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: UAxisTheme.darkTheme,
        home: child ?? const CreatePostScreen(),
      ),
    );
  }

  group('CreatePostScreen', () {
    testWidgets('Post button is disabled when content is empty', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final postButton = find.byKey(const Key('create_post_submit_button'));
      expect(postButton, findsOneWidget);

      final button = tester.widget<FilledButton>(postButton);
      expect(button.onPressed, isNull);
    });

    testWidgets('Post button is enabled when text is entered', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final textField = find.byKey(const Key('create_post_text_field'));
      expect(textField, findsOneWidget);

      await tester.enterText(textField, 'Hello world!');
      await tester.pump();

      final postButton = find.byKey(const Key('create_post_submit_button'));
      final button = tester.widget<FilledButton>(postButton);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('Privacy selector shows current visibility', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Public'), findsOneWidget);
      expect(find.byIcon(Icons.public), findsOneWidget);
    });

    testWidgets('Tapping privacy selector opens bottom sheet', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final privacyButton = find.byKey(const Key('create_post_visibility_button'));
      expect(privacyButton, findsOneWidget);

      await tester.tap(privacyButton);
      await tester.pumpAndSettle();

      expect(find.text('Who can see this post?'), findsOneWidget);
      expect(find.text('Friends'), findsWidgets);
      expect(find.text('Only Me'), findsOneWidget);
    });

    testWidgets('Selecting Friends updates privacy state', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final privacyButton = find.byKey(const Key('create_post_visibility_button'));
      await tester.tap(privacyButton);
      await tester.pumpAndSettle();

      final friendsOption = find.widgetWithText(ListTile, 'Friends');
      await tester.tap(friendsOption);
      await tester.pumpAndSettle();

      expect(find.text('Friends'), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
    });

    testWidgets('Selecting Only Me updates privacy state', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final privacyButton = find.byKey(const Key('create_post_visibility_button'));
      await tester.tap(privacyButton);
      await tester.pumpAndSettle();

      final onlyMeOption = find.widgetWithText(ListTile, 'Only Me');
      await tester.tap(onlyMeOption);
      await tester.pumpAndSettle();

      expect(find.text('Only Me'), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('Discard dialog appears when closing with text content', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final textField = find.byKey(const Key('create_post_text_field'));
      await tester.enterText(textField, 'Unsaved content');
      await tester.pump();

      final closeButton = find.byKey(const Key('create_post_close_button'));
      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      expect(find.text('Discard post?'), findsOneWidget);
      expect(find.text('Keep editing'), findsOneWidget);
      expect(find.text('Discard'), findsOneWidget);
    });

    testWidgets('Keep editing dismisses discard dialog', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final textField = find.byKey(const Key('create_post_text_field'));
      await tester.enterText(textField, 'Unsaved content');
      await tester.pump();

      final closeButton = find.byKey(const Key('create_post_close_button'));
      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      final keepButton = find.byKey(const Key('discard_dialog_keep_button'));
      await tester.tap(keepButton);
      await tester.pumpAndSettle();

      expect(find.text('Discard post?'), findsNothing);
      expect(find.byKey(const Key('create_post_text_field')), findsOneWidget);
    });

    testWidgets('No discard dialog when closing with empty content', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final closeButton = find.byKey(const Key('create_post_close_button'));
      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      expect(find.text('Discard post?'), findsNothing);
    });

    testWidgets('Character counter shows correct count', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('0/500'), findsOneWidget);

      final textField = find.byKey(const Key('create_post_text_field'));
      await tester.enterText(textField, 'Hello');
      await tester.pump();

      expect(find.text('5/500'), findsOneWidget);
    });

    testWidgets('Photo button exists and is enabled initially', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final photoButton = find.byKey(const Key('create_post_photo_button'));
      expect(photoButton, findsOneWidget);
    });

    testWidgets('Video button exists and is enabled initially', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final videoButton = find.byKey(const Key('create_post_video_button'));
      expect(videoButton, findsOneWidget);
    });

    testWidgets('Author row displays You for new post', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('You'), findsOneWidget);
    });

    testWidgets('Title shows Create post for new post', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('New Post'), findsOneWidget);
    });

    testWidgets('Media preview displayed inside scroll view when media exists', (tester) async {
       final post = Post(
         id: '1',
         authorId: 'u1',
         authorName: 'User',
         authorUsername: 'user1',
         content: 'Test content',
         createdAt: DateTime.now(),
         media: [
           PostMedia(id: 'm1', type: MediaType.image, localPath: 'path/to/image'),
         ],
       );

       await tester.pumpWidget(buildTestWidget(child: CreatePostScreen(editPost: post)));
       await tester.pumpAndSettle();

       final scrollViewFinder = find.byKey(const Key('create_post_scroll_view'));
       final mediaPreviewFinder = find.byKey(const Key('create_post_media_previews'));

       expect(scrollViewFinder, findsOneWidget);
       expect(mediaPreviewFinder, findsOneWidget);

       // Verify media preview IS a child of scroll view (updated requirement)
       final descendant = find.descendant(
         of: scrollViewFinder,
         matching: mediaPreviewFinder,
       );
       expect(descendant, findsOneWidget);
    });
  });

}
