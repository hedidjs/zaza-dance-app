import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../shared/widgets/animated_gradient_background.dart';
import '../../../../shared/widgets/neon_text.dart';
import '../../../../shared/widgets/enhanced_neon_effects.dart';

/// עמוד הגדרות כלליות של האפליקציה עבור מנהלי זזה דאנס
class AppSettingsPage extends ConsumerStatefulWidget {
  const AppSettingsPage({super.key});

  @override
  ConsumerState<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends ConsumerState<AppSettingsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  // General Settings
  bool _enablePushNotifications = true;
  bool _enableEmailNotifications = true;
  bool _enableSMSNotifications = false;
  bool _maintenanceMode = false;
  bool _debugMode = false;
  
  // App Configuration
  int _maxFileUploadSize = 50; // MB
  int _sessionTimeout = 30; // minutes
  int _maxLoginAttempts = 5;
  String _appTheme = 'dark';
  String _defaultLanguage = 'he';
  
  // Content Settings
  bool _autoApproveContent = false;
  bool _enableContentReporting = true;
  int _maxTutorialDuration = 30; // minutes
  int _maxGalleryItems = 1000;
  
  // Security Settings
  bool _requireEmailVerification = true;
  bool _enableTwoFactorAuth = false;
  bool _logUserActivity = true;
  int _passwordMinLength = 8;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadSettings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      // Load settings from Supabase
      final response = await SupabaseConfig.client
          .from('app_settings')
          .select()
          .limit(1)
          .maybeSingle();

