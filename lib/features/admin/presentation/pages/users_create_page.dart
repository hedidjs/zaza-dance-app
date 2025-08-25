import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/admin_providers.dart';
import '../../../../shared/widgets/enhanced_neon_effects.dart';
import '../../../../shared/widgets/neon_text.dart';

class UsersCreatePage extends ConsumerStatefulWidget {
  const UsersCreatePage({super.key});

  @override
  ConsumerState<UsersCreatePage> createState() => _UsersCreatePageState();
}

class _UsersCreatePageState extends ConsumerState<UsersCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedRole = 'student';

  @override
  void dispose() {
    _emailController.dispose();
    _displayNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final createUserState = ref.watch(createUserProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.backgroundGradient,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: _buildForm(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonPink.withValues(alpha: 0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go('/admin/dashboard'),
            icon: const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.primaryText,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: NeonText(
              text: 'יצירת משתמש חדש',
              fontSize: 24,
              glowColor: AppColors.neonPink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFormCard(),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return NeonGlowContainer(
      glowColor: AppColors.neonTurquoise,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              AppColors.darkSurface.withValues(alpha: 0.8),
              AppColors.darkSurface.withValues(alpha: 0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: AppColors.neonTurquoise.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NeonText(
              text: 'פרטי המשתמש',
              fontSize: 20,
              glowColor: AppColors.neonTurquoise,
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _displayNameController,
              label: 'שם מלא',
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'שם מלא הוא שדה חובה';
                }
                if (value.trim().length < 2) {
                  return 'שם מלא חייב להכיל לפחות 2 תווים';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
              label: 'כתובת אימייל',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'כתובת אימייל היא שדה חובה';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                  return 'כתובת האימייל אינה תקינה';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _phoneController,
              label: 'מספר טלפון (אופציונלי)',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  if (!RegExp(r'^[\d\-\+\s\(\)]+$').hasMatch(value.trim())) {
                    return 'מספר טלפון אינו תקין';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildRoleSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.assistant(
            color: AppColors.primaryText,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.assistant(
            color: AppColors.primaryText,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: AppColors.neonTurquoise,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.neonTurquoise.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.neonTurquoise.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.neonTurquoise,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: AppColors.darkSurface.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'תפקיד במערכת',
          style: GoogleFonts.assistant(
            color: AppColors.primaryText,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.neonTurquoise.withValues(alpha: 0.3),
            ),
            color: AppColors.darkSurface.withValues(alpha: 0.3),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedRole,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedRole = newValue;
                });
              }
            },
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.admin_panel_settings,
                color: AppColors.neonTurquoise,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            style: GoogleFonts.assistant(
              color: AppColors.primaryText,
              fontSize: 16,
            ),
            dropdownColor: AppColors.darkSurface,
            items: const [
              DropdownMenuItem(value: 'student', child: Text('תלמיד/ה')),
              DropdownMenuItem(value: 'parent', child: Text('הורה')),
              DropdownMenuItem(value: 'instructor', child: Text('מדריך/ה')),
              DropdownMenuItem(value: 'admin', child: Text('מנהל/ת')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final createUserState = ref.watch(createUserProvider);
    
    return Row(
      children: [
        Expanded(
          child: NeonButton(
            text: 'ביטול',
            onPressed: () => context.go('/admin/dashboard'),
            glowColor: AppColors.secondaryText,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: createUserState.when(
            data: (_) => NeonButton(
              text: 'יצירת משתמש',
              onPressed: _createUser,
              glowColor: AppColors.neonPink,
              fontSize: 16,
            ),
            loading: () => NeonButton(
              text: 'יוצר...',
              onPressed: null,
              glowColor: AppColors.neonPink,
              fontSize: 16,
            ),
            error: (_, __) => NeonButton(
              text: 'נסה שוב',
              onPressed: _createUser,
              glowColor: AppColors.error,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Use the actual admin provider to create the user
      await ref.read(createUserProvider.notifier).createUser(
        email: _emailController.text.trim(),
        displayName: _displayNameController.text.trim(),
        role: _selectedRole,
      );

      // Check for success
      final createUserState = ref.read(createUserProvider);
      
      if (createUserState.hasError) {
        throw Exception(createUserState.error.toString());
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'המשתמש "${_displayNameController.text.trim()}" נוצר בהצלחה',
              style: GoogleFonts.assistant(color: AppColors.primaryText),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // Navigate back to dashboard
      if (mounted) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            context.go('/admin/dashboard');
          }
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'שגיאה ביצירת המשתמש: $error',
              style: GoogleFonts.assistant(color: AppColors.primaryText),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}