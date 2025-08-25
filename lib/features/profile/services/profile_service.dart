import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/models/user_model.dart';
import '../../../core/constants/app_constants.dart';

/// Service for managing user profile operations
class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _imagePicker = ImagePicker();

  /// Get user statistics and dashboard data
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      // Get real user statistics from Supabase database
      final response = await _supabase.rpc('get_user_stats', params: {'user_id': userId});
      
      // If no data is returned, provide default empty stats
      final stats = response ?? {
        'danceLevel': 'טוען...',
        'instructorsWatched': 0,
        'attendanceDays': 0,
        'favoriteMoves': [],
        'achievements': [],
        'recentActivity': [],
      };
      
      return stats;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('ProfileService: Error getting user stats: $error');
      }
      throw Exception('Failed to load user statistics');
    }
  }

  /// Get user preferences
  Future<Map<String, dynamic>> getUserPreferences(String userId) async {
    try {
      final response = await _supabase
          .from('user_preferences')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      if (response == null) {
        // Return default preferences
        return {
          'notifications_enabled': true,
          'email_notifications': true,
          'push_notifications': true,
          'language': 'he',
          'theme': 'dark',
          'auto_play_videos': true,
          'data_saver_mode': false,
        };
      }
      
      return response;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('ProfileService: Error getting user preferences: $error');
      }
      // Return default preferences on error
      return {
        'notifications_enabled': true,
        'email_notifications': true,
        'push_notifications': true,
        'language': 'he',
        'theme': 'dark',
        'auto_play_videos': true,
        'data_saver_mode': false,
      };
    }
  }

  /// Update user preferences
  Future<void> updateUserPreferences(String userId, Map<String, dynamic> preferences) async {
    try {
      await _supabase
          .from('user_preferences')
          .upsert({
            'user_id': userId,
            ...preferences,
            'updated_at': DateTime.now().toIso8601String(),
          });
    } catch (error) {
      if (kDebugMode) {
        debugPrint('ProfileService: Error updating user preferences: $error');
      }
      throw Exception('Failed to update preferences');
    }
  }

  /// Pick and upload profile image
  Future<String?> updateProfileImage(String userId) async {
    try {
      // Pick image from gallery
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) return null;

      // Check file size
      final File imageFile = File(image.path);
      final int fileSize = await imageFile.length();
      
      if (fileSize > AppConstants.maxProfileImageSize) {
        throw Exception('Image size too large. Maximum size is 5MB.');
      }

      // Generate unique filename
      final String fileName = 'profile_$userId.jpg';
      
      // Upload to Supabase storage
      await _supabase.storage
          .from(AppConstants.profileImagesBucket)
          .upload(fileName, imageFile, fileOptions: const FileOptions(upsert: true));

      // Get public URL
      final String publicUrl = _supabase.storage
          .from(AppConstants.profileImagesBucket)
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('ProfileService: Error uploading profile image: $error');
      }
      throw Exception('Failed to upload image: $error');
    }
  }

  /// Update user profile
  Future<UserModel> updateProfile({
    required String userId,
    String? fullName,
    String? phoneNumber,
    String? address,
    DateTime? birthDate,
    String? avatarUrl,
  }) async {
    try {
      final Map<String, dynamic> updates = {
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Use correct column names for 'users' table
      if (fullName != null) updates['display_name'] = fullName;
      if (phoneNumber != null) updates['phone'] = phoneNumber;
      if (address != null) updates['address'] = address;
      if (birthDate != null) updates['birth_date'] = birthDate.toIso8601String();
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      if (kDebugMode) {
        debugPrint('ProfileService: Updating profile for userId: $userId');
        debugPrint('ProfileService: Updates data: $updates');
      }

      final response = await _supabase
          .from('users')  // Use 'users' table, not 'profiles'
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      if (kDebugMode) {
        debugPrint('ProfileService: Update successful, response: $response');
      }

      return UserModel.fromJson(response);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('ProfileService: Error updating profile: $error');
        debugPrint('ProfileService: Error type: ${error.runtimeType}');
      }
      
      // Enhanced error handling with specific error messages
      String errorMessage = 'Failed to update profile';
      if (error.toString().contains('Row Level Security')) {
        errorMessage = 'אין הרשאה לעדכן פרופיל. יש להתחבר קודם.';
      } else if (error.toString().contains('duplicate key')) {
        errorMessage = 'שגיאה בנתונים - כתובת אימייל או טלפון כבר קיימים';
      } else if (error.toString().contains('violates foreign key')) {
        errorMessage = 'שגיאה בחיבור לנתונים';
      }
      
      throw Exception(errorMessage);
    }
  }

  /// Change user password
  Future<void> changePassword(String newPassword) async {
    try {
      final UserResponse response = await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user == null) {
        throw Exception('Failed to update password');
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('ProfileService: Error changing password: $error');
      }
      throw Exception('Failed to change password: $error');
    }
  }

  /// Delete user account
  Future<void> deleteAccount(String userId) async {
    try {
      // Mark user as inactive instead of deleting (for data integrity)
      await _supabase
          .from('users')
          .update({'is_active': false})
          .eq('id', userId);

      // Delete user preferences
      await _supabase
          .from('user_preferences')
          .delete()
          .eq('user_id', userId);

      // Note: We don't delete the auth user directly here as it requires service role
      // This should be handled by a server-side function
    } catch (error) {
      if (kDebugMode) {
        debugPrint('ProfileService: Error deleting account: $error');
      }
      throw Exception('Failed to delete account: $error');
    }
  }

  /// Export user data
  Future<Map<String, dynamic>> exportUserData(String userId) async {
    try {
      final List<Future> futures = [
        _supabase.from('users').select().eq('id', userId).maybeSingle(),
        _supabase.from('user_preferences').select().eq('user_id', userId).maybeSingle(),
      ];

      final results = await Future.wait(futures);

      return {
        'profile': results[0],
        'preferences': results[1],
        'exported_at': DateTime.now().toIso8601String(),
      };
    } catch (error) {
      if (kDebugMode) {
        debugPrint('ProfileService: Error exporting user data: $error');
      }
      throw Exception('Failed to export user data: $error');
    }
  }

  /// Get role-specific information
  String getRoleDisplayName(String role) {
    switch (role) {
      case AppConstants.roleStudent:
        return 'תלמיד';
      case AppConstants.roleParent:
        return 'הורה';
      case AppConstants.roleInstructor:
        return 'מדריך';
      case AppConstants.roleAdmin:
        return 'מנהל';
      default:
        return 'משתמש';
    }
  }

  /// Get role icon
  String getRoleIcon(String role) {
    switch (role) {
      case AppConstants.roleStudent:
        return '🎓';
      case AppConstants.roleParent:
        return '👨‍👩‍👧‍👦';
      case AppConstants.roleInstructor:
        return '🎭';
      case AppConstants.roleAdmin:
        return '👑';
      default:
        return '👤';
    }
  }
}