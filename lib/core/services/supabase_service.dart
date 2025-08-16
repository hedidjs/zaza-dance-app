import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

import '../constants/app_constants.dart';
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
        print('SupabaseService initialized with device ID: $_deviceId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing SupabaseService: $e');
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
        print('Error getting device ID: $e');
      }
    }
  }

  // CATEGORIES
  /// Get all active categories
  Future<List<CategoryModel>> getCategories() async {
    try {
      if (kDebugMode) {
        print('SupabaseService: Fetching categories from Supabase...');
      }
      final response = await _client
          .from('categories')
          .select('*')
          .eq('is_active', true)
          .order('sort_order');
      
      if (kDebugMode) {
        print('SupabaseService: Retrieved ${(response as List).length} categories');
      }
      
      return (response as List)
          .map((data) => CategoryModel.fromJson(data))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching categories: $e');
      }
      return [];
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
          .select('*, categories(*)')
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
        print('Error fetching gallery items: $e');
      }
      return [];
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
          .select('*, categories(*)')
          .eq('is_active', true)
          .or('title_he.ilike.%$query%,description_he.ilike.%$query%')
          .order('created_at', ascending: false)
          .limit(20);

      return (response as List)
          .map((data) => GalleryModel.fromJson(data))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error searching gallery items: $e');
      }
      return [];
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
      var query = _client
          .from('tutorials')
          .select('*, categories(*)')
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

      return (response as List)
          .map((data) => TutorialModel.fromJson(data))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching tutorials: $e');
      }
      return [];
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
          .select('*, categories(*)')
          .eq('is_active', true)
          .or('title_he.ilike.%$query%,description_he.ilike.%$query%,instructor_name.ilike.%$query%')
          .order('created_at', ascending: false)
          .limit(20);

      return (response as List)
          .map((data) => TutorialModel.fromJson(data))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error searching tutorials: $e');
      }
      return [];
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
        print('Error fetching updates: $e');
      }
      return [];
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
        print('Error searching updates: $e');
      }
      return [];
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
        print('Tracked interaction: $interactionType for $contentType:$contentId');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error tracking interaction: $e');
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
        print('Removed interaction: $interactionType for $contentType:$contentId');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error removing interaction: $e');
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
        print('Error checking user interaction: $e');
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
        print('Error uploading file: $e');
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
}