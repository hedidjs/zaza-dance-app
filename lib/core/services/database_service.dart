import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_model.dart';
import '../../shared/models/tutorial_model.dart';
import '../../shared/models/gallery_model.dart';
import '../../shared/models/update_model.dart';

/// Database service for Zaza Dance app using Supabase
class DatabaseService {
  static final SupabaseClient _client = SupabaseConfig.client;

  // =============================================
  // USER OPERATIONS
  // =============================================

  /// Get all users (admin only)
  static Future<List<UserModel>> getUsers({
    String? role,
    String? searchQuery,
    String orderBy = 'created_at',
    bool ascending = false,
  }) async {
    var query = _client
        .from(SupabaseConfig.usersTable)
        .select()
        .eq('is_active', true);

    if (role != null && role != 'all') {
      query = query.eq('role', role);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or('display_name.ilike.%$searchQuery%,email.ilike.%$searchQuery%');
    }

    final response = await query.order(orderBy, ascending: ascending);
    return (response as List)
        .map((json) => UserModel.fromJson(json))
        .toList();
  }

  /// Create user profile after auth signup
  static Future<UserModel> createUserProfile({
    required String userId,
    required String email,
    required String displayName,
    String? phone,
    String? address,
    String role = 'student',
  }) async {
    final userData = {
      'id': userId,
      'email': email,
      'display_name': displayName,
      'phone': phone,
      'address': address,
      'role': role,
      'is_active': true,
    };

    final response = await _client
        .from(SupabaseConfig.usersTable)
        .insert(userData)
        .select()
        .single();

    return UserModel.fromJson(response);
  }

  /// Update user profile
  static Future<UserModel> updateUserProfile({
    required String userId,
    String? displayName,
    String? phone,
    String? address,
    String? profileImageUrl,
    String? bio,
  }) async {
    final updateData = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (displayName != null) updateData['display_name'] = displayName;
    if (phone != null) updateData['phone'] = phone;
    if (address != null) updateData['address'] = address;
    if (profileImageUrl != null) updateData['profile_image_url'] = profileImageUrl;
    if (bio != null) updateData['bio'] = bio;

    final response = await _client
        .from(SupabaseConfig.usersTable)
        .update(updateData)
        .eq('id', userId)
        .select()
        .single();

    return UserModel.fromJson(response);
  }

  /// Get user by ID
  static Future<UserModel?> getUserById(String userId) async {
    final response = await _client
        .from(SupabaseConfig.usersTable)
        .select()
        .eq('id', userId)
        .eq('is_active', true)
        .maybeSingle();

    return response != null ? UserModel.fromJson(response) : null;
  }

  /// Delete user (admin only)
  static Future<void> deleteUser(String userId) async {
    await _client
        .from(SupabaseConfig.usersTable)
        .update({'is_active': false})
        .eq('id', userId);
  }

  // =============================================
  // TUTORIAL OPERATIONS
  // =============================================

  /// Get tutorials with filters
  static Future<List<TutorialModel>> getTutorials({
    DifficultyLevel? difficulty,
    String? category,
    String? searchQuery,
    bool? isFeatured,
    String orderBy = 'created_at',
    bool ascending = false,
    int? limit,
  }) async {
    var query = _client
        .from(SupabaseConfig.tutorialsTable)
        .select('''
          *,
          instructor:instructor_id(id, display_name)
        ''')
        .eq('is_published', true);

    if (difficulty != null) {
      query = query.eq('difficulty_level', difficulty.name);
    }

    if (category != null && category.isNotEmpty) {
      query = query.eq('category', category);
    }

    if (isFeatured != null) {
      query = query.eq('is_featured', isFeatured);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or('title_he.ilike.%$searchQuery%,description_he.ilike.%$searchQuery%');
    }

    query = query.order(orderBy, ascending: ascending);

    if (limit != null) {
      query = query.limit(limit);
    }

    final response = await query;
    return (response as List)
        .map((json) => TutorialModel.fromJson(json))
        .toList();
  }

