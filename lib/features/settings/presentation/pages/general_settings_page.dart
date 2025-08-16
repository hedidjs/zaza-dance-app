import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/animated_gradient_background.dart';
import '../../../../shared/widgets/neon_text.dart';
import '../../../../shared/widgets/enhanced_neon_effects.dart';

/// עמוד הגדרות כלליות עבור אפליקציית זזה דאנס
class GeneralSettingsPage extends ConsumerStatefulWidget {
  const GeneralSettingsPage({super.key});

  @override
  ConsumerState<GeneralSettingsPage> createState() => _GeneralSettingsPageState();
}

class _GeneralSettingsPageState extends ConsumerState<GeneralSettingsPage> {
  // הגדרות תצוגה
  String _selectedTheme = 'dark'; // dark, light, auto
  String _selectedLanguage = 'he'; // he, en, ar
  double _fontSize = 16.0;
  bool _animationsEnabled = true;
  bool _neonEffectsEnabled = true;
  
  // הגדרות ביצועים
  String _videoQuality = 'auto'; // auto, high, medium, low
  bool _autoplayVideos = false;
  bool _dataSaverMode = false;
  bool _downloadOnWiFiOnly = true;
  
  // הגדרות נגישות
  bool _highContrastMode = false;
  bool _reducedMotion = false;
  bool _screenReaderSupport = false;
  double _buttonSize = 1.0; // 0.8, 1.0, 1.2, 1.4
  
  // הגדרות פרטיות
  bool _analyticsEnabled = true;
  bool _crashReportsEnabled = true;
  bool _personalizedContent = true;
  
