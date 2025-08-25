import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/widgets/animated_gradient_background.dart';
import '../../../../shared/widgets/neon_text.dart';
import '../../../../shared/widgets/enhanced_neon_effects.dart';

/// עמוד הגדרות פרופיל אישי עבור אפליקציית זזה דאנס
class ProfileSettingsPage extends ConsumerStatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  ConsumerState<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends ConsumerState<ProfileSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _bioController = TextEditingController();
  
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();
  
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final currentUser = ref.read(currentUserProvider);
    currentUser.whenData((user) {
      if (user != null) {
        _displayNameController.text = user.displayName;
        _phoneController.text = user.phone ?? '';
        _addressController.text = user.address ?? '';
        _bioController.text = user.bio ?? '';
      }
    });
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (!isAuthenticated) {
      return _buildNotAuthenticatedView();
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: NeonText(
            text: 'עריכת פרופיל',
            fontSize: 24,
            glowColor: AppColors.neonPink,
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.primaryText,
            ),
            onPressed: () => context.pop(),
          ),
          actions: [
            if (_hasChanges && !_isLoading)
              IconButton(
                icon: Icon(
                  Icons.save,
                  color: AppColors.neonTurquoise,
                ),
                onPressed: _saveProfile,
                tooltip: 'שמור שינויים',
              ),
          ],
        ),
        body: AnimatedGradientBackground(
          child: SafeArea(
            child: currentUser.when(
              data: (user) => user != null ? _buildProfileForm(user) : _buildNotAuthenticatedView(),
              loading: () => Center(
                child: CircularProgressIndicator(color: AppColors.neonTurquoise),
              ),
              error: (error, stack) => _buildErrorView(error.toString()),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileForm(UserModel user) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // תמונת פרופיל
            _buildProfileImageSection(user),
            
            const SizedBox(height: 30),
            
            // פרטים אישיים
            _buildSection(
              'פרטים אישיים',
              AppColors.neonPink,
              [
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
                  onChanged: (_) => _onFieldChanged(),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: TextEditingController(text: user.email),
                  label: 'אימייל',
                  icon: Icons.email,
                  enabled: false,
                  helperText: 'לא ניתן לשנות את כתובת האימייל',
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // פרטי קשר
            _buildSection(
              'פרטי קשר',
              AppColors.neonTurquoise,
              [
                _buildTextField(
                  controller: _phoneController,
                  label: 'מספר טלפון',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      // בדיקה בסיסית לפורמט טלפון ישראלי
                      final phoneRegex = RegExp(r'^0[5-9]\d{8}$');
                      if (!phoneRegex.hasMatch(value.replaceAll('-', '').replaceAll(' ', ''))) {
                        return 'פורמט טלפון לא תקין (דוגמה: 050-1234567)';
                      }
                    }
                    return null;
                  },
                  onChanged: (_) => _onFieldChanged(),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _addressController,
                  label: 'כתובת',
                  icon: Icons.location_on,
                  maxLines: 2,
                  onChanged: (_) => _onFieldChanged(),
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // מידע נוסף
            _buildSection(
              'מידע נוסף',
              AppColors.neonBlue,
              [
                _buildTextField(
                  controller: _bioController,
                  label: 'קצת עליי',
                  icon: Icons.description,
                  maxLines: 4,
                  helperText: 'ספר קצת על עצמך, התחביבים שלך בריקוד ועוד',
                  onChanged: (_) => _onFieldChanged(),
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // מידע על חשבון
            _buildAccountInfoSection(user),
            
            const SizedBox(height: 30),
            
            // פעולות
            _buildActionButtons(),
            
            const SizedBox(height: 100), // מקום לניווט תחתון
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImageSection(UserModel user) {
    return Center(
      child: Column(
        children: [
          NeonText(
            text: 'תמונת פרופיל',
            fontSize: 18,
            glowColor: AppColors.neonPink,
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              NeonGlowContainer(
                glowColor: AppColors.neonPink,
                animate: true,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.darkSurface,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : (user.avatarUrl != null
                          ? NetworkImage(user.avatarUrl!)
                          : null) as ImageProvider?,
                  child: (_selectedImage == null && user.avatarUrl == null)
                      ? Icon(
                          Icons.person,
                          size: 60,
                          color: AppColors.neonPink,
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: NeonGlowContainer(
                  glowColor: AppColors.neonTurquoise,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.neonTurquoise,
                        width: 2,
                      ),
                    ),
                    child: InkWell(
                      onTap: _pickImage,
                      child: Icon(
                        Icons.camera_alt,
                        color: AppColors.neonTurquoise,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Color glowColor, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NeonText(
          text: title,
          fontSize: 18,
          glowColor: glowColor,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.cardGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: glowColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    Function(String)? onChanged,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool enabled = true,
    String? helperText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        prefixIcon: Icon(icon, color: AppColors.neonTurquoise),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.inputFocusedBorder, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.inputErrorBorder),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.inputErrorBorder, width: 2),
        ),
        labelStyle: GoogleFonts.assistant(color: AppColors.secondaryText),
        helperStyle: GoogleFonts.assistant(color: AppColors.secondaryText, fontSize: 12),
        filled: true,
        fillColor: AppColors.darkSurface,
      ),
      style: GoogleFonts.assistant(color: AppColors.primaryText),
      validator: validator,
      onChanged: onChanged,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
    );
  }

  Widget _buildAccountInfoSection(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkSurface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: AppColors.info),
              const SizedBox(width: 8),
              NeonText(
                text: 'מידע על החשבון',
                fontSize: 16,
                glowColor: AppColors.info,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('תפקיד', user.role.displayName),
          _buildInfoRow('תאריך הצטרפות', _formatDate(user.createdAt)),
          _buildInfoRow('עדכון אחרון', _formatDate(user.updatedAt)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.assistant(
              color: AppColors.secondaryText,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.assistant(
              color: AppColors.primaryText,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
            onPressed: _hasChanges && !_isLoading ? _saveProfile : null,
            glowColor: AppColors.neonTurquoise,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: NeonButton(
            text: 'ביטול שינויים',
            onPressed: _hasChanges && !_isLoading ? _resetChanges : null,
            glowColor: AppColors.warning,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: NeonButton(
            text: 'שינוי סיסמה',
            onPressed: !_isLoading ? _changePassword : null,
            glowColor: AppColors.accent1,
          ),
        ),
      ],
    );
  }

  Widget _buildNotAuthenticatedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off,
            size: 80,
            color: AppColors.secondaryText,
          ),
          const SizedBox(height: 20),
          NeonText(
            text: 'נדרשת התחברות',
            fontSize: 20,
            glowColor: AppColors.warning,
          ),
          const SizedBox(height: 10),
          Text(
            'יש להתחבר כדי לערוך את הפרופיל',
            style: GoogleFonts.assistant(
              color: AppColors.secondaryText,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 30),
          NeonButton(
            text: 'התחבר',
            onPressed: () => context.go('/auth/login'),
            glowColor: AppColors.neonGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: AppColors.error,
          ),
          const SizedBox(height: 20),
          NeonText(
            text: 'שגיאה בטעינת הפרופיל',
            fontSize: 20,
            glowColor: AppColors.error,
          ),
          const SizedBox(height: 10),
          Text(
            error,
            style: GoogleFonts.assistant(
              color: AppColors.secondaryText,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'בחר תמונת פרופיל',
                style: GoogleFonts.assistant(
                  color: AppColors.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceButton(
                    icon: Icons.camera_alt,
                    label: 'מצלמה',
                    onTap: () => _selectImageSource(ImageSource.camera),
                  ),
                  _buildImageSourceButton(
                    icon: Icons.photo_library,
                    label: 'גלריה',
                    onTap: () => _selectImageSource(ImageSource.gallery),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neonTurquoise.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.neonTurquoise,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.assistant(
                color: AppColors.primaryText,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectImageSource(ImageSource source) async {
    context.pop();
    
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _hasChanges = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה בבחירת תמונה: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = ref.read(authProvider.notifier);
      
      String? imageUrl;
      if (_selectedImage != null) {
        // העלאת תמונה ל-Supabase Storage
        final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final bytes = await _selectedImage!.readAsBytes();
        
        await Supabase.instance.client.storage
            .from('profile-images')
            .uploadBinary(fileName, bytes);
            
        imageUrl = Supabase.instance.client.storage
            .from('profile-images')
            .getPublicUrl(fileName);
      }
      
      final result = await authService.updateUserProfile(
        displayName: _displayNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        avatarUrl: imageUrl,
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
      );
      
      if (result.isSuccess) {
        setState(() {
          _hasChanges = false;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception(result.message);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('הפרופיל נשמר בהצלחה'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה בשמירת הפרופיל: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _resetChanges() {
    setState(() {
      _selectedImage = null;
      _hasChanges = false;
    });
    _loadUserData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('השינויים בוטלו'),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _changePassword() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: AppColors.accent1.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          title: Row(
            children: [
              Icon(Icons.lock, color: AppColors.accent1),
              const SizedBox(width: 8),
              NeonText(
                text: 'שינוי סיסמה',
                fontSize: 18,
                glowColor: AppColors.accent1,
              ),
            ],
          ),
          content: Text(
            'תישלח אליך הודעת אימייל לשינוי הסיסמה',
            style: GoogleFonts.assistant(
              color: AppColors.primaryText,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: Text(
                'ביטול',
                style: TextStyle(color: AppColors.secondaryText),
              ),
            ),
            NeonButton(
              text: 'שלח',
              onPressed: () async {
                context.pop();
                try {
                  await Supabase.instance.client.auth.resetPasswordForEmail(
                    ref.read(currentUserProvider).value?.email ?? '',
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('הודעה נשלחה לאימייל לשינוי סיסמה'),
                        backgroundColor: AppColors.info,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('שגיאה בשליחת אימייל: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              glowColor: AppColors.accent1,
            ),
          ],
        ),
      ),
    );
  }


  String _formatDate(DateTime? date) {
    if (date == null) return 'לא ידוע';
    return '${date.day}/${date.month}/${date.year}';
  }
}