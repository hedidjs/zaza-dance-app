import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../shared/widgets/animated_gradient_background.dart';
import '../../../../shared/widgets/neon_text.dart';
import '../../../../shared/widgets/enhanced_neon_effects.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/app_bottom_navigation.dart';

/// לוח בקרה מנהלים עבור אפליקציית זזה דאנס
class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final isAdmin = ref.watch(isAdminProvider);

    // בדיקה שהמשתמש הוא מנהל
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
            text: 'לוח בקרה מנהלים',
            fontSize: 24,
            glowColor: AppColors.neonPink,
          ),
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(
                Icons.menu,
                color: AppColors.primaryText,
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: AppColors.neonTurquoise,
              ),
              onPressed: _refreshData,
              tooltip: 'רענן נתונים',
            ),
          ],
        ),
        drawer: const AppDrawer(),
        body: AnimatedGradientBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ברוכים הבאים
                  _buildWelcomeSection(currentUser),
                  
                  const SizedBox(height: 30),
                  
                  // סטטיסטיקות כלליות
                  _buildStatsOverview(),
                  
                  const SizedBox(height: 30),
                  
                  // פעולות מהירות
                  _buildQuickActions(),
                  
                  const SizedBox(height: 30),
                  
                  // פעילות אחרונה
                  _buildRecentActivity(),
                  
                  const SizedBox(height: 30),
                  
                  // התראות ומשימות
                  _buildAlertsAndTasks(),
                  
                  const SizedBox(height: 100), // מקום לניווט תחתון
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: const AppBottomNavigation(
          currentPage: NavigationPage.home,
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(AsyncValue userAsync) {
    return userAsync.when(
      data: (user) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.neonPink.withOpacity(0.2),
              AppColors.neonTurquoise.withOpacity(0.2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.neonPink.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            NeonGlowContainer(
              glowColor: AppColors.neonPink,
              animate: true,
              child: CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.darkSurface,
                backgroundImage: user?.profileImageUrl != null
                    ? NetworkImage(user!.profileImageUrl!)
                    : null,
                child: user?.profileImageUrl == null
                    ? Icon(
                        Icons.admin_panel_settings,
                        size: 35,
                        color: AppColors.neonPink,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NeonText(
                    text: 'שלום ${user?.displayName ?? "מנהל"}!',
                    fontSize: 20,
                    glowColor: AppColors.neonPink,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ברוך הבא ללוח הבקרה של זזה דאנס',
                    style: GoogleFonts.assistant(
                      color: AppColors.secondaryText,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'עדכון אחרון: ${_getTimeOfDay()}',
                    style: GoogleFonts.assistant(
                      color: AppColors.neonTurquoise,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.3),
      loading: () => const CircularProgressIndicator(color: AppColors.neonPink),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatsOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NeonText(
          text: 'סטטיסטיקות כלליות',
          fontSize: 18,
          glowColor: AppColors.neonTurquoise,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.people,
                title: 'משתמשים',
                value: '247',
                subtitle: '+12 החודש',
                glowColor: AppColors.neonBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.video_library,
                title: 'מדריכים',
                value: '58',
                subtitle: '+3 השבוע',
                glowColor: AppColors.neonPink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.photo_library,
                title: 'תמונות',
                value: '892',
                subtitle: '+45 היום',
                glowColor: AppColors.neonTurquoise,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.notifications,
                title: 'עדכונים',
                value: '23',
                subtitle: '12 פעילים',
                glowColor: AppColors.neonGreen,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color glowColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.cardGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: glowColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: glowColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.assistant(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          NeonText(
            text: value,
            fontSize: 24,
            glowColor: glowColor,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.assistant(
              color: AppColors.secondaryText,
              fontSize: 10,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms).scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NeonText(
          text: 'פעולות מהירות',
          fontSize: 18,
          glowColor: AppColors.neonPink,
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.2,
          children: [
            _buildActionCard(
              icon: Icons.people_outline,
              title: 'ניהול משתמשים',
              subtitle: 'הוספה, עריכה ומחיקה',
              onTap: () => _navigateToUserManagement(),
              glowColor: AppColors.neonBlue,
            ),
            _buildActionCard(
              icon: Icons.video_call,
              title: 'העלאת מדריך',
              subtitle: 'הוספת מדריך חדש',
              onTap: () => _navigateToUploadTutorial(),
              glowColor: AppColors.neonPink,
            ),
            _buildActionCard(
              icon: Icons.photo_camera,
              title: 'העלאת תמונות',
              subtitle: 'הוספה לגלריה',
              onTap: () => _navigateToUploadGallery(),
              glowColor: AppColors.neonTurquoise,
            ),
            _buildActionCard(
              icon: Icons.announcement,
              title: 'עדכון חדש',
              subtitle: 'פרסום הודעה',
              onTap: () => _navigateToCreateUpdate(),
              glowColor: AppColors.neonGreen,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color glowColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.cardGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: glowColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NeonGlowContainer(
                glowColor: glowColor,
                child: Icon(
                  icon,
                  size: 36,
                  color: glowColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.assistant(
                  color: AppColors.primaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
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
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 400.ms).scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: NeonText(
                text: 'פעילות אחרונה',
                fontSize: 18,
                glowColor: AppColors.neonTurquoise,
              ),
            ),
            TextButton(
              onPressed: () => _viewAllActivity(),
              child: Text(
                'הצג הכל',
                style: GoogleFonts.assistant(
                  color: AppColors.neonTurquoise,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
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
            children: [
              _buildActivityItem(
                icon: Icons.person_add,
                title: 'משתמש חדש נרשם',
                subtitle: 'דנה כהן הצטרפה כתלמידה',
                time: 'לפני 5 דקות',
                glowColor: AppColors.neonGreen,
              ),
              _buildActivityItem(
                icon: Icons.video_library,
                title: 'מדריך חדש הועלה',
                subtitle: 'ברייקדאנס למתחילים - פרק 3',
                time: 'לפני 2 שעות',
                glowColor: AppColors.neonPink,
              ),
              _buildActivityItem(
                icon: Icons.photo_camera,
                title: 'תמונות חדשות',
                subtitle: '15 תמונות מהופעת סיום',
                time: 'אתמול',
                glowColor: AppColors.neonTurquoise,
              ),
              _buildActivityItem(
                icon: Icons.announcement,
                title: 'עדכון פורסם',
                subtitle: 'שיעורים מיוחדים לחופש הגדול',
                time: 'לפני 3 ימים',
                glowColor: AppColors.warning,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color glowColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: glowColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: glowColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.assistant(
                    color: AppColors.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
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
          Text(
            time,
            style: GoogleFonts.assistant(
              color: AppColors.secondaryText,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsAndTasks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NeonText(
          text: 'התראות ומשימות',
          fontSize: 18,
          glowColor: AppColors.warning,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.cardGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.warning.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _buildAlertItem(
                icon: Icons.warning,
                title: 'שרת עומס גבוה',
                subtitle: 'זמני טעינה איטיים במדריכי וידאו',
                priority: 'בינוני',
                priorityColor: AppColors.warning,
              ),
              const Divider(color: AppColors.darkBorder),
              _buildAlertItem(
                icon: Icons.backup,
                title: 'גיבוי יומי',
                subtitle: 'גיבוי אוטומטי הושלם בהצלחה',
                priority: 'מידע',
                priorityColor: AppColors.info,
              ),
              const Divider(color: AppColors.darkBorder),
              _buildAlertItem(
                icon: Icons.update,
                title: 'עדכון תוכנה',
                subtitle: 'גרסה 2.1.0 זמינה להורדה',
                priority: 'נמוך',
                priorityColor: AppColors.neonGreen,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlertItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String priority,
    required Color priorityColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: priorityColor,
            size: 20,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.assistant(
                    color: AppColors.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: priorityColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: priorityColor.withOpacity(0.5)),
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
                const SizedBox(height: 8),
                Text(
                  'אנא פנה למנהל המערכת לקבלת הרשאות',
                  style: GoogleFonts.assistant(
                    color: AppColors.secondaryText,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                NeonButton(
                  text: 'חזור לעמוד הבית',
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                  glowColor: AppColors.neonTurquoise,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTimeOfDay() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  void _refreshData() {
    // TODO: רענון נתונים
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('נתונים עודכנו'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _navigateToUserManagement() {
    // TODO: ניווט לניהול משתמשים
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ניהול משתמשים בפיתוח'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _navigateToUploadTutorial() {
    // TODO: ניווט להעלאת מדריך
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('העלאת מדריך בפיתוח'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _navigateToUploadGallery() {
    // TODO: ניווט להעלאת תמונות
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('העלאת גלריה בפיתוח'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _navigateToCreateUpdate() {
    // TODO: ניווט ליצירת עדכון
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('יצירת עדכון בפיתוח'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _viewAllActivity() {
    // TODO: הצגת כל הפעילות
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('הצגת פעילות מלאה בפיתוח'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}