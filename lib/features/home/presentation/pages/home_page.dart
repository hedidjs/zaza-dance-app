import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_glow/flutter_glow.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/animated_gradient_background.dart';
import '../../../../shared/widgets/neon_text.dart';
import '../../../gallery/presentation/pages/gallery_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: NeonText(
          text: 'זזה דאנס',
          fontSize: 24,
          glowColor: AppColors.neonPink,
        ),
        actions: [
          IconButton(
            icon: GlowIcon(
              Icons.menu,
              color: AppColors.primaryText,
              glowColor: AppColors.neonTurquoise,
            ),
            onPressed: () {
              // TODO: Open menu
            },
          ),
        ],
      ),
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  
                  // Welcome section
                  _buildWelcomeSection(),
                  
                  const SizedBox(height: 40),
                  
                  // Quick actions
                  _buildQuickActions(context),
                  
                  const SizedBox(height: 40),
                  
                  // Featured content
                  _buildFeaturedContent(),
                  
                  const SizedBox(height: 40),
                  
                  // Latest updates
                  _buildLatestUpdates(),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NeonText(
          text: 'ברוכים הבאים לבית הדיגיטלי',
          fontSize: 28,
          glowColor: AppColors.neonPink,
          fontWeight: FontWeight.bold,
        ).animate().fadeIn(duration: 800.ms).slideX(begin: 1),
        
        const SizedBox(height: 10),
        
        NeonText(
          text: 'של קהילת ההיפ הופ',
          fontSize: 28,
          glowColor: AppColors.neonTurquoise,
          fontWeight: FontWeight.bold,
        ).animate().fadeIn(duration: 800.ms, delay: 200.ms).slideX(begin: -1),
        
        const SizedBox(height: 20),
        
        Text(
          'הרגישו את הקצב, השראה והאנרגיה של עולם הריקוד',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.secondaryText,
          ),
        ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NeonText(
          text: 'מה תרצו לעשות היום?',
          fontSize: 20,
          glowColor: AppColors.neonPurple,
        ),
        
        const SizedBox(height: 20),
        
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.video_library,
                title: 'מדריכי ריקוד',
                subtitle: 'תרגלו מהבית',
                color: AppColors.neonPink,
                onTap: () {
                  // TODO: Navigate to tutorials
                },
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildActionCard(
                icon: Icons.photo_library,
                title: 'גלריה',
                subtitle: 'תמונות וסרטונים',
                color: AppColors.neonTurquoise,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const GalleryPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 15),
        
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.announcement,
                title: 'עדכונים',
                subtitle: 'מה חדש בסטודיו',
                color: AppColors.neonPurple,
                onTap: () {
                  // TODO: Navigate to updates
                },
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildActionCard(
                icon: Icons.person,
                title: 'פרופיל',
                subtitle: 'הגדרות אישיות',
                color: AppColors.neonBlue,
                onTap: () {
                  // TODO: Navigate to profile
                },
              ),
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
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.darkSurface,
              AppColors.darkCard,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlowIcon(
              icon,
              color: color,
              glowColor: color,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildFeaturedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NeonText(
          text: 'תוכן מומלץ',
          fontSize: 20,
          glowColor: AppColors.neonTurquoise,
        ),
        
        const SizedBox(height: 20),
        
        Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_circle_filled,
                  size: 60,
                  color: AppColors.primaryText,
                ),
                const SizedBox(height: 10),
                Text(
                  'סרטון פתיחה',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
                Text(
                  'הכירו את הסטודיו',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryText.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLatestUpdates() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NeonText(
          text: 'עדכונים אחרונים',
          fontSize: 20,
          glowColor: AppColors.neonPink,
        ),
        
        const SizedBox(height: 20),
        
        _buildUpdateItem(
          title: 'שיעור חדש ביום רביעי!',
          time: 'לפני 2 שעות',
          isNew: true,
        ),
        
        const SizedBox(height: 10),
        
        _buildUpdateItem(
          title: 'תחרות ריקוד בקרוב',
          time: 'אתמול',
          isNew: false,
        ),
        
        const SizedBox(height: 10),
        
        _buildUpdateItem(
          title: 'מדריך חדש הצטרף לצוות',
          time: 'לפני 3 ימים',
          isNew: false,
        ),
      ],
    );
  }

  Widget _buildUpdateItem({
    required String title,
    required String time,
    required bool isNew,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNew 
              ? AppColors.neonTurquoise.withOpacity(0.3)
              : AppColors.darkBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (isNew)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.neonTurquoise,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonTurquoise.withOpacity(0.5),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          if (isNew) const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.secondaryText,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.backgroundGradient,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          top: BorderSide(
            color: AppColors.neonPink.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        selectedItemColor: AppColors.neonPink,
        unselectedItemColor: AppColors.secondaryText,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'בית',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'מדריכים',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'גלריה',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.announcement),
            label: 'עדכונים',
          ),
        ],
      ),
    );
  }
}