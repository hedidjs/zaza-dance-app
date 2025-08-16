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
import 'notification_settings_page.dart';
import 'profile_settings_page.dart';
import 'general_settings_page.dart';

/// עמוד הגדרות ראשי לאפליקציית זזה דאנס
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: NeonText(
            text: 'הגדרות',
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
        ),
        drawer: const AppDrawer(),
        body: AnimatedGradientBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isAuthenticated) ...[
                    _buildUserHeader(currentUser),
                    const SizedBox(height: 30),
                  ],
                  
                  _buildSettingsSection(
                    'הגדרות אישיות',
                    [
                      if (isAuthenticated) ...[
                        _buildSettingsItem(
                          context,
                          icon: Icons.person,
                          title: 'פרופיל אישי',
                          subtitle: 'עריכת פרטים אישיים',
                          onTap: () => _navigateToProfileSettings(context),
                          glowColor: AppColors.neonPink,
                        ),
                        _buildSettingsItem(
                          context,
                          icon: Icons.notifications,
                          title: 'הגדרות התראות',
                          subtitle: 'ניהול התראות push והודעות',
                          onTap: () => _navigateToNotificationSettings(context),
                          glowColor: AppColors.neonTurquoise,
                        ),
                      ] else ...[
                        _buildSettingsItem(
                          context,
                          icon: Icons.login,
                          title: 'התחברות',
                          subtitle: 'התחבר כדי לגשת להגדרות אישיות',
                          onTap: () => Navigator.of(context).pushNamed('/login'),
                          glowColor: AppColors.neonGreen,
                        ),
                      ],
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  _buildSettingsSection(
                    'הגדרות כלליות',
                    [
                      _buildSettingsItem(
                        context,
                        icon: Icons.settings,
                        title: 'הגדרות אפליקציה',
                        subtitle: 'נושא, שפה והעדפות כלליות',
                        onTap: () => _navigateToGeneralSettings(context),
                        glowColor: AppColors.neonPurple,
                      ),
                      _buildSettingsItem(
                        context,
                        icon: Icons.info,
                        title: 'אודות האפליקציה',
                        subtitle: 'מידע על גרסה ופיתוח',
                        onTap: () => _showAboutDialog(context),
                        glowColor: AppColors.info,
                      ),
                      _buildSettingsItem(
                        context,
                        icon: Icons.help,
                        title: 'עזרה ותמיכה',
                        subtitle: 'שאלות נפוצות ויצירת קשר',
                        onTap: () => _showHelpDialog(context),
                        glowColor: AppColors.neonBlue,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  _buildSettingsSection(
                    'מידע',
                    [
                      _buildSettingsItem(
                        context,
                        icon: Icons.privacy_tip,
                        title: 'מדיניות פרטיות',
                        subtitle: 'איך אנחנו מטפלים במידע שלך',
                        onTap: () => _showPrivacyDialog(context),
                        glowColor: AppColors.warning,
                      ),
                      _buildSettingsItem(
                        context,
                        icon: Icons.article,
                        title: 'תנאי שימוש',
                        subtitle: 'תנאים והגבלות השימוש',
                        onTap: () => _showTermsDialog(context),
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
          currentPage: NavigationPage.home, // אין עמוד הגדרות בניווט, נשאיר בית
        ),
      ),
    );
  }

  Widget _buildUserHeader(AsyncValue userAsync) {
    return userAsync.when(
      data: (user) {
        if (user == null) return const SizedBox.shrink();
        
        return NeonGlowContainer(
          glowColor: AppColors.neonPink,
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
                color: AppColors.neonPink.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                NeonGlowContainer(
                  glowColor: AppColors.neonTurquoise,
                  animate: true,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.darkSurface,
                    backgroundImage: user.profileImageUrl != null
                        ? NetworkImage(user.profileImageUrl!)
                        : null,
                    child: user.profileImageUrl == null
                        ? Icon(
                            Icons.person,
                            size: 35,
                            color: AppColors.neonTurquoise,
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
                        text: user.displayName,
                        fontSize: 20,
                        glowColor: AppColors.neonPink,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: GoogleFonts.assistant(
                          color: AppColors.secondaryText,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.neonTurquoise.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.neonTurquoise.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _getRoleDisplayName(user.role),
                          style: GoogleFonts.assistant(
                            color: AppColors.neonTurquoise,
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
      },
      loading: () => const CircularProgressIndicator(color: AppColors.neonPink),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NeonText(
          text: title,
          fontSize: 18,
          glowColor: AppColors.neonTurquoise,
        ),
        const SizedBox(height: 16),
        ...items,
      ],
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color glowColor,
    bool showArrow = true,
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
                if (showArrow)
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

  void _navigateToProfileSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProfileSettingsPage(),
      ),
    );
  }

  void _navigateToNotificationSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NotificationSettingsPage(),
      ),
    );
  }

  void _navigateToGeneralSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const GeneralSettingsPage(),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: AppColors.info.withOpacity(0.3),
              width: 1,
            ),
          ),
          title: Row(
            children: [
              Icon(Icons.info, color: AppColors.info),
              const SizedBox(width: 8),
              NeonText(
                text: 'אודות האפליקציה',
                fontSize: 18,
                glowColor: AppColors.info,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'זזה דאנס - אפליקציית הסטודיו',
                style: GoogleFonts.assistant(
                  color: AppColors.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'גרסה: 2.0.0',
                style: GoogleFonts.assistant(
                  color: AppColors.secondaryText,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'פותח בהשראת תרבות ההיפ הופ והרצון ליצור קהילה דיגיטלית חמה ומזמינה.',
                style: GoogleFonts.assistant(
                  color: AppColors.primaryText,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
          actions: [
            NeonButton(
              text: 'סגור',
              onPressed: () => Navigator.of(context).pop(),
              glowColor: AppColors.info,
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: AppColors.neonBlue.withOpacity(0.3),
              width: 1,
            ),
          ),
          title: Row(
            children: [
              Icon(Icons.help, color: AppColors.neonBlue),
              const SizedBox(width: 8),
              NeonText(
                text: 'עזרה ותמיכה',
                fontSize: 18,
                glowColor: AppColors.neonBlue,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'זקוקים לעזרה? אנחנו כאן בשבילכם!',
                style: GoogleFonts.assistant(
                  color: AppColors.primaryText,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              _buildContactInfo(Icons.phone, 'טלפון: 050-123-4567'),
              const SizedBox(height: 8),
              _buildContactInfo(Icons.email, 'אימייל: support@zazadance.com'),
              const SizedBox(height: 8),
              _buildContactInfo(Icons.schedule, 'זמני תמיכה: א-ה 10:00-18:00'),
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

  void _showPrivacyDialog(BuildContext context) {
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
          title: Row(
            children: [
              Icon(Icons.privacy_tip, color: AppColors.warning),
              const SizedBox(width: 8),
              NeonText(
                text: 'מדיניות פרטיות',
                fontSize: 18,
                glowColor: AppColors.warning,
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(
              'אנו מחויבים להגנה על הפרטיות שלכם:\n\n'
              '• המידע האישי שלכם נשמר בצורה מאובטחת\n'
              '• איננו משתפים מידע עם צדדים שלישיים\n'
              '• אתם יכולים לבקש מחיקת חשבון בכל עת\n'
              '• שימוש במידע לשיפור השירות בלבד\n\n'
              'לפרטים נוספים צרו קשר עמנו.',
              style: GoogleFonts.assistant(
                color: AppColors.primaryText,
                fontSize: 14,
                height: 1.5,
              ),
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

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: AppColors.accent1.withOpacity(0.3),
              width: 1,
            ),
          ),
          title: Row(
            children: [
              Icon(Icons.article, color: AppColors.accent1),
              const SizedBox(width: 8),
              NeonText(
                text: 'תנאי שימוש',
                fontSize: 18,
                glowColor: AppColors.accent1,
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(
              'תנאי השימוש באפליקציה:\n\n'
              '• השימוש באפליקציה מותנה בקבלת התנאים\n'
              '• האפליקציה מיועדת לתלמידי הסטודיו ומשפחותיהם\n'
              '• אסור לעשות שימוש לא הולם בתכנים\n'
              '• אנו שומרים על הזכות לעדכן תנאים\n'
              '• פעילות בלתי חוקית תוביל לחסימת חשבון\n\n'
              'בהמשך השימוש אתם מסכימים לתנאים אלה.',
              style: GoogleFonts.assistant(
                color: AppColors.primaryText,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
          actions: [
            NeonButton(
              text: 'הבנתי',
              onPressed: () => Navigator.of(context).pop(),
              glowColor: AppColors.accent1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.neonBlue, size: 16),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.assistant(
            color: AppColors.primaryText,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'student':
        return 'תלמיד/ה';
      case 'parent':
        return 'הורה';
      case 'instructor':
        return 'מדריך/ה';
      case 'admin':
        return 'מנהל/ת';
      default:
        return 'משתמש/ת';
    }
  }
}