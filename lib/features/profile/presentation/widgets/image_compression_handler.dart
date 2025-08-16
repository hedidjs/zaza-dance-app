import 'dart:io';
import 'dart:typed_data';
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

class ImageCompressionHandler extends ConsumerStatefulWidget {
  final XFile? imageFile;
  final Function(XFile?) onImageProcessed;
  final Function(String)? onError;
  final Function(double)? onProgressUpdate;

  const ImageCompressionHandler({
    super.key,
    required this.imageFile,
    required this.onImageProcessed,
    this.onError,
    this.onProgressUpdate,
  });

  @override
  ConsumerState<ImageCompressionHandler> createState() => _ImageCompressionHandlerState();
}

class _ImageCompressionHandlerState extends ConsumerState<ImageCompressionHandler>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  
  bool _isCompressing = false;
  double _compressionProgress = 0.0;
  String _currentStep = '';
  Map<String, dynamic>? _imageInfo;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _processImage();
  }

  @override
  void didUpdateWidget(ImageCompressionHandler oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageFile != widget.imageFile && widget.imageFile != null) {
      _processImage();
    }
  }

  void _initializeAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _processImage() async {
    if (widget.imageFile == null) return;

    setState(() {
      _isCompressing = true;
      _compressionProgress = 0.0;
      _currentStep = 'מתחיל לעבד את התמונה...';
    });

    _pulseController.repeat(reverse: true);

    try {
      // Step 1: Analyze image
      await _updateProgress(0.1, 'מנתח את התמונה...');
      final imageInfo = await _analyzeImage(widget.imageFile!);
      
      setState(() {
        _imageInfo = imageInfo;
      });

      // Step 2: Check if compression is needed
      await _updateProgress(0.2, 'בודק אם נדרשת דחיסה...');
      
      if (imageInfo['size'] <= AppConstants.maxProfileImageSize && 
          imageInfo['width'] <= 1024 && 
          imageInfo['height'] <= 1024) {
        // No compression needed
        await _updateProgress(1.0, 'התמונה מוכנה!');
        _completeProcessing(widget.imageFile!);
        return;
      }

      // Step 3: Compress image
      await _updateProgress(0.3, 'דוחס את התמונה...');
      final compressedImage = await _compressImage(widget.imageFile!);

      // Step 4: Validate result
      await _updateProgress(0.9, 'מוודא איכות...');
      final finalInfo = await _analyzeImage(compressedImage);
      
      if (finalInfo['size'] > AppConstants.maxProfileImageSize) {
        throw Exception('לא ניתן לדחוס את התמונה מספיק. נסו תמונה אחרת.');
      }

      await _updateProgress(1.0, 'התמונה מוכנה!');
      _completeProcessing(compressedImage);

    } catch (e) {
      _handleError(e.toString());
    }
  }

  Future<void> _updateProgress(double progress, String step) async {
    setState(() {
      _compressionProgress = progress;
      _currentStep = step;
    });
    
    _progressController.animateTo(progress);
    widget.onProgressUpdate?.call(progress);
    
    // Small delay for UX
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<Map<String, dynamic>> _analyzeImage(XFile imageFile) async {
    final file = File(imageFile.path);
    final bytes = await file.readAsBytes();
    
    // Get file size
    final size = bytes.length;
    
    // Decode image to get dimensions
    final image = await decodeImageFromList(bytes);
    
    return {
      'size': size,
      'width': image.width,
      'height': image.height,
      'format': path.extension(imageFile.path).toLowerCase(),
    };
  }

  Future<XFile> _compressImage(XFile imageFile) async {
    final dir = await getTemporaryDirectory();
    final targetPath = path.join(
      dir.absolute.path,
      'compressed_profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    // Calculate optimal compression settings
    final imageInfo = _imageInfo!;
    int quality = 85;
    int maxWidth = 1024;
    int maxHeight = 1024;

    // Adjust settings based on original image size
    if (imageInfo['size'] > 10 * 1024 * 1024) { // > 10MB
      quality = 70;
      maxWidth = 800;
      maxHeight = 800;
    } else if (imageInfo['size'] > 5 * 1024 * 1024) { // > 5MB
      quality = 75;
      maxWidth = 900;
      maxHeight = 900;
    }

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      imageFile.path,
      targetPath,
      quality: quality,
      minWidth: 512,
      minHeight: 512,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      format: CompressFormat.jpeg,
    );

    return compressedFile ?? imageFile;
  }

  void _completeProcessing(XFile processedImage) {
    _pulseController.stop();
    _pulseController.reset();
    
    setState(() {
      _isCompressing = false;
    });

    widget.onImageProcessed(processedImage);
  }

  void _handleError(String error) {
    _pulseController.stop();
    _pulseController.reset();
    
    setState(() {
      _isCompressing = false;
    });

    widget.onError?.call(error);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCompressing) {
      return const SizedBox.shrink();
    }

    return _buildCompressionOverlay();
  }

  Widget _buildCompressionOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: NeonGlowContainer(
          glowColor: AppColors.neonTurquoise,
          glowRadius: 20,
          opacity: 0.3,
          animate: true,
          isSubtle: true,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.authCardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.neonTurquoise.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCompressionAnimation(),
                const SizedBox(height: 20),
                _buildProgressIndicator(),
                const SizedBox(height: 16),
                _buildStatusText(),
                if (_imageInfo != null) ...[
                  const SizedBox(height: 20),
                  _buildImageInfo(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompressionAnimation() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: NeonGlowContainer(
            glowColor: AppColors.neonPink,
            glowRadius: 25,
            opacity: 0.4,
            animate: true,
            isSubtle: true,
            borderRadius: BorderRadius.circular(50),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.neonTurquoise.withOpacity(0.3),
                    AppColors.neonPink.withOpacity(0.3),
                  ],
                ),
                border: Border.all(
                  color: AppColors.neonTurquoise.withOpacity(0.6),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.compress,
                color: AppColors.neonTurquoise,
                size: 32,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Container(
          width: 250,
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: AppColors.neonTurquoise.withOpacity(0.3),
              width: 0.5,
            ),
          ),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerRight,
                widthFactor: _progressAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.neonTurquoise,
                        AppColors.neonPink,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonTurquoise.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(_compressionProgress * 100).toInt()}%',
          style: GoogleFonts.assistant(
            color: AppColors.neonTurquoise,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusText() {
    return Text(
      _currentStep,
      style: GoogleFonts.assistant(
        color: AppColors.primaryText,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildImageInfo() {
    final info = _imageInfo!;
    final sizeInMB = (info['size'] / (1024 * 1024)).toStringAsFixed(2);
    
    return Container(
      padding: const EdgeInsets.all(12),
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
          Text(
            'פרטי התמונה',
            style: GoogleFonts.assistant(
              color: AppColors.neonTurquoise,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'גודל:',
                style: GoogleFonts.assistant(
                  color: AppColors.secondaryText,
                  fontSize: 11,
                ),
              ),
              Text(
                '${sizeInMB} MB',
                style: GoogleFonts.assistant(
                  color: AppColors.primaryText,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'רזולוציה:',
                style: GoogleFonts.assistant(
                  color: AppColors.secondaryText,
                  fontSize: 11,
                ),
              ),
              Text(
                '${info['width']} × ${info['height']}',
                style: GoogleFonts.assistant(
                  color: AppColors.primaryText,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Loading states for various profile operations
class ProfileLoadingState extends StatefulWidget {
  final String operation;
  final String? description;
  final bool showProgress;
  final double? progress;
  final Color? glowColor;

  const ProfileLoadingState({
    super.key,
    required this.operation,
    this.description,
    this.showProgress = false,
    this.progress,
    this.glowColor,
  });

  @override
  State<ProfileLoadingState> createState() => _ProfileLoadingStateState();
}

class _ProfileLoadingStateState extends State<ProfileLoadingState>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_rotationController);

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.glowColor ?? AppColors.neonTurquoise;
    
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: NeonGlowContainer(
            glowColor: effectiveColor,
            glowRadius: 20,
            opacity: 0.3,
            animate: true,
            isSubtle: true,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.authCardBackground.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: effectiveColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLoadingIcon(effectiveColor),
                  const SizedBox(height: 16),
                  Text(
                    widget.operation,
                    style: GoogleFonts.assistant(
                      color: AppColors.primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (widget.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.description!,
                      style: GoogleFonts.assistant(
                        color: AppColors.secondaryText,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (widget.showProgress && widget.progress != null) ...[
                    const SizedBox(height: 16),
                    _buildProgressBar(effectiveColor),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIcon(Color color) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value * 2 * 3.14159,
          child: NeonGlowContainer(
            glowColor: color,
            glowRadius: 15,
            opacity: 0.4,
            isSubtle: true,
            borderRadius: BorderRadius.circular(25),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    color.withOpacity(0.3),
                    color.withOpacity(0.1),
                  ],
                ),
                border: Border.all(
                  color: color.withOpacity(0.6),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.sync,
                color: color,
                size: 24,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(Color color) {
    return Column(
      children: [
        Container(
          width: 200,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerRight,
            widthFactor: widget.progress!,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(widget.progress! * 100).toInt()}%',
          style: GoogleFonts.assistant(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// Provider for image compression state
final imageCompressionProvider = StateNotifierProvider<ImageCompressionNotifier, ImageCompressionState>((ref) {
  return ImageCompressionNotifier();
});

class ImageCompressionState {
  final bool isCompressing;
  final double progress;
  final String currentStep;
  final String? error;
  final XFile? originalImage;
  final XFile? compressedImage;
  final Map<String, dynamic>? imageInfo;

  const ImageCompressionState({
    this.isCompressing = false,
    this.progress = 0.0,
    this.currentStep = '',
    this.error,
    this.originalImage,
    this.compressedImage,
    this.imageInfo,
  });

  ImageCompressionState copyWith({
    bool? isCompressing,
    double? progress,
    String? currentStep,
    String? error,
    XFile? originalImage,
    XFile? compressedImage,
    Map<String, dynamic>? imageInfo,
  }) {
    return ImageCompressionState(
      isCompressing: isCompressing ?? this.isCompressing,
      progress: progress ?? this.progress,
      currentStep: currentStep ?? this.currentStep,
      error: error,
      originalImage: originalImage ?? this.originalImage,
      compressedImage: compressedImage ?? this.compressedImage,
      imageInfo: imageInfo ?? this.imageInfo,
    );
  }
}

class ImageCompressionNotifier extends StateNotifier<ImageCompressionState> {
  ImageCompressionNotifier() : super(const ImageCompressionState());

  Future<XFile?> compressImage(XFile imageFile) async {
    state = state.copyWith(
      isCompressing: true,
      progress: 0.0,
      currentStep: 'מתחיל דחיסה...',
      originalImage: imageFile,
      error: null,
    );

    try {
      // Implementation similar to _processImage in ImageCompressionHandler
      // This is a simplified version
      
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(
        dir.absolute.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      state = state.copyWith(progress: 0.5, currentStep: 'דוחס תמונה...');

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.path,
        targetPath,
        quality: 85,
        minWidth: 512,
        minHeight: 512,
        maxWidth: 1024,
        maxHeight: 1024,
        format: CompressFormat.jpeg,
      );

      state = state.copyWith(
        isCompressing: false,
        progress: 1.0,
        currentStep: 'הושלם!',
        compressedImage: compressedFile,
      );

      return compressedFile;
    } catch (e) {
      state = state.copyWith(
        isCompressing: false,
        error: e.toString(),
      );
      return null;
    }
  }

  void reset() {
    state = const ImageCompressionState();
  }
}