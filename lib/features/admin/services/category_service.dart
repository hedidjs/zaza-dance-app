import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// מחלקת שירות מקצועית לניהול קטגוריות בפאנל המנהל
/// Professional Category Management Service for Zaza Dance Admin Panel
class CategoryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // שמות טבלאות הקטגוריות - Category table names (using existing categories table)
  static const String tutorialCategoriesTable = 'categories';
  static const String galleryCategoriesTable = 'categories';
  static const String updateCategoriesTable = 'categories';

  // =============================================
  // פעולות CRUD כלליות - Generic CRUD Operations
  // =============================================

  /// קבלת כל הקטגוריות מטבלה מסוימת
  /// Get all categories from a specific table
  Future<List<Map<String, dynamic>>> getCategoriesByType(String categoryType, {
    bool activeOnly = true,
    String sortBy = 'sort_order',
    bool ascending = true,
  }) async {
    try {
      debugPrint('📋 CategoryService: Getting $categoryType categories');
      
      final tableName = _getTableName(categoryType);
      if (tableName == null) {
        throw Exception('סוג קטגוריה לא תקין: $categoryType');
      }

      var query = _supabase.from(tableName).select('*');
      
      if (activeOnly) {
        query = query.eq('is_active', true);
      }

      final response = await query.order(sortBy, ascending: ascending);
      
      debugPrint('✅ CategoryService: Found ${response.length} $categoryType categories');
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      debugPrint('❌ CategoryService: Error getting $categoryType categories - $error');
      throw Exception('שגיאה בטעינת קטגוריות $categoryType: $error');
    }
  }

  /// יצירת קטגוריה חדשה
  /// Create new category
  Future<Map<String, dynamic>> createCategory(
    String categoryType, {
    required String nameHe,
    String? nameEn,
    String? descriptionHe,
    String? descriptionEn,
    String? colorCode,
    String? iconName,
    int sortOrder = 0,
    bool isActive = true,
    Map<String, dynamic>? additionalFields,
  }) async {
    try {
      debugPrint('➕ CategoryService: Creating $categoryType category - $nameHe');
      
      final tableName = _getTableName(categoryType);
      if (tableName == null) {
        throw Exception('סוג קטגוריה לא תקין: $categoryType');
      }

      final categoryData = {
        'name_he': nameHe,
        'name_en': nameEn,
        'description_he': descriptionHe,
        'description_en': descriptionEn,
        'color': colorCode ?? _getDefaultColorCode(categoryType),
        'icon': iconName,
        'sort_order': sortOrder,
        'is_active': isActive,
        'created_by': _supabase.auth.currentUser?.id,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // הוספת שדות נוספים ספציפיים לטבלה
      if (additionalFields != null) {
        categoryData.addAll(additionalFields);
      }

      final response = await _supabase
          .from(tableName)
          .insert(categoryData)
          .select()
          .single();

      debugPrint('✅ CategoryService: Category created successfully - ${response['id']}');
      return response;
    } catch (error) {
      debugPrint('❌ CategoryService: Error creating $categoryType category - $error');
      throw Exception('שגיאה ביצירת קטגוריה: $error');
    }
  }

  /// עדכון קטגוריה קיימת
  /// Update existing category
  Future<Map<String, dynamic>> updateCategory(
    String categoryType,
    String categoryId, {
    String? nameHe,
    String? nameEn,
    String? descriptionHe,
    String? descriptionEn,
    String? colorCode,
    String? iconName,
    int? sortOrder,
    bool? isActive,
    Map<String, dynamic>? additionalFields,
  }) async {
    try {
      debugPrint('📝 CategoryService: Updating $categoryType category - $categoryId');
      
      final tableName = _getTableName(categoryType);
      if (tableName == null) {
        throw Exception('סוג קטגוריה לא תקין: $categoryType');
      }

      // First check if the category exists
      final existingCategory = await _supabase
          .from(tableName)
          .select('id')
          .eq('id', categoryId)
          .maybeSingle();

      if (existingCategory == null) {
        debugPrint('⚠️ CategoryService: Category not found - $categoryId');
        throw Exception('קטגוריה לא נמצאה: $categoryId');
      }

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (nameHe != null) updateData['name_he'] = nameHe;
      if (nameEn != null) updateData['name_en'] = nameEn;
      if (descriptionHe != null) updateData['description_he'] = descriptionHe;
      if (descriptionEn != null) updateData['description_en'] = descriptionEn;
      if (colorCode != null) updateData['color'] = colorCode;
      if (iconName != null) updateData['icon'] = iconName;
      if (sortOrder != null) updateData['sort_order'] = sortOrder;
      if (isActive != null) updateData['is_active'] = isActive;

      // הוספת שדות נוספים ספציפיים לטבלה
      if (additionalFields != null) {
        updateData.addAll(additionalFields);
      }

      final response = await _supabase
          .from(tableName)
          .update(updateData)
          .eq('id', categoryId)
          .select()
          .maybeSingle();

      if (response == null) {
        throw Exception('לא ניתן היה לעדכן את הקטגוריה');
      }

      debugPrint('✅ CategoryService: Category updated successfully - $categoryId');
      return response;
    } catch (error) {
      debugPrint('❌ CategoryService: Error updating $categoryType category - $error');
      
      // Return a safe error response instead of throwing
      return {
        'error': true,
        'message': 'שגיאה בעדכון קטגוריה: $error',
        'id': categoryId,
        'category_type': categoryType,
      };
    }
  }

  /// מחיקת קטגוריה (מחיקה רכה)
  /// Delete category (soft delete)
  Future<void> deleteCategory(String categoryType, String categoryId) async {
    try {
      debugPrint('🗑️ CategoryService: Deleting $categoryType category - $categoryId');
      
      final tableName = _getTableName(categoryType);
      if (tableName == null) {
        throw Exception('סוג קטגוריה לא תקין: $categoryType');
      }

      await _supabase
          .from(tableName)
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', categoryId);

      debugPrint('✅ CategoryService: Category deleted successfully - $categoryId');
    } catch (error) {
      debugPrint('❌ CategoryService: Error deleting $categoryType category - $error');
      throw Exception('שגיאה במחיקת קטגוריה: $error');
    }
  }

  /// שחזור קטגוריה מחוקה
  /// Restore deleted category
  Future<Map<String, dynamic>> restoreCategory(String categoryType, String categoryId) async {
    try {
      debugPrint('♻️ CategoryService: Restoring $categoryType category - $categoryId');
      
      final tableName = _getTableName(categoryType);
      if (tableName == null) {
        throw Exception('סוג קטגוריה לא תקין: $categoryType');
      }

      // First check if the category exists
      final existingCategory = await _supabase
          .from(tableName)
          .select('id')
          .eq('id', categoryId)
          .maybeSingle();

      if (existingCategory == null) {
        debugPrint('⚠️ CategoryService: Category not found for restore - $categoryId');
        throw Exception('קטגוריה לא נמצאה: $categoryId');
      }

      final response = await _supabase
          .from(tableName)
          .update({
            'is_active': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', categoryId)
          .select()
          .maybeSingle();

      if (response == null) {
        throw Exception('לא ניתן היה לשחזר את הקטגוריה');
      }

      debugPrint('✅ CategoryService: Category restored successfully - $categoryId');
      return response;
    } catch (error) {
      debugPrint('❌ CategoryService: Error restoring $categoryType category - $error');
      
      // Return a safe error response instead of throwing
      return {
        'error': true,
        'message': 'שגיאה בשחזור קטגוריה: $error',
        'id': categoryId,
        'category_type': categoryType,
      };
    }
  }

  // =============================================
  // פעולות ספציפיות לקטגוריות מדריכים
  // Tutorial Categories Specific Operations
  // =============================================

  /// קבלת כל קטגוריות המדריכים
  /// Get all tutorial categories
  Future<List<Map<String, dynamic>>> getTutorialCategories({bool activeOnly = true}) async {
    return await getCategoriesByType('tutorial', activeOnly: activeOnly);
  }

  /// יצירת קטגוריית מדריכים
  /// Create tutorial category
  Future<Map<String, dynamic>> createTutorialCategory({
    required String nameHe,
    String? nameEn,
    String? descriptionHe,
    String? descriptionEn,
    String? colorCode,
    String? iconName,
    int sortOrder = 0,
  }) async {
    return await createCategory(
      'tutorial',
      nameHe: nameHe,
      nameEn: nameEn,
      descriptionHe: descriptionHe,
      descriptionEn: descriptionEn,
      colorCode: colorCode,
      iconName: iconName,
      sortOrder: sortOrder,
    );
  }

  // =============================================
  // פעולות ספציפיות לקטגוריות גלריה
  // Gallery Categories Specific Operations
  // =============================================

  /// קבלת כל קטגוריות הגלריה
  /// Get all gallery categories
  Future<List<Map<String, dynamic>>> getGalleryCategories({bool activeOnly = true}) async {
    return await getCategoriesByType('gallery', activeOnly: activeOnly);
  }

  /// יצירת קטגוריית גלריה
  /// Create gallery category
  Future<Map<String, dynamic>> createGalleryCategory({
    required String nameHe,
    String? nameEn,
    String? descriptionHe,
    String? descriptionEn,
    String? colorCode,
    String? iconName,
    int sortOrder = 0,
  }) async {
    return await createCategory(
      'gallery',
      nameHe: nameHe,
      nameEn: nameEn,
      descriptionHe: descriptionHe,
      descriptionEn: descriptionEn,
      colorCode: colorCode,
      iconName: iconName,
      sortOrder: sortOrder,
    );
  }

  // =============================================
  // פעולות ספציפיות לקטגוריות עדכונים
  // Update Categories Specific Operations
  // =============================================

  /// קבלת כל קטגוריות העדכונים
  /// Get all update categories
  Future<List<Map<String, dynamic>>> getUpdateCategories({bool activeOnly = true}) async {
    return await getCategoriesByType('update', activeOnly: activeOnly);
  }

  /// יצירת קטגוריית עדכונים
  /// Create update category
  Future<Map<String, dynamic>> createUpdateCategory({
    required String nameHe,
    String? nameEn,
    String? descriptionHe,
    String? descriptionEn,
    String? colorCode,
    String? iconName,
    bool autoPublish = false,
    bool notificationEnabled = true,
    int sortOrder = 0,
  }) async {
    return await createCategory(
      'update',
      nameHe: nameHe,
      nameEn: nameEn,
      descriptionHe: descriptionHe,
      descriptionEn: descriptionEn,
      colorCode: colorCode,
      iconName: iconName,
      sortOrder: sortOrder,
      additionalFields: {
        'auto_publish': autoPublish,
        'notification_enabled': notificationEnabled,
      },
    );
  }

  // =============================================
  // פעולות מתקדמות וסטטיסטיקות
  // Advanced Operations & Statistics
  // =============================================

  /// קבלת סטטיסטיקות קטגוריה
  /// Get category statistics
  Future<Map<String, dynamic>> getCategoryStats(String categoryType, String categoryId) async {
    try {
      debugPrint('📊 CategoryService: Getting stats for $categoryType category - $categoryId');
      
      // שימוש בפונקציה שנוצרה בבסיס הנתונים
      final response = await _supabase.rpc('get_category_stats', params: {
        'category_table': _getTableName(categoryType),
        'category_id_param': categoryId,
      });

      debugPrint('✅ CategoryService: Stats retrieved for category $categoryId');
      return Map<String, dynamic>.from(response ?? {});
    } catch (error) {
      debugPrint('❌ CategoryService: Error getting category stats - $error');
      return {};
    }
  }

  /// עדכון סדר המיון של קטגוריות
  /// Update categories sort order
  Future<void> reorderCategories(
    String categoryType,
    List<Map<String, dynamic>> categoriesWithNewOrder,
  ) async {
    try {
      debugPrint('🔄 CategoryService: Reordering $categoryType categories');
      
      final tableName = _getTableName(categoryType);
      if (tableName == null) {
        throw Exception('סוג קטגוריה לא תקין: $categoryType');
      }

      for (final category in categoriesWithNewOrder) {
        if (category['id'] != null) {
          // Check if category exists before updating
          final existingCategory = await _supabase
              .from(tableName)
              .select('id')
              .eq('id', category['id'])
              .maybeSingle();

          if (existingCategory != null) {
            await _supabase
                .from(tableName)
                .update({
                  'sort_order': category['sort_order'],
                  'updated_at': DateTime.now().toIso8601String(),
                })
                .eq('id', category['id']);
          } else {
            debugPrint('⚠️ CategoryService: Category not found during reorder - ${category['id']}');
          }
        }
      }

      debugPrint('✅ CategoryService: Categories reordered successfully');
    } catch (error) {
      debugPrint('❌ CategoryService: Error reordering categories - $error');
      // Don't throw error, just log it
      debugPrint('🔄 CategoryService: Continuing despite reorder errors');
    }
  }

  /// חיפוש קטגוריות
  /// Search categories
  Future<List<Map<String, dynamic>>> searchCategories(
    String categoryType, {
    required String searchQuery,
    bool activeOnly = true,
  }) async {
    try {
      debugPrint('🔍 CategoryService: Searching $categoryType categories - $searchQuery');
      
      final tableName = _getTableName(categoryType);
      if (tableName == null) {
        throw Exception('סוג קטגוריה לא תקין: $categoryType');
      }

      var query = _supabase
          .from(tableName)
          .select('*')
          .or('name_he.ilike.%$searchQuery%,name_en.ilike.%$searchQuery%,description_he.ilike.%$searchQuery%');

      if (activeOnly) {
        query = query.eq('is_active', true);
      }

      final response = await query.order('sort_order', ascending: true);
      
      debugPrint('✅ CategoryService: Found ${response.length} categories matching search');
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      debugPrint('❌ CategoryService: Error searching categories - $error');
      throw Exception('שגיאה בחיפוש קטגוריות: $error');
    }
  }

  /// מחיקה קבוצתית של קטגוריות
  /// Bulk delete categories
  Future<void> bulkDeleteCategories(String categoryType, List<String> categoryIds) async {
    try {
      debugPrint('🗑️ CategoryService: Bulk deleting ${categoryIds.length} $categoryType categories');
      
      final tableName = _getTableName(categoryType);
      if (tableName == null) {
        throw Exception('סוג קטגוריה לא תקין: $categoryType');
      }

      await _supabase
          .from(tableName)
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .inFilter('id', categoryIds);

      debugPrint('✅ CategoryService: Bulk delete completed - ${categoryIds.length} categories');
    } catch (error) {
      debugPrint('❌ CategoryService: Error in bulk delete - $error');
      throw Exception('שגיאה במחיקה קבוצתית של קטגוריות: $error');
    }
  }

  /// העתקת קטגוריה
  /// Duplicate category
  Future<Map<String, dynamic>> duplicateCategory(String categoryType, String categoryId) async {
    try {
      debugPrint('📋 CategoryService: Duplicating $categoryType category - $categoryId');
      
      final tableName = _getTableName(categoryType);
      if (tableName == null) {
        throw Exception('סוג קטגוריה לא תקין: $categoryType');
      }

      // קבלת הקטגוריה המקורית
      final original = await _supabase
          .from(tableName)
          .select('*')
          .eq('id', categoryId)
          .single();

      // יצירת העתק
      final duplicateData = Map<String, dynamic>.from(original);
      duplicateData.remove('id');
      duplicateData.remove('created_at');
      duplicateData.remove('updated_at');
      duplicateData['name_he'] = '${original['name_he']} (העתק)';
      if (original['name_en'] != null) {
        duplicateData['name_en'] = '${original['name_en']} (Copy)';
      }
      duplicateData['sort_order'] = (original['sort_order'] ?? 0) + 1;
      duplicateData['created_by'] = _supabase.auth.currentUser?.id;
      duplicateData['created_at'] = DateTime.now().toIso8601String();
      duplicateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from(tableName)
          .insert(duplicateData)
          .select()
          .single();

      debugPrint('✅ CategoryService: Category duplicated successfully - ${response['id']}');
      return response;
    } catch (error) {
      debugPrint('❌ CategoryService: Error duplicating category - $error');
      throw Exception('שגיאה בהעתקת קטגוריה: $error');
    }
  }

  /// ייצוא קטגוריות ל-CSV
  /// Export categories to CSV
  Future<String> exportCategoriesToCSV(String categoryType) async {
    try {
      debugPrint('📤 CategoryService: Exporting $categoryType categories to CSV');
      
      final categories = await getCategoriesByType(categoryType, activeOnly: false);
      
      final csvLines = <String>[];
      
      // כותרות - Headers
      csvLines.add('ID,שם עברית,שם אנגלית,תיאור עברית,תיאור אנגלית,קוד צבע,אייקון,סדר מיון,פעיל,תאריך יצירה');
      
      // שורות נתונים - Data rows
      for (final category in categories) {
        csvLines.add([
          category['id'],
          category['name_he']?.replaceAll(',', '') ?? '',
          category['name_en']?.replaceAll(',', '') ?? '',
          category['description_he']?.replaceAll(',', '') ?? '',
          category['description_en']?.replaceAll(',', '') ?? '',
          category['color'] ?? '',
          category['icon'] ?? '',
          category['sort_order']?.toString() ?? '0',
          (category['is_active'] ?? false) ? 'כן' : 'לא',
          category['created_at'] ?? '',
        ].join(','));
      }

      debugPrint('✅ CategoryService: CSV export completed - ${categories.length} categories');
      return csvLines.join('\n');
    } catch (error) {
      debugPrint('❌ CategoryService: Error exporting to CSV - $error');
      throw Exception('שגיאה בייצוא לקובץ CSV: $error');
    }
  }

  // =============================================
  // פונקציות עזר פרטיות - Private Helper Functions
  // =============================================

  /// מחזירה את שם הטבלה לפי סוג הקטגוריה
  /// Returns table name by category type
  String? _getTableName(String categoryType) {
    switch (categoryType.toLowerCase()) {
      case 'tutorial':
      case 'tutorials':
        return tutorialCategoriesTable;
      case 'gallery':
        return galleryCategoriesTable;
      case 'update':
      case 'updates':
        return updateCategoriesTable;
      default:
        return null;
    }
  }

  /// מחזירה קוד צבע ברירת מחדל לפי סוג הקטגוריה
  /// Returns default color code by category type
  String _getDefaultColorCode(String categoryType) {
    switch (categoryType.toLowerCase()) {
      case 'tutorial':
      case 'tutorials':
        return '#FF00FF'; // פוקסיה - Fuchsia
      case 'gallery':
        return '#40E0D0'; // טורקיז - Turquoise
      case 'update':
      case 'updates':
        return '#E91E63'; // ורוד - Pink
      default:
        return '#9C27B0'; // סגול - Purple
    }
  }

  /// ולידציה של נתוני קטגוריה
  /// Validate category data
  bool _validateCategoryData(Map<String, dynamic> categoryData) {
    // בדיקה שיש שם בעברית
    if (categoryData['name_he'] == null || categoryData['name_he'].toString().trim().isEmpty) {
      return false;
    }

    // בדיקה שהשם לא ארוך מדי
    if (categoryData['name_he'].toString().length > 100) {
      return false;
    }

    // בדיקה של קוד צבע
    if (categoryData['color'] != null) {
      final colorCode = categoryData['color'].toString();
      if (!RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(colorCode)) {
        return false;
      }
    }

    return true;
  }
}