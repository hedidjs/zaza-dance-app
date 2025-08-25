/// Test data fixtures for Zaza Dance integration tests
class TestData {
  
  // Test user credentials
  static const Map<String, dynamic> testUser = {
    'email': 'test@zazadance.com',
    'password': 'TestPassword123!',
    'name': 'משתמש בדיקה',
    'phone': '0501234567',
  };

  static const Map<String, dynamic> adminUser = {
    'email': 'admin@zazadance.com',
    'password': 'AdminPassword123!',
    'name': 'אדמין בדיקה',
    'phone': '0509876543',
  };

  // Test categories
  static const List<Map<String, dynamic>> testCategories = [
    {
      'id': 'test-category-beginners',
      'name': 'בגינרים',
      'icon': 'beginner',
      'description': 'שיעורים לבגינרים',
      'order_index': 0,
      'is_active': true,
    },
    {
      'id': 'test-category-intermediate',
      'name': 'בינוניים',
      'icon': 'intermediate',
      'description': 'שיעורים לרמה בינונית',
      'order_index': 1,
      'is_active': true,
    },
    {
      'id': 'test-category-advanced',
      'name': 'מתקדמים',
      'icon': 'advanced',
      'description': 'שיעורים למתקדמים',
      'order_index': 2,
      'is_active': true,
    },
  ];

  // Test gallery items
  static const List<Map<String, dynamic>> testGalleryItems = [
    {
      'id': 'test-gallery-video-1',
      'title': 'סרטון ריקוד בגינרים',
      'description': 'סרטון ראשון לבגינרים בהיפ הופ',
      'media_url': 'https://storage.googleapis.com/test-bucket/video1.mp4',
      'thumbnail_url': 'https://storage.googleapis.com/test-bucket/thumb1.jpg',
      'media_type': 'video',
      'category_id': 'test-category-beginners',
      'duration': 120,
      'order_index': 0,
      'is_published': true,
      'view_count': 150,
      'created_at': '2024-01-15T10:00:00Z',
    },
    {
      'id': 'test-gallery-image-1',
      'title': 'תמונה מהשיעור השבועי',
      'description': 'תמונה מהשיעור השבועי - קבוצת בגינרים',
      'media_url': 'https://storage.googleapis.com/test-bucket/image1.jpg',
      'thumbnail_url': 'https://storage.googleapis.com/test-bucket/image1.jpg',
      'media_type': 'image',
      'category_id': 'test-category-beginners',
      'order_index': 1,
      'is_published': true,
      'view_count': 89,
      'created_at': '2024-01-14T14:30:00Z',
    },
    {
      'id': 'test-gallery-video-2',
      'title': 'ריקוד מתקדמים',
      'description': 'סרטון עם תנועות מתקדמות',
      'media_url': 'https://storage.googleapis.com/test-bucket/video2.mp4',
      'thumbnail_url': 'https://storage.googleapis.com/test-bucket/thumb2.jpg',
      'media_type': 'video',
      'category_id': 'test-category-advanced',
      'duration': 240,
      'order_index': 0,
      'is_published': true,
      'view_count': 320,
      'created_at': '2024-01-13T16:45:00Z',
    },
  ];

