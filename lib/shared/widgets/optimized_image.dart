import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/cache_service.dart';

/// Optimized image widget with enhanced performance and user experience
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Color? placeholderColor;
  final Widget? errorWidget;
  final Duration animationDuration;
  final bool enableHeroAnimation;
  final String? heroTag;
  final VoidCallback? onTap;
  final bool useShimmer;
  final double? aspectRatio;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderColor,
    this.errorWidget,
    this.animationDuration = const Duration(milliseconds: 300),
    this.enableHeroAnimation = false,
    this.heroTag,
    this.onTap,
    this.useShimmer = true,
    this.aspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = _buildCachedImage();

    // Apply border radius if specified
    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    // Apply aspect ratio if specified
    if (aspectRatio != null) {
      imageWidget = AspectRatio(
        aspectRatio: aspectRatio!,
        child: imageWidget,
      );
    }

    // Apply hero animation if enabled
    if (enableHeroAnimation && heroTag != null) {
      imageWidget = Hero(
        tag: heroTag!,
        child: imageWidget,
      );
    }

    // Apply tap gesture if specified
    if (onTap != null) {
      imageWidget = GestureDetector(
        onTap: onTap,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildCachedImage() {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      cacheManager: CacheService().imageCache,
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) => _buildErrorWidget(),
      fadeInDuration: animationDuration,
      fadeOutDuration: animationDuration,
      memCacheWidth: _getOptimalWidth(),
      memCacheHeight: _getOptimalHeight(),
    );
  }

  Widget _buildPlaceholder() {
    if (useShimmer) {
      return _buildShimmerPlaceholder();
    } else {
      return _buildSimplePlaceholder();
    }
  }

  Widget _buildShimmerPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: placeholderColor ?? AppColors.darkCard,
        borderRadius: borderRadius,
      ),
      child: Stack(
        children: [
          // Base color
          Positioned.fill(
            child: Container(
              color: AppColors.darkCard,
            ),
          ),
          // Shimmer effect
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: const Alignment(-1.0, -0.3),
                  end: const Alignment(1.0, 0.3),
                  colors: [
                    AppColors.darkCard,
                    AppColors.darkCard.withOpacity(0.3),
                    AppColors.neonTurquoise.withOpacity(0.1),
                    AppColors.darkCard.withOpacity(0.3),
                    AppColors.darkCard,
                  ],
                  stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
                ),
              ),
            ).animate(onPlay: (controller) => controller.repeat())
                .slideX(
                  duration: const Duration(milliseconds: 1500),
                  begin: -1,
                  end: 1,
                  curve: Curves.easeInOut,
                ),
          ),
          // Loading icon
          Center(
            child: Icon(
              Icons.image,
              color: AppColors.secondaryText.withOpacity(0.5),
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimplePlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: placeholderColor ?? AppColors.darkCard,
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.neonTurquoise,
              strokeWidth: 2,
            ),
            const SizedBox(height: 8),
            Text(
              'טוען...',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return errorWidget ?? Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: borderRadius,
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            color: AppColors.error,
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            'שגיאה בטעינה',
            style: TextStyle(
              color: AppColors.error,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Optimize memory usage by calculating appropriate cache dimensions
  int? _getOptimalWidth() {
    if (width == null) return null;
    // Use 2x for high DPI screens, but cap at reasonable size
    return (width! * 2).clamp(100, 800).toInt();
  }

  int? _getOptimalHeight() {
    if (height == null) return null;
    // Use 2x for high DPI screens, but cap at reasonable size
    return (height! * 2).clamp(100, 800).toInt();
  }
}

/// Specialized optimized image for thumbnails
class OptimizedThumbnail extends StatelessWidget {
  final String imageUrl;
  final double size;
  final VoidCallback? onTap;
  final bool enableHeroAnimation;
  final String? heroTag;

  const OptimizedThumbnail({
    super.key,
    required this.imageUrl,
    this.size = 80,
    this.onTap,
    this.enableHeroAnimation = false,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return OptimizedImage(
      imageUrl: imageUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(8),
      enableHeroAnimation: enableHeroAnimation,
      heroTag: heroTag,
      onTap: onTap,
      useShimmer: false, // Simpler placeholder for thumbnails
    );
  }
}

/// Grid of optimized images with staggered loading
class OptimizedImageGrid extends StatelessWidget {
  final List<String> imageUrls;
  final int crossAxisCount;
  final double aspectRatio;
  final EdgeInsets padding;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final Function(String, int)? onImageTap;

  const OptimizedImageGrid({
    super.key,
    required this.imageUrls,
    this.crossAxisCount = 2,
    this.aspectRatio = 1.0,
    this.padding = const EdgeInsets.all(16),
    this.mainAxisSpacing = 12,
    this.crossAxisSpacing = 12,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: aspectRatio,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
        ),
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          final imageUrl = imageUrls[index];
          return OptimizedImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(12),
            enableHeroAnimation: true,
            heroTag: 'image_$index',
            onTap: onImageTap != null ? () => onImageTap!(imageUrl, index) : null,
            animationDuration: Duration(milliseconds: 300 + (index * 50)),
          ).animate()
              .fadeIn(duration: 500.ms, delay: (index * 100).ms)
              .scale(begin: const Offset(0.8, 0.8));
        },
      ),
    );
  }
}