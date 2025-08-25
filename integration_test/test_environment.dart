import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'fixtures/test_data.dart';

/// Test environment configuration and setup
class TestEnvironment {
  static bool _isInitialized = false;
  static late String _supabaseUrl;
  static late String _supabaseAnonKey;

  /// Initialize test environment
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load test environment variables
      _loadEnvironmentVariables();
      
      // Initialize Supabase for testing
      await _initializeSupabase();
      
      // Setup test database
      await _setupTestDatabase();
      
      _isInitialized = true;
      
      if (kDebugMode) {
        print('✅ Test environment initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to initialize test environment: $e');
      }
      rethrow;
    }
  }

  /// Load environment variables for testing
  static void _loadEnvironmentVariables() {
    // Use test environment variables or defaults
    _supabaseUrl = const String.fromEnvironment(
      'SUPABASE_TEST_URL',
      defaultValue: 'https://your-test-project.supabase.co',
    );
    
    _supabaseAnonKey = const String.fromEnvironment(
      'SUPABASE_TEST_ANON_KEY',
      defaultValue: 'your-test-anon-key',
    );

    if (kDebugMode) {
      print('🔧 Using test Supabase URL: $_supabaseUrl');
    }
  }

  /// Initialize Supabase for testing
  static Future<void> _initializeSupabase() async {
    try {
      await Supabase.initialize(
        url: _supabaseUrl,
        anonKey: _supabaseAnonKey,
        debug: kDebugMode,
      );
      
      if (kDebugMode) {
        print('🔗 Supabase initialized for testing');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Supabase already initialized or failed: $e');
      }
    }
  }

  /// Setup test database with test data
  static Future<void> _setupTestDatabase() async {
    try {
      final supabase = Supabase.instance.client;
      
      // Create test categories
      await _setupTestCategories(supabase);
      
      // Create test gallery items
      await _setupTestGalleryItems(supabase);
      
      // Create test tutorials
      await _setupTestTutorials(supabase);
      
      // Create test updates
      await _setupTestUpdates(supabase);
      
      if (kDebugMode) {
        print('📊 Test database setup completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Test database setup failed: $e');
      }
      // Don't throw error - tests can run without database setup
    }
  }

  /// Setup test categories
  static Future<void> _setupTestCategories(SupabaseClient supabase) async {
    final categories = TestData.getTestCategories();
    
    for (final category in categories) {
      try {
        await supabase
            .from('categories')
            .upsert(category);
      } catch (e) {
        if (kDebugMode) {
          print('Failed to create test category ${category['id']}: $e');
        }
      }
    }
  }

  /// Setup test gallery items
  static Future<void> _setupTestGalleryItems(SupabaseClient supabase) async {
    final galleryItems = TestData.getTestGalleryItems();
    
    for (final item in galleryItems) {
      try {
        await supabase
            .from('gallery')
            .upsert(item);
      } catch (e) {
        if (kDebugMode) {
          print('Failed to create test gallery item ${item['id']}: $e');
        }
      }
    }
  }

  /// Setup test tutorials
  static Future<void> _setupTestTutorials(SupabaseClient supabase) async {
    final tutorials = TestData.getTestTutorials();
    
    for (final tutorial in tutorials) {
      try {
        await supabase
            .from('tutorials')
            .upsert(tutorial);
      } catch (e) {
        if (kDebugMode) {
          print('Failed to create test tutorial ${tutorial['id']}: $e');
        }
      }
    }
  }

  /// Setup test updates
  static Future<void> _setupTestUpdates(SupabaseClient supabase) async {
    final updates = TestData.getTestUpdates();
    
    for (final update in updates) {
      try {
        await supabase
            .from('updates')
            .upsert(update);
      } catch (e) {
        if (kDebugMode) {
          print('Failed to create test update ${update['id']}: $e');
        }
      }
    }
  }

  /// Create test user account
  static Future<User?> createTestUser() async {
    try {
      final testUser = TestData.getTestUser();
      final response = await Supabase.instance.client.auth.signUp(
        email: testUser['email'],
        password: testUser['password'],
        data: {
          'name': testUser['name'],
          'phone': testUser['phone'],
        },
      );
      
      if (kDebugMode) {
        print('👤 Test user created: ${testUser['email']}');
      }
      
      return response.user;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to create test user: $e');
      }
      return null;
    }
  }

  /// Login test user
  static Future<User?> loginTestUser() async {
    try {
      final testUser = TestData.getTestUser();
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: testUser['email'],
        password: testUser['password'],
      );
      
      if (kDebugMode) {
        print('🔑 Test user logged in: ${testUser['email']}');
      }
      
      return response.user;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to login test user: $e');
      }
      return null;
    }
  }

  /// Logout current user
  static Future<void> logoutUser() async {
    try {
      await Supabase.instance.client.auth.signOut();
      
      if (kDebugMode) {
        print('👋 User logged out');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to logout user: $e');
      }
    }
  }

  /// Clean up test environment
  static Future<void> cleanup() async {
    try {
      // Logout any authenticated user
      await logoutUser();
      
      // Clean up test data
      await _cleanupTestData();
      
      if (kDebugMode) {
        print('🧹 Test environment cleaned up');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to cleanup test environment: $e');
      }
    }
  }

  /// Clean up test data from database
  static Future<void> _cleanupTestData() async {
    if (!kDebugMode) {
      // Only cleanup in debug mode to prevent accidental data loss
      return;
    }

    try {
      final supabase = Supabase.instance.client;
      
      // Delete test data (only runs in debug mode)
      final testIds = [
        // Categories
        'test-category-beginners',
        'test-category-intermediate', 
        'test-category-advanced',
        // Gallery items
        'test-gallery-video-1',
        'test-gallery-image-1',
        'test-gallery-video-2',
        // Tutorials
        'test-tutorial-basic-1',
        'test-tutorial-basic-2',
        'test-tutorial-intermediate-1',
        'test-tutorial-advanced-1',
        // Updates
        'test-update-registration',
        'test-update-event',
        'test-update-achievement',
      ];
      
      // Clean up each table
      for (final id in testIds) {
        try {
          await supabase.from('categories').delete().eq('id', id);
          await supabase.from('gallery').delete().eq('id', id);
          await supabase.from('tutorials').delete().eq('id', id);
          await supabase.from('updates').delete().eq('id', id);
        } catch (e) {
          // Ignore individual cleanup errors
        }
      }
      
      if (kDebugMode) {
        print('🗑️ Test data cleaned up');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to cleanup test data: $e');
      }
    }
  }

  /// Reset app state to clean state
  static Future<void> resetAppState() async {
    try {
      // Clear any cached data
      // Note: Implementation depends on your caching strategy
      
      // Logout user
      await logoutUser();
      
      if (kDebugMode) {
        print('🔄 App state reset');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to reset app state: $e');
      }
    }
  }

  /// Simulate network conditions
  static Future<void> simulateNetworkCondition(NetworkCondition condition) async {
    // Note: This is a placeholder for network simulation
    // In real implementation, you might use tools like:
    // - Charles Proxy
    // - Network Link Conditioner
    // - Custom HTTP interceptors
    
    switch (condition) {
      case NetworkCondition.offline:
        if (kDebugMode) print('📵 Simulating offline mode');
        break;
      case NetworkCondition.slow:
        if (kDebugMode) print('🐌 Simulating slow network');
        break;
      case NetworkCondition.fast:
        if (kDebugMode) print('⚡ Simulating fast network');
        break;
    }
  }

  /// Check if environment is properly set up
  static bool get isInitialized => _isInitialized;
  
  /// Get current Supabase client
  static SupabaseClient get client => Supabase.instance.client;
  
  /// Get test configuration
  static Map<String, dynamic> get testConfiguration => {
    'supabase_url': _supabaseUrl,
    'is_debug': kDebugMode,
    'performance_benchmarks': TestData.performanceBenchmarks,
    'device_configurations': TestData.testDeviceConfigurations,
  };
}

/// Network condition types for simulation
enum NetworkCondition {
  offline,
  slow,
  fast,
}

/// Test environment exception
class TestEnvironmentException implements Exception {
  final String message;
  final dynamic originalError;
  
  const TestEnvironmentException(this.message, [this.originalError]);
  
  @override
  String toString() {
    return 'TestEnvironmentException: $message${originalError != null ? ' (Original: $originalError)' : ''}';
  }
}