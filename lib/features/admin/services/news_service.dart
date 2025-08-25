import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/core/services/push_notification_service.dart';
import '/shared/models/update_model.dart';
import '/core/services/performance_service.dart';
import '/core/services/notification_service.dart';

enum UpdateStatus {
  draft,
  scheduled,
  published,
  archived
}

enum UpdateCategory {
  announcement,
  classNews,
  studentAchievement,
  studioEvent,
  tutorial,
  emergency
}

class NewsService {
  final SupabaseClient _supabase;
  final PushNotificationService _pushNotificationService;
  final PerformanceService _performanceService;
  final NotificationService _notificationService;

  NewsService({
    required SupabaseClient supabase,
    required PushNotificationService pushNotificationService,
    required PerformanceService performanceService,
    required NotificationService notificationService,
  }) : 
    _supabase = supabase,
    _pushNotificationService = pushNotificationService,
    _performanceService = performanceService,
    _notificationService = notificationService;

  // Create a new update/news post
  Future<UpdateModel> createUpdate({
    required String title,
    required String content,
    String? imageUrl,
    bool isImportant = false,
    DateTime? publishAt,
    UpdateCategory category = UpdateCategory.announcement,
  }) async {
    // Validate input
    _validateUpdateContent(title, content);

    try {
      // Generate SEO-friendly slug
      final slug = _generateSlug(title);

      // Create update data for insertion
      final updateData = {
        'title_he': title,
        'content_he': content,
        'image_url': imageUrl,
        'is_important': isImportant,
        'update_type': category.toString().split('.').last,
        'status': publishAt != null 
          ? UpdateStatus.scheduled.toString().split('.').last
          : UpdateStatus.draft.toString().split('.').last,
        'publish_date': publishAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'author_name': _supabase.auth.currentUser?.email,
        'likes_count': 0,
        'comments_count': 0,
        'shares_count': 0,
        'tags': <String>[],
        'is_pinned': false,
        'is_featured': false,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Insert into Supabase
      final response = await _supabase
        .from('updates')
        .insert(updateData)
        .select()
        .single();

      // Log performance
      try {
        await _performanceService.logEvent('update_created');
      } catch (e) {
        // Ignore performance logging errors
        if (kDebugMode) print('Performance logging error: $e');
      }

      return UpdateModel.fromJson(response);
    } catch (e) {
      try {
        // Log exception - captureException method not available
        debugPrint('Exception caught: $e');
      } catch (notificationError) {
        // Ignore notification service errors
        if (kDebugMode) print('Notification service error: $notificationError');
      }
      rethrow;
    }
  }

  // Update existing update
  Future<UpdateModel> updateUpdate({
    required String updateId,
    String? title,
    String? content,
    String? imageUrl,
    bool? isImportant,
    UpdateCategory? category,
  }) async {
    try {
      // Fetch existing update
      final existingUpdate = await _supabase
        .from('updates')
        .select()
        .eq('id', updateId)
        .single();

      // Prepare update data
      final updateData = {
        if (title != null) 'title': title,
        if (content != null) 'content': content,
        if (imageUrl != null) 'image_url': imageUrl,
        if (isImportant != null) 'is_important': isImportant,
        if (category != null) 'category': category.toString().split('.').last,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Validate content if provided
      if (title != null || content != null) {
        _validateUpdateContent(
          title ?? existingUpdate['title'], 
          content ?? existingUpdate['content']
        );
      }

      // Update in Supabase
      final response = await _supabase
        .from('updates')
        .update(updateData)
        .eq('id', updateId)
        .select()
        .single();

      // Log performance
      try {
        await _performanceService.logEvent('update_edited');
      } catch (e) {
        // Ignore performance logging errors
        if (kDebugMode) print('Performance logging error: $e');
      }

      return UpdateModel.fromJson(response);
    } catch (e) {
      try {
        // Log exception - captureException method not available
        debugPrint('Exception caught: $e');
      } catch (notificationError) {
        // Ignore notification service errors
        if (kDebugMode) print('Notification service error: $notificationError');
      }
      rethrow;
    }
  }

  // Delete update (soft delete)
  Future<void> deleteUpdate(String updateId) async {
    try {
      await _supabase
        .from('updates')
        .update({
          'status': UpdateStatus.archived.toString().split('.').last,
          'deleted_at': DateTime.now().toIso8601String()
        })
        .eq('id', updateId);

      // Log performance
      try {
        await _performanceService.logEvent('update_deleted');
      } catch (e) {
        // Ignore performance logging errors
        if (kDebugMode) print('Performance logging error: $e');
      }
    } catch (e) {
      try {
        // Log exception - captureException method not available
        debugPrint('Exception caught: $e');
      } catch (notificationError) {
        // Ignore notification service errors
        if (kDebugMode) print('Notification service error: $notificationError');
      }
      rethrow;
    }
  }

  // Publish draft or scheduled update
  Future<UpdateModel> publishUpdate(String updateId) async {
    try {
      final response = await _supabase
        .from('updates')
        .update({
          'status': UpdateStatus.published.toString().split('.').last,
          'published_at': DateTime.now().toIso8601String()
        })
        .eq('id', updateId)
        .select()
        .single();

      final update = UpdateModel.fromJson(response);

      // Send push notification for important updates
      if (update.isImportant) {
        await sendPushNotification(
          updateId: updateId, 
          title: update.title, 
          body: _truncateContent(update.content)
        );
      }

      // Log performance
      try {
        await _performanceService.logEvent('update_published');
      } catch (e) {
        // Ignore performance logging errors
        if (kDebugMode) print('Performance logging error: $e');
      }

      return update;
    } catch (e) {
      try {
        // Log exception - captureException method not available
        debugPrint('Exception caught: $e');
      } catch (notificationError) {
        // Ignore notification service errors
        if (kDebugMode) print('Notification service error: $notificationError');
      }
      rethrow;
    }
  }

  // Schedule update for future publishing
  Future<UpdateModel> scheduleUpdate(
    String updateId, 
    DateTime publishAt
  ) async {
    try {
      final response = await _supabase
        .from('updates')
        .update({
          'status': UpdateStatus.scheduled.toString().split('.').last,
          'published_at': publishAt.toIso8601String()
        })
        .eq('id', updateId)
        .select()
        .single();

      // Log performance
      try {
        await _performanceService.logEvent('update_scheduled');
      } catch (e) {
        // Ignore performance logging errors
        if (kDebugMode) print('Performance logging error: $e');
      }

      return UpdateModel.fromJson(response);
    } catch (e) {
      try {
        // Log exception - captureException method not available
        debugPrint('Exception caught: $e');
      } catch (notificationError) {
        // Ignore notification service errors
        if (kDebugMode) print('Notification service error: $notificationError');
      }
      rethrow;
    }
  }

  // Get all updates with pagination and filtering
  Future<List<UpdateModel>> getAllUpdates({
    int page = 1,
    int limit = 10,
    UpdateStatus? status,
    String sortBy = 'created_at',
    bool descending = true,
  }) async {
    try {
      var query = _supabase
        .from('updates')
        .select();

      if (status != null) {
        query = query.eq('status', status.toString().split('.').last);
      }

      final response = await query
        .order(sortBy, ascending: !descending)
        .range((page - 1) * limit, page * limit - 1);

      return response.map((json) => UpdateModel.fromJson(json)).toList();
    } catch (e) {
      try {
        // Log exception - captureException method not available
        debugPrint('Exception caught: $e');
      } catch (notificationError) {
        // Ignore notification service errors
        if (kDebugMode) print('Notification service error: $notificationError');
      }
      rethrow;
    }
  }

  // Get only published updates
  Future<List<UpdateModel>> getPublishedUpdates({
    int page = 1, 
    int limit = 10
  }) async {
    return getAllUpdates(
      page: page, 
      limit: limit, 
      status: UpdateStatus.published
    );
  }

  // Get draft updates
  Future<List<UpdateModel>> getDraftUpdates() async {
    return getAllUpdates(status: UpdateStatus.draft);
  }

  // Search and filter updates
  Future<List<UpdateModel>> searchUpdates({
    String? query,
    UpdateStatus? status,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      var q = _supabase.from('updates').select();

      if (query != null) {
        q = q.or(
          'title.ilike.%$query%, content.ilike.%$query%'
        );
      }

      if (status != null) {
        q = q.eq('status', status.toString().split('.').last);
      }

      if (dateFrom != null) {
        q = q.gte('created_at', dateFrom.toIso8601String());
      }

      if (dateTo != null) {
        q = q.lte('created_at', dateTo.toIso8601String());
      }

      final response = await q;
      return response.map((json) => UpdateModel.fromJson(json)).toList();
    } catch (e) {
      try {
        // Log exception - captureException method not available
        debugPrint('Exception caught: $e');
      } catch (notificationError) {
        // Ignore notification service errors
        if (kDebugMode) print('Notification service error: $notificationError');
      }
      rethrow;
    }
  }

  // Send push notification
  Future<void> sendPushNotification({
    required String updateId,
    required String title,
    required String body,
  }) async {
    try {
      await _pushNotificationService.sendNotification(
        title: title,
        body: body,
        data: {'update_id': updateId}
      );

      // Log performance
      try {
        await _performanceService.logEvent('push_notification_sent');
      } catch (e) {
        // Ignore performance logging errors
        if (kDebugMode) print('Performance logging error: $e');
      }
    } catch (e) {
      try {
        // Log exception - captureException method not available
        debugPrint('Exception caught: $e');
      } catch (notificationError) {
        // Ignore notification service errors
        if (kDebugMode) print('Notification service error: $notificationError');
      }
      rethrow;
    }
  }

  // Get update statistics
  Future<Map<String, dynamic>> getUpdateStats(String updateId) async {
    try {
      // Fetch view count and engagement metrics
      final viewCount = await _supabase
        .from('update_views')
        .select('count')
        .eq('update_id', updateId)
        .single();

      // Add more metrics as needed
      return {
        'view_count': viewCount['count'] ?? 0,
        // Add more metrics like likes, shares, etc.
      };
    } catch (e) {
      try {
        // Log exception - captureException method not available
        debugPrint('Exception caught: $e');
      } catch (notificationError) {
        // Ignore notification service errors
        if (kDebugMode) print('Notification service error: $notificationError');
      }
      rethrow;
    }
  }

  // Duplicate an existing update as draft
  Future<UpdateModel> duplicateUpdate(String updateId) async {
    try {
      final existingUpdate = await _supabase
        .from('updates')
        .select()
        .eq('id', updateId)
        .single();

      return createUpdate(
        title: '${existingUpdate['title']} (Copy)',
        content: existingUpdate['content'],
        imageUrl: existingUpdate['image_url'],
        isImportant: existingUpdate['is_important'] ?? false,
      );
    } catch (e) {
      try {
        // Log exception - captureException method not available
        debugPrint('Exception caught: $e');
      } catch (notificationError) {
        // Ignore notification service errors
        if (kDebugMode) print('Notification service error: $notificationError');
      }
      rethrow;
    }
  }

  // Bulk publish updates
  Future<void> bulkPublish(List<String> updateIds) async {
    try {
      for (final updateId in updateIds) {
        await publishUpdate(updateId);
      }

      // Log performance
      try {
        await _performanceService.logEvent('bulk_updates_published');
      } catch (e) {
        // Ignore performance logging errors
        if (kDebugMode) print('Performance logging error: $e');
      }
    } catch (e) {
      try {
        // Log exception - captureException method not available
        debugPrint('Exception caught: $e');
      } catch (notificationError) {
        // Ignore notification service errors
        if (kDebugMode) print('Notification service error: $notificationError');
      }
      rethrow;
    }
  }

  // Get scheduled updates
  Future<List<UpdateModel>> getScheduledUpdates() async {
    return getAllUpdates(status: UpdateStatus.scheduled);
  }

  // Cancel scheduled update
  Future<void> cancelScheduled(String updateId) async {
    try {
      await _supabase
        .from('updates')
        .update({
          'status': UpdateStatus.draft.toString().split('.').last,
          'published_at': null
        })
        .eq('id', updateId);

      // Log performance
      try {
        await _performanceService.logEvent('scheduled_update_canceled');
      } catch (e) {
        // Ignore performance logging errors
        if (kDebugMode) print('Performance logging error: $e');
      }
    } catch (e) {
      try {
        // Log exception - captureException method not available
        debugPrint('Exception caught: $e');
      } catch (notificationError) {
        // Ignore notification service errors
        if (kDebugMode) print('Notification service error: $notificationError');
      }
      rethrow;
    }
  }

  // Private helper methods
  void _validateUpdateContent(String title, String content) {
    if (title.length < 3 || title.length > 120) {
      throw ArgumentError('כותרת צריכה להיות באורך בין 3 ל-120 תווים');
    }

    if (content.length < 10 || content.length > 5000) {
      throw ArgumentError('תוכן העדכון צריך להיות באורך בין 10 ל-5000 תווים');
    }
  }

  String _generateSlug(String title) {
    // Convert to Hebrew-friendly slug
    return title
      .toLowerCase()
      .replaceAll(' ', '-')
      .replaceAll(RegExp(r'[^\w-]'), '');
  }

  String _truncateContent(String content, {int maxLength = 100}) {
    return content.length > maxLength 
      ? '${content.substring(0, maxLength)}...' 
      : content;
  }
}