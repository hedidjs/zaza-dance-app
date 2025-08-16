import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

/// Provider for admin user management
final adminUsersProvider = StateNotifierProvider<AdminUsersNotifier, AsyncValue<List<UserModel>>>(
  (ref) => AdminUsersNotifier(),
);

/// Provider for analytics data
final analyticsProvider = StateNotifierProvider<AnalyticsNotifier, AsyncValue<List<Map<String, dynamic>>>>(
  (ref) => AnalyticsNotifier(),
);

/// Provider for user progress data
final userProgressProvider = FutureProvider.family<List<Map<String, dynamic>>, String>(
  (ref, userId) async {
    return await DatabaseService.getUserProgress(userId);
  },
);

/// Notifier for admin user management
class AdminUsersNotifier extends StateNotifier<AsyncValue<List<UserModel>>> {
  AdminUsersNotifier() : super(const AsyncValue.loading()) {
    loadUsers();
  }

  /// Load all users
  Future<void> loadUsers({
    String? role,
    String? searchQuery,
  }) async {
    try {
      state = const AsyncValue.loading();
      
      final users = await DatabaseService.getUsers(
        role: role,
        searchQuery: searchQuery,
        orderBy: 'created_at',
        ascending: false,
      );

      state = AsyncValue.data(users);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Delete user (mark as inactive)
  Future<bool> deleteUser(String userId) async {
    try {
      await DatabaseService.deleteUser(userId);
      
      // Reload users to reflect changes
      await loadUsers();
      
      return true;
    } catch (error) {
      return false;
    }
  }

  /// Refresh users list
  Future<void> refresh() async {
    await loadUsers();
  }
}

/// Notifier for analytics management
class AnalyticsNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  AnalyticsNotifier() : super(const AsyncValue.loading()) {
    loadAnalytics();
  }

  /// Load analytics data
  Future<void> loadAnalytics({
    String? eventType,
    String? contentType,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      state = const AsyncValue.loading();
      
      final analytics = await DatabaseService.getAnalytics(
        eventType: eventType,
        contentType: contentType,
        startDate: startDate,
        endDate: endDate,
        limit: limit ?? 100,
      );

      state = AsyncValue.data(analytics);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Track analytics event
  Future<void> trackEvent({
    required String eventType,
    String? userId,
    String? contentId,
    String? contentType,
    Map<String, dynamic>? metadata,
    String? sessionId,
    Map<String, dynamic>? deviceInfo,
  }) async {
    try {
      await DatabaseService.trackEvent(
        eventType: eventType,
        userId: userId,
        contentId: contentId,
        contentType: contentType,
        metadata: metadata,
        sessionId: sessionId,
        deviceInfo: deviceInfo,
      );
    } catch (error) {
      // Ignore analytics tracking errors
    }
  }

  /// Refresh analytics
  Future<void> refresh() async {
    await loadAnalytics();
  }
}

/// Provider for likes functionality
final likesProvider = StateNotifierProvider<LikesNotifier, AsyncValue<void>>(
  (ref) => LikesNotifier(),
);

/// Notifier for likes management
class LikesNotifier extends StateNotifier<AsyncValue<void>> {
  LikesNotifier() : super(const AsyncValue.data(null));

  /// Toggle like for content
  Future<bool> toggleLike({
    required String userId,
    required String contentId,
    required String contentType,
  }) async {
    try {
      final result = await DatabaseService.toggleLike(
        userId: userId,
        contentId: contentId,
        contentType: contentType,
      );
      
      return result; // true if liked, false if unliked
    } catch (error) {
      return false;
    }
  }

  /// Check if user has liked content
  Future<bool> hasUserLiked({
    required String userId,
    required String contentId,
    required String contentType,
  }) async {
    try {
      return await DatabaseService.hasUserLiked(
        userId: userId,
        contentId: contentId,
        contentType: contentType,
      );
    } catch (error) {
      return false;
    }
  }
}

/// Provider for notifications
final notificationsProvider = StateNotifierProvider<NotificationsNotifier, AsyncValue<List<Map<String, dynamic>>>>(
  (ref) => NotificationsNotifier(),
);

/// Notifier for notifications management
class NotificationsNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  NotificationsNotifier() : super(const AsyncValue.loading());

  /// Load user notifications
  Future<void> loadNotifications({
    required String userId,
    bool? isRead,
    String? notificationType,
    int? limit,
  }) async {
    try {
      state = const AsyncValue.loading();
      
      final notifications = await DatabaseService.getUserNotifications(
        userId: userId,
        isRead: isRead,
        notificationType: notificationType,
        limit: limit,
      );

      state = AsyncValue.data(notifications);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await DatabaseService.markNotificationAsRead(notificationId);
      // Note: Should reload notifications or update state locally
    } catch (error) {
      // Handle error silently
    }
  }

  /// Create new notification
  Future<void> createNotification({
    required String titleHe,
    required String contentHe,
    required String userId,
    required String notificationType,
    String? actionUrl,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await DatabaseService.createNotification(
        titleHe: titleHe,
        contentHe: contentHe,
        userId: userId,
        notificationType: notificationType,
        actionUrl: actionUrl,
        imageUrl: imageUrl,
        metadata: metadata,
      );
    } catch (error) {
      // Handle error
    }
  }

  /// Refresh notifications
  Future<void> refresh(String userId) async {
    await loadNotifications(userId: userId);
  }
}