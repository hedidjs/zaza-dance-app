import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';

/// שירות ניהול הגדרות עם סנכרון Supabase
class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  
  /// הגדרות התראות
  Future<NotificationSettings> getNotificationSettings(String userId) async {
    try {
      // קודם ננסה לטעון מ-Supabase
      final response = await _supabase
          .from('user_notification_settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        return NotificationSettings.fromJson(response);
      }

      // אם לא קיים, נטען מ-SharedPreferences כ-fallback
      return await _getNotificationSettingsFromLocal();
    } catch (e) {
      // במקרה של שגיאה, נטען מ-SharedPreferences
      return await _getNotificationSettingsFromLocal();
    }
  }

  Future<void> saveNotificationSettings(String userId, NotificationSettings settings) async {
    try {
      // שמירה ב-Supabase עם conflict resolution נכון
      await _supabase
          .from('user_notification_settings')
          .upsert({
            'user_id': userId,
            ...settings.toJson(),
            'updated_at': DateTime.now().toIso8601String(),
          }, onConflict: 'user_id');

      // גם שמירה מקומית כ-backup
      await _saveNotificationSettingsToLocal(settings);
    } catch (e) {
      // במקרה של שגיאה, לפחות נשמור מקומית
      await _saveNotificationSettingsToLocal(settings);
      rethrow;
    }
  }

  /// הגדרות כלליות
  Future<GeneralSettings> getGeneralSettings(String userId) async {
    try {
      final response = await _supabase
          .from('user_general_settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        return GeneralSettings.fromJson(response);
      }

      return await _getGeneralSettingsFromLocal();
    } catch (e) {
      return await _getGeneralSettingsFromLocal();
    }
  }

  Future<void> saveGeneralSettings(String userId, GeneralSettings settings) async {
    try {
      await _supabase
          .from('user_general_settings')
          .upsert({
            'user_id': userId,
            ...settings.toJson(),
            'updated_at': DateTime.now().toIso8601String(),
          }, onConflict: 'user_id');

      await _saveGeneralSettingsToLocal(settings);
    } catch (e) {
      await _saveGeneralSettingsToLocal(settings);
      rethrow;
    }
  }

  /// פונקציות עזר ל-SharedPreferences
  Future<NotificationSettings> _getNotificationSettingsFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    
    return NotificationSettings(
      pushNotificationsEnabled: prefs.getBool('push_notifications_enabled') ?? true,
      newTutorialsNotifications: prefs.getBool('new_tutorials_notifications') ?? true,
      galleryUpdatesNotifications: prefs.getBool('gallery_updates_notifications') ?? true,
      studioNewsNotifications: prefs.getBool('studio_news_notifications') ?? true,
      classRemindersNotifications: prefs.getBool('class_reminders_notifications') ?? true,
      eventNotifications: prefs.getBool('event_notifications') ?? true,
      messageNotifications: prefs.getBool('message_notifications') ?? true,
      quietHoursEnabled: prefs.getBool('quiet_hours_enabled') ?? false,
      quietHoursStart: prefs.getString('quiet_start') ?? '22:00',
      quietHoursEnd: prefs.getString('quiet_end') ?? '08:00',
      reminderFrequency: prefs.getString('reminder_frequency') ?? 'daily',
    );
  }

  Future<void> _saveNotificationSettingsToLocal(NotificationSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool('push_notifications_enabled', settings.pushNotificationsEnabled);
    await prefs.setBool('new_tutorials_notifications', settings.newTutorialsNotifications);
    await prefs.setBool('gallery_updates_notifications', settings.galleryUpdatesNotifications);
    await prefs.setBool('studio_news_notifications', settings.studioNewsNotifications);
    await prefs.setBool('class_reminders_notifications', settings.classRemindersNotifications);
    await prefs.setBool('event_notifications', settings.eventNotifications);
    await prefs.setBool('message_notifications', settings.messageNotifications);
    await prefs.setBool('quiet_hours_enabled', settings.quietHoursEnabled);
    await prefs.setString('quiet_start', settings.quietHoursStart);
    await prefs.setString('quiet_end', settings.quietHoursEnd);
    await prefs.setString('reminder_frequency', settings.reminderFrequency);
  }

  Future<GeneralSettings> _getGeneralSettingsFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    
    return GeneralSettings(
      fontSize: prefs.getDouble('font_size') ?? 16.0,
      animationsEnabled: prefs.getBool('animations_enabled') ?? true,
      neonEffectsEnabled: prefs.getBool('neon_effects_enabled') ?? true,
      videoQuality: prefs.getString('video_quality') ?? 'auto',
      autoplayVideos: prefs.getBool('autoplay_videos') ?? false,
      dataSaverMode: prefs.getBool('data_saver_mode') ?? false,
      downloadOnWiFiOnly: prefs.getBool('download_wifi_only') ?? true,
      highContrastMode: prefs.getBool('high_contrast_mode') ?? false,
      reducedMotion: prefs.getBool('reduced_motion') ?? false,
      screenReaderSupport: prefs.getBool('screen_reader_support') ?? false,
      buttonSize: prefs.getDouble('button_size') ?? 1.0,
      analyticsEnabled: prefs.getBool('analytics_enabled') ?? true,
      crashReportsEnabled: prefs.getBool('crash_reports_enabled') ?? true,
      personalizedContent: prefs.getBool('personalized_content') ?? true,
    );
  }

  Future<void> _saveGeneralSettingsToLocal(GeneralSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setDouble('font_size', settings.fontSize);
    await prefs.setBool('animations_enabled', settings.animationsEnabled);
    await prefs.setBool('neon_effects_enabled', settings.neonEffectsEnabled);
    await prefs.setString('video_quality', settings.videoQuality);
    await prefs.setBool('autoplay_videos', settings.autoplayVideos);
    await prefs.setBool('data_saver_mode', settings.dataSaverMode);
    await prefs.setBool('download_wifi_only', settings.downloadOnWiFiOnly);
    await prefs.setBool('high_contrast_mode', settings.highContrastMode);
    await prefs.setBool('reduced_motion', settings.reducedMotion);
    await prefs.setBool('screen_reader_support', settings.screenReaderSupport);
    await prefs.setDouble('button_size', settings.buttonSize);
    await prefs.setBool('analytics_enabled', settings.analyticsEnabled);
    await prefs.setBool('crash_reports_enabled', settings.crashReportsEnabled);
    await prefs.setBool('personalized_content', settings.personalizedContent);
  }

  /// איפוס הגדרות לברירת מחדל
  Future<void> resetToDefaults(String userId) async {
    final defaultNotifications = NotificationSettings.defaults();
    final defaultGeneral = GeneralSettings.defaults();

    await saveNotificationSettings(userId, defaultNotifications);
    await saveGeneralSettings(userId, defaultGeneral);
  }

  /// ניקוי מטמון מקומי
  Future<void> clearLocalCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => 
      key.startsWith('cache_') || 
      key.startsWith('temp_') ||
      key.startsWith('image_cache_') ||
      key.startsWith('video_cache_')
    ).toList();
    
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}