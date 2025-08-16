import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/animated_gradient_background.dart';
import '../../../../shared/widgets/neon_text.dart';
import '../../../../shared/widgets/enhanced_neon_effects.dart';

/// עמוד הגדרות התראות עבור אפליקציית זזה דאנס
class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends ConsumerState<NotificationSettingsPage> {
  // הגדרות התראות
  bool _pushNotificationsEnabled = true;
  bool _newTutorialsNotifications = true;
  bool _galleryUpdatesNotifications = true;
  bool _studioNewsNotifications = true;
  bool _classRemindersNotifications = true;
  bool _eventNotifications = true;
  bool _messageNotifications = true;
  
  // הגדרות זמן
  TimeOfDay _quietHoursStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietHoursEnd = const TimeOfDay(hour: 8, minute: 0);
  bool _quietHoursEnabled = false;
  
  // הגדרות תדירות
  String _reminderFrequency = 'daily'; // daily, weekly, never

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: NeonText(
            text: 'הגדרות התראות',
            fontSize: 24,
            glowColor: AppColors.neonTurquoise,
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.primaryText,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: AnimatedGradientBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // הגדרות כלליות
                  _buildSection(
                    'הגדרות כלליות',
                    AppColors.neonPink,
                    [
                      _buildSwitchTile(
                        icon: Icons.notifications,
                        title: 'התראות Push',
                        subtitle: 'קבלת התראות באפליקציה',
                        value: _pushNotificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _pushNotificationsEnabled = value;
                          });
                        },
                        glowColor: AppColors.neonPink,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // סוגי התראות
                  _buildSection(
                    'סוגי התראות',
                    AppColors.neonTurquoise,
                    [
                      _buildSwitchTile(
                        icon: Icons.video_library,
                        title: 'מדריכים חדשים',
                        subtitle: 'התראה על מדריכי ריקוד חדשים',
                        value: _newTutorialsNotifications,
                        onChanged: _pushNotificationsEnabled ? (value) {
                          setState(() {
                            _newTutorialsNotifications = value;
                          });
                        } : null,
                        glowColor: AppColors.neonTurquoise,
                      ),
                      _buildSwitchTile(
                        icon: Icons.photo_library,
                        title: 'עדכוני גלריה',
                        subtitle: 'תמונות וסרטונים חדשים בגלריה',
                        value: _galleryUpdatesNotifications,
                        onChanged: _pushNotificationsEnabled ? (value) {
                          setState(() {
                            _galleryUpdatesNotifications = value;
                          });
                        } : null,
                        glowColor: AppColors.neonBlue,
                      ),
                      _buildSwitchTile(
                        icon: Icons.announcement,
                        title: 'חדשות הסטודיו',
                        subtitle: 'עדכונים והודעות מהסטודיו',
                        value: _studioNewsNotifications,
                        onChanged: _pushNotificationsEnabled ? (value) {
                          setState(() {
                            _studioNewsNotifications = value;
                          });
                        } : null,
                        glowColor: AppColors.neonPurple,
                      ),
                      _buildSwitchTile(
                        icon: Icons.schedule,
                        title: 'תזכורות שיעורים',
                        subtitle: 'תזכורת לפני שיעורים',
                        value: _classRemindersNotifications,
                        onChanged: _pushNotificationsEnabled ? (value) {
                          setState(() {
                            _classRemindersNotifications = value;
                          });
                        } : null,
                        glowColor: AppColors.warning,
                      ),
                      _buildSwitchTile(
                        icon: Icons.event,
                        title: 'אירועים מיוחדים',
                        subtitle: 'הופעות, תחרויות וסדנאות',
                        value: _eventNotifications,
                        onChanged: _pushNotificationsEnabled ? (value) {
                          setState(() {
                            _eventNotifications = value;
                          });
                        } : null,
                        glowColor: AppColors.accent1,
                      ),
                      _buildSwitchTile(
                        icon: Icons.message,
                        title: 'הודעות אישיות',
                        subtitle: 'הודעות ממדריכים ומנהלים',
                        value: _messageNotifications,
                        onChanged: _pushNotificationsEnabled ? (value) {
                          setState(() {
                            _messageNotifications = value;
                          });
                        } : null,
                        glowColor: AppColors.info,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // שעות שקט
                  _buildSection(
                    'שעות שקט',
                    AppColors.neonGreen,
                    [
                      _buildSwitchTile(
                        icon: Icons.bedtime,
                        title: 'הפעלת שעות שקט',
                        subtitle: 'ללא התראות בזמנים מסוימים',
                        value: _quietHoursEnabled,
                        onChanged: _pushNotificationsEnabled ? (value) {
                          setState(() {
                            _quietHoursEnabled = value;
                          });
                        } : null,
                        glowColor: AppColors.neonGreen,
                      ),
                      if (_quietHoursEnabled && _pushNotificationsEnabled) ...[ 
                        _buildTimeTile(
                          icon: Icons.nightlight,
                          title: 'תחילת שעות שקט',
                          time: _quietHoursStart,
                          onTap: () => _selectTime(true),
                          glowColor: AppColors.neonGreen,
                        ),
                        _buildTimeTile(
                          icon: Icons.wb_sunny,
                          title: 'סיום שעות שקט',
                          time: _quietHoursEnd,
                          onTap: () => _selectTime(false),
                          glowColor: AppColors.warning,
                        ),
                      ],
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // תדירות תזכורות
                  _buildSection(
                    'תזכורות שיעורים',
                    AppColors.accent2,
                    [
                      _buildFrequencyTile(),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // פעולות
                  _buildActionButtons(),
                  
                  const SizedBox(height: 100), // מקום לניווט תחתון
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, Color glowColor, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NeonText(
          text: title,
          fontSize: 18,
          glowColor: glowColor,
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
              color: glowColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: glowColor,
            activeTrackColor: glowColor.withOpacity(0.3),
            inactiveThumbColor: AppColors.secondaryText,
            inactiveTrackColor: AppColors.darkSurface,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTile({
    required IconData icon,
    required String title,
    required TimeOfDay time,
    required VoidCallback onTap,
    required Color glowColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
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
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.assistant(
                  color: AppColors.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              time.format(context),
              style: GoogleFonts.assistant(
                color: AppColors.secondaryText,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_back_ios,
              color: AppColors.secondaryText,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyTile() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent2.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.repeat,
                  color: AppColors.accent2,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'תדירות תזכורות',
                  style: GoogleFonts.assistant(
                    color: AppColors.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...['daily', 'weekly', 'never'].map((frequency) {
            return RadioListTile<String>(
              value: frequency,
              groupValue: _reminderFrequency,
              onChanged: _pushNotificationsEnabled && _classRemindersNotifications ? (value) {
                setState(() {
                  _reminderFrequency = value ?? 'daily';
                });
              } : null,
              title: Text(
                _getFrequencyDisplayName(frequency),
                style: GoogleFonts.assistant(
                  color: AppColors.primaryText,
                  fontSize: 14,
                ),
              ),
              activeColor: AppColors.accent2,
              contentPadding: EdgeInsets.zero,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: NeonButton(
            text: 'שמור הגדרות',
            onPressed: _saveSettings,
            glowColor: AppColors.neonTurquoise,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: NeonButton(
            text: 'איפוס להגדרות ברירת מחדל',
            onPressed: _resetToDefaults,
            glowColor: AppColors.warning,
          ),
        ),
      ],
    );
  }

  String _getFrequencyDisplayName(String frequency) {
    switch (frequency) {
      case 'daily':
        return 'יומית (24 שעות לפני)';
      case 'weekly':
        return 'שבועית (יום לפני)';
      case 'never':
        return 'ללא תזכורות';
      default:
        return frequency;
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _quietHoursStart : _quietHoursEnd,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.neonTurquoise,
                onSurface: AppColors.primaryText,
                surface: AppColors.darkSurface,
              ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _quietHoursStart = picked;
        } else {
          _quietHoursEnd = picked;
        }
      });
    }
  }

  void _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // שמירת הגדרות התראות
      await prefs.setBool('notifications_enabled', _notificationsEnabled);
      await prefs.setBool('push_notifications', _pushNotifications);
      await prefs.setBool('email_notifications', _emailNotifications);
      await prefs.setBool('sms_notifications', _smsNotifications);
      await prefs.setBool('class_reminders', _classReminders);
      await prefs.setBool('new_tutorials', _newTutorials);
      await prefs.setBool('studio_updates', _studioUpdates);
      await prefs.setBool('achievements', _achievements);
      await prefs.setBool('marketing_updates', _marketingUpdates);
      
      // שמירת הגדרות זמן
      await prefs.setString('quiet_start', '${_quietHoursStart.hour}:${_quietHoursStart.minute}');
      await prefs.setString('quiet_end', '${_quietHoursEnd.hour}:${_quietHoursEnd.minute}');
      
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('הגדרות נשמרו בהצלחה'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _resetToDefaults() {
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
              Icon(Icons.warning, color: AppColors.warning),
              const SizedBox(width: 8),
              NeonText(
                text: 'איפוס הגדרות',
                fontSize: 18,
                glowColor: AppColors.warning,
              ),
            ],
          ),
          content: Text(
            'האם אתה בטוח שברצונך לאפס את כל ההגדרות לברירת המחדל?',
            style: GoogleFonts.assistant(
              color: AppColors.primaryText,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'ביטול',
                style: TextStyle(color: AppColors.secondaryText),
              ),
            ),
            NeonButton(
              text: 'איפוס',
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _pushNotificationsEnabled = true;
                  _newTutorialsNotifications = true;
                  _galleryUpdatesNotifications = true;
                  _studioNewsNotifications = true;
                  _classRemindersNotifications = true;
                  _eventNotifications = true;
                  _messageNotifications = true;
                  _quietHoursEnabled = false;
                  _quietHoursStart = const TimeOfDay(hour: 22, minute: 0);
                  _quietHoursEnd = const TimeOfDay(hour: 8, minute: 0);
                  _reminderFrequency = 'daily';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('הגדרות אופסו לברירת המחדל'),
                    backgroundColor: AppColors.info,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              glowColor: AppColors.warning,
            ),
          ],
        ),
      ),
    );
  }
}