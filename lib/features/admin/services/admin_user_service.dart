import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';
import '../../../shared/models/user_model.dart';

/// שירות מנהל משתמשים עם אינטגרציה מלאה עם Supabase
/// מספק פונקציות ניהול מתקדמות למנהלי המערכת
class AdminUserService {
  static final SupabaseClient _client = SupabaseConfig.client;
  
  // =============================================
  // פונקציות ניהול משתמשים בסיסיות
  // =============================================

  /// קבלת כל המשתמשים עם סינון ומיון
  /// [role] - סינון לפי תפקיד (admin, instructor, parent, student)
  /// [searchQuery] - חיפוש בשם, אימייל או טלפון
  /// [sortBy] - מיון לפי (created_at, display_name, email, role)
  /// [sortOrder] - סדר המיון (asc, desc)
  /// [isActive] - הצגת משתמשים פעילים/לא פעילים
  /// [limit] - מגבלת התוצאות
  /// [offset] - היסט לעמוד נוכחי
  static Future<AdminUserResult<List<UserModel>>> getAllUsers({
    String? role,
    String? searchQuery,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    bool? isActive,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('AdminUserService: Fetching users with filters - role: $role, search: $searchQuery');
      }

      dynamic queryBuilder = _client
          .from('users')
          .select('*');

      // סינון לפי סטטוס פעילות
      if (isActive != null) {
        queryBuilder = queryBuilder.eq('is_active', isActive);
      }

      // סינון לפי תפקיד
      if (role != null && role != 'all' && role.isNotEmpty) {
        queryBuilder = queryBuilder.eq('role', role);
      }

      // חיפוש טקסט
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final query = searchQuery.trim();
        queryBuilder = queryBuilder.or(
          'display_name.ilike.%$query%,'
          'email.ilike.%$query%,'
          'phone.ilike.%$query%,'
          'first_name.ilike.%$query%,'
          'last_name.ilike.%$query%'
        );
      }

      // מיון
      final ascending = sortOrder.toLowerCase() == 'asc';
      queryBuilder = queryBuilder.order(sortBy, ascending: ascending);

      // עמוד וגבלה
      queryBuilder = queryBuilder.range(offset, offset + limit - 1);

      final response = await queryBuilder;
      