  /// Create new tutorial
  static Future<TutorialModel> createTutorial({
    required String titleHe,
    String? titleEn,
    String? descriptionHe,
    String? descriptionEn,
    required String videoUrl,
    String? thumbnailUrl,
    required DifficultyLevel difficultyLevel,
    required int durationMinutes,
    String? instructorId,
    String? category,
    String? danceStyle,
    bool isFeatured = false,
    List<String>? tags,
  }) async {
    final tutorialData = {
      'title_he': titleHe,
      'title_en': titleEn,
      'description_he': descriptionHe,
      'description_en': descriptionEn,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'difficulty_level': difficultyLevel.name,
      'duration_minutes': durationMinutes,
      'instructor_id': instructorId,
      'category': category,
      'dance_style': danceStyle,
      'is_featured': isFeatured,
      'tags': tags,
      'is_published': true,
    };

    final response = await _client
        .from(SupabaseConfig.tutorialsTable)
        .insert(tutorialData)
        .select('''
          *,
          instructor:instructor_id(id, display_name)
        ''')
        .single();

    return TutorialModel.fromJson(response);
  }

  /// Update tutorial
  static Future<TutorialModel> updateTutorial({
    required String tutorialId,
    String? titleHe,
    String? titleEn,
    String? descriptionHe,
    String? descriptionEn,
    String? videoUrl,
    String? thumbnailUrl,
    DifficultyLevel? difficultyLevel,
    int? durationMinutes,
    String? instructorId,
    String? category,
    String? danceStyle,
    bool? isFeatured,
    bool? isPublished,
    List<String>? tags,
  }) async {
    final updateData = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (titleHe != null) updateData['title_he'] = titleHe;
    if (titleEn != null) updateData['title_en'] = titleEn;
    if (descriptionHe != null) updateData['description_he'] = descriptionHe;
    if (descriptionEn != null) updateData['description_en'] = descriptionEn;
    if (videoUrl != null) updateData['video_url'] = videoUrl;
    if (thumbnailUrl != null) updateData['thumbnail_url'] = thumbnailUrl;
    if (difficultyLevel != null) updateData['difficulty_level'] = difficultyLevel.name;
    if (durationMinutes != null) updateData['duration_minutes'] = durationMinutes;
    if (instructorId != null) updateData['instructor_id'] = instructorId;
    if (category != null) updateData['category'] = category;
    if (danceStyle != null) updateData['dance_style'] = danceStyle;
    if (isFeatured != null) updateData['is_featured'] = isFeatured;
    if (isPublished != null) updateData['is_published'] = isPublished;
    if (tags != null) updateData['tags'] = tags;

    final response = await _client
        .from(SupabaseConfig.tutorialsTable)
        .update(updateData)
        .eq('id', tutorialId)
        .select('''
          *,
          instructor:instructor_id(id, display_name)
        ''')
        .single();

    return TutorialModel.fromJson(response);
  }

  /// Increment tutorial view count
  static Future<void> incrementTutorialViews(String tutorialId) async {
    await _client.rpc('increment_view_count', params: {
      'content_table': 'tutorials',
      'content_id': tutorialId,
    });
  }

  /// Delete tutorial
  static Future<void> deleteTutorial(String tutorialId) async {
    await _client
        .from(SupabaseConfig.tutorialsTable)
        .update({'is_published': false})
        .eq('id', tutorialId);
  }

  // =============================================
  // GALLERY OPERATIONS
  // =============================================

  /// Get gallery items
  static Future<List<GalleryModel>> getGalleryItems({
    String? category,
    String? mediaType,
    String? searchQuery,
    bool? isFeatured,
    String orderBy = 'created_at',
    bool ascending = false,
    int? limit,
  }) async {
    var query = _client
        .from(SupabaseConfig.galleryItemsTable)
        .select('''
          *,
          uploader:uploaded_by(id, display_name)
        ''')
        .eq('is_published', true);

    if (category != null && category.isNotEmpty) {
      query = query.eq('category', category);
    }

    if (mediaType != null && mediaType.isNotEmpty) {
      query = query.eq('media_type', mediaType);
    }

    if (isFeatured != null) {
      query = query.eq('is_featured', isFeatured);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or('title_he.ilike.%$searchQuery%,description_he.ilike.%$searchQuery%');
    }

    query = query.order(orderBy, ascending: ascending);

    if (limit != null) {
      query = query.limit(limit);
    }

    final response = await query;
    return (response as List)
        .map((json) => GalleryModel.fromJson(json))
        .toList();
  }

