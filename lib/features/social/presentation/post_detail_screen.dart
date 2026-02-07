import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/universe_back_button.dart';
import '../../../app/theme/theme_extensions.dart';
import '../models/post_data.dart';
import '../widgets/post_card.dart';
import '../application/posts_controller.dart';
import '../application/current_user_provider.dart';
import 'comments_sheet.dart';
import 'package:go_router/go_router.dart';

class PostDetailScreen extends ConsumerWidget {
  final PostData postData;

  const PostDetailScreen({
    super.key,
    required this.postData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        leading: const UniverseBackButton(),
        title: Text(
          'Post',
          style: TextStyle(
            color: context.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: context.scaffoldBg,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: PostCard(
          post: postData,
          isOwner: postData.authorId == ref.read(currentUserIdProvider),
           onReact: (type) {
             // We need to map back to original post ID if possible, 
             // but PostData holds the ID.
             ref.read(postsControllerProvider.notifier).reactToPost(postData.id, type);
           },
          onComment: () => CommentsSheet.show(context, postData.id),
          // We disable tap on post here to avoid recursion
          onTapPost: null,
          onAuthorTap: () => context.push('/user/${postData.authorId}'),
          // Add other handlers as needed
        ),
      ),
    );
  }
}
