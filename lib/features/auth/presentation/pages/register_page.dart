import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../shared/widgets/neon_text.dart';
import '../../../../shared/widgets/enhanced_neon_effects.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String _selectedRole = AppConstants.roleStudent;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await ref.read(currentUserProvider.notifier).register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        role: _selectedRole,
      );

      if (mounted) {
        if (result.isSuccess) {
          _showMessage(result.message);
          Navigator.of(context).pop(); // Go back to login
        } else {
          _showErrorMessage(result.message);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: AppColors.primaryText,
            fontFamily: GoogleFonts.assistant().fontFamily,
          ),
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorMessage(String message) => _showMessage(message, isError: true);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.primaryText),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildRegisterForm(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Subtle animated icon with elegant glow
        NeonGlowContainer(
          glowColor: AppColors.neonTurquoise,
          animate: true,
          glowRadius: 10.0,
          opacity: 0.25,
          isSubtle: true,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.neonTurquoise.withOpacity(0.15),
                  AppColors.neonTurquoise.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
            ),
            child: Icon(
              Icons.person_add,
              size: 50,
              color: AppColors.neonTurquoise.withOpacity(0.9),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Refined title with subtle glow
        NeonText(
          text: 'הצטרפו אלינו',
          fontSize: 28,
          glowColor: AppColors.neonTurquoise,
          fontWeight: FontWeight.w600,
          isSubtle: true,
        ),
        const SizedBox(height: 10),
        // Clean subtitle without effects
        Text(
          'צרו חשבון חדש ובואו להיות חלק מקהילת הריקוד שלנו',
          style: GoogleFonts.assistant(
            fontSize: 14,
            color: AppColors.secondaryText,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return NeonGlowContainer(
      glowColor: AppColors.neonPink,
      glowRadius: 10,
      opacity: 0.15,
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
          // Subtle backdrop blur effect
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildFullNameField(),
              const SizedBox(height: 16),
              _buildEmailField(),
              const SizedBox(height: 16),
              _buildPhoneField(),
              const SizedBox(height: 16),
              _buildAddressField(),
              const SizedBox(height: 16),
              _buildRoleSelector(),
              const SizedBox(height: 16),
              _buildPasswordField(),
              const SizedBox(height: 16),
              _buildConfirmPasswordField(),
              const SizedBox(height: 30),
              _buildRegisterButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullNameField() {
    return TextFormField(
      controller: _fullNameController,
      style: GoogleFonts.assistant(color: AppColors.primaryText),
      decoration: InputDecoration(
        labelText: 'שם מלא *',
        labelStyle: GoogleFonts.assistant(color: AppColors.secondaryText),
        prefixIcon: Icon(Icons.person, color: AppColors.neonTurquoise.withOpacity(0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputFocusedBorder, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputErrorBorder),
        ),
        filled: true,
        fillColor: AppColors.darkSurface,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'אנא הזינו את השם המלא';
        }
        if (value.trim().length < 2) {
          return 'השם חייב להכיל לפחות 2 תווים';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: GoogleFonts.assistant(color: AppColors.primaryText),
      decoration: InputDecoration(
        labelText: 'כתובת אימייל *',
        labelStyle: GoogleFonts.assistant(color: AppColors.secondaryText),
        prefixIcon: Icon(Icons.email, color: AppColors.neonTurquoise.withOpacity(0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputFocusedBorder, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputErrorBorder),
        ),
        filled: true,
        fillColor: AppColors.darkSurface,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'אנא הזינו כתובת אימייל';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
          return 'כתובת אימייל לא תקינה';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      style: GoogleFonts.assistant(color: AppColors.primaryText),
      decoration: InputDecoration(
        labelText: 'מספר טלפון *',
        labelStyle: GoogleFonts.assistant(color: AppColors.secondaryText),
        prefixIcon: Icon(Icons.phone, color: AppColors.neonTurquoise.withOpacity(0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputFocusedBorder, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputErrorBorder),
        ),
        filled: true,
        fillColor: AppColors.darkSurface,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'אנא הזינו מספר טלפון';
        }
        if (!RegExp(r'^[0-9\-\+\s\(\)]+$').hasMatch(value.trim())) {
          return 'מספר טלפון לא תקין';
        }
        return null;
      },
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      controller: _addressController,
      style: GoogleFonts.assistant(color: AppColors.primaryText),
      decoration: InputDecoration(
        labelText: 'כתובת (אופציונלי)',
        labelStyle: GoogleFonts.assistant(color: AppColors.secondaryText),
        prefixIcon: Icon(Icons.location_on, color: AppColors.neonTurquoise.withOpacity(0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputFocusedBorder, width: 2),
        ),
        filled: true,
        fillColor: AppColors.darkSurface,
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'סוג המשתמש *',
          style: GoogleFonts.assistant(
            color: AppColors.secondaryText,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedRole,
            style: GoogleFonts.assistant(color: AppColors.primaryText),
            dropdownColor: AppColors.darkSurface,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: const [
              DropdownMenuItem(
                value: AppConstants.roleStudent,
                child: Text('תלמיד/תלמידה'),
              ),
              DropdownMenuItem(
                value: AppConstants.roleParent,
                child: Text('הורה'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedRole = value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      style: GoogleFonts.assistant(color: AppColors.primaryText),
      decoration: InputDecoration(
        labelText: 'סיסמה *',
        labelStyle: GoogleFonts.assistant(color: AppColors.secondaryText),
        prefixIcon: Icon(Icons.lock, color: AppColors.neonTurquoise.withOpacity(0.7)),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
            color: AppColors.secondaryText,
          ),
          onPressed: () {
            setState(() => _isPasswordVisible = !_isPasswordVisible);
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputFocusedBorder, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputErrorBorder),
        ),
        filled: true,
        fillColor: AppColors.darkSurface,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'אנא הזינו סיסמה';
        }
        if (value.length < 6) {
          return 'הסיסמה חייבת להכיל לפחות 6 תווים';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: !_isConfirmPasswordVisible,
      style: GoogleFonts.assistant(color: AppColors.primaryText),
      decoration: InputDecoration(
        labelText: 'אישור סיסמה *',
        labelStyle: GoogleFonts.assistant(color: AppColors.secondaryText),
        prefixIcon: Icon(Icons.lock_outline, color: AppColors.neonTurquoise.withOpacity(0.7)),
        suffixIcon: IconButton(
          icon: Icon(
            _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
            color: AppColors.secondaryText,
          ),
          onPressed: () {
            setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputFocusedBorder, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputErrorBorder),
        ),
        filled: true,
        fillColor: AppColors.darkSurface,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'אנא אשרו את הסיסמה';
        }
        if (value != _passwordController.text) {
          return 'הסיסמאות אינן תואמות';
        }
        return null;
      },
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: NeonButton(
        text: _isLoading ? 'נרשם...' : 'הרשמה',
        onPressed: _isLoading ? null : _handleRegister,
        glowColor: AppColors.neonTurquoise,
        fontSize: 18,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}