  /// Create gallery item
  static Future<GalleryModel> createGalleryItem({
    required String titleHe,
    String? titleEn,
    String? descriptionHe,
    String? descriptionEn,
    required String mediaUrl,
    required String mediaType,
    required String category,
    String? thumbnailUrl,
    int? fileSize,
    int? durationSeconds,
    int? width,
    int? height,
    String? uploadedBy,
    bool isFeatured = false,
    List<String>? tags,
  }) async {
    final galleryData = {
      'title_he': titleHe,
      'title_en': titleEn,
      'description_he': descriptionHe,
      'description_en': descriptionEn,
      'media_url': mediaUrl,
      'media_type': mediaType,
      'category': category,
      'thumbnail_url': thumbnailUrl,
      'file_size': fileSize,
      'duration_seconds': durationSeconds,
      'width': width,
      'height': height,
      'uploaded_by': uploadedBy,
      'is_featured': isFeatured,
      'tags': tags,
      'is_published': true,
    };

    final response = await _client
        .from(SupabaseConfig.galleryItemsTable)
        .insert(galleryData)
        .select('''
          *,
          uploader:uploaded_by(id, display_name)
        ''')
        .single();

    return GalleryModel.fromJson(response);
  }

  /// Increment gallery item view count
  static Future<void> incrementGalleryViews(String galleryItemId) async {
    await _client.rpc('increment_view_count', params: {
      'content_table': 'gallery_items',
      'content_id': galleryItemId,
    });
  }

  // =============================================
  // UPDATES OPERATIONS
  // =============================================

  /// Get updates/news
  static Future<List<UpdateModel>> getUpdates({
    String? updateType,
    String? searchQuery,
    bool? isActive,
    bool? isPinned,
    String orderBy = 'created_at',
    bool ascending = false,
    int? limit,
  }) async {
    var query = _client
        .from(SupabaseConfig.updatesTable)
        .select('''
          *,
          author:author_id(id, display_name)
        ''')
        .lte('publish_at', DateTime.now().toIso8601String());

    if (isActive != null) {
      query = query.eq('is_active', isActive);
    } else {
      query = query.eq('is_active', true);
    }

    if (updateType != null && updateType.isNotEmpty) {
      query = query.eq('update_type', updateType);
    }

    if (isPinned != null) {
      query = query.eq('is_pinned', isPinned);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or('title_he.ilike.%$searchQuery%,content_he.ilike.%$searchQuery%');
    }

    // Order by pinned first, then by specified order
    query = query.order('is_pinned', ascending: false);
    query = query.order(orderBy, ascending: ascending);

    if (limit != null) {
      query = query.limit(limit);
    }

    final response = await query;
    return (response as List)
        .map((json) => UpdateModel.fromJson(json))
        .toList();
  }

  /// Create update
  static Future<UpdateModel> createUpdate({
    required String titleHe,
    required String contentHe,
    String? summaryHe,
    required String updateType,
    String? authorId,
    bool isActive = true,
    bool isPinned = false,
    int priority = 1,
    String? imageUrl,
    DateTime? publishAt,
    DateTime? expiresAt,
    List<String>? tags,
  }) async {
    final updateData = {
      'title_he': titleHe,
      'content_he': contentHe,
      'summary_he': summaryHe,
      'update_type': updateType,
      'author_id': authorId,
      'is_active': isActive,
      'is_pinned': isPinned,
      'priority': priority,
      'image_url': imageUrl,
      'publish_at': publishAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'tags': tags,
    };

    final response = await _client
        .from(SupabaseConfig.updatesTable)
        .insert(updateData)
        .select('''
          *,
          author:author_id(id, display_name)
        ''')
        .single();

    return UpdateModel.fromJson(response);
  }

  /// Increment update view count
  static Future<void> incrementUpdateViews(String updateId) async {
    await _client.rpc('increment_view_count', params: {
      'content_table': 'updates',
      'content_id': updateId,
    });
  }

  // =============================================
  // USER PROGRESS OPERATIONS
  // =============================================

  /// Update user progress for tutorial
  static Future<void> updateUserProgress({
    required String userId,
    required String tutorialId,
    required int watchedDurationSeconds,
    required bool isCompleted,
    required double completionPercentage,
  }) async {
    final progressData = {
      'user_id': userId,
      'tutorial_id': tutorialId,
      'watched_duration_seconds': watchedDurationSeconds,
      'is_completed': isCompleted,
      'completion_percentage': completionPercentage,
      'last_watched_at': DateTime.now().toIso8601String(),
      'completed_at': isCompleted ? DateTime.now().toIso8601String() : null,
    };

    await _client
        .from(SupabaseConfig.userProgressTable)
        .upsert(progressData, onConflict: 'user_id,tutorial_id');
  }

