import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/data_providers.dart';
import '../../../../shared/widgets/animated_gradient_background.dart';
import '../../../../shared/widgets/neon_text.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/app_bottom_navigation.dart';
import '../../../../shared/widgets/enhanced_video_player.dart';
import '../../../../shared/widgets/enhanced_neon_effects.dart';
import '../../../../shared/models/tutorial_model.dart';

class TutorialsPage extends ConsumerStatefulWidget {
  const TutorialsPage({super.key});

  @override
  ConsumerState<TutorialsPage> createState() => _TutorialsPageState();
}

class _TutorialsPageState extends ConsumerState<TutorialsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  VideoPlayerController? _videoController;
  String _searchQuery = '';
  DifficultyLevel _selectedDifficulty = DifficultyLevel.beginner;

  List<String> get categories => [
    'הכל',
    'מתחילים',
    'בינוני',
    'מתקדמים',
    'כוריאוגרפיה',
    'ברייקדאנס',
    'פופינג',
  ];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  List<TutorialModel> _getFilteredTutorials(List<TutorialModel> allTutorials, int categoryIndex) {
    List<TutorialModel> filtered = List.from(allTutorials);
    
    // Filter by category
    switch (categoryIndex) {
      case 0: // הכל
        break;
      case 1: // מתחילים
        filtered = filtered.where((t) => t.difficultyLevel == DifficultyLevel.beginner).toList();
        break;
      case 2: // בינוני
        filtered = filtered.where((t) => t.difficultyLevel == DifficultyLevel.intermediate).toList();
        break;
      case 3: // מתקדמים
        filtered = filtered.where((t) => t.difficultyLevel == DifficultyLevel.advanced).toList();
        break;
      case 4: // כוריאוגרפיה
        filtered = filtered.where((t) => t.titleHe.contains('כוריאוגרפיה')).toList();
        break;
      case 5: // ברייקדאנס
        filtered = filtered.where((t) => t.titleHe.contains('ברייקדאנס')).toList();
        break;
      case 6: // פופינג
        filtered = filtered.where((t) => t.titleHe.contains('פופינג')).toList();
        break;
    }
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((tutorial) =>
        tutorial.titleHe.contains(_searchQuery) ||
        (tutorial.descriptionHe != null && tutorial.descriptionHe!.contains(_searchQuery)) ||
        (tutorial.instructorName != null && tutorial.instructorName!.contains(_searchQuery))
      ).toList();
    }
    
    // Sort by creation date (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final tutorialsAsync = ref.watch(tutorialsProvider);
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: NeonText(
            text: 'מדריכי ריקוד',
            fontSize: 24,
            glowColor: AppColors.neonPink,
          ),
          leading: Builder(
            builder: (context) => IconButton(
              icon: GlowIcon(
                Icons.menu,
                color: AppColors.primaryText,
                glowColor: AppColors.neonTurquoise,
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildSearchBar(),
              ),
              // Tabs
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.neonPink,
                labelColor: AppColors.primaryText,
                unselectedLabelColor: AppColors.secondaryText,
                isScrollable: true,
                tabs: categories.map((category) => Tab(text: category)).toList(),
              ),
            ],
          ),
        ),
        ),
        drawer: const AppDrawer(),
        body: AnimatedGradientBackground(
          child: SafeArea(
            child: tutorialsAsync.when(
              data: (tutorials) => TabBarView(
                controller: _tabController,
                children: categories.asMap().entries.map((entry) {
                  final categoryIndex = entry.key;
                  return _buildTutorialsGrid(tutorials, categoryIndex);
                }).toList(),
              ),
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: AppColors.neonTurquoise,
                ),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 80,
                      color: AppColors.secondaryText,
                    ),
                    const SizedBox(height: 20),
                    NeonText(
                      text: 'שגיאה בטעינת המדריכים',
                      fontSize: 18,
                      glowColor: AppColors.neonPink,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'אנא נסו שוב מאוחר יותר',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: const AppBottomNavigation(
          currentPage: NavigationPage.tutorials,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.cardGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AppColors.neonTurquoise.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: TextField(
        style: TextStyle(color: AppColors.primaryText),
        decoration: InputDecoration(
          hintText: 'חפשו מדריכים...',
          hintStyle: TextStyle(color: AppColors.secondaryText),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.neonTurquoise,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: AppColors.secondaryText,
                  ),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildTutorialsGrid(List<TutorialModel> allTutorials, int categoryIndex) {
    final tutorials = _getFilteredTutorials(allTutorials, categoryIndex);
    
    if (tutorials.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 80,
              color: AppColors.secondaryText,
            ),
            const SizedBox(height: 20),
            NeonText(
              text: _searchQuery.isNotEmpty 
                  ? 'לא נמצאו מדריכים'
                  : 'אין מדריכים בקטגוריה זו',
              fontSize: 18,
              glowColor: AppColors.neonPink,
            ),
            const SizedBox(height: 10),
            Text(
              _searchQuery.isNotEmpty 
                  ? 'נסו לשנות את החיפוש'
                  : 'מדריכים חדשים יתווספו בקרוב',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CustomScrollView(
        slivers: [
          // Featured tutorial section (only on "הכל" tab)
          if (categoryIndex == 0 && _searchQuery.isEmpty) ...[
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NeonText(
                    text: 'מדריך מומלץ',
                    fontSize: 20,
                    glowColor: AppColors.neonPink,
                  ),
                  const SizedBox(height: 16),
                  _buildFeaturedTutorial(tutorials.first),
                  const SizedBox(height: 30),
                  NeonText(
                    text: 'כל המדריכים',
                    fontSize: 20,
                    glowColor: AppColors.neonTurquoise,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
          
          // Grid of tutorials
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final startIndex = (categoryIndex == 0 && _searchQuery.isEmpty) ? 1 : 0;
                final tutorial = tutorials[startIndex + index];
                return _buildTutorialCard(tutorial, index);
              },
              childCount: tutorials.length - ((categoryIndex == 0 && _searchQuery.isEmpty) ? 1 : 0),
            ),
          ),
          
          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedTutorial(TutorialModel tutorial) {
    return GestureDetector(
      onTap: () => _openTutorialPlayer(tutorial),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: AppColors.cardGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: AppColors.neonPink.withValues(alpha: 0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonPink.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Background image
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: tutorial.thumbnailUrl ?? '',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.darkCard,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.neonTurquoise,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Play button
              Center(
                child: GlowIcon(
                  Icons.play_circle_filled,
                  color: AppColors.primaryText,
                  glowColor: AppColors.neonPink,
                  size: 60,
                ),
              ),
              
              // Content
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.neonPink.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.neonPink.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        'מומלץ',
                        style: TextStyle(
                          color: AppColors.neonPink,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    NeonText(
                      text: tutorial.titleHe,
                      fontSize: 18,
                      glowColor: AppColors.neonTurquoise,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${tutorial.instructorName ?? 'מדריך לא ידוע'} • ${tutorial.formattedDuration}',
                      style: TextStyle(
                        color: AppColors.primaryText.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3),
    );
  }

  Widget _buildTutorialCard(TutorialModel tutorial, int index) {
    return GestureDetector(
      onTap: () => _openTutorialPlayer(tutorial),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: AppColors.cardGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: AppColors.neonTurquoise.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonTurquoise.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CachedNetworkImage(
                        imageUrl: tutorial.thumbnailUrl ?? '',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.darkCard,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.neonTurquoise,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Duration overlay
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tutorial.formattedDuration,
                          style: TextStyle(
                            color: AppColors.primaryText,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    // Featured badge
                    if (tutorial.isFeatured)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.neonPink.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.star,
                            color: AppColors.primaryText,
                            size: 16,
                          ),
                        ),
                      ),
                    
                    // Play button overlay
                    Center(
                      child: GlowIcon(
                        Icons.play_circle_filled,
                        color: AppColors.primaryText,
                        glowColor: AppColors.neonTurquoise,
                        size: 36,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Difficulty badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(tutorial.difficultyLevel ?? DifficultyLevel.beginner).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getDifficultyColor(tutorial.difficultyLevel ?? DifficultyLevel.beginner).withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          (tutorial.difficultyLevel ?? DifficultyLevel.beginner).displayName,
                          style: TextStyle(
                            color: _getDifficultyColor(tutorial.difficultyLevel ?? DifficultyLevel.beginner),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Title
                      Expanded(
                        child: Text(
                          tutorial.titleHe,
                          style: TextStyle(
                            color: AppColors.primaryText,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Instructor and views
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              tutorial.instructorName ?? 'מדריך לא ידוע',
                              style: TextStyle(
                                color: AppColors.secondaryText,
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.remove_red_eye,
                            color: AppColors.secondaryText,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            _formatViewCount(tutorial.viewsCount),
                            style: TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 500.ms, delay: (index * 100).ms).scale(begin: const Offset(0.8, 0.8)),
    );
  }

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return const Color(0xFF4CAF50); // Green
      case DifficultyLevel.intermediate:
        return const Color(0xFFFF9800); // Orange
      case DifficultyLevel.advanced:
        return const Color(0xFFF44336); // Red
    }
  }

  String _formatViewCount(int viewCount) {
    if (viewCount >= 1000000) {
      return '${(viewCount / 1000000).toStringAsFixed(1)}M';
    } else if (viewCount >= 1000) {
      return '${(viewCount / 1000).toStringAsFixed(1)}K';
    } else {
      return viewCount.toString();
    }
  }

  void _openTutorialPlayer(TutorialModel tutorial) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TutorialPlayerPage(tutorial: tutorial),
      ),
    );
  }
}

/// עמוד נגן המדריכים עם נגן וידאו משופר
class TutorialPlayerPage extends StatefulWidget {
  final TutorialModel tutorial;

  const TutorialPlayerPage({
    super.key,
    required this.tutorial,
  });

  @override
  State<TutorialPlayerPage> createState() => _TutorialPlayerPageState();
}

class _TutorialPlayerPageState extends State<TutorialPlayerPage> {
  bool _isVideoCompleted = false;
  Duration _watchedDuration = Duration.zero;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: CustomScrollView(
          slivers: [
            // AppBar עם רקע שקוף
            SliverAppBar(
              expandedHeight: 60,
              floating: true,
              pinned: true,
              backgroundColor: AppColors.darkBackground.withOpacity(0.9),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.primaryText),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                widget.tutorial.titleHe,
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.share, color: AppColors.neonTurquoise),
                  onPressed: _shareVideo,
                ),
                IconButton(
                  icon: Icon(Icons.bookmark_border, color: AppColors.neonPink),
                  onPressed: _toggleBookmark,
                ),
              ],
            ),
            
            // תוכן העמוד
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // נגן הוידאו
                  _buildVideoPlayer(),
                  
                  const SizedBox(height: 20),
                  
                  // פרטי המדריך
                  _buildTutorialInfo(),
                  
                  const SizedBox(height: 20),
                  
                  // סטטיסטיקות התקדמות
                  _buildProgressStats(),
                  
                  const SizedBox(height: 20),
                  
                  // תיאור המדריך
                  _buildDescription(),
                  
                  const SizedBox(height: 20),
                  
                  // פעולות נוספות
                  _buildActionButtons(),
                  
                  const SizedBox(height: 100), // מקום לניווט תחתון
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: const AppBottomNavigation(
          currentPage: NavigationPage.tutorials,
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: EnhancedVideoPlayer(
        videoUrl: widget.tutorial.videoUrl,
        title: widget.tutorial.titleHe,
        subtitle: 'מדריך: ${widget.tutorial.instructorName ?? "לא ידוע"}',
        autoPlay: false,
        showControls: true,
        allowFullScreen: true,
        onVideoEnded: () {
          setState(() {
            _isVideoCompleted = true;
          });
          _showCompletionDialog();
        },
        onProgressChanged: (position) {
          setState(() {
            _watchedDuration = position;
          });
        },
      ),
    );
  }

  Widget _buildTutorialInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.cardGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.neonTurquoise.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: NeonText(
                  text: widget.tutorial.titleHe,
                  fontSize: 20,
                  glowColor: AppColors.neonPink,
                ),
              ),
              _buildDifficultyChip(),
            ],
          ),
          const SizedBox(height: 12),
          
          // פרטי המדריך
          _buildInfoRow(Icons.person, 'מדריך', widget.tutorial.instructorName ?? 'לא ידוע'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.timer, 'משך', '${widget.tutorial.duration} דקות'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.visibility, 'צפיות', '${widget.tutorial.viewsCount}'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.thumb_up, 'אהבו', '${widget.tutorial.likesCount}'),
        ],
      ),
    );
  }

  Widget _buildDifficultyChip() {
    Color chipColor;
    String difficultyText;
    
    switch (widget.tutorial.difficultyLevel) {
      case DifficultyLevel.beginner:
        chipColor = AppColors.success;
        difficultyText = 'מתחילים';
        break;
      case DifficultyLevel.intermediate:
        chipColor = AppColors.warning;
        difficultyText = 'בינוניים';
        break;
      case DifficultyLevel.advanced:
        chipColor = AppColors.error;
        difficultyText = 'מתקדמים';
        break;
      default:
        chipColor = AppColors.secondaryText;
        difficultyText = 'לא ידוע';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor, width: 1),
      ),
      child: Text(
        difficultyText,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.neonTurquoise, size: 16),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: AppColors.secondaryText,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressStats() {
    if (_watchedDuration == Duration.zero) return const SizedBox.shrink();
    
    final totalDuration = Duration(minutes: widget.tutorial.duration);
    final progressPercent = totalDuration.inSeconds > 0
        ? (_watchedDuration.inSeconds / totalDuration.inSeconds * 100)
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.neonPink.withOpacity(0.1),
            AppColors.neonTurquoise.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.neonPink.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NeonText(
            text: 'התקדמות הצפייה',
            fontSize: 16,
            glowColor: AppColors.neonPink,
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progressPercent / 100,
                  backgroundColor: AppColors.darkSurface,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.neonPink),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${progressPercent.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          if (_isVideoCompleted)
            Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 16),
                const SizedBox(width: 8),
                Text(
                  'המדריך הושלם!',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NeonText(
            text: 'תיאור המדריך',
            fontSize: 16,
            glowColor: AppColors.neonTurquoise,
          ),
          const SizedBox(height: 12),
          Text(
            widget.tutorial.description,
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: NeonButton(
              text: 'חזור לרשימה',
              onPressed: () => Navigator.pop(context),
              glowColor: AppColors.neonTurquoise,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: NeonButton(
              text: 'מדריך הבא',
              onPressed: _goToNextTutorial,
              glowColor: AppColors.neonPink,
            ),
          ),
        ],
      ),
    );
  }

  void _shareVideo() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('שיתוף המדריך בקרוב'),
        backgroundColor: AppColors.neonTurquoise,
      ),
    );
  }

  void _toggleBookmark() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('נשמר לסימניות'),
        backgroundColor: AppColors.neonPink,
      ),
    );
  }

  void _goToNextTutorial() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('מדריך הבא בקרוב'),
        backgroundColor: AppColors.neonPink,
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: AppColors.success.withOpacity(0.3),
              width: 1,
            ),
          ),
          title: Row(
            children: [
              Icon(Icons.celebration, color: AppColors.success),
              const SizedBox(width: 8),
              NeonText(
                text: 'כל הכבוד!',
                fontSize: 20,
                glowColor: AppColors.success,
              ),
            ],
          ),
          content: Text(
            'סיימת לצפות במדריך!\nמוכן למדריך הבא?',
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('אחר כך', style: TextStyle(color: AppColors.secondaryText)),
            ),
            NeonButton(
              text: 'מדריך הבא',
              onPressed: () {
                Navigator.of(context).pop();
                _goToNextTutorial();
              },
              glowColor: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }
}