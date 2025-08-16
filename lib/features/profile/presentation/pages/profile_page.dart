import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../shared/widgets/enhanced_neon_effects.dart';
import '../../../../shared/widgets/neon_text.dart';

/// עמוד פרופיל משתמש
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: NeonText(
            text: 'פרופיל אישי',
            fontSize: 20,
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
            IconButton(
              icon: Icon(
                Icons.edit,
                color: AppColors.neonTurquoise,
              ),
              onPressed: () => context.push('/profile/edit'),
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.backgroundGradient,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: currentUser.when(
              data: (user) => _buildContent(context, user),
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.neonTurquoise,
                ),
              ),
              error: (error, stack) => Center(
                child: Text(
                  'שגיאה בטעינת הפרופיל',
                  style: GoogleFonts.assistant(
                    color: AppColors.error,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, dynamic user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildProfileHeader(context, user),
          const SizedBox(height: 30),
          _buildUserInfo(user),
          const SizedBox(height: 30),
          _buildStats(user),
          const SizedBox(height: 30),
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, dynamic user) {
    return Column(
      children: [
        NeonGlowContainer(
          glowColor: AppColors.neonTurquoise,
          animate: true,
          child: CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.darkSurface,
            backgroundImage: user?.profileImageUrl != null
                ? NetworkImage(user!.profileImageUrl!)
                : null,
            child: user?.profileImageUrl == null
                ? Icon(
                    Icons.person,
                    size: 60,
                    color: AppColors.neonTurquoise,
                  )
                : null,
          ),
        ),
        const SizedBox(height: 20),
        NeonText(
          text: user?.displayName ?? 'משתמש',
          fontSize: 24,
          glowColor: AppColors.neonPink,
        ),
        const SizedBox(height: 8),
        Text(
          _getRoleDisplayName(user?.role ?? 'student'),
          style: GoogleFonts.assistant(
            color: AppColors.secondaryText,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.cardGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.neonTurquoise.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NeonText(
            text: 'פרטים אישיים',
            fontSize: 18,
            glowColor: AppColors.neonTurquoise,
          ),
          const SizedBox(height: 15),
          _buildInfoRow(Icons.email, 'אימייל', user?.email ?? ''),
          if (user?.phoneNumber != null)
            _buildInfoRow(Icons.phone, 'טלפון', user!.phoneNumber!),
          if (user?.address != null)
            _buildInfoRow(Icons.location_on, 'כתובת', user!.address!),
          if (user?.bio != null)
            _buildInfoRow(Icons.info, 'אודותיי', user!.bio!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.neonTurquoise.withOpacity(0.7),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: GoogleFonts.assistant(
              color: AppColors.secondaryText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.assistant(
                color: AppColors.primaryText,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.cardGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.neonPink.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NeonText(
            text: 'הסטטיסטיקות שלי',
            fontSize: 18,
            glowColor: AppColors.neonPink,
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('רמת ריקוד', 'מתחיל', AppColors.neonGreen),
              _buildStatItem('מדריכים', '12', AppColors.neonTurquoise),
              _buildStatItem('ימי נוכחות', '45', AppColors.neonPink),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.assistant(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.assistant(
            color: AppColors.secondaryText,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: NeonButton(
            text: 'עריכת פרופיל',
            onPressed: () => context.push('/profile/edit'),
            glowColor: AppColors.neonTurquoise,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: NeonButton(
            text: 'הגדרות',
            onPressed: () => context.push('/settings'),
            glowColor: AppColors.neonPink,
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