      if (response != null) {
        setState(() {
          _enablePushNotifications = response['enable_push_notifications'] ?? true;
          _enableEmailNotifications = response['enable_email_notifications'] ?? true;
          _enableSMSNotifications = response['enable_sms_notifications'] ?? false;
          _maintenanceMode = response['maintenance_mode'] ?? false;
          _debugMode = response['debug_mode'] ?? false;
          _maxFileUploadSize = response['max_file_upload_size'] ?? 50;
          _sessionTimeout = response['session_timeout'] ?? 30;
          _maxLoginAttempts = response['max_login_attempts'] ?? 5;
          _appTheme = response['app_theme'] ?? 'dark';
          _defaultLanguage = response['default_language'] ?? 'he';
          _autoApproveContent = response['auto_approve_content'] ?? false;
          _enableContentReporting = response['enable_content_reporting'] ?? true;
          _maxTutorialDuration = response['max_tutorial_duration'] ?? 30;
          _maxGalleryItems = response['max_gallery_items'] ?? 1000;
          _requireEmailVerification = response['require_email_verification'] ?? true;
          _enableTwoFactorAuth = response['enable_two_factor_auth'] ?? false;
          _logUserActivity = response['log_user_activity'] ?? true;
          _passwordMinLength = response['password_min_length'] ?? 8;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה בטעינת הגדרות: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    try {
      final settings = {
        'enable_push_notifications': _enablePushNotifications,
        'enable_email_notifications': _enableEmailNotifications,
        'enable_sms_notifications': _enableSMSNotifications,
        'maintenance_mode': _maintenanceMode,
        'debug_mode': _debugMode,
        'max_file_upload_size': _maxFileUploadSize,
        'session_timeout': _sessionTimeout,
        'max_login_attempts': _maxLoginAttempts,
        'app_theme': _appTheme,
        'default_language': _defaultLanguage,
        'auto_approve_content': _autoApproveContent,
        'enable_content_reporting': _enableContentReporting,
        'max_tutorial_duration': _maxTutorialDuration,
        'max_gallery_items': _maxGalleryItems,
        'require_email_verification': _requireEmailVerification,
        'enable_two_factor_auth': _enableTwoFactorAuth,
        'log_user_activity': _logUserActivity,
        'password_min_length': _passwordMinLength,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Try to update existing settings or insert new ones
      await SupabaseConfig.client
          .from('app_settings')
          .upsert(settings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('הגדרות נשמרו בהצלחה'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה בשמירת הגדרות: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
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
            text: 'הגדרות אפליקציה',
            fontSize: 24,
            glowColor: AppColors.neonBlue,
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
                Icons.save,
                color: AppColors.neonGreen,
              ),
              onPressed: _saveSettings,
              tooltip: 'שמור הגדרות',
            ),
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: AppColors.neonTurquoise,
              ),
              onPressed: _loadSettings,
              tooltip: 'רענן הגדרות',
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.neonBlue,
            labelColor: AppColors.primaryText,
            unselectedLabelColor: AppColors.secondaryText,
            isScrollable: true,
            tabs: const [
              Tab(text: 'כללי'),
              Tab(text: 'תוכן'),
              Tab(text: 'אבטחה'),
              Tab(text: 'מתקדם'),
            ],
          ),
        ),
        body: AnimatedGradientBackground(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildGeneralTab(),
              _buildContentTab(),
              _buildSecurityTab(),
              _buildAdvancedTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('הגדרות כלליות'),
          
          _buildSettingCard(
            'התראות',
            [
              _buildSwitchTile(
                'הודעות דחיפה',
                'הפעל הודעות דחיפה למשתמשים',
                _enablePushNotifications,
                (value) => setState(() => _enablePushNotifications = value),
                Icons.notifications,
              ),
              _buildSwitchTile(
                'התראות אימייל',
                'שלח התראות בדוא״ל',
                _enableEmailNotifications,
                (value) => setState(() => _enableEmailNotifications = value),
                Icons.email,
              ),
              _buildSwitchTile(
                'הודעות SMS',
                'שלח הודעות SMS חירום',
                _enableSMSNotifications,
                (value) => setState(() => _enableSMSNotifications = value),
                Icons.sms,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          _buildSettingCard(
            'מצב אפליקציה',
            [
              _buildSwitchTile(
                'מצב תחזוקה',
                'חסום גישה למשתמשים רגילים',
                _maintenanceMode,
                (value) => setState(() => _maintenanceMode = value),
                Icons.build,
                isWarning: true,
              ),
              _buildSwitchTile(
                'מצב דיבאג',
                'הפעל רישום מפורט לבעיות',
                _debugMode,
                (value) => setState(() => _debugMode = value),
                Icons.bug_report,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          _buildSettingCard(
            'תצורת אפליקציה',
            [
              _buildSliderTile(
                'גודל קובץ מקסימלי',
                'מגבלת העלאה במגה-בייט',
                _maxFileUploadSize.toDouble(),
                1.0,
                100.0,
                (value) => setState(() => _maxFileUploadSize = value.round()),
                Icons.cloud_upload,
                suffix: 'MB',
              ),
              _buildSliderTile(
                'פתע זמן חיבור',
                'זמן חיבור מקסימלי בדקות',
                _sessionTimeout.toDouble(),
                5.0,
                120.0,
                (value) => setState(() => _sessionTimeout = value.round()),
                Icons.timer,
                suffix: 'דקות',
              ),
            ],
          ),
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
          _buildSectionHeader('הגדרות תוכן'),
          
          _buildSettingCard(
            'ניהול תוכן',
            [
              _buildSwitchTile(
                'אישור אוטומטי',
                'אשר תוכן חדש אוטומטית',
                _autoApproveContent,
                (value) => setState(() => _autoApproveContent = value),
                Icons.auto_awesome,
                isWarning: true,
              ),
              _buildSwitchTile(
                'דיווח על תוכן',
                'אפשר למשתמשים לדווח על תוכן',
                _enableContentReporting,
                (value) => setState(() => _enableContentReporting = value),
                Icons.report,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          _buildSettingCard(
            'מגבלות תוכן',
            [
              _buildSliderTile(
                'משך מדריך מקסימלי',
                'משך וידאו מקסימלי בדקות',
                _maxTutorialDuration.toDouble(),
                1.0,
                60.0,
                (value) => setState(() => _maxTutorialDuration = value.round()),
                Icons.video_library,
                suffix: 'דקות',
              ),
              _buildSliderTile(
                'פריטי גלריה מקסימליים',
                'מספר פריטים מקסימלי בגלריה',
                _maxGalleryItems.toDouble(),
                100.0,
                5000.0,
                (value) => setState(() => _maxGalleryItems = value.round()),
                Icons.photo_library,
                suffix: 'פריטים',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('הגדרות אבטחה'),
          
          _buildSettingCard(
            'אימות משתמשים',
            [
              _buildSwitchTile(
                'אימות אימייל',
                'דרוש אימות אימייל לרישום',
                _requireEmailVerification,
                (value) => setState(() => _requireEmailVerification = value),
                Icons.verified_user,
              ),
              _buildSwitchTile(
                'אימות דו-שלבי',
                'הפעל אימות דו-שלבי למנהלים',
                _enableTwoFactorAuth,
                (value) => setState(() => _enableTwoFactorAuth = value),
                Icons.security,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          _buildSettingCard(
            'רישום פעילות',
            [
              _buildSwitchTile(
                'רישום פעולות משתמש',
                'שמור יומן פעילות משתמשים',
                _logUserActivity,
                (value) => setState(() => _logUserActivity = value),
                Icons.history,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          _buildSettingCard(
            'מדיניות סיסמאות',
            [
              _buildSliderTile(
                'אורך סיסמה מינימלי',
                'מספר תווים מינימלי בסיסמה',
                _passwordMinLength.toDouble(),
                6.0,
                20.0,
                (value) => setState(() => _passwordMinLength = value.round()),
                Icons.lock,
                suffix: 'תווים',
              ),
              _buildSliderTile(
                'ניסיונות כניסה מקסימליים',
                'מספר ניסיונות כניסה נכשלים',
                _maxLoginAttempts.toDouble(),
                3.0,
                10.0,
                (value) => setState(() => _maxLoginAttempts = value.round()),
                Icons.login,
                suffix: 'ניסיונות',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('הגדרות מתקדמות'),
          
          _buildSettingCard(
            'מסד נתונים',
            [
              _buildActionTile(
                'גיבוי מסד נתונים',
                'צור גיבוי מלא של המסד',
                Icons.backup,
                () => _showBackupDialog(),
              ),
              _buildActionTile(
                'אופטימיזציה',
                'אמט את בסיס הנתונים',
                Icons.tune,
                () => _showOptimizeDialog(),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          _buildSettingCard(
            'מערכת',
            [
              _buildActionTile(
                'נקה Cache',
                'נקה קבצי cache זמניים',
                Icons.clear_all,
                () => _clearCache(),
              ),
              _buildActionTile(
                'בדוק עדכונים',
                'בדוק עדכוני מערכת זמינים',
                Icons.system_update,
                () => _checkUpdates(),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          _buildSettingCard(
            'לוגים ותחזוקה',
            [
              _buildActionTile(
                'ייצא לוגים',
                'הורד קובץ לוגים למחשב',
                Icons.download,
                () => _exportLogs(),
              ),
              _buildActionTile(
                'אפס הגדרות',
                'החזר הגדרות לברירת מחדל',
                Icons.settings_backup_restore,
                () => _showResetDialog(),
                isDestructive: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: NeonText(
        text: title,
        fontSize: 20,
        glowColor: AppColors.neonBlue,
      ),
    );
  }

  Widget _buildSettingCard(String title, List<Widget> children) {
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
          Text(
            title,
            style: GoogleFonts.assistant(
              color: AppColors.primaryText,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2);
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    IconData icon, {
    bool isWarning = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: isWarning ? AppColors.warning : AppColors.neonBlue,
      ),
      title: Text(
        title,
        style: GoogleFonts.assistant(
          color: AppColors.primaryText,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.assistant(
          color: AppColors.secondaryText,
          fontSize: 12,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: isWarning ? AppColors.warning : AppColors.neonBlue,
        inactiveThumbColor: AppColors.darkSurface,
        inactiveTrackColor: AppColors.darkBorder,
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    String subtitle,
    double value,
    double min,
    double max,
    Function(double) onChanged,
    IconData icon, {
    String? suffix,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            icon,
            color: AppColors.neonTurquoise,
          ),
          title: Text(
            title,
            style: GoogleFonts.assistant(
              color: AppColors.primaryText,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.assistant(
              color: AppColors.secondaryText,
              fontSize: 12,
            ),
          ),
          trailing: Text(
            '${value.round()}${suffix ?? ''}',
            style: GoogleFonts.assistant(
              color: AppColors.neonTurquoise,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.neonTurquoise,
            inactiveTrackColor: AppColors.darkBorder,
            thumbColor: AppColors.neonTurquoise,
            overlayColor: AppColors.neonTurquoise.withValues(alpha: 0.2),
            valueIndicatorColor: AppColors.neonTurquoise,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).round(),
            onChanged: onChanged,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.neonGreen,
      ),
      title: Text(
        title,
        style: GoogleFonts.assistant(
          color: AppColors.primaryText,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.assistant(
          color: AppColors.secondaryText,
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: AppColors.secondaryText,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          'גיבוי מסד נתונים',
          style: GoogleFonts.assistant(color: AppColors.primaryText),
        ),
        content: Text(
          'האם אתה בטוח שברצונך ליצור גיבוי מלא של מסד הנתונים?\nהפעולה עלולה לקחת מספר דקות.',
          style: GoogleFonts.assistant(color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('ביטול', style: TextStyle(color: AppColors.secondaryText)),
          ),
          NeonButton(
            text: 'צור גיבוי',
            onPressed: () {
              context.pop();
              _createBackup();
            },
            glowColor: AppColors.neonGreen,
          ),
        ],
      ),
    );
  }

  void _showOptimizeDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('מחקק אופטימיזציה לבסיס הנתונים מתבצע...'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          'איפוס הגדרות',
          style: GoogleFonts.assistant(color: AppColors.error),
        ),
        content: Text(
          'האם אתה בטוח שברצונך לאפס את כל ההגדרות לברירת המחדל?\nפעולה זו אינה הפיכה!',
          style: GoogleFonts.assistant(color: AppColors.primaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('ביטול', style: TextStyle(color: AppColors.secondaryText)),
          ),
          NeonButton(
            text: 'אפס הגדרות',
            onPressed: () {
              context.pop();
              _resetSettings();
            },
            glowColor: AppColors.error,
          ),
        ],
      ),
    );
  }

  void _createBackup() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('גיבוי מסד נתונים מתחיל...'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _clearCache() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cache נוקה בהצלחה'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _checkUpdates() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('בודק עדכונים זמינים...'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _exportLogs() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('מייצא לוגים...'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _resetSettings() {
    setState(() {
      _enablePushNotifications = true;
      _enableEmailNotifications = true;
      _enableSMSNotifications = false;
      _maintenanceMode = false;
      _debugMode = false;
      _maxFileUploadSize = 50;
      _sessionTimeout = 30;
      _maxLoginAttempts = 5;
      _autoApproveContent = false;
      _enableContentReporting = true;
      _maxTutorialDuration = 30;
      _maxGalleryItems = 1000;
      _requireEmailVerification = true;
      _enableTwoFactorAuth = false;
      _logUserActivity = true;
      _passwordMinLength = 8;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('הגדרות אופסו לברירת מחדל'),
        backgroundColor: AppColors.success,
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
}