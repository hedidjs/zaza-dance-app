import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

/// Service for handling push notifications and local notifications
/// According to PRD: Important announcements and reminders
class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  BuildContext? _context;

  /// Set the global context for navigation
  void setContext(BuildContext context) {
    _context = context;
  }

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize local notifications
      await _initializeLocalNotifications();

      // Request permissions
      await _requestPermissions();

      _isInitialized = true;
      if (kDebugMode) {
        print('PushNotificationService initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing PushNotificationService: $e');
      }
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    // Request permissions for iOS
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    // Request permissions for Android 13+
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse notificationResponse) {
    try {
      final payload = notificationResponse.payload;
      if (payload != null) {
        final data = jsonDecode(payload);
        _handleNotificationNavigation(data);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling notification tap: $e');
      }
    }
  }

  /// Handle navigation based on notification data
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final targetId = data['targetId'] as String?;

    if (kDebugMode) {
      print('Navigating to: $type with ID: $targetId');
    }

    if (_context == null || !_context!.mounted) {
      if (kDebugMode) {
        print('Context not available for navigation');
      }
      return;
    }

    try {
      switch (type) {
        case 'tutorial':
          // נווט לעמוד הטוטוריאלים
          _context!.go('/tutorials');
          break;
        case 'update':
          // נווט לעמוד העדכונים
          _context!.go('/updates');
          break;
        case 'event':
          // נווט לעמוד העדכונים (שם מוצגים גם האירועים)
          _context!.go('/updates');
          break;
        case 'gallery':
          // נווט לגלריה
          _context!.go('/gallery');
          break;
        case 'profile':
          // נווט לפרופיל
          _context!.go('/profile');
          break;
        case 'settings':
          // נווט להגדרות
          _context!.go('/settings');
          break;
        default:
          // במקרה של סוג לא ידוע, נווט לעמוד הבית
          _context!.go('/home');
          break;
      }

      if (kDebugMode) {
        print('Successfully navigated to $type');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error navigating from notification: $e');
      }
      // במקרה של שגיאה, נווט לעמוד הבית
      try {
        _context!.go('/home');
      } catch (navError) {
        if (kDebugMode) {
          print('Failed to navigate to home: $navError');
        }
      }
    }
  }

  /// Show notification for new tutorial
  Future<void> showNewTutorialNotification({
    required String tutorialTitle,
    required String tutorialId,
  }) async {
    if (!_isInitialized) await initialize();

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'tutorials',
        'חדשות טוטוריאלים',
        channelDescription: 'התראות על טוטוריאלים חדשים',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFFFF00FF), // Neon pink
      ),
      iOS: DarwinNotificationDetails(
        categoryIdentifier: 'tutorials',
      ),
    );

    final payload = jsonEncode({
      'type': 'tutorial',
      'targetId': tutorialId,
    });

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      '🎵 טוטוריאל חדש זמין!',
      'למד את "$tutorialTitle" עכשיו',
      notificationDetails,
      payload: payload,
    );
  }

  /// Show notification for gallery updates
  Future<void> showGalleryUpdateNotification({
    required String galleryTitle,
    required String galleryId,
  }) async {
    if (!_isInitialized) await initialize();

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'gallery',
        'עדכוני גלריה',
        channelDescription: 'התראות על תמונות וסרטונים חדשים',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF9C27B0), // Neon purple
      ),
      iOS: DarwinNotificationDetails(
        categoryIdentifier: 'gallery',
      ),
    );

    final payload = jsonEncode({
      'type': 'gallery',
      'targetId': galleryId,
    });

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      '📸 תמונות חדשות בגלריה!',
      galleryTitle,
      notificationDetails,
      payload: payload,
    );
  }

  /// Show notification for studio updates
  Future<void> showStudioUpdateNotification({
    required String updateTitle,
    required String updateId,
    bool isImportant = false,
  }) async {
    if (!_isInitialized) await initialize();

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        isImportant ? 'important_updates' : 'general_updates',
        isImportant ? 'עדכונים חשובים' : 'עדכוני הסטודיו',
        channelDescription: isImportant 
            ? 'עדכונים חשובים מהסטודיו'
            : 'עדכונים כלליים מהסטודיו',
        importance: isImportant ? Importance.max : Importance.high,
        priority: isImportant ? Priority.max : Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF00FFFF), // Neon turquoise
      ),
      iOS: DarwinNotificationDetails(
        categoryIdentifier: 'updates',
      ),
    );

    final payload = jsonEncode({
      'type': 'update',
      'targetId': updateId,
    });

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      isImportant ? '🔥 עדכון חשוב!' : '📢 עדכון חדש',
      updateTitle,
      notificationDetails,
      payload: payload,
    );
  }

  /// Show notification for student achievements
  Future<void> showAchievementNotification({
    required String studentName,
    required String achievement,
  }) async {
    if (!_isInitialized) await initialize();

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'achievements',
        'הישגי תלמידים',
        channelDescription: 'התראות על הישגים מיוחדים',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFFE91E63), // Pink
      ),
      iOS: DarwinNotificationDetails(
        categoryIdentifier: 'achievements',
      ),
    );

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      '⭐ הישג מדהים!',
      '$studentName: $achievement',
      notificationDetails,
    );
  }

  /// Show notification for upcoming events
  Future<void> showEventNotification({
    required String eventTitle,
    required DateTime eventDate,
    required String eventId,
  }) async {
    if (!_isInitialized) await initialize();

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'events',
        'אירועים',
        channelDescription: 'התראות על אירועים קרובים',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF9C27B0), // Purple
      ),
      iOS: DarwinNotificationDetails(
        categoryIdentifier: 'events',
      ),
    );

    final payload = jsonEncode({
      'type': 'event',
      'targetId': eventId,
    });

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      '🎉 אירוע קרוב!',
      eventTitle,
      notificationDetails,
      payload: payload,
    );
  }

  /// Schedule weekly reminder notification
  Future<void> scheduleWeeklyReminder() async {
    if (!_isInitialized) await initialize();

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'reminders',
        'תזכורות',
        channelDescription: 'תזכורות קבועות לתרגול',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF40E0D0), // Turquoise
      ),
      iOS: DarwinNotificationDetails(
        categoryIdentifier: 'reminders',
      ),
    );

    // Schedule for every Tuesday at 7 PM (popular time for dance classes)
    await _flutterLocalNotificationsPlugin.periodicallyShow(
      1, // notification id
      '💃 זמן לתרגל!',
      'בואו נתרגל יחד את הטוטוריאלים החדשים',
      RepeatInterval.weekly,
      notificationDetails,
    );
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Get pending notifications count
  Future<int> getPendingNotificationsCount() async {
    final pending = await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return pending.length;
  }
}