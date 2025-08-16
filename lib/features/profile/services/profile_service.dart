import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/user_model.dart';
import '../../../core/constants/app_constants.dart';

/// Service for managing user profile operations
class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _imagePicker = ImagePicker();

  /// Get user statistics and dashboard data
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      // Mock data for demonstration - in real app, fetch from database
      await Future.delayed(const Duration(milliseconds: 500));
      
      final stats = {
        'danceLevel': 'מתחיל',
        'instructorsWatched': 5,
        'attendanceDays': 42,
        'favoriteMoves': ['Breakdance', 'Freestyle', 'Hip-Hop'],
        'achievements': [
          {'title': 'רקדן חדש', 'icon': '🎯', 'date': '2024-01-15'},
          {'title': 'נוכחות מושלמת', 'icon': '⭐', 'date': '2024-02-01'},
          {'title': 'תלמיד מצטיין', 'icon': '🏆', 'date': '2024-03-01'},
        ],
        'recentActivity': [
          {'action': 'צפיה בשיעור חדש', 'date': '2024-03-10'},
          {'action': 'עדכון פרופיל', 'date': '2024-03-08'},
          {'action': 'השתתפות באירוע', 'date': '2024-03-05'},
        ],
      };
      
      return stats;
    } catch (error) {
      if (kDebugMode) {
        print('ProfileService: Error getting user stats: $error');
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
        print('ProfileService: Error getting user preferences: $error');
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
        print('ProfileService: Error updating user preferences: $error');
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
        maxWidth: 512,
        maxHeight: 512,
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
        print('ProfileService: Error uploading profile image: $error');
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
    String? profileImageUrl,
  }) async {
    try {
      final Map<String, dynamic> updates = {
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updates['full_name'] = fullName;
      if (phoneNumber != null) updates['phone_number'] = phoneNumber;
      if (address != null) updates['address'] = address;
      if (birthDate != null) updates['birth_date'] = birthDate.toIso8601String();
      if (profileImageUrl != null) updates['profile_image_url'] = profileImageUrl;

      final response = await _supabase
          .from('profiles')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (error) {
      if (kDebugMode) {
        print('ProfileService: Error updating profile: $error');
      }
      throw Exception('Failed to update profile');
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
        print('ProfileService: Error changing password: $error');
      }
      throw Exception('Failed to change password: $error');
    }
  }

  /// Delete user account
  Future<void> deleteAccount(String userId) async {
    try {
      // Delete user profile
      await _supabase
          .from('profiles')
          .delete()
          .eq('id', userId);

      // Delete user preferences
      await _supabase
          .from('user_preferences')
          .delete()
          .eq('user_id', userId);

      // Delete auth user (this will cascade delete related data)
      await _supabase.auth.admin.deleteUser(userId);
    } catch (error) {
      if (kDebugMode) {
        print('ProfileService: Error deleting account: $error');
      }
      throw Exception('Failed to delete account');
    }
  }

  /// Export user data
  Future<Map<String, dynamic>> exportUserData(String userId) async {
    try {
      final List<Future> futures = [
        _supabase.from('profiles').select().eq('id', userId).maybeSingle(),
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
        print('ProfileService: Error exporting user data: $error');
      }
      throw Exception('Failed to export user data');
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