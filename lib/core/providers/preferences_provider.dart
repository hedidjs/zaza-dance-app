import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';

/// Provider for user preferences
final userPreferencesProvider = StateNotifierProvider<UserPreferencesNotifier, AsyncValue<Map<String, dynamic>?>>(
  (ref) => UserPreferencesNotifier(),
);

/// Notifier for user preferences management
class UserPreferencesNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  UserPreferencesNotifier() : super(const AsyncValue.data(null));

  /// Load user preferences
  Future<void> loadPreferences(String userId) async {
    try {
      state = const AsyncValue.loading();
      
      final preferences = await DatabaseService.getUserPreferences(userId);
      
      state = AsyncValue.data(preferences);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update user preferences
  Future<bool> updatePreferences({
    required String userId,
    Map<String, dynamic>? preferences,
  }) async {
    if (preferences == null || preferences.isEmpty) {
      return false;
    }
    
    final previousState = state;
    
    try {
      // Optimistic update
      if (state.value != null) {
        final updatedPrefs = Map<String, dynamic>.from(state.value!);
        updatedPrefs.addAll(preferences);
        state = AsyncValue.data(updatedPrefs);
      }
      
      await DatabaseService.updateUserPreferences(
        userId: userId,
        preferences: preferences,
      );
      
      return true;
    } catch (error) {
      // Revert on error
      state = previousState;
      return false;
    }
  }

  /// Update notification preferences
  Future<bool> updateNotificationPreferences({
    required String userId,
    bool? notificationsEnabled,
    bool? pushNotifications,
    bool? emailNotifications,
    bool? newTutorialsNotifications,
    bool? galleryUpdatesNotifications,
    bool? studioNewsNotifications,
    bool? classRemindersNotifications,
    bool? eventNotifications,
    bool? messageNotifications,
  }) async {
    final preferences = <String, dynamic>{};
    
    if (notificationsEnabled != null) preferences['notifications_enabled'] = notificationsEnabled;
    if (pushNotifications != null) preferences['push_notifications'] = pushNotifications;
    if (emailNotifications != null) preferences['email_notifications'] = emailNotifications;
    if (newTutorialsNotifications != null) preferences['new_tutorials_notifications'] = newTutorialsNotifications;
    if (galleryUpdatesNotifications != null) preferences['gallery_updates_notifications'] = galleryUpdatesNotifications;
    if (studioNewsNotifications != null) preferences['studio_news_notifications'] = studioNewsNotifications;
    if (classRemindersNotifications != null) preferences['class_reminders_notifications'] = classRemindersNotifications;
    if (eventNotifications != null) preferences['event_notifications'] = eventNotifications;
    if (messageNotifications != null) preferences['message_notifications'] = messageNotifications;

    return await updatePreferences(userId: userId, preferences: preferences);
  }

  /// Update quiet hours preferences
  Future<bool> updateQuietHours({
    required String userId,
    bool? quietHoursEnabled,
    String? quietHoursStart, // Time format: "HH:mm"
    String? quietHoursEnd,   // Time format: "HH:mm"
  }) async {
    final preferences = <String, dynamic>{};
    
    if (quietHoursEnabled != null) preferences['quiet_hours_enabled'] = quietHoursEnabled;
    if (quietHoursStart != null) preferences['quiet_hours_start'] = quietHoursStart;
    if (quietHoursEnd != null) preferences['quiet_hours_end'] = quietHoursEnd;

    return await updatePreferences(userId: userId, preferences: preferences);
  }

  /// Update app preferences
  Future<bool> updateAppPreferences({
    required String userId,
    String? preferredLanguage,
    bool? autoPlayVideos,
    String? videoQuality,
    bool? dataSaverMode,
    bool? downloadWifiOnly,
  }) async {
    final preferences = <String, dynamic>{};
    
    if (preferredLanguage != null) preferences['preferred_language'] = preferredLanguage;
    if (autoPlayVideos != null) preferences['auto_play_videos'] = autoPlayVideos;
    if (videoQuality != null) preferences['video_quality'] = videoQuality;
    if (dataSaverMode != null) preferences['data_saver_mode'] = dataSaverMode;
    if (downloadWifiOnly != null) preferences['download_wifi_only'] = downloadWifiOnly;

    return await updatePreferences(userId: userId, preferences: preferences);
  }

  /// Get specific preference value
  T? getPreference<T>(String key) {
    return state.when(
      data: (preferences) => preferences?[key] as T?,
      loading: () => null,
      error: (_, __) => null,
    );
  }

  /// Check if notifications are enabled
  bool get notificationsEnabled {
    return getPreference<bool>('notifications_enabled') ?? true;
  }

  /// Check if push notifications are enabled
  bool get pushNotificationsEnabled {
    return getPreference<bool>('push_notifications') ?? true;
  }

  /// Check if auto-play videos is enabled
  bool get autoPlayVideosEnabled {
    return getPreference<bool>('auto_play_videos') ?? false;
  }

  /// Get preferred video quality
  String get videoQuality {
    return getPreference<String>('video_quality') ?? 'auto';
  }

  /// Check if data saver mode is enabled
  bool get dataSaverModeEnabled {
    return getPreference<bool>('data_saver_mode') ?? false;
  }

  /// Get preferred language
  String get preferredLanguage {
    return getPreference<String>('preferred_language') ?? 'he';
  }
  
  /// Check if current language is Hebrew
  bool get isHebrewEnabled {
    return preferredLanguage == 'he';
  }
  
  /// Check if quiet hours are currently active
  bool get isInQuietHours {
    if (!(getPreference<bool>('quiet_hours_enabled') ?? false)) return false;
    
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final startTime = getPreference<String>('quiet_hours_start') ?? '22:00';
    final endTime = getPreference<String>('quiet_hours_end') ?? '08:00';
    
    return _isTimeInRange(currentTime, startTime, endTime);
  }
  
  /// Helper method to check if time is in range
  bool _isTimeInRange(String current, String start, String end) {
    final currentMinutes = _timeToMinutes(current);
    final startMinutes = _timeToMinutes(start);
    final endMinutes = _timeToMinutes(end);
    
    if (startMinutes <= endMinutes) {
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    } else {
      // Crosses midnight
      return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
    }
  }
  
  /// Convert time string to minutes since midnight
  int _timeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  /// Refresh preferences
  Future<void> refresh(String userId) async {
    await loadPreferences(userId);
  }
}