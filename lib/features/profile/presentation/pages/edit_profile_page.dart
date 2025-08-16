import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../shared/widgets/enhanced_neon_effects.dart';
import '../../../../shared/widgets/neon_text.dart';

/// עמוד עריכת פרופיל משתמש
class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _bioController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user != null) {
      _nameController.text = user.fullName ?? '';
      _phoneController.text = user.phoneNumber ?? '';
      _addressController.text = user.address ?? '';
      _bioController.text = user.bio ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: NeonText(
            text: 'עריכת פרופיל',
            fontSize: 20,
            glowColor: AppColors.neonTurquoise,
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.primaryText,
            ),
            onPressed: () => context.pop(),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.backgroundGradient,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: currentUser.when(
              data: (user) => _buildContent(user),
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.neonTurquoise,
                ),
              ),
              error: (error, stack) => Center(
                child: Text(
                  'שגיאה בטעינת הנתונים',
                  style: GoogleFonts.assistant(
                    color: AppColors.error,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(dynamic user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileImageSection(user),
            const SizedBox(height: 30),
            _buildFormFields(user),
            const SizedBox(height: 40),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImageSection(dynamic user) {
    return Center(
      child: NeonGlowContainer(
        glowColor: AppColors.neonTurquoise,
        animate: true,
        child: CircleAvatar(
          radius: 60,
          backgroundColor: AppColors.darkSurface,
          backgroundImage: user?.profileImageUrl != null
              ? NetworkImage(user!.profileImageUrl!)
              : null,
          child: user?.profileImageUrl == null
              ? Icon(
                  Icons.person,
                  size: 60,
                  color: AppColors.neonTurquoise,
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildFormFields(dynamic user) {
    return Column(
      children: [
        _buildFormField(
          label: 'שם מלא',
          controller: _nameController,
          icon: Icons.person,
          validator: (value) {
            if (value?.trim().isEmpty ?? true) {
              return 'שם מלא הוא שדה חובה';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildFormField(
          label: 'אימייל',
          controller: TextEditingController(text: user?.email ?? ''),
          icon: Icons.email,
          enabled: false,
        ),
        const SizedBox(height: 20),
        _buildFormField(
          label: 'טלפון',
          controller: _phoneController,
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 20),
        _buildFormField(
          label: 'כתובת',
          controller: _addressController,
          icon: Icons.location_on,
        ),
        const SizedBox(height: 20),
        _buildFormField(
          label: 'קצת עליי',
          controller: _bioController,
          icon: Icons.info,
          maxLines: 3,
          maxLength: 500,
        ),
      ],
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool enabled = true,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.cardGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.neonTurquoise.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        enabled: enabled,
        maxLines: maxLines,
        maxLength: maxLength,
        style: GoogleFonts.assistant(
          color: enabled ? AppColors.primaryText : AppColors.secondaryText,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.assistant(
            color: AppColors.secondaryText,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: AppColors.neonTurquoise.withOpacity(0.7),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          counterStyle: GoogleFonts.assistant(
            color: AppColors.secondaryText,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: NeonButton(
            text: _isLoading ? 'שומר...' : 'שמור שינויים',
            onPressed: _isLoading ? null : _saveProfile,
            glowColor: AppColors.neonTurquoise,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: NeonButton(
            text: 'ביטול',
            onPressed: () => context.pop(),
            glowColor: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement actual save logic with ProfileService
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'הפרופיל נשמר בהצלחה',
              style: GoogleFonts.assistant(color: AppColors.primaryText),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        context.pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'שגיאה בשמירת הפרופיל',
              style: GoogleFonts.assistant(color: AppColors.primaryText),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}