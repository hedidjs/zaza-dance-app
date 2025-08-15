import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/animated_gradient_background.dart';
import '../../../../shared/widgets/neon_text.dart';
import '../../../../shared/models/tutorial_model.dart';

class TutorialsPage extends StatefulWidget {
  const TutorialsPage({super.key});

  @override
  State<TutorialsPage> createState() => _TutorialsPageState();
}

class _TutorialsPageState extends State<TutorialsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  VideoPlayerController? _videoController;
  String _searchQuery = '';
  DifficultyLevel _selectedDifficulty = DifficultyLevel.all;
  
  // Mock data - בעתיד יחובר ל-Supabase
  final List<TutorialModel> _allTutorials = [
    TutorialModel(
      id: '1',
      title: 'בסיסי - צעדי היפ הופ ראשונים',
      description: 'למדו את הצעדים הבסיסיים של ההיפ הופ. מתאים למתחילים לחלוטין.',
      instructor: 'רון המדריך',
      videoUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
      thumbnailUrl: 'https://picsum.photos/400/300?random=1',
      duration: const Duration(minutes: 15, seconds: 30),
      difficulty: DifficultyLevel.beginner,
      danceStyle: 'היפ הופ בסיסי',
      isDownloaded: false,
      downloadProgress: 0.0,
      viewCount: 1250,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    TutorialModel(
      id: '2',
      title: 'פופינג ולוקינג - טכניקות מתקדמות',
      description: 'שלבו תנועות פופינג ולוקינג מרהיבות בכוריאוגרפיה שלכם.',
      instructor: 'מיה המדריכה',
      videoUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_2mb.mp4',
      thumbnailUrl: 'https://picsum.photos/400/300?random=2',
      duration: const Duration(minutes: 22, seconds: 45),
      difficulty: DifficultyLevel.advanced,
      danceStyle: 'פופינג ולוקינג',
      isDownloaded: true,
      downloadProgress: 1.0,
      viewCount: 890,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    TutorialModel(
      id: '3',
      title: 'ברייקדאנס - סיבובים וכוח',
      description: 'התחילו את המסע שלכם בעולם הברייקדאנס עם תנועות כוח בסיסיות.',
      instructor: 'דני המדריך',
      videoUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_5mb.mp4',
      thumbnailUrl: 'https://picsum.photos/400/300?random=3',
      duration: const Duration(minutes: 18, seconds: 20),
      difficulty: DifficultyLevel.intermediate,
      danceStyle: 'ברייקדאנס',
      isDownloaded: false,
      downloadProgress: 0.0,
      viewCount: 2100,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    TutorialModel(
      id: '4',
      title: 'כוריאוגרפיה מלאה - רמיקס 2024',
      description: 'כוריאוגרפיה מלאה לשיר פופולרי. מתאים לרמה בינונית.',
      instructor: 'שרה המדריכה',
      videoUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
      thumbnailUrl: 'https://picsum.photos/400/300?random=4',
      duration: const Duration(minutes: 12, seconds: 15),
      difficulty: DifficultyLevel.intermediate,
      danceStyle: 'כוריאוגרפיה',
      isDownloaded: false,
      downloadProgress: 0.6,
      viewCount: 3450,
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    TutorialModel(
      id: '5',
      title: 'סטייל וביטוי - מצאו את הקול שלכם',
      description: 'פתחו את הסטייל האישי שלכם ותביעו אישיות בריקוד.',
      instructor: 'אלכס המדריך',
      videoUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_2mb.mp4',
      thumbnailUrl: 'https://picsum.photos/400/300?random=5',
      duration: const Duration(minutes: 25, seconds: 0),
      difficulty: DifficultyLevel.beginner,
      danceStyle: 'סטייל אישי',
      isDownloaded: true,
      downloadProgress: 1.0,
      viewCount: 1780,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

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

  List<TutorialModel> _getFilteredTutorials(int categoryIndex) {
    List<TutorialModel> filtered = _allTutorials;
    
    // Filter by category
    switch (categoryIndex) {
      case 0: // הכל
        break;
      case 1: // מתחילים
        filtered = filtered.where((t) => t.difficulty == DifficultyLevel.beginner).toList();
        break;
      case 2: // בינוני
        filtered = filtered.where((t) => t.difficulty == DifficultyLevel.intermediate).toList();
        break;
      case 3: // מתקדמים
        filtered = filtered.where((t) => t.difficulty == DifficultyLevel.advanced).toList();
        break;
      case 4: // כוריאוגרפיה
        filtered = filtered.where((t) => t.danceStyle.contains('כוריאוגרפיה')).toList();
        break;
      case 5: // ברייקדאנס
        filtered = filtered.where((t) => t.danceStyle.contains('ברייקדאנס')).toList();
        break;
      case 6: // פופינג
        filtered = filtered.where((t) => t.danceStyle.contains('פופינג')).toList();
        break;
    }
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((tutorial) =>
        tutorial.title.contains(_searchQuery) ||
        tutorial.description.contains(_searchQuery) ||
        tutorial.instructor.contains(_searchQuery) ||
        tutorial.danceStyle.contains(_searchQuery)
      ).toList();
    }
    
    // Sort by creation date (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: NeonText(
          text: 'מדריכי ריקוד',
          fontSize: 24,
          glowColor: AppColors.neonPink,
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
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: TabBarView(
            controller: _tabController,
            children: categories.asMap().entries.map((entry) {
              final categoryIndex = entry.key;
              return _buildTutorialsGrid(categoryIndex);
            }).toList(),
          ),
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

  Widget _buildTutorialsGrid(int categoryIndex) {
    final tutorials = _getFilteredTutorials(categoryIndex);
    
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
                  imageUrl: tutorial.thumbnailUrl,
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
                      text: tutorial.title,
                      fontSize: 18,
                      glowColor: AppColors.neonTurquoise,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${tutorial.instructor} • ${tutorial.formattedDuration}',
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
                        imageUrl: tutorial.thumbnailUrl,
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
                    
                    // Download status
                    if (tutorial.isDownloaded || tutorial.downloadProgress > 0)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: tutorial.isDownloaded 
                                ? AppColors.neonTurquoise.withValues(alpha: 0.8)
                                : Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: tutorial.isDownloaded
                              ? Icon(
                                  Icons.download_done,
                                  color: AppColors.primaryText,
                                  size: 16,
                                )
                              : SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    value: tutorial.downloadProgress,
                                    color: AppColors.neonTurquoise,
                                    strokeWidth: 2,
                                  ),
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
                          color: tutorial.difficultyColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: tutorial.difficultyColor.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          tutorial.difficultyText,
                          style: TextStyle(
                            color: tutorial.difficultyColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Title
                      Expanded(
                        child: Text(
                          tutorial.title,
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
                              tutorial.instructor,
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
                            tutorial.formattedViewCount,
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

  void _openTutorialPlayer(TutorialModel tutorial) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TutorialPlayerPage(tutorial: tutorial),
      ),
    );
  }
}

// Tutorial Player Page (placeholder for now)
class TutorialPlayerPage extends StatelessWidget {
  final TutorialModel tutorial;

  const TutorialPlayerPage({
    super.key,
    required this.tutorial,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          tutorial.title,
          style: TextStyle(color: AppColors.primaryText),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_filled,
              size: 100,
              color: AppColors.neonPink,
            ),
            const SizedBox(height: 20),
            NeonText(
              text: 'נגן וידאו',
              fontSize: 24,
              glowColor: AppColors.neonTurquoise,
            ),
            const SizedBox(height: 10),
            Text(
              'יחובר לנגן וידאו אמיתי בעתיד',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}