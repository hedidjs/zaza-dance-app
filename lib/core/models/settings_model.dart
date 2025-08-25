/// מודל עבור הגדרות התראות
class NotificationSettings {
  final bool pushNotificationsEnabled;
  final bool newTutorialsNotifications;
  final bool galleryUpdatesNotifications;
  final bool studioNewsNotifications;
  final bool classRemindersNotifications;
  final bool eventNotifications;
  final bool messageNotifications;
  final bool quietHoursEnabled;
  final String quietHoursStart;
  final String quietHoursEnd;
  final String reminderFrequency;

  const NotificationSettings({
    required this.pushNotificationsEnabled,
    required this.newTutorialsNotifications,
    required this.galleryUpdatesNotifications,
    required this.studioNewsNotifications,
    required this.classRemindersNotifications,
    required this.eventNotifications,
    required this.messageNotifications,
    required this.quietHoursEnabled,
    required this.quietHoursStart,
    required this.quietHoursEnd,
    required this.reminderFrequency,
  });

  factory NotificationSettings.defaults() {
    return const NotificationSettings(
      pushNotificationsEnabled: true,
      newTutorialsNotifications: true,
      galleryUpdatesNotifications: true,
      studioNewsNotifications: true,
      classRemindersNotifications: true,
      eventNotifications: true,
      messageNotifications: true,
      quietHoursEnabled: false,
      quietHoursStart: '22:00',
      quietHoursEnd: '08:00',
      reminderFrequency: 'daily',
    );
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      pushNotificationsEnabled: json['push_notifications_enabled'] ?? true,
      newTutorialsNotifications: json['new_tutorials_notifications'] ?? true,
      galleryUpdatesNotifications: json['gallery_updates_notifications'] ?? true,
      studioNewsNotifications: json['studio_news_notifications'] ?? true,
      classRemindersNotifications: json['class_reminders_notifications'] ?? true,
      eventNotifications: json['event_notifications'] ?? true,
      messageNotifications: json['message_notifications'] ?? true,
      quietHoursEnabled: json['quiet_hours_enabled'] ?? false,
      quietHoursStart: json['quiet_hours_start'] ?? '22:00',
      quietHoursEnd: json['quiet_hours_end'] ?? '08:00',
      reminderFrequency: json['reminder_frequency'] ?? 'daily',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'push_notifications_enabled': pushNotificationsEnabled,
      'new_tutorials_notifications': newTutorialsNotifications,
      'gallery_updates_notifications': galleryUpdatesNotifications,
      'studio_news_notifications': studioNewsNotifications,
      'class_reminders_notifications': classRemindersNotifications,
      'event_notifications': eventNotifications,
      'message_notifications': messageNotifications,
      'quiet_hours_enabled': quietHoursEnabled,
      'quiet_hours_start': quietHoursStart,
      'quiet_hours_end': quietHoursEnd,
      'reminder_frequency': reminderFrequency,
    };
  }

  NotificationSettings copyWith({
    bool? pushNotificationsEnabled,
    bool? newTutorialsNotifications,
    bool? galleryUpdatesNotifications,
    bool? studioNewsNotifications,
    bool? classRemindersNotifications,
    bool? eventNotifications,
    bool? messageNotifications,
    bool? quietHoursEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
    String? reminderFrequency,
  }) {
    return NotificationSettings(
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      newTutorialsNotifications: newTutorialsNotifications ?? this.newTutorialsNotifications,
      galleryUpdatesNotifications: galleryUpdatesNotifications ?? this.galleryUpdatesNotifications,
      studioNewsNotifications: studioNewsNotifications ?? this.studioNewsNotifications,
      classRemindersNotifications: classRemindersNotifications ?? this.classRemindersNotifications,
      eventNotifications: eventNotifications ?? this.eventNotifications,
      messageNotifications: messageNotifications ?? this.messageNotifications,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      reminderFrequency: reminderFrequency ?? this.reminderFrequency,
    );
  }

  @override
  String toString() {
    return 'NotificationSettings(pushNotificationsEnabled: $pushNotificationsEnabled, quietHoursEnabled: $quietHoursEnabled)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationSettings &&
        other.pushNotificationsEnabled == pushNotificationsEnabled &&
        other.newTutorialsNotifications == newTutorialsNotifications &&
        other.galleryUpdatesNotifications == galleryUpdatesNotifications &&
        other.studioNewsNotifications == studioNewsNotifications &&
        other.classRemindersNotifications == classRemindersNotifications &&
        other.eventNotifications == eventNotifications &&
        other.messageNotifications == messageNotifications &&
        other.quietHoursEnabled == quietHoursEnabled &&
        other.quietHoursStart == quietHoursStart &&
        other.quietHoursEnd == quietHoursEnd &&
        other.reminderFrequency == reminderFrequency;
  }

  @override
  int get hashCode {
    return Object.hash(
      pushNotificationsEnabled,
      newTutorialsNotifications,
      galleryUpdatesNotifications,
      studioNewsNotifications,
      classRemindersNotifications,
      eventNotifications,
      messageNotifications,
      quietHoursEnabled,
      quietHoursStart,
      quietHoursEnd,
      reminderFrequency,
    );
  }
}

