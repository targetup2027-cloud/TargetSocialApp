import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/business_controller.dart';
import '../application/business_progress_provider.dart';
import '../domain/entities/business.dart';
import 'widgets/business_progress_bar.dart';

class CreateBusinessScreen extends ConsumerStatefulWidget {
  const CreateBusinessScreen({super.key});

  @override
  ConsumerState<CreateBusinessScreen> createState() => _CreateBusinessScreenState();
}

class _CreateBusinessScreenState extends ConsumerState<CreateBusinessScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _addressController = TextEditingController();
  final _commercialRegController = TextEditingController();
  final _taxNumberController = TextEditingController();
  final _foundingYearController = TextEditingController();
  String _selectedCategory = 'Retail';
  bool _isLoading = false;
  Uint8List? _selectedLogoBytes;
  Uint8List? _selectedCoverBytes;
  XFile? _verticalVideo;
  XFile? _horizontalVideo;
  final List<XFile> _selectedImages = [];
  final Map<String, Uint8List> _imageBytes = {};
  final ImagePicker _picker = ImagePicker();

  final List<String> _categories = [
    'Retail',
    'Food & Beverage',
    'Technology',
    'Services',
    'Fashion',
    'Health & Fitness',
    'Entertainment',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(businessProgressProvider.notifier).initialize();
      _syncProgressToProvider();
    });
    _nameController.addListener(_updateProgress);
    _descriptionController.addListener(_updateProgress);
    _emailController.addListener(_updateProgress);
    _phoneController.addListener(_updateProgress);
    _websiteController.addListener(_updateProgress);
    _addressController.addListener(_updateProgress);
    _commercialRegController.addListener(_updateProgress);
    _taxNumberController.addListener(_updateProgress);
    _foundingYearController.addListener(_updateProgress);
  }

  void _updateProgress() {
    _syncProgressToProvider();
    setState(() {});
  }

  void _syncProgressToProvider() {
    ref.read(businessProgressProvider.notifier).updateMultipleFields({
      'name': _nameController.text.trim().isNotEmpty,
      'description': _descriptionController.text.trim().isNotEmpty,
      'logo': _selectedLogoBytes != null,
      'cover': _selectedCoverBytes != null,
      'subcategories': false,
      'email': _emailController.text.trim().isNotEmpty,
      'phone': _phoneController.text.trim().isNotEmpty,
      'website': _websiteController.text.trim().isNotEmpty,
      'address': _addressController.text.trim().isNotEmpty,
      'commercialReg': _commercialRegController.text.trim().isNotEmpty,
      'taxNumber': _taxNumberController.text.trim().isNotEmpty,
      'foundingYear': _foundingYearController.text.trim().isNotEmpty,
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _commercialRegController.dispose();
    _taxNumberController.dispose();
    _foundingYearController.dispose();
    _imageBytes.clear();
    _selectedLogoBytes = null;
    super.dispose();
  }

  Future<void> _createBusiness() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final category = _mapCategory(_selectedCategory);
      
      await ref.read(userBusinessesProvider.notifier).createBusiness(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: category,
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        commercialRegistration: _commercialRegController.text.trim().isEmpty ? null : _commercialRegController.text.trim(),
        taxNumber: _taxNumberController.text.trim().isEmpty ? null : _taxNumberController.text.trim(),
        foundingYear: _foundingYearController.text.trim().isEmpty ? null : int.tryParse(_foundingYearController.text.trim()),
        logoBytes: _selectedLogoBytes,
        coverBytes: _selectedCoverBytes,
        verticalVideo: _verticalVideo,
        horizontalVideo: _horizontalVideo,
        galleryImages: _selectedImages,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Business created successfully!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  BusinessCategory _mapCategory(String category) {
    switch (category) {
      case 'Retail': return BusinessCategory.retail;
      case 'Food & Beverage': return BusinessCategory.food;
      case 'Services': return BusinessCategory.services;
      case 'Technology': return BusinessCategory.technology;
      case 'Health & Fitness': return BusinessCategory.health;
      case 'Education': return BusinessCategory.education;
      case 'Entertainment': return BusinessCategory.entertainment;
      default: return BusinessCategory.other;
    }
  }

  void _pickLogo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF8B5CF6)),
              title: Text('Take Photo', style: TextStyle(color: context.onSurface)),
              onTap: () async {
                Navigator.pop(context);
                final image = await _picker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 512,
                  maxHeight: 512,
                  imageQuality: 85,
                );
                if (image != null && mounted) {
                  final bytes = await image.readAsBytes();
                  setState(() {
                    _selectedLogoBytes = bytes;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF8B5CF6)),
              title: Text('Choose from Gallery', style: TextStyle(color: context.onSurface)),
              onTap: () async {
                Navigator.pop(context);
                final image = await _picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 512,
                  maxHeight: 512,
                  imageQuality: 85,
                );
                if (image != null && mounted) {
                  final bytes = await image.readAsBytes();
                  setState(() {
                    _selectedLogoBytes = bytes;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCover() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 600,
      imageQuality: 85,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() => _selectedCoverBytes = bytes);
      _updateProgress();
    }
  }

  Future<void> _pickVideo(bool isVertical) async {
    final video = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 1),
    );
    
    if (video != null && mounted) {
      setState(() {
        if (isVertical) {
          _verticalVideo = video;
        } else {
          _horizontalVideo = video;
        }
      });
    }
  }

  Future<void> _pickImages() async {
    final images = await _picker.pickMultiImage(
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    
    if (images.isNotEmpty && mounted) {
      final remainingSlots = 5 - _selectedImages.length;
      if (remainingSlots > 0) {
        final imagesToAdd = images.take(remainingSlots).toList();
        for (final img in imagesToAdd) {
          final bytes = await img.readAsBytes();
          _imageBytes[img.path] = bytes;
        }
        setState(() {
          _selectedImages.addAll(imagesToAdd);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maximum 5 images allowed on Free Plan')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        backgroundColor: context.scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: context.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            Text(
              'Create Business',
              style: TextStyle(
                color: context.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36),
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
            child: const BusinessProgressBar(),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCoverSection(context),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: _pickLogo,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: context.dividerColor,
                        width: 2,
                      ),
                    ),
                    child: _selectedLogoBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.memory(
                              _selectedLogoBytes!,
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                color: context.hintColor,
                                size: 32,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Add Logo',
                                style: TextStyle(
                                  color: context.hintColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildTextField(
                label: 'Business Name',
                controller: _nameController,
                hint: 'Enter your business name',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Business name is required';
                  }
                  return null;
                },
                context: context,
              ),
              const SizedBox(height: 20),
              Text(
                'Category',
                style: TextStyle(
                  color: context.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.dividerColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    dropdownColor: context.cardColor,
                    style: TextStyle(color: context.onSurface, fontSize: 16),
                    icon: Icon(Icons.keyboard_arrow_down, color: context.iconColor),
                    items: _categories.map((cat) => DropdownMenuItem(
                      value: cat,
                      child: Text(cat),
                    )).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedCategory = value);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Description',
                controller: _descriptionController,
                hint: 'Describe your business',
                maxLines: 4,
                maxLength: 300,
                context: context,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Email',
                controller: _emailController,
                hint: 'business@example.com',
                context: context,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Phone',
                controller: _phoneController,
                hint: '+1 234 567 8900',
                context: context,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Website',
                controller: _websiteController,
                hint: 'https://yourbusiness.com',
                context: context,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Address',
                controller: _addressController,
                hint: 'Enter business address',
                maxLines: 2,
                context: context,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Founding Year',
                controller: _foundingYearController,
                hint: 'e.g. 2020',
                context: context,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Commercial Registration',
                controller: _commercialRegController,
                hint: 'Enter registration number',
                context: context,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Tax Number',
                controller: _taxNumberController,
                hint: 'Enter tax number',
                context: context,
              ),
              const SizedBox(height: 32),
              _buildMediaUploadSection(context),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified, color: Color(0xFF10B981), size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trust Score Enabled',
                            style: TextStyle(
                              color: context.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Your business will start with a base trust score',
                            style: TextStyle(
                              color: context.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: _isLoading ? null : _createBusiness,
                child: Container(
                  height: 52,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: !_isLoading
                        ? const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                          )
                        : null,
                    color: _isLoading ? context.onSurface.withValues(alpha: 0.1) : null,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Center(
                    child: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.onSurface,
                            ),
                          )
                        : const Text(
                            'Create Business',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cover Image',
          style: TextStyle(
            color: context.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickCover,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.dividerColor),
              image: _selectedCoverBytes != null
                  ? DecorationImage(
                      image: MemoryImage(_selectedCoverBytes!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _selectedCoverBytes == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.panorama_outlined,
                        color: context.hintColor,
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add Cover Image',
                        style: TextStyle(
                          color: context.hintColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  )
                : Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
    required BuildContext context,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.onSurfaceVariant,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          validator: validator,
          keyboardType: keyboardType,
          style: TextStyle(color: context.onSurface, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: context.hintColor),
            filled: true,
            fillColor: context.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaUploadSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111318), // Dark background matching image
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.dividerColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _MediaUploadSlot(
                  title: 'Vertical Video',
                  subtitle: '1 min max',
                  icon: Icons.videocam_outlined,
                  aspectRatio: 1.4,
                  onTap: () => _pickVideo(true),
                  isSelected: _verticalVideo != null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MediaUploadSlot(
                  title: 'Horizontal Video',
                  subtitle: '1 min max',
                  icon: Icons.videocam_outlined,
                  aspectRatio: 1.4,
                  onTap: () => _pickVideo(false),
                  isSelected: _horizontalVideo != null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (int i = 0; i < 5; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _MediaUploadSlot(
                    icon: Icons.image_outlined,
                    aspectRatio: 1.0,
                    isSmall: true,
                    onTap: _pickImages,
                    imageBytes: i < _selectedImages.length ? _imageBytes[_selectedImages[i].path] : null,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Free Plan: 2 videos + 5 images',
                style: TextStyle(
                  color: context.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => context.push('/business-plans'),
                child: const Text(
                  'Upgrade for more',
                  style: TextStyle(
                    color: Color(0xFF6366F1), // Indigo/Blueish like in image
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MediaUploadSlot extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final IconData icon;
  final double aspectRatio;
  final bool isSmall;
  final VoidCallback? onTap;
  final Uint8List? imageBytes;
  final bool isSelected;

  const _MediaUploadSlot({
    this.title,
    this.subtitle,
    required this.icon,
    required this.aspectRatio,
    this.isSmall = false,
    this.onTap,
    this.imageBytes,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: isSelected || imageBytes != null 
              ? const Color(0xFF10B981)
              : const Color(0xFF4B5563),
          strokeWidth: 1.5,
          gap: 4,
          dash: 4,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: imageBytes != null
                ? Image.memory(imageBytes!, fit: BoxFit.cover)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle : icon,
                        color: isSelected 
                            ? const Color(0xFF10B981) 
                            : const Color(0xFF9CA3AF), // Light gray icon
                        size: isSmall ? 20 : 24,
                      ),
                      if (!isSmall && title != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          title!,
                          style: TextStyle(
                            color: isSelected 
                                ? const Color(0xFF10B981)
                                : const Color(0xFFD1D5DB), // Light gray text
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dash;

  _DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
    this.dash = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(12),
      ));

    final Path dashPath = Path();
    double distance = 0.0;
    
    // Simple dash implementation
    for (ui.PathMetric measurePath in path.computeMetrics()) {
      while (distance < measurePath.length) {
        final double length = measurePath.length;
        if (distance + dash > length) {
           // Handle wrap around roughly or just clip
           dashPath.addPath(
             measurePath.extractPath(distance, length),
             Offset.zero,
           );
        } else {
           dashPath.addPath(
             measurePath.extractPath(distance, distance + dash),
             Offset.zero,
           );
        }
        distance += dash + gap;
      }
      distance = 0.0; // Reset for next contour if any
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
