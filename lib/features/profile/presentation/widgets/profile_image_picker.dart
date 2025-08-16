import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/enhanced_neon_effects.dart';
import '../providers/edit_profile_provider.dart';

class ProfileImagePicker extends ConsumerStatefulWidget {
  final String? currentImageUrl;
  final Function(XFile?) onImageSelected;
  final Function()? onImageRemoved;
  final bool isLoading;

  const ProfileImagePicker({
    super.key,
    this.currentImageUrl,
    required this.onImageSelected,
    this.onImageRemoved,
    this.isLoading = false,
  });

  @override
  ConsumerState<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends ConsumerState<ProfileImagePicker>
    with SingleTickerProviderStateMixin {
  XFile? _selectedImage;
  bool _isCompressing = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildImageContainer(),
        const SizedBox(height: 16),
        _buildActionButtons(),
        const SizedBox(height: 8),
        _buildImageInfo(),
      ],
    );
  }

  Widget _buildImageContainer() {
    return GestureDetector(
      onTap: widget.isLoading || _isCompressing ? null : _showImageSourceDialog,
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: _buildImageWidget(),
          );
        },
      ),
    );
  }

  Widget _buildImageWidget() {
    return Stack(
      children: [
        NeonGlowContainer(
          glowColor: AppColors.neonPink,
          animate: widget.isLoading || _isCompressing,
          glowRadius: 25,
          opacity: 0.3,
          isSubtle: true,
          borderRadius: BorderRadius.circular(100),
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.neonPink.withOpacity(0.6),
                width: 3,
              ),
              gradient: _selectedImage == null && widget.currentImageUrl == null
                  ? RadialGradient(
                      colors: [
                        AppColors.neonPink.withOpacity(0.2),
                        AppColors.neonTurquoise.withOpacity(0.2),
                      ],
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipOval(
              child: _getImageContent(),
            ),
          ),
        ),
        if (widget.isLoading || _isCompressing)
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
                  const SizedBox(height: 16),
                  Text(
                    _isCompressing ? 'דוחס תמונה...' : 'מעלה תמונה...',
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
          bottom: 15,
          left: 15,
          child: _buildCameraButton(),
        ),
        if (_selectedImage != null || widget.currentImageUrl != null)
          Positioned(
            top: 15,
            right: 15,
            child: _buildRemoveButton(),
          ),
      ],
    );
  }

  Widget _getImageContent() {
    if (_selectedImage != null) {
      return Image.file(
        File(_selectedImage!.path),
        fit: BoxFit.cover,
        width: 180,
        height: 180,
      );
    } else if (widget.currentImageUrl != null) {
      return Image.network(
        widget.currentImageUrl!,
        fit: BoxFit.cover,
        width: 180,
        height: 180,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
      );
    } else {
      return _buildDefaultAvatar();
    }
  }

  Widget _buildDefaultAvatar() {
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
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'לחצו להעלאה',
              style: GoogleFonts.assistant(
                color: AppColors.secondaryText,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.darkSurface,
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.neonTurquoise,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildCameraButton() {
    return NeonGlowContainer(
      glowColor: AppColors.neonTurquoise,
      glowRadius: 12,
      opacity: 0.4,
      isSubtle: true,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.neonTurquoise.withOpacity(0.6),
            width: 1.5,
          ),
        ),
        child: const Icon(
          Icons.camera_alt,
          size: 24,
          color: AppColors.neonTurquoise,
        ),
      ),
    );
  }

  Widget _buildRemoveButton() {
    return GestureDetector(
      onTap: _removeImage,
      child: NeonGlowContainer(
        glowColor: AppColors.error,
        glowRadius: 10,
        opacity: 0.4,
        isSubtle: true,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.error.withOpacity(0.6),
              width: 1.5,
            ),
          ),
          child: const Icon(
            Icons.close,
            size: 20,
            color: AppColors.error,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildActionButton(
          icon: Icons.photo_library,
          label: 'מהגלריה',
          onTap: () => _pickImage(ImageSource.gallery),
        ),
        const SizedBox(width: 20),
        _buildActionButton(
          icon: Icons.camera_alt,
          label: 'מהמצלמה',
          onTap: () => _pickImage(ImageSource.camera),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: widget.isLoading || _isCompressing ? null : onTap,
      child: NeonGlowContainer(
        glowColor: AppColors.neonTurquoise,
        glowRadius: 8,
        opacity: 0.2,
        isSubtle: true,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.darkSurface.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.neonTurquoise.withOpacity(0.3),
              width: 0.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: AppColors.neonTurquoise,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.assistant(
                  color: AppColors.primaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.darkSurface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.neonTurquoise.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.neonTurquoise.withOpacity(0.7),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'מידע על תמונת הפרופיל',
                style: GoogleFonts.assistant(
                  color: AppColors.neonTurquoise,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• גודל מקסימלי: 5MB\n• פורמטים נתמכים: JPG, PNG\n• התמונה תידחס אוטומטית לאיכות מיטבית',
            style: GoogleFonts.assistant(
              color: AppColors.secondaryText,
              fontSize: 12,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.authCardBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.secondaryText,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'בחירת תמונת פרופיל',
                style: GoogleFonts.assistant(
                  color: AppColors.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildBottomSheetOption(
                icon: Icons.photo_library,
                title: 'מהגלריה',
                subtitle: 'בחירה מהתמונות השמורות',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 12),
              _buildBottomSheetOption(
                icon: Icons.camera_alt,
                title: 'מהמצלמה',
                subtitle: 'צילום תמונה חדשה',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheetOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.neonTurquoise.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            NeonGlowContainer(
              glowColor: AppColors.neonTurquoise,
              glowRadius: 8,
              opacity: 0.3,
              isSubtle: true,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.neonTurquoise.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppColors.neonTurquoise,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.assistant(
                      color: AppColors.primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.assistant(
                      color: AppColors.secondaryText,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.secondaryText,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90,
      );

      if (image != null) {
        // Check file size before compression
        final file = File(image.path);
        final fileSize = await file.length();
        
        if (fileSize > AppConstants.maxProfileImageSize) {
          _showErrorDialog('התמונה גדולה מדי. גודל מקסימלי: 5MB');
          return;
        }

        setState(() {
          _isCompressing = true;
        });

        // Compress image
        final compressedImage = await _compressImage(image);
        
        setState(() {
          _selectedImage = compressedImage;
          _isCompressing = false;
        });

        widget.onImageSelected(compressedImage);
        
        _showSuccessMessage('התמונה נבחרה בהצלחה');
      }
    } catch (e) {
      setState(() {
        _isCompressing = false;
      });
      _showErrorDialog('שגיאה בבחירת התמונה: ${e.toString()}');
    }
  }

  Future<XFile> _compressImage(XFile image) async {
    final dir = await getTemporaryDirectory();
    final targetPath = path.join(
      dir.absolute.path,
      'compressed_profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      image.path,
      targetPath,
      quality: 85,
      minWidth: 512,
      minHeight: 512,
      format: CompressFormat.jpeg,
    );

    return compressedFile ?? image;
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
    widget.onImageSelected(null);
    widget.onImageRemoved?.call();
    _showSuccessMessage('התמונה הוסרה');
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.authCardBackground,
          title: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'שגיאה',
                style: GoogleFonts.assistant(
                  color: AppColors.error,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: GoogleFonts.assistant(
              color: AppColors.secondaryText,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'אישור',
                style: GoogleFonts.assistant(
                  color: AppColors.neonTurquoise,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.assistant(
            color: AppColors.primaryText,
            fontSize: 14,
          ),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}