  /// Get user progress for tutorials
  static Future<List<Map<String, dynamic>>> getUserProgress(String userId) async {
    final response = await _client
        .from(SupabaseConfig.userProgressTable)
        .select('''
          *,
          tutorial:tutorial_id(id, title_he, thumbnail_url)
        ''')
        .eq('user_id', userId)
        .order('last_watched_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // =============================================
  // ANALYTICS OPERATIONS
  // =============================================

  /// Track analytics event
  static Future<void> trackEvent({
    required String eventType,
    String? userId,
    String? contentId,
    String? contentType,
    Map<String, dynamic>? metadata,
    String? sessionId,
    Map<String, dynamic>? deviceInfo,
  }) async {
    final analyticsData = {
      'event_type': eventType,
      'user_id': userId,
      'content_id': contentId,
      'content_type': contentType,
      'metadata': metadata,
      'session_id': sessionId,
      'device_info': deviceInfo,
    };

    await _client
        .from(SupabaseConfig.analyticsTable)
        .insert(analyticsData);
  }

  /// Get analytics data (admin only)
  static Future<List<Map<String, dynamic>>> getAnalytics({
    String? eventType,
    String? contentType,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    var query = _client
        .from(SupabaseConfig.analyticsTable)
        .select();

    if (eventType != null) {
      query = query.eq('event_type', eventType);
    }

    if (contentType != null) {
      query = query.eq('content_type', contentType);
    }

    if (startDate != null) {
      query = query.gte('created_at', startDate.toIso8601String());
    }

    if (endDate != null) {
      query = query.lte('created_at', endDate.toIso8601String());
    }

    query = query.order('created_at', ascending: false);

    if (limit != null) {
      query = query.limit(limit);
    }

    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }

  // =============================================
  // LIKES OPERATIONS
  // =============================================

  /// Toggle like for content
  static Future<bool> toggleLike({
    required String userId,
    required String contentId,
    required String contentType,
  }) async {
    final result = await _client.rpc('toggle_like', params: {
      'user_id': userId,
      'content_id': contentId,
      'content_type': contentType,
    });

    return result as bool; // Returns true if liked, false if unliked
  }

  /// Check if user has liked content
  static Future<bool> hasUserLiked({
    required String userId,
    required String contentId,
    required String contentType,
  }) async {
    final response = await _client
        .from(SupabaseConfig.likesTable)
        .select()
        .eq('user_id', userId)
        .eq('content_id', contentId)
        .eq('content_type', contentType)
        .maybeSingle();

    return response != null;
  }

  // =============================================
  // NOTIFICATIONS OPERATIONS
  // =============================================

  /// Get user notifications
  static Future<List<Map<String, dynamic>>> getUserNotifications({
    required String userId,
    bool? isRead,
    String? notificationType,
    int? limit,
  }) async {
    var query = _client
        .from(SupabaseConfig.notificationsTable)
        .select()
        .eq('user_id', userId);

    if (isRead != null) {
      query = query.eq('is_read', isRead);
    }

    if (notificationType != null) {
      query = query.eq('notification_type', notificationType);
    }

    query = query.order('sent_at', ascending: false);

    if (limit != null) {
      query = query.limit(limit);
    }

    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }

  /// Mark notification as read
  static Future<void> markNotificationAsRead(String notificationId) async {
    await _client
        .from(SupabaseConfig.notificationsTable)
        .update({
          'is_read': true,
          'read_at': DateTime.now().toIso8601String(),
        })
        .eq('id', notificationId);
  }

  /// Create notification
  static Future<void> createNotification({
    required String titleHe,
    required String contentHe,
    required String userId,
    required String notificationType,
    String? actionUrl,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) async {
    final notificationData = {
      'title_he': titleHe,
      'content_he': contentHe,
      'user_id': userId,
      'notification_type': notificationType,
      'action_url': actionUrl,
      'image_url': imageUrl,
      'metadata': metadata,
    };

    await _client
        .from(SupabaseConfig.notificationsTable)
        .insert(notificationData);
  }

  // =============================================
  // USER PREFERENCES OPERATIONS
  // =============================================

  /// Get user preferences
  static Future<Map<String, dynamic>?> getUserPreferences(String userId) async {
    final response = await _client
        .from(SupabaseConfig.userPreferencesTable)
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    return response;
  }

  /// Update user preferences
  static Future<void> updateUserPreferences({
    required String userId,
    Map<String, dynamic>? preferences,
  }) async {
    if (preferences == null || preferences.isEmpty) return;

    final updateData = Map<String, dynamic>.from(preferences);
    updateData['user_id'] = userId;
    updateData['updated_at'] = DateTime.now().toIso8601String();

    await _client
        .from(SupabaseConfig.userPreferencesTable)
        .upsert(updateData, onConflict: 'user_id');
  }
}