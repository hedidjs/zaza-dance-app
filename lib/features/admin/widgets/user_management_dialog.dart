import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/neon_text.dart';
import '../../../shared/widgets/enhanced_neon_effects.dart';
import '../../../shared/models/user_model.dart';
import '../services/admin_user_service.dart';

/// דיאלוג מקיף לניהול משתמשים במערכת זזה דאנס
/// Comprehensive user management dialog for Zaza Dance system
class UserManagementDialog extends ConsumerStatefulWidget {
  /// המשתמש הקיים לעריכה (null עבור יצירת משתמש חדש)
  /// Existing user for editing (null for creating new user)
  final UserModel? existingUser;
  
  /// פונקציית callback עם השמירה מצליחה
  /// Callback function when save is successful
  final Function(UserModel user)? onSaved;
  
  /// פונקציית callback עם המחיקה מצליחה
  /// Callback function when deletion is successful
  final Function()? onDeleted;

  const UserManagementDialog({
    super.key,
    this.existingUser,
    this.onSaved,
    this.onDeleted,
  });

  @override
  ConsumerState<UserManagementDialog> createState() => _UserManagementDialogState();
}

class _UserManagementDialogState extends ConsumerState<UserManagementDialog>
    with TickerProviderStateMixin {
  
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _bioController = TextEditingController();
  
  // Form state
  String _selectedRole = 'student';
  DateTime? _selectedBirthDate;
  bool _isLoading = false;
  bool _isValidatingEmail = false;
  bool _emailExists = false;
  String? _errorMessage;
  
  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;
  
  // Available user roles with Hebrew descriptions
  final Map<String, String> _roleOptions = {
    'admin': 'מנהל מערכת',
    'instructor': 'מדריך',
    'parent': 'הורה',
    'student': 'תלמיד',
  };

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initializeForm();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _displayNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
  }

  void _initializeForm() {
    if (widget.existingUser != null) {
      final user = widget.existingUser!;
      _emailController.text = user.email;
      _firstNameController.text = user.firstName ?? '';
      _lastNameController.text = user.lastName ?? '';
      _displayNameController.text = user.displayName;
      _phoneController.text = user.phone ?? '';
      _addressController.text = user.address ?? '';
      _bioController.text = user.bio ?? '';
      _selectedRole = user.role.value;
      _selectedBirthDate = user.dateOfBirth;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: _buildDialogContent(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDialogContent() {
    return NeonGlowContainer(
      glowColor: AppColors.neonPink,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.darkCard,
              AppColors.darkSurface,
              AppColors.darkCard,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.neonPink.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: _buildForm(),
            ),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.neonPink.withValues(alpha: 0.1),
            AppColors.neonTurquoise.withValues(alpha: 0.1),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: NeonGlowContainer(
                  glowColor: widget.existingUser != null 
                      ? AppColors.neonTurquoise 
                      : AppColors.neonPink,
                  animate: true,
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.darkSurface,
                    child: Icon(
                      widget.existingUser != null 
                          ? Icons.edit_rounded 
                          : Icons.person_add_rounded,
                      color: widget.existingUser != null 
                          ? AppColors.neonTurquoise 
                          : AppColors.neonPink,
                      size: 28,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NeonText(
                  text: widget.existingUser != null 
                      ? 'עריכת משתמש' 
                      : 'יצירת משתמש חדש',
                  fontSize: 22,
                  glowColor: widget.existingUser != null 
                      ? AppColors.neonTurquoise 
                      : AppColors.neonPink,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.existingUser != null 
                      ? 'עדכון פרטי משתמש קיים במערכת'
                      : 'הוספת משתמש חדש למערכת זזה דאנס',
                  style: GoogleFonts.assistant(
                    color: AppColors.secondaryText,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: NeonGlowContainer(
              glowColor: AppColors.error,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: AppColors.error,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            
            // Error message
            if (_errorMessage != null) ...[
              _buildErrorCard(),
              const SizedBox(height: 16),
            ],
            
            // Email field
            _buildEmailField(),
            const SizedBox(height: 16),
            
            // Name fields row
            Row(
              children: [
                Expanded(child: _buildFirstNameField()),
                const SizedBox(width: 12),
                Expanded(child: _buildLastNameField()),
              ],
            ),
            const SizedBox(height: 16),
            
            // Display name field
            _buildDisplayNameField(),
            const SizedBox(height: 16),
            
            // Role selection
            _buildRoleField(),
            const SizedBox(height: 16),
            
            // Phone field
            _buildPhoneField(),
            const SizedBox(height: 16),
            
            // Birth date field
            _buildBirthDateField(),
            const SizedBox(height: 16),
            
            // Address field
            _buildAddressField(),
            const SizedBox(height: 16),
            
            // Bio field
            _buildBioField(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return NeonGlowContainer(
      glowColor: AppColors.error,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.error.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage!,
                style: GoogleFonts.assistant(
                  color: AppColors.error,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return _buildFormField(
      controller: _emailController,
      label: 'כתובת אימייל',
      icon: Icons.email_rounded,
      keyboardType: TextInputType.emailAddress,
      isRequired: true,
      suffix: _isValidatingEmail
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(AppColors.neonTurquoise),
              ),
            )
          : _emailExists
              ? Icon(Icons.error_rounded, color: AppColors.error, size: 20)
              : null,
      validator: _validateEmail,
      onChanged: widget.existingUser == null ? _onEmailChanged : null,
      enabled: widget.existingUser == null, // לא ניתן לשנות אימייל של משתמש קיים
    );
  }

  Widget _buildFirstNameField() {
    return _buildFormField(
      controller: _firstNameController,
      label: 'שם פרטי',
      icon: Icons.person_rounded,
      isRequired: true,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'שם פרטי הוא שדה חובה';
        }
        if (value.trim().length < 2) {
          return 'שם פרטי חייב להכיל לפחות 2 תווים';
        }
        return null;
      },
    );
  }

  Widget _buildLastNameField() {
    return _buildFormField(
      controller: _lastNameController,
      label: 'שם משפחה',
      icon: Icons.family_restroom_rounded,
      validator: (value) {
        if (value != null && value.trim().isNotEmpty && value.trim().length < 2) {
          return 'שם משפחה חייב להכיל לפחות 2 תווים';
        }
        return null;
      },
    );
  }

  Widget _buildDisplayNameField() {
    return _buildFormField(
      controller: _displayNameController,
      label: 'שם תצוגה',
      icon: Icons.badge_rounded,
      isRequired: true,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'שם תצוגה הוא שדה חובה';
        }
        if (value.trim().length < 2) {
          return 'שם תצוגה חייב להכיל לפחות 2 תווים';
        }
        return null;
      },
    );
  }

  Widget _buildRoleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.admin_panel_settings_rounded,
              color: AppColors.neonTurquoise,
              size: 20,
            ),
            const SizedBox(width: 8),
            NeonText(
              text: 'תפקיד במערכת',
              fontSize: 14,
              glowColor: AppColors.neonTurquoise,
              fontWeight: FontWeight.w600,
            ),
            Text(
              ' *',
              style: GoogleFonts.assistant(
                color: AppColors.error,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        NeonGlowContainer(
          glowColor: AppColors.neonTurquoise,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.neonTurquoise.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: DropdownButtonFormField<String>(
              initialValue: _selectedRole,
              style: GoogleFonts.assistant(
                color: AppColors.primaryText,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: InputBorder.none,
                fillColor: Colors.transparent,
                filled: false,
              ),
              dropdownColor: AppColors.darkCard,
              icon: Icon(
                Icons.arrow_drop_down_rounded,
                color: AppColors.neonTurquoise,
              ),
              items: _roleOptions.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Row(
                    children: [
                      _getRoleIcon(entry.key),
                      const SizedBox(width: 12),
                      Text(
                        entry.value,
                        style: GoogleFonts.assistant(
                          color: AppColors.primaryText,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedRole = value;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return _buildFormField(
      controller: _phoneController,
      label: 'מספר טלפון',
      icon: Icons.phone_rounded,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s\(\)]')),
      ],
      validator: _validatePhoneNumber,
      hint: 'לדוגמה: 050-1234567',
    );
  }

  Widget _buildBirthDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.cake_rounded,
              color: AppColors.neonPurple,
              size: 20,
            ),
            const SizedBox(width: 8),
            NeonText(
              text: 'תאריך לידה',
              fontSize: 14,
              glowColor: AppColors.neonPurple,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectBirthDate,
          borderRadius: BorderRadius.circular(12),
          child: NeonGlowContainer(
            glowColor: AppColors.neonPurple,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.neonPurple.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedBirthDate != null
                          ? '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}'
                          : 'בחר תאריך לידה',
                      style: GoogleFonts.assistant(
                        color: _selectedBirthDate != null
                            ? AppColors.primaryText
                            : AppColors.disabledText,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.calendar_today_rounded,
                    color: AppColors.neonPurple,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressField() {
    return _buildFormField(
      controller: _addressController,
      label: 'כתובת',
      icon: Icons.location_on_rounded,
      maxLines: 2,
      hint: 'רחוב, עיר, מיקוד',
    );
  }

  Widget _buildBioField() {
    return _buildFormField(
      controller: _bioController,
      label: 'אודות',
      icon: Icons.info_rounded,
      maxLines: 3,
      hint: 'ספר מעט על עצמך...',
      maxLength: 500,
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool isRequired = false,
    bool enabled = true,
    Widget? suffix,
    String? hint,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: AppColors.neonTurquoise,
              size: 20,
            ),
            const SizedBox(width: 8),
            NeonText(
              text: label,
              fontSize: 14,
              glowColor: AppColors.neonTurquoise,
              fontWeight: FontWeight.w600,
            ),
            if (isRequired)
              Text(
                ' *',
                style: GoogleFonts.assistant(
                  color: AppColors.error,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        NeonGlowContainer(
          glowColor: enabled ? AppColors.neonTurquoise : AppColors.disabledText,
          borderRadius: BorderRadius.circular(12),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            validator: validator,
            onChanged: onChanged,
            enabled: enabled,
            maxLines: maxLines,
            maxLength: maxLength,
            style: GoogleFonts.assistant(
              color: enabled ? AppColors.primaryText : AppColors.disabledText,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.assistant(
                color: AppColors.disabledText,
                fontSize: 16,
              ),
              suffixIcon: suffix != null ? Padding(
                padding: const EdgeInsets.only(left: 12),
                child: suffix,
              ) : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: enabled 
                      ? AppColors.neonTurquoise.withValues(alpha: 0.3)
                      : AppColors.disabledText.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.neonTurquoise.withValues(alpha: 0.3),
                  width: 1,
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
                  width: 1,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.disabledText.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              fillColor: enabled ? AppColors.darkSurface : AppColors.darkSurface.withValues(alpha: 0.5),
              filled: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.neonTurquoise.withValues(alpha: 0.05),
            AppColors.neonPink.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          // Delete button (only for existing users)
          if (widget.existingUser != null) ...[
            Expanded(
              child: NeonButton(
                text: 'מחק משתמש',
                onPressed: _isLoading ? null : _deleteUser,
                glowColor: AppColors.error,
              ),
            ),
            const SizedBox(width: 12),
          ],
          
          // Cancel button
          Expanded(
            child: NeonButton(
              text: 'ביטול',
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              glowColor: AppColors.secondaryText,
            ),
          ),
          const SizedBox(width: 12),
          
          // Save button
          Expanded(
            flex: 2,
            child: NeonButton(
              text: _isLoading ? 'שומר...' : (widget.existingUser != null ? 'עדכן' : 'שמור'),
              onPressed: _isLoading ? null : _saveUser,
              glowColor: AppColors.neonPink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getRoleIcon(String role) {
    switch (role) {
      case 'admin':
        return Icon(Icons.admin_panel_settings_rounded, color: AppColors.warning, size: 20);
      case 'instructor':
        return Icon(Icons.school_rounded, color: AppColors.neonTurquoise, size: 20);
      case 'parent':
        return Icon(Icons.family_restroom_rounded, color: AppColors.neonPurple, size: 20);
      case 'student':
        return Icon(Icons.person_rounded, color: AppColors.neonBlue, size: 20);
      default:
        return Icon(Icons.person_rounded, color: AppColors.secondaryText, size: 20);
    }
  }

  // Validation methods
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'כתובת אימייל היא שדה חובה';
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'כתובת אימייל לא תקינה';
    }
    
    if (_emailExists && widget.existingUser == null) {
      return 'כתובת אימייל זו כבר רשומה במערכת';
    }
    
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone is optional
    }
    
    final phoneRegex = RegExp(r'^[\+]?[0-9\-\s\(\)]{9,15}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'מספר טלפון לא תקין';
    }
    
    return null;
  }

  // Event handlers
  void _onEmailChanged(String value) async {
    if (value.trim().isEmpty) {
      setState(() {
        _emailExists = false;
        _isValidatingEmail = false;
      });
      return;
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      setState(() {
        _emailExists = false;
        _isValidatingEmail = false;
      });
      return;
    }
    
    setState(() {
      _isValidatingEmail = true;
      _emailExists = false;
    });
    
    // Simulate email validation check
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (mounted && _emailController.text == value) {
      setState(() {
        _isValidatingEmail = false;
        _emailExists = false; // In real implementation, check with AdminUserService
      });
    }
  }

  void _selectBirthDate() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 100);
    final lastDate = DateTime(now.year - 5); // Minimum age 5 years
    
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(now.year - 20),
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.neonPurple,
              onPrimary: AppColors.primaryText,
              surface: AppColors.darkCard,
              onSurface: AppColors.primaryText,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (selectedDate != null) {
      setState(() {
        _selectedBirthDate = selectedDate;
      });
    }
  }

  void _saveUser() async {
    if (!_formKey.currentState!.validate()) {
      _shakeController.forward().then((_) => _shakeController.reset());
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      if (widget.existingUser != null) {
        // Update existing user
        final updateData = {
          'first_name': _firstNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
          'display_name': _displayNameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'bio': _bioController.text.trim(),
          if (_selectedBirthDate != null)
            'date_of_birth': _selectedBirthDate!.toIso8601String(),
        };
        
        final result = await AdminUserService.updateUser(
          widget.existingUser!.id,
          updateData,
        );
        
        if (result.isSuccess && result.data != null) {
          if (mounted) {
            Navigator.of(context).pop();
            widget.onSaved?.call(result.data!);
            _showSuccessSnackBar('פרטי המשתמש עודכנו בהצלחה');
          }
        } else {
          throw Exception(result.message);
        }
      } else {
        // Create new user
        final result = await AdminUserService.createUser(
          email: _emailController.text.trim(),
          displayName: _displayNameController.text.trim(),
          role: _selectedRole,
          phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
          address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
        );
        
        if (result.isSuccess && result.data != null) {
          if (mounted) {
            Navigator.of(context).pop();
            widget.onSaved?.call(result.data!);
            _showSuccessSnackBar('המשתמש נוצר בהצלחה');
          }
        } else {
          throw Exception(result.message);
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      _shakeController.forward().then((_) => _shakeController.reset());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _deleteUser() async {
    if (widget.existingUser == null) return;
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.darkCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: AppColors.error.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          title: NeonText(
            text: 'אישור מחיקה',
            fontSize: 20,
            glowColor: AppColors.error,
          ),
          content: Text(
            'האם אתה בטוח שברצונך למחוק את המשתמש "${widget.existingUser!.displayName}"?\nפעולה זו אינה ניתנת לביטול.',
            style: GoogleFonts.assistant(
              color: AppColors.primaryText,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'ביטול',
                style: GoogleFonts.assistant(
                  color: AppColors.secondaryText,
                  fontSize: 16,
                ),
              ),
            ),
            NeonButton(
              text: 'מחק',
              onPressed: () => Navigator.of(context).pop(true),
              glowColor: AppColors.error,
            ),
          ],
        ),
      ),
    );
    
    if (confirmed != true) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final result = await AdminUserService.deleteUser(widget.existingUser!.id);
      
      if (result.isSuccess) {
        if (mounted) {
          Navigator.of(context).pop();
          widget.onDeleted?.call();
          _showSuccessSnackBar('המשתמש הוסר מהמערכת בהצלחה');
        }
      } else {
        throw Exception(result.message);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      _shakeController.forward().then((_) => _shakeController.reset());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.assistant(
                  color: AppColors.primaryText,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success.withValues(alpha: 0.2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: AppColors.success.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}