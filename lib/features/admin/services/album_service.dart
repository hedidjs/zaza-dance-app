import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// מחלקת שירות מקצועית לניהול אלבומי גלריה בפאנל המנהל
/// Professional Album Management Service for Zaza Dance Admin Panel
class AlbumService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // שמות הטבלאות - Table names
  static const String albumsTable = 'gallery_albums';
  static const String galleryItemsTable = 'gallery_items';
  static const String galleryCategoriesTable = 'gallery_categories';

  // =============================================
  // פעולות CRUD בסיסיות - Basic CRUD Operations
  // =============================================

  /// קבלת כל האלבומים עם סינון וחיפוש
  /// Get all albums with filtering and search
  Future<List<Map<String, dynamic>>> getAllAlbums({
    String? categoryId,
    String? searchQuery,
    bool? isActive,
    bool? isFeatured,
    String sortBy = 'sort_order',
    bool ascending = true,
    int? limit,
    int? offset,
  }) async {
    try {
      debugPrint('📚 AlbumService: Getting albums - categoryId: $categoryId, search: $searchQuery');
      
      var query = _supabase
          .from(albumsTable)
          .select('''
            *,
            category:category_id(id, name_he, name_en, color)
          ''');

      // סינון פעיל/לא פעיל - Active/Inactive filter
      if (isActive != null) {
        query = query.eq('is_active', isActive);
      } else {
        query = query.eq('is_active', true); // ברירת מחדל - רק פעילים
      }

      // סינון לפי קטגוריה - Filter by category
      if (categoryId != null && categoryId != 'all') {
        query = query.eq('category_id', categoryId);
      }

      // סינון מוצג/לא מוצג - Featured filter
      if (isFeatured != null) {
        query = query.eq('is_featured', isFeatured);
      }

      // חיפוש טקסט - Text search
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        query = query.or(
          'name_he.ilike.%${searchQuery.trim()}%,'
          'name_en.ilike.%${searchQuery.trim()}%,'
          'description_he.ilike.%${searchQuery.trim()}%'
        );
      }

      // מיון - Sorting
      final orderedQuery = query.order(sortBy, ascending: ascending);

      // הגבלה וקפיצה - Limit and offset
      final finalQuery = limit != null 
          ? (offset != null 
              ? orderedQuery.range(offset, offset + limit - 1)
              : orderedQuery.limit(limit))
          : orderedQuery;

      final response = await finalQuery;
      final albums = List<Map<String, dynamic>>.from(response);

      debugPrint('✅ AlbumService: Found ${albums.length} albums');
      return albums;
    } catch (error) {
      debugPrint('❌ AlbumService: Error getting albums - $error');
      throw Exception('שגיאה בטעינת אלבומים: $error');
    }
  }

  /// יצירת אלבום חדש
  /// Create new album
  Future<Map<String, dynamic>> createAlbum({
    required String nameHe,
    String? nameEn,
    String? descriptionHe,
    String? descriptionEn,
    required String categoryId,
    String? coverImageUrl,
    int sortOrder = 0,
    bool isFeatured = false,
    bool isActive = true,
  }) async {
    try {
      debugPrint('➕ AlbumService: Creating album - $nameHe');
      
      // ולידציה של נתונים
      if (nameHe.trim().isEmpty) {
        throw Exception('שם האלבום בעברית חובה');
      }

      // בדיקה שהקטגוריה קיימת
      final categoryExists = await _checkCategoryExists(categoryId);
      if (!categoryExists) {
        throw Exception('קטגוריה לא נמצאה');
      }

      final albumData = {
        'name_he': nameHe.trim(),
        'name_en': nameEn?.trim(),
        'description_he': descriptionHe?.trim(),
        'description_en': descriptionEn?.trim(),
        'category_id': categoryId,
        'cover_image_url': coverImageUrl,
        'sort_order': sortOrder,
        'is_featured': isFeatured,
        'is_active': isActive,
        'created_by': _supabase.auth.currentUser?.id,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from(albumsTable)
          .insert(albumData)
          .select('''
            *,
            category:category_id(id, name_he, name_en, color)
          ''')
          .single();

      debugPrint('✅ AlbumService: Album created successfully - ${response['id']}');
      return response;
    } catch (error) {
      debugPrint('❌ AlbumService: Error creating album - $error');
      throw Exception('שגיאה ביצירת אלבום: $error');
    }
  }

  /// עדכון אלבום קיים
  /// Update existing album
  Future<Map<String, dynamic>> updateAlbum({
    required String albumId,
    String? nameHe,
    String? nameEn,
    String? descriptionHe,
    String? descriptionEn,
    String? categoryId,
    String? coverImageUrl,
    int? sortOrder,
    bool? isFeatured,
    bool? isActive,
  }) async {
    try {
      debugPrint('📝 AlbumService: Updating album - $albumId');
      
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (nameHe != null) updateData['name_he'] = nameHe.trim();
      if (nameEn != null) updateData['name_en'] = nameEn.trim();
      if (descriptionHe != null) updateData['description_he'] = descriptionHe.trim();
      if (descriptionEn != null) updateData['description_en'] = descriptionEn.trim();
      if (coverImageUrl != null) updateData['cover_image_url'] = coverImageUrl;
      if (sortOrder != null) updateData['sort_order'] = sortOrder;
      if (isFeatured != null) updateData['is_featured'] = isFeatured;
      if (isActive != null) updateData['is_active'] = isActive;

      // עדכון קטגוריה עם ולידציה
      if (categoryId != null) {
        final categoryExists = await _checkCategoryExists(categoryId);
        if (!categoryExists) {
          throw Exception('קטגוריה לא נמצאה');
        }
        updateData['category_id'] = categoryId;
      }

      final response = await _supabase
          .from(albumsTable)
          .update(updateData)
          .eq('id', albumId)
          .select('''
            *,
            category:category_id(id, name_he, name_en, color)
          ''')
          .single();

      debugPrint('✅ AlbumService: Album updated successfully - $albumId');
      return response;
    } catch (error) {
      debugPrint('❌ AlbumService: Error updating album - $error');
      throw Exception('שגיאה בעדכון אלבום: $error');
    }
  }

  /// מחיקת אלבום (מחיקה רכה)
  /// Delete album (soft delete)
  Future<void> deleteAlbum(String albumId) async {
    try {
      debugPrint('🗑️ AlbumService: Deleting album - $albumId');
      
      await _supabase
          .from(albumsTable)
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', albumId);

      debugPrint('✅ AlbumService: Album deleted successfully - $albumId');
    } catch (error) {
      debugPrint('❌ AlbumService: Error deleting album - $error');
      throw Exception('שגיאה במחיקת אלבום: $error');
    }
  }

  /// שחזור אלבום מחוק
  /// Restore deleted album
  Future<Map<String, dynamic>> restoreAlbum(String albumId) async {
    try {
      debugPrint('♻️ AlbumService: Restoring album - $albumId');
      
      final response = await _supabase
          .from(albumsTable)
          .update({
            'is_active': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', albumId)
          .select('''
            *,
            category:category_id(id, name_he, name_en, color)
          ''')
          .single();

      debugPrint('✅ AlbumService: Album restored successfully - $albumId');
      return response;
    } catch (error) {
      debugPrint('❌ AlbumService: Error restoring album - $error');
      throw Exception('שגיאה בשחזור אלבום: $error');
    }
  }

  // =============================================
  // ניהול תמונות ופריטי גלריה באלבום
  // Managing Images and Gallery Items in Album
  // =============================================

  /// קבלת כל הפריטים באלבום
  /// Get all items in album
  Future<List<Map<String, dynamic>>> getAlbumItems({
    required String albumId,
    String? mediaType,
    String sortBy = 'sort_order',
    bool ascending = true,
  }) async {
    try {
      debugPrint('🖼️ AlbumService: Getting items for album - $albumId');
      
      var query = _supabase
          .from(galleryItemsTable)
          .select('*')
          .eq('album_id', albumId)
          .eq('is_active', true);

      if (mediaType != null && mediaType != 'all') {
        query = query.eq('media_type', mediaType);
      }

      final response = await query.order(sortBy, ascending: ascending);
      
      debugPrint('✅ AlbumService: Found ${response.length} items in album');
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      debugPrint('❌ AlbumService: Error getting album items - $error');
      throw Exception('שגיאה בטעינת פריטי האלבום: $error');
    }
  }

  /// הוספת פריט לאלבום
  /// Add item to album
  Future<Map<String, dynamic>> addItemToAlbum({
    required String albumId,
    required String titleHe,
    String? titleEn,
    String? descriptionHe,
    String? descriptionEn,
    required String mediaUrl,
    required String mediaType,
    String? thumbnailUrl,
    String? altTextHe,
    String? altTextEn,
    int? fileSize,
    int? width,
    int? height,
    int? durationSeconds,
    int sortOrder = 0,
  }) async {
    try {
      debugPrint('➕ AlbumService: Adding item to album - $albumId');
      
      // ולידציה
      if (titleHe.trim().isEmpty) {
        throw Exception('כותרת הפריט בעברית חובה');
      }

      if (mediaUrl.trim().isEmpty) {
        throw Exception('קישור למדיה חובה');
      }

      final itemData = {
        'album_id': albumId,
        'title_he': titleHe.trim(),
        'title_en': titleEn?.trim(),
        'description_he': descriptionHe?.trim(),
        'description_en': descriptionEn?.trim(),
        'media_url': mediaUrl,
        'media_type': mediaType,
        'thumbnail_url': thumbnailUrl,
        'alt_text_he': altTextHe?.trim(),
        'alt_text_en': altTextEn?.trim(),
        'file_size': fileSize,
        'width': width,
        'height': height,
        'duration_seconds': durationSeconds,
        'sort_order': sortOrder,
        'created_by': _supabase.auth.currentUser?.id,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from(galleryItemsTable)
          .insert(itemData)
          .select()
          .single();

      debugPrint('✅ AlbumService: Item added to album successfully - ${response['id']}');
      return response;
    } catch (error) {
      debugPrint('❌ AlbumService: Error adding item to album - $error');
      throw Exception('שגיאה בהוספת פריט לאלבום: $error');
    }
  }

  /// הסרת פריט מאלבום
  /// Remove item from album
  Future<void> removeItemFromAlbum(String itemId) async {
    try {
      debugPrint('🗑️ AlbumService: Removing item from album - $itemId');
      
      await _supabase
          .from(galleryItemsTable)
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', itemId);

      debugPrint('✅ AlbumService: Item removed from album successfully');
    } catch (error) {
      debugPrint('❌ AlbumService: Error removing item from album - $error');
      throw Exception('שגיאה בהסרת פריט מהאלבום: $error');
    }
  }

  /// עדכון סדר הפריטים באלבום
  /// Update items order in album
  Future<void> reorderAlbumItems(List<Map<String, dynamic>> itemsWithNewOrder) async {
    try {
      debugPrint('🔄 AlbumService: Reordering album items');
      
      for (final item in itemsWithNewOrder) {
        await _supabase
            .from(galleryItemsTable)
            .update({
              'sort_order': item['sort_order'],
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', item['id']);
      }

      debugPrint('✅ AlbumService: Album items reordered successfully');
    } catch (error) {
      debugPrint('❌ AlbumService: Error reordering album items - $error');
      throw Exception('שגיאה בעדכון סדר הפריטים באלבום: $error');
    }
  }

  /// עדכון תמונת הכריכה של האלבום
  /// Update album cover image
  Future<Map<String, dynamic>> updateAlbumCover(String albumId, String coverImageUrl) async {
    try {
      debugPrint('🖼️ AlbumService: Updating album cover - $albumId');
      
      final response = await _supabase
          .from(albumsTable)
          .update({
            'cover_image_url': coverImageUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', albumId)
          .select('''
            *,
            category:category_id(id, name_he, name_en, color)
          ''')
          .single();

      debugPrint('✅ AlbumService: Album cover updated successfully');
      return response;
    } catch (error) {
      debugPrint('❌ AlbumService: Error updating album cover - $error');
      throw Exception('שגיאה בעדכון תמונת כריכת האלבום: $error');
    }
  }

  // =============================================
  // פעולות מתקדמות וסטטיסטיקות
  // Advanced Operations & Statistics
  // =============================================

  /// קבלת סטטיסטיקות אלבום
  /// Get album statistics
  Future<Map<String, dynamic>> getAlbumStatistics(String albumId) async {
    try {
      debugPrint('📊 AlbumService: Getting statistics for album - $albumId');
      
      // Get all items and calculate statistics
      final allItems = await _supabase.from(galleryItemsTable)
          .select('*')
          .eq('album_id', albumId)
          .eq('is_active', true);
      
      final totalItems = allItems.length;
      final images = allItems.where((item) => item['media_type'] == 'image').length;
      final videos = allItems.where((item) => item['media_type'] == 'video').length;
      
      // קבלת גודל קבצים
      final fileSizes = allItems as List;
      final totalSize = fileSizes.fold<int>(
        0, 
        (sum, item) => sum + (item['file_size'] as int? ?? 0)
      );

      final statistics = {
        'total_items': totalItems,
        'images_count': images,
        'videos_count': videos,
        'total_size_bytes': totalSize,
        'total_size_mb': (totalSize / 1048576).toStringAsFixed(2),
        'generated_at': DateTime.now().toIso8601String(),
      };

      debugPrint('✅ AlbumService: Statistics generated for album');
      return statistics;
    } catch (error) {
      debugPrint('❌ AlbumService: Error getting album statistics - $error');
      throw Exception('שגיאה בטעינת סטטיסטיקות האלבום: $error');
    }
  }

  /// חיפוש אלבומים
  /// Search albums
  Future<List<Map<String, dynamic>>> searchAlbums({
    required String searchQuery,
    String? categoryId,
    bool activeOnly = true,
  }) async {
    try {
      debugPrint('🔍 AlbumService: Searching albums - $searchQuery');
      
      return await getAllAlbums(
        categoryId: categoryId,
        searchQuery: searchQuery,
        isActive: activeOnly ? true : null,
        sortBy: 'name_he',
        ascending: true,
      );
    } catch (error) {
      debugPrint('❌ AlbumService: Error searching albums - $error');
      throw Exception('שגיאה בחיפוש אלבומים: $error');
    }
  }

  /// מחיקה קבוצתית של אלבומים
  /// Bulk delete albums
  Future<void> bulkDeleteAlbums(List<String> albumIds) async {
    try {
      debugPrint('🗑️ AlbumService: Bulk deleting ${albumIds.length} albums');
      
      await _supabase
          .from(albumsTable)
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .inFilter('id', albumIds);

      debugPrint('✅ AlbumService: Bulk delete completed - ${albumIds.length} albums');
    } catch (error) {
      debugPrint('❌ AlbumService: Error in bulk delete - $error');
      throw Exception('שגיאה במחיקה קבוצתית של אלבומים: $error');
    }
  }

  /// העתקת אלבום
  /// Duplicate album
  Future<Map<String, dynamic>> duplicateAlbum(String albumId, {bool includeItems = false}) async {
    try {
      debugPrint('📋 AlbumService: Duplicating album - $albumId');
      
      // קבלת האלבום המקורי
      final original = await _supabase
          .from(albumsTable)
          .select('*')
          .eq('id', albumId)
          .single();

      // יצירת העתק האלבום
      final duplicateData = Map<String, dynamic>.from(original);
      duplicateData.remove('id');
      duplicateData.remove('created_at');
      duplicateData.remove('updated_at');
      duplicateData['name_he'] = '${original['name_he']} (העתק)';
      if (original['name_en'] != null) {
        duplicateData['name_en'] = '${original['name_en']} (Copy)';
      }
      duplicateData['sort_order'] = (original['sort_order'] ?? 0) + 1;
      duplicateData['is_featured'] = false; // האלבום המועתק לא יהיה מוצג
      duplicateData['created_by'] = _supabase.auth.currentUser?.id;
      duplicateData['created_at'] = DateTime.now().toIso8601String();
      duplicateData['updated_at'] = DateTime.now().toIso8601String();

      final newAlbum = await _supabase
          .from(albumsTable)
          .insert(duplicateData)
          .select('''
            *,
            category:category_id(id, name_he, name_en, color)
          ''')
          .single();

      // העתקת הפריטים אם נדרש
      if (includeItems) {
        final originalItems = await getAlbumItems(albumId: albumId);
        
        for (final item in originalItems) {
          final itemData = Map<String, dynamic>.from(item);
          itemData.remove('id');
          itemData.remove('created_at');
          itemData.remove('updated_at');
          itemData['album_id'] = newAlbum['id'];
          itemData['created_by'] = _supabase.auth.currentUser?.id;
          itemData['created_at'] = DateTime.now().toIso8601String();
          itemData['updated_at'] = DateTime.now().toIso8601String();

          await _supabase.from(galleryItemsTable).insert(itemData);
        }
      }

      debugPrint('✅ AlbumService: Album duplicated successfully - ${newAlbum['id']}');
      return newAlbum;
    } catch (error) {
      debugPrint('❌ AlbumService: Error duplicating album - $error');
      throw Exception('שגיאה בהעתקת אלבום: $error');
    }
  }

  /// ייצוא אלבומים ל-CSV
  /// Export albums to CSV
  Future<String> exportAlbumsToCSV({String? categoryId}) async {
    try {
      debugPrint('📤 AlbumService: Exporting albums to CSV');
      
      final albums = await getAllAlbums(categoryId: categoryId, isActive: null);
      
      final csvLines = <String>[];
      
      // כותרות - Headers
      csvLines.add('ID,שם עברית,שם אנגלית,תיאור,קטגוריה,מספר פריטים,מוצג,פעיל,תאריך יצירה');
      
      // שורות נתונים - Data rows
      for (final album in albums) {
        final itemsCount = album['gallery_items_count'] ?? 0;
        final categoryName = album['category']?['name_he'] ?? '';
        
        csvLines.add([
          album['id'],
          album['name_he']?.replaceAll(',', '') ?? '',
          album['name_en']?.replaceAll(',', '') ?? '',
          album['description_he']?.replaceAll(',', '') ?? '',
          categoryName.replaceAll(',', ''),
          itemsCount.toString(),
          (album['is_featured'] ?? false) ? 'כן' : 'לא',
          (album['is_active'] ?? false) ? 'כן' : 'לא',
          album['created_at'] ?? '',
        ].join(','));
      }

      debugPrint('✅ AlbumService: CSV export completed - ${albums.length} albums');
      return csvLines.join('\n');
    } catch (error) {
      debugPrint('❌ AlbumService: Error exporting to CSV - $error');
      throw Exception('שגיאה בייצוא לקובץ CSV: $error');
    }
  }

  // =============================================
  // פונקציות עזר פרטיות - Private Helper Functions
  // =============================================

  /// בדיקה שקטגוריה קיימת
  /// Check if category exists
  Future<bool> _checkCategoryExists(String categoryId) async {
    try {
      final response = await _supabase
          .from(galleryCategoriesTable)
          .select('id')
          .eq('id', categoryId)
          .eq('is_active', true)
          .maybeSingle();
      
      return response != null;
    } catch (error) {
      debugPrint('❌ AlbumService: Error checking category - $error');
      return false;
    }
  }

  /// קבלת אלבום לפי ID
  /// Get album by ID
  Future<Map<String, dynamic>?> getAlbumById(String albumId) async {
    try {
      final response = await _supabase
          .from(albumsTable)
          .select('''
            *,
            category:category_id(id, name_he, name_en, color),
            gallery_items_count:gallery_items(count)
          ''')
          .eq('id', albumId)
          .maybeSingle();

      return response;
    } catch (error) {
      debugPrint('❌ AlbumService: Error getting album by ID - $error');
      return null;
    }
  }

  /// עדכון סדר המיון של אלבומים
  /// Update albums sort order
  Future<void> reorderAlbums(List<Map<String, dynamic>> albumsWithNewOrder) async {
    try {
      debugPrint('🔄 AlbumService: Reordering albums');
      
      for (final album in albumsWithNewOrder) {
        await _supabase
            .from(albumsTable)
            .update({
              'sort_order': album['sort_order'],
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', album['id']);
      }

      debugPrint('✅ AlbumService: Albums reordered successfully');
    } catch (error) {
      debugPrint('❌ AlbumService: Error reordering albums - $error');
      throw Exception('שגיאה בעדכון סדר האלבומים: $error');
    }
  }
}