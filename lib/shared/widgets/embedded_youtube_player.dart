import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import '../../core/constants/app_colors.dart';
import 'neon_text.dart';

/// נגן YouTube משובץ שמפעיל את הסרטון בתוך האפליקציה
class EmbeddedYouTubePlayer extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String? subtitle;
  final VoidCallback? onVideoEnded;

  const EmbeddedYouTubePlayer({
    super.key,
    required this.videoUrl,
    required this.title,
    this.subtitle,
    this.onVideoEnded,
  });

  @override
  State<EmbeddedYouTubePlayer> createState() => _EmbeddedYouTubePlayerState();
}

class _EmbeddedYouTubePlayerState extends State<EmbeddedYouTubePlayer> {
  String? _videoId;
  String? _embedUrl;
  late String _viewId;

  @override
  void initState() {
    super.initState();
    _extractVideoId();
    _setupPlayer();
  }

  void _extractVideoId() {
    try {
      // חילוץ מזהה הסרטון מכתובת YouTube
      if (widget.videoUrl.contains('youtube.com/watch?v=')) {
        _videoId = widget.videoUrl.split('watch?v=')[1].split('&')[0];
      } else if (widget.videoUrl.contains('youtu.be/')) {
        _videoId = widget.videoUrl.split('youtu.be/')[1].split('?')[0];
      }
      
      if (_videoId != null && _videoId!.isNotEmpty) {
        _embedUrl = 'https://www.youtube.com/embed/$_videoId?autoplay=0&rel=0&modestbranding=1&showinfo=0';
      }
    } catch (e) {
      print('Error extracting video ID: $e');
    }
  }

  void _setupPlayer() {
    if (_embedUrl != null) {
      _viewId = 'youtube-player-$_videoId';
      
      // יצירת iframe עבור YouTube
      final iframe = html.IFrameElement()
        ..src = _embedUrl!
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allowFullscreen = true;

      // רישום ה-iframe
      ui_web.platformViewRegistry.registerViewFactory(
        _viewId,
        (int viewId) => iframe,
      );
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
              
              // נגן YouTube משובץ
              AspectRatio(
                aspectRatio: 16 / 9,
                child: _buildEmbeddedPlayer(),
              ),
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
                'נגן YouTube משובץ',
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

  Widget _buildEmbeddedPlayer() {
    if (_embedUrl == null || _videoId == null) {
      return Container(
        color: AppColors.darkCard,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 60,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              NeonText(
                text: 'שגיאה בטעינת הסרטון',
                fontSize: 16,
                glowColor: AppColors.error,
              ),
              const SizedBox(height: 8),
              Text(
                'הקישור לא תקין',
                style: GoogleFonts.assistant(
                  color: AppColors.secondaryText,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return HtmlElementView(
      viewType: _viewId,
    );
  }
}