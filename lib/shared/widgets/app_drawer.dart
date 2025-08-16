import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/gallery/presentation/pages/gallery_page.dart';
import '../../features/tutorials/presentation/pages/tutorials_page.dart';
import '../../features/updates/presentation/pages/updates_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/admin/presentation/pages/admin_page.dart';
import 'enhanced_neon_effects.dart';
import 'neon_text.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final canAccessAdmin = ref.watch(canAccessAdminProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Drawer(
        backgroundColor: AppColors.darkBackground,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.backgroundGradient,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              _buildHeader(context, currentUser, isAuthenticated),
              Expanded(
                child: _buildMenuItems(context, ref, isAuthenticated, canAccessAdmin),
              ),
              if (isAuthenticated) _buildFooter(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AsyncValue currentUser, bool isAuthenticated) {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonPink.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              NeonGlowContainer(
                glowColor: AppColors.neonTurquoise,
                animate: true,
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.darkSurface,
                  child: Icon(
                    isAuthenticated ? Icons.person : Icons.person_outline,
                    size: 30,
                    color: AppColors.neonTurquoise,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isAuthenticated) ...[
                      currentUser.when(
                        data: (user) => NeonText(
                          text: user?.displayName ?? 'משתמש',
                          fontSize: 20,
                          glowColor: AppColors.primaryText,
                        ),
                        loading: () => const CircularProgressIndicator(
                          color: AppColors.neonTurquoise,
                          strokeWidth: 2,
                        ),
                        error: (_, __) => NeonText(
                          text: 'משתמש',
                          fontSize: 20,
                          glowColor: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 5),
                      currentUser.when(
                        data: (user) => Text(
                          _getRoleDisplayName(user?.role ?? 'student'),
                          style: GoogleFonts.assistant(
                            color: AppColors.primaryText.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ] else ...[
                      NeonText(
                        text: 'ברוכים הבאים',
                        fontSize: 18,
                        glowColor: AppColors.primaryText,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'היכנסו לחשבון שלכם',
                        style: GoogleFonts.assistant(
                          color: AppColors.primaryText.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context, WidgetRef ref, bool isAuthenticated, bool canAccessAdmin) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 10),
      children: [
        _buildMenuItem(
          context,
          icon: Icons.home,
          title: 'בית',
          onTap: () => _navigateToPage(context, const HomePage()),
          glowColor: AppColors.neonPink,
        ),
        _buildMenuItem(
          context,
          icon: Icons.video_library,
          title: 'מדריכי ריקוד',
          onTap: () => _navigateToPage(context, const TutorialsPage()),
          glowColor: AppColors.neonTurquoise,
        ),
        _buildMenuItem(
          context,
          icon: Icons.photo_library,
          title: 'גלריה',
          onTap: () => _navigateToPage(context, const GalleryPage()),
          glowColor: AppColors.neonPurple,
        ),
        _buildMenuItem(
          context,
          icon: Icons.announcement,
          title: 'עדכונים',
          onTap: () => _navigateToPage(context, const UpdatesPage()),
          glowColor: AppColors.neonBlue,
        ),
        
        if (isAuthenticated) ...[
          const NeonDivider(),
          _buildMenuItem(
            context,
            icon: Icons.person,
            title: 'פרופיל אישי',
            onTap: () => _navigateToPage(context, const ProfilePage()),
            glowColor: AppColors.neonGreen,
          ),
          _buildMenuItem(
            context,
            icon: Icons.settings,
            title: 'הגדרות',
            onTap: () => _navigateToPage(context, const SettingsPage()),
            glowColor: AppColors.accent1,
          ),
        ],

        // Admin functionality temporarily disabled - keeping backend structure intact
        // if (canAccessAdmin) ...[
        //   const NeonDivider(),
        //   _buildMenuItem(
        //     context,
        //     icon: Icons.admin_panel_settings,
        //     title: 'ניהול מערכת',
        //     onTap: () => _navigateToPage(context, const AdminPage()),
        //     glowColor: AppColors.warning,
        //   ),
        // ],

        if (!isAuthenticated) ...[
          const NeonDivider(),
          _buildMenuItem(
            context,
            icon: Icons.login,
            title: 'התחברות',
            onTap: () => _navigateToPage(context, const LoginPage()),
            glowColor: AppColors.neonGreen,
          ),
        ],

        const NeonDivider(),
        _buildMenuItem(
          context,
          icon: Icons.info_outline,
          title: 'אודות הסטודיו',
          onTap: () {
            Navigator.of(context).pop();
            _showAboutDialog(context);
          },
          glowColor: AppColors.info,
        ),
        _buildMenuItem(
          context,
          icon: Icons.contact_phone,
          title: 'יצירת קשר',
          onTap: () {
            Navigator.of(context).pop();
            _showContactDialog(context);
          },
          glowColor: AppColors.accent2,
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color glowColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: glowColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: glowColor,
                  size: 24,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.assistant(
                      color: AppColors.primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
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

  Widget _buildFooter(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.neonTurquoise.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: NeonButton(
          text: 'התנתקות',
          onPressed: () => _handleLogout(context, ref),
          glowColor: AppColors.error,
          fontSize: 16,
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.of(context).pop();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    Navigator.of(context).pop();
    
    final result = await ref.read(currentUserProvider.notifier).signOut();
    
    if (context.mounted) {
      if (result.isSuccess) {
        Navigator.of(context).pushReplacementNamed('/');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.message,
              style: GoogleFonts.assistant(color: AppColors.primaryText),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: AppColors.neonTurquoise.withOpacity(0.3),
              width: 1,
            ),
          ),
          title: NeonText(
            text: 'בקרוב',
            fontSize: 20,
            glowColor: AppColors.neonTurquoise,
          ),
          content: Text(
            feature,
            style: GoogleFonts.assistant(
              color: AppColors.primaryText,
              fontSize: 16,
            ),
          ),
          actions: [
            NeonButton(
              text: 'הבנתי',
              onPressed: () => Navigator.of(context).pop(),
              glowColor: AppColors.neonTurquoise,
            ),
          ],
        ),
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
              color: AppColors.neonPink.withOpacity(0.3),
              width: 1,
            ),
          ),
          title: NeonText(
            text: 'אודות זזה דאנס',
            fontSize: 20,
            glowColor: AppColors.neonPink,
          ),
          content: Text(
            'זזה דאנס הוא מקום בו הקצב מתחיל, הריתמוס מדבר והאנרגיה של ההיפ הופ חיה.\n\n'
            'כאן כל תלמיד מוצא את הביטוי הייחודי שלו ובונה ביטחון דרך התנועה.\n\n'
            'בואו להיות חלק מהקהילה שלנו!',
            style: GoogleFonts.assistant(
              color: AppColors.primaryText,
              fontSize: 16,
              height: 1.5,
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

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: AppColors.neonTurquoise.withOpacity(0.3),
              width: 1,
            ),
          ),
          title: NeonText(
            text: 'יצירת קשר',
            fontSize: 20,
            glowColor: AppColors.neonTurquoise,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildContactInfo(Icons.phone, 'טלפון: 050-123-4567'),
              const SizedBox(height: 10),
              _buildContactInfo(Icons.email, 'אימייל: info@zazadance.com'),
              const SizedBox(height: 10),
              _buildContactInfo(Icons.location_on, 'כתובת: רחוב הריקוד 10, תל אביב'),
              const SizedBox(height: 10),
              _buildContactInfo(Icons.schedule, 'שעות פעילות: א-ה 16:00-21:00'),
            ],
          ),
          actions: [
            NeonButton(
              text: 'סגור',
              onPressed: () => Navigator.of(context).pop(),
              glowColor: AppColors.neonTurquoise,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.neonTurquoise, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.assistant(
              color: AppColors.primaryText,
              fontSize: 14,
            ),
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