/// מודל עבור הגדרות כלליות
class GeneralSettings {
  final double fontSize;
  final bool animationsEnabled;
  final bool neonEffectsEnabled;
  final String videoQuality;
  final bool autoplayVideos;
  final bool dataSaverMode;
  final bool downloadOnWiFiOnly;
  final bool highContrastMode;
  final bool reducedMotion;
  final bool screenReaderSupport;
  final double buttonSize;
  final bool analyticsEnabled;
  final bool crashReportsEnabled;
  final bool personalizedContent;

  const GeneralSettings({
    required this.fontSize,
    required this.animationsEnabled,
    required this.neonEffectsEnabled,
    required this.videoQuality,
    required this.autoplayVideos,
    required this.dataSaverMode,
    required this.downloadOnWiFiOnly,
    required this.highContrastMode,
    required this.reducedMotion,
    required this.screenReaderSupport,
    required this.buttonSize,
    required this.analyticsEnabled,
    required this.crashReportsEnabled,
    required this.personalizedContent,
  });

  factory GeneralSettings.defaults() {
    return const GeneralSettings(
      fontSize: 16.0,
      animationsEnabled: true,
      neonEffectsEnabled: true,
      videoQuality: 'auto',
      autoplayVideos: false,
      dataSaverMode: false,
      downloadOnWiFiOnly: true,
      highContrastMode: false,
      reducedMotion: false,
      screenReaderSupport: false,
      buttonSize: 1.0,
      analyticsEnabled: true,
      crashReportsEnabled: true,
      personalizedContent: true,
    );
  }

