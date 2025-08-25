import 'package:json_annotation/json_annotation.dart';

part 'admin_stats_model.g.dart';

/// מודל לסטטיסטיקות מנהלים באפליקציית זזה דאנס
@JsonSerializable(fieldRename: FieldRename.snake)
class AdminStatsModel {
  /// מספר המשתמשים הכולל
  @JsonKey(name: 'total_users')
  final int totalUsers;
  
  /// מספר המשתמשים הפעילים (חודש אחרון)
  @JsonKey(name: 'active_users')
  final int activeUsers;
  
  /// מספר המדריכים הכולל
  @JsonKey(name: 'total_tutorials')
  final int totalTutorials;
  
  /// מספר צפיות במדריכים (חודש אחרון)
  @JsonKey(name: 'tutorial_views')
  final int tutorialViews;
  
  /// מספר תמונות בגלריה
  @JsonKey(name: 'gallery_images')
  final int galleryImages;
  
  /// מספר עדכונים שפורסמו
  @JsonKey(name: 'published_updates')
  final int publishedUpdates;
  
  /// שיעור השלמת מדריכים (אחוז)
  @JsonKey(name: 'completion_rate')
  final double completionRate;
  
  /// מספר הרשמות חדשות (שבוע אחרון)
  @JsonKey(name: 'new_signups')
  final int newSignups;
  
  /// התפלגות משתמשים לפי תפקיד
  @JsonKey(name: 'users_by_role')
  final Map<String, int> usersByRole;
  
  /// סטטיסטיקות שימוש יומי (7 ימים אחרונים)
  @JsonKey(name: 'daily_usage')
  final List<DailyUsageStats> dailyUsage;
  
  /// מדריכים פופולריים (5 הראשונים)
  @JsonKey(name: 'popular_tutorials')
  final List<PopularTutorial> popularTutorials;

  const AdminStatsModel({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalTutorials,
    required this.tutorialViews,
    required this.galleryImages,
    required this.publishedUpdates,
    required this.completionRate,
    required this.newSignups,
    required this.usersByRole,
    required this.dailyUsage,
    required this.popularTutorials,
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) =>
      _$AdminStatsModelFromJson(json);

  Map<String, dynamic> toJson() => _$AdminStatsModelToJson(this);

  /// יצירת מודל ריק עבור loading state
  factory AdminStatsModel.empty() => const AdminStatsModel(
        totalUsers: 0,
        activeUsers: 0,
        totalTutorials: 0,
        tutorialViews: 0,
        galleryImages: 0,
        publishedUpdates: 0,
        completionRate: 0.0,
        newSignups: 0,
        usersByRole: {},
        dailyUsage: [],
        popularTutorials: [],
      );

  @override
  String toString() => 'AdminStatsModel(totalUsers: $totalUsers, activeUsers: $activeUsers)';
}

/// סטטיסטיקות שימוש יומי
@JsonSerializable(fieldRename: FieldRename.snake)
class DailyUsageStats {
  /// תאריך היום
  final DateTime date;
  
  /// מספר משתמשים פעילים ביום
  @JsonKey(name: 'active_users')
  final int activeUsers;
  
  /// מספר צפיות במדריכים ביום
  @JsonKey(name: 'tutorial_views')
  final int tutorialViews;
  
  /// זמן שימוש ממוצע בדקות
  @JsonKey(name: 'avg_session_time')
  final double avgSessionTime;

  const DailyUsageStats({
    required this.date,
    required this.activeUsers,
    required this.tutorialViews,
    required this.avgSessionTime,
  });

  factory DailyUsageStats.fromJson(Map<String, dynamic> json) =>
      _$DailyUsageStatsFromJson(json);

  Map<String, dynamic> toJson() => _$DailyUsageStatsToJson(this);

  @override
  String toString() => 'DailyUsageStats(date: $date, activeUsers: $activeUsers)';
}

/// מדריך פופולרי
@JsonSerializable(fieldRename: FieldRename.snake)
class PopularTutorial {
  /// מזהה המדריך
  final String id;
  
  /// כותרת המדריך
  final String title;
  
  /// מספר צפיות
  final int views;
  
  /// שיעור השלמה (אחוז)
  @JsonKey(name: 'completion_rate')
  final double completionRate;
  
  /// URL של thumbnail
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;

  const PopularTutorial({
    required this.id,
    required this.title,
    required this.views,
    required this.completionRate,
    this.thumbnailUrl,
  });

  factory PopularTutorial.fromJson(Map<String, dynamic> json) =>
      _$PopularTutorialFromJson(json);

  Map<String, dynamic> toJson() => _$PopularTutorialToJson(this);

  @override
  String toString() => 'PopularTutorial(title: $title, views: $views)';
}

/// סוגי פעולות מנהלים לצורך audit log
enum AdminActionType {
  @JsonValue('user_created')
  userCreated,
  
  @JsonValue('user_updated')
  userUpdated,
  
  @JsonValue('user_deleted')
  userDeleted,
  
  @JsonValue('user_role_changed')
  userRoleChanged,
  
  @JsonValue('tutorial_uploaded')
  tutorialUploaded,
  
  @JsonValue('gallery_item_added')
  galleryItemAdded,
  
  @JsonValue('update_published')
  updatePublished,
  
  @JsonValue('bulk_operation')
  bulkOperation,
}

/// מודל פעולת מנהל
@JsonSerializable(fieldRename: FieldRename.snake)
class AdminAction {
  /// מזהה הפעולה
  final String id;
  
  /// מזהה המנהל שביצע את הפעולה
  @JsonKey(name: 'admin_id')
  final String adminId;
  
  /// שם המנהל
  @JsonKey(name: 'admin_name')
  final String adminName;
  
  /// סוג הפעולה
  @JsonKey(name: 'action_type')
  final AdminActionType actionType;
  
  /// תיאור הפעולה
  final String description;
  
  /// מזהה הישות שהושפעה (משתמש, מדריך וכו')
  @JsonKey(name: 'target_id')
  final String? targetId;
  
  /// מטא-דאטה נוספת (JSON)
  final Map<String, dynamic>? metadata;
  
  /// זמן ביצוע הפעולה
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const AdminAction({
    required this.id,
    required this.adminId,
    required this.adminName,
    required this.actionType,
    required this.description,
    this.targetId,
    this.metadata,
    required this.createdAt,
  });

  factory AdminAction.fromJson(Map<String, dynamic> json) =>
      _$AdminActionFromJson(json);

  Map<String, dynamic> toJson() => _$AdminActionToJson(this);

  @override
  String toString() => 'AdminAction(actionType: $actionType, description: $description)';
}