import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../shared/widgets/enhanced_neon_effects.dart';
import '../../../../shared/widgets/neon_text.dart';
import '../providers/edit_profile_provider.dart';
import '../../providers/profile_provider.dart';
import '../widgets/profile_image_picker.dart';
import '../widgets/profile_form_field.dart';
import '../widgets/auto_save_indicator.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  
  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _bioController;
  
  // State
  DateTime? _selectedBirthDate;
  XFile? _selectedImage;
  bool _hasUnsavedChanges = false;
  Timer? _autoSaveTimer;
  
  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeControllers();
    _startAutoSave();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  void _initializeControllers() {
    final user = ref.read(currentUserProvider).value;
    
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _selectedBirthDate = user?.birthDate;
    
    // Add listeners to detect changes
    _nameController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _addressController.addListener(_onFieldChanged);
    _bioController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  void _startAutoSave() {
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_hasUnsavedChanges && _formKey.currentState?.validate() == true) {
        _autoSave();
      }
    });
  }

  Future<void> _autoSave() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    try {
      await ref.read(editProfileProvider.notifier).autoSaveProfile(
        userId: user.id,
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
        bio: _bioController.text.trim().isNotEmpty ? _bioController.text.trim() : null,
        birthDate: _selectedBirthDate,
      );
      
      setState(() {
        _hasUnsavedChanges = false;
      });
    } catch (e) {
      // Silent auto-save failure - don't disturb user
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;
    final editState = ref.watch(editProfileProvider);

    if (user == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.darkBackground, Color(0xFF1A1A1A)],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.neonPink),
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1A1A1A),
                  Color(0xFF0F0F0F),
                  AppColors.darkBackground,
                ],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildContent(user, editState),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(dynamic user, EditProfileState editState) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        _buildSliverAppBar(),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildProfileImageSection(user, editState),
                    const SizedBox(height: 8),
                    const AutoSaveStatus(),
                    const SizedBox(height: 24),
                    _buildPersonalInfoCard(),
                    const SizedBox(height: 20),
                    _buildContactInfoCard(),
                    const SizedBox(height: 20),
                    _buildBioCard(),
                    const SizedBox(height: 24),
                    _buildActionButtons(editState),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
        onPressed: () => _handleBackPress(),
      ),
      title: NeonText(
        text: 'עריכת פרופיל',
        fontSize: 20,
        glowColor: AppColors.neonTurquoise,
        fontWeight: FontWeight.bold,
        isSubtle: true,
      ),
      actions: [
        if (_hasUnsavedChanges)
          Container(
            margin: const EdgeInsets.only(left: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.warning.withOpacity(0.5),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'לא שמור',
                      style: GoogleFonts.assistant(
                        color: AppColors.warning,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileImageSection(dynamic user, EditProfileState editState) {
    return NeonGlowContainer(
      glowColor: AppColors.neonPink,
      glowRadius: 15,
      opacity: 0.2,
      isSubtle: true,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.authCardBackground.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.neonPink.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: Column(
          children: [
            NeonText(
              text: 'תמונת פרופיל',
              fontSize: 18,
              glowColor: AppColors.neonPink,
              fontWeight: FontWeight.w600,
              isSubtle: true,
            ),
            const SizedBox(height: 20),
            ProfileImagePicker(
              currentImageUrl: user.profileImageUrl,
              isLoading: editState.isImageUploading,
              onImageSelected: (image) {
                setState(() {
                  _selectedImage = image;
                  _hasUnsavedChanges = true;
                });
              },
              onImageRemoved: () {
                setState(() {
                  _selectedImage = null;
                  _hasUnsavedChanges = true;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker(dynamic user, EditProfileState editState) {
    return GestureDetector(
      onTap: editState.isImageUploading ? null : _pickImage,
      child: Stack(
        children: [
          NeonGlowContainer(
            glowColor: AppColors.neonPink,
            animate: editState.isImageUploading,
            glowRadius: 20,
            opacity: 0.3,
            isSubtle: true,
            borderRadius: BorderRadius.circular(80),
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.neonPink.withOpacity(0.5),
                  width: 2,
                ),
                gradient: RadialGradient(
                  colors: [
                    AppColors.neonPink.withOpacity(0.1),
                    AppColors.neonTurquoise.withOpacity(0.1),
                  ],
                ),
              ),
              child: ClipOval(
                child: _getImageWidget(user),
              ),
            ),
          ),
          if (editState.isImageUploading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.7),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: AppColors.neonPink,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'מעלה תמונה...',
                      style: GoogleFonts.assistant(
                        color: AppColors.primaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 10,
            left: 10,
            child: NeonGlowContainer(
              glowColor: AppColors.neonTurquoise,
              glowRadius: 12,
              opacity: 0.4,
              isSubtle: true,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.neonTurquoise.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 20,
                  color: AppColors.neonTurquoise,
                ),
              ),
            ),
          ),
          if (_selectedImage != null || user.profileImageUrl != null)
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: _clearImage,
                child: NeonGlowContainer(
                  glowColor: AppColors.error,
                  glowRadius: 10,
                  opacity: 0.4,
                  isSubtle: true,
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.error.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _getImageWidget(dynamic user) {
    if (_selectedImage != null) {
      return Image.file(
        File(_selectedImage!.path),
        fit: BoxFit.cover,
        width: 160,
        height: 160,
      );
    } else if (user.profileImageUrl != null) {
      return Image.network(
        user.profileImageUrl!,
        fit: BoxFit.cover,
        width: 160,
        height: 160,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar(user);
        },
      );
    } else {
      return _buildDefaultAvatar(user);
    }
  }

  Widget _buildDefaultAvatar(dynamic user) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.neonPink.withOpacity(0.3),
            AppColors.neonTurquoise.withOpacity(0.3),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              size: 60,
              color: AppColors.primaryText.withOpacity(0.7),
            ),
            const SizedBox(height: 8),
            Text(
              'הוספת תמונה',
              style: GoogleFonts.assistant(
                color: AppColors.primaryText.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return NeonGlowContainer(
      glowColor: AppColors.neonTurquoise,
      glowRadius: 12,
      opacity: 0.15,
      isSubtle: true,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.authCardBackground.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.neonTurquoise.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: AppColors.neonTurquoise.withOpacity(0.8),
                  size: 20,
                ),
                const SizedBox(width: 8),
                NeonText(
                  text: 'פרטים אישיים',
                  fontSize: 18,
                  glowColor: AppColors.neonTurquoise,
                  fontWeight: FontWeight.w600,
                  isSubtle: true,
                ),
              ],
            ),
            const SizedBox(height: 20),
            NameFormField(
              controller: _nameController,
              onChanged: (_) => _onFieldChanged(),
            ),
            const SizedBox(height: 16),
            EmailDisplayField(email: user?.email ?? ''),
            const SizedBox(height: 16),
            DatePickerField(
              label: 'תאריך לידה',
              icon: Icons.cake_outlined,
              selectedDate: _selectedBirthDate,
              onDateSelected: (date) {
                setState(() {
                  _selectedBirthDate = date;
                  _hasUnsavedChanges = true;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoCard() {
    return NeonGlowContainer(
      glowColor: AppColors.neonPink,
      glowRadius: 12,
      opacity: 0.15,
      isSubtle: true,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.authCardBackground.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.neonPink.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.contact_phone,
                  color: AppColors.neonPink.withOpacity(0.8),
                  size: 20,
                ),
                const SizedBox(width: 8),
                NeonText(
                  text: 'פרטי קשר',
                  fontSize: 18,
                  glowColor: AppColors.neonPink,
                  fontWeight: FontWeight.w600,
                  isSubtle: true,
                ),
              ],
            ),
            const SizedBox(height: 20),
            PhoneFormField(
              controller: _phoneController,
              onChanged: (_) => _onFieldChanged(),
            ),
            const SizedBox(height: 16),
            AddressFormField(
              controller: _addressController,
              onChanged: (_) => _onFieldChanged(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBioCard() {
    return NeonGlowContainer(
      glowColor: AppColors.neonPurple,
      glowRadius: 12,
      opacity: 0.15,
      isSubtle: true,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.authCardBackground.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.neonPurple.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.edit_note,
                  color: AppColors.neonPurple.withOpacity(0.8),
                  size: 20,
                ),
                const SizedBox(width: 8),
                NeonText(
                  text: 'ביוגרפיה',
                  fontSize: 18,
                  glowColor: AppColors.neonPurple,
                  fontWeight: FontWeight.w600,
                  isSubtle: true,
                ),
              ],
            ),
            const SizedBox(height: 20),
            BioFormField(
              controller: _bioController,
              onChanged: (_) => _onFieldChanged(),
            ),
          ],
        ),
      ),
    );
  }




  Widget _buildActionButtons(EditProfileState editState) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: NeonButton(
            text: editState.isSaving ? 'שומר...' : 'שמירת שינויים',
            onPressed: editState.isSaving ? null : _handleSave,
            glowColor: AppColors.neonTurquoise,
            fontSize: 16,
            padding: const EdgeInsets.symmetric(vertical: 16),
            isSubtle: true,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: editState.isSaving ? null : _handleCancel,
            child: Text(
              'ביטול',
              style: GoogleFonts.assistant(
                color: AppColors.secondaryText,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Event handlers


  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      _showMessage('אנא תקנו את השגיאות בטופס', isError: true);
      return;
    }

    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    final success = await ref.read(editProfileProvider.notifier).saveProfile(
      userId: user.id,
      fullName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
      address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
      bio: _bioController.text.trim().isNotEmpty ? _bioController.text.trim() : null,
      birthDate: _selectedBirthDate,
      imageFile: _selectedImage,
    );

    if (success && mounted) {
      setState(() {
        _hasUnsavedChanges = false;
      });
      _showMessage('הפרופיל עודכן בהצלחה');
      Navigator.of(context).pop(true);
    } else if (mounted) {
      final error = ref.read(editProfileProvider).error;
      _showMessage(error ?? 'שגיאה בעדכון הפרופיל', isError: true);
    }
  }

  void _handleCancel() {
    if (_hasUnsavedChanges) {
      _showUnsavedChangesDialog();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _handleBackPress() {
    if (_hasUnsavedChanges) {
      _showUnsavedChangesDialog();
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<bool> _onWillPop() async {
    if (_hasUnsavedChanges) {
      _showUnsavedChangesDialog();
      return false;
    }
    return true;
  }

  void _showUnsavedChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.authCardBackground,
          title: Text(
            'שינויים לא שמורים',
            style: GoogleFonts.assistant(
              color: AppColors.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'יש לך שינויים שלא נשמרו. האם אתה בטוח שברצונך לצאת?',
            style: GoogleFonts.assistant(
              color: AppColors.secondaryText,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'ביטול',
                style: GoogleFonts.assistant(
                  color: AppColors.secondaryText,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _hasUnsavedChanges = false;
                });
                Navigator.of(context).pop();
              },
              child: Text(
                'יציאה ללא שמירה',
                style: GoogleFonts.assistant(
                  color: AppColors.error,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.assistant(
            color: AppColors.primaryText,
            fontSize: 14,
          ),
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: Duration(seconds: isError ? 4 : 3),
      ),
    );
  }
}