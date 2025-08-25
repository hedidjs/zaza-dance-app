/// Environment configuration for Zaza Dance app
class Environment {
  // Private constructor to prevent instantiation
  Environment._();
  
  /// Environment type
  static const bool isProduction = bool.fromEnvironment('PRODUCTION', defaultValue: false);
  static const bool isDevelopment = !isProduction;
  
  /// Supabase configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://yyvoavzgapsyycjwirmg.supabase.co',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl5dm9hdnpnYXBzeXljandpcm1nIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUyOTgyMzgsImV4cCI6MjA3MDg3NDIzOH0.IU_dW_8K-yuV1grWIWJdetU7jK-b-QDPFYp_m5iFP90',
  );
  
  /// App configuration
  static const String appName = 'זזה דאנס - Zaza Dance';
  static const String appVersion = '1.0.0';
  
  /// Contact information
  static const String contactPhone = '050-123-4567';
  static const String contactEmail = 'info@zazadance.co.il';
  static const String studioAddress = 'רחוב הריקוד 15, תל אביב';
  
  /// Social media links
  static const String instagramUrl = 'https://instagram.com/zazadance';
  static const String whatsappUrl = 'https://wa.me/972501234567';
  
  /// Deep link configuration
  static const String appScheme = 'com.zazadance.zazaDance';
  static const String webDomain = 'zazadance.com';
  
  /// Debug configuration
  static bool get enableDebugLogs => isDevelopment;
  static bool get enableAnalytics => isProduction;
}