import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/constants/app_colors.dart';
import 'neon_text.dart';
import 'enhanced_neon_effects.dart';

/// נגן YouTube פשוט שפותח את הסרטון בדפדפן או באפליקציית YouTube
class SimpleYouTubePlayer extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String? subtitle;
  final VoidCallback? onVideoEnded;

  const SimpleYouTubePlayer({
    super.key,
    required this.videoUrl,
    required this.title,
    this.subtitle,
    this.onVideoEnded,
  });

  @override
  State<SimpleYouTubePlayer> createState() => _SimpleYouTubePlayerState();
}

class _SimpleYouTubePlayerState extends State<SimpleYouTubePlayer> {
  String? _thumbnailUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _extractThumbnail();
  }

  void _extractThumbnail() {
    try {
      // חילוץ מזהה הסרטון מכתובת YouTube
      String? videoId;
      
      if (widget.videoUrl.contains('youtube.com/watch?v=')) {
        videoId = widget.videoUrl.split('watch?v=')[1].split('&')[0];
      } else if (widget.videoUrl.contains('youtu.be/')) {
        videoId = widget.videoUrl.split('youtu.be/')[1].split('?')[0];
      }
      
      if (videoId != null && videoId.isNotEmpty) {
        setState(() {
          _thumbnailUrl = 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openVideo() async {
    try {
      final uri = Uri.parse(widget.videoUrl);
      
      // ניסיון לפתוח באפליקציית YouTube תחילה
      final youtubeUri = Uri.parse(widget.videoUrl.replaceFirst('https://www.youtube.com', 'youtube:'));
      
      if (await canLaunchUrl(youtubeUri)) {
        await launchUrl(youtubeUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('לא ניתן לפתוח את הסרטון'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה בפתיחת הסרטון: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonPink.withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: [
              // כותרת הסרטון
              _buildVideoHeader(),
              
              // תמונה ממוזערת וכפתור הפעלה
              AspectRatio(
                aspectRatio: 16 / 9,
                child: _buildThumbnailWithPlayButton(),
              ),
              
              // כפתורי פעולה
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.neonPink.withValues(alpha: 0.1),
            AppColors.neonTurquoise.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NeonText(
            text: widget.title,
            fontSize: 18,
            glowColor: AppColors.neonPink,
          ),
          if (widget.subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              widget.subtitle!,
              style: GoogleFonts.assistant(
                color: AppColors.secondaryText,
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.play_circle_outline,
                color: AppColors.neonTurquoise,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'לחץ לנגן את הסרטון',
                style: GoogleFonts.assistant(
                  color: AppColors.neonTurquoise,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnailWithPlayButton() {
    if (_isLoading) {
      return Container(
        color: AppColors.darkCard,
        child: Center(
          child: NeonGlowContainer(
            glowColor: AppColors.neonTurquoise,
            animate: true,
            child: CircularProgressIndicator(
              color: AppColors.neonTurquoise,
              strokeWidth: 3,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _openVideo,
      child: Stack(
        children: [
          // תמונה ממוזערת
          if (_thumbnailUrl != null)
            CachedNetworkImage(
              imageUrl: _thumbnailUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (context, url) => Container(
                color: AppColors.darkCard,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.neonTurquoise,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.darkCard,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.video_library,
                      size: 60,
                      color: AppColors.secondaryText,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'YouTube Video',
                      style: GoogleFonts.assistant(
                        color: AppColors.secondaryText,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              color: AppColors.darkCard,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.video_library,
                    size: 60,
                    color: AppColors.secondaryText,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'YouTube Video',
                    style: GoogleFonts.assistant(
                      color: AppColors.secondaryText,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          
          // כיסוי שקיפות
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),
          
          // כפתור הפעלה מרכזי
          Center(
            child: NeonGlowContainer(
              glowColor: AppColors.neonPink,
              animate: true,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neonPink.withValues(alpha: 0.2),
                  border: Border.all(
                    color: AppColors.neonPink,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.play_arrow,
                  color: AppColors.neonPink,
                  size: 40,
                ),
              ),
            ),
          ),
          
          // לוגו YouTube
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'YouTube',
                style: GoogleFonts.assistant(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        border: Border(
          top: BorderSide(
            color: AppColors.neonTurquoise.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.play_circle_filled,
            label: 'נגן כאן',
            onPressed: _openVideo,
            isPrimary: true,
          ),
          
          _buildActionButton(
            icon: Icons.share,
            label: 'שתף',
            onPressed: () async {
              try {
                // שיתוף הקישור
                final text = 'צפה במדריך הדאנס הזה: ${widget.videoUrl}';
                await launchUrl(
                  Uri.parse('mailto:?subject=${Uri.encodeComponent(widget.title)}&body=${Uri.encodeComponent(text)}'),
                );
              } catch (e) {
                // אם השיתוף נכשל, פשוט נתעלם
              }
            },
          ),
          
          _buildActionButton(
            icon: Icons.open_in_new,
            label: 'פתח בדפדפן',
            onPressed: () async {
              try {
                final uri = Uri.parse(widget.videoUrl);
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } catch (e) {
                // אם הפתיחה נכשלת, נראה הודעת שגיאה
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('לא ניתן לפתוח את הקישור'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return NeonGlowContainer(
      glowColor: isPrimary ? AppColors.neonPink : AppColors.neonTurquoise,
      animate: isPrimary,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPrimary 
                  ? AppColors.neonPink.withValues(alpha: 0.2)
                  : AppColors.darkSurface.withValues(alpha: 0.7),
              border: Border.all(
                color: isPrimary ? AppColors.neonPink : AppColors.neonTurquoise,
                width: 1,
              ),
            ),
            child: IconButton(
              onPressed: onPressed,
              icon: Icon(
                icon,
                color: isPrimary ? AppColors.neonPink : AppColors.primaryText,
                size: isPrimary ? 24 : 20,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.assistant(
              color: isPrimary ? AppColors.neonPink : AppColors.secondaryText,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}