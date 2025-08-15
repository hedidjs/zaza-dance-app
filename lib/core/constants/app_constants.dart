class AppConstants {
  // App info
  static const String appName = 'זזה דאנס';
  static const String appDescription = 'בית דיגיטלי לקהילת חוג ההיפ הופ';
  
  // Database
  static const String supabaseUrl = https://yyvoavzgapsyycjwirmg.supabase.co;
  static const String supabaseAnonKey = eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl5dm9hdnpnYXBzeXljandpcm1nIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUyOTgyMzgsImV4cCI6MjA3MDg3NDIzOH0.IU_dW_8K-yuV1grWIWJdetU7jK-b-QDPFYp_m5iFP90;
  
  // Storage buckets
  static const String profileImagesBucket = 'profile-images';
  static const String galleryMediaBucket = 'gallery-media';
  static const String tutorialVideosBucket = 'tutorial-videos';
  static const String tutorialThumbnailsBucket = 'tutorial-thumbnails';
  static const String updateImagesBucket = 'update-images';
  
  // File size limits (in bytes)
  static const int maxProfileImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxGalleryMediaSize = 50 * 1024 * 1024; // 50MB
  static const int maxTutorialVideoSize = 100 * 1024 * 1024; // 100MB
  static const int maxThumbnailSize = 2 * 1024 * 1024; // 2MB
  static const int maxUpdateImageSize = 10 * 1024 * 1024; // 10MB
}