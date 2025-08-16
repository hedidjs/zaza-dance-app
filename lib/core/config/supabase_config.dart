import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase configuration for Zaza Dance app
class SupabaseConfig {
  static const String supabaseUrl = 'https://yyvoavzgapsyycjwirmg.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl5dm9hdnpnYXBzeXljandpcm1nIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUyOTgyMzgsImV4cCI6MjA3MDg3NDIzOH0.IU_dW_8K-yuV1grWIWJdetU7jK-b-QDPFYp_m5iFP90';
  
  /// Initialize Supabase client
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: false, // Set to true for development
    );
  }
  
  /// Get Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;
  
  /// Storage bucket names
  static const String avatarsBucket = 'avatars';
  static const String tutorialsBucket = 'tutorials';
  static const String galleryBucket = 'gallery';
  static const String thumbnailsBucket = 'thumbnails';
  static const String updatesBucket = 'updates';
  
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