      final users = (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();

      if (kDebugMode) {
        debugPrint('AdminUserService: Retrieved ${users.length} users');
      }

      return AdminUserResult.success(
        data: users,
        message: 'נטענו ${users.length} משתמשים בהצלחה',
      );
    } on PostgrestException catch (e) {
      if (kDebugMode) {
        debugPrint('AdminUserService: Database error in getAllUsers: ${e.message}');
      }
      return AdminUserResult.error('שגיאה בטעינת נתוני משתמשים: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AdminUserService: Error in getAllUsers: $e');
      }
      return AdminUserResult.error('שגיאה בטעינת משתמשים: $e');
    }
  }

  /// יצירת משתמש חדש עם ולידציה מלאה
  /// [email] - כתובת אימייל (חובה)
  /// [displayName] - שם תצוגה (חובה)
  /// [role] - תפקיד (admin, instructor, parent, student)
  /// [phone] - מספר טלפון (אופציונלי)
  /// [address] - כתובת (אופציונלי)
  static Future<AdminUserResult<UserModel>> createUser({
    required String email,
    required String displayName,
    required String role,
    String? phone,
    String? address,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('AdminUserService: Creating user with email: $email');
      }

      // ולידציה של פרמטרים
      final validationResult = _validateUserInput(
        email: email,
        displayName: displayName,
        role: role,
        phone: phone,
      );
      
      if (!validationResult.isSuccess) {
        return AdminUserResult.error(validationResult.message);
      }

      // בדיקה אם המשתמש כבר קיים
      final existingUser = await _checkUserExists(email);
      if (existingUser != null) {
        return AdminUserResult.error('משתמש עם אימייל זה כבר קיים במערכת');
      }

      // פיצול שם מלא לפרטי ומשפחה
      final nameParts = displayName.trim().split(' ');
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : null;

      // יצירת משתמש ב-Auth של Supabase
      final authResponse = await _client.auth.admin.createUser(
        AdminUserAttributes(
          email: email,
          emailConfirm: true,
          userMetadata: {
            'display_name': displayName,
            'role': role,
            'created_by_admin': true,
          },
        ),
      );

      if (authResponse.user == null) {
        return AdminUserResult.error('שגיאה ביצירת חשבון משתמש');
      }

      // יצירת פרופיל משתמש בטבלה
      final userData = {
        'id': authResponse.user!.id,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'display_name': displayName,
        'role': role,
        'phone': _formatPhoneNumber(phone),
        'address': address?.trim(),
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from(SupabaseConfig.usersTable)
          .insert(userData)
          .select()
          .single();

      final createdUser = UserModel.fromJson(response);

      // רישום פעולה ב-Audit Log
      await _logAdminAction(
        action: 'create_user',
        targetUserId: createdUser.id,
        details: {
          'email': email,
          'role': role,
          'display_name': displayName,
        },
      );

      if (kDebugMode) {
        debugPrint('AdminUserService: User created successfully: ${createdUser.id}');
      }

      return AdminUserResult.success(
        data: createdUser,
        message: 'המשתמש נוצר בהצלחה',
      );
    } on AuthException catch (e) {
      if (kDebugMode) {
        debugPrint('AdminUserService: Auth error in createUser: ${e.message}');
      }
      return AdminUserResult.error('שגיאה באימות: ${e.message}');
    } on PostgrestException catch (e) {
      if (kDebugMode) {
        debugPrint('AdminUserService: Database error in createUser: ${e.message}');
      }
      return AdminUserResult.error('שגיאה בבסיס הנתונים: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AdminUserService: Error in createUser: $e');
      }
      return AdminUserResult.error('שגיאה ביצירת משתמש: $e');
    }
  }

  /// עדכון פרטי משתמש
  /// [userId] - מזהה המשתמש
  /// [userData] - מפה של נתונים לעדכון
  static Future<AdminUserResult<UserModel>> updateUser(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint('AdminUserService: Updating user: $userId');
      }

      // ולידציה של מזהה המשתמש
      if (userId.trim().isEmpty) {
        return AdminUserResult.error('מזהה משתמש לא תקין');
      }

      // בדיקה שהמשתמש קיים
      final existingUser = await _getUserById(userId);
      if (existingUser == null) {
        return AdminUserResult.error('משתמש לא נמצא');
      }

      // הכנת נתונים לעדכון
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      // עדכון שדות מותרים בלבד
      final allowedFields = [
        'first_name',
        'last_name', 
        'display_name',
        'phone',
        'address',
        'bio',
        'avatar_url',
        'date_of_birth',
      ];

      for (final field in allowedFields) {
        if (userData.containsKey(field) && userData[field] != null) {
          if (field == 'phone') {
            updateData[field] = _formatPhoneNumber(userData[field]);
          } else if (field == 'date_of_birth' && userData[field] is String) {
            final date = DateTime.tryParse(userData[field]);
            updateData[field] = date?.toIso8601String();
          } else {
            updateData[field] = userData[field].toString().trim();
          }
        }
      }

      // ולידציה של נתונים
      if (updateData.containsKey('phone')) {
        final phoneValidation = _validatePhoneNumber(updateData['phone']);
        if (!phoneValidation.isValid) {
          return AdminUserResult.error(phoneValidation.error!);
        }
      }

      final response = await _client
          .from(SupabaseConfig.usersTable)
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();

      final updatedUser = UserModel.fromJson(response);

      // רישום פעולה ב-Audit Log
      await _logAdminAction(
        action: 'update_user',
        targetUserId: userId,
        details: updateData,
      );

      if (kDebugMode) {
        debugPrint('AdminUserService: User updated successfully: $userId');
      }

      return AdminUserResult.success(
        data: updatedUser,
        message: 'פרטי המשתמש עודכנו בהצלחה',
      );
    } on PostgrestException catch (e) {
      if (kDebugMode) {
        debugPrint('AdminUserService: Database error in updateUser: ${e.message}');
      }
      return AdminUserResult.error('שגיאה בעדכון נתונים: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AdminUserService: Error in updateUser: $e');
      }
      return AdminUserResult.error('שגיאה בעדכון משתמש: $e');
    }
  }

  /// מחיקה רכה של משתמש (סימון כלא פעיל)
  /// [userId] - מזהה המשתמש למחיקה
  static Future<AdminUserResult<void>> deleteUser(String userId) async {
    try {
      if (kDebugMode) {
        debugPrint('AdminUserService: Soft deleting user: $userId');
      }

      // בדיקה שהמשתמש קיים
      final existingUser = await _getUserById(userId);
      if (existingUser == null) {
        return AdminUserResult.error('משתמש לא נמצא');
      }

      // מחיקה רכה - סימון כלא פעיל
      await _client
          .from(SupabaseConfig.usersTable)
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
            'deactivated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      // רישום פעולה ב-Audit Log
      await _logAdminAction(
        action: 'delete_user',
        targetUserId: userId,
        details: {
          'user_email': existingUser.email,
          'user_name': existingUser.displayName,
        },
      );

      if (kDebugMode) {
        debugPrint('AdminUserService: User deactivated successfully: $userId');
      }

      return AdminUserResult.success(
        data: null,
        message: 'המשתמש הוסר מהמערכת בהצלחה',
      );
    } on PostgrestException catch (e) {
      if (kDebugMode) {
        debugPrint('AdminUserService: Database error in deleteUser: ${e.message}');
      }
      return AdminUserResult.error('שגיאה במחיקת משתמש: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AdminUserService: Error in deleteUser: $e');
      }
      return AdminUserResult.error('שגיאה במחיקת משתמש: $e');
    }
  }

  /// שינוי תפקיד משתמש עם ולידציה
  /// [userId] - מזהה המשתמש
  /// [newRole] - התפקיד החדש
  static Future<AdminUserResult<UserModel>> changeUserRole(
    String userId,
    String newRole,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint('AdminUserService: Changing user role: $userId to $newRole');
      }

      // ולידציה של תפקיד
      if (!_isValidRole(newRole)) {
        return AdminUserResult.error('תפקיד לא תקין');
      }

      // בדיקה שהמשתמש קיים
      final existingUser = await _getUserById(userId);
      if (existingUser == null) {
        return AdminUserResult.error('משתמש לא נמצא');
      }

      // בדיקה שהתפקיד באמת משתנה
      if (existingUser.role.value == newRole) {
        return AdminUserResult.error('המשתמש כבר בעל תפקיד זה');
      }

      // עדכון התפקיד
      final response = await _client
          .from(SupabaseConfig.usersTable)
          .update({
            'role': newRole,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId)
          .select()
          .single();

      final updatedUser = UserModel.fromJson(response);

      // רישום פעולה ב-Audit Log
      await _logAdminAction(
        action: 'change_user_role',
        targetUserId: userId,
        details: {
          'old_role': existingUser.role.value,
          'new_role': newRole,
          'user_email': existingUser.email,
        },
      );

      if (kDebugMode) {
        debugPrint('AdminUserService: User role changed successfully: $userId');
      }

      return AdminUserResult.success(
        data: updatedUser,
        message: 'תפקיד המשתמש שונה בהצלחה',
      );
    } on PostgrestException catch (e) {
      if (kDebugMode) {
        debugPrint('AdminUserService: Database error in changeUserRole: ${e.message}');
      }
      return AdminUserResult.error('שגיאה בשינוי תפקיד: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AdminUserService: Error in changeUserRole: $e');
      }
      return AdminUserResult.error('שגיאה בשינוי תפקיד: $e');
    }
  }

  /// חיפוש מתקדם של משתמשים
  /// [query] - מחרוזת החיפוש
  /// [role] - סינון לפי תפקיד
  /// [sortBy] - שדה המיון
  /// [sortOrder] - סדר המיון
  static Future<AdminUserResult<List<UserModel>>> searchUsers({
    required String query,
    String? role,
    String sortBy = 'display_name',
    String sortOrder = 'asc',
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('AdminUserService: Searching users with query: $query');
      }

      if (query.trim().isEmpty) {
        return AdminUserResult.error('נא להזין מילת חיפוש');
      }

      return await getAllUsers(
        searchQuery: query.trim(),
        role: role,
        sortBy: sortBy,
        sortOrder: sortOrder,
        limit: 100, // חיפוש עם מגבלה גבוהה יותר
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AdminUserService: Error in searchUsers: $e');
      }
      return AdminUserResult.error('שגיאה בחיפוש משתמשים: $e');
    }
  }

  /// קבלת סטטיסטיקות משתמש
  /// [userId] - מזהה המשתמש
  static Future<AdminUserResult<Map<String, dynamic>>> getUserStats(
    String userId,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint('AdminUserService: Getting stats for user: $userId');
      }

      // בדיקה שהמשתמש קיים
      final user = await _getUserById(userId);
      if (user == null) {
        return AdminUserResult.error('משתמש לא נמצא');
      }

      // קבלת סטטיסטיקות מהטבלאות השונות
      final futures = await Future.wait([
        _getUserProgressStats(userId),
        _getUserActivityStats(userId),
        _getUserEngagementStats(userId),
      ]);

      final progressStats = futures[0];
      final activityStats = futures[1];
      final engagementStats = futures[2];

      final stats = {
        'user_info': {
          'id': user.id,
          'email': user.email,
          'display_name': user.displayName,
          'role': user.role.value,
          'created_at': user.createdAt.toIso8601String(),
          'is_active': true, // מקבלים רק משתמשים פעילים
        },
        'progress': progressStats,
        'activity': activityStats,
        'engagement': engagementStats,
        'generated_at': DateTime.now().toIso8601String(),
      };

      if (kDebugMode) {
        debugPrint('AdminUserService: Stats generated for user: $userId');
      }

      return AdminUserResult.success(
        data: stats,
        message: 'סטטיסטיקות המשתמש נטענו בהצלחה',
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AdminUserService: Error in getUserStats: $e');
      }
      return AdminUserResult.error('שגיאה בטעינת סטטיסטיקות: $e');
    }
  }

  /// עדכון קבוצתי של משתמשים
  /// [userIds] - רשימת מזהי משתמשים
  /// [updateData] - נתונים לעדכון
  static Future<AdminUserResult<List<UserModel>>> bulkUpdateUsers(
    List<String> userIds,
    Map<String, dynamic> updateData,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint('AdminUserService: Bulk updating ${userIds.length} users');
      }

      if (userIds.isEmpty) {
        return AdminUserResult.error('לא נבחרו משתמשים לעדכון');
      }

      if (updateData.isEmpty) {
        return AdminUserResult.error('לא הוגדרו נתונים לעדכון');
      }

      // הכנת נתונים לעדכון
      final bulkUpdateData = Map<String, dynamic>.from(updateData);
      bulkUpdateData['updated_at'] = DateTime.now().toIso8601String();

      // ולידציה של שדות מותרים
      final allowedFields = [
        'role',
        'is_active',
        'phone',
        'address',
        'updated_at'
      ];

      final invalidFields = bulkUpdateData.keys
          .where((key) => !allowedFields.contains(key))
          .toList();

      if (invalidFields.isNotEmpty) {
        return AdminUserResult.error('שדות לא מותרים לעדכון: ${invalidFields.join(", ")}');
      }

      // עדכון בטופס נתונים
      final response = await _client
          .from(SupabaseConfig.usersTable)
          .update(bulkUpdateData)
          .inFilter('id', userIds)
          .select();

      final updatedUsers = (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();

      // רישום פעולה ב-Audit Log
      await _logAdminAction(
        action: 'bulk_update_users',
        details: {
          'user_count': userIds.length,
          'user_ids': userIds,
          'update_data': updateData,
        },
      );

      if (kDebugMode) {
        debugPrint('AdminUserService: Bulk update completed for ${updatedUsers.length} users');
      }

      return AdminUserResult.success(
        data: updatedUsers,
        message: 'עודכנו ${updatedUsers.length} משתמשים בהצלחה',
      );
    } on PostgrestException catch (e) {
      if (kDebugMode) {
        debugPrint('AdminUserService: Database error in bulkUpdateUsers: ${e.message}');
      }
      return AdminUserResult.error('שגיאה בעדכון קבוצתי: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AdminUserService: Error in bulkUpdateUsers: $e');
      }
      return AdminUserResult.error('שגיאה בעדכון קבוצתי: $e');
    }
  }

  /// שליחת איפוס סיסמה למשתמש
  /// [email] - כתובת האימייל
  static Future<AdminUserResult<void>> sendPasswordReset(String email) async {
    try {
      if (kDebugMode) {
        debugPrint('AdminUserService: Sending password reset to: $email');
      }

      // ולידציה של אימייל
      if (!_isValidEmail(email)) {
        return AdminUserResult.error('כתובת אימייל לא תקינה');
      }

      // בדיקה שהמשתמש קיים
      final existingUser = await _checkUserExists(email);
      if (existingUser == null) {
        return AdminUserResult.error('משתמש עם אימייל זה לא קיים במערכת');
      }

      // שליחת איפוס סיסמה
      await _client.auth.resetPasswordForEmail(email);

      // רישום פעולה ב-Audit Log
      await _logAdminAction(
        action: 'send_password_reset',
        targetUserId: existingUser['id'],
        details: {
          'email': email,
        },
      );

      if (kDebugMode) {
        debugPrint('AdminUserService: Password reset sent successfully to: $email');
      }

      return AdminUserResult.success(
        data: null,
        message: 'נשלח אימייל איפוס סיסמה למשתמש',
      );
    } on AuthException catch (e) {
      if (kDebugMode) {
        debugPrint('AdminUserService: Auth error in sendPasswordReset: ${e.message}');
      }
      return AdminUserResult.error('שגיאה בשליחת איפוס סיסמה: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AdminUserService: Error in sendPasswordReset: $e');
      }
      return AdminUserResult.error('שגיאה בשליחת איפוס סיסמה: $e');
    }
  }

  /// הפעלה מחדש של משתמש שהוסר
  /// [userId] - מזהה המשתמש להפעלה מחדש
  static Future<AdminUserResult<UserModel>> reactivateUser(String userId) async {
    try {
      if (kDebugMode) {
        debugPrint('AdminUserService: Reactivating user: $userId');
      }

      // בדיקה שהמשתמש קיים (כולל לא פעילים)
      final response = await _client
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        return AdminUserResult.error('משתמש לא נמצא');
      }

      final user = UserModel.fromJson(response);
      
      // בדיקה שהמשתמש באמת לא פעיל
      if (response['is_active'] == true) {
        return AdminUserResult.error('המשתמש כבר פעיל במערכת');
      }

      // הפעלה מחדש
      final updateResponse = await _client
          .from(SupabaseConfig.usersTable)
          .update({
            'is_active': true,
            'updated_at': DateTime.now().toIso8601String(),
            'reactivated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId)
          .select()
          .single();

      final reactivatedUser = UserModel.fromJson(updateResponse);

      // רישום פעולה ב-Audit Log
      await _logAdminAction(
        action: 'reactivate_user',
        targetUserId: userId,
        details: {
          'user_email': user.email,
          'user_name': user.displayName,
        },
      );

      if (kDebugMode) {
        debugPrint('AdminUserService: User reactivated successfully: $userId');
      }

      return AdminUserResult.success(
        data: reactivatedUser,
        message: 'המשתמש הופעל מחדש בהצלחה',
      );
    } on PostgrestException catch (e) {
      if (kDebugMode) {
        debugPrint('AdminUserService: Database error in reactivateUser: ${e.message}');
      }
      return AdminUserResult.error('שגיאה בהפעלת משתמש: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AdminUserService: Error in reactivateUser: $e');
      }
      return AdminUserResult.error('שגיאה בהפעלת משתמש: $e');
    }
  }

  // =============================================
  // פונקציות עזר פרטיות
  // =============================================

  /// קבלת משתמש לפי ID
  static Future<UserModel?> _getUserById(String userId) async {
    try {
      final response = await _client
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('id', userId)
          .maybeSingle();

      return response != null ? UserModel.fromJson(response) : null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AdminUserService: Error getting user by ID: $e');
      }
      return null;
    }
  }

  /// בדיקה אם משתמש קיים לפי אימייל
  static Future<Map<String, dynamic>?> _checkUserExists(String email) async {
    try {
      final response = await _client
          .from(SupabaseConfig.usersTable)
          .select('id, email, is_active')
          .eq('email', email.toLowerCase().trim())
          .maybeSingle();

      return response;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AdminUserService: Error checking user exists: $e');
      }
      return null;
    }
  }

  /// ולידציה של נתוני קלט למשתמש
  static AdminUserResult<void> _validateUserInput({
    required String email,
    required String displayName,
    required String role,
    String? phone,
  }) {
    // ולידציה של אימייל
    if (!_isValidEmail(email)) {
      return AdminUserResult.error('כתובת אימייל לא תקינה');
    }

    // ולידציה של שם תצוגה
    if (displayName.trim().length < 2) {
      return AdminUserResult.error('שם התצוגה חייב להכיל לפחות 2 תווים');
    }

    // ולידציה של תפקיד
    if (!_isValidRole(role)) {
      return AdminUserResult.error('תפקיד לא תקין');
    }

    // ולידציה של טלפון (אם קיים)
    if (phone != null && phone.isNotEmpty) {
      final phoneValidation = _validatePhoneNumber(phone);
      if (!phoneValidation.isValid) {
        return AdminUserResult.error(phoneValidation.error!);
      }
    }

    return AdminUserResult.success(data: null, message: 'ולידציה עברה בהצלחה');
  }

  /// בדיקה אם אימייל תקין
  static bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email.trim());
  }

  /// בדיקה אם תפקיד תקין
  static bool _isValidRole(String role) {
    const validRoles = ['admin', 'instructor', 'parent', 'student'];
    return validRoles.contains(role.toLowerCase().trim());
  }

  /// ולידציה של מספר טלפון
  static ({bool isValid, String? error}) _validatePhoneNumber(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return (isValid: true, error: null);
    }

    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // בדיקה לטלפונים ישראליים
    if (cleanPhone.startsWith('+972')) {
      if (cleanPhone.length != 13) {
        return (isValid: false, error: 'מספר טלפון ישראלי חייב להכיל 13 ספרות עם קידומת +972');
      }
    } else if (cleanPhone.startsWith('0')) {
      if (cleanPhone.length != 10) {
        return (isValid: false, error: 'מספר טלפון ישראלי חייב להכיל 10 ספרות');
      }
    } else {
      return (isValid: false, error: 'מספר טלפון לא תקין. נא להזין מספר ישראלי');
    }

    return (isValid: true, error: null);
  }

  /// עיצוב מספר טלפון
  static String? _formatPhoneNumber(String? phone) {
    if (phone == null || phone.trim().isEmpty) return null;

    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    if (cleanPhone.startsWith('+972')) {
      return cleanPhone;
    } else if (cleanPhone.startsWith('0') && cleanPhone.length == 10) {
      return '+972${cleanPhone.substring(1)}';
    }
    
    return cleanPhone;
  }

  /// קבלת סטטיסטיקות התקדמות משתמש
  static Future<Map<String, dynamic>> _getUserProgressStats(String userId) async {
    try {
      final progressData = await _client
          .from(SupabaseConfig.userProgressTable)
          .select('*, tutorial:tutorial_id(title_he, duration_minutes)')
          .eq('user_id', userId);

      final completedCount = (progressData as List)
          .where((p) => p['is_completed'] == true)
          .length;

      final totalWatchTime = progressData
          .fold<int>(0, (sum, p) => sum + (p['watched_duration_seconds'] as int? ?? 0));

      return {
        'tutorials_started': progressData.length,
        'tutorials_completed': completedCount,
        'completion_rate': progressData.isNotEmpty 
            ? (completedCount / progressData.length * 100).round()
            : 0,
        'total_watch_time_minutes': (totalWatchTime / 60).round(),
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting user progress stats: $e');
      }
      return {
        'tutorials_started': 0,
        'tutorials_completed': 0,
        'completion_rate': 0,
        'total_watch_time_minutes': 0,
      };
    }
  }

  /// קבלת סטטיסטיקות פעילות משתמש
  static Future<Map<String, dynamic>> _getUserActivityStats(String userId) async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      final activityData = await _client
          .from(SupabaseConfig.analyticsTable)
          .select('event_type, created_at')
          .eq('user_id', userId)
          .gte('created_at', thirtyDaysAgo.toIso8601String());

      final recentActivity = (activityData as List).length;
      final lastActivity = activityData.isNotEmpty
          ? DateTime.parse(activityData.first['created_at'])
          : null;

      return {
        'recent_activity_count': recentActivity,
        'last_activity': lastActivity?.toIso8601String(),
        'days_since_last_activity': lastActivity != null
            ? DateTime.now().difference(lastActivity).inDays
            : null,
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting user activity stats: $e');
      }
      return {
        'recent_activity_count': 0,
        'last_activity': null,
        'days_since_last_activity': null,
      };
    }
  }

  /// קבלת סטטיסטיקות מעורבות משתמש
  static Future<Map<String, dynamic>> _getUserEngagementStats(String userId) async {
    try {
      final likesData = await _client
          .from(SupabaseConfig.likesTable)
          .select('content_type')
          .eq('user_id', userId);

      final likesCount = (likesData as List).length;
      
      final contentTypeCounts = <String, int>{};
      for (final like in likesData) {
        final contentType = like['content_type'] as String;
        contentTypeCounts[contentType] = (contentTypeCounts[contentType] ?? 0) + 1;
      }

      return {
        'total_likes': likesCount,
        'likes_by_content_type': contentTypeCounts,
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting user engagement stats: $e');
      }
      return {
        'total_likes': 0,
        'likes_by_content_type': <String, int>{},
      };
    }
  }

  /// רישום פעולת מנהל ב-Audit Log
  static Future<void> _logAdminAction({
    required String action,
    String? targetUserId,
    Map<String, dynamic>? details,
  }) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return;

      await _client.from(SupabaseConfig.analyticsTable).insert({
        'event_type': 'admin_action',
        'user_id': currentUser.id,
        'content_type': 'user_management',
        'content_id': targetUserId,
        'metadata': {
          'action': action,
          'details': details,
          'timestamp': DateTime.now().toIso8601String(),
        },
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error logging admin action: $e');
      }
    }
  }
}

/// מחלקת תוצאות לפעולות מנהל משתמשים
class AdminUserResult<T> {
  final bool isSuccess;
  final String message;
  final T? data;
  final String? errorCode;

  const AdminUserResult._({
    required this.isSuccess,
    required this.message,
    this.data,
    this.errorCode,
  });

  factory AdminUserResult.success({
    required T? data,
    required String message,
  }) {
    return AdminUserResult._(
      isSuccess: true,
      message: message,
      data: data,
    );
  }

  factory AdminUserResult.error(String message, {String? errorCode}) {
    return AdminUserResult._(
      isSuccess: false,
      message: message,
      errorCode: errorCode,
    );
  }

  @override
  String toString() {
    return 'AdminUserResult(isSuccess: $isSuccess, message: $message, data: $data)';
  }
}