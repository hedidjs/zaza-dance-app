import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import 'neon_text.dart';
import 'enhanced_neon_effects.dart';

/// YouTube video player widget עם עיצוב נאון לזאזא דאנס
class YouTubeVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String? subtitle;
  final bool autoPlay;
  final bool showControls;
  final bool allowFullScreen;
  final VoidCallback? onVideoEnded;
  final Function(Duration)? onProgressChanged;

  const YouTubeVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.title,
    this.subtitle,
    this.autoPlay = false,
    this.showControls = true,
    this.allowFullScreen = true,
    this.onVideoEnded,
    this.onProgressChanged,
  });

  @override
  State<YouTubeVideoPlayer> createState() => _YouTubeVideoPlayerState();
}

class _YouTubeVideoPlayerState extends State<YouTubeVideoPlayer> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    try {
      // חילוץ מזהה הסרטון מכתובת YouTube
      final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
      
      if (videoId == null) {
        setState(() {
          _hasError = true;
          _errorMessage = 'קישור YouTube לא תקין';
        });
        return;
      }

      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: YoutubePlayerFlags(
          autoPlay: widget.autoPlay,
          mute: false,
          enableCaption: true,
          captionLanguage: 'he', // כתוביות עברית אם זמינות
          loop: false,
          isLive: false,
          forceHD: false,
          showLiveFullscreenButton: widget.allowFullScreen,
        ),
      );

      _controller.addListener(_onPlayerStateChange);
      
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'שגיאה בטעינת הסרטון: $e';
      });
    }
  }

  void _onPlayerStateChange() {
    if (_controller.value.isReady) {
      setState(() {
        _isPlayerReady = true;
      });
    }

    if (_controller.value.playerState == PlayerState.ended) {
      widget.onVideoEnded?.call();
    }

    // עדכון התקדמות הסרטון
    widget.onProgressChanged?.call(_controller.value.position);
  }

  @override
  void dispose() {
    _controller.dispose();
    // איפוס הגדרות המסך
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
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
          child: _buildVideoContent(),
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    if (_hasError) {
      return _buildErrorWidget();
    }

    return Column(
      children: [
        // כותרת הסרטון
        _buildVideoHeader(),
        
        // נגן YouTube
        AspectRatio(
          aspectRatio: 16 / 9,
          child: YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: AppColors.neonPink,
            progressColors: ProgressBarColors(
              playedColor: AppColors.neonPink,
              handleColor: AppColors.neonPink,
              bufferedColor: AppColors.neonTurquoise.withValues(alpha: 0.3),
              backgroundColor: AppColors.darkSurface,
            ),
            onReady: () {
              setState(() {
                _isPlayerReady = true;
              });
            },
            onEnded: (data) {
              widget.onVideoEnded?.call();
            },
          ),
        ),
        
        // בקרות נוספות
        if (widget.showControls && _isPlayerReady)
          _buildCustomControls(),
      ],
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
                'מדריך דאנס',
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

  Widget _buildCustomControls() {
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
          _buildControlButton(
            icon: Icons.replay_10,
            label: 'אחורה',
            onPressed: () {
              final currentPosition = _controller.value.position;
              final newPosition = currentPosition - const Duration(seconds: 10);
              _controller.seekTo(
                newPosition < Duration.zero ? Duration.zero : newPosition,
              );
            },
          ),
          
          _buildControlButton(
            icon: _controller.value.playerState == PlayerState.playing 
                ? Icons.pause_circle 
                : Icons.play_circle,
            label: _controller.value.playerState == PlayerState.playing 
                ? 'השהה' 
                : 'הפעל',
            onPressed: () {
              if (_controller.value.playerState == PlayerState.playing) {
                _controller.pause();
              } else {
                _controller.play();
              }
            },
            isPrimary: true,
          ),
          
          _buildControlButton(
            icon: Icons.forward_10,
            label: 'קדימה',
            onPressed: () {
              final currentPosition = _controller.value.position;
              final videoDuration = _controller.metadata.duration;
              final newPosition = currentPosition + const Duration(seconds: 10);
              _controller.seekTo(
                newPosition > videoDuration ? videoDuration : newPosition,
              );
            },
          ),
          
          if (widget.allowFullScreen)
            _buildControlButton(
              icon: Icons.fullscreen,
              label: 'מסך מלא',
              onPressed: () {
                _controller.toggleFullScreenMode();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
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
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NeonGlowContainer(
            glowColor: AppColors.error,
            animate: true,
            child: Icon(
              Icons.error_outline,
              size: 60,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 20),
          NeonText(
            text: 'שגיאה בטעינת הווידאו',
            fontSize: 18,
            glowColor: AppColors.error,
          ),
          const SizedBox(height: 10),
          Text(
            _errorMessage ?? 'נסה שוב מאוחר יותר',
            style: GoogleFonts.assistant(
              color: AppColors.secondaryText,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          YouTubeNeonButton(
            text: 'נסה שוב',
            onPressed: () {
              setState(() {
                _hasError = false;
                _errorMessage = null;
              });
              _initializePlayer();
            },
            glowColor: AppColors.neonTurquoise,
          ),
        ],
      ),
    );
  }
}

/// כפתור נאון מותאם אישית ל-YouTube player
class YouTubeNeonButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color glowColor;

  const YouTubeNeonButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return NeonGlowContainer(
      glowColor: glowColor,
      animate: true,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: glowColor.withValues(alpha: 0.1),
          foregroundColor: glowColor,
          side: BorderSide(color: glowColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: Text(
          text,
          style: GoogleFonts.assistant(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}