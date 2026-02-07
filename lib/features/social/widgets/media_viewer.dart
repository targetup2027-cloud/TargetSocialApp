import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../../../app/theme/uaxis_theme.dart';
import '../../../app/theme/theme_extensions.dart';
import 'package:gal/gal.dart';

class MediaViewer extends StatefulWidget {
  final String mediaUrl;
  final String? localPath;
  final bool isOwner;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const MediaViewer({
    super.key,
    required this.mediaUrl,
    this.localPath,
    this.isOwner = false,
    this.onDelete,
    this.onEdit,
  });

  @override
  State<MediaViewer> createState() => _MediaViewerState();
}

class _MediaViewerState extends State<MediaViewer> with SingleTickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animationController.addListener(() {
      if (_animation != null) {
        _transformationController.value = _animation!.value;
      }
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: Matrix4.identity(),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward(from: 0);
  }

  Future<void> _downloadImage() async {
    try {
      // Check for access first, although Gal handles requests, it's good to be explicit for UI feedback
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final granted = await Gal.requestAccess();
        if (!granted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Permission denied to save image'),
                backgroundColor: const Color(0xFFEF4444),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
          return;
        }
      }

      if (widget.localPath != null && widget.localPath!.isNotEmpty) {
        await Gal.putImage(widget.localPath!);
      } else if (widget.mediaUrl.startsWith('http')) {
        final response = await http.get(Uri.parse(widget.mediaUrl));
        if (response.statusCode == 200) {
          await Gal.putImageBytes(response.bodyBytes);
        } else {
          throw Exception('Failed to download image');
        }
      } else {
        throw Exception('Invalid media source');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                const Text('Image saved to Gallery'),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save image: $e'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _shareImage() async {
    try {
      String filePath;
      if (widget.localPath != null && widget.localPath!.isNotEmpty) {
        filePath = widget.localPath!;
      } else if (widget.mediaUrl.startsWith('http')) {
        final response = await http.get(Uri.parse(widget.mediaUrl));
        if (response.statusCode == 200) {
          final directory = await getTemporaryDirectory();
          final file = File('${directory.path}/share_${DateTime.now().millisecondsSinceEpoch}.jpg');
          await file.writeAsBytes(response.bodyBytes);
          filePath = file.path;
        } else {
          throw Exception('Failed to download image');
        }
      } else {
        throw Exception('Invalid media source');
      }

      await Share.shareXFiles([XFile(filePath)], text: 'Shared via U-ΛXIS');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to share image'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _copyLink() {
    if (widget.mediaUrl.startsWith('http')) {
      Clipboard.setData(ClipboardData(text: widget.mediaUrl));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              const Text('Link copied to clipboard'),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No link available for local media'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Report Image',
          style: TextStyle(color: context.onSurface),
        ),
        content: Text(
          'Are you sure you want to report this image?',
          style: TextStyle(color: context.hintColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.hintColor),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Report submitted'),
                  backgroundColor: const Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: const Text(
              'Report',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Image',
          style: TextStyle(color: context.onSurface),
        ),
        content: Text(
          'Are you sure you want to delete this image?',
          style: TextStyle(color: context.hintColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.hintColor),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              widget.onDelete?.call();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }

  void _showOptionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
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
              const SizedBox(height: 20),
              _buildOption(
                icon: Icons.download_rounded,
                label: 'Download',
                onTap: () {
                  Navigator.pop(context);
                  _downloadImage();
                },
              ),
              _buildOption(
                icon: Icons.share_rounded,
                label: 'Share',
                onTap: () {
                  Navigator.pop(context);
                  _shareImage();
                },
              ),
              _buildOption(
                icon: Icons.link_rounded,
                label: 'Copy Link',
                onTap: () {
                  Navigator.pop(context);
                  _copyLink();
                },
              ),
              _buildOption(
                icon: Icons.flag_rounded,
                label: 'Report',
                onTap: () {
                  Navigator.pop(context);
                  _showReportDialog();
                },
                isDestructive: true,
              ),
              if (widget.isOwner) ...[
                Divider(color: context.dividerColor, height: 1),
                _buildOption(
                  icon: Icons.edit_rounded,
                  label: 'Edit',
                  onTap: () {
                    Navigator.pop(context);
                    widget.onEdit?.call();
                  },
                ),
                _buildOption(
                  icon: Icons.delete_rounded,
                  label: 'Delete',
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteDialog();
                  },
                  isDestructive: true,
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? const Color(0xFFEF4444) : context.onSurface,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive ? const Color(0xFFEF4444) : context.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          setState(() => _showControls = !_showControls);
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            InteractiveViewer(
              transformationController: _transformationController,
              onInteractionEnd: (_) {
                final scale = _transformationController.value.getMaxScaleOnAxis();
                if (scale < 1.0) {
                  _resetZoom();
                }
              },
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: _buildImage(),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                          onPressed: () => Navigator.pop(context),
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 28),
                          onPressed: _showOptionsSheet,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (widget.localPath != null && widget.localPath!.isNotEmpty) {
      final file = File(widget.localPath!);
      return Image.file(
        file,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildNetworkImage(),
      );
    }
    return _buildNetworkImage();
  }

  Widget _buildNetworkImage() {
    if (widget.mediaUrl.isEmpty) {
      return Container(
        color: const Color(0xFF2A2A2A),
        child: const Center(
          child: Icon(Icons.broken_image, color: Colors.white38, size: 64),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: widget.mediaUrl,
      fit: BoxFit.contain,
      placeholder: (context, url) => const Center(
        child: CircularProgressIndicator(
          color: UAxisColors.social,
          strokeWidth: 2,
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: const Color(0xFF2A2A2A),
        child: const Center(
          child: Icon(Icons.broken_image, color: Colors.white38, size: 64),
        ),
      ),
    );
  }
}
