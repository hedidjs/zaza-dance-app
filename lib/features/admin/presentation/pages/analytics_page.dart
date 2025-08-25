import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../shared/widgets/animated_gradient_background.dart';
import '../../../../shared/widgets/neon_text.dart';
import '../../../../shared/widgets/enhanced_neon_effects.dart';
import '../../services/admin_analytics_service.dart';
import '../../models/admin_stats_model.dart';

/// עמוד סטטיסטיקות ודוחות עבור מנהלי זזה דאנס
class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = '7d'; // 7d, 30d, 90d, 1y
  bool _isLoading = false;
  AdminStatsModel? _dashboardStats;
  Map<String, dynamic>? _userAnalytics;
  Map<String, dynamic>? _tutorialAnalytics;
  Map<String, dynamic>? _galleryAnalytics;
  String _errorMessage = '';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAnalytics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Load dashboard stats
      final dashboardStats = await AdminAnalyticsService.getDashboardStats();
      
      // Calculate date range based on selected period
      final endDate = DateTime.now();
      final startDate = _getStartDateForPeriod(endDate);
      
      // Load analytics data in parallel
      final futures = await Future.wait([
        AdminAnalyticsService.getUserAnalytics(
          dateFrom: startDate,
          dateTo: endDate,
        ),
        AdminAnalyticsService.getTutorialAnalytics(
          dateFrom: startDate,
          dateTo: endDate,
        ),
        AdminAnalyticsService.getGalleryAnalytics(
          dateFrom: startDate,
          dateTo: endDate,
        ),
      ]);

      setState(() {
        _dashboardStats = dashboardStats;
        _userAnalytics = futures[0];
        _tutorialAnalytics = futures[1];
        _galleryAnalytics = futures[2];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  DateTime _getStartDateForPeriod(DateTime endDate) {
    switch (_selectedPeriod) {
      case '7d':
        return endDate.subtract(const Duration(days: 7));
      case '30d':
        return endDate.subtract(const Duration(days: 30));
      case '90d':
        return endDate.subtract(const Duration(days: 90));
      case '1y':
        return endDate.subtract(const Duration(days: 365));
      default:
        return endDate.subtract(const Duration(days: 7));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider);

    if (!isAdmin) {
      return _buildAccessDeniedView();
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: NeonText(
            text: 'סטטיסטיקות ודוחות',
            fontSize: 24,
            glowColor: AppColors.neonTurquoise,
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.primaryText,
            ),
            onPressed: () => context.pop(),
          ),
          actions: [
            // Period selector
            PopupMenuButton<String>(
              icon: Icon(
                Icons.date_range,
                color: AppColors.neonTurquoise,
              ),
              color: AppColors.darkSurface,
              onSelected: (value) {
                setState(() {
                  _selectedPeriod = value;
                });
                _loadAnalytics();
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: '7d',
                  child: Row(
                    children: [
                      Icon(Icons.today, color: AppColors.neonGreen, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '7 ימים אחרונים',
                        style: GoogleFonts.assistant(color: AppColors.primaryText),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: '30d',
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month, color: AppColors.neonBlue, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '30 ימים אחרונים',
                        style: GoogleFonts.assistant(color: AppColors.primaryText),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: '90d',
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: AppColors.neonPink, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '3 חודשים אחרונים',
                        style: GoogleFonts.assistant(color: AppColors.primaryText),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: '1y',
                  child: Row(
                    children: [
                      Icon(Icons.event, color: AppColors.warning, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'שנה אחרונה',
                        style: GoogleFonts.assistant(color: AppColors.primaryText),
                      ),
                    ],
                  ),
                ),
              ],
              tooltip: 'בחר תקופה',
            ),
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: AppColors.neonTurquoise,
              ),
              onPressed: _loadAnalytics,
              tooltip: 'רענן נתונים',
            ),
            IconButton(
              icon: Icon(
                Icons.download,
                color: AppColors.neonGreen,
              ),
              onPressed: _exportData,
              tooltip: 'ייצא נתונים',
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.neonTurquoise,
            labelColor: AppColors.primaryText,
            unselectedLabelColor: AppColors.secondaryText,
            isScrollable: true,
            tabs: const [
              Tab(text: 'סקירה כללית'),
              Tab(text: 'משתמשים'),
              Tab(text: 'תוכן'),
              Tab(text: 'התקשרות'),
            ],
          ),
        ),
        body: AnimatedGradientBackground(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.neonTurquoise,
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildUsersTab(),
                    _buildContentTab(),
                    _buildEngagementTab(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // תקופה נבחרת
          _buildPeriodHeader(),
          
          const SizedBox(height: 20),
          
          // מטריקות עיקריות
          _buildMainMetrics(),
          
          const SizedBox(height: 30),
          
          // גרף צפיות יומי
          _buildDailyViewsChart(),
          
          const SizedBox(height: 30),
          
          // התפלגות משתמשים
          _buildUserDistribution(),
          
          const SizedBox(height: 30),
          
          // תוכן פופולרי
          _buildPopularContent(),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // סטטיסטיקות משתמשים
          _buildUserStats(),
          
          const SizedBox(height: 30),
          
          // משתמשים חדשים
          _buildNewUsersChart(),
          
          const SizedBox(height: 30),
          
          // פעילות משתמשים
          _buildUserActivity(),
          
          const SizedBox(height: 30),
          
          // משתמשים פעילים
          _buildActiveUsers(),
        ],
      ),
    );
  }

  Widget _buildContentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // סטטיסטיקות תוכן
          _buildContentStats(),
          
          const SizedBox(height: 30),
          
          // מדריכים פופולריים
          _buildPopularTutorials(),
          
          const SizedBox(height: 30),
          
          // תמונות פופולריות
          _buildPopularGalleryItems(),
          
          const SizedBox(height: 30),
          
          // ביצועי עדכונים
          _buildUpdatesPerformance(),
        ],
      ),
    );
  }

  Widget _buildEngagementTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // מטריקות התקשרות
          _buildEngagementMetrics(),
          
          const SizedBox(height: 30),
          
          // זמן בילוי באפליקציה
          _buildTimeSpentChart(),
          
          const SizedBox(height: 30),
          
          // פעולות משתמשים
          _buildUserActions(),
          
          const SizedBox(height: 30),
          
          // חזרה לאפליקציה
          _buildRetentionChart(),
        ],
      ),
    );
  }

  Widget _buildPeriodHeader() {
    String periodText = '';
    switch (_selectedPeriod) {
      case '7d':
        periodText = '7 ימים אחרונים';
        break;
      case '30d':
        periodText = '30 ימים אחרונים';
        break;
      case '90d':
        periodText = '3 חודשים אחרונים';
        break;
      case '1y':
        periodText = 'שנה אחרונה';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.neonTurquoise.withValues(alpha: 0.2),
            AppColors.neonBlue.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.neonTurquoise.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.insights,
            color: AppColors.neonTurquoise,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            'נתונים עבור: $periodText',
            style: GoogleFonts.assistant(
              color: AppColors.primaryText,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainMetrics() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          NeonText(
            text: 'מטריקות עיקריות',
            fontSize: 18,
            glowColor: AppColors.neonTurquoise,
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            children: [
              _buildMetricCard(
                'משתמשים פעילים',
                _dashboardStats?.activeUsers.toString() ?? 'טוען...',
                '+12%',
                true,
                AppColors.neonGreen,
                Icons.people,
              ),
              _buildMetricCard(
                'צפיות במדריכים',
                _dashboardStats?.tutorialViews.toString() ?? 'טוען...',
                '+5%',
                true,
                AppColors.neonPink,
                Icons.play_circle,
              ),
              _buildMetricCard(
                'תמונות בגלריה',
                _dashboardStats?.galleryImages.toString() ?? 'טוען...',
                '+8%',
                true,
                AppColors.neonTurquoise,
                Icons.photo,
              ),
              _buildMetricCard(
                'שיעור השלמה',
                '${(_dashboardStats?.completionRate ?? 0.0).toStringAsFixed(1)}%',
                '+3%',
                true,
                AppColors.warning,
                Icons.timeline,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3);
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String change,
    bool isPositive,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (isPositive ? AppColors.success : AppColors.error).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  change,
                  style: GoogleFonts.assistant(
                    color: isPositive ? AppColors.success : AppColors.error,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          NeonText(
            text: value,
            fontSize: 20,
            glowColor: color,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.assistant(
              color: AppColors.secondaryText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyViewsChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.cardGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
            text: 'צפיות יומיות',
            fontSize: 18,
            glowColor: AppColors.neonPink,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.show_chart,
                    size: 60,
                    color: AppColors.neonPink,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'גרף צפיות יומיות',
                    style: GoogleFonts.assistant(
                      color: AppColors.primaryText,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'גרף אינטראקטיבי - נתונים בזמן אמת',
                    style: GoogleFonts.assistant(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDistribution() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.cardGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.neonBlue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NeonText(
            text: 'התפלגות משתמשים',
            fontSize: 18,
            glowColor: AppColors.neonBlue,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildDistributionItem(
                  'תלמידים',
                  _calculatePercentage('student'),
                  _dashboardStats?.usersByRole['student'] ?? 0,
                  AppColors.neonGreen,
                ),
              ),
              Expanded(
                child: _buildDistributionItem(
                  'הורים',
                  _calculatePercentage('parent'),
                  _dashboardStats?.usersByRole['parent'] ?? 0,
                  AppColors.neonTurquoise,
                ),
              ),
              Expanded(
                child: _buildDistributionItem(
                  'מדריכים',
                  _calculatePercentage('instructor'),
                  _dashboardStats?.usersByRole['instructor'] ?? 0,
                  AppColors.neonPink,
                ),
              ),
              Expanded(
                child: _buildDistributionItem(
                  'מנהלים',
                  _calculatePercentage('admin'),
                  _dashboardStats?.usersByRole['admin'] ?? 0,
                  AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionItem(String label, String percentage, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.2),
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: NeonText(
              text: percentage,
              fontSize: 14,
              glowColor: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.assistant(
            color: AppColors.primaryText,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '($count)',
          style: GoogleFonts.assistant(
            color: AppColors.secondaryText,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildPopularContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.cardGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.neonGreen.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NeonText(
            text: 'תוכן פופולרי',
            fontSize: 18,
            glowColor: AppColors.neonGreen,
          ),
          const SizedBox(height: 20),
          _buildPopularItem('נתונים יטענו מהמסד נתונים', 'טוען...', AppColors.neonPink),
          _buildPopularItem('נתונים יטענו מהמסד נתונים', 'טוען...', AppColors.neonTurquoise),
          _buildPopularItem('נתונים יטענו מהמסד נתונים', 'טוען...', AppColors.neonBlue),
          _buildPopularItem('נתונים יטענו מהמסד נתונים', 'טוען...', AppColors.neonGreen),
        ],
      ),
    );
  }

  Widget _buildPopularItem(String title, String views, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
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
                const SizedBox(height: 4),
                Text(
                  views,
                  style: GoogleFonts.assistant(
                    color: color,
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

  Widget _buildUserStats() {
    return _buildStatsContainer(
      'סטטיסטיקות משתמשים',
      AppColors.neonBlue,
      [
        _buildStatRow('סך משתמשים רשומים', _dashboardStats?.totalUsers.toString() ?? 'טוען...'),
        _buildStatRow('משתמשים פעילים החודש', _dashboardStats?.activeUsers.toString() ?? 'טוען...'),
        _buildStatRow('משתמשים חדשים השבוע', _dashboardStats?.newSignups.toString() ?? 'טוען...'),
        _buildStatRow('שיעור השלמה', '${(_dashboardStats?.completionRate ?? 0.0).toStringAsFixed(1)}%'),
      ],
    );
  }

  Widget _buildNewUsersChart() {
    return _buildChartContainer(
      'משתמשים חדשים',
      AppColors.neonGreen,
      'גרף הרשמות יומיות',
    );
  }

  Widget _buildUserActivity() {
    return _buildStatsContainer(
      'פעילות משתמשים',
      AppColors.neonPink,
      [
        _buildStatRow('ממוצע כניסות ליום', 'טוען...'),
        _buildStatRow('זמן בילוי ממוצע', 'טוען...'),
        _buildStatRow('עמודים בכל ביקור', 'טוען...'),
        _buildStatRow('שיעור יציאה מהירה', 'טוען...'),
      ],
    );
  }

  Widget _buildActiveUsers() {
    return _buildChartContainer(
      'משתמשים פעילים',
      AppColors.neonTurquoise,
      'גרף פעילות יומית',
    );
  }

  Widget _buildContentStats() {
    return _buildStatsContainer(
      'סטטיסטיקות תוכן',
      AppColors.neonPink,
      [
        _buildStatRow('סך מדריכים', _dashboardStats?.totalTutorials.toString() ?? 'טוען...'),
        _buildStatRow('סך תמונות', _dashboardStats?.galleryImages.toString() ?? 'טוען...'),
        _buildStatRow('סך עדכונים', _dashboardStats?.publishedUpdates.toString() ?? 'טוען...'),
        _buildStatRow('צפיות השבוע', _dashboardStats?.tutorialViews.toString() ?? 'טוען...'),
      ],
    );
  }

  Widget _buildPopularTutorials() {
    final popularTutorials = _dashboardStats?.popularTutorials ?? [];
    final tutorialsList = popularTutorials.isEmpty
        ? [
            {'title': 'לא נמצאו נתונים', 'metric': '0 צפיות'},
            {'title': 'אין מדריכים פופולריים', 'metric': '0 צפיות'},
            {'title': 'הוסף מדריכים למערכת', 'metric': '0 צפיות'},
          ]
        : popularTutorials.take(3).map((tutorial) => {
            'title': tutorial.title,
            'metric': '${tutorial.views} צפיות',
          }).toList();

    return _buildTopContentContainer(
      'מדריכים פופולריים',
      AppColors.neonPink,
      tutorialsList,
    );
  }

  Widget _buildPopularGalleryItems() {
    return _buildTopContentContainer(
      'תמונות פופולריות',
      AppColors.neonTurquoise,
      [
        {'title': 'נתונים יטענו מהמסד נתונים', 'metric': 'טוען...'},
        {'title': 'נתונים יטענו מהמסד נתונים', 'metric': 'טוען...'},
        {'title': 'נתונים יטענו מהמסד נתונים', 'metric': 'טוען...'},
      ],
    );
  }

  Widget _buildUpdatesPerformance() {
    return _buildTopContentContainer(
      'ביצועי עדכונים',
      AppColors.neonGreen,
      [
        {'title': 'נתונים יטענו מהמסד נתונים', 'metric': 'טוען...'},
        {'title': 'נתונים יטענו מהמסד נתונים', 'metric': 'טוען...'},
        {'title': 'נתונים יטענו מהמסד נתונים', 'metric': 'טוען...'},
      ],
    );
  }

  Widget _buildEngagementMetrics() {
    return _buildStatsContainer(
      'מטריקות התקשרות',
      AppColors.neonTurquoise,
      [
        _buildStatRow('שיעור התקשרות', 'טוען...'),
        _buildStatRow('זמן בילוי ממוצע', 'טוען...'),
        _buildStatRow('פעולות בביקור', 'טוען...'),
        _buildStatRow('שיתופים', 'טוען...'),
      ],
    );
  }

  Widget _buildTimeSpentChart() {
    return _buildChartContainer(
      'זמן בילוי באפליקציה',
      AppColors.neonPink,
      'גרף זמני השימוש',
    );
  }

  Widget _buildUserActions() {
    return _buildStatsContainer(
      'פעולות משתמשים',
      AppColors.neonGreen,
      [
        _buildStatRow('צפיות במדריכים', 'טוען...'),
        _buildStatRow('צפיות בגלריה', 'טוען...'),
        _buildStatRow('קריאת עדכונים', 'טוען...'),
        _buildStatRow('שיתופים', 'טוען...'),
      ],
    );
  }

  Widget _buildRetentionChart() {
    return _buildChartContainer(
      'שיעור חזרה לאפליקציה',
      AppColors.warning,
      'גרף שמירת משתמשים',
    );
  }

  Widget _buildStatsContainer(String title, Color color, List<Widget> stats) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          NeonText(
            text: title,
            fontSize: 18,
            glowColor: color,
          ),
          const SizedBox(height: 20),
          ...stats,
        ],
      ),
    );
  }

  Widget _buildChartContainer(String title, Color color, String placeholder) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          NeonText(
            text: title,
            fontSize: 18,
            glowColor: color,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.show_chart,
                    size: 40,
                    color: color,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    placeholder,
                    style: GoogleFonts.assistant(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopContentContainer(String title, Color color, List<Map<String, String>> items) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          NeonText(
            text: title,
            fontSize: 18,
            glowColor: color,
          ),
          const SizedBox(height: 20),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: GoogleFonts.assistant(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item['title']!,
                      style: GoogleFonts.assistant(
                        color: AppColors.primaryText,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    item['metric']!,
                    style: GoogleFonts.assistant(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.assistant(
                color: AppColors.secondaryText,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.assistant(
              color: AppColors.primaryText,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
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
                  text: 'גישה מוגבלת',
                  fontSize: 28,
                  glowColor: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'דף זה מיועד למנהלים בלבד',
                  style: GoogleFonts.assistant(
                    color: AppColors.secondaryText,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                NeonButton(
                  text: 'חזור',
                  onPressed: () => context.pop(),
                  glowColor: AppColors.neonTurquoise,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _exportData() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
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
              Icon(Icons.download, color: AppColors.neonGreen),
              const SizedBox(width: 8),
              NeonText(
                text: 'ייצא נתונים',
                fontSize: 18,
                glowColor: AppColors.neonGreen,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.table_chart, color: AppColors.neonTurquoise),
                title: Text(
                  'ייצא ל-Excel',
                  style: GoogleFonts.assistant(color: AppColors.primaryText),
                ),
                onTap: () => _exportToExcel(),
              ),
              ListTile(
                leading: Icon(Icons.picture_as_pdf, color: AppColors.neonPink),
                title: Text(
                  'ייצא ל-PDF',
                  style: GoogleFonts.assistant(color: AppColors.primaryText),
                ),
                onTap: () => _exportToPDF(),
              ),
              ListTile(
                leading: Icon(Icons.code, color: AppColors.neonBlue),
                title: Text(
                  'ייצא JSON',
                  style: GoogleFonts.assistant(color: AppColors.primaryText),
                ),
                onTap: () => _exportToJSON(),
              ),
            ],
          ),
          actions: [
            NeonButton(
              text: 'סגור',
              onPressed: () => context.pop(),
              glowColor: AppColors.neonGreen,
            ),
          ],
        ),
      ),
    );
  }

  void _exportToExcel() {
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('יצוא נתונים ל-Excel'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _exportToPDF() {
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('יצוא דוח PDF'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _exportToJSON() {
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('יצוא נתונים גולמיים JSON'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  String _calculatePercentage(String role) {
    if (_dashboardStats == null) return '0%';
    
    final roleCount = _dashboardStats!.usersByRole[role] ?? 0;
    final totalUsers = _dashboardStats!.totalUsers;
    
    if (totalUsers == 0) return '0%';
    
    final percentage = (roleCount / totalUsers) * 100;
    return '${percentage.toStringAsFixed(1)}%';
  }
}