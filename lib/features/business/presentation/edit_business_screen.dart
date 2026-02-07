import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/business_controller.dart';
import '../application/business_progress_provider.dart';
import '../domain/entities/business.dart';
import 'widgets/business_progress_bar.dart';

class EditBusinessScreen extends ConsumerStatefulWidget {
  final Business business;

  const EditBusinessScreen({super.key, required this.business});

  @override
  ConsumerState<EditBusinessScreen> createState() => _EditBusinessScreenState();
}

class _EditBusinessScreenState extends ConsumerState<EditBusinessScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _websiteController;
  late TextEditingController _addressController;
  late TextEditingController _commercialRegController;
  late TextEditingController _taxNumberController;
  late TextEditingController _foundingYearController;
  late String _selectedCategory;
  bool _isLoading = false;
  Uint8List? _selectedLogoBytes;
  Uint8List? _selectedCoverBytes;
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedVerticalVideo;
  XFile? _selectedHorizontalVideo;
  List<XFile> _selectedGalleryImages = [];
  int _currentPercentage = 0;

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
    _nameController = TextEditingController(text: widget.business.name);
    _descriptionController = TextEditingController(text: widget.business.description ?? '');
    _emailController = TextEditingController(text: widget.business.email ?? '');
    _phoneController = TextEditingController(text: widget.business.phone ?? '');
    _websiteController = TextEditingController(text: widget.business.website ?? '');
    _addressController = TextEditingController(
      text: widget.business.address?.formattedAddress ?? '',
    );
    _commercialRegController = TextEditingController(text: widget.business.commercialRegistration ?? '');
    _taxNumberController = TextEditingController(text: widget.business.taxNumber ?? '');
    _foundingYearController = TextEditingController(
      text: widget.business.foundingYear?.toString() ?? '',
    );
    _selectedCategory = _categoryToString(widget.business.category);
    _currentPercentage = _calculateDynamicPercentage();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncProgressToProvider();
    });

    _nameController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _websiteController.addListener(_onFieldChanged);
    _addressController.addListener(_onFieldChanged);
    _commercialRegController.addListener(_onFieldChanged);
    _taxNumberController.addListener(_onFieldChanged);
    _foundingYearController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    final newPercentage = _calculateDynamicPercentage();
    if (newPercentage != _currentPercentage) {
      setState(() => _currentPercentage = newPercentage);
    }
    _syncProgressToProvider();
  }

  void _syncProgressToProvider() {
    ref.read(businessProgressProvider.notifier).updateMultipleFields({
      'name': _nameController.text.trim().isNotEmpty,
      'description': _descriptionController.text.trim().isNotEmpty,
      'logo': _selectedLogoBytes != null || (widget.business.logoUrl?.isNotEmpty ?? false),
      'cover': _selectedCoverBytes != null || (widget.business.coverImageUrl?.isNotEmpty ?? false),
      'email': _emailController.text.trim().isNotEmpty,
      'phone': _phoneController.text.trim().isNotEmpty,
      'website': _websiteController.text.trim().isNotEmpty,
      'address': _addressController.text.trim().isNotEmpty,
      'hours': widget.business.hours != null,
      'subcategories': widget.business.subcategories.isNotEmpty,
      'socialLinks': widget.business.socialLinks?.isNotEmpty ?? false,
      'productsCount': widget.business.productsCount > 0,
      'commercialReg': _commercialRegController.text.trim().isNotEmpty,
      'taxNumber': _taxNumberController.text.trim().isNotEmpty,
      'foundingYear': _foundingYearController.text.trim().isNotEmpty,
    });
  }

  int _calculateDynamicPercentage() {
    int score = 0;
    const int totalFields = 15;

    if (_nameController.text.trim().isNotEmpty) score++;
    if (_descriptionController.text.trim().isNotEmpty) score++;
    if (_selectedLogoBytes != null || (widget.business.logoUrl?.isNotEmpty ?? false)) score++;
    if (_selectedCoverBytes != null || (widget.business.coverImageUrl?.isNotEmpty ?? false)) score++;
    if (_emailController.text.trim().isNotEmpty) score++;
    if (_phoneController.text.trim().isNotEmpty) score++;
    if (_websiteController.text.trim().isNotEmpty) score++;
    if (_addressController.text.trim().isNotEmpty) score++;
    if (widget.business.hours != null) score++;
    if (widget.business.subcategories.isNotEmpty) score++;
    if (widget.business.socialLinks?.isNotEmpty ?? false) score++;
    if (widget.business.productsCount > 0) score++;
    if (_commercialRegController.text.trim().isNotEmpty) score++;
    if (_taxNumberController.text.trim().isNotEmpty) score++;
    if (_foundingYearController.text.trim().isNotEmpty) score++;

    return ((score / totalFields) * 100).round();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _commercialRegController.dispose();
    _taxNumberController.dispose();
    _foundingYearController.dispose();
    super.dispose();
  }

  String _categoryToString(BusinessCategory category) {
    switch (category) {
      case BusinessCategory.retail: return 'Retail';
      case BusinessCategory.food: return 'Food & Beverage';
      case BusinessCategory.technology: return 'Technology';
      case BusinessCategory.services: return 'Services';
      case BusinessCategory.health: return 'Health & Fitness';
      case BusinessCategory.education: return 'Education';
      case BusinessCategory.entertainment: return 'Entertainment';
      case BusinessCategory.other: return 'Other';
    }
  }

  BusinessCategory _stringToCategory(String value) {
    switch (value) {
      case 'Retail': return BusinessCategory.retail;
      case 'Food & Beverage': return BusinessCategory.food;
      case 'Technology': return BusinessCategory.technology;
      case 'Services': return BusinessCategory.services;
      case 'Health & Fitness': return BusinessCategory.health;
      case 'Entertainment': return BusinessCategory.entertainment;
      default: return BusinessCategory.other;
    }
  }

  Future<void> _updateBusiness() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedBusiness = widget.business.copyWith(
        name: _nameController.text.trim(),
        description: Nullable(_descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim()),
        email: Nullable(_emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim()),
        phone: Nullable(_phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim()),
        website: Nullable(_websiteController.text.trim().isEmpty
            ? null
            : _websiteController.text.trim()),
        address: Nullable(_addressController.text.trim().isEmpty
            ? null
            : BusinessAddress(street: _addressController.text.trim())),
        category: _stringToCategory(_selectedCategory),
        commercialRegistration: Nullable(_commercialRegController.text.trim().isEmpty
            ? null
            : _commercialRegController.text.trim()),
        taxNumber: Nullable(_taxNumberController.text.trim().isEmpty
            ? null
            : _taxNumberController.text.trim()),
        foundingYear: Nullable(_foundingYearController.text.trim().isEmpty
            ? null
            : int.tryParse(_foundingYearController.text.trim())),
      );

      await ref.read(userBusinessesProvider.notifier).updateBusiness(
        updatedBusiness,
        logoBytes: _selectedLogoBytes,
        coverBytes: _selectedCoverBytes,
        verticalVideo: _selectedVerticalVideo,
        horizontalVideo: _selectedHorizontalVideo,
        imageFiles: _selectedGalleryImages,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Business updated successfully'),
            backgroundColor: context.primaryColor,
          ),
        );
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating business: $e'),
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

  Future<void> _pickLogo() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (image != null && mounted) {
      final bytes = await image.readAsBytes();
      setState(() => _selectedLogoBytes = bytes);
    }
  }

  Future<void> _pickCover() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 600,
      imageQuality: 85,
    );
    if (image != null && mounted) {
      final bytes = await image.readAsBytes();
      setState(() => _selectedCoverBytes = bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: context.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Edit Business',
          style: TextStyle(
            color: context.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updateBusiness,
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.primaryColor,
                    ),
                  )
                : Text(
                    'Save',
                    style: TextStyle(
                      color: context.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
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
              _buildLogoSection(context),
              const SizedBox(height: 24),
              _buildTextField(
                label: 'Business Name',
                controller: _nameController,
                hint: 'Enter your business name',
                prefixIcon: Icons.store_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Business name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Description',
                controller: _descriptionController,
                hint: 'Tell customers about your business',
                prefixIcon: Icons.description_outlined,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              _buildCategoryDropdown(context),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Email',
                controller: _emailController,
                hint: 'business@example.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Phone',
                controller: _phoneController,
                hint: '+1 234 567 8900',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Website',
                controller: _websiteController,
                hint: 'https://yourbusiness.com',
                prefixIcon: Icons.language_outlined,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Address',
                controller: _addressController,
                hint: 'Enter business address',
                prefixIcon: Icons.location_on_outlined,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Founding Year',
                controller: _foundingYearController,
                hint: 'e.g. 2020',
                prefixIcon: Icons.calendar_today_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Commercial Registration',
                controller: _commercialRegController,
                hint: 'Enter Commercial Registration No.',
                prefixIcon: Icons.assignment_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Tax Number',
                controller: _taxNumberController,
                hint: 'Enter Tax Number',
                prefixIcon: Icons.receipt_long_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),
              _buildMediaUploadSection(context),
              const SizedBox(height: 32),
              _buildMissingFieldsSection(context),
              const SizedBox(height: 100),
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
                  : widget.business.coverImageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(widget.business.coverImageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
            ),
            child: _selectedCoverBytes == null && widget.business.coverImageUrl == null
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

  Widget _buildLogoSection(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: _pickLogo,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.dividerColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: context.primaryColor.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
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
              : widget.business.logoUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.network(
                        widget.business.logoUrl!,
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
                          'Logo',
                          style: TextStyle(
                            color: context.hintColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(color: context.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: context.hintColor),
            prefixIcon: maxLines == 1
                ? Icon(prefixIcon, color: context.iconColor)
                : null,
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
              borderSide: BorderSide(color: context.primaryColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaUploadSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Media',
          style: TextStyle(
            color: context.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _buildMediaUploadItem(
          context,
          label: 'Vertical Video',
          icon: Icons.smartphone,
          file: _selectedVerticalVideo,
          existingUrl: widget.business.videoUrl,
          onTap: () async {
            final video = await _picker.pickVideo(source: ImageSource.gallery);
            if (video != null && mounted) {
              setState(() => _selectedVerticalVideo = video);
              _syncProgressToProvider();
            }
          },
        ),
        const SizedBox(height: 12),
        _buildMediaUploadItem(
          context,
          label: 'Horizontal Video',
          icon: Icons.ondemand_video,
          file: _selectedHorizontalVideo,
          existingUrl: widget.business.horizontalVideoUrl,
          onTap: () async {
            final video = await _picker.pickVideo(source: ImageSource.gallery);
            if (video != null && mounted) {
              setState(() => _selectedHorizontalVideo = video);
              _syncProgressToProvider();
            }
          },
        ),
        const SizedBox(height: 12),
        _buildMediaUploadItem(
          context,
          label: 'Gallery Images',
          icon: Icons.photo_library_outlined,
          description: '${_selectedGalleryImages.length + widget.business.galleryImageUrls.length} selected',
          onTap: () async {
            final images = await _picker.pickMultiImage();
            if (images.isNotEmpty && mounted) {
              setState(() {
                _selectedGalleryImages = [..._selectedGalleryImages, ...images];
              });
              _syncProgressToProvider();
            }
          },
        ),
      ],
    );
  }

  Widget _buildMediaUploadItem(
    BuildContext context, {
    required String label,
    required IconData icon,
    XFile? file,
    String? existingUrl,
    String? description,
    required VoidCallback onTap,
  }) {
    final hasContent = file != null || (existingUrl != null && existingUrl.isNotEmpty) || (description != null && description.contains('selected') && !description.startsWith('0'));
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasContent ? context.primaryColor : context.dividerColor,
            width: hasContent ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: hasContent 
                    ? context.primaryColor.withValues(alpha: 0.1)
                    : context.dividerColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: hasContent ? context.primaryColor : context.hintColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: context.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        color: hasContent ? context.primaryColor : context.hintColor,
                        fontSize: 12,
                      ),
                    ),
                  ] else if (hasContent) ...[
                     const SizedBox(height: 2),
                     Text(
                       file != null ? 'File selected' : 'Existing media',
                       style: TextStyle(
                         color: context.primaryColor,
                         fontSize: 12,
                       ),
                     ),
                  ],
                ],
              ),
            ),
            if (hasContent)
              Icon(
                Icons.check_circle,
                color: context.primaryColor,
                size: 20,
              )
            else
              Icon(
                Icons.add,
                color: context.hintColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            color: context.onSurface,
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
              style: TextStyle(color: context.onSurface),
              icon: Icon(Icons.keyboard_arrow_down, color: context.iconColor),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMissingFieldsSection(BuildContext context) {
    final missingFields = widget.business.missingFields;
    if (missingFields.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: Color(0xFFF59E0B),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Complete your profile',
                style: TextStyle(
                  color: context.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: missingFields.take(5).map((field) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: context.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: context.onSurfaceVariant,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      field,
                      style: TextStyle(
                        color: context.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
