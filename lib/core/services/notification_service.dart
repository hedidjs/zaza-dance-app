import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

/// Service for handling push notifications and local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  Function(String)? _onNotificationTap;

  /// Initialize notification service
  Future<void> initialize({Function(String)? onNotificationTap}) async {
    if (_isInitialized) return;

    _onNotificationTap = onNotificationTap;

    // Request permissions
    await _requestPermissions();

    // Initialize local notifications
    await _initializeLocalNotifications();

    _isInitialized = true;

    if (kDebugMode) {
      debugPrint('NotificationService initialized');
    }
  }

  /// Request notification permissions
  Future<bool> _requestPermissions() async {
    try {
      final status = await Permission.notification.request();
      
      if (status.isGranted) {
        if (kDebugMode) {
          debugPrint('Notification permission granted');
        }
        return true;
      } else {
        if (kDebugMode) {
          debugPrint('Notification permission denied');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error requesting notification permissions: $e');
      }
      return false;
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );

      // Create notification channels for Android
      await _createNotificationChannels();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error initializing local notifications: $e');
      }
    }
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    const channels = [
      AndroidNotificationChannel(
        'updates',
        'עדכונים',
        description: 'עדכונים חדשים מהסטודיו',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      ),
      AndroidNotificationChannel(
        'announcements',
        'הודעות',
        description: 'הודעות חשובות מהסטודיו',
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
      ),
      AndroidNotificationChannel(
        'achievements',
        'הישגים',
        description: 'הישגי תלמידים חדשים',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      ),
    ];

    for (final channel in channels) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  /// Handle notification tap
  void _onNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && _onNotificationTap != null) {
      _onNotificationTap!(payload);
    }
  }

  /// Show local notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    NotificationType type = NotificationType.update,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final notificationDetails = _getNotificationDetails(type);
      
      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      if (kDebugMode) {
        debugPrint('Notification shown: $title');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error showing notification: $e');
      }
    }
  }

  /// Schedule notification for later
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    NotificationType type = NotificationType.update,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final notificationDetails = _getNotificationDetails(type);
      
      await _localNotifications.zonedSchedule(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );

      if (kDebugMode) {
        debugPrint('Notification scheduled for: $scheduledDate');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error scheduling notification: $e');
      }
    }
  }

  /// Get notification details based on type
  NotificationDetails _getNotificationDetails(NotificationType type) {
    final androidDetails = AndroidNotificationDetails(
      _getChannelId(type),
      _getChannelName(type),
      channelDescription: _getChannelDescription(type),
      importance: Importance.high,
      priority: Priority.high,
      color: _getNotificationColor(type),
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: const BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  String _getChannelId(NotificationType type) {
    switch (type) {
      case NotificationType.announcement:
        return 'announcements';
      case NotificationType.achievement:
        return 'achievements';
      case NotificationType.update:
        return 'updates';
    }
  }

  String _getChannelName(NotificationType type) {
    switch (type) {
      case NotificationType.announcement:
        return 'הודעות';
      case NotificationType.achievement:
        return 'הישגים';
      case NotificationType.update:
        return 'עדכונים';
    }
  }

  String _getChannelDescription(NotificationType type) {
    switch (type) {
      case NotificationType.announcement:
        return 'הודעות חשובות מהסטודיו';
      case NotificationType.achievement:
        return 'הישגי תלמידים חדשים';
      case NotificationType.update:
        return 'עדכונים חדשים מהסטודיו';
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.announcement:
        return const Color(0xFFFF00FF); // Neon Pink
      case NotificationType.achievement:
        return const Color(0xFF40E0D0); // Neon Turquoise
      case NotificationType.update:
        return const Color(0xFF9C27B0); // Purple
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
      if (kDebugMode) {
        debugPrint('All notifications cancelled');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error cancelling notifications: $e');
      }
    }
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    try {
      await _localNotifications.cancel(id);
      if (kDebugMode) {
        debugPrint('Notification $id cancelled');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error cancelling notification $id: $e');
      }
    }
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _localNotifications.pendingNotificationRequests();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting pending notifications: $e');
      }
      return [];
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking notification status: $e');
      }
      return false;
    }
  }


  /// Check initialization status
  bool get isInitialized => _isInitialized;
}

/// Types of notifications
enum NotificationType {
  update,
  announcement,
  achievement,
}

/// Notification payload data
class NotificationPayload {
  final String type;
  final String id;
  final String route;
  final Map<String, dynamic>? data;

  const NotificationPayload({
    required this.type,
    required this.id,
    required this.route,
    this.data,
  });

  factory NotificationPayload.fromJson(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return NotificationPayload(
      type: json['type'] as String,
      id: json['id'] as String,
      route: json['route'] as String,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  String toJson() {
    return jsonEncode({
      'type': type,
      'id': id,
      'route': route,
      'data': data,
    });
  }
}