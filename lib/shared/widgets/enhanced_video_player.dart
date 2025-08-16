import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import 'neon_text.dart';
import 'enhanced_neon_effects.dart';

/// נגן וידאו משופר עם בקרות מלאות לאפליקציית זזה דאנס
class EnhancedVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String? subtitle;
  final bool autoPlay;
  final bool showControls;
  final bool allowFullScreen;
  final double aspectRatio;
  final VoidCallback? onVideoEnded;
  final Function(Duration)? onProgressChanged;

  const EnhancedVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.title,
    this.subtitle,
    this.autoPlay = false,
    this.showControls = true,
    this.allowFullScreen = true,
    this.aspectRatio = 16 / 9,
    this.onVideoEnded,
    this.onProgressChanged,
  });

  @override
  State<EnhancedVideoPlayer> createState() => _EnhancedVideoPlayerState();
}

class _EnhancedVideoPlayerState extends State<EnhancedVideoPlayer>
    with TickerProviderStateMixin {
  VideoPlayerController? _controller;
  late AnimationController _controlsAnimationController;
  late Animation<double> _controlsAnimation;
  
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showControls = true;
  bool _isFullScreen = false;
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  String _selectedQuality = 'auto';
  
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadVideoQuality();
    _initializeVideo();
  }

  void _loadVideoQuality() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final quality = prefs.getString('video_quality') ?? 'auto';
      setState(() {
        _selectedQuality = quality;
      });
    } catch (e) {
      // אם יש שגיאה, נשתמש בברירת המחדל
      setState(() {
        _selectedQuality = 'auto';
      });
    }
  }

  void _setupAnimations() {
    _controlsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _controlsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controlsAnimationController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.showControls) {
      _controlsAnimationController.forward();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      
      await _controller!.initialize();
      
      _controller!.addListener(_videoListener);
      
      setState(() {
        _isInitialized = true;
        _isLoading = false;
        _duration = _controller!.value.duration;
      });

      if (widget.autoPlay) {
        await _playVideo();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'שגיאה בטעינת הווידאו: ${e.toString()}';
      });
    }
  }

  void _videoListener() {
    if (_controller == null) return;
    
    final position = _controller!.value.position;
    final duration = _controller!.value.duration;
    
    setState(() {
      _position = position;
      _duration = duration;
      _isPlaying = _controller!.value.isPlaying;
    });

    widget.onProgressChanged?.call(position);

    // בדיקה אם הווידאו הסתיים
    if (position >= duration && duration > Duration.zero) {
      widget.onVideoEnded?.call();
    }
  }

  Future<void> _playVideo() async {
    if (_controller != null && _isInitialized) {
      await _controller!.play();
      _startHideControlsTimer();
    }
  }

  Future<void> _pauseVideo() async {
    if (_controller != null && _isInitialized) {
      await _controller!.pause();
      _cancelHideControlsTimer();
    }
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _pauseVideo();
    } else {
      await _playVideo();
    }
  }

  Future<void> _seekTo(Duration position) async {
    if (_controller != null && _isInitialized) {
      await _controller!.seekTo(position);
    }
  }

  Future<void> _seekRelative(Duration delta) async {
    final newPosition = _position + delta;
    final clampedPosition = Duration(
      milliseconds: newPosition.inMilliseconds.clamp(0, _duration.inMilliseconds),
    );
    await _seekTo(clampedPosition);
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      _controlsAnimationController.forward();
      _startHideControlsTimer();
    } else {
      _controlsAnimationController.reverse();
      _cancelHideControlsTimer();
    }
  }

  void _startHideControlsTimer() {
    _cancelHideControlsTimer();
    if (_isPlaying) {
      _hideControlsTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && _isPlaying) {
          setState(() {
            _showControls = false;
          });
          _controlsAnimationController.reverse();
        }
      });
    }
  }

  void _cancelHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = null;
  }

  Future<void> _toggleFullScreen() async {
    if (widget.allowFullScreen) {
      setState(() {
        _isFullScreen = !_isFullScreen;
      });

      if (_isFullScreen) {
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
      }
    }
  }

  @override
  void dispose() {
    _cancelHideControlsTimer();
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    _controlsAnimationController.dispose();
    
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
              color: AppColors.neonPink.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _isFullScreen 
              ? _buildVideoContent()
              : AspectRatio(
                  aspectRatio: widget.aspectRatio,
                  child: _buildVideoContent(),
                ),
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    if (_hasError) {
      return _buildErrorWidget();
    }

    if (_isLoading || !_isInitialized) {
      return _buildLoadingWidget();
    }

    return GestureDetector(
      onTap: _toggleControls,
      child: Stack(
        children: [
          // נגן הווידאו
          VideoPlayer(_controller!),
          
          // כיסוי שקוף לגילוי מגע
          Positioned.fill(
            child: Container(color: Colors.transparent),
          ),
          
          // בקרות הווידאו
          if (widget.showControls)
            _buildVideoControls(),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      color: AppColors.darkBackground,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NeonGlowContainer(
              glowColor: AppColors.neonTurquoise,
              animate: true,
              child: CircularProgressIndicator(
                color: AppColors.neonTurquoise,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            NeonText(
              text: 'טוען וידאו...',
              fontSize: 16,
              glowColor: AppColors.neonTurquoise,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: AppColors.darkBackground,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: AppColors.error,
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
            NeonButton(
              text: 'נסה שוב',
              onPressed: _initializeVideo,
              glowColor: AppColors.neonTurquoise,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoControls() {
    return AnimatedBuilder(
      animation: _controlsAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _controlsAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black54,
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black87,
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: Column(
              children: [
                _buildTopControls(),
                Expanded(child: _buildCenterControls()),
                _buildBottomControls(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopControls() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
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
              ],
            ),
          ),
          if (widget.allowFullScreen)
            IconButton(
              onPressed: _toggleFullScreen,
              icon: Icon(
                _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                color: AppColors.primaryText,
                size: 28,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCenterControls() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // אחורה 10 שניות
          _buildControlButton(
            icon: Icons.replay_10,
            onPressed: () => _seekRelative(const Duration(seconds: -10)),
            tooltip: 'אחורה 10 שניות',
          ),
          
          const SizedBox(width: 30),
          
          // הפעל/השהה
          _buildControlButton(
            icon: _isPlaying ? Icons.pause : Icons.play_arrow,
            onPressed: _togglePlayPause,
            tooltip: _isPlaying ? 'השהה' : 'הפעל',
            size: 60,
            isPrimary: true,
          ),
          
          const SizedBox(width: 30),
          
          // קדימה 10 שניות
          _buildControlButton(
            icon: Icons.forward_10,
            onPressed: () => _seekRelative(const Duration(seconds: 10)),
            tooltip: 'קדימה 10 שניות',
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // פס התקדמות
          _buildProgressBar(),
          
          const SizedBox(height: 12),
          
          // זמן ובקרות נוספות
          Row(
            children: [
              Text(
                _formatDuration(_position),
                style: GoogleFonts.assistant(
                  color: AppColors.primaryText,
                  fontSize: 14,
                ),
              ),
              Text(
                ' / ',
                style: GoogleFonts.assistant(
                  color: AppColors.secondaryText,
                  fontSize: 14,
                ),
              ),
              Text(
                _formatDuration(_duration),
                style: GoogleFonts.assistant(
                  color: AppColors.secondaryText,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              // כפתורי בקרה נוספים
              IconButton(
                onPressed: _showQualitySelection,
                icon: Icon(
                  Icons.settings,
                  color: AppColors.secondaryText,
                  size: 20,
                ),
                tooltip: 'איכות וידאו: $_selectedQuality',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    double size = 45,
    bool isPrimary = false,
  }) {
    return NeonGlowContainer(
      glowColor: isPrimary ? AppColors.neonPink : AppColors.neonTurquoise,
      animate: isPrimary,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isPrimary 
              ? AppColors.neonPink.withOpacity(0.2)
              : AppColors.darkSurface.withOpacity(0.7),
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
            size: isPrimary ? 30 : 24,
          ),
          tooltip: tooltip,
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: AppColors.darkSurface,
      ),
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 4,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          activeTrackColor: AppColors.neonPink,
          inactiveTrackColor: AppColors.darkSurface,
          thumbColor: AppColors.neonPink,
          overlayColor: AppColors.neonPink.withOpacity(0.2),
        ),
        child: Slider(
          value: _duration.inMilliseconds > 0
              ? _position.inMilliseconds.toDouble()
              : 0.0,
          max: _duration.inMilliseconds.toDouble(),
          onChanged: (value) {
            _seekTo(Duration(milliseconds: value.toInt()));
          },
          onChangeStart: (value) {
            _cancelHideControlsTimer();
          },
          onChangeEnd: (value) {
            _startHideControlsTimer();
          },
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
             '${minutes.toString().padLeft(2, '0')}:'
             '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
           '${seconds.toString().padLeft(2, '0')}';
  }
}