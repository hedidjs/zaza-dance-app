import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings_model.dart';
import '../services/settings_service.dart';
import 'auth_provider.dart';

/// ספק שירות הגדרות
final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

/// ספק הגדרות התראות
final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, AsyncValue<NotificationSettings>>((ref) {
  final settingsService = ref.watch(settingsServiceProvider);
  return NotificationSettingsNotifier(settingsService, ref);
});

/// ספק הגדרות כלליות
final generalSettingsProvider = StateNotifierProvider<GeneralSettingsNotifier, AsyncValue<GeneralSettings>>((ref) {
  final settingsService = ref.watch(settingsServiceProvider);
  return GeneralSettingsNotifier(settingsService, ref);
});

/// מנהל מצב הגדרות התראות
class NotificationSettingsNotifier extends StateNotifier<AsyncValue<NotificationSettings>> {
  final SettingsService _settingsService;
  final Ref _ref;

  NotificationSettingsNotifier(this._settingsService, this._ref) 
      : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final userAsync = _ref.read(currentUserProvider);
      final user = userAsync.value;
      if (user?.id != null) {
        final settings = await _settingsService.getNotificationSettings(user!.id);
        state = AsyncValue.data(settings);
      } else {
        // אם המשתמש לא מחובר, נטען הגדרות ברירת מחדל
        state = AsyncValue.data(NotificationSettings.defaults());
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateSettings(NotificationSettings settings) async {
    final previousState = state;
    
    try {
      // עדכון מיידי של המצב
      state = AsyncValue.data(settings);
      
      final userAsync = _ref.read(currentUserProvider);
      final user = userAsync.value;
      if (user?.id != null) {
        await _settingsService.saveNotificationSettings(user!.id, settings);
      }
    } catch (error) {
      // החזרת המצב הקודם במקרה של שגיאה
      state = previousState;
      rethrow;
    }
  }

  Future<void> updatePushNotifications(bool enabled) async {
    final current = state.value;
    if (current != null) {
      await updateSettings(current.copyWith(pushNotificationsEnabled: enabled));
    }
  }

  Future<void> updateNewTutorials(bool enabled) async {
    final current = state.value;
    if (current != null) {
      await updateSettings(current.copyWith(newTutorialsNotifications: enabled));
    }
  }

  Future<void> updateGalleryUpdates(bool enabled) async {
    final current = state.value;
    if (current != null) {
      await updateSettings(current.copyWith(galleryUpdatesNotifications: enabled));
    }
  }

  Future<void> updateStudioNews(bool enabled) async {
    final current = state.value;
    if (current != null) {
      await updateSettings(current.copyWith(studioNewsNotifications: enabled));
    }
  }

  Future<void> updateClassReminders(bool enabled) async {
    final current = state.value;
    if (current != null) {
      await updateSettings(current.copyWith(classRemindersNotifications: enabled));
    }
  }

  Future<void> updateEventNotifications(bool enabled) async {
    final current = state.value;
    if (current != null) {
      await updateSettings(current.copyWith(eventNotifications: enabled));
    }
  }

  Future<void> updateMessageNotifications(bool enabled) async {
    final current = state.value;
    if (current != null) {
      await updateSettings(current.copyWith(messageNotifications: enabled));
    }
  }

  Future<void> updateQuietHours(bool enabled, {String? start, String? end}) async {
    final current = state.value;
    if (current != null) {
      await updateSettings(current.copyWith(
        quietHoursEnabled: enabled,
        quietHoursStart: start ?? current.quietHoursStart,
        quietHoursEnd: end ?? current.quietHoursEnd,
      ));
    }
  }

  Future<void> updateReminderFrequency(String frequency) async {
    final current = state.value;
    if (current != null) {
      await updateSettings(current.copyWith(reminderFrequency: frequency));
    }
  }

  Future<void> resetToDefaults() async {
    await updateSettings(NotificationSettings.defaults());
  }

  void reload() {
    _loadSettings();
  }
}

/// מנהל מצב הגדרות כלליות
class GeneralSettingsNotifier extends StateNotifier<AsyncValue<GeneralSettings>> {
  final SettingsService _settingsService;
  final Ref _ref;

