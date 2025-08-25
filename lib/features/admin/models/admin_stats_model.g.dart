// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminStatsModel _$AdminStatsModelFromJson(Map<String, dynamic> json) =>
    AdminStatsModel(
      totalUsers: (json['total_users'] as num).toInt(),
      activeUsers: (json['active_users'] as num).toInt(),
      totalTutorials: (json['total_tutorials'] as num).toInt(),
      tutorialViews: (json['tutorial_views'] as num).toInt(),
      galleryImages: (json['gallery_images'] as num).toInt(),
      publishedUpdates: (json['published_updates'] as num).toInt(),
      completionRate: (json['completion_rate'] as num).toDouble(),
      newSignups: (json['new_signups'] as num).toInt(),
      usersByRole: Map<String, int>.from(json['users_by_role'] as Map),
      dailyUsage: (json['daily_usage'] as List<dynamic>)
          .map((e) => DailyUsageStats.fromJson(e as Map<String, dynamic>))
          .toList(),
      popularTutorials: (json['popular_tutorials'] as List<dynamic>)
          .map((e) => PopularTutorial.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AdminStatsModelToJson(AdminStatsModel instance) =>
    <String, dynamic>{
      'total_users': instance.totalUsers,
      'active_users': instance.activeUsers,
      'total_tutorials': instance.totalTutorials,
      'tutorial_views': instance.tutorialViews,
      'gallery_images': instance.galleryImages,
      'published_updates': instance.publishedUpdates,
      'completion_rate': instance.completionRate,
      'new_signups': instance.newSignups,
      'users_by_role': instance.usersByRole,
      'daily_usage': instance.dailyUsage,
      'popular_tutorials': instance.popularTutorials,
    };

DailyUsageStats _$DailyUsageStatsFromJson(Map<String, dynamic> json) =>
    DailyUsageStats(
      date: DateTime.parse(json['date'] as String),
      activeUsers: (json['active_users'] as num).toInt(),
      tutorialViews: (json['tutorial_views'] as num).toInt(),
      avgSessionTime: (json['avg_session_time'] as num).toDouble(),
    );

Map<String, dynamic> _$DailyUsageStatsToJson(DailyUsageStats instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'active_users': instance.activeUsers,
      'tutorial_views': instance.tutorialViews,
      'avg_session_time': instance.avgSessionTime,
    };

PopularTutorial _$PopularTutorialFromJson(Map<String, dynamic> json) =>
    PopularTutorial(
      id: json['id'] as String,
      title: json['title'] as String,
      views: (json['views'] as num).toInt(),
      completionRate: (json['completion_rate'] as num).toDouble(),
      thumbnailUrl: json['thumbnail_url'] as String?,
    );

Map<String, dynamic> _$PopularTutorialToJson(PopularTutorial instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'views': instance.views,
      'completion_rate': instance.completionRate,
      'thumbnail_url': instance.thumbnailUrl,
    };

AdminAction _$AdminActionFromJson(Map<String, dynamic> json) => AdminAction(
  id: json['id'] as String,
  adminId: json['admin_id'] as String,
  adminName: json['admin_name'] as String,
  actionType: $enumDecode(_$AdminActionTypeEnumMap, json['action_type']),
  description: json['description'] as String,
  targetId: json['target_id'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$AdminActionToJson(AdminAction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'admin_id': instance.adminId,
      'admin_name': instance.adminName,
      'action_type': _$AdminActionTypeEnumMap[instance.actionType]!,
      'description': instance.description,
      'target_id': instance.targetId,
      'metadata': instance.metadata,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$AdminActionTypeEnumMap = {
  AdminActionType.userCreated: 'user_created',
  AdminActionType.userUpdated: 'user_updated',
  AdminActionType.userDeleted: 'user_deleted',
  AdminActionType.userRoleChanged: 'user_role_changed',
  AdminActionType.tutorialUploaded: 'tutorial_uploaded',
  AdminActionType.galleryItemAdded: 'gallery_item_added',
  AdminActionType.updatePublished: 'update_published',
  AdminActionType.bulkOperation: 'bulk_operation',
};
