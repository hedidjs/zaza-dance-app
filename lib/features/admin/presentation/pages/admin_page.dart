import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../shared/widgets/animated_gradient_background.dart';
import '../../../../shared/widgets/neon_text.dart';
import '../../../../shared/widgets/enhanced_neon_effects.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/app_bottom_navigation.dart';

/// עמוד ניהול למנהלי המערכת
class AdminPage extends ConsumerWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isAdmin = ref.watch(isAdminProvider);

    // בדיקה שהמשתמש הוא אדמין
    if (!isAdmin) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.darkBackground,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: NeonText(
              text: 'אין הרשאות',
              fontSize: 24,
              glowColor: AppColors.error,
            ),
          ),
          body: AnimatedGradientBackground(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.security,
                    size: 100,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 20),
                  NeonText(
                    text: 'אין לך הרשאות גישה לעמוד זה',
                    fontSize: 18,
                    glowColor: AppColors.error,
                  ),
                  const SizedBox(height: 30),
                  NeonButton(
                    text: 'חזור לעמוד הבית',
                    onPressed: () => Navigator.of(context).pop(),
                    glowColor: AppColors.neonPink,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: NeonText(
            text: 'פאנל ניהול',
            fontSize: 24,
            glowColor: AppColors.warning,
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
        ),
        drawer: const AppDrawer(),
        body: AnimatedGradientBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // מידע על האדמין
                  currentUser.when(
                    data: (user) => _buildAdminHeader(user),
                    loading: () => const CircularProgressIndicator(color: AppColors.warning),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // כלי ניהול
                  _buildAdminSection(
                    'ניהול תוכן',
                    [
                      _buildAdminCard(
                        context,
                        icon: Icons.video_library,
                        title: 'ניהול מדריכים',
                        subtitle: 'הוספה, עריכה ומחיקה של מדריכי ריקוד',
                        onTap: () => _showComingSoon(context, 'ניהול מדריכים'),
                        glowColor: AppColors.neonTurquoise,
                      ),
                      _buildAdminCard(
                        context,
                        icon: Icons.photo_library,
                        title: 'ניהול גלריה',
                        subtitle: 'הוספה, עריכה ומחיקה של תמונות וסרטונים',
                        onTap: () => _showComingSoon(context, 'ניהול גלריה'),
                        glowColor: AppColors.neonPurple,
                      ),
                      _buildAdminCard(
                        context,
                        icon: Icons.announcement,
                        title: 'ניהול עדכונים',
                        subtitle: 'פרסום והעלאת עדכונים וחדשות',
                        onTap: () => _showComingSoon(context, 'ניהול עדכונים'),
                        glowColor: AppColors.neonBlue,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  _buildAdminSection(
                    'ניהול משתמשים',
                    [
                      _buildAdminCard(
                        context,
                        icon: Icons.people,
                        title: 'רשימת משתמשים',
                        subtitle: 'צפייה וניהול משתמשים רשומים',
                        onTap: () => _showComingSoon(context, 'ניהול משתמשים'),
                        glowColor: AppColors.neonGreen,
                      ),
                      _buildAdminCard(
                        context,
                        icon: Icons.analytics,
                        title: 'סטטיסטיקות',
                        subtitle: 'צפייה בנתוני שימוש ואינטראקציות',
                        onTap: () => _showComingSoon(context, 'סטטיסטיקות'),
                        glowColor: AppColors.accent1,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 100), // מקום לניווט תחתון
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: const AppBottomNavigation(
          currentPage: NavigationPage.home, // אין עמוד אדמין בניווט
        ),
      ),
    );
  }

  Widget _buildAdminHeader(dynamic user) {
    return NeonGlowContainer(
      glowColor: AppColors.warning,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.cardGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.warning.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            NeonGlowContainer(
              glowColor: AppColors.warning,
              animate: true,
              child: CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.darkSurface,
                child: Icon(
                  Icons.admin_panel_settings,
                  size: 35,
                  color: AppColors.warning,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NeonText(
                    text: user?.displayName ?? 'מנהל מערכת',
                    fontSize: 20,
                    glowColor: AppColors.warning,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'מנהל מערכת - זזה דאנס',
                    style: GoogleFonts.assistant(
                      color: AppColors.secondaryText,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.warning.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'הרשאות מלאות',
                      style: GoogleFonts.assistant(
                        color: AppColors.warning,
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
      ),
    );
  }

  Widget _buildAdminSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NeonText(
          text: title,
          fontSize: 18,
          glowColor: AppColors.warning,
        ),
        const SizedBox(height: 16),
        ...items,
      ],
    );
  }

  Widget _buildAdminCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color glowColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: glowColor.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: glowColor.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
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
                    size: 24,
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
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.assistant(
                          color: AppColors.secondaryText,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.secondaryText,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: AppColors.warning.withOpacity(0.3),
              width: 1,
            ),
          ),
          title: NeonText(
            text: 'בפיתוח',
            fontSize: 20,
            glowColor: AppColors.warning,
          ),
          content: Text(
            '$feature יהיה זמין בקרוב.\nאנחנו עובדים על כלי ניהול מתקדמים עבורכם!',
            style: GoogleFonts.assistant(
              color: AppColors.primaryText,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          actions: [
            NeonButton(
              text: 'הבנתי',
              onPressed: () => Navigator.of(context).pop(),
              glowColor: AppColors.warning,
            ),
          ],
        ),
      ),
    );
  }
}