  GeneralSettingsNotifier(this._settingsService, this._ref) 
      : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final userAsync = _ref.read(currentUserProvider);
      final user = userAsync.value;
      if (user?.id != null) {
        final settings = await _settingsService.getGeneralSettings(user!.id);
        state = AsyncValue.data(settings);
      } else {
        state = AsyncValue.data(GeneralSettings.defaults());
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateSettings(GeneralSettings settings) async {
    final previousState = state;
    
    try {
      state = AsyncValue.data(settings);
      
      final userAsync = _ref.read(currentUserProvider);
      final user = userAsync.value;
      if (user?.id != null) {
        await _settingsService.saveGeneralSettings(user!.id, settings);
      }
    } catch (error) {
      state = previousState;
      rethrow;
    }
  }

  Future<void> updateFontSize(double size) async {
    final current = state.value;
    if (current != null) {
      await updateSettings(current.copyWith(fontSize: size));
    }
  }

  Future<void> updateAnimations(bool enabled) async {
    final current = state.value;
    if (current != null) {
      await updateSettings(current.copyWith(animationsEnabled: enabled));
    }
  }

  Future<void> updateNeonEffects(bool enabled) async {
    final current = state.value;
    if (current != null) {
      await updateSettings(current.copyWith(neonEffectsEnabled: enabled));
    }
  }

  Future<void> updateVideoQuality(String quality) async {
    final current = state.value;
    if (current != null) {
      await updateSettings(current.copyWith(videoQuality: quality));
    }
  }

  Future<void> updateAutoplayVideos(bool enabled) async {
    final current = state.value;
    if (current != null) {
      await updateSettings(current.copyWith(autoplayVideos: enabled));
    }
  }

  Future<void> updateDataSaverMode(bool enabled) async {
    final current = state.value;
    if (current != null) {
      // כאשר מצב חיסכון בנתונים מופעל, נעדכן גם הגדרות נוספות
      if (enabled) {
        await updateSettings(current.copyWith(
          dataSaverMode: enabled,
          videoQuality: 'low',
          autoplayVideos: false,
        ));
      } else {
        await updateSettings(current.copyWith(dataSaverMode: enabled));
      }
    }
  }

  Future<void> updateDownloadWiFiOnly(bool enabled) async {
    final current = state.value;
    if (current != null) {
      await updateSettings(current.copyWith(downloadOnWiFiOnly: enabled));
    }
  }

  Future<void> updateHighContrastMode(bool enabled) async {
    final current = state.value;
    if (current != null) {
      await updateSettings(current.copyWith(highContrastMode: enabled));
    }
  }

  Future<void> updateReducedMotion(bool enabled) async {
    final current = state.value;
    if (current != null) {
      // כאשר מצב הפחתת תנועה מופעל, נכבה גם אנימציות ואפקטים
      if (enabled) {
        await updateSettings(current.copyWith(
          reducedMotion: enabled,
          animationsEnabled: false,
          neonEffectsEnabled: false,
        ));
      } else {
        await updateSettings(current.copyWith(reducedMotion: enabled));
      }
    }
  }

  Future<void> updateScreenReaderSupport(bool enabled) async {
    final current = state.value;
    if (current != null) {
      await updateSettings(current.copyWith(screenReaderSupport: enabled));
    }
  }

  Future<void> updateButtonSize(double size) async {
    final current = state.value;
    if (current != null) {
      await updateSettings(current.copyWith(buttonSize: size));
    }
  }

  Future<void> updateAnalytics(bool enabled) async {
    final current = state.value;
    if (current != null) {
      await updateSettings(current.copyWith(analyticsEnabled: enabled));
    }
  }

  Future<void> updateCrashReports(bool enabled) async {
    final current = state.value;
    if (current != null) {
      await updateSettings(current.copyWith(crashReportsEnabled: enabled));
    }
  }

  Future<void> updatePersonalizedContent(bool enabled) async {
    final current = state.value;
    if (current != null) {
      await updateSettings(current.copyWith(personalizedContent: enabled));
    }
  }

  Future<void> resetToDefaults() async {
    await updateSettings(GeneralSettings.defaults());
  }

  void reload() {
    _loadSettings();
  }
}

/// ספק ניקוי מטמון
final clearCacheProvider = FutureProvider.family<void, String>((ref, userId) async {
  final settingsService = ref.watch(settingsServiceProvider);
  await settingsService.clearLocalCache();
});

/// ספק איפוס הגדרות
final resetSettingsProvider = FutureProvider.family<void, String>((ref, userId) async {
  final settingsService = ref.watch(settingsServiceProvider);
  await settingsService.resetToDefaults(userId);
  
  // רענון ספקי ההגדרות
  ref.invalidate(notificationSettingsProvider);
  ref.invalidate(generalSettingsProvider);
});