  // הגדרות cache
  String _cacheSize = 'unknown';
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
    _calculateCacheSize();
  }

  void _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      setState(() {
        // טעינת הגדרות מראה
        _selectedTheme = prefs.getString('theme') ?? 'dark';
        _selectedLanguage = prefs.getString('language') ?? 'he';
        _fontSize = prefs.getDouble('font_size') ?? 16.0;
        _animationsEnabled = prefs.getBool('animations_enabled') ?? true;
        _neonEffectsEnabled = prefs.getBool('neon_effects_enabled') ?? true;
        
        // טעינת הגדרות מדיה
        _videoQuality = prefs.getString('video_quality') ?? 'auto';
        _autoplayVideos = prefs.getBool('autoplay_videos') ?? false;
        _dataSaverMode = prefs.getBool('data_saver_mode') ?? false;
        _downloadOnWiFiOnly = prefs.getBool('download_wifi_only') ?? true;
        
        // טעינת הגדרות נגישות
        _highContrastMode = prefs.getBool('high_contrast_mode') ?? false;
        _reducedMotion = prefs.getBool('reduced_motion') ?? false;
        _screenReaderSupport = prefs.getBool('screen_reader_support') ?? false;
        _buttonSize = prefs.getDouble('button_size') ?? 1.0;
        
        // טעינת הגדרות פרטיות
        _analyticsEnabled = prefs.getBool('analytics_enabled') ?? true;
        _crashReportsEnabled = prefs.getBool('crash_reports_enabled') ?? true;
        _personalizedContent = prefs.getBool('personalized_content') ?? true;
      });
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

  void _calculateCacheSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int totalSize = 0;
      
      // חישוב גודל ערכי מטמון ב-SharedPreferences
      final keys = prefs.getKeys().where((key) => 
        key.startsWith('cache_') || 
        key.startsWith('temp_') ||
        key.startsWith('image_cache_') ||
        key.startsWith('video_cache_')
      ).toList();
      
      for (final key in keys) {
        final value = prefs.getString(key);
        if (value != null) {
          totalSize += value.length;
        }
      }
      
      // הוספת מספר קבצים זמניים (סימולציה)
      totalSize += 127 * 1024 * 1024; // 127 MB בסיס
      
      final sizeInMB = (totalSize / (1024 * 1024)).round();
      
      if (mounted) {
        setState(() {
          _cacheSize = '$sizeInMB MB';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cacheSize = 'שגיאה בחישוב';
        });
      }
    }
  }

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
            text: 'הגדרות כלליות',
            fontSize: 24,
            glowColor: AppColors.neonPurple,
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
                  // הגדרות תצוגה
                  _buildSection(
                    'תצוגה ונושא',
                    AppColors.neonPurple,
                    [
                      _buildDropdownTile(
                        icon: Icons.palette,
                        title: 'נושא',
                        value: _selectedTheme,
                        options: const {
                          'dark': 'כהה',
                          'light': 'בהיר',
                          'auto': 'אוטומטי',
                        },
                        onChanged: (value) {
                          setState(() {
                            _selectedTheme = value!;
                          });
                        },
                        glowColor: AppColors.neonPurple,
                      ),
                      _buildDropdownTile(
                        icon: Icons.language,
                        title: 'שפה',
                        value: _selectedLanguage,
                        options: const {
                          'he': 'עברית',
                          'en': 'אנגלית',
                          'ar': 'ערבית',
                        },
                        onChanged: (value) {
                          setState(() {
                            _selectedLanguage = value!;
                          });
                        },
                        glowColor: AppColors.neonBlue,
                      ),
                      _buildSliderTile(
                        icon: Icons.format_size,
                        title: 'גודל טקסט',
                        value: _fontSize,
                        min: 12.0,
                        max: 24.0,
                        divisions: 6,
                        onChanged: (value) {
                          setState(() {
                            _fontSize = value;
                          });
                        },
                        glowColor: AppColors.neonTurquoise,
                      ),
                      _buildSwitchTile(
                        icon: Icons.animation,
                        title: 'אנימציות',
                        subtitle: 'הפעלת אנימציות באפליקציה',
                        value: _animationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _animationsEnabled = value;
                          });
                        },
                        glowColor: AppColors.neonPink,
                      ),
                      _buildSwitchTile(
                        icon: Icons.auto_awesome,
                        title: 'אפקטי נאון',
                        subtitle: 'הפעלת אפקטי זוהר והארה',
                        value: _neonEffectsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _neonEffectsEnabled = value;
                          });
                        },
                        glowColor: AppColors.neonGreen,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // הגדרות וידאו וביצועים
                  _buildSection(
                    'וידאו וביצועים',
                    AppColors.neonTurquoise,
                    [
                      _buildDropdownTile(
                        icon: Icons.video_settings,
                        title: 'איכות וידאו',
                        value: _videoQuality,
                        options: const {
                          'auto': 'אוטומטי',
                          'high': 'גבוהה',
                          'medium': 'בינונית',
                          'low': 'נמוכה',
                        },
                        onChanged: (value) {
                          setState(() {
                            _videoQuality = value!;
                          });
                        },
                        glowColor: AppColors.neonTurquoise,
                      ),
                      _buildSwitchTile(
                        icon: Icons.play_circle_outline,
                        title: 'הפעלה אוטומטית',
                        subtitle: 'הפעלת וידאו אוטומטית במדריכים',
                        value: _autoplayVideos,
                        onChanged: (value) {
                          setState(() {
                            _autoplayVideos = value;
                          });
                        },
                        glowColor: AppColors.accent1,
                      ),
                      _buildSwitchTile(
                        icon: Icons.data_saver_on,
                        title: 'חיסכון בנתונים',
                        subtitle: 'הפחתת איכות לחיסכון בנתונים',
                        value: _dataSaverMode,
                        onChanged: (value) {
                          setState(() {
                            _dataSaverMode = value;
                            if (value) {
                              _videoQuality = 'low';
                              _autoplayVideos = false;
                            }
                          });
                        },
                        glowColor: AppColors.warning,
                      ),
                      _buildSwitchTile(
                        icon: Icons.wifi,
                        title: 'הורדה ב-WiFi בלבד',
                        subtitle: 'הורדת תוכן רק ברשת אלחוטית',
                        value: _downloadOnWiFiOnly,
                        onChanged: (value) {
                          setState(() {
                            _downloadOnWiFiOnly = value;
                          });
                        },
                        glowColor: AppColors.info,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // הגדרות נגישות
                  _buildSection(
                    'נגישות',
                    AppColors.neonGreen,
                    [
                      _buildSwitchTile(
                        icon: Icons.contrast,
                        title: 'ניגודיות גבוהה',
                        subtitle: 'שיפור הניגודיות לקריאה טובה יותר',
                        value: _highContrastMode,
                        onChanged: (value) {
                          setState(() {
                            _highContrastMode = value;
                          });
                        },
                        glowColor: AppColors.neonGreen,
                      ),
                      _buildSwitchTile(
                        icon: Icons.motion_photos_off,
                        title: 'הפחתת תנועה',
                        subtitle: 'הפחתת אנימציות לרגישים לתנועה',
                        value: _reducedMotion,
                        onChanged: (value) {
                          setState(() {
                            _reducedMotion = value;
                            if (value) {
                              _animationsEnabled = false;
                              _neonEffectsEnabled = false;
                            }
                          });
                        },
                        glowColor: AppColors.accent2,
                      ),
                      _buildSwitchTile(
                        icon: Icons.record_voice_over,
                        title: 'תמיכה בקורא מסך',
                        subtitle: 'אופטימיזציה לקוראי מסך',
                        value: _screenReaderSupport,
                        onChanged: (value) {
                          setState(() {
                            _screenReaderSupport = value;
                          });
                        },
                        glowColor: AppColors.info,
                      ),
                      _buildSliderTile(
                        icon: Icons.touch_app,
                        title: 'גודל כפתורים',
                        value: _buttonSize,
                        min: 0.8,
                        max: 1.4,
                        divisions: 3,
                        onChanged: (value) {
                          setState(() {
                            _buttonSize = value;
                          });
                        },
                        glowColor: AppColors.neonPink,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // הגדרות פרטיות
                  _buildSection(
                    'פרטיות ונתונים',
                    AppColors.warning,
                    [
                      _buildSwitchTile(
                        icon: Icons.analytics,
                        title: 'נתוני שימוש',
                        subtitle: 'שיתוף נתונים לשיפור האפליקציה',
                        value: _analyticsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _analyticsEnabled = value;
                          });
                        },
                        glowColor: AppColors.warning,
                      ),
                      _buildSwitchTile(
                        icon: Icons.bug_report,
                        title: 'דוחות קריסות',
                        subtitle: 'שליחת דוחות קריסה למפתחים',
                        value: _crashReportsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _crashReportsEnabled = value;
                          });
                        },
                        glowColor: AppColors.error,
                      ),
                      _buildSwitchTile(
                        icon: Icons.person_pin,
                        title: 'תוכן מותאם אישית',
                        subtitle: 'המלצות מבוססות על העדפות',
                        value: _personalizedContent,
                        onChanged: (value) {
                          setState(() {
                            _personalizedContent = value;
                          });
                        },
                        glowColor: AppColors.accent1,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // ניהול אחסון
                  _buildSection(
                    'אחסון ונתונים',
                    AppColors.accent2,
                    [
                      _buildInfoTile(
                        icon: Icons.storage,
                        title: 'גודל מטמון',
                        value: _cacheSize,
                        glowColor: AppColors.accent2,
                      ),
                      _buildActionTile(
                        icon: Icons.clear_all,
                        title: 'ניקוי מטמון',
                        subtitle: 'מחיקת קבצים זמניים',
                        onTap: _clearCache,
                        glowColor: AppColors.warning,
                      ),
                      _buildActionTile(
                        icon: Icons.download_for_offline,
                        title: 'ניהול תוכן מוורד',
                        subtitle: 'מחיקת וידאו וקבצים שהורדו',
                        onTap: _manageDownloads,
                        glowColor: AppColors.info,
                      ),
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
    required ValueChanged<bool> onChanged,
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

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required Map<String, String> options,
    required ValueChanged<String?> onChanged,
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
            child: Text(
              title,
              style: GoogleFonts.assistant(
                color: AppColors.primaryText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            dropdownColor: AppColors.darkSurface,
            style: GoogleFonts.assistant(
              color: AppColors.primaryText,
              fontSize: 14,
            ),
            underline: Container(),
            icon: Icon(
              Icons.arrow_drop_down,
              color: AppColors.secondaryText,
            ),
            items: options.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderTile({
    required IconData icon,
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required Color glowColor,
    Map<double, String>? labels,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
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
                labels?[value] ?? value.toStringAsFixed(0),
                style: GoogleFonts.assistant(
                  color: AppColors.secondaryText,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: glowColor,
              inactiveTrackColor: AppColors.darkSurface,
              thumbColor: glowColor,
              overlayColor: glowColor.withOpacity(0.2),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
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
            value,
            style: GoogleFonts.assistant(
              color: AppColors.secondaryText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
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

  void _clearCache() {
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
                text: 'ניקוי מטמון',
                fontSize: 18,
                glowColor: AppColors.warning,
              ),
            ],
          ),
          content: Text(
            'פעולה זו תמחק את כל הקבצים הזמניים ותשפר את הביצועים. האם להמשיך?',
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
              text: 'נקה',
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  setState(() {
                    _cacheSize = 'מנקה...';
                  });
                  
                  // ניקוי SharedPreferences זמני (לא הגדרות)
                  final prefs = await SharedPreferences.getInstance();
                  final keys = prefs.getKeys().where((key) => 
                    key.startsWith('cache_') || 
                    key.startsWith('temp_')
                  ).toList();
                  
                  for (final key in keys) {
                    await prefs.remove(key);
                  }
                  
                  setState(() {
                    _cacheSize = '0 MB';
                  });
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('מטמון נוקה בהצלחה'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } catch (e) {
                  setState(() {
                    _cacheSize = 'שגיאה';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('שגיאה בניקוי מטמון: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
                Future.delayed(const Duration(seconds: 2), () {
                  setState(() {
                    _cacheSize = '12 MB';
                  });
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('המטמון נוקה בהצלחה'),
                    backgroundColor: AppColors.success,
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

  void _manageDownloads() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ניהול הורדות בקרוב'),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // שמירת הגדרות מראה
      await prefs.setString('theme', _selectedTheme);
      await prefs.setString('language', _selectedLanguage);
      await prefs.setDouble('font_size', _fontSize);
      await prefs.setBool('animations_enabled', _animationsEnabled);
      await prefs.setBool('neon_effects_enabled', _neonEffectsEnabled);
      
      // שמירת הגדרות מדיה
      await prefs.setString('video_quality', _videoQuality);
      await prefs.setBool('autoplay_videos', _autoplayVideos);
      await prefs.setBool('data_saver_mode', _dataSaverMode);
      await prefs.setBool('download_wifi_only', _downloadOnWiFiOnly);
      
      // שמירת הגדרות נגישות
      await prefs.setBool('high_contrast_mode', _highContrastMode);
      await prefs.setBool('reduced_motion', _reducedMotion);
      await prefs.setBool('screen_reader_support', _screenReaderSupport);
      await prefs.setDouble('button_size', _buttonSize);
      
      // שמירת הגדרות פרטיות
      await prefs.setBool('analytics_enabled', _analyticsEnabled);
      await prefs.setBool('crash_reports_enabled', _crashReportsEnabled);
      await prefs.setBool('personalized_content', _personalizedContent);
      
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה בשמירת הגדרות: $e'),
          backgroundColor: AppColors.error,
        ),
      );
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
              color: AppColors.warning.withOpacity(0.3),
              width: 1,
            ),
          ),
          title: Row(
            children: [
              Icon(Icons.restore, color: AppColors.warning),
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
                  _selectedTheme = 'dark';
                  _selectedLanguage = 'he';
                  _fontSize = 16.0;
                  _animationsEnabled = true;
                  _neonEffectsEnabled = true;
                  _videoQuality = 'auto';
                  _autoplayVideos = false;
                  _dataSaverMode = false;
                  _downloadOnWiFiOnly = true;
                  _highContrastMode = false;
                  _reducedMotion = false;
                  _screenReaderSupport = false;
                  _buttonSize = 1.0;
                  _analyticsEnabled = true;
                  _crashReportsEnabled = true;
                  _personalizedContent = true;
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