  factory GeneralSettings.fromJson(Map<String, dynamic> json) {
    return GeneralSettings(
      fontSize: (json['font_size'] as num?)?.toDouble() ?? 16.0,
      animationsEnabled: json['animations_enabled'] ?? true,
      neonEffectsEnabled: json['neon_effects_enabled'] ?? true,
      videoQuality: json['video_quality'] ?? 'auto',
      autoplayVideos: json['autoplay_videos'] ?? false,
      dataSaverMode: json['data_saver_mode'] ?? false,
      downloadOnWiFiOnly: json['download_wifi_only'] ?? true,
      highContrastMode: json['high_contrast_mode'] ?? false,
      reducedMotion: json['reduced_motion'] ?? false,
      screenReaderSupport: json['screen_reader_support'] ?? false,
      buttonSize: (json['button_size'] as num?)?.toDouble() ?? 1.0,
      analyticsEnabled: json['analytics_enabled'] ?? true,
      crashReportsEnabled: json['crash_reports_enabled'] ?? true,
      personalizedContent: json['personalized_content'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'font_size': fontSize,
      'animations_enabled': animationsEnabled,
      'neon_effects_enabled': neonEffectsEnabled,
      'video_quality': videoQuality,
      'autoplay_videos': autoplayVideos,
      'data_saver_mode': dataSaverMode,
      'download_wifi_only': downloadOnWiFiOnly,
      'high_contrast_mode': highContrastMode,
      'reduced_motion': reducedMotion,
      'screen_reader_support': screenReaderSupport,
      'button_size': buttonSize,
      'analytics_enabled': analyticsEnabled,
      'crash_reports_enabled': crashReportsEnabled,
      'personalized_content': personalizedContent,
    };
  }

  GeneralSettings copyWith({
    double? fontSize,
    bool? animationsEnabled,
    bool? neonEffectsEnabled,
    String? videoQuality,
    bool? autoplayVideos,
    bool? dataSaverMode,
    bool? downloadOnWiFiOnly,
    bool? highContrastMode,
    bool? reducedMotion,
    bool? screenReaderSupport,
    double? buttonSize,
    bool? analyticsEnabled,
    bool? crashReportsEnabled,
    bool? personalizedContent,
  }) {
    return GeneralSettings(
      fontSize: fontSize ?? this.fontSize,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      neonEffectsEnabled: neonEffectsEnabled ?? this.neonEffectsEnabled,
      videoQuality: videoQuality ?? this.videoQuality,
      autoplayVideos: autoplayVideos ?? this.autoplayVideos,
      dataSaverMode: dataSaverMode ?? this.dataSaverMode,
      downloadOnWiFiOnly: downloadOnWiFiOnly ?? this.downloadOnWiFiOnly,
      highContrastMode: highContrastMode ?? this.highContrastMode,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      screenReaderSupport: screenReaderSupport ?? this.screenReaderSupport,
      buttonSize: buttonSize ?? this.buttonSize,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      crashReportsEnabled: crashReportsEnabled ?? this.crashReportsEnabled,
      personalizedContent: personalizedContent ?? this.personalizedContent,
    );
  }

  @override
  String toString() {
    return 'GeneralSettings(fontSize: $fontSize, animationsEnabled: $animationsEnabled, videoQuality: $videoQuality)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GeneralSettings &&
        other.fontSize == fontSize &&
        other.animationsEnabled == animationsEnabled &&
        other.neonEffectsEnabled == neonEffectsEnabled &&
        other.videoQuality == videoQuality &&
        other.autoplayVideos == autoplayVideos &&
        other.dataSaverMode == dataSaverMode &&
        other.downloadOnWiFiOnly == downloadOnWiFiOnly &&
        other.highContrastMode == highContrastMode &&
        other.reducedMotion == reducedMotion &&
        other.screenReaderSupport == screenReaderSupport &&
        other.buttonSize == buttonSize &&
        other.analyticsEnabled == analyticsEnabled &&
        other.crashReportsEnabled == crashReportsEnabled &&
        other.personalizedContent == personalizedContent;
  }

  @override
  int get hashCode {
    return Object.hash(
      fontSize,
      animationsEnabled,
      neonEffectsEnabled,
      videoQuality,
      autoplayVideos,
      dataSaverMode,
      downloadOnWiFiOnly,
      highContrastMode,
      reducedMotion,
      screenReaderSupport,
      buttonSize,
      analyticsEnabled,
      crashReportsEnabled,
      personalizedContent,
    );
  }
}

/// מודל משולב עבור כל ההגדרות
class SettingsModel {
  final String userId;
  final NotificationSettings notificationSettings;
  final GeneralSettings generalSettings;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SettingsModel({
    required this.userId,
    required this.notificationSettings,
    required this.generalSettings,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SettingsModel.defaults(String userId) {
    final now = DateTime.now();
    return SettingsModel(
      userId: userId,
      notificationSettings: NotificationSettings.defaults(),
      generalSettings: GeneralSettings.defaults(),
      createdAt: now,
      updatedAt: now,
    );
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    try {
      return SettingsModel(
        userId: json['user_id']?.toString() ?? '',
        notificationSettings: json['notification_settings'] != null
            ? NotificationSettings.fromJson(json['notification_settings'] as Map<String, dynamic>)
            : NotificationSettings.defaults(),
        generalSettings: json['general_settings'] != null
            ? GeneralSettings.fromJson(json['general_settings'] as Map<String, dynamic>)
            : GeneralSettings.defaults(),
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
      );
    } catch (e) {
      throw FormatException('Failed to parse SettingsModel from JSON: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'notification_settings': notificationSettings.toJson(),
      'general_settings': generalSettings.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  SettingsModel copyWith({
    NotificationSettings? notificationSettings,
    GeneralSettings? generalSettings,
    DateTime? updatedAt,
  }) {
    return SettingsModel(
      userId: userId,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      generalSettings: generalSettings ?? this.generalSettings,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'SettingsModel(userId: $userId, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SettingsModel && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}