  // Test tutorials
  static const List<Map<String, dynamic>> testTutorials = [
    {
      'id': 'test-tutorial-basic-1',
      'title': 'שיעור בסיסי - תנועות ראשונות',
      'description': 'שיעור בסיסי הכולל תנועות היפ הופ בסיסיות לבגינרים',
      'video_url': 'https://storage.googleapis.com/test-bucket/tutorial1.mp4',
      'thumbnail_url': 'https://storage.googleapis.com/test-bucket/tutorial-thumb1.jpg',
      'duration': 900, // 15 minutes
      'difficulty_level': 'beginner',
      'category_id': 'test-category-beginners',
      'instructor_name': 'מורה דנה',
      'instructor_bio': 'מורה מנוסה עם 10 שנות ניסיון',
      'tags': ['בסיסי', 'תנועות', 'היפ הופ'],
      'order_index': 0,
      'is_published': true,
      'view_count': 456,
      'like_count': 23,
      'created_at': '2024-01-10T09:00:00Z',
    },
    {
      'id': 'test-tutorial-basic-2',
      'title': 'שיעור בסיסי - קואורדינציה',
      'description': 'למידת קואורדינציה בסיסית בין זרועות ורגליים',
      'video_url': 'https://storage.googleapis.com/test-bucket/tutorial2.mp4',
      'thumbnail_url': 'https://storage.googleapis.com/test-bucket/tutorial-thumb2.jpg',
      'duration': 720, // 12 minutes
      'difficulty_level': 'beginner',
      'category_id': 'test-category-beginners',
      'instructor_name': 'מורה רון',
      'instructor_bio': 'מתמחה בלימוד בגינרים',
      'tags': ['קואורדינציה', 'בסיסי'],
      'order_index': 1,
      'is_published': true,
      'view_count': 334,
      'like_count': 18,
      'created_at': '2024-01-11T11:30:00Z',
    },
    {
      'id': 'test-tutorial-intermediate-1',
      'title': 'שיעור בינוני - קומבינציות',
      'description': 'קומבינציות תנועות ברמה בינונית',
      'video_url': 'https://storage.googleapis.com/test-bucket/tutorial3.mp4',
      'thumbnail_url': 'https://storage.googleapis.com/test-bucket/tutorial-thumb3.jpg',
      'duration': 1200, // 20 minutes
      'difficulty_level': 'intermediate',
      'category_id': 'test-category-intermediate',
      'instructor_name': 'מורה שירה',
      'instructor_bio': 'מורה מובילה ברמה בינונית ומתקדמת',
      'tags': ['קומבינציות', 'בינוני'],
      'order_index': 0,
      'is_published': true,
      'view_count': 278,
      'like_count': 31,
      'created_at': '2024-01-12T15:00:00Z',
    },
    {
      'id': 'test-tutorial-advanced-1',
      'title': 'שיעור מתקדמים - פריסטייל',
      'description': 'טכניקות פריסטייל ואלתור במוזיקה',
      'video_url': 'https://storage.googleapis.com/test-bucket/tutorial4.mp4',
      'thumbnail_url': 'https://storage.googleapis.com/test-bucket/tutorial-thumb4.jpg',
      'duration': 1800, // 30 minutes
      'difficulty_level': 'advanced',
      'category_id': 'test-category-advanced',
      'instructor_name': 'מורה עמית',
      'instructor_bio': 'רקדן מקצועי ומורה לפריסטייל',
      'tags': ['פריסטייל', 'מתקדמים', 'אלתור'],
      'order_index': 0,
      'is_published': true,
      'view_count': 167,
      'like_count': 45,
      'created_at': '2024-01-13T17:30:00Z',
    },
  ];

  // Test updates/news
  static const List<Map<String, dynamic>> testUpdates = [
    {
      'id': 'test-update-registration',
      'title': 'פתיחת הרשמה לשיעורים חדשים!',
      'content': '''
נפתחה ההרשמה לשיעורים החדשים לחודש הבא!

🔥 שיעורים זמינים:
• בגינרים - ימי ראשון ושלישי 19:00
• בינוניים - ימי שני ורביעי 20:00  
• מתקדמים - ימי חמישי 21:00

📱 להרשמה צרו קשר בווטסאפ או בטלפון
💰 מחירים מיוחדים לחברי הקהילה
      ''',
      'image_url': 'https://storage.googleapis.com/test-bucket/update1.jpg',
      'category': 'registration',
      'is_pinned': true,
      'is_published': true,
      'author': 'אדמין החוג',
      'created_at': '2024-01-16T12:00:00Z',
      'updated_at': '2024-01-16T12:00:00Z',
    },
    {
      'id': 'test-update-event',
      'title': 'ערב ריקודים מיוחד השבוע!',
      'content': '''
מזמינים אתכם לערב ריקודים מיוחד 🎉

📅 תאריך: יום שישי הקרוב
🕰️ שעה: 20:00
📍 מקום: האולם הגדול
🎵 מוזיקה: DJ מיוחד + נגינה חיה

כניסה חופשית לכל תלמידי החוג!
הבאו את החברים והמשפחה 🥳
      ''',
      'image_url': 'https://storage.googleapis.com/test-bucket/update2.jpg',
      'category': 'event',
      'is_pinned': false,
      'is_published': true,
      'author': 'צוות החוג',
      'created_at': '2024-01-15T15:30:00Z',
      'updated_at': '2024-01-15T15:30:00Z',
    },
    {
      'id': 'test-update-achievement',
      'title': 'הישג מיוחד לתלמידי החוג!',
      'content': '''
גאים להודיע על הישג מיוחד! 🏆

תלמידי החוג שלנו זכו במקום השני 
בתחרות הריקוד האזורית!

👏 מזל טוב לכל המשתתפים:
• קבוצת הבגינרים - מקום 3
• קבוצת הבינוניים - מקום 2
• קבוצת המתקדמים - מקום 1

אנחנו גאים בכולכם! 💪
      ''',
      'image_url': 'https://storage.googleapis.com/test-bucket/update3.jpg',
      'category': 'achievement',
      'is_pinned': false,
      'is_published': true,
      'author': 'הנהלת החוג',
      'created_at': '2024-01-14T18:00:00Z',
      'updated_at': '2024-01-14T18:00:00Z',
    },
  ];

  // Test user preferences
  static const Map<String, dynamic> testUserPreferences = {
    'language': 'he',
    'notifications_enabled': true,
    'auto_play_videos': false,
    'download_quality': 'high',
    'theme_mode': 'dark',
    'tutorial_autoplay': true,
    'show_subtitles': false,
  };

  // Test search queries
  static const List<String> testSearchQueries = [
    'ריקוד',
    'בגינרים',
    'היפ הופ',
    'שיעור',
    'תנועות',
    'בסיסי',
    'מתקדמים',
    'קואורדינציה',
  ];

  // Test error scenarios
  static const Map<String, dynamic> testErrorScenarios = {
    'network_error': {
      'type': 'NetworkException',
      'message': 'בעיה בחיבור לאינטרנט',
      'code': 'NETWORK_ERROR',
    },
    'auth_error': {
      'type': 'AuthException',
      'message': 'שם משתמש או סיסמה שגויים',
      'code': 'INVALID_CREDENTIALS',
    },
    'server_error': {
      'type': 'ServerException',
      'message': 'שגיאה בשרת, נסה שוב מאוחר יותר',
      'code': 'SERVER_ERROR',
    },
    'validation_error': {
      'type': 'ValidationException',
      'message': 'נתונים לא תקינים',
      'code': 'VALIDATION_ERROR',
    },
  };

  // Test performance benchmarks
  static const Map<String, int> performanceBenchmarks = {
    'app_startup_max_ms': 3000,
    'page_navigation_max_ms': 2000,
    'video_load_max_ms': 5000,
    'image_load_max_ms': 3000,
    'search_response_max_ms': 1500,
    'api_response_max_ms': 2000,
  };

  // Test device configurations
  static const List<Map<String, dynamic>> testDeviceConfigurations = [
    {
      'name': 'iPhone 12',
      'platform': 'iOS',
      'screen_width': 390,
      'screen_height': 844,
      'pixel_ratio': 3.0,
    },
    {
      'name': 'Samsung Galaxy S21',
      'platform': 'Android',
      'screen_width': 384,
      'screen_height': 854,
      'pixel_ratio': 2.75,
    },
    {
      'name': 'iPad Air',
      'platform': 'iOS',
      'screen_width': 820,
      'screen_height': 1180,
      'pixel_ratio': 2.0,
    },
  ];

  // Test accessibility scenarios
  static const Map<String, dynamic> accessibilityTestScenarios = {
    'screen_reader': {
      'enabled': true,
      'expected_semantic_labels': [
        'דף הבית',
        'גלריה',
        'שיעורים',
        'עדכונים',
        'פרופיל',
      ],
    },
    'high_contrast': {
      'enabled': true,
      'min_contrast_ratio': 4.5,
    },
    'large_text': {
      'enabled': true,
      'text_scale_factor': 1.5,
    },
  };

  // Helper methods to get test data
  static Map<String, dynamic> getTestUser() => Map.from(testUser);
  static Map<String, dynamic> getAdminUser() => Map.from(adminUser);
  
  static List<Map<String, dynamic>> getTestCategories() =>
      testCategories.map((e) => Map<String, dynamic>.from(e)).toList();
      
  static List<Map<String, dynamic>> getTestGalleryItems() =>
      testGalleryItems.map((e) => Map<String, dynamic>.from(e)).toList();
      
  static List<Map<String, dynamic>> getTestTutorials() =>
      testTutorials.map((e) => Map<String, dynamic>.from(e)).toList();
      
  static List<Map<String, dynamic>> getTestUpdates() =>
      testUpdates.map((e) => Map<String, dynamic>.from(e)).toList();

  // Get filtered test data
  static List<Map<String, dynamic>> getTutorialsByDifficulty(String difficulty) {
    return testTutorials
        .where((tutorial) => tutorial['difficulty_level'] == difficulty)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  static List<Map<String, dynamic>> getGalleryItemsByType(String mediaType) {
    return testGalleryItems
        .where((item) => item['media_type'] == mediaType)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  static List<Map<String, dynamic>> getContentByCategory(String categoryId) {
    final galleries = testGalleryItems
        .where((item) => item['category_id'] == categoryId)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
        
    final tutorials = testTutorials
        .where((tutorial) => tutorial['category_id'] == categoryId)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
        
    return [...galleries, ...tutorials];
  }

  // Validation helpers
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= 8 &&
           RegExp(r'[A-Z]').hasMatch(password) &&
           RegExp(r'[a-z]').hasMatch(password) &&
           RegExp(r'[0-9]').hasMatch(password);
  }

  static bool isValidPhoneNumber(String phone) {
    return RegExp(r'^05[0-9]{8}$').hasMatch(phone);
  }
}