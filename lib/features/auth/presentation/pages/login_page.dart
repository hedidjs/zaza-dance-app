import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../shared/widgets/neon_text.dart';
import '../../../../shared/widgets/enhanced_neon_effects.dart';
import 'register_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await ref.read(currentUserProvider.notifier).signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        if (result.isSuccess) {
          Navigator.of(context).pushReplacementNamed('/home');
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

  Future<void> _handleForgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      _showErrorMessage('אנא הזינו את כתובת האימייל שלכם');
      return;
    }

    final result = await ref.read(currentUserProvider.notifier).resetPassword(
      email: _emailController.text.trim(),
    );

    if (mounted) {
      _showMessage(result.message, isError: !result.isSuccess);
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
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.5,
              colors: [
                Color(0xFF2A2A2A),
                Color(0xFF1A1A1A),
                AppColors.darkBackground,
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  _buildHeader(),
                  const SizedBox(height: 60),
                  _buildLoginForm(),
                  const SizedBox(height: 40),
                  _buildRegisterPrompt(),
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
        NeonGlowContainer(
          glowColor: AppColors.neonPink,
          animate: true,
          child: Icon(
            Icons.login,
            size: 80,
            color: AppColors.neonPink,
          ),
        ),
        const SizedBox(height: 30),
        NeonText(
          text: 'ברוכים השבים',
          fontSize: 32,
          glowColor: AppColors.neonPink,
        ),
        const SizedBox(height: 10),
        Text(
          'התחברו לחשבון שלכם',
          style: GoogleFonts.assistant(
            fontSize: 16,
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return NeonGlowContainer(
      glowColor: AppColors.neonTurquoise,
      glowRadius: 15,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.authCardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.neonTurquoise.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildEmailField(),
              const SizedBox(height: 20),
              _buildPasswordField(),
              const SizedBox(height: 12),
              _buildForgotPasswordButton(),
              const SizedBox(height: 30),
              _buildLoginButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: GoogleFonts.assistant(color: AppColors.primaryText),
      decoration: InputDecoration(
        labelText: 'כתובת אימייל',
        labelStyle: GoogleFonts.assistant(color: AppColors.secondaryText),
        prefixIcon: Icon(Icons.email, color: AppColors.neonTurquoise),
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

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      style: GoogleFonts.assistant(color: AppColors.primaryText),
      decoration: InputDecoration(
        labelText: 'סיסמה',
        labelStyle: GoogleFonts.assistant(color: AppColors.secondaryText),
        prefixIcon: Icon(Icons.lock, color: AppColors.neonTurquoise),
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

  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: _handleForgotPassword,
        child: Text(
          'שכחתם את הסיסמה?',
          style: GoogleFonts.assistant(
            color: AppColors.neonTurquoise,
            fontSize: 14,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: NeonButton(
        text: _isLoading ? 'מתחבר...' : 'התחברות',
        onPressed: _isLoading ? null : _handleLogin,
        glowColor: AppColors.neonPink,
        fontSize: 18,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildRegisterPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'אין לכם חשבון? ',
          style: GoogleFonts.assistant(
            color: AppColors.secondaryText,
            fontSize: 16,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const RegisterPage(),
              ),
            );
          },
          child: Text(
            'הרשמה',
            style: GoogleFonts.assistant(
              color: AppColors.neonTurquoise,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}