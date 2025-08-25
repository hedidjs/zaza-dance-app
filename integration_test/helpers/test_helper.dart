import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TestHelper {
  static const String testEmail = 'test@zazadance.com';
  static const String testPassword = 'TestPassword123!';
  
  /// Setup test environment with test data and configurations
  Future<void> setupTestEnvironment() async {
    try {
      // Clear shared preferences
      SharedPreferences.setMockInitialValues({});
      
      // Initialize Supabase with test credentials if available
      try {
        await _initializeTestSupabase();
      } catch (e) {
        // Supabase might already be initialized
      }
      
      // Setup test data
      await _setupTestData();
      
      if (kDebugMode) {
        print('Test environment setup completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Test environment setup failed: $e');
      }
      // Continue with tests even if some setup fails
    }
  }

  /// Initialize Supabase for testing
  Future<void> _initializeTestSupabase() async {
    try {
      // Use environment variables or test defaults
      const supabaseUrl = String.fromEnvironment(
        'SUPABASE_URL',
        defaultValue: 'https://your-test-project.supabase.co',
      );
      const supabaseAnonKey = String.fromEnvironment(
        'SUPABASE_ANON_KEY',
        defaultValue: 'your-test-anon-key',
      );
      
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: kDebugMode,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Supabase initialization failed in test: $e');
      }
    }
  }

  /// Setup test data in database
  Future<void> _setupTestData() async {
    try {
      // Create test categories
      await _createTestCategories();
      
      // Create test gallery items
      await _createTestGalleryItems();
      
      // Create test tutorials
      await _createTestTutorials();
      
      // Create test updates
      await _createTestUpdates();
    } catch (e) {
      if (kDebugMode) {
        print('Test data setup failed: $e');
      }
    }
  }

  /// Create test categories
  Future<void> _createTestCategories() async {
    final testCategories = [
      {
        'id': 'test-category-1',
        'name': 'בגינרים',
        'icon': 'beginner',
        'order_index': 0,
        'is_active': true,
      },
      {
        'id': 'test-category-2', 
        'name': 'מתקדמים',
        'icon': 'advanced',
        'order_index': 1,
        'is_active': true,
      },
    ];

    try {
      for (final category in testCategories) {
        await Supabase.instance.client
            .from('categories')
            .upsert(category);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to create test categories: $e');
      }
    }
  }

  /// Create test gallery items
  Future<void> _createTestGalleryItems() async {
    final testGalleryItems = [
      {
        'id': 'test-gallery-1',
        'title': 'ריקוד בגינרים',
        'description': 'סרטון ריקוד לבגינרים',
        'media_url': 'https://example.com/test-video1.mp4',
        'thumbnail_url': 'https://example.com/test-thumb1.jpg',
        'media_type': 'video',
        'category_id': 'test-category-1',
        'order_index': 0,
        'is_published': true,
      },
      {
        'id': 'test-gallery-2',
        'title': 'תמונה מהשיעור',
        'description': 'תמונה מהשיעור השבועי',
        'media_url': 'https://example.com/test-image1.jpg',
        'thumbnail_url': 'https://example.com/test-image1.jpg',
        'media_type': 'image',
        'category_id': 'test-category-1',
        'order_index': 1,
        'is_published': true,
      },
    ];

    try {
      for (final item in testGalleryItems) {
        await Supabase.instance.client
            .from('gallery')
            .upsert(item);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to create test gallery items: $e');
      }
    }
  }

  /// Create test tutorials
  Future<void> _createTestTutorials() async {
    final testTutorials = [
      {
        'id': 'test-tutorial-1',
        'title': 'שיעור בסיסי',
        'description': 'שיעור בסיסי לבגינרים',
        'video_url': 'https://example.com/test-tutorial1.mp4',
        'thumbnail_url': 'https://example.com/test-tutorial-thumb1.jpg',
        'duration': 300,
        'difficulty_level': 'beginner',
        'category_id': 'test-category-1',
        'order_index': 0,
        'is_published': true,
      },
      {
        'id': 'test-tutorial-2',
        'title': 'טכניקות מתקדמות',
        'description': 'שיעור טכניקות מתקדמות',
        'video_url': 'https://example.com/test-tutorial2.mp4',
        'thumbnail_url': 'https://example.com/test-tutorial-thumb2.jpg',
        'duration': 600,
        'difficulty_level': 'advanced',
        'category_id': 'test-category-2',
        'order_index': 0,
        'is_published': true,
      },
    ];

    try {
      for (final tutorial in testTutorials) {
        await Supabase.instance.client
            .from('tutorials')
            .upsert(tutorial);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to create test tutorials: $e');
      }
    }
  }

  /// Create test updates
  Future<void> _createTestUpdates() async {
    final testUpdates = [
      {
        'id': 'test-update-1',
        'title': 'עדכון חדש',
        'content': 'זהו עדכון חדש מהחוג',
        'image_url': 'https://example.com/test-update1.jpg',
        'category': 'general',
        'is_published': true,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'test-update-2',
        'title': 'הרשמה לשיעורים',
        'content': 'פתחנו הרשמה לשיעורים חדשים',
        'image_url': 'https://example.com/test-update2.jpg',
        'category': 'registration',
        'is_published': true,
        'created_at': DateTime.now().toIso8601String(),
      },
    ];

    try {
      for (final update in testUpdates) {
        await Supabase.instance.client
            .from('updates')
            .upsert(update);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to create test updates: $e');
      }
    }
  }

  /// Simulate offline mode
  Future<void> simulateOfflineMode() async {
    // Note: In real implementation, you might use a network interceptor
    // or modify the HTTP client to simulate offline behavior
    if (kDebugMode) {
      print('Simulating offline mode');
    }
  }

  /// Simulate online mode  
  Future<void> simulateOnlineMode() async {
    if (kDebugMode) {
      print('Simulating online mode');
    }
  }

  /// Login with test user credentials
  Future<void> loginTestUser() async {
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: testEmail,
        password: testPassword,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Test user login failed: $e');
      }
    }
  }

  /// Logout current user
  Future<void> logoutUser() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('User logout failed: $e');
      }
    }
  }

  /// Clean up test data and state
  Future<void> cleanup() async {
    try {
      // Clear any temporary test data
      await _cleanupTestData();
      
      // Reset app state
      await _resetAppState();
      
      if (kDebugMode) {
        print('Test cleanup completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Test cleanup failed: $e');
      }
    }
  }

  /// Clean up test data from database
  Future<void> _cleanupTestData() async {
    try {
      // Delete test data (only if using test database)
      if (kDebugMode) {
        // Only cleanup in debug mode to prevent accidental data loss
        final testIds = [
          'test-category-1',
          'test-category-2',
          'test-gallery-1', 
          'test-gallery-2',
          'test-tutorial-1',
          'test-tutorial-2',
          'test-update-1',
          'test-update-2',
        ];
        
        // Note: In production, ensure this only runs against test database
        for (final id in testIds) {
          await Supabase.instance.client
              .from('categories')
              .delete()
              .eq('id', id);
              
          await Supabase.instance.client
              .from('gallery')
              .delete()
              .eq('id', id);
              
          await Supabase.instance.client
              .from('tutorials')
              .delete()
              .eq('id', id);
              
          await Supabase.instance.client
              .from('updates')
              .delete()
              .eq('id', id);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to cleanup test data: $e');
      }
    }
  }

  /// Reset app state
  Future<void> _resetAppState() async {
    try {
      // Clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Logout any authenticated user
      await logoutUser();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to reset app state: $e');
      }
    }
  }

  /// Wait for widget with timeout
  Future<void> waitForWidget(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final endTime = DateTime.now().add(timeout);
    
    while (DateTime.now().isBefore(endTime)) {
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      
      if (finder.evaluate().isNotEmpty) {
        return;
      }
      
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    throw TimeoutException(
      'Widget not found within timeout: ${finder.toString()}',
      timeout,
    );
  }
}

class TimeoutException implements Exception {
  final String message;
  final Duration timeout;
  
  const TimeoutException(this.message, this.timeout);
  
  @override
  String toString() => 'TimeoutException: $message (timeout: $timeout)';
}