import 'package:supabase_flutter/supabase_flutter.dart';
import 'environment.dart';

/// Supabase configuration for Zaza Dance app
class SupabaseConfig {
  
  /// Initialize Supabase client
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: Environment.supabaseUrl,
      anonKey: Environment.supabaseAnonKey,
      debug: Environment.enableDebugLogs,
    );
  }
  
  /// Get Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;
  
  /// Storage bucket names (matching PRD requirements)
  static const String profileImagesBucket = 'profile-images';
  static const String galleryMediaBucket = 'gallery-media';
  static const String tutorialVideosBucket = 'tutorial-videos';
  static const String tutorialThumbnailsBucket = 'tutorial-thumbnails';
  static const String updateImagesBucket = 'update-images';
  
  /// Database table names
  static const String usersTable = 'users';
  static const String tutorialsTable = 'tutorials';
  static const String galleryItemsTable = 'gallery_items';
  static const String updatesTable = 'updates';
  static const String userProgressTable = 'user_progress';
  static const String analyticsTable = 'analytics';
  static const String notificationsTable = 'notifications';
  static const String userPreferencesTable = 'user_preferences';
  static const String likesTable = 'likes';
}