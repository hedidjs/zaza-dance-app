import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/settings_model.dart';
import '../../../../core/providers/settings_provider.dart';
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
  // השתמש בהגדרות זמן מקומיות
  TimeOfDay _quietHoursStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietHoursEnd = const TimeOfDay(hour: 8, minute: 0);

  @override
  void initState() {
    super.initState();
    // טעינת הגדרות זמן מההגדרות הקיימות
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsAsync = ref.read(notificationSettingsProvider);
      if (settingsAsync.hasValue) {
        final settings = settingsAsync.value!;
        final startParts = settings.quietHoursStart.split(':');
        final endParts = settings.quietHoursEnd.split(':');
        
        if (startParts.length == 2) {
          _quietHoursStart = TimeOfDay(
            hour: int.tryParse(startParts[0]) ?? 22,
            minute: int.tryParse(startParts[1]) ?? 0,
          );
        }
        
        if (endParts.length == 2) {
          _quietHoursEnd = TimeOfDay(
            hour: int.tryParse(endParts[0]) ?? 8,
            minute: int.tryParse(endParts[1]) ?? 0,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(notificationSettingsProvider);
    
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
            onPressed: () => context.pop(),
          ),
        ),
        body: AnimatedGradientBackground(
          child: SafeArea(
            child: settingsAsync.when(
              data: (settings) => _buildSettingsContent(settings),
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.neonTurquoise),
              ),
              error: (error, stack) => _buildErrorView(error.toString()),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsContent(NotificationSettings settings) {
    return SingleChildScrollView(
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
                        value: settings.pushNotificationsEnabled,
                        onChanged: (value) async {
                          try {
                            await ref.read(notificationSettingsProvider.notifier).updatePushNotifications(value);
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('שגיאה בעדכון הגדרות: $e'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
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
                        value: settings.newTutorialsNotifications,
                        onChanged: settings.pushNotificationsEnabled ? (value) async {
                          try {
                            await ref.read(notificationSettingsProvider.notifier).updateNewTutorials(value);
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('שגיאה בעדכון הגדרות: $e'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        } : null,
                        glowColor: AppColors.neonTurquoise,
                      ),
                      _buildSwitchTile(
                        icon: Icons.photo_library,
                        title: 'עדכוני גלריה',
                        subtitle: 'תמונות וסרטונים חדשים בגלריה',
                        value: settings.galleryUpdatesNotifications,
                        onChanged: settings.pushNotificationsEnabled ? (value) async {
                          try {
                            await ref.read(notificationSettingsProvider.notifier).updateGalleryUpdates(value);
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('שגיאה בעדכון הגדרות: $e'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        } : null,
                        glowColor: AppColors.neonBlue,
                      ),
                      _buildSwitchTile(
                        icon: Icons.announcement,
                        title: 'חדשות הסטודיו',
                        subtitle: 'עדכונים והודעות מהסטודיו',
                        value: settings.studioNewsNotifications,
                        onChanged: settings.pushNotificationsEnabled ? (value) async {
                          try {
                            await ref.read(notificationSettingsProvider.notifier).updateStudioNews(value);
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('שגיאה בעדכון הגדרות: $e'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        } : null,
                        glowColor: AppColors.neonPurple,
                      ),
                      _buildSwitchTile(
                        icon: Icons.schedule,
                        title: 'תזכורות שיעורים',
                        subtitle: 'תזכורת לפני שיעורים',
                        value: settings.classRemindersNotifications,
                        onChanged: settings.pushNotificationsEnabled ? (value) async {
                          try {
                            await ref.read(notificationSettingsProvider.notifier).updateClassReminders(value);
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('שגיאה בעדכון הגדרות: $e'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        } : null,
                        glowColor: AppColors.warning,
                      ),
                      _buildSwitchTile(
                        icon: Icons.event,
                        title: 'אירועים מיוחדים',
                        subtitle: 'הופעות, תחרויות וסדנאות',
                        value: settings.eventNotifications,
                        onChanged: settings.pushNotificationsEnabled ? (value) async {
                          try {
                            await ref.read(notificationSettingsProvider.notifier).updateEventNotifications(value);
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('שגיאה בעדכון הגדרות: $e'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        } : null,
                        glowColor: AppColors.accent1,
                      ),
                      _buildSwitchTile(
                        icon: Icons.message,
                        title: 'הודעות אישיות',
                        subtitle: 'הודעות ממדריכים ומנהלים',
                        value: settings.messageNotifications,
                        onChanged: settings.pushNotificationsEnabled ? (value) async {
                          try {
                            await ref.read(notificationSettingsProvider.notifier).updateMessageNotifications(value);
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('שגיאה בעדכון הגדרות: $e'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
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
                        value: settings.quietHoursEnabled,
                        onChanged: settings.pushNotificationsEnabled ? (value) async {
                          try {
                            await ref.read(notificationSettingsProvider.notifier).updateQuietHours(value);
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('שגיאה בעדכון הגדרות: $e'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        } : null,
                        glowColor: AppColors.neonGreen,
                      ),
                      if (settings.quietHoursEnabled && settings.pushNotificationsEnabled) ...[ 
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
                      _buildFrequencyTile(settings),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // פעולות
                  _buildActionButtons(),
                  
                  const SizedBox(height: 100), // מקום לניווט תחתון
                ],
              ),
            );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: AppColors.error,
          ),
          const SizedBox(height: 20),
          NeonText(
            text: 'שגיאה בטעינת הגדרות',
            fontSize: 20,
            glowColor: AppColors.error,
          ),
          const SizedBox(height: 10),
          Text(
            error,
            style: GoogleFonts.assistant(
              color: AppColors.secondaryText,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          NeonButton(
            text: 'נסה שוב',
            onPressed: () {
              ref.read(notificationSettingsProvider.notifier).reload();
            },
            glowColor: AppColors.neonTurquoise,
          ),
        ],
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
              color: glowColor.withValues(alpha: 0.3),
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
              color: glowColor.withValues(alpha: 0.2),
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
            activeThumbColor: glowColor,
            activeTrackColor: glowColor.withValues(alpha: 0.3),
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
                color: glowColor.withValues(alpha: 0.2),
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

  Widget _buildFrequencyTile(NotificationSettings settings) {
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
                  color: AppColors.accent2.withValues(alpha: 0.2),
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
              groupValue: settings.reminderFrequency,
              onChanged: settings.pushNotificationsEnabled && settings.classRemindersNotifications ? (value) async {
                try {
                  await ref.read(notificationSettingsProvider.notifier).updateReminderFrequency(value ?? 'daily');
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('שגיאה בעדכון הגדרות: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
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
          }),
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
      
      // עדכון ההגדרות בProvider
      try {
        final timeString = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        if (isStartTime) {
          await ref.read(notificationSettingsProvider.notifier).updateQuietHours(
            true, 
            start: timeString
          );
        } else {
          await ref.read(notificationSettingsProvider.notifier).updateQuietHours(
            true, 
            end: timeString
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('שגיאה בעדכון שעות שקט: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  void _saveSettings() async {
    try {
      // ההגדרות כבר נשמרו אוטומטית דרך הספקים
      // נציג הודעה למשתמש
      if (mounted) {
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
              color: AppColors.warning.withValues(alpha: 0.3),
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
              onPressed: () => context.pop(),
              child: Text(
                'ביטול',
                style: TextStyle(color: AppColors.secondaryText),
              ),
            ),
            NeonButton(
              text: 'איפוס',
              onPressed: () async {
                context.pop();
                try {
                  await ref.read(notificationSettingsProvider.notifier).resetToDefaults();
                  // איפוס הגדרות זמן מקומיות
                  setState(() {
                    _quietHoursStart = const TimeOfDay(hour: 22, minute: 0);
                    _quietHoursEnd = const TimeOfDay(hour: 8, minute: 0);
                  });
                  if (mounted) {
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
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('שגיאה באיפוס הגדרות: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              glowColor: AppColors.warning,
            ),
          ],
        ),
      ),
    );
  }
}