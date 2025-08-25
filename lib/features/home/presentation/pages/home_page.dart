import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/tutorials_provider.dart';
import '../../../../core/providers/updates_provider.dart';
import '../../../../core/providers/gallery_provider.dart';
import '../../../../shared/widgets/animated_gradient_background.dart';
import '../../../../shared/widgets/neon_text.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/app_bottom_navigation.dart';
import '../../../../shared/widgets/zaza_logo.dart';
import '../../../../shared/models/tutorial_model.dart';
import '../../../../shared/models/update_model.dart';
import '../../../../shared/models/gallery_model.dart';
import '../../../../shared/models/user_model.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final featuredTutorials = ref.watch(featuredTutorialsProvider);
    final recentUpdates = ref.watch(recentUpdatesProvider);
    final featuredGallery = ref.watch(featuredGalleryProvider);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const ZazaLogo.appBar(),
          centerTitle: true,
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
        ),
        drawer: const AppDrawer(),
        body: AnimatedGradientBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    
                    // Quick actions
                    _buildQuickActions(context),
                    
                    const SizedBox(height: 40),
                    
                    // Featured content
                    _buildFeaturedContent(ref, featuredTutorials, featuredGallery),
                    
                    const SizedBox(height: 40),
                    
                    // Latest updates
                    _buildLatestUpdates(context, ref, recentUpdates),
                    
                    const SizedBox(height: 30),
                    
                    // User stats section
                    _buildUserStats(context, ref, user),
                    
                    const SizedBox(height: 20),
                  ],
                ),
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


  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        NeonText(
          text: 'מה תרצו לעשות היום?',
          fontSize: 24,
          glowColor: AppColors.neonPink,
        ).animate().fadeIn(duration: 600.ms),
        
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
                  GoRouter.of(context).go('/tutorials');
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
                  GoRouter.of(context).go('/gallery');
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
                  GoRouter.of(context).go('/updates');
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
                  GoRouter.of(context).go('/profile');
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
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
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

  Widget _buildFeaturedContent(WidgetRef ref, AsyncValue<List<TutorialModel>> featuredTutorials, AsyncValue<List<GalleryModel>> featuredGallery) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NeonText(
          text: 'תוכן מומלץ',
          fontSize: 20,
          glowColor: AppColors.neonTurquoise,
        ),
        
        const SizedBox(height: 20),
        
        // Featured tutorials section
        featuredTutorials.when(
          data: (tutorials) => tutorials.isNotEmpty 
              ? _buildFeaturedTutorialsCarousel(tutorials)
              : _buildNoContentPlaceholder('מדריכים חדשים בטעינה... 🎬', Icons.video_library),
          loading: () => _buildLoadingPlaceholder('טוען מדריכים מומלצים...'),
          error: (error, stack) => _buildErrorPlaceholder('שגיאה בטעינת מדריכים', () => ref.refresh(featuredTutorialsProvider)),
        ),
        
        const SizedBox(height: 20),
        
        // Featured gallery section
        featuredGallery.when(
          data: (gallery) => gallery.isNotEmpty 
              ? Builder(
                  builder: (context) => _buildFeaturedGalleryRow(context, gallery),
                )
              : Container(),
          loading: () => Container(),
          error: (error, stack) => Container(),
        ),
      ],
    );
  }

  Widget _buildFeaturedTutorialsCarousel(List<TutorialModel> tutorials) {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: tutorials.length,
        itemBuilder: (context, index) {
          final tutorial = tutorials[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => GoRouter.of(context).go('/tutorials'),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GlowIcon(
                            Icons.play_circle_filled,
                            color: AppColors.primaryText,
                            glowColor: AppColors.neonTurquoise,
                            size: 40,
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.neonTurquoise.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getDifficultyText(tutorial.difficultyLevel),
                              style: TextStyle(
                                color: AppColors.neonTurquoise,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        tutorial.titleHe,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      if (tutorial.descriptionHe?.isNotEmpty == true)
                        Text(
                          tutorial.descriptionHe!,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primaryText.withValues(alpha: 0.8),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: AppColors.secondaryText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${(tutorial.durationSeconds ?? 0) ~/ 60} דקות',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.secondaryText,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.visibility,
                            size: 16,
                            color: AppColors.secondaryText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${tutorial.viewsCount}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedGalleryRow(BuildContext context, List<GalleryModel> gallery) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            NeonText(
              text: 'תמונות אחרונות',
              fontSize: 16,
              glowColor: AppColors.neonPink,
            ),
            const Spacer(),
            TextButton(
              onPressed: () => GoRouter.of(context).go('/gallery'),
              child: Text(
                'צפייה בכל התמונות',
                style: TextStyle(
                  color: AppColors.neonTurquoise,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: gallery.length,
            itemBuilder: (context, index) {
              final item = gallery[index];
              return Container(
                width: 80,
                margin: const EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.neonPink.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item.thumbnailUrl != null
                      ? Image.network(
                          item.thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                              _buildGalleryPlaceholder(),
                        )
                      : _buildGalleryPlaceholder(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGalleryPlaceholder() {
    return Container(
      color: AppColors.darkSurface,
      child: Center(
        child: Icon(
          Icons.image,
          color: AppColors.secondaryText,
          size: 24,
        ),
      ),
    );
  }

  String _getDifficultyText(DifficultyLevel? level) {
    if (level == null) return 'לא צוין';
    switch (level) {
      case DifficultyLevel.beginner:
        return 'מתחיל';
      case DifficultyLevel.intermediate:
        return 'בינוני';
      case DifficultyLevel.advanced:
        return 'מתקדם';
    }
  }

  Widget _buildLoadingPlaceholder(String message) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.darkBorder,
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.neonTurquoise,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoContentPlaceholder(String message, IconData icon) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.darkBorder,
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: AppColors.secondaryText,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder(String message, VoidCallback onRetry) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 50,
              color: AppColors.error,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.primaryText,
              ),
              child: const Text('נסה שוב'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestUpdates(BuildContext context, WidgetRef ref, AsyncValue<List<UpdateModel>> recentUpdates) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            NeonText(
              text: 'עדכונים אחרונים',
              fontSize: 20,
              glowColor: AppColors.neonPink,
            ),
            const Spacer(),
            TextButton(
              onPressed: () => GoRouter.of(context).go('/updates'),
              child: Text(
                'כל העדכונים',
                style: TextStyle(
                  color: AppColors.neonPink,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        recentUpdates.when(
          data: (updates) {
            if (updates.isEmpty) {
              return _buildUpdateItem(
                context: context,
                title: 'ברוכים הבאים לזזה דאנס! 🎉',
                time: 'הצטרפתם לקהילת הריקוד הכי אנרגטית בארץ',
                isNew: true,
                isEmpty: false,
                onTap: () => GoRouter.of(context).go('/updates'),
              );
            }
            
            return Column(
              children: updates.take(3).map((update) {
                final isNew = DateTime.now().difference(update.createdAt).inHours < 24;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildUpdateItem(
                    context: context,
                    title: update.titleHe,
                    time: _formatTimeAgo(update.createdAt),
                    isNew: isNew,
                    updateType: update.updateType.value,
                    onTap: () {
                      ref.read(updatesProvider.notifier).incrementViews(update.id);
                      GoRouter.of(context).go('/updates');
                    },
                  ),
                );
              }).toList(),
            );
          },
          loading: () => Column(
            children: List.generate(3, (index) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildUpdateItem(
                  context: context,
                  title: 'טוען עדכון...',
                  time: 'טוען...',
                  isNew: false,
                  isLoading: true,
                ),
              ),
            ),
          ),
          error: (error, stack) => _buildUpdateItem(
            context: context,
            title: 'שגיאה בטעינת עדכונים',
            time: 'לחץ לניסיון חוזר',
            isNew: false,
            onTap: () => ref.refresh(recentUpdatesProvider),
          ),
        ),
      ],
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 60) {
      return 'לפני ${difference.inMinutes} דקות';
    } else if (difference.inHours < 24) {
      return 'לפני ${difference.inHours} שעות';
    } else if (difference.inDays < 7) {
      return 'לפני ${difference.inDays} ימים';
    } else {
      return intl.DateFormat('dd/MM', 'he').format(dateTime);
    }
  }

  Widget _buildUpdateItem({
    required BuildContext context,
    required String title,
    required String time,
    required bool isNew,
    String? updateType,
    VoidCallback? onTap,
    bool isLoading = false,
    bool isEmpty = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isEmpty ? AppColors.darkCard : AppColors.darkSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isNew 
                  ? AppColors.neonTurquoise.withValues(alpha: 0.3)
                  : AppColors.darkBorder,
              width: 1,
            ),
            boxShadow: isNew ? [
              BoxShadow(
                color: AppColors.neonTurquoise.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ] : null,
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
                        color: AppColors.neonTurquoise.withValues(alpha: 0.5),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              if (isNew) const SizedBox(width: 12),
              
              // Update type icon
              if (updateType != null && !isLoading && !isEmpty)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _getUpdateTypeColor(updateType).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    _getUpdateTypeIcon(updateType),
                    size: 16,
                    color: _getUpdateTypeColor(updateType),
                  ),
                ),
              if (updateType != null && !isLoading && !isEmpty) const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isLoading)
                      Container(
                        width: double.infinity,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.darkBorder,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )
                    else
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isEmpty ? AppColors.secondaryText : AppColors.primaryText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    if (isLoading)
                      Container(
                        width: 100,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.darkBorder,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )
                    else
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
              if (!isLoading && !isEmpty)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.secondaryText,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getUpdateTypeColor(String updateType) {
    switch (updateType.toLowerCase()) {
      case 'announcement':
        return AppColors.neonTurquoise;
      case 'event':
        return AppColors.neonPink;
      case 'class':
        return AppColors.neonPurple;
      default:
        return AppColors.neonBlue;
    }
  }

  IconData _getUpdateTypeIcon(String updateType) {
    switch (updateType.toLowerCase()) {
      case 'announcement':
        return Icons.announcement;
      case 'event':
        return Icons.event;
      case 'class':
        return Icons.school;
      default:
        return Icons.info;
    }
  }

  Widget _buildUserStats(BuildContext context, WidgetRef ref, AsyncValue<UserModel?> user) {
    return user.when(
      data: (userData) {
        if (userData == null) return Container();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NeonText(
              text: 'הסטטיסטיקות שלך',
              fontSize: 20,
              glowColor: AppColors.neonBlue,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    icon: Icons.video_library,
                    title: 'שיעורים שצפיתי',
                    value: '12', // This would come from user progress data
                    color: AppColors.neonTurquoise,
                    onTap: () => GoRouter.of(context).go('/tutorials'),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    icon: Icons.access_time,
                    title: 'זמן תרגול',
                    value: '8.5 שעות',
                    color: AppColors.neonPink,
                    onTap: () => GoRouter.of(context).go('/profile'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    icon: Icons.favorite,
                    title: 'מועדפים',
                    value: '5',
                    color: AppColors.neonPurple,
                    onTap: () => GoRouter.of(context).go('/tutorials'),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    icon: Icons.military_tech,
                    title: 'רמה נוכחית',
                    value: 'בינוני',
                    color: AppColors.neonBlue,
                    onTap: () => GoRouter.of(context).go('/profile'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
      loading: () => Container(),
      error: (error, stack) => Container(),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.darkSurface,
              AppColors.darkCard,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
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
              size: 24,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.9, 0.9));
  }
}