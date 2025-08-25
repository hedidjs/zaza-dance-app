import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import '../../shared/models/gallery_model.dart';
import '../../shared/models/tutorial_model.dart';
import '../../shared/models/update_model.dart';
import '../../shared/models/category_model.dart';

/// Service for handling all Supabase operations
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get _client => Supabase.instance.client;
  String? _deviceId;

  /// Initialize the service and get device ID for interaction tracking
  Future<void> initialize() async {
    try {
      await _getDeviceId();
      if (kDebugMode) {
        debugPrint('SupabaseService initialized with device ID: $_deviceId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error initializing SupabaseService: $e');
      }
    }
  }

  /// Get unique device ID for tracking user interactions
  Future<void> _getDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _deviceId = iosInfo.identifierForVendor;
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _deviceId = androidInfo.id;
      }
      _deviceId ??= 'unknown_device';
    } catch (e) {
      _deviceId = 'unknown_device';
      if (kDebugMode) {
        debugPrint('Error getting device ID: $e');
      }
    }
  }

  // CATEGORIES
  /// Get all active categories
  Future<List<CategoryModel>> getCategories() async {
    try {
      if (kDebugMode) {
        debugPrint('SupabaseService: Fetching categories from Supabase...');
      }
      final response = await _client
          .from('gallery_categories')
          .select('*')
          .eq('is_active', true)
          .order('sort_order');
      
      if (kDebugMode) {
        debugPrint('SupabaseService: Retrieved ${(response as List).length} categories');
      }
      
      return (response as List)
          .map((data) => CategoryModel.fromJson(data))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching categories: $e');
      }
      throw Exception('Failed to load categories from database');
    }
  }

  // GALLERY
  /// Get gallery items with optional filtering
  Future<List<GalleryModel>> getGalleryItems({
    String? categoryId,
    bool? featuredOnly,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = _client
          .from('gallery_items')
          .select('*, gallery_categories(*)')
          .eq('is_active', true);

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      if (featuredOnly == true) {
        query = query.eq('is_featured', true);
      }

      final response = await query
          .order('sort_order')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((data) => GalleryModel.fromJson(data))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching gallery items: $e');
      }
      throw Exception('Failed to load gallery items from database');
    }
  }

  /// Get featured gallery items
  Future<List<GalleryModel>> getFeaturedGalleryItems() async {
    return await getGalleryItems(featuredOnly: true, limit: 10);
  }

  /// Search gallery items
  Future<List<GalleryModel>> searchGalleryItems(String query) async {
    try {
      final response = await _client
          .from('gallery_items')
          .select('*, gallery_categories(*)')
          .eq('is_active', true)
          .or('title_he.ilike.%$query%,description_he.ilike.%$query%')
          .order('created_at', ascending: false)
          .limit(20);

      return (response as List)
          .map((data) => GalleryModel.fromJson(data))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error searching gallery items: $e');
      }
      throw Exception('Failed to search gallery items in database');
    }
  }

  // TUTORIALS
  /// Get tutorials with optional filtering
  Future<List<TutorialModel>> getTutorials({
    String? categoryId,
    String? difficultyLevel,
    bool? featuredOnly,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('SupabaseService: Fetching tutorials from Supabase...');
      }
      var query = _client
          .from('tutorials')
          .select('*, tutorial_categories(*)')
          .eq('is_active', true);

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      if (difficultyLevel != null) {
        query = query.eq('difficulty_level', difficultyLevel);
      }

      if (featuredOnly == true) {
        query = query.eq('is_featured', true);
      }

      final response = await query
          .order('sort_order')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      if (kDebugMode) {
        debugPrint('SupabaseService: Retrieved ${(response as List).length} tutorials');
      }

      return (response as List)
          .map((data) => TutorialModel.fromJson(data))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching tutorials: $e');
      }
      throw Exception('Failed to load tutorials from database');
    }
  }

  /// Get featured tutorials
  Future<List<TutorialModel>> getFeaturedTutorials() async {
    return await getTutorials(featuredOnly: true, limit: 10);
  }

  /// Search tutorials
  Future<List<TutorialModel>> searchTutorials(String query) async {
    try {
      final response = await _client
          .from('tutorials')
          .select('*, tutorial_categories(*)')
          .eq('is_active', true)
          .or('title_he.ilike.%$query%,description_he.ilike.%$query%,instructor_name.ilike.%$query%')
          .order('created_at', ascending: false)
          .limit(20);

      return (response as List)
          .map((data) => TutorialModel.fromJson(data))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error searching tutorials: $e');
      }
      throw Exception('Failed to search tutorials in database');
    }
  }

  // UPDATES/NEWS
  /// Get updates with optional filtering
  Future<List<UpdateModel>> getUpdates({
    String? updateType,
    bool? pinnedOnly,
    bool? featuredOnly,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = _client
          .from('updates')
          .select('*')
          .eq('is_active', true);

      if (updateType != null) {
        query = query.eq('update_type', updateType);
      }

      if (pinnedOnly == true) {
        query = query.eq('is_pinned', true);
      }

      if (featuredOnly == true) {
        query = query.eq('is_featured', true);
      }

      final response = await query
          .order('is_pinned', ascending: false)
          .order('publish_date', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((data) => UpdateModel.fromJson(data))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching updates: $e');
      }
      throw Exception('Failed to load updates from database');
    }
  }

  /// Get pinned updates
  Future<List<UpdateModel>> getPinnedUpdates() async {
    return await getUpdates(pinnedOnly: true, limit: 5);
  }

  /// Search updates
  Future<List<UpdateModel>> searchUpdates(String query) async {
    try {
      final response = await _client
          .from('updates')
          .select('*')
          .eq('is_active', true)
          .or('title_he.ilike.%$query%,content_he.ilike.%$query%,excerpt_he.ilike.%$query%')
          .order('publish_date', ascending: false)
          .limit(20);

      return (response as List)
          .map((data) => UpdateModel.fromJson(data))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error searching updates: $e');
      }
      throw Exception('Failed to search updates in database');
    }
  }

  // USER INTERACTIONS
  /// Track user interaction (like, view, share, download)
  Future<bool> trackInteraction({
    required String contentType,
    required String contentId,
    required String interactionType,
  }) async {
    try {
      if (_deviceId == null) {
        await _getDeviceId();
      }

      await _client.from('user_interactions').upsert({
        'user_device_id': _deviceId,
        'content_type': contentType,
        'content_id': contentId,
        'interaction_type': interactionType,
      });

      if (kDebugMode) {
        debugPrint('Tracked interaction: $interactionType for $contentType:$contentId');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error tracking interaction: $e');
      }
      return false;
    }
  }

  /// Remove user interaction (unlike)
  Future<bool> removeInteraction({
    required String contentType,
    required String contentId,
    required String interactionType,
  }) async {
    try {
      if (_deviceId == null) {
        await _getDeviceId();
      }

      await _client
          .from('user_interactions')
          .delete()
          .eq('user_device_id', _deviceId!)
          .eq('content_type', contentType)
          .eq('content_id', contentId)
          .eq('interaction_type', interactionType);

      if (kDebugMode) {
        debugPrint('Removed interaction: $interactionType for $contentType:$contentId');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error removing interaction: $e');
      }
      return false;
    }
  }

  /// Check if user has interacted with content
  Future<bool> hasUserInteracted({
    required String contentType,
    required String contentId,
    required String interactionType,
  }) async {
    try {
      if (_deviceId == null) {
        await _getDeviceId();
      }

      final response = await _client
          .from('user_interactions')
          .select('id')
          .eq('user_device_id', _deviceId!)
          .eq('content_type', contentType)
          .eq('content_id', contentId)
          .eq('interaction_type', interactionType)
          .maybeSingle();

      return response != null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking user interaction: $e');
      }
      return false;
    }
  }

  // STORAGE OPERATIONS
  /// Get public URL for storage file
  String getStorageUrl(String bucket, String path) {
    return _client.storage.from(bucket).getPublicUrl(path);
  }

  /// Upload file to storage
  Future<String?> uploadFile({
    required String bucket,
    required String path,
    required String filePath,
  }) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      
      await _client.storage.from(bucket).uploadBinary(path, bytes);
      
      return getStorageUrl(bucket, path);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error uploading file: $e');
      }
      return null;
    }
  }

  // CONVENIENCE METHODS
  /// Like gallery item
  Future<bool> likeGalleryItem(String itemId) async {
    return await trackInteraction(
      contentType: 'gallery_item',
      contentId: itemId,
      interactionType: 'like',
    );
  }

  /// Unlike gallery item
  Future<bool> unlikeGalleryItem(String itemId) async {
    return await removeInteraction(
      contentType: 'gallery_item',
      contentId: itemId,
      interactionType: 'like',
    );
  }

  /// Like tutorial
  Future<bool> likeTutorial(String tutorialId) async {
    return await trackInteraction(
      contentType: 'tutorial',
      contentId: tutorialId,
      interactionType: 'like',
    );
  }

  /// Unlike tutorial
  Future<bool> unlikeTutorial(String tutorialId) async {
    return await removeInteraction(
      contentType: 'tutorial',
      contentId: tutorialId,
      interactionType: 'like',
    );
  }

  /// Track tutorial view
  Future<bool> viewTutorial(String tutorialId) async {
    return await trackInteraction(
      contentType: 'tutorial',
      contentId: tutorialId,
      interactionType: 'view',
    );
  }

  /// Track tutorial download
  Future<bool> downloadTutorial(String tutorialId) async {
    return await trackInteraction(
      contentType: 'tutorial',
      contentId: tutorialId,
      interactionType: 'download',
    );
  }

  /// Like update
  Future<bool> likeUpdate(String updateId) async {
    return await trackInteraction(
      contentType: 'update',
      contentId: updateId,
      interactionType: 'like',
    );
  }

  /// Unlike update
  Future<bool> unlikeUpdate(String updateId) async {
    return await removeInteraction(
      contentType: 'update',
      contentId: updateId,
      interactionType: 'like',
    );
  }

  /// Check if gallery item is liked
  Future<bool> isGalleryItemLiked(String itemId) async {
    return await hasUserInteracted(
      contentType: 'gallery_item',
      contentId: itemId,
      interactionType: 'like',
    );
  }

  /// Check if tutorial is liked
  Future<bool> isTutorialLiked(String tutorialId) async {
    return await hasUserInteracted(
      contentType: 'tutorial',
      contentId: tutorialId,
      interactionType: 'like',
    );
  }

  /// Check if update is liked
  Future<bool> isUpdateLiked(String updateId) async {
    return await hasUserInteracted(
      contentType: 'update',
      contentId: updateId,
      interactionType: 'like',
    );
  }

  // MARK: - CRUD OPERATIONS FOR ADMIN

  // CATEGORIES CRUD
  /// Create a new category
  Future<CategoryModel?> createCategory({
    required String nameHe,
    String? descriptionHe,
    String color = '#FF00FF',
    int sortOrder = 0,
  }) async {
    try {
      final response = await _client.from('gallery_categories').insert({
        'name_he': nameHe,
        'description_he': descriptionHe,
        'color': color,
        'sort_order': sortOrder,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).select().single();

      return CategoryModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error creating category: $e');
      }
      return null;
    }
  }

  /// Update an existing category
  Future<CategoryModel?> updateCategory({
    required String categoryId,
    String? nameHe,
    String? descriptionHe,
    String? color,
    int? sortOrder,
    bool? isActive,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (nameHe != null) updates['name_he'] = nameHe;
      if (descriptionHe != null) updates['description_he'] = descriptionHe;
      if (color != null) updates['color'] = color;
      if (sortOrder != null) updates['sort_order'] = sortOrder;
      if (isActive != null) updates['is_active'] = isActive;

      final response = await _client
          .from('gallery_categories')
          .update(updates)
          .eq('id', categoryId)
          .select()
          .single();

      return CategoryModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating category: $e');
      }
      return null;
    }
  }

  /// Delete a category
  Future<bool> deleteCategory(String categoryId) async {
    try {
      await _client.from('gallery_categories').delete().eq('id', categoryId);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting category: $e');
      }
      return false;
    }
  }

  // GALLERY CRUD
  /// Create a new gallery item
  Future<GalleryModel?> createGalleryItem({
    required String titleHe,
    String? descriptionHe,
    required String mediaUrl,
    String? thumbnailUrl,
    required String mediaType,
    String? categoryId,
    List<String> tags = const [],
    bool isFeatured = false,
    int sortOrder = 0,
  }) async {
    try {
      final response = await _client.from('gallery_items').insert({
        'title_he': titleHe,
        'description_he': descriptionHe,
        'media_url': mediaUrl,
        'thumbnail_url': thumbnailUrl,
        'media_type': mediaType,
        'category_id': categoryId,
        'tags': tags,
        'is_featured': isFeatured,
        'sort_order': sortOrder,
        'likes_count': 0,
        'views_count': 0,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).select('*, gallery_categories(*)').single();

      return GalleryModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error creating gallery item: $e');
      }
      return null;
    }
  }

  /// Update an existing gallery item
  Future<GalleryModel?> updateGalleryItem({
    required String itemId,
    String? titleHe,
    String? descriptionHe,
    String? mediaUrl,
    String? thumbnailUrl,
    String? categoryId,
    List<String>? tags,
    bool? isFeatured,
    int? sortOrder,
    bool? isActive,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (titleHe != null) updates['title_he'] = titleHe;
      if (descriptionHe != null) updates['description_he'] = descriptionHe;
      if (mediaUrl != null) updates['media_url'] = mediaUrl;
      if (thumbnailUrl != null) updates['thumbnail_url'] = thumbnailUrl;
      if (categoryId != null) updates['category_id'] = categoryId;
      if (tags != null) updates['tags'] = tags;
      if (isFeatured != null) updates['is_featured'] = isFeatured;
      if (sortOrder != null) updates['sort_order'] = sortOrder;
      if (isActive != null) updates['is_active'] = isActive;

      final response = await _client
          .from('gallery_items')
          .update(updates)
          .eq('id', itemId)
          .select('*, gallery_categories(*)')
          .single();

      return GalleryModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating gallery item: $e');
      }
      return null;
    }
  }

  /// Delete a gallery item
  Future<bool> deleteGalleryItem(String itemId) async {
    try {
      await _client.from('gallery_items').delete().eq('id', itemId);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting gallery item: $e');
      }
      return false;
    }
  }

  // TUTORIALS CRUD
  /// Create a new tutorial
  Future<TutorialModel?> createTutorial({
    required String titleHe,
    String? descriptionHe,
    required String videoUrl,
    String? thumbnailUrl,
    int durationSeconds = 0,
    String? difficultyLevel,
    String? instructorName,
    String? categoryId,
    List<String> tags = const [],
    bool isFeatured = false,
    int sortOrder = 0,
  }) async {
    try {
      final response = await _client.from('tutorials').insert({
        'title_he': titleHe,
        'description_he': descriptionHe,
        'video_url': videoUrl,
        'thumbnail_url': thumbnailUrl,
        'duration_seconds': durationSeconds,
        'difficulty_level': difficultyLevel,
        'instructor_name': instructorName,
        'category_id': categoryId,
        'tags': tags,
        'is_featured': isFeatured,
        'sort_order': sortOrder,
        'likes_count': 0,
        'views_count': 0,
        'downloads_count': 0,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).select('*, tutorial_categories(*)').single();

      return TutorialModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error creating tutorial: $e');
      }
      return null;
    }
  }

  /// Update an existing tutorial
  Future<TutorialModel?> updateTutorial({
    required String tutorialId,
    String? titleHe,
    String? descriptionHe,
    String? videoUrl,
    String? thumbnailUrl,
    int? durationSeconds,
    String? difficultyLevel,
    String? instructorName,
    String? categoryId,
    List<String>? tags,
    bool? isFeatured,
    int? sortOrder,
    bool? isActive,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (titleHe != null) updates['title_he'] = titleHe;
      if (descriptionHe != null) updates['description_he'] = descriptionHe;
      if (videoUrl != null) updates['video_url'] = videoUrl;
      if (thumbnailUrl != null) updates['thumbnail_url'] = thumbnailUrl;
      if (durationSeconds != null) updates['duration_seconds'] = durationSeconds;
      if (difficultyLevel != null) updates['difficulty_level'] = difficultyLevel;
      if (instructorName != null) updates['instructor_name'] = instructorName;
      if (categoryId != null) updates['category_id'] = categoryId;
      if (tags != null) updates['tags'] = tags;
      if (isFeatured != null) updates['is_featured'] = isFeatured;
      if (sortOrder != null) updates['sort_order'] = sortOrder;
      if (isActive != null) updates['is_active'] = isActive;

      final response = await _client
          .from('tutorials')
          .update(updates)
          .eq('id', tutorialId)
          .select('*, tutorial_categories(*)')
          .single();

      return TutorialModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating tutorial: $e');
      }
      return null;
    }
  }

  /// Delete a tutorial
  Future<bool> deleteTutorial(String tutorialId) async {
    try {
      await _client.from('tutorials').delete().eq('id', tutorialId);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting tutorial: $e');
      }
      return false;
    }
  }

  // UPDATES CRUD
  /// Create a new update/news item
  Future<UpdateModel?> createUpdate({
    required String titleHe,
    required String contentHe,
    String? excerptHe,
    String? imageUrl,
    required String updateType,
    String? authorName,
    bool isPinned = false,
    bool isFeatured = false,
    DateTime? publishDate,
    List<String> tags = const [],
  }) async {
    try {
      final response = await _client.from('updates').insert({
        'title_he': titleHe,
        'content_he': contentHe,
        'excerpt_he': excerptHe,
        'image_url': imageUrl,
        'update_type': updateType,
        'author_name': authorName,
        'is_pinned': isPinned,
        'is_featured': isFeatured,
        'publish_date': (publishDate ?? DateTime.now()).toIso8601String(),
        'tags': tags,
        'likes_count': 0,
        'comments_count': 0,
        'shares_count': 0,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).select().single();

      return UpdateModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error creating update: $e');
      }
      return null;
    }
  }

  /// Update an existing update/news item
  Future<UpdateModel?> updateUpdate({
    required String updateId,
    String? titleHe,
    String? contentHe,
    String? excerptHe,
    String? imageUrl,
    String? updateType,
    String? authorName,
    bool? isPinned,
    bool? isFeatured,
    DateTime? publishDate,
    List<String>? tags,
    bool? isActive,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (titleHe != null) updates['title_he'] = titleHe;
      if (contentHe != null) updates['content_he'] = contentHe;
      if (excerptHe != null) updates['excerpt_he'] = excerptHe;
      if (imageUrl != null) updates['image_url'] = imageUrl;
      if (updateType != null) updates['update_type'] = updateType;
      if (authorName != null) updates['author_name'] = authorName;
      if (isPinned != null) updates['is_pinned'] = isPinned;
      if (isFeatured != null) updates['is_featured'] = isFeatured;
      if (publishDate != null) updates['publish_date'] = publishDate.toIso8601String();
      if (tags != null) updates['tags'] = tags;
      if (isActive != null) updates['is_active'] = isActive;

      final response = await _client
          .from('updates')
          .update(updates)
          .eq('id', updateId)
          .select()
          .single();

      return UpdateModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating update: $e');
      }
      return null;
    }
  }

  /// Delete an update/news item
  Future<bool> deleteUpdate(String updateId) async {
    try {
      await _client.from('updates').delete().eq('id', updateId);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting update: $e');
      }
      return false;
    }
  }

  // BULK OPERATIONS
  /// Get content statistics
  Future<Map<String, int>> getContentStats() async {
    try {
      final futures = await Future.wait([
        _client.from('gallery_items').select('id').eq('is_active', true),
        _client.from('tutorials').select('id').eq('is_active', true),
        _client.from('updates').select('id').eq('is_active', true),
        _client.from('gallery_categories').select('id').eq('is_active', true),
      ]);

      return {
        'gallery_items': (futures[0] as List).length,
        'tutorials': (futures[1] as List).length,
        'updates': (futures[2] as List).length,
        'categories': (futures[3] as List).length,
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting content stats: $e');
      }
      return {
        'gallery_items': 0,
        'tutorials': 0,
        'updates': 0,
        'categories': 0,
      };
    }
  }
}