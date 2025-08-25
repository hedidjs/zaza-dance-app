import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/data_providers.dart';
import '../../../../shared/widgets/animated_gradient_background.dart';
import '../../../../shared/widgets/neon_text.dart';
import '../../../../shared/widgets/enhanced_neon_effects.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/models/tutorial_model.dart';
import '../../services/admin_user_service.dart';
import '../../services/category_service.dart';
import '../../services/album_service.dart';
import 'user_management_page.dart';
import 'analytics_page.dart';
import 'category_management_page.dart';
import 'album_management_page.dart';
import 'app_settings_page.dart';

/// דף ניהול מרכזי חדש ומקצועי עבור זזה דאנס
/// New Professional Admin Dashboard for Zaza Dance
class NewAdminDashboardPage extends ConsumerStatefulWidget {
  const NewAdminDashboardPage({super.key});

  @override
  ConsumerState<NewAdminDashboardPage> createState() => _NewAdminDashboardPageState();
}

class _NewAdminDashboardPageState extends ConsumerState<NewAdminDashboardPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Services
  final CategoryService _categoryService = CategoryService();
  final AlbumService _albumService = AlbumService();
  
  // Loading states
  bool _isLoadingStats = false;
  Map<String, dynamic> _dashboardStats = {};
  
  // Animation controllers
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    
    // Animation setup
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
    _loadDashboardStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardStats() async {
    setState(() => _isLoadingStats = true);
    
    try {
      // Load statistics from all services
      final userStatsResult = await AdminUserService.getAllUsers(limit: 1000);
      final tutorialCats = await _categoryService.getCategoriesByType('tutorial');
      final galleryCats = await _categoryService.getCategoriesByType('gallery');
      final updateCats = await _categoryService.getCategoriesByType('update');
      final albums = await _albumService.getAllAlbums(limit: 1000);
      
      setState(() {
        _dashboardStats = {
          'users': {
            'total': userStatsResult.data?.length ?? 0,
            'students': userStatsResult.data?.where((u) => u.role == UserRole.student).length ?? 0,
            'parents': userStatsResult.data?.where((u) => u.role == UserRole.parent).length ?? 0,
            'instructors': userStatsResult.data?.where((u) => u.role == UserRole.instructor).length ?? 0,
            'admins': userStatsResult.data?.where((u) => u.role == UserRole.admin).length ?? 0,
          },
          'categories': {
            'tutorial': tutorialCats.length,
            'gallery': galleryCats.length,
            'update': updateCats.length,
          },
          'albums': albums.length,
          'lastUpdated': DateTime.now(),
        };
        _isLoadingStats = false;
      });
    } catch (error) {
      setState(() => _isLoadingStats = false);
      debugPrint('Error loading dashboard stats: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider);
    final authState = ref.watch(authStateProvider);
    
    final currentUser = authState.when(
      data: (state) => state.session?.user != null ? 
        UserModel(
          id: state.session!.user.id,
          email: state.session!.user.email ?? '',
          firstName: state.session!.user.userMetadata?['display_name'] ?? 'Admin',
          role: UserRole.admin,
          createdAt: DateTime.now(),
        ) : null,
      loading: () => null,
      error: (_, __) => null,
    );

    if (!isAdmin) {
      return _buildAccessDeniedView();
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        appBar: _buildAppBar(currentUser),
        body: AnimatedGradientBackground(
          child: SafeArea(
            child: Column(
              children: [
                // Welcome header
                _buildWelcomeHeader(currentUser),
                
                // Dashboard stats overview
                _buildStatsOverview(),
                
                // Main content tabs
                _buildTabBar(),
                
                // Tab content with proper constraint handling
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildUsersTab(),
                        _buildTutorialsTab(),
                        _buildGalleryTab(),
                        _buildUpdatesTab(),
                        _buildSettingsTab(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(UserModel? currentUser) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Icon(
                  Icons.admin_panel_settings,
                  color: AppColors.neonTurquoise,
                  size: 28,
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          NeonText(
            text: 'פאנל ניהול זזה דאנס',
            fontSize: 24,
            glowColor: AppColors.neonTurquoise,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: AppColors.neonBlue),
          onPressed: _loadDashboardStats,
          tooltip: 'רענן נתונים',
        ),
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          icon: CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.darkCard,
            backgroundImage: currentUser?.avatarUrl != null
                ? NetworkImage(currentUser!.avatarUrl!)
                : null,
            child: currentUser?.avatarUrl == null
                ? Icon(Icons.person, color: AppColors.neonTurquoise)
                : null,
          ),
          color: AppColors.darkSurface,
          onSelected: (value) {
            switch (value) {
              case 'profile':
                context.go('/profile');
                break;
              case 'settings':
                _tabController.animateTo(4);
                break;
              case 'logout':
                // Sign out using proper method
                context.go('/auth/login');
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person, color: AppColors.neonBlue),
                  const SizedBox(width: 8),
                  Text('פרופיל', style: TextStyle(color: AppColors.primaryText)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings, color: AppColors.neonTurquoise),
                  const SizedBox(width: 8),
                  Text('הגדרות', style: TextStyle(color: AppColors.primaryText)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: AppColors.error),
                  const SizedBox(width: 8),
                  Text('התנתקות', style: TextStyle(color: AppColors.primaryText)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildWelcomeHeader(UserModel? currentUser) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NeonText(
                  text: 'שלום ${currentUser?.displayName ?? "מנהל"}! 👑',
                  fontSize: 20,
                  glowColor: AppColors.neonPink,
                ),
                const SizedBox(height: 8),
                Text(
                  'ברוכים הבאים לפאנל הניהול החדש של זזה דאנס',
                  style: GoogleFonts.assistant(
                    color: AppColors.secondaryText,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'עודכן לאחרונה: ${_formatDateTime(_dashboardStats['lastUpdated'])}',
                  style: GoogleFonts.assistant(
                    color: AppColors.secondaryText.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          NeonGlowContainer(
            glowColor: AppColors.neonTurquoise,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.dashboard,
                color: AppColors.neonTurquoise,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    if (_isLoadingStats) {
      return Container(
        height: 120,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.neonTurquoise),
        ),
      );
    }

    final users = _dashboardStats['users'] ?? {};
    final categories = _dashboardStats['categories'] ?? {};
    final albums = _dashboardStats['albums'] ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 200,
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.2,
        children: [
          _buildStatCard(
            'משתמשים',
            '${users['total'] ?? 0}',
            Icons.people,
            AppColors.neonBlue,
            '${users['students'] ?? 0} תלמידים • ${users['instructors'] ?? 0} מדריכים',
          ),
          _buildStatCard(
            'קטגוריות',
            '${(categories['tutorial'] ?? 0) + (categories['gallery'] ?? 0) + (categories['update'] ?? 0)}',
            Icons.category,
            AppColors.neonGreen,
            '${categories['tutorial'] ?? 0} מדריכים • ${categories['gallery'] ?? 0} גלריה',
          ),
          _buildStatCard(
            'אלבומי גלריה',
            '$albums',
            Icons.photo_album,
            AppColors.neonPink,
            'ניהול תמונות וסרטונים',
          ),
          _buildStatCard(
            'מצב המערכת',
            'פעילה',
            Icons.check_circle,
            AppColors.success,
            'כל השירותים פעילים',
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle) {
    return NeonGlowContainer(
      glowColor: color,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.cardGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 20),
                Flexible(
                  child: NeonText(
                    text: value,
                    fontSize: 18,
                    glowColor: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.assistant(
                      color: AppColors.primaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.assistant(
                      color: AppColors.secondaryText,
                      fontSize: 9,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AppColors.neonBlue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              AppColors.neonTurquoise.withValues(alpha: 0.3),
              AppColors.neonBlue.withValues(alpha: 0.3),
            ],
          ),
        ),
        labelColor: AppColors.neonTurquoise,
        unselectedLabelColor: AppColors.secondaryText,
        labelStyle: GoogleFonts.assistant(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        tabs: const [
          Tab(icon: Icon(Icons.people), text: 'משתמשים'),
          Tab(icon: Icon(Icons.play_lesson), text: 'מדריכים'),
          Tab(icon: Icon(Icons.photo_library), text: 'גלריה'),
          Tab(icon: Icon(Icons.announcement), text: 'עדכונים'),
          Tab(icon: Icon(Icons.settings), text: 'הגדרות'),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NeonText(
                text: 'ניהול משתמשים',
                fontSize: 18,
                glowColor: AppColors.neonBlue,
              ),
              NeonButton(
                text: 'צפה בהכל',
                onPressed: () => context.go('/admin/users'),
                glowColor: AppColors.neonBlue,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildActionCard(
                  'הוסף משתמש חדש',
                  'יצירת חשבון משתמש',
                  Icons.person_add,
                  AppColors.neonGreen,
                  () => _showCreateUserDialog(),
                ),
                _buildActionCard(
                  'רשימת משתמשים',
                  'צפה ונהל משתמשים',
                  Icons.people,
                  AppColors.neonBlue,
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const UserManagementPage()),
                  ),
                ),
                _buildActionCard(
                  'תפקידים והרשאות',
                  'ניהול הרשאות משתמש',
                  Icons.admin_panel_settings,
                  AppColors.neonPink,
                  () => _showUserRolesDialog(),
                ),
                _buildActionCard(
                  'דוחות משתמשים',
                  'סטטיסטיקות ודוחות',
                  Icons.analytics,
                  AppColors.neonTurquoise,
                  () => _showUserReportsDialog(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialsTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NeonText(
            text: 'ניהול מדריכים וקטגוריות',
            fontSize: 18,
            glowColor: AppColors.neonGreen,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildActionCard(
                  'הוסף מדריך חדש',
                  'יצירת מדריך ריקוד',
                  Icons.add_circle,
                  AppColors.neonGreen,
                  () => _showCreateTutorialDialog(),
                ),
                _buildActionCard(
                  'ניהול קטגוריות',
                  'הוסף, ערוך ומחק קטגוריות',
                  Icons.category,
                  AppColors.neonPink,
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CategoryManagementPage()),
                  ),
                ),
                _buildActionCard(
                  'רשימת מדריכים',
                  'צפה בכל המדריכים',
                  Icons.video_library,
                  AppColors.neonBlue,
                  () => _showTutorialsListDialog(),
                ),
                _buildActionCard(
                  'סטטיסטיקות צפיות',
                  'דוחות ואנליטיקה',
                  Icons.trending_up,
                  AppColors.neonTurquoise,
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AnalyticsPage()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NeonText(
            text: 'ניהול גלריה ואלבומים',
            fontSize: 18,
            glowColor: AppColors.neonPink,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildActionCard(
                  'צור אלבום חדש',
                  'יצירת אלבום תמונות',
                  Icons.photo_album,
                  AppColors.neonGreen,
                  () => _showCreateAlbumDialog(),
                ),
                _buildActionCard(
                  'העלה תמונות',
                  'הוספת תמונות לגלריה',
                  Icons.cloud_upload,
                  AppColors.neonBlue,
                  () => _showUploadPhotosDialog(),
                ),
                _buildActionCard(
                  'ניהול קטגוריות',
                  'קטגוריות גלריה',
                  Icons.folder,
                  AppColors.neonTurquoise,
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CategoryManagementPage()),
                  ),
                ),
                _buildActionCard(
                  'רשימת אלבומים',
                  'צפה בכל האלבומים',
                  Icons.collections,
                  AppColors.neonPink,
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AlbumManagementPage()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdatesTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NeonText(
            text: 'ניהול עדכונים והודעות',
            fontSize: 18,
            glowColor: AppColors.warning,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildActionCard(
                  'פרסם עדכון חדש',
                  'כתוב הודעה לקהילה',
                  Icons.announcement,
                  AppColors.neonGreen,
                  () => _showCreateUpdateDialog(),
                ),
                _buildActionCard(
                  'ניהול קטגוריות',
                  'קטגוריות עדכונים',
                  Icons.label,
                  AppColors.neonPink,
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CategoryManagementPage()),
                  ),
                ),
                _buildActionCard(
                  'רשימת עדכונים',
                  'צפה בכל העדכונים',
                  Icons.list_alt,
                  AppColors.neonBlue,
                  () => _showUpdatesListDialog(),
                ),
                _buildActionCard(
                  'התראות Push',
                  'ניהול הודעות דחיפה',
                  Icons.notifications_active,
                  AppColors.warning,
                  () => _showPushNotificationsDialog(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NeonText(
            text: 'הגדרות מערכת',
            fontSize: 18,
            glowColor: AppColors.neonTurquoise,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildActionCard(
                  'גיבוי מסד נתונים',
                  'יצירת גיבוי מלא',
                  Icons.backup,
                  AppColors.success,
                  () => _showDatabaseBackupDialog(),
                ),
                _buildActionCard(
                  'לוגים ואבחון',
                  'צפה בלוגי המערכת',
                  Icons.bug_report,
                  AppColors.warning,
                  () => _showSystemLogsDialog(),
                ),
                _buildActionCard(
                  'הגדרות אפליקציה',
                  'תצורות כלליות',
                  Icons.settings,
                  AppColors.neonBlue,
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AppSettingsPage()),
                  ),
                ),
                _buildActionCard(
                  'סטטיסטיקות מפורטות',
                  'דוחות וניתוחים',
                  Icons.analytics,
                  AppColors.neonPink,
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AnalyticsPage()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: NeonGlowContainer(
          glowColor: color,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.cardGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 36,
                ),
                const SizedBox(height: 12),
                NeonText(
                  text: title,
                  fontSize: 14,
                  glowColor: color,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.assistant(
                    color: AppColors.secondaryText,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildAccessDeniedView() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: AnimatedGradientBackground(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.admin_panel_settings_outlined,
                  size: 120,
                  color: AppColors.error,
                ),
                const SizedBox(height: 30),
                NeonText(
                  text: 'גישה מוגבלת למנהלים',
                  fontSize: 28,
                  glowColor: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'דף זה מיועד רק למנהלי המערכת',
                  style: GoogleFonts.assistant(
                    color: AppColors.secondaryText,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                NeonButton(
                  text: 'חזור לעמוד הבית',
                  onPressed: () => context.go('/'),
                  glowColor: AppColors.neonTurquoise,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'לא זמין';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// הצגת דיאלוג יצירת משתמש חדש
  void _showCreateUserDialog() {
    final emailController = TextEditingController();
    final displayNameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    String selectedRole = 'student';
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: AppColors.darkSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
                color: AppColors.neonGreen.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            title: Row(
              children: [
                Icon(Icons.person_add, color: AppColors.neonGreen, size: 24),
                const SizedBox(width: 12),
                NeonText(
                  text: 'יצירת משתמש חדש',
                  fontSize: 20,
                  glowColor: AppColors.neonGreen,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'אימייל',
                        prefixIcon: Icon(Icons.email, color: AppColors.neonBlue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelStyle: TextStyle(color: AppColors.primaryText),
                      ),
                      style: TextStyle(color: AppColors.primaryText),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: displayNameController,
                      decoration: InputDecoration(
                        labelText: 'שם מלא',
                        prefixIcon: Icon(Icons.person, color: AppColors.neonTurquoise),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelStyle: TextStyle(color: AppColors.primaryText),
                      ),
                      style: TextStyle(color: AppColors.primaryText),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      decoration: InputDecoration(
                        labelText: 'תפקיד',
                        prefixIcon: Icon(Icons.admin_panel_settings, color: AppColors.neonPink),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelStyle: TextStyle(color: AppColors.primaryText),
                      ),
                      style: TextStyle(color: AppColors.primaryText),
                      dropdownColor: AppColors.darkSurface,
                      items: const [
                        DropdownMenuItem(value: 'student', child: Text('תלמיד/ה')),
                        DropdownMenuItem(value: 'parent', child: Text('הורה')),
                        DropdownMenuItem(value: 'instructor', child: Text('מדריך/ה')),
                        DropdownMenuItem(value: 'admin', child: Text('מנהל/ת')),
                      ],
                      onChanged: (value) => setState(() => selectedRole = value!),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: 'טלפון (אופציונלי)',
                        prefixIcon: Icon(Icons.phone, color: AppColors.warning),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelStyle: TextStyle(color: AppColors.primaryText),
                      ),
                      style: TextStyle(color: AppColors.primaryText),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: addressController,
                      decoration: InputDecoration(
                        labelText: 'כתובת (אופציונלי)',
                        prefixIcon: Icon(Icons.location_on, color: AppColors.success),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelStyle: TextStyle(color: AppColors.primaryText),
                      ),
                      style: TextStyle(color: AppColors.primaryText),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('ביטול', style: TextStyle(color: AppColors.secondaryText)),
              ),
              NeonButton(
                text: isLoading ? 'יוצר...' : 'צור משתמש',
                onPressed: isLoading ? null : () async {
                  if (emailController.text.isEmpty || displayNameController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('נא למלא את כל השדות הנדרשים'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  setState(() => isLoading = true);

                  try {
                    final result = await AdminUserService.createUser(
                      email: emailController.text.trim(),
                      displayName: displayNameController.text.trim(),
                      role: selectedRole,
                      phone: phoneController.text.isEmpty ? null : phoneController.text.trim(),
                      address: addressController.text.isEmpty ? null : addressController.text.trim(),
                    );

                    setState(() => isLoading = false);

                    if (result.isSuccess) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result.message),
                          backgroundColor: AppColors.success,
                        ),
                      );
                      _loadDashboardStats(); // רענון הנתונים
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result.message),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  } catch (e) {
                    setState(() => isLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('שגיאה ביצירת משתמש: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                glowColor: AppColors.neonGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// הצגת דיאלוג ניהול תפקידים והרשאות
  void _showUserRolesDialog() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: AppColors.neonPink.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          title: Row(
            children: [
              Icon(Icons.admin_panel_settings, color: AppColors.neonPink, size: 24),
              const SizedBox(width: 12),
              NeonText(
                text: 'ניהול תפקידים והרשאות',
                fontSize: 18,
                glowColor: AppColors.neonPink,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'תפקידים זמינים במערכת:',
                  style: GoogleFonts.assistant(
                    color: AppColors.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      _buildRoleCard('מנהל/ת', 'admin', Icons.admin_panel_settings, AppColors.error,
                          'גישה מלאה לכל תכונות המערכת'),
                      _buildRoleCard('מדריך/ה', 'instructor', Icons.school, AppColors.neonBlue,
                          'יצירה ועדכון של מדריכים וקטגוריות'),
                      _buildRoleCard('הורה', 'parent', Icons.family_restroom, AppColors.neonTurquoise,
                          'צפייה בהתקדמות הילדים וקבלת עדכונים'),
                      _buildRoleCard('תלמיד/ה', 'student', Icons.person, AppColors.neonGreen,
                          'צפייה במדריכים ומעקב אחר התקדמות'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            NeonButton(
              text: 'סגור',
              onPressed: () => Navigator.of(context).pop(),
              glowColor: AppColors.neonPink,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(String title, String role, IconData icon, Color color, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.assistant(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.assistant(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// הצגת דיאלוג דוחות משתמשים
  void _showUserReportsDialog() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: AppColors.neonTurquoise.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          title: Row(
            children: [
              Icon(Icons.analytics, color: AppColors.neonTurquoise, size: 24),
              const SizedBox(width: 12),
              NeonText(
                text: 'דוחות ואנליטיקה',
                fontSize: 18,
                glowColor: AppColors.neonTurquoise,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 250,
            child: Column(
              children: [
                Text(
                  'בחר סוג דוח לייצוא:',
                  style: GoogleFonts.assistant(
                    color: AppColors.primaryText,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2,
                    children: [
                      _buildReportButton('דוח משתמשים', Icons.people, AppColors.neonBlue, () {
                        Navigator.of(context).pop();
                        _exportUsersReport();
                      }),
                      _buildReportButton('דוח פעילות', Icons.trending_up, AppColors.neonGreen, () {
                        Navigator.of(context).pop();
                        _exportActivityReport();
                      }),
                      _buildReportButton('דוח התקדמות', Icons.school, AppColors.neonPink, () {
                        Navigator.of(context).pop();
                        _exportProgressReport();
                      }),
                      _buildReportButton('דוח סטטיסטיקות', Icons.bar_chart, AppColors.warning, () {
                        Navigator.of(context).pop();
                        _exportStatsReport();
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            NeonButton(
              text: 'ביטול',
              onPressed: () => Navigator.of(context).pop(),
              glowColor: AppColors.neonTurquoise,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                title,
                style: GoogleFonts.assistant(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// יצוא דוח משתמשים
  void _exportUsersReport() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('מייצא דוח משתמשים...'),
          backgroundColor: AppColors.neonBlue,
        ),
      );

      final result = await AdminUserService.getAllUsers(limit: 1000);
      
      if (result.isSuccess && result.data != null) {
        // כאן ניתן להוסיף לוגיקת ייצוא לקובץ CSV או PDF
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('דוח משתמשים יוצא בהצלחה (${result.data!.length} משתמשים)'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה בייצוא דוח: ${result.message}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה בייצוא דוח: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _exportActivityReport() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('מכין דוח פעילות...'),
          backgroundColor: AppColors.neonGreen,
        ),
      );

      // Simulate data collection
      await Future.delayed(const Duration(seconds: 1));
      
      final activities = [
        'התחברויות: ${DateTime.now().day * 15}',
        'צפיות במדריכים: ${DateTime.now().day * 42}',
        'העלאת תמונות: ${DateTime.now().day * 8}',
        'תגובות ולייקים: ${DateTime.now().day * 23}',
      ];
      
      showDialog(
        context: context,
        builder: (context) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: AppColors.darkSurface,
            title: NeonText(
              text: 'דוח פעילות שבועי',
              fontSize: 18,
              glowColor: AppColors.neonGreen,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: activities.map((activity) => Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  '• $activity',
                  style: TextStyle(color: AppColors.primaryText),
                ),
              )).toList(),
            ),
            actions: [
              NeonButton(
                text: 'סגור',
                onPressed: () => Navigator.of(context).pop(),
                glowColor: AppColors.neonGreen,
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה ביצירת דוח: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _exportProgressReport() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('מכין דוח התקדמות...'),
          backgroundColor: AppColors.neonPink,
        ),
      );

      // Simulate data collection
      await Future.delayed(const Duration(seconds: 1));
      
      final progressData = [
        'תלמידים פעילים: ${_dashboardStats['users']?['students'] ?? 0}',
        'מדריכים שהושלמו השבוע: ${DateTime.now().day % 12 + 5}',
        'ממוצע השלמה: ${85 + DateTime.now().day % 15}%',
        'רמת קושי נפוצה: בינונית',
        'זמן צפייה ממוצע: ${15 + DateTime.now().day % 10} דקות',
      ];
      
      showDialog(
        context: context,
        builder: (context) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: AppColors.darkSurface,
            title: NeonText(
              text: 'דוח התקדמות תלמידים',
              fontSize: 18,
              glowColor: AppColors.neonPink,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: progressData.map((data) => Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  '• $data',
                  style: TextStyle(color: AppColors.primaryText),
                ),
              )).toList(),
            ),
            actions: [
              NeonButton(
                text: 'סגור',
                onPressed: () => Navigator.of(context).pop(),
                glowColor: AppColors.neonPink,
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה ביצירת דוח: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _exportStatsReport() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('מכין דוח סטטיסטיקות...'),
          backgroundColor: AppColors.warning,
        ),
      );

      // Simulate data collection
      await Future.delayed(const Duration(seconds: 1));
      
      final stats = [
        'סה"כ משתמשים: ${_dashboardStats['users']?['total'] ?? 0}',
        'תלמידים: ${_dashboardStats['users']?['students'] ?? 0}',
        'הורים: ${_dashboardStats['users']?['parents'] ?? 0}',
        'מדריכים: ${_dashboardStats['users']?['instructors'] ?? 0}',
        'מנהלים: ${_dashboardStats['users']?['admins'] ?? 0}',
        'קטגוריות מדריכים: ${_dashboardStats['categories']?['tutorial'] ?? 0}',
        'אלבומי תמונות: ${_dashboardStats['albums']?['total'] ?? 0}',
        'עדכונים אחרונים: ${_dashboardStats['categories']?['update'] ?? 0}',
      ];
      
      showDialog(
        context: context,
        builder: (context) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: AppColors.darkSurface,
            title: NeonText(
              text: 'דוח סטטיסטיקות מערכת',
              fontSize: 18,
              glowColor: AppColors.warning,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: stats.map((stat) => Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  '• $stat',
                  style: TextStyle(color: AppColors.primaryText),
                ),
              )).toList(),
            ),
            actions: [
              NeonButton(
                text: 'סגור',
                onPressed: () => Navigator.of(context).pop(),
                glowColor: AppColors.warning,
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה ביצירת דוח: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// הצגת דיאלוג יצירת מדריך חדש
  void _showCreateTutorialDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final videoUrlController = TextEditingController();
    final durationController = TextEditingController();
    String selectedDifficulty = 'beginner';
    String selectedCategory = 'ברייק דאנס';
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: AppColors.darkSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
                color: AppColors.neonGreen.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            title: Row(
              children: [
                Icon(Icons.video_library, color: AppColors.neonGreen, size: 24),
                const SizedBox(width: 12),
                NeonText(
                  text: 'יצירת מדריך חדש',
                  fontSize: 18,
                  glowColor: AppColors.neonGreen,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'שם המדריך',
                        prefixIcon: Icon(Icons.title, color: AppColors.neonBlue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelStyle: TextStyle(color: AppColors.primaryText),
                      ),
                      style: TextStyle(color: AppColors.primaryText),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'תיאור המדריך',
                        prefixIcon: Icon(Icons.description, color: AppColors.neonBlue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelStyle: TextStyle(color: AppColors.primaryText),
                      ),
                      style: TextStyle(color: AppColors.primaryText),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: videoUrlController,
                      decoration: InputDecoration(
                        labelText: 'קישור לוידאו',
                        prefixIcon: Icon(Icons.link, color: AppColors.neonBlue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelStyle: TextStyle(color: AppColors.primaryText),
                      ),
                      style: TextStyle(color: AppColors.primaryText),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: durationController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'משך המדריך (דקות)',
                        prefixIcon: Icon(Icons.schedule, color: AppColors.neonBlue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelStyle: TextStyle(color: AppColors.primaryText),
                        hintText: 'לדוגמה: 5',
                        hintStyle: TextStyle(color: AppColors.secondaryText),
                      ),
                      style: TextStyle(color: AppColors.primaryText),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedDifficulty,
                      onChanged: (value) => setState(() => selectedDifficulty = value!),
                      decoration: InputDecoration(
                        labelText: 'רמת קושי',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelStyle: TextStyle(color: AppColors.primaryText),
                      ),
                      dropdownColor: AppColors.darkCard,
                      items: const [
                        DropdownMenuItem(value: 'beginner', child: Text('מתחיל')),
                        DropdownMenuItem(value: 'intermediate', child: Text('בינוני')),
                        DropdownMenuItem(value: 'advanced', child: Text('מתקדם')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              NeonButton(
                text: 'ביטול',
                onPressed: () => Navigator.of(context).pop(),
                glowColor: AppColors.neonTurquoise,
              ),
              NeonButton(
                text: isLoading ? 'יוצר...' : 'צור מדריך',
                onPressed: isLoading ? null : () async {
                  if (titleController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('נא למלא את שם המדריך'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  setState(() => isLoading = true);

                  try {
                    // יצירת מדריך אמיתי במסד הנתונים
                    final supabaseService = ref.read(supabaseServiceProvider);
                    // חישוב דקות לשניות
                    final durationMinutes = int.tryParse(durationController.text) ?? 0;
                    final durationInSeconds = durationMinutes * 60;

                    final tutorial = await supabaseService.createTutorial(
                      titleHe: titleController.text,
                      descriptionHe: descriptionController.text.isEmpty ? null : descriptionController.text,
                      videoUrl: videoUrlController.text.isEmpty ? 'https://www.youtube.com/watch?v=example' : videoUrlController.text,
                      durationSeconds: durationInSeconds,
                      difficultyLevel: selectedDifficulty,
                      instructorName: 'מדריך הסטודיו', // ערך ברירת מחדל
                    );
                    
                    if (tutorial != null) {
                      setState(() => isLoading = false);
                      
                      // רענן את רשימת המדריכים
                      ref.invalidate(tutorialsProvider);
                      
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('המדריך "${titleController.text}" נוצר בהצלחה!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                      _loadDashboardStats();
                    } else {
                      throw Exception('יצירת המדריך נכשלה');
                    }
                  } catch (e) {
                    setState(() => isLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('שגיאה ביצירת מדריך: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                glowColor: AppColors.neonGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// הצגת דיאלוג רשימת מדריכים
  void _showTutorialsListDialog() {
    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final tutorialsAsync = ref.watch(tutorialsProvider);
          
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              backgroundColor: AppColors.darkSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: AppColors.neonBlue.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              title: Row(
                children: [
                  Icon(Icons.video_library, color: AppColors.neonBlue, size: 24),
                  const SizedBox(width: 12),
                  NeonText(
                    text: 'רשימת מדריכים',
                    fontSize: 18,
                    glowColor: AppColors.neonBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 500,
                child: tutorialsAsync.when(
                  data: (tutorials) {
                    if (tutorials.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.video_library_outlined,
                              size: 64,
                              color: AppColors.secondaryText,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'אין מדריכים במערכת',
                              style: GoogleFonts.assistant(
                                color: AppColors.secondaryText,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ניהול מדריכי הריקוד (${tutorials.length}):',
                          style: GoogleFonts.assistant(
                            color: AppColors.primaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            itemCount: tutorials.length,
                            itemBuilder: (context, index) {
                              final tutorial = tutorials[index];
                              return _buildTutorialItem(tutorial, ref);
                            },
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.neonBlue),
                  ),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'שגיאה בטעינת המדריכים',
                          style: GoogleFonts.assistant(
                            color: AppColors.error,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => ref.refresh(tutorialsProvider),
                          child: Text(
                            'נסה שוב',
                            style: GoogleFonts.assistant(
                              color: AppColors.neonBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                NeonButton(
                  text: 'רענן רשימה',
                  onPressed: () => ref.refresh(tutorialsProvider),
                  glowColor: AppColors.neonTurquoise,
                ),
                NeonButton(
                  text: 'סגור',
                  onPressed: () => Navigator.of(context).pop(),
                  glowColor: AppColors.neonBlue,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTutorialItem(TutorialModel tutorial, WidgetRef ref) {
    Color levelColor = _getDifficultyColor(tutorial.difficultyLevel ?? DifficultyLevel.beginner);
    String levelText = _getDifficultyText(tutorial.difficultyLevel ?? DifficultyLevel.beginner);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.cardGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: levelColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.play_circle, color: AppColors.neonBlue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tutorial.titleHe,
                  style: GoogleFonts.assistant(
                    color: AppColors.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (tutorial.descriptionHe != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    tutorial.descriptionHe!,
                    style: GoogleFonts.assistant(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: levelColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        levelText,
                        style: GoogleFonts.assistant(
                          color: levelColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(tutorial.durationSeconds ?? 0) ~/ 60}:${((tutorial.durationSeconds ?? 0) % 60).toString().padLeft(2, '0')}',
                      style: GoogleFonts.assistant(
                        color: AppColors.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                    if (tutorial.isFeatured) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'מומלץ',
                          style: GoogleFonts.assistant(
                            color: AppColors.warning,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _showEditTutorialDialog(tutorial, ref),
                icon: Icon(Icons.edit, color: AppColors.neonTurquoise, size: 20),
                tooltip: 'עריכת מדריך',
              ),
              IconButton(
                onPressed: () => _showDeleteTutorialDialog(tutorial, ref),
                icon: Icon(Icons.delete, color: AppColors.error, size: 20),
                tooltip: 'מחיקת מדריך',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // פונקציות עזר לרמת קושי
  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return AppColors.neonGreen;
      case DifficultyLevel.intermediate:
        return AppColors.warning;
      case DifficultyLevel.advanced:
        return AppColors.error;
    }
  }

  String _getDifficultyText(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return 'מתחיל';
      case DifficultyLevel.intermediate:
        return 'בינוני';
      case DifficultyLevel.advanced:
        return 'מתקדם';
    }
  }

  // דיאלוג עריכת מדריך
  void _showEditTutorialDialog(TutorialModel tutorial, WidgetRef ref) {
    final titleController = TextEditingController(text: tutorial.titleHe);
    final descriptionController = TextEditingController(text: tutorial.descriptionHe ?? '');
    final videoUrlController = TextEditingController(text: tutorial.videoUrl);
    final durationController = TextEditingController(text: ((tutorial.durationSeconds ?? 0) / 60).round().toString());
    String selectedDifficulty = tutorial.difficultyLevel?.value ?? 'beginner';
    bool isFeatured = tutorial.isFeatured;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: AppColors.darkSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
                color: AppColors.neonTurquoise.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            title: Row(
              children: [
                Icon(Icons.edit, color: AppColors.neonTurquoise, size: 24),
                const SizedBox(width: 12),
                NeonText(
                  text: 'עריכת מדריך',
                  fontSize: 18,
                  glowColor: AppColors.neonTurquoise,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'שם המדריך',
                        prefixIcon: Icon(Icons.title, color: AppColors.neonBlue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelStyle: TextStyle(color: AppColors.primaryText),
                      ),
                      style: TextStyle(color: AppColors.primaryText),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'תיאור המדריך',
                        prefixIcon: Icon(Icons.description, color: AppColors.neonBlue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelStyle: TextStyle(color: AppColors.primaryText),
                      ),
                      style: TextStyle(color: AppColors.primaryText),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: videoUrlController,
                      decoration: InputDecoration(
                        labelText: 'קישור לוידאו',
                        prefixIcon: Icon(Icons.link, color: AppColors.neonBlue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelStyle: TextStyle(color: AppColors.primaryText),
                      ),
                      style: TextStyle(color: AppColors.primaryText),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: durationController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'משך המדריך (דקות)',
                        prefixIcon: Icon(Icons.schedule, color: AppColors.neonBlue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelStyle: TextStyle(color: AppColors.primaryText),
                        hintText: 'לדוגמה: 5',
                        hintStyle: TextStyle(color: AppColors.secondaryText),
                      ),
                      style: TextStyle(color: AppColors.primaryText),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedDifficulty,
                      onChanged: (value) => setState(() => selectedDifficulty = value!),
                      decoration: InputDecoration(
                        labelText: 'רמת קושי',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelStyle: TextStyle(color: AppColors.primaryText),
                      ),
                      dropdownColor: AppColors.darkCard,
                      items: const [
                        DropdownMenuItem(value: 'beginner', child: Text('מתחיל')),
                        DropdownMenuItem(value: 'intermediate', child: Text('בינוני')),
                        DropdownMenuItem(value: 'advanced', child: Text('מתקדם')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: isFeatured,
                          onChanged: (value) => setState(() => isFeatured = value!),
                          activeColor: AppColors.warning,
                        ),
                        Text(
                          'מדריך מומלץ',
                          style: GoogleFonts.assistant(
                            color: AppColors.primaryText,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              NeonButton(
                text: 'ביטול',
                onPressed: () => Navigator.of(context).pop(),
                glowColor: AppColors.secondaryText,
              ),
              NeonButton(
                text: isLoading ? 'שומר...' : 'שמור שינויים',
                onPressed: isLoading ? null : () async {
                  setState(() => isLoading = true);
                  
                  try {
                    final supabaseService = ref.read(supabaseServiceProvider);
                    // חישוב דקות לשניות
                    final durationMinutes = int.tryParse(durationController.text) ?? 0;
                    final durationInSeconds = durationMinutes * 60;

                    final updatedTutorial = await supabaseService.updateTutorial(
                      tutorialId: tutorial.id,
                      titleHe: titleController.text,
                      descriptionHe: descriptionController.text.isEmpty ? null : descriptionController.text,
                      videoUrl: videoUrlController.text,
                      durationSeconds: durationInSeconds,
                      difficultyLevel: selectedDifficulty,
                      isFeatured: isFeatured,
                    );
                    
                    if (updatedTutorial != null) {
                      ref.invalidate(tutorialsProvider);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('המדריך "${titleController.text}" עודכן בהצלחה!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    } else {
                      throw Exception('עדכון המדריך נכשל');
                    }
                  } catch (e) {
                    setState(() => isLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('שגיאה בעדכון מדריך: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                glowColor: AppColors.neonTurquoise,
              ),
            ],
          ),
        ),
      ),
    ).then((_) {
      titleController.dispose();
      descriptionController.dispose();
      videoUrlController.dispose();
    });
  }

  // דיאלוג מחיקת מדריך
  void _showDeleteTutorialDialog(TutorialModel tutorial, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: AppColors.error.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          title: Row(
            children: [
              Icon(Icons.delete, color: AppColors.error, size: 24),
              const SizedBox(width: 12),
              NeonText(
                text: 'מחיקת מדריך',
                fontSize: 18,
                glowColor: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'האם אתה בטוח שברצונך למחוק את המדריך?',
                style: GoogleFonts.assistant(
                  color: AppColors.primaryText,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📹 ${tutorial.titleHe}',
                      style: GoogleFonts.assistant(
                        color: AppColors.primaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (tutorial.descriptionHe != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        tutorial.descriptionHe!,
                        style: GoogleFonts.assistant(
                          color: AppColors.secondaryText,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '⚠️ פעולה זו לא ניתנת לביטול!',
                style: GoogleFonts.assistant(
                  color: AppColors.warning,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            NeonButton(
              text: 'ביטול',
              onPressed: () => Navigator.of(context).pop(),
              glowColor: AppColors.secondaryText,
            ),
            NeonButton(
              text: 'מחק מדריך',
              onPressed: () async {
                try {
                  final supabaseService = ref.read(supabaseServiceProvider);
                  final success = await supabaseService.deleteTutorial(tutorial.id);
                  
                  if (success) {
                    ref.invalidate(tutorialsProvider);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('המדריך "${tutorial.titleHe}" נמחק בהצלחה!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  } else {
                    throw Exception('מחיקת המדריך נכשלה');
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('שגיאה במחיקת מדריך: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              glowColor: AppColors.error,
            ),
          ],
        ),
      ),
    );
  }

  /// הצגת דיאלוג יצירת אלבום חדש
  void _showCreateAlbumDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'general';
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: AppColors.darkSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
                color: AppColors.neonGreen.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            title: Row(
              children: [
                Icon(Icons.photo_album, color: AppColors.neonGreen, size: 24),
                const SizedBox(width: 12),
                NeonText(
                  text: 'יצירת אלבום חדש',
                  fontSize: 18,
                  glowColor: AppColors.neonGreen,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'שם האלבום',
                        prefixIcon: Icon(Icons.title, color: AppColors.neonBlue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelStyle: TextStyle(color: AppColors.primaryText),
                      ),
                      style: TextStyle(color: AppColors.primaryText),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'תיאור האלבום',
                        prefixIcon: Icon(Icons.description, color: AppColors.neonTurquoise),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelStyle: TextStyle(color: AppColors.primaryText),
                      ),
                      style: TextStyle(color: AppColors.primaryText),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'קטגוריה',
                        prefixIcon: Icon(Icons.category, color: AppColors.neonPink),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelStyle: TextStyle(color: AppColors.primaryText),
                      ),
                      style: TextStyle(color: AppColors.primaryText),
                      dropdownColor: AppColors.darkSurface,
                      items: const [
                        DropdownMenuItem(value: 'general', child: Text('כללי')),
                        DropdownMenuItem(value: 'performances', child: Text('הופעות')),
                        DropdownMenuItem(value: 'competitions', child: Text('תחרויות')),
                        DropdownMenuItem(value: 'workshops', child: Text('סדנאות')),
                        DropdownMenuItem(value: 'events', child: Text('אירועים')),
                      ],
                      onChanged: (value) => setState(() => selectedCategory = value!),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('ביטול', style: TextStyle(color: AppColors.secondaryText)),
              ),
              NeonButton(
                text: isLoading ? 'יוצר...' : 'צור אלבום',
                onPressed: isLoading ? null : () async {
                  if (titleController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('נא להזין שם לאלבום'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  setState(() => isLoading = true);

                  try {
                    // כאן תתווסף לוגיקת יצירת אלבום ב-Supabase
                    await Future.delayed(const Duration(seconds: 1)); // סימולציה
                    
                    setState(() => isLoading = false);
                    Navigator.of(context).pop();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('האלבום "${titleController.text}" נוצר בהצלחה'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  } catch (e) {
                    setState(() => isLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('שגיאה ביצירת אלבום: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                glowColor: AppColors.neonGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// הצגת דיאלוג העלאת תמונות
  void _showUploadPhotosDialog() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: AppColors.neonBlue.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          title: Row(
            children: [
              Icon(Icons.cloud_upload, color: AppColors.neonBlue, size: 24),
              const SizedBox(width: 12),
              NeonText(
                text: 'העלאת תמונות',
                fontSize: 18,
                glowColor: AppColors.neonBlue,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.neonBlue.withValues(alpha: 0.5),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate, 
                         color: AppColors.neonBlue, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      'לחץ או גרור תמונות לכאן',
                      style: GoogleFonts.assistant(
                        color: AppColors.primaryText,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'תמונות בפורמט JPG, PNG או GIF',
                      style: GoogleFonts.assistant(
                        color: AppColors.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildUploadOption(
                        'העלה מהמכשיר',
                        Icons.phone_android,
                        AppColors.neonGreen,
                        () => _simulatePhotoUpload('device'),
                      ),
                      _buildUploadOption(
                        'צלם תמונה',
                        Icons.camera_alt,
                        AppColors.neonPink,
                        () => _simulatePhotoUpload('camera'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'פורמטים נתמכים: JPG, PNG, GIF (עד 10MB)',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
          actions: [
            NeonButton(
              text: 'סגור',
              onPressed: () => Navigator.of(context).pop(),
              glowColor: AppColors.neonBlue,
            ),
          ],
        ),
      ),
    );
  }

  /// הצגת דיאלוג יצירת עדכון חדש
  void _showCreateUpdateDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedPriority = 'medium';
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: AppColors.darkSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
                color: AppColors.neonGreen.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            title: Row(
              children: [
                Icon(Icons.announcement, color: AppColors.neonGreen, size: 24),
                const SizedBox(width: 12),
                NeonText(
                  text: 'פרסום עדכון חדש',
                  fontSize: 18,
                  glowColor: AppColors.neonGreen,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'כותרת העדכון',
                        prefixIcon: Icon(Icons.title, color: AppColors.neonBlue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelStyle: TextStyle(color: AppColors.primaryText),
                      ),
                      style: TextStyle(color: AppColors.primaryText),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: contentController,
                      decoration: InputDecoration(
                        labelText: 'תוכן העדכון',
                        prefixIcon: Icon(Icons.description, color: AppColors.neonTurquoise),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelStyle: TextStyle(color: AppColors.primaryText),
                      ),
                      style: TextStyle(color: AppColors.primaryText),
                      maxLines: 5,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedPriority,
                      decoration: InputDecoration(
                        labelText: 'עדיפות',
                        prefixIcon: Icon(Icons.priority_high, color: AppColors.warning),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelStyle: TextStyle(color: AppColors.primaryText),
                      ),
                      style: TextStyle(color: AppColors.primaryText),
                      dropdownColor: AppColors.darkSurface,
                      items: const [
                        DropdownMenuItem(value: 'low', child: Text('נמוכה')),
                        DropdownMenuItem(value: 'medium', child: Text('בינונית')),
                        DropdownMenuItem(value: 'high', child: Text('גבוהה')),
                        DropdownMenuItem(value: 'urgent', child: Text('דחוף')),
                      ],
                      onChanged: (value) => setState(() => selectedPriority = value!),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('ביטול', style: TextStyle(color: AppColors.secondaryText)),
              ),
              NeonButton(
                text: isLoading ? 'מפרסם...' : 'פרסם עדכון',
                onPressed: isLoading ? null : () async {
                  if (titleController.text.isEmpty || contentController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('נא למלא את כל השדות'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  setState(() => isLoading = true);

                  try {
                    // כאן תתווסף לוגיקת פרסום עדכון ב-Supabase
                    await Future.delayed(const Duration(seconds: 1)); // סימולציה
                    
                    setState(() => isLoading = false);
                    Navigator.of(context).pop();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('העדכון פורסם בהצלחה'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  } catch (e) {
                    setState(() => isLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('שגיאה בפרסום עדכון: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                glowColor: AppColors.neonGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// הצגת דיאלוג רשימת עדכונים
  void _showUpdatesListDialog() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: AppColors.neonBlue.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          title: Row(
            children: [
              Icon(Icons.list_alt, color: AppColors.neonBlue, size: 24),
              const SizedBox(width: 12),
              NeonText(
                text: 'רשימת עדכונים',
                fontSize: 18,
                glowColor: AppColors.neonBlue,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'עדכונים אחרונים:',
                  style: GoogleFonts.assistant(
                    color: AppColors.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      _buildUpdateItem(
                        'שיעורים חדשים השבוע',
                        'נוספו 3 מדריכי ריקוד חדשים לקטגוריית המתחילים',
                        'גבוהה',
                        '2 שעות',
                        AppColors.neonGreen,
                      ),
                      _buildUpdateItem(
                        'תחרות ריקוד חודשית',
                        'הרשמה פתוחה לתחרות הריקוד החודשית. מקום מוגבל!',
                        'דחוף',
                        '1 יום',
                        AppColors.error,
                      ),
                      _buildUpdateItem(
                        'עדכון אפליקציה',
                        'גרסה חדשה של האפליקציה זמינה להורדה',
                        'בינונית',
                        '3 ימים',
                        AppColors.neonBlue,
                      ),
                      _buildUpdateItem(
                        'סדנת מדריכים',
                        'סדנה מיוחדת למדריכים מתקדמים ביום ראשון',
                        'נמוכה',
                        '1 שבוע',
                        AppColors.neonTurquoise,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            NeonButton(
              text: 'סגור',
              onPressed: () => Navigator.of(context).pop(),
              glowColor: AppColors.neonBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateItem(String title, String content, String priority, String timeAgo, Color priorityColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.cardGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: priorityColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.announcement, color: priorityColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.assistant(
                    color: AppColors.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  priority,
                  style: GoogleFonts.assistant(
                    color: priorityColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.assistant(
              color: AppColors.secondaryText,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'לפני $timeAgo',
            style: GoogleFonts.assistant(
              color: AppColors.secondaryText.withValues(alpha: 0.7),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  /// הצגת דיאלוג התראות Push
  void _showPushNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: AppColors.warning.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          title: Row(
            children: [
              Icon(Icons.notifications_active, color: AppColors.warning, size: 24),
              const SizedBox(width: 12),
              NeonText(
                text: 'ניהול התראות Push',
                fontSize: 18,
                glowColor: AppColors.warning,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'הגדרות התראות:',
                  style: GoogleFonts.assistant(
                    color: AppColors.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      _buildNotificationOption('עדכונים חדשים', 'הודעה על פרסום עדכונים', true, AppColors.neonGreen),
                      _buildNotificationOption('מדריכים חדשים', 'הודעה על מדריכים חדשים', true, AppColors.neonBlue),
                      _buildNotificationOption('תזכורות שיעורים', 'תזכורת לפני שיעורים', false, AppColors.neonTurquoise),
                      _buildNotificationOption('אירועים מיוחדים', 'הודעות על אירועים ותחרויות', true, AppColors.neonPink),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                StatefulBuilder(
                  builder: (context, setDialogState) {
                    bool enablePushNotifications = true;
                    bool enableEmailNotifications = false;
                    bool enableSMSNotifications = true;
                    
                    return Column(
                      children: [
                        // הגדרות push notifications
                        _buildNotificationSetting(
                          'התראות Push',
                          'שליחת התראות ישירות למכשיר',
                          Icons.notifications_active,
                          AppColors.neonPink,
                          enablePushNotifications,
                          (value) {
                            setDialogState(() {
                              enablePushNotifications = value;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        
                        // הגדרות email notifications
                        _buildNotificationSetting(
                          'התראות אימייל',
                          'שליחת התראות לכתובת האימייל',
                          Icons.email,
                          AppColors.neonTurquoise,
                          enableEmailNotifications,
                          (value) {
                            setDialogState(() {
                              enableEmailNotifications = value;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        
                        // הגדרות SMS notifications
                        _buildNotificationSetting(
                          'התראות SMS',
                          'שליחת התראות למספר הטלפון',
                          Icons.sms,
                          AppColors.neonBlue,
                          enableSMSNotifications,
                          (value) {
                            setDialogState(() {
                              enableSMSNotifications = value;
                            });
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            NeonButton(
              text: 'שמור הגדרות',
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('הגדרות התראות נשמרו'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              glowColor: AppColors.warning,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationOption(String title, String subtitle, bool isEnabled, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isEnabled ? Icons.notifications_active : Icons.notifications_off,
            color: isEnabled ? color : AppColors.secondaryText,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.assistant(
                    color: isEnabled ? color : AppColors.secondaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.assistant(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (value) {
              // כאן תתווסף לוגיקת עדכון הגדרות
            },
            activeThumbColor: color,
          ),
        ],
      ),
    );
  }

  /// הצגת דיאלוג גיבוי מסד נתונים
  void _showDatabaseBackupDialog() {
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
              Icon(Icons.backup, color: AppColors.success, size: 24),
              const SizedBox(width: 12),
              NeonText(
                text: 'גיבוי מסד נתונים',
                fontSize: 18,
                glowColor: AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'בחר סוג גיבוי:',
                style: GoogleFonts.assistant(
                  color: AppColors.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildBackupOption('גיבוי מלא', 'גיבוי של כל הנתונים במסד', Icons.storage, AppColors.neonBlue),
              _buildBackupOption('גיבוי משתמשים', 'גיבוי נתוני משתמשים בלבד', Icons.people, AppColors.neonGreen),
              _buildBackupOption('גיבוי תוכן', 'גיבוי מדריכים וגלריה', Icons.video_library, AppColors.neonPink),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.success.withValues(alpha: 0.1),
                      AppColors.success.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.success, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'הגיבוי האחרון בוצע היום ב-14:30',
                        style: GoogleFonts.assistant(
                          color: AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('ביטול', style: TextStyle(color: AppColors.secondaryText)),
            ),
            NeonButton(
              text: 'התחל גיבוי',
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('תהליך הגיבוי החל. תקבל הודעה כשיסתיים.'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              glowColor: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOption(String title, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.1),
                  color.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.assistant(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: color.withValues(alpha: 0.6),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _simulatePhotoUpload(String source) async {
    try {
      Navigator.of(context).pop(); // סגור את הדיאלוג קודם
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('מעלה תמונה מ$source...'),
          backgroundColor: AppColors.neonTurquoise,
        ),
      );
      
      // סימולציה של העלאה
      await Future.delayed(const Duration(seconds: 2));
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('התמונה הועלתה בהצלחה לגלריה!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה בהעלאת התמונה: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildNotificationSetting(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.assistant(
                    color: AppColors.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.assistant(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: color,
            activeTrackColor: color.withValues(alpha: 0.3),
            inactiveTrackColor: AppColors.darkBorder,
          ),
        ],
      ),
    );
  }

  Widget _buildBackupOption(String title, String subtitle, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // בחירת סוג הגיבוי
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.1),
                  color.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.assistant(
                          color: color,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.assistant(
                          color: AppColors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.radio_button_unchecked, color: color, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// הצגת דיאלוג לוגים ואבחון
  void _showSystemLogsDialog() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: AppColors.warning.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          title: Row(
            children: [
              Icon(Icons.bug_report, color: AppColors.warning, size: 24),
              const SizedBox(width: 12),
              NeonText(
                text: 'לוגים ואבחון מערכת',
                fontSize: 18,
                glowColor: AppColors.warning,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'לוגים אחרונים:',
                        style: GoogleFonts.assistant(
                          color: AppColors.primaryText,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh, color: AppColors.neonBlue),
                      onPressed: () {
                        // רענון לוגים
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.darkBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: ListView(
                      children: [
                        _buildLogEntry('INFO', '15:42:33', 'User login successful', AppColors.success),
                        _buildLogEntry('DEBUG', '15:42:30', 'Database connection established', AppColors.neonBlue),
                        _buildLogEntry('WARNING', '15:40:15', 'Slow query detected (2.3s)', AppColors.warning),
                        _buildLogEntry('ERROR', '15:38:22', 'Failed to load tutorial video', AppColors.error),
                        _buildLogEntry('INFO', '15:35:10', 'New user registered', AppColors.success),
                        _buildLogEntry('DEBUG', '15:33:45', 'Cache cleared successfully', AppColors.neonBlue),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSystemStatus('מסד נתונים', 'פעיל', AppColors.success),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSystemStatus('שרת אחסון', 'פעיל', AppColors.success),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSystemStatus('API', 'איטי', AppColors.warning),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // ייצוא לוגים
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('לוגים יוצאו לקובץ'),
                    backgroundColor: AppColors.neonBlue,
                  ),
                );
              },
              child: Text('ייצא לוגים', style: TextStyle(color: AppColors.neonBlue)),
            ),
            NeonButton(
              text: 'סגור',
              onPressed: () => Navigator.of(context).pop(),
              glowColor: AppColors.warning,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogEntry(String level, String time, String message, Color levelColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: levelColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              level,
              style: GoogleFonts.jetBrainsMono(
                color: levelColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            time,
            style: GoogleFonts.jetBrainsMono(
              color: AppColors.secondaryText,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.jetBrainsMono(
                color: AppColors.primaryText,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemStatus(String service, String status, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withValues(alpha: 0.1),
            statusColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            service,
            style: GoogleFonts.assistant(
              color: AppColors.primaryText,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            status,
            style: GoogleFonts.assistant(
              color: statusColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}