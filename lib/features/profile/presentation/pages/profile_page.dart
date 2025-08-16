import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../shared/widgets/enhanced_neon_effects.dart';
import '../../../../shared/widgets/neon_text.dart';
import '../../providers/profile_provider.dart';
import '../../services/profile_service.dart';
import 'edit_profile_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final profileService = ref.read(profileServiceProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1A1A1A),
                Color(0xFF0F0F0F),
                AppColors.darkBackground,
              ],
              stops: [0.0, 0.6, 1.0],
            ),
          ),
          child: user.when(
            data: (userData) {
              if (userData == null) {
                return _buildNotAuthenticated();
              }
              return _buildProfileContent(userData, profileService);
            },
            loading: () => _buildLoading(),
            error: (error, _) => _buildError(error.toString()),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(dynamic userData, ProfileService profileService) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: CustomScrollView(
        slivers: [
          _buildSliverAppBar(userData, profileService),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildUserInfoCard(userData),
                const SizedBox(height: 20),
                _buildStatsCard(userData.id),
                const SizedBox(height: 20),
                _buildPreferencesCard(userData.id),
                const SizedBox(height: 20),
                _buildSecurityCard(),
                const SizedBox(height: 20),
                _buildActionButtons(userData),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(dynamic userData, ProfileService profileService) {
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.neonPink.withOpacity(0.1),
                AppColors.neonTurquoise.withOpacity(0.1),
                Colors.transparent,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                _buildProfileImage(userData, profileService),
                const SizedBox(height: 20),
                _buildUserTitle(userData, profileService),
              ],
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: IconButton(
            icon: const Icon(Icons.edit, color: AppColors.neonTurquoise),
            onPressed: () => _showEditProfileDialog(userData),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage(dynamic userData, ProfileService profileService) {
    final editingState = ref.watch(profileEditingProvider);
    
    return GestureDetector(
      onTap: () => _updateProfileImage(userData.id),
      child: Stack(
        children: [
          NeonGlowContainer(
            glowColor: AppColors.neonPink,
            animate: true,
            glowRadius: 15,
            opacity: 0.3,
            isSubtle: true,
            borderRadius: BorderRadius.circular(60),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.neonPink.withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipOval(
                child: userData.profileImageUrl != null
                    ? Image.network(
                        userData.profileImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultAvatar(userData, profileService);
                        },
                      )
                    : _buildDefaultAvatar(userData, profileService),
              ),
            ),
          ),
          if (editingState.isLoading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.7),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.neonPink,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            child: NeonGlowContainer(
              glowColor: AppColors.neonTurquoise,
              glowRadius: 8,
              opacity: 0.4,
              isSubtle: true,
              borderRadius: BorderRadius.circular(15),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.neonTurquoise.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 16,
                  color: AppColors.neonTurquoise,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(dynamic userData, ProfileService profileService) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.neonPink.withOpacity(0.3),
            AppColors.neonTurquoise.withOpacity(0.3),
          ],
        ),
      ),
      child: Center(
        child: Text(
          profileService.getRoleIcon(userData.role),
          style: const TextStyle(fontSize: 40),
        ),
      ),
    );
  }

  Widget _buildUserTitle(dynamic userData, ProfileService profileService) {
    return Column(
      children: [
        NeonText(
          text: userData.displayName,
          fontSize: 24,
          glowColor: AppColors.neonPink,
          fontWeight: FontWeight.bold,
          isSubtle: true,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.neonTurquoise.withOpacity(0.3),
                    AppColors.neonTurquoise.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.neonTurquoise.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    profileService.getRoleIcon(userData.role),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    profileService.getRoleDisplayName(userData.role),
                    style: GoogleFonts.assistant(
                      color: AppColors.primaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserInfoCard(dynamic userData) {
    return NeonGlowContainer(
      glowColor: AppColors.neonTurquoise,
      glowRadius: 12,
      opacity: 0.15,
      isSubtle: true,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.authCardBackground.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.neonTurquoise.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: AppColors.neonTurquoise.withOpacity(0.8),
                  size: 20,
                ),
                const SizedBox(width: 8),
                NeonText(
                  text: 'פרטים אישיים',
                  fontSize: 18,
                  glowColor: AppColors.neonTurquoise,
                  fontWeight: FontWeight.w600,
                  isSubtle: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('שם מלא', userData.fullName ?? 'לא הוזן', Icons.person_outline),
            _buildInfoRow('אימייל', userData.email, Icons.email_outlined),
            if (userData.phoneNumber != null)
              _buildInfoRow('טלפון', userData.phoneNumber!, Icons.phone_outlined),
            if (userData.address != null)
              _buildInfoRow('כתובת', userData.address!, Icons.location_on_outlined),
            if (userData.birthDate != null)
              _buildInfoRow(
                'תאריך לידה',
                DateFormat('dd/MM/yyyy').format(userData.birthDate!),
                Icons.cake_outlined,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.secondaryText,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.assistant(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.assistant(
                    color: AppColors.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(String userId) {
    final statsAsync = ref.watch(userStatsProvider(userId));
    
    return statsAsync.when(
      data: (stats) => NeonGlowContainer(
        glowColor: AppColors.neonPink,
        glowRadius: 12,
        opacity: 0.15,
        isSubtle: true,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.authCardBackground.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.neonPink.withOpacity(0.2),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.analytics,
                    color: AppColors.neonPink.withOpacity(0.8),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  NeonText(
                    text: 'סטטיסטיקות',
                    fontSize: 18,
                    glowColor: AppColors.neonPink,
                    fontWeight: FontWeight.w600,
                    isSubtle: true,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'רמת ריקוד',
                      stats['danceLevel'] ?? '',
                      Icons.stars,
                      AppColors.neonPink,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'מדריכים שנצפו',
                      '${stats['instructorsWatched'] ?? 0}',
                      Icons.people,
                      AppColors.neonTurquoise,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'ימי נוכחות',
                      '${stats['attendanceDays'] ?? 0}',
                      Icons.calendar_today,
                      AppColors.neonPink,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'הישגים',
                      '${(stats['achievements'] as List?)?.length ?? 0}',
                      Icons.emoji_events,
                      AppColors.neonTurquoise,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      loading: () => _buildLoadingCard(),
      error: (error, _) => _buildErrorCard(),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color.withOpacity(0.8), size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.assistant(
              color: AppColors.primaryText,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.assistant(
              color: AppColors.secondaryText,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard(String userId) {
    final preferencesAsync = ref.watch(userPreferencesProvider(userId));
    
    return preferencesAsync.when(
      data: (preferences) => NeonGlowContainer(
        glowColor: AppColors.neonTurquoise,
        glowRadius: 12,
        opacity: 0.15,
        isSubtle: true,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.authCardBackground.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.neonTurquoise.withOpacity(0.2),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.settings,
                    color: AppColors.neonTurquoise.withOpacity(0.8),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  NeonText(
                    text: 'העדפות',
                    fontSize: 18,
                    glowColor: AppColors.neonTurquoise,
                    fontWeight: FontWeight.w600,
                    isSubtle: true,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildPreferenceToggle(
                'התראות',
                preferences['notifications_enabled'] ?? true,
                Icons.notifications,
                (value) => _updatePreference(userId, 'notifications_enabled', value),
              ),
              _buildPreferenceToggle(
                'התראות אימייל',
                preferences['email_notifications'] ?? true,
                Icons.email,
                (value) => _updatePreference(userId, 'email_notifications', value),
              ),
              _buildPreferenceToggle(
                'ניגון אוטומטי',
                preferences['auto_play_videos'] ?? true,
                Icons.play_circle,
                (value) => _updatePreference(userId, 'auto_play_videos', value),
              ),
            ],
          ),
        ),
      ),
      loading: () => _buildLoadingCard(),
      error: (error, _) => _buildErrorCard(),
    );
  }

  Widget _buildPreferenceToggle(
    String title,
    bool value,
    IconData icon,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.secondaryText,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.assistant(
                color: AppColors.primaryText,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.neonTurquoise,
            inactiveThumbColor: AppColors.secondaryText,
            inactiveTrackColor: AppColors.darkSurface,
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard() {
    return NeonGlowContainer(
      glowColor: AppColors.neonPink,
      glowRadius: 12,
      opacity: 0.15,
      isSubtle: true,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.authCardBackground.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.neonPink.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.security,
                  color: AppColors.neonPink.withOpacity(0.8),
                  size: 20,
                ),
                const SizedBox(width: 8),
                NeonText(
                  text: 'אבטחה',
                  fontSize: 18,
                  glowColor: AppColors.neonPink,
                  fontWeight: FontWeight.w600,
                  isSubtle: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildActionItem(
              'שינוי סיסמה',
              'עדכון סיסמת החשבון',
              Icons.lock,
              () => _showChangePasswordDialog(),
            ),
            _buildActionItem(
              'אימות דו-שלבי',
              'הגדרת אבטחה מתקדמת',
              Icons.verified_user,
              () => _showComingSoonDialog('אימות דו-שלבי'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.secondaryText,
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
                      color: AppColors.primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.assistant(
                      color: AppColors.secondaryText,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.secondaryText,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(dynamic userData) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: NeonButton(
            text: 'עריכת פרופיל',
            onPressed: () => _navigateToEditProfile(context),
            glowColor: AppColors.neonTurquoise,
            fontSize: 16,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: NeonButton(
            text: 'יציאה מהמערכת',
            onPressed: _handleLogout,
            glowColor: AppColors.error,
            fontSize: 16,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.authCardBackground.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.neonTurquoise,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.authCardBackground.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error.withOpacity(0.8),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            'שגיאה בטעינת הנתונים',
            style: GoogleFonts.assistant(
              color: AppColors.error,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.neonPink,
        strokeWidth: 3,
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'שגיאה בטעינת הפרופיל',
            style: GoogleFonts.assistant(
              color: AppColors.error,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: GoogleFonts.assistant(
              color: AppColors.secondaryText,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotAuthenticated() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off,
            color: AppColors.secondaryText,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'לא מחובר למערכת',
            style: GoogleFonts.assistant(
              color: AppColors.secondaryText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          NeonButton(
            text: 'התחברות',
            onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
            glowColor: AppColors.neonPink,
          ),
        ],
      ),
    );
  }

  // Event handlers
  Future<void> _updateProfileImage(String userId) async {
    final success = await ref.read(profileEditingProvider.notifier).updateProfileImage(userId);
    
    if (success && mounted) {
      _showMessage('תמונת הפרופיל עודכנה בהצלחה');
    } else if (mounted) {
      final error = ref.read(profileEditingProvider).error;
      _showMessage(error ?? 'שגיאה בעדכון תמונת הפרופיל', isError: true);
    }
  }

  Future<void> _updatePreference(String userId, String key, dynamic value) async {
    try {
      await ref.read(userPreferencesProvider(userId).notifier).updatePreference(key, value);
      if (mounted) {
        _showMessage('ההעדפה עודכנה בהצלחה');
      }
    } catch (error) {
      if (mounted) {
        _showMessage('שגיאה בעדכון העדפה', isError: true);
      }
    }
  }

  void _navigateToEditProfile(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EditProfilePage(),
      ),
    );
    
    // If profile was updated, show success message
    if (result == true && mounted) {
      _showMessage('הפרופיל עודכן בהצלחה');
    }
  }

  void _showEditProfileDialog(dynamic userData) {
    showDialog(
      context: context,
      builder: (context) => _ProfileEditDialog(userData: userData),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => const _ChangePasswordDialog(),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.authCardBackground,
        title: Text(
          'בקרוב',
          style: GoogleFonts.assistant(color: AppColors.primaryText),
        ),
        content: Text(
          'התכונה "$feature" תהיה זמינה בקרוב.',
          style: GoogleFonts.assistant(color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'אישור',
              style: GoogleFonts.assistant(color: AppColors.neonTurquoise),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.authCardBackground,
        title: Text(
          'יציאה מהמערכת',
          style: GoogleFonts.assistant(color: AppColors.primaryText),
        ),
        content: Text(
          'האם אתם בטוחים שברצונכם לצאת מהמערכת?',
          style: GoogleFonts.assistant(color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'ביטול',
              style: GoogleFonts.assistant(color: AppColors.secondaryText),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'יציאה',
              style: GoogleFonts.assistant(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final result = await ref.read(currentUserProvider.notifier).signOut();
      if (result.isSuccess && mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      } else if (mounted) {
        _showMessage('שגיאה ביציאה מהמערכת', isError: true);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.assistant(
            color: AppColors.primaryText,
          ),
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// Dialog for editing profile
class _ProfileEditDialog extends ConsumerStatefulWidget {
  final dynamic userData;

  const _ProfileEditDialog({required this.userData});

  @override
  ConsumerState<_ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends ConsumerState<_ProfileEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  DateTime? _selectedBirthDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData.fullName ?? '');
    _phoneController = TextEditingController(text: widget.userData.phoneNumber ?? '');
    _addressController = TextEditingController(text: widget.userData.address ?? '');
    _selectedBirthDate = widget.userData.birthDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editingState = ref.watch(profileEditingProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: AppColors.authCardBackground,
        title: Text(
          'עריכת פרופיל',
          style: GoogleFonts.assistant(
            color: AppColors.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(
                  controller: _nameController,
                  label: 'שם מלא',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'אנא הזינו שם מלא';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _phoneController,
                  label: 'טלפון',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _addressController,
                  label: 'כתובת',
                  icon: Icons.location_on,
                ),
                const SizedBox(height: 16),
                _buildDateField(),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: editingState.isLoading ? null : () => Navigator.of(context).pop(),
            child: Text(
              'ביטול',
              style: GoogleFonts.assistant(color: AppColors.secondaryText),
            ),
          ),
          TextButton(
            onPressed: editingState.isLoading ? null : _handleSave,
            child: editingState.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: AppColors.neonTurquoise,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'שמירה',
                    style: GoogleFonts.assistant(color: AppColors.neonTurquoise),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.assistant(color: AppColors.primaryText),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.assistant(color: AppColors.secondaryText),
        prefixIcon: Icon(icon, color: AppColors.neonTurquoise.withOpacity(0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputFocusedBorder, width: 2),
        ),
        filled: true,
        fillColor: AppColors.darkSurface,
      ),
      validator: validator,
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _selectBirthDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Row(
          children: [
            Icon(
              Icons.cake,
              color: AppColors.neonTurquoise.withOpacity(0.7),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'תאריך לידה',
                    style: GoogleFonts.assistant(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _selectedBirthDate != null
                        ? DateFormat('dd/MM/yyyy').format(_selectedBirthDate!)
                        : 'לא נבחר',
                    style: GoogleFonts.assistant(
                      color: AppColors.primaryText,
                      fontSize: 16,
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

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.neonTurquoise,
              onPrimary: AppColors.darkBackground,
              surface: AppColors.authCardBackground,
              onSurface: AppColors.primaryText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(profileEditingProvider.notifier).updateProfile(
      userId: widget.userData.id,
      fullName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
      address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
      birthDate: _selectedBirthDate,
    );

    if (mounted) {
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'הפרופיל עודכן בהצלחה',
              style: GoogleFonts.assistant(color: AppColors.primaryText),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        final error = ref.read(profileEditingProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error ?? 'שגיאה בעדכון הפרופיל',
              style: GoogleFonts.assistant(color: AppColors.primaryText),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

// Dialog for changing password
class _ChangePasswordDialog extends ConsumerStatefulWidget {
  const _ChangePasswordDialog();

  @override
  ConsumerState<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editingState = ref.watch(profileEditingProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: AppColors.authCardBackground,
        title: Text(
          'שינוי סיסמה',
          style: GoogleFonts.assistant(
            color: AppColors.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPasswordField(
                controller: _newPasswordController,
                label: 'סיסמה חדשה',
                isVisible: _isNewPasswordVisible,
                onToggleVisibility: () => setState(() => _isNewPasswordVisible = !_isNewPasswordVisible),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'אנא הזינו סיסמה חדשה';
                  }
                  if (value.length < 6) {
                    return 'הסיסמה חייבת להכיל לפחות 6 תווים';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                controller: _confirmPasswordController,
                label: 'אימות סיסמה',
                isVisible: _isConfirmPasswordVisible,
                onToggleVisibility: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'אנא אמתו את הסיסמה';
                  }
                  if (value != _newPasswordController.text) {
                    return 'הסיסמאות אינן תואמות';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: editingState.isLoading ? null : () => Navigator.of(context).pop(),
            child: Text(
              'ביטול',
              style: GoogleFonts.assistant(color: AppColors.secondaryText),
            ),
          ),
          TextButton(
            onPressed: editingState.isLoading ? null : _handleChangePassword,
            child: editingState.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: AppColors.neonPink,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'שינוי סיסמה',
                    style: GoogleFonts.assistant(color: AppColors.neonPink),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      style: GoogleFonts.assistant(color: AppColors.primaryText),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.assistant(color: AppColors.secondaryText),
        prefixIcon: Icon(Icons.lock, color: AppColors.neonPink.withOpacity(0.7)),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility_off : Icons.visibility,
            color: AppColors.secondaryText,
          ),
          onPressed: onToggleVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputFocusedBorder, width: 2),
        ),
        filled: true,
        fillColor: AppColors.darkSurface,
      ),
      validator: validator,
    );
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(profileEditingProvider.notifier).changePassword(
      _newPasswordController.text,
    );

    if (mounted) {
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'הסיסמה שונתה בהצלחה',
              style: GoogleFonts.assistant(color: AppColors.primaryText),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        final error = ref.read(profileEditingProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error ?? 'שגיאה בשינוי הסיסמה',
              style: GoogleFonts.assistant(color: AppColors.primaryText),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}