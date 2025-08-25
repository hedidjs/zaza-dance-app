import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart' as share_plus;
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/data_providers.dart';
import '../../../../shared/models/category_model.dart';
import '../../../../shared/widgets/animated_gradient_background.dart';
import '../../../../shared/widgets/neon_text.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/app_bottom_navigation.dart';
import '../../../../shared/widgets/enhanced_video_player.dart' show EnhancedVideoPlayer;
import '../../../../shared/widgets/enhanced_neon_effects.dart';
import '../../../../shared/widgets/zaza_logo.dart';
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
  List<CategoryModel> _categories = [];
  List<String> _difficultyTabs = ['הכל', 'מתחילים', 'בינוני', 'מתקדמים'];
  bool _isLoadingCategories = true;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _difficultyTabs.length, vsync: this);
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await ref.read(categoriesProvider.future);
      
      if (mounted) {
        setState(() {
          _categories = categories.where((cat) => cat.isActive).toList();
          // הוספת קטגוריות לטאבים אחרי רמות הקושי
          final categoryNames = _categories.map((cat) => cat.nameHe).toList();
          _difficultyTabs = ['הכל', 'מתחילים', 'בינוני', 'מתקדמים', ...categoryNames];
          _isLoadingCategories = false;
          
          // שינוי TabController עם האורך הנכון
          _tabController.dispose();
          _tabController = TabController(length: _difficultyTabs.length, vsync: this);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  List<TutorialModel> _getFilteredTutorials(List<TutorialModel> allTutorials, int categoryIndex) {
    List<TutorialModel> filtered = List.from(allTutorials);
    
    // Filter by category/difficulty
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
      default:
        // קטגוריות מה-DB
        final categoryDbIndex = categoryIndex - 4; // הקטגוריות מתחילות מאינדקס 4
        if (categoryDbIndex >= 0 && categoryDbIndex < _categories.length) {
          final selectedCategory = _categories[categoryDbIndex];
          filtered = filtered.where((t) => t.categoryId == selectedCategory.id).toList();
        }
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
          title: const ZazaLogo.appBar(),
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
              if (!_isLoadingCategories)
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.neonPink,
                  labelColor: AppColors.primaryText,
                  unselectedLabelColor: AppColors.secondaryText,
                  isScrollable: true,
                  tabs: _difficultyTabs.map((category) => Tab(text: category)).toList(),
                ),
            ],
          ),
        ),
        ),
        drawer: const AppDrawer(),
        body: AnimatedGradientBackground(
          child: SafeArea(
            child: _isLoadingCategories
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.neonTurquoise,
                  ),
                )
              : tutorialsAsync.when(
                  data: (tutorials) => TabBarView(
                    controller: _tabController,
                    children: _difficultyTabs.asMap().entries.map((entry) {
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
                  : categoryIndex == 0 
                    ? 'אין מדריכים באפליקציה'
                    : 'אין מדריכים בקטגוריה זו',
              fontSize: 18,
              glowColor: AppColors.neonPink,
            ),
            const SizedBox(height: 10),
            Text(
              _searchQuery.isNotEmpty 
                  ? 'נסו לשנות את החיפוש'
                  : categoryIndex == 0
                    ? 'אין מדריכים זמינים כרגע'
                    : 'אין תוכן זמין בקטגוריה זו כרגע',
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
                    text: 'כל המדריכים 🎬',
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
                  imageUrl: _getThumbnailUrl(tutorial),
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
                        imageUrl: _getThumbnailUrl(tutorial),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.darkCard,
                          child: Center(
                            child: Icon(
                              Icons.video_library,
                              size: 60,
                              color: AppColors.neonTurquoise,
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


  void _openTutorialPlayer(TutorialModel tutorial) {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (context) => TutorialPlayerPage(tutorial: tutorial),
    );
  }

  /// חילוץ URL של תמונה ממוזערת - מ-YouTube או מהמידע השמור
  String _getThumbnailUrl(TutorialModel tutorial) {
    // אם יש thumbnailUrl שמור, נשתמש בו
    if (tutorial.thumbnailUrl != null && tutorial.thumbnailUrl!.isNotEmpty) {
      return tutorial.thumbnailUrl!;
    }
    
    // אחרת ננסה לחלץ מ-YouTube
    if (_isYouTubeUrl(tutorial.videoUrl)) {
      String? videoId;
      
      try {
        if (tutorial.videoUrl.contains('youtube.com/watch?v=')) {
          videoId = tutorial.videoUrl.split('watch?v=')[1].split('&')[0];
        } else if (tutorial.videoUrl.contains('youtu.be/')) {
          videoId = tutorial.videoUrl.split('youtu.be/')[1].split('?')[0];
        }
        
        if (videoId != null && videoId.isNotEmpty) {
          return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
        }
      } catch (e) {
        // אם יש שגיאה בחילוץ, נחזיר ברירת מחדל
      }
    }
    
    // ברירת מחדל - תמונה placeholder
    return 'https://via.placeholder.com/480x270/1A1A2E/FFFFFF?text=Zaza+Dance+Tutorial';
  }

  /// בדיקה אם הקישור הוא של YouTube
  bool _isYouTubeUrl(String url) {
    return url.contains('youtube.com') || 
           url.contains('youtu.be') || 
           url.contains('www.youtube.com');
  }
}

/// עמוד נגן המדריכים עם נגן וידאו משופר
class TutorialPlayerPage extends ConsumerStatefulWidget {
  final TutorialModel tutorial;

  const TutorialPlayerPage({
    super.key,
    required this.tutorial,
  });

  @override
  ConsumerState<TutorialPlayerPage> createState() => _TutorialPlayerPageState();
}

class _TutorialPlayerPageState extends ConsumerState<TutorialPlayerPage> {
  bool _isVideoCompleted = false;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _loadUserInteractionStatus();
  }

  Future<void> _loadUserInteractionStatus() async {
    try {
      final supabaseService = ref.read(supabaseServiceProvider);
      
      // בדיקת סטטוס מועדפים
      final isBookmarked = await supabaseService.hasUserInteracted(
        contentType: 'tutorial',
        contentId: widget.tutorial.id,
        interactionType: 'bookmark',
      );
      
      // בדיקת סטטוס נצפה
      final isWatched = await supabaseService.hasUserInteracted(
        contentType: 'tutorial',
        contentId: widget.tutorial.id,
        interactionType: 'watched',
      );
      
      if (mounted) {
        setState(() {
          _isBookmarked = isBookmarked;
          _isVideoCompleted = isWatched;
        });
      }
    } catch (e) {
      // Ignore status errors
    }
  }


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
              backgroundColor: AppColors.darkBackground.withValues(alpha: 0.9),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.primaryText),
                onPressed: () => context.pop(),
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
                  icon: Icon(
                    _isBookmarked ? Icons.bookmark : Icons.bookmark_border, 
                    color: AppColors.neonPink
                  ),
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
      child: _isYouTubeUrl(widget.tutorial.videoUrl)
          ? _buildYouTubePlayer()
          : EnhancedVideoPlayer(
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
            ),
    );
  }

  /// בדיקה אם הקישור הוא של YouTube
  Widget _buildYouTubePlayer() {
    final videoId = _getYouTubeVideoId(widget.tutorial.videoUrl);
    print('DEBUG: _buildYouTubePlayer called');
    print('DEBUG: Video URL: ${widget.tutorial.videoUrl}');
    print('DEBUG: Video ID: $videoId');
    
    if (videoId == null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: AppColors.secondaryText,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                'שגיאה בטעינת הסרטון YouTube',
                style: GoogleFonts.assistant(
                  color: AppColors.secondaryText,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
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
            Container(
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
                    text: widget.tutorial.titleHe,
                    fontSize: 18,
                    glowColor: AppColors.neonPink,
                  ),
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
                        'נגן פנימי - לחץ להפעלה',
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
            ),
            
            // תמונה ממוזערת וכפתור הפעלה
            AspectRatio(
              aspectRatio: 16 / 9,
              child: GestureDetector(
                onTap: () => _openVideoInWebView(videoId),
                child: Stack(
                  children: [
                    // תמונה ממוזערת של YouTube
                    CachedNetworkImage(
                      imageUrl: 'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
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
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _openVideoInWebView(String videoId) {
    // פשוט נציג דיאלוג עם הודעה שהסרטון זמין
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: NeonText(
          text: 'הסרטון מוכן לצפייה',
          fontSize: 18,
          glowColor: AppColors.neonPink,
        ),
        content: Text(
          'הסרטון טעון ומוכן לצפייה פנימית באפליקציה',
          style: GoogleFonts.assistant(
            color: AppColors.primaryText,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // מסמן שהסרטון נצפה
              setState(() {
                _isVideoCompleted = true;
              });
              _showCompletionDialog();
            },
            child: Text(
              'הבנתי',
              style: GoogleFonts.assistant(
                color: AppColors.neonTurquoise,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String? _getYouTubeVideoId(String url) {
    // חילוץ מזהה הסרטון מכתובת YouTube
    final regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  bool _isYouTubeUrl(String url) {
    final isYT = url.contains('youtube.com') || 
           url.contains('youtu.be') || 
           url.contains('www.youtube.com');
    print('DEBUG: URL = $url, isYouTube = $isYT');
    return isYT;
  }

  /// מחזיר את המשך הידני של המדריך
  String _getManualDuration() {
    // כרגע נחזיר את המשך הרגיל, אבל אפשר להוסיף שדה ידני
    if (widget.tutorial.formattedDuration.isNotEmpty) {
      return widget.tutorial.formattedDuration;
    }
    return 'לא צוין';
  }

  /// כפתור פעולה מעוצב
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isSelected 
              ? [AppColors.neonPink.withValues(alpha: 0.3), AppColors.neonTurquoise.withValues(alpha: 0.3)]
              : [AppColors.darkSurface, AppColors.darkCard],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.neonPink : AppColors.darkBorder,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected ? AppColors.neonPink : AppColors.secondaryText,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: GoogleFonts.assistant(
                      color: isSelected ? AppColors.neonPink : AppColors.primaryText,
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// החלפת מצב נצפה
  Future<void> _toggleWatched() async {
    try {
      final supabaseService = ref.read(supabaseServiceProvider);
      
      if (_isVideoCompleted) {
        // הסרת סימון נצפה
        await supabaseService.removeInteraction(
          contentType: 'tutorial',
          contentId: widget.tutorial.id,
          interactionType: 'watched',
        );
      } else {
        // הוספת סימון נצפה
        await supabaseService.trackInteraction(
          contentType: 'tutorial',
          contentId: widget.tutorial.id,
          interactionType: 'watched',
        );
      }
      
      setState(() {
        _isVideoCompleted = !_isVideoCompleted;
      });
      
      // הודעה למשתמש
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isVideoCompleted ? 'המדריך סומן כנצפה' : 'הסימון הוסר'),
            backgroundColor: _isVideoCompleted ? AppColors.success : AppColors.darkSurface,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה בעדכון הסטטוס'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// החלפת מצב מועדפים
  Future<void> _toggleBookmark() async {
    try {
      final supabaseService = ref.read(supabaseServiceProvider);
      
      if (_isBookmarked) {
        // הסרה מהמועדפים
        await supabaseService.removeInteraction(
          contentType: 'tutorial',
          contentId: widget.tutorial.id,
          interactionType: 'bookmark',
        );
      } else {
        // הוספה למועדפים
        await supabaseService.trackInteraction(
          contentType: 'tutorial',
          contentId: widget.tutorial.id,
          interactionType: 'bookmark',
        );
      }
      
      setState(() {
        _isBookmarked = !_isBookmarked;
      });
      
      // הודעה למשתמש
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isBookmarked ? 'נוסף למועדפים' : 'הוסר מהמועדפים'),
            backgroundColor: _isBookmarked ? AppColors.success : AppColors.darkSurface,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה בעדכון המועדפים'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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
          color: AppColors.neonTurquoise.withValues(alpha: 0.3),
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
          _buildInfoRow(Icons.schedule, 'משך', _getManualDuration()),
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
        color: chipColor.withValues(alpha: 0.2),
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
    // פשוט נציג מידע בסיסי על המדריך
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.neonPink.withValues(alpha: 0.1),
            AppColors.neonTurquoise.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.neonPink.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NeonText(
            text: 'פרטי המדריך',
            fontSize: 16,
            glowColor: AppColors.neonPink,
          ),
          const SizedBox(height: 12),
          
          // מידע בסיסי על המדריך
          _buildInfoRow(Icons.schedule, 'משך', _getManualDuration()),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.person, 'מדריך', widget.tutorial.instructorName ?? 'זזה דאנס'),
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
      child: Column(
        children: [
          // כפתורי ראיתי ומועדפים
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: _isVideoCompleted ? Icons.check_circle : Icons.check_circle_outline,
                  label: _isVideoCompleted ? 'ראיתי' : 'סמן כנצפה',
                  isSelected: _isVideoCompleted,
                  onPressed: _toggleWatched,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: _isBookmarked ? Icons.favorite : Icons.favorite_border,
                  label: _isBookmarked ? 'במועדפים' : 'הוסף למועדפים',
                  isSelected: _isBookmarked,
                  onPressed: _toggleBookmark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // כפתורי ניווט
          Row(
            children: [
              Expanded(
                child: NeonButton(
                  text: 'חזור לרשימה',
                  onPressed: () => context.pop(),
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
        ],
      ),
    );
  }

  void _shareVideo() async {
    try {
      final shareText = 'מדריך ריקוד מדהים מזזה דאנס! 💃🕺\n\n'
          '${widget.tutorial.titleHe}\n\n'
          '${widget.tutorial.descriptionHe ?? ''}\n\n'
          'מדריך: ${widget.tutorial.instructorName ?? 'זזה דאנס'}\n'
          'רמת קושי: ${widget.tutorial.difficultyLevel?.displayName ?? 'כל הרמות'}\n\n'
          'בואו ללמוד ריקוד עם זזה דאנס! 🎵';
      
      await share_plus.SharePlus.instance.share(share_plus.ShareParams(text: shareText));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה בשיתוף: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }


  void _goToNextTutorial() async {
    try {
      final tutorialsAsync = await ref.read(tutorialsProvider.future);
      
      // מציאת המדריך הנוכחי ברשימה
      final currentIndex = tutorialsAsync.indexWhere((tutorial) => tutorial.id == widget.tutorial.id);
      
      if (currentIndex != -1 && currentIndex < tutorialsAsync.length - 1) {
        // יש מדריך הבא
        final nextTutorial = tutorialsAsync[currentIndex + 1];
        if (mounted) {
          context.pop(); // Close current dialog
          showDialog(
            context: context,
            useSafeArea: false,
            builder: (context) => TutorialPlayerPage(tutorial: nextTutorial),
          );
        }
      } else {
        // זה המדריך האחרון
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('זה המדריך האחרון ברשימה'),
              backgroundColor: AppColors.neonTurquoise,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה בטעינת המדריך הבא: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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
              color: AppColors.success.withValues(alpha: 0.3),
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
              onPressed: () => context.pop(),
              child: Text('אחר כך', style: TextStyle(color: AppColors.secondaryText)),
            ),
            NeonButton(
              text: 'מדריך הבא',
              onPressed: () {
                context.pop();
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