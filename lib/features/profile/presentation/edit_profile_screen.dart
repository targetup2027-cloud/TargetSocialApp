import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app/theme/theme_extensions.dart';
import '../application/profile_controller.dart';
import '../domain/entities/user_profile.dart';
import 'package:image_cropper/image_cropper.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  late TextEditingController _websiteController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _nationalIdController;
  late TextEditingController _interestsController;
  bool _isLoading = false;
  bool _initialized = false;
  String? _selectedAvatarPath;
  String? _selectedCoverPath;
  String? _selectedNationalIdImagePath;
  DateTime? _selectedDateOfBirth;
  IdDocumentType? _selectedIdDocumentType;
  final ImagePicker _picker = ImagePicker();
  int _currentPercentage = 0;
  
  late TextEditingController _facebookController;
  late TextEditingController _instagramController;
  late TextEditingController _twitterController;
  late TextEditingController _linkedinController;

  // Regex Validators
  final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final _phoneRegex = RegExp(r'^(\+20|0)?1[0125][0-9]{8}$');
  final _nationalIdRegex = RegExp(r'^\d{14}$');
  final _urlRegex = RegExp(r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w\.-]*)*\/?$');
  final _usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _usernameController = TextEditingController();
    _bioController = TextEditingController();
    _locationController = TextEditingController();
    _websiteController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _nationalIdController = TextEditingController();
    _interestsController = TextEditingController();
    _facebookController = TextEditingController();
    _instagramController = TextEditingController();
    _twitterController = TextEditingController();
    _linkedinController = TextEditingController();

    _displayNameController.addListener(_onFieldChanged);
    _usernameController.addListener(_onFieldChanged);
    _bioController.addListener(_onFieldChanged);
    _locationController.addListener(_onFieldChanged);
    _websiteController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _nationalIdController.addListener(_onFieldChanged);
    _interestsController.addListener(_onFieldChanged);
    _facebookController.addListener(_onFieldChanged);
    _instagramController.addListener(_onFieldChanged);
    _twitterController.addListener(_onFieldChanged);
    _linkedinController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _nationalIdController.dispose();
    _interestsController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    final newPercentage = _calculateDynamicPercentage();
    if (newPercentage != _currentPercentage) {
      setState(() => _currentPercentage = newPercentage);
    }
  }

  int _calculateDynamicPercentage() {
    int score = 0;
    const int maxScore = 105;
    
    final profile = ref.read(profileControllerProvider).valueOrNull;
    
    if (_selectedAvatarPath != null || (profile?.avatarUrl?.isNotEmpty ?? false)) score += 15;
    if (_nationalIdController.text.trim().isNotEmpty) score += 15;
    if (_selectedNationalIdImagePath != null || (profile?.nationalIdImageUrl?.isNotEmpty ?? false)) score += 10;
    if (_selectedIdDocumentType != null) score += 5;
    if (profile?.isNationalIdVerified ?? false) score += 10;
    if (_phoneController.text.trim().isNotEmpty) score += 10;
    if (_emailController.text.trim().isNotEmpty) score += 10;
    if (_bioController.text.trim().isNotEmpty) score += 10;
    if (_selectedCoverPath != null || (profile?.coverImageUrl?.isNotEmpty ?? false)) score += 5;
    if (_locationController.text.trim().isNotEmpty) score += 5;
    if (_websiteController.text.trim().isNotEmpty) score += 5;
    if (_selectedDateOfBirth != null) score += 5;
    if (_interestsController.text.isNotEmpty) score += 5;
    if (_facebookController.text.isNotEmpty || _instagramController.text.isNotEmpty || _twitterController.text.isNotEmpty || _linkedinController.text.isNotEmpty || (profile?.socialLinks?.isNotEmpty ?? false)) score += 5;
    
    return ((score / maxScore) * 100).round().clamp(0, 100);
  }

  void _updateControllers(UserProfile profile) {
    _displayNameController.removeListener(_onFieldChanged);
    _usernameController.removeListener(_onFieldChanged);
    _bioController.removeListener(_onFieldChanged);
    _locationController.removeListener(_onFieldChanged);
    _websiteController.removeListener(_onFieldChanged);
    _phoneController.removeListener(_onFieldChanged);
    _emailController.removeListener(_onFieldChanged);
    _nationalIdController.removeListener(_onFieldChanged);
    _interestsController.removeListener(_onFieldChanged);
    _facebookController.removeListener(_onFieldChanged);
    _instagramController.removeListener(_onFieldChanged);
    _twitterController.removeListener(_onFieldChanged);
    _linkedinController.removeListener(_onFieldChanged);

    _currentPercentage = profile.profileCompletionPercentage;
    _displayNameController.text = profile.displayName;
    _usernameController.text = profile.username;
    _bioController.text = profile.bio ?? '';
    _locationController.text = profile.location ?? '';
    _websiteController.text = profile.website ?? '';
    _phoneController.text = profile.phoneNumber ?? '';
    _emailController.text = profile.email ?? '';
    _nationalIdController.text = profile.nationalId ?? '';
    _interestsController.text = profile.interests.join(', ');
    _selectedDateOfBirth = profile.dateOfBirth;
    _selectedIdDocumentType = profile.idDocumentType;
    
    final socialLinks = profile.socialLinks ?? {};
    _facebookController.text = socialLinks['facebook'] ?? '';
    _instagramController.text = socialLinks['instagram'] ?? '';
    _twitterController.text = socialLinks['twitter'] ?? '';
    _linkedinController.text = socialLinks['linkedin'] ?? '';

    _displayNameController.addListener(_onFieldChanged);
    _usernameController.addListener(_onFieldChanged);
    _bioController.addListener(_onFieldChanged);
    _locationController.addListener(_onFieldChanged);
    _websiteController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _nationalIdController.addListener(_onFieldChanged);
    _interestsController.addListener(_onFieldChanged);
    _facebookController.addListener(_onFieldChanged);
    _instagramController.addListener(_onFieldChanged);
    _twitterController.addListener(_onFieldChanged);
    _linkedinController.addListener(_onFieldChanged);
  }

  void _showImageSourceOptions(Function(ImageSource) onPick) {
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
                color: context.hintColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF8B5CF6)),
              title: Text('Take Photo', style: TextStyle(color: context.onSurface)),
              onTap: () {
                Navigator.pop(context);
                onPick(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF8B5CF6)),
              title: Text('Choose from Gallery', style: TextStyle(color: context.onSurface)),
              onTap: () {
                Navigator.pop(context);
                onPick(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, Function(String) onPicked, {bool isAvatar = false}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null && mounted) {
        final croppedFile = await _cropImage(image.path, isAvatar: isAvatar);
        if (croppedFile != null && mounted) {
          onPicked(croppedFile.path);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image updated! Don\'t forget to save.'),
              backgroundColor: Color(0xFF10B981),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<CroppedFile?> _cropImage(String sourcePath, {required bool isAvatar}) async {
    if (kIsWeb) {
      return CroppedFile(sourcePath);
    }
    return await ImageCropper().cropImage(
      sourcePath: sourcePath,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: isAvatar ? 'Edit Avatar' : 'Edit Image',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          backgroundColor: Colors.black,
          initAspectRatio: isAvatar ? CropAspectRatioPreset.square : CropAspectRatioPreset.original,
          lockAspectRatio: isAvatar,
          activeControlsWidgetColor: const Color(0xFF8B5CF6),
        ),
        IOSUiSettings(
          title: isAvatar ? 'Crop Avatar' : 'Crop Image',
          doneButtonTitle: 'Done',
          cancelButtonTitle: 'Cancel',
          aspectRatioLockEnabled: isAvatar,
          aspectRatioPickerButtonHidden: isAvatar,
          resetAspectRatioEnabled: !isAvatar,
        ),
      ],
    );
  }

  Future<void> _pickProfileImage() async {
    _showImageSourceOptions((source) {
      _pickImage(source, (path) => setState(() => _selectedAvatarPath = path), isAvatar: true);
    });
  }

  Future<void> _pickCoverImage() async {
    _showImageSourceOptions((source) {
      _pickImage(source, (path) => setState(() => _selectedCoverPath = path), isAvatar: false);
    });
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8B5CF6),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  Future<void> _pickNationalIdImage() async {
    _showImageSourceOptions((source) {
      _pickImage(source, (path) => setState(() => _selectedNationalIdImagePath = path));
    });
  }


  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please correct the invalid fields highlighted in red'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final controller = ref.read(profileControllerProvider.notifier);
      final currentProfile = ref.read(profileControllerProvider).valueOrNull;
      final wasVerified = currentProfile?.isVerified ?? false;

      final interests = _interestsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toSet()
          .toList();

      final socialLinks = <String, String>{};
      if (_facebookController.text.trim().isNotEmpty) socialLinks['facebook'] = _facebookController.text.trim();
      if (_instagramController.text.trim().isNotEmpty) socialLinks['instagram'] = _instagramController.text.trim();
      if (_twitterController.text.trim().isNotEmpty) socialLinks['twitter'] = _twitterController.text.trim();
      if (_linkedinController.text.trim().isNotEmpty) socialLinks['linkedin'] = _linkedinController.text.trim();

      final willBeComplete = _calculateDynamicPercentage() >= 100;
      final shouldVerify = willBeComplete && !wasVerified;

      await controller.updateProfile(
        displayName: _displayNameController.text.trim(),
        username: _usernameController.text.trim(),
        bio: Nullable(_bioController.text.trim().isEmpty ? null : _bioController.text.trim()),
        location: Nullable(_locationController.text.trim().isEmpty ? null : _locationController.text.trim()),
        website: Nullable(_websiteController.text.trim().isEmpty ? null : _websiteController.text.trim()),
        phoneNumber: Nullable(_phoneController.text.trim().isEmpty ? null : _phoneController.text.trim()),
        email: Nullable(_emailController.text.trim().isEmpty ? null : _emailController.text.trim()),
        nationalId: Nullable(_nationalIdController.text.trim().isEmpty ? null : _nationalIdController.text.trim()),
        dateOfBirth: Nullable(_selectedDateOfBirth),
        interests: interests,
        socialLinks: Nullable(socialLinks.isEmpty ? null : socialLinks),
        isVerified: shouldVerify ? true : null,
      );

      if (_selectedAvatarPath != null) {
        await controller.updateAvatar(_selectedAvatarPath!);
      }

      if (_selectedCoverPath != null) {
        await controller.updateCoverImage(_selectedCoverPath!);
      }

      if (_selectedNationalIdImagePath != null) {
        await controller.updateNationalIdImage(_selectedNationalIdImagePath!);
      }

      if (_selectedIdDocumentType != null) {
        await controller.updateIdDocumentType(_selectedIdDocumentType!);
      }

      if (mounted) {
        if (shouldVerify) {
          await _showVerificationCongratulationsDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        }
        if (mounted) context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showVerificationCongratulationsDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: context.isDarkMode 
                  ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                  : [Colors.white, const Color(0xFFF9FAFB)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.verified,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '🎉 Congratulations! 🎉',
                style: TextStyle(
                  color: context.onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You\'ve earned free verification\nby completing your profile!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.onSurface.withValues(alpha: 0.8),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.verified, color: Color(0xFF10B981), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Account Verified',
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Awesome!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<UserProfile>>(profileControllerProvider, (previous, next) {
      if (next is AsyncData && next.value != null && !_initialized) {
        _updateControllers(next.value!);
        _initialized = true;
      }
    });

    final profileAsync = ref.watch(profileControllerProvider);
    final displayPercentage = _initialized 
        ? _currentPercentage 
        : (profileAsync.valueOrNull?.profileCompletionPercentage ?? 0);

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Profile',
              style: TextStyle(
                color: context.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: displayPercentage / 100,
                      backgroundColor: context.dividerColor.withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        displayPercentage >= 70 ? const Color(0xFF10B981) : const Color(0xFF8B5CF6),
                      ),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$displayPercentage%',
                  style: TextStyle(
                    color: displayPercentage >= 70 ? const Color(0xFF10B981) : const Color(0xFF8B5CF6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _isLoading ? null : _saveProfile,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  gradient: !_isLoading
                      ? const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                        )
                      : null,
                  color: _isLoading ? context.dividerColor : null,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          if (!_initialized) {
            _updateControllers(profile);
            _initialized = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
               _onFieldChanged(); // Calculate initial percentage
            });
          }
          return _buildForm(profile);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e', style: TextStyle(color: context.onSurface))),
      ),
    );
  }

  Widget _buildForm(UserProfile profile) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(profile),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildSectionLabel('Basic Information'),
                  _buildSectionContainer(
                    children: [
                      _buildTextField(
                        label: 'Display Name',
                        controller: _displayNameController,
                        hintText: 'e.g. John Doe, محمد أحمد',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Display name is required';
                          }
                          if (value.trim().length < 2) {
                            return 'Display name must be at least 2 characters';
                          }
                          if (value.trim().length > 50) {
                            return 'Display name must be less than 50 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Username',
                        controller: _usernameController,
                        prefix: '@',
                        hintText: 'username',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Username is required';
                          }
                          if (!_usernameRegex.hasMatch(value.trim())) {
                            return 'Username can only contain letters, numbers, and underscores';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Bio',
                        controller: _bioController,
                        maxLines: 3,
                        maxLength: 150,
                        hintText: 'Tell us a bit about yourself...',
                      ),
                      const SizedBox(height: 16),
                      _buildDatePicker(),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Location',
                        controller: _locationController,
                        prefixIcon: Icons.location_on_outlined,
                        hintText: 'City, Country',
                      ),
                       const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Interests',
                        controller: _interestsController,
                        prefixIcon: Icons.star_outline,
                        hintText: 'Coding, Design, Travel... (comma separated)',
                      ),
                    ],
                  ),

                  _buildSectionLabel('Contact Details'),
                  _buildSectionContainer(
                    children: [
                       _buildTextField(
                        label: 'Phone Number',
                        controller: _phoneController,
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        hintText: '+20...',
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            if (!_phoneRegex.hasMatch(value.trim())) {
                              return 'Invalid phone number';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Email Address',
                        controller: _emailController,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        hintText: 'you@example.com',
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            if (!_emailRegex.hasMatch(value.trim())) {
                              return 'Invalid email address';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Website',
                        controller: _websiteController,
                        prefixIcon: Icons.link,
                        keyboardType: TextInputType.url,
                        hintText: 'https://yourwebsite.com',
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            if (!_urlRegex.hasMatch(value.trim())) {
                              return 'Invalid URL';
                            }
                          }
                          return null;
                        },
                      ),
                    ],
                  ),

                  _buildSectionLabel('Identity Verification'),
                  _buildSectionContainer(
                    children: [
                      _buildDropdownField(),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: _selectedIdDocumentType?.label ?? 'ID Number',
                        controller: _nationalIdController,
                        prefixIcon: _selectedIdDocumentType?.icon ?? Icons.badge_outlined,
                        keyboardType: TextInputType.text,
                        hintText: 'Enter your ${_selectedIdDocumentType?.label ?? "ID"} number',
                        maxLength: _selectedIdDocumentType == IdDocumentType.nationalId ? 14 : null,
                        validator: (value) {
                          if (_selectedIdDocumentType == IdDocumentType.nationalId && value != null && value.trim().isNotEmpty) {
                            if (!_nationalIdRegex.hasMatch(value.trim())) {
                              return 'National ID must be exactly 14 digits';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildNationalIdImagePicker(profile),
                      const SizedBox(height: 12),
                       Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lock_outline, size: 14, color: context.hintColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Your National ID and details are encrypted and securely stored. We only use this for verification purposes.',
                              style: TextStyle(
                                color: context.hintColor,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  _buildSectionLabel('Social Profiles'),
                  _buildSectionContainer(
                    children: [
                      _buildTextField(
                        label: 'Facebook',
                        controller: _facebookController,
                        prefixIcon: Icons.facebook,
                        hintText: 'facebook.com/username',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Instagram',
                        controller: _instagramController,
                        prefixIcon: Icons.camera_alt_outlined,
                        hintText: 'instagram.com/username',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Twitter / X',
                        controller: _twitterController,
                        prefixIcon: Icons.alternate_email,
                        hintText: 'twitter.com/username',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'LinkedIn',
                        controller: _linkedinController,
                        prefixIcon: Icons.work_outline,
                        hintText: 'linkedin.com/in/username',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 32, 4, 12),
      child: Text(
        title,
        style: TextStyle(
          color: context.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSectionContainer({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.dividerColor.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildHeaderSection(UserProfile profile) {
    return Stack(
      children: [
        GestureDetector(
          onTap: _pickCoverImage,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF3F4F6),
              image: _selectedCoverPath != null
                  ? DecorationImage(
                      image: kIsWeb 
                          ? NetworkImage(_selectedCoverPath!) 
                          : FileImage(File(_selectedCoverPath!)) as ImageProvider,
                      fit: BoxFit.cover,
                    )
                  : profile.coverImageUrl != null
                      ? DecorationImage(
                          image: profile.coverImageUrl!.startsWith('http')
                              ? NetworkImage(profile.coverImageUrl!) as ImageProvider
                              : FileImage(File(profile.coverImageUrl!)),
                          fit: BoxFit.cover,
                        )
                      : null,
            ),
            child: _selectedCoverPath == null && profile.coverImageUrl == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, color: context.hintColor.withValues(alpha: 0.7), size: 32),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to add cover photo',
                          style: TextStyle(color: context.hintColor.withValues(alpha: 0.7), fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                    alignment: Alignment.bottomRight,
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 16),
                    ),
                  ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 130),
          alignment: Alignment.center,
          child: Stack(
            children: [
               Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: context.scaffoldBg, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: context.isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0),
                  backgroundImage: _selectedAvatarPath != null
                      ? (kIsWeb 
                          ? NetworkImage(_selectedAvatarPath!) 
                          : FileImage(File(_selectedAvatarPath!)) as ImageProvider)
                      : (profile.avatarUrl != null
                          ? (profile.avatarUrl!.startsWith('http')
                              ? NetworkImage(profile.avatarUrl!) as ImageProvider
                              : FileImage(File(profile.avatarUrl!)))
                          : null),
                  child: _selectedAvatarPath == null && profile.avatarUrl == null
                      ? Icon(Icons.person, color: context.iconColor, size: 40)
                      : null,
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: GestureDetector(
                  onTap: _pickProfileImage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF8B5CF6), // Primary Color
                      shape: BoxShape.circle,
                      boxShadow: [
                         BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date of Birth',
          style: TextStyle(
            color: context.onSurface.withValues(alpha: 0.7),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDateOfBirth,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: context.scaffoldBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.dividerColor),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, color: context.hintColor, size: 20),
                const SizedBox(width: 12),
                Text(
                  _selectedDateOfBirth != null
                      ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                      : 'DD/MM/YYYY',
                  style: TextStyle(
                    color: _selectedDateOfBirth != null
                        ? context.onSurface
                        : context.hintColor,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                Icon(Icons.chevron_right, color: context.hintColor, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

   Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ID Document Type',
          style: TextStyle(
            color: context.onSurface.withValues(alpha: 0.7),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: context.scaffoldBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.dividerColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<IdDocumentType>(
              value: _selectedIdDocumentType,
              isExpanded: true,
              hint: Text(
                'Select ID type',
                style: TextStyle(color: context.hintColor, fontSize: 15),
              ),
              dropdownColor: context.cardColor,
              icon: Icon(Icons.keyboard_arrow_down, color: context.hintColor),
              items: IdDocumentType.values.map((type) => DropdownMenuItem(
                value: type,
                child: Row(
                  children: [
                    Icon(type.icon, color: const Color(0xFF8B5CF6), size: 20),
                    const SizedBox(width: 12),
                    Text(
                      type.label,
                      style: TextStyle(color: context.onSurface, fontSize: 15),
                    ),
                  ],
                ),
              )).toList(),
              onChanged: (value) => setState(() => _selectedIdDocumentType = value),
            ),
          ),
        ),
      ],
    );
  }

   Widget _buildNationalIdImagePicker(UserProfile profile) {
     return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'National ID Document',
          style: TextStyle(
            color: context.onSurface.withValues(alpha: 0.7),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickNationalIdImage,
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.scaffoldBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.dividerColor, style: BorderStyle.values[1]), // Simple solid border
              image: _selectedNationalIdImagePath != null
                  ? DecorationImage(
                      image: FileImage(File(_selectedNationalIdImagePath!)),
                      fit: BoxFit.cover,
                    )
                  : profile.nationalIdImageUrl != null
                      ? DecorationImage(
                          image: profile.nationalIdImageUrl!.startsWith('http')
                              ? NetworkImage(profile.nationalIdImageUrl!) as ImageProvider
                              : FileImage(File(profile.nationalIdImageUrl!)),
                          fit: BoxFit.cover,
                        )
                      : null,
            ),
             child: _selectedNationalIdImagePath == null && profile.nationalIdImageUrl == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.dividerColor.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.file_upload_outlined, color: context.iconColor, size: 24),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Upload Document',
                        style: TextStyle(
                          color: context.onSurface,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'JPG, PNG or PDF',
                        style: TextStyle(
                          color: context.hintColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )
                : null,
          ),
        ),
      ],
     );
   }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? prefix,
    IconData? prefixIcon,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.onSurface.withValues(alpha: 0.7),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: TextStyle(color: context.onSurface, fontSize: 15),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: context.hintColor.withValues(alpha: 0.6), fontSize: 14),
            prefixText: prefix,
            prefixStyle: TextStyle(color: context.onSurface, fontSize: 15, fontWeight: FontWeight.w500),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: context.hintColor, size: 20)
                : null,
            filled: true,
            fillColor: context.scaffoldBg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            errorStyle: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w500),
            errorMaxLines: 2,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
             enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
            ),
            focusedErrorBorder: OutlineInputBorder(
               borderRadius: BorderRadius.circular(12),
               borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

