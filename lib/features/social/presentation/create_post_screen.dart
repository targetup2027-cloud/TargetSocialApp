import 'package:flutter/material.dart';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../app/theme/uaxis_theme.dart';
import '../../../app/theme/theme_extensions.dart';
import '../application/posts_controller.dart';
import '../models/post_data.dart';
import '../domain/entities/post.dart';
import '../widgets/media_viewer.dart';
import '../widgets/video_player_screen.dart';

import '../../business/domain/entities/business_plan.dart';

const int _kMaxTextLength = 500;

class CreatePostScreen extends ConsumerStatefulWidget {
  final Post? editPost;

  const CreatePostScreen({super.key, this.editPost});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  bool _isProcessingMedia = false;
  bool _isPosting = false;
  final List<String> _tempThumbnails = [];

  final TextEditingController _contentController = TextEditingController();
  PostVisibility _selectedPostVisibility = PostVisibility.public;
  final List<PostMedia> _mediaList = [];
  final ImagePicker _picker = ImagePicker();
  final Map<String, String> _videoThumbnails = {};
  String? _errorMessage;

  bool get isEditMode => widget.editPost != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _contentController.text = widget.editPost!.content ?? '';
      _selectedPostVisibility = widget.editPost!.visibility;
      // Filter out any invalid media but try to keep what we can
      _mediaList.addAll(widget.editPost!.media);
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _cleanupTempFiles();
    super.dispose();
  }

  Future<void> _cleanupTempFiles() async {
    for (final path in _tempThumbnails) {
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('Failed to delete temp thumbnail: $e');
      }
    }
    _tempThumbnails.clear();
  }

  bool get _hasContent =>
      _contentController.text.trim().isNotEmpty || _mediaList.isNotEmpty;

  bool get _isTextLimitExceeded =>
      _contentController.text.length > _kMaxTextLength;

  bool get _canPublish => _hasContent && !_isTextLimitExceeded && !_isProcessingMedia;

  // For now, we assume everyone is on the Free plan as per the user's request context.
  // In a real scenario, this would come from a user/business provider.
  final BusinessPlan _currentPlan = BusinessPlan.free;

  int get _maxImagesAllowed => _currentPlan.maxImages == -1 ? 999 : _currentPlan.maxImages;
  int get _maxVideosAllowed => _currentPlan.maxVideos == -1 ? 999 : _currentPlan.maxVideos;
  
  // Total media limit could be the sum or a specific limit. 
  // Assuming a safe max for the UI equal to the image limit + video limit or a fixed number.
  // But let's stick to the logic: separate counts for images and videos as requested.
  
  bool get _isImageLimitReached {
     final imageCount = _mediaList.where((m) => m.type == MediaType.image).length;
     return imageCount >= _maxImagesAllowed;
  }

  bool get _isVideoLimitReached {
     final videoCount = _mediaList.where((m) => m.type == MediaType.video).length;
     return videoCount >= _maxVideosAllowed;
  }

  Future<void> _pickImages() async {
    if (_isProcessingMedia) return;

    final imageCount = _mediaList.where((m) => m.type == MediaType.image).length;
    final remainingSlots = _maxImagesAllowed - imageCount;
    
    if (remainingSlots <= 0) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Free Plan limit: Max $_maxImagesAllowed images. Upgrade for more.'),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
               action: SnackBarAction(
                label: 'Upgrade',
                textColor: Colors.white,
                onPressed: () {
                  // Navigate to plans if needed
                  // context.push('/business/plans'); 
                },
              ),
            ),
          );
      }
      return;
    }

    setState(() => _isProcessingMedia = true);

    try {
      final List<XFile> images = await _picker.pickMultiImage(limit: remainingSlots);
      
      if (!mounted) return;

      if (images.isNotEmpty) {
        final List<PostMedia> validImages = [];
        String? errorMsg;

        for (final image in images) {
           final file = File(image.path);
           final size = await file.length();
           if (size > 100 * 1024 * 1024) { // 100MB limit
             errorMsg = 'Some images were skipped (max 100MB)';
             continue;
           }

           if (validImages.length + imageCount < _maxImagesAllowed) {
             // Show crop option for each image
             final processedPath = await _showCropOptionDialog(image.path);
             
             if (processedPath != null && mounted) {
               validImages.add(PostMedia(
                  id: DateTime.now().millisecondsSinceEpoch.toString() + validImages.length.toString(),
                  type: MediaType.image,
                  localPath: processedPath,
               ));
             }
           } else {
             errorMsg = 'Some images skipped. Plan limit reached.';
           }
        }

        if (mounted) {
          setState(() {
            _errorMessage = errorMsg;
            _mediaList.addAll(validImages);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to pick images';
        });
      }
    } finally {
      if (mounted) setState(() => _isProcessingMedia = false);
    }
  }

  /// Shows a dialog asking user if they want to crop the image
  /// Returns the final image path (cropped or original)
  /// Returns null if user cancels
  Future<String?> _showCropOptionDialog(String imagePath) async {
    final result = await showModalBottomSheet<_CropChoice>(
      context: context,
      backgroundColor: context.cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.hintColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Edit Image',
                  style: TextStyle(
                    color: context.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Image preview
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                constraints: const BoxConstraints(maxHeight: 180),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black,
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.crop, color: Color(0xFF8B5CF6)),
                ),
                title: Text('Crop Image', style: TextStyle(color: context.onSurface)),
                subtitle: Text('Adjust size and dimensions', style: TextStyle(color: context.hintColor, fontSize: 12)),
                onTap: () => Navigator.pop(ctx, _CropChoice.crop),
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.check_circle_outline, color: Color(0xFF3B82F6)),
                ),
                title: Text('Use Original', style: TextStyle(color: context.onSurface)),
                subtitle: Text('Full width and height', style: TextStyle(color: context.hintColor, fontSize: 12)),
                onTap: () => Navigator.pop(ctx, _CropChoice.useOriginal),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(ctx, _CropChoice.cancel),
                child: Text('Cancel', style: TextStyle(color: context.hintColor)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );

    if (result == null || result == _CropChoice.cancel) {
      return null;
    }

    if (result == _CropChoice.useOriginal) {
      return imagePath;
    }

    // Crop the image
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            backgroundColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            activeControlsWidgetColor: const Color(0xFF8B5CF6),
          ),
          IOSUiSettings(
            title: 'Crop Image',
            doneButtonTitle: 'Done',
            cancelButtonTitle: 'Cancel',
          ),
        ],
      );

      if (croppedFile != null) {
        return croppedFile.path;
      }
      // User cancelled cropping, return original
      return imagePath;
    } catch (e) {
      debugPrint('Error cropping image: $e');
      // On error, return original image
      return imagePath;
    }
  }

  Future<void> _pickVideo() async {
    if (_isProcessingMedia) return;

    if (_isVideoLimitReached) {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Free Plan limit: Max $_maxVideosAllowed videos. Upgrade for more.'),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Upgrade',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
      }
      return;
    }

    setState(() => _isProcessingMedia = true);

    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      
      if (!mounted) return;

      if (video != null) {
        final file = File(video.path);
        final size = await file.length();
        if (size > 100 * 1024 * 1024) {
           setState(() => _errorMessage = 'Video too large (max 100MB)');
           return;
        }

        final mediaId = DateTime.now().millisecondsSinceEpoch.toString();
        
        final thumbnailPath = await VideoThumbnail.thumbnailFile(
          video: video.path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 200,
          quality: 75,
        );

        if (!mounted) return;

        setState(() {
          _errorMessage = null;
          if (thumbnailPath != null) {
            _videoThumbnails[mediaId] = thumbnailPath;
            _tempThumbnails.add(thumbnailPath);
          }
          _mediaList.add(PostMedia(
            id: mediaId,
            type: MediaType.video,
            localPath: video.path,
          ));
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to pick video';
        });
      }
    } finally {
       if (mounted) setState(() => _isProcessingMedia = false);
    }
  }

  void _removeMedia(int index) {
    setState(() {
      final media = _mediaList[index];
      if (media.type == MediaType.video) {
        final thumbPath = _videoThumbnails.remove(media.id);
        if (thumbPath != null && _tempThumbnails.contains(thumbPath)) {
           // Delete file asynchronously but we remove from UI immediately
            File(thumbPath).delete().ignore();
            _tempThumbnails.remove(thumbPath);
        }
      }
      _mediaList.removeAt(index);
      _errorMessage = null;
    });
  }

  void _openMediaViewer(PostMedia media) {
    if (media.type == MediaType.video) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoPlayerScreen(
            videoUrl: media.remoteUrl ?? '',
            localPath: media.localPath,
            autoPlay: true,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MediaViewer(
            mediaUrl: media.remoteUrl ?? '',
            localPath: media.localPath,
            isOwner: true,
            onEdit: () {
              Navigator.pop(context); // Close viewer before editing
              if (media.localPath.isNotEmpty) {
                 _cropImage(media); // Only crop local files
              }
            },
          ),
        ),
      );
    }
  }

  Future<void> _cropImage(PostMedia media) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: media.localPath,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Edit Image',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Edit Image',
          ),
        ],
      );

      if (croppedFile != null && mounted) {
        final newPath = croppedFile.path;
        setState(() {
          final index = _mediaList.indexWhere((m) => m.id == media.id);
          if (index != -1) {
            _mediaList[index] = media.copyWith(localPath: newPath, remoteUrl: null); // Clear remoteUrl on edit
          }
        });
      }
    } catch (e) {
      // Handle error cleanly
      debugPrint('Error cropping image: $e');
    } finally {
      if (mounted) setState(() => _isProcessingMedia = false);
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasContent) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Discard post?',
          style: TextStyle(color: context.onSurface),
        ),
        content: Text(
          'You have unsaved changes. Are you sure you want to discard this post?',
          style: TextStyle(color: context.hintColor),
        ),
        actions: [
          TextButton(
            key: const Key('discard_dialog_keep_button'),
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Keep editing',
              style: TextStyle(color: context.hintColor),
            ),
          ),
          TextButton(
            key: const Key('discard_dialog_discard_button'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Discard',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _handleClose() async {
    final shouldPop = await _onWillPop();
    if (shouldPop && mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _savePost() async {
    if (!_canPublish) return;

    setState(() {
      _isPosting = true;
      _errorMessage = null;
    });

    try {
      if (isEditMode) {
        await ref.read(postsControllerProvider.notifier).updatePost(
              postId: widget.editPost!.id,
              content: _contentController.text.trim(),
              visibility: _selectedPostVisibility,
              media: _mediaList,
              // Use remoteUrl if available (server media), otherwise localPath (newly picked)
              mediaUrls: _mediaList.map((m) => m.remoteUrl ?? m.localPath).toList(),
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post updated successfully!'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
          context.pop();
        }
      } else {
        await ref.read(postsControllerProvider.notifier).createPost(
              content: _contentController.text.trim(),
              visibility: _selectedPostVisibility,
              media: _mediaList,
              mediaUrls: _mediaList.map((m) => m.localPath).toList(),
              mediaType: _mediaList.isNotEmpty
                  ? (_mediaList.first.type == MediaType.video
                      ? 'video'
                      : 'image')
                  : null,
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post created successfully!'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
          if (mounted) Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to save post. Please try again.';
        });
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  void _showPostVisibilityPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.hintColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Who can see this post?',
                style: TextStyle(
                  color: context.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _PostVisibilityOption(
              icon: Icons.public,
              label: 'Public',
              description: 'Anyone can see this post',
              isSelected: _selectedPostVisibility == PostVisibility.public,
              onTap: () {
                setState(() => _selectedPostVisibility = PostVisibility.public);
                Navigator.pop(context);
              },
            ),
            _PostVisibilityOption(
              icon: Icons.people,
              label: 'Friends',
              description: 'Only your friends can see this',
              isSelected: _selectedPostVisibility == PostVisibility.friends,
              onTap: () {
                setState(
                    () => _selectedPostVisibility = PostVisibility.friends);
                Navigator.pop(context);
              },
            ),
            _PostVisibilityOption(
              icon: Icons.lock,
              label: 'Only Me',
              description: 'Only you can see this post',
              isSelected: _selectedPostVisibility == PostVisibility.onlyMe,
              onTap: () {
                setState(() => _selectedPostVisibility = PostVisibility.onlyMe);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
  );
  }

  IconData _getPostVisibilityIcon() {
    switch (_selectedPostVisibility) {
      case PostVisibility.public:
        return Icons.public;
      case PostVisibility.friends:
        return Icons.people;
      case PostVisibility.onlyMe:
        return Icons.lock;
    }
  }

  String _getPostVisibilityLabel() {
    switch (_selectedPostVisibility) {
      case PostVisibility.public:
        return 'Public';
      case PostVisibility.friends:
        return 'Friends';
      case PostVisibility.onlyMe:
        return 'Only Me';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use a clean layout that respects the keyboard and safe areas
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = GoRouter.of(context);
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          navigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: context.scaffoldBg,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                key: const Key('create_post_scroll_view'),
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    _buildAuthorRow(),
                    const SizedBox(height: 8),
                    _buildComposer(),
                    if (_mediaList.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildMediaPreviews(),
                    ],

                    const SizedBox(height: 48), // Bottom padding for scrolling
                  ],
                ),
              ),
            ),
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: context.scaffoldBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close_rounded, color: context.onSurface, size: 28),
        onPressed: _handleClose,
        key: const Key('create_post_close_button'),
        tooltip: 'Close',
        style: IconButton.styleFrom(
          highlightColor: context.onSurface.withValues(alpha: 0.1),
        ),
      ),
      centerTitle: true,
      title: Text(
        isEditMode ? 'Edit Post' : 'New Post',
        style: TextStyle(
          color: context.onSurface,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _contentController,
            builder: (context, value, _) {
              final canPublish = (value.text.trim().isNotEmpty || _mediaList.isNotEmpty) &&
                                 value.text.length <= _kMaxTextLength &&
                                 !_isProcessingMedia;
              return AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: canPublish ? 1.0 : 0.5,
                child: FilledButton(
                  key: const Key('create_post_submit_button'),
                  onPressed: _isPosting || !canPublish
                      ? null
                      : () {
                          HapticFeedback.mediumImpact();
                          _savePost();
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: UAxisColors.social,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    minimumSize: const Size(0, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: canPublish ? 2 : 0,
                  ),
                  child: _isPosting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isEditMode ? 'Save' : 'Post',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAuthorRow() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(2.5),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.scaffoldBg,
            ),
            child: widget.editPost?.authorAvatarUrl != null
                ? ClipOval(
                    child: Image.network(
                      widget.editPost!.authorAvatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.person,
                        color: context.onSurface,
                      ),
                    ),
                  )
                : Icon(
                    Icons.person_outline_rounded,
                    color: context.onSurface,
                    size: 24,
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.editPost?.authorName ?? 'You',
              style: TextStyle(
                color: context.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 2),
            GestureDetector(
              onTap: _showPostVisibilityPicker,
              key: const Key('create_post_visibility_button'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: context.dividerColor,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getPostVisibilityIcon(),
                      color: const Color(0xFF6366F1),
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getPostVisibilityLabel(),
                      style: const TextStyle(
                        color: Color(0xFF6366F1),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: context.hintColor,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComposer() {
    return TextField(
      key: const Key('create_post_text_field'),
      controller: _contentController,
      minLines: 3,
      maxLines: null,
      autofocus: true,
      textInputAction: TextInputAction.newline,
      style: TextStyle(
        color: context.onSurface,
        fontSize: 20,
        height: 1.5,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        hintText: "What's happening?",
        hintStyle: TextStyle(
          color: context.hintColor.withValues(alpha: 0.5),
          fontSize: 20,
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildMediaPreviews() {
    return Container(
      key: const Key('create_post_media_previews'),
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _mediaList.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final media = _mediaList[index];
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 104,
                  height: 104,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildMediaContent(media),
                      if (media.type == MediaType.video)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _openMediaViewer(media),
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _removeMedia(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 14),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMediaContent(PostMedia media) {
    if (media.type == MediaType.video) {
        // ... (Video thumbnail logic not changed much but let's check remoteUrl)
      if (media.remoteUrl != null) {
          // If we had a mechanism to get thumb from remote video, we'd use it.
          // For now, fallback to placeholder or local thumb if cached.
      }
      
      final thumbPath = _videoThumbnails[media.id];
      if (thumbPath != null) {
        return Image.file(
          File(thumbPath),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => _buildVideoPlaceholder(),
        );
      }
      return _buildVideoPlaceholder();
    }
    
    // IMAGE
    if (media.remoteUrl != null && media.remoteUrl!.isNotEmpty) {
         return Image.network(
            media.remoteUrl!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => Container(
            color: context.cardColor,
            child: const Center(child: Icon(Icons.broken_image_rounded)),
            ),
        );
    }

    if (media.localPath.isNotEmpty) {
      return Image.file(
        File(media.localPath),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => Container(
          color: context.cardColor,
          child: const Center(child: Icon(Icons.broken_image_rounded)),
        ),
      );
    }
    
    return Container(
      color: context.cardColor,
      child: const Center(child: Icon(Icons.image_not_supported_rounded)),
    );
  }

  Widget _buildVideoPlaceholder() {
    return Container(
      color: Colors.black12,
      child: const Center(child: Icon(Icons.videocam_rounded, size: 40, color: Colors.black26)),
    );
  }

  Widget _buildBottomActionBar() {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom > 0 
        ? 12.0 
        : MediaQuery.of(context).padding.bottom + 12;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPadding),
      decoration: BoxDecoration(
        color: context.scaffoldBg,
        border: Border(top: BorderSide(color: context.dividerColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
           if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_rounded, color: Color(0xFFEF4444), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Row(
            children: [
              _ActionButton(
                key: const Key('create_post_photo_button'),
                icon: Icons.image_outlined,
                label: 'Photo',
                color: const Color(0xFF10B981),
                onTap: _isImageLimitReached || _isProcessingMedia ? null : _pickImages,
              ),
              const SizedBox(width: 16),
              _ActionButton(
                key: const Key('create_post_video_button'),
                icon: Icons.videocam_outlined,
                label: 'Video',
                 color: const Color(0xFFF59E0B),
                onTap: _isVideoLimitReached || _isProcessingMedia ? null : _pickVideo,
              ),
              const Spacer(),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _contentController,
                builder: (context, value, _) {
                  final textLength = value.text.length;
                  final isExceeded = textLength > _kMaxTextLength;
                  return Text(
                    '$textLength/$_kMaxTextLength',
                    style: TextStyle(
                      color: isExceeded ? const Color(0xFFEF4444) : context.hintColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: isEnabled ? () {
        HapticFeedback.lightImpact();
        onTap!();
      } : null,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostVisibilityOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _PostVisibilityOption({
    required this.icon,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF6366F1).withValues(alpha: 0.1)
                : context.cardColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? const Color(0xFF6366F1) : context.dividerColor,
            ),
          ),
          child: Icon(
            icon,
            color: isSelected ? const Color(0xFF6366F1) : context.onSurface,
            size: 24,
          ),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: context.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            color: context.hintColor,
            fontSize: 14,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle_rounded, color: Color(0xFF6366F1), size: 28)
            : null,
      ),
    );
  }
}

enum _CropChoice { crop, useOriginal, cancel }
