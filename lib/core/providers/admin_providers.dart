import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/push_notification_service.dart';
import '../services/performance_service.dart';
import '../services/notification_service.dart';
import '../../features/admin/services/admin_user_service.dart';
import '../../features/admin/services/content_upload_service.dart';
import '../../features/admin/services/news_service.dart';
import '../../features/admin/services/admin_analytics_service.dart';
import '../../features/admin/models/admin_stats_model.dart';
import '../../shared/models/user_model.dart';
import '../../shared/models/update_model.dart';
import 'data_providers.dart';

// Service providers that are needed for admin services
final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  return PushNotificationService();
});

final performanceServiceProvider = Provider<PerformanceService>((ref) {
  return PerformanceService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// MARK: - Admin Service Providers

/// Content Upload Service Provider
final contentUploadServiceProvider = Provider<ContentUploadService>((ref) {
  return ContentUploadService();
});

/// News Service Provider
final newsServiceProvider = Provider<NewsService>((ref) {
  return NewsService(
    supabase: Supabase.instance.client,
    pushNotificationService: ref.read(pushNotificationServiceProvider),
    performanceService: ref.read(performanceServiceProvider),
    notificationService: ref.read(notificationServiceProvider),
  );
});

// MARK: - Admin Data Providers

/// Dashboard Stats Provider
final dashboardStatsProvider = FutureProvider<AdminStatsModel>((ref) async {
  try {
    return await AdminAnalyticsService.getDashboardStats();
  } catch (error) {
    throw Exception('שגיאה בטעינת סטטיסטיקות: $error');
  }
});

/// All Users Provider (for admin management)
final allUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  try {
    final result = await AdminUserService.getAllUsers();
    if (result.isSuccess && result.data != null) {
      return result.data!;
    } else {
      throw Exception(result.message ?? 'שגיאה בטעינת משתמשים');
    }
  } catch (error) {
    throw Exception('שגיאה בטעינת נתוני משתמשים: $error');
  }
});

/// User Search Provider
final userSearchProvider = FutureProvider.family<List<UserModel>, String>((ref, query) async {
  if (query.trim().isEmpty) {
    return [];
  }
  
  try {
    final result = await AdminUserService.getAllUsers(searchQuery: query.trim());
    if (result.isSuccess && result.data != null) {
      return result.data!;
    } else {
      throw Exception(result.message ?? 'שגיאה בחיפוש משתמשים');
    }
  } catch (error) {
    throw Exception('שגיאה בחיפוש: $error');
  }
});

// MARK: - Admin Mutation Providers

/// Create User Provider
final createUserProvider = StateNotifierProvider<CreateUserNotifier, AsyncValue<UserModel?>>((ref) {
  return CreateUserNotifier(ref);
});

class CreateUserNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  CreateUserNotifier(this._ref) : super(const AsyncValue.data(null));
  
  final Ref _ref;
  
  Future<void> createUser({
    required String email,
    required String displayName,
    String role = 'student',
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await AdminUserService.createUser(
        email: email,
        displayName: displayName,
        role: role,
      );
      if (result.isSuccess) {
        state = AsyncValue.data(result.data);
        // Refresh the users list
        _ref.invalidate(allUsersProvider);
      } else {
        throw Exception(result.message);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// Update User Provider
final updateUserProvider = StateNotifierProvider<UpdateUserNotifier, AsyncValue<UserModel?>>((ref) {
  return UpdateUserNotifier(ref);
});

class UpdateUserNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  UpdateUserNotifier(this._ref) : super(const AsyncValue.data(null));
  
  final Ref _ref;
  
  Future<void> updateUser({
    required String userId,
    String? displayName,
    String? role,
    bool? isActive,
  }) async {
    state = const AsyncValue.loading();
    try {
      final updates = <String, dynamic>{};
      if (displayName != null) updates['display_name'] = displayName;
      if (role != null) updates['role'] = role;
      if (isActive != null) updates['is_active'] = isActive;
      
      final result = await AdminUserService.updateUser(userId, updates);
      if (result.isSuccess) {
        state = AsyncValue.data(result.data);
        // Refresh the users list
        _ref.invalidate(allUsersProvider);
      } else {
        throw Exception(result.message);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// Delete User Provider
final deleteUserProvider = StateNotifierProvider<DeleteUserNotifier, AsyncValue<bool>>((ref) {
  return DeleteUserNotifier(ref);
});

class DeleteUserNotifier extends StateNotifier<AsyncValue<bool>> {
  DeleteUserNotifier(this._ref) : super(const AsyncValue.data(false));
  
  final Ref _ref;
  
  Future<void> deleteUser(String userId) async {
    state = const AsyncValue.loading();
    try {
      final result = await AdminUserService.deleteUser(userId);
      if (result.isSuccess) {
        state = const AsyncValue.data(true);
        // Refresh the users list
        _ref.invalidate(allUsersProvider);
      } else {
        throw Exception(result.message);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// Create Update Provider
final createUpdateProvider = StateNotifierProvider<CreateUpdateNotifier, AsyncValue<UpdateModel?>>((ref) {
  final newsService = ref.read(newsServiceProvider);
  return CreateUpdateNotifier(newsService, ref);
});

class CreateUpdateNotifier extends StateNotifier<AsyncValue<UpdateModel?>> {
  CreateUpdateNotifier(this._newsService, this._ref) : super(const AsyncValue.data(null));
  
  final NewsService _newsService;
  final Ref _ref;
  
  Future<void> createUpdate({
    required String title,
    required String content,
    String? imageUrl,
    bool isImportant = false,
    DateTime? publishAt,
  }) async {
    state = const AsyncValue.loading();
    try {
      final update = await _newsService.createUpdate(
        title: title,
        content: content,
        imageUrl: imageUrl,
        isImportant: isImportant,
        publishAt: publishAt,
      );
      state = AsyncValue.data(update);
      
      // Refresh the updates list
      _ref.invalidate(updatesProvider);
      _ref.invalidate(pinnedUpdatesProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// Publish Update Provider
final publishUpdateProvider = StateNotifierProvider<PublishUpdateNotifier, AsyncValue<UpdateModel?>>((ref) {
  final newsService = ref.read(newsServiceProvider);
  return PublishUpdateNotifier(newsService, ref);
});

class PublishUpdateNotifier extends StateNotifier<AsyncValue<UpdateModel?>> {
  PublishUpdateNotifier(this._newsService, this._ref) : super(const AsyncValue.data(null));
  
  final NewsService _newsService;
  final Ref _ref;
  
  Future<void> publishUpdate(String updateId) async {
    state = const AsyncValue.loading();
    try {
      final updatedUpdate = await _newsService.publishUpdate(updateId);
      state = AsyncValue.data(updatedUpdate);
      
      // Refresh the updates list
      _ref.invalidate(updatesProvider);
      _ref.invalidate(pinnedUpdatesProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// Admin Refresh Controller - refreshes all main app data
final adminRefreshProvider = StateNotifierProvider<AdminRefreshNotifier, bool>((ref) {
  return AdminRefreshNotifier(ref);
});

class AdminRefreshNotifier extends StateNotifier<bool> {
  AdminRefreshNotifier(this._ref) : super(false);
  
  final Ref _ref;
  
  /// Refresh all gallery data
  void refreshGallery() {
    _ref.invalidate(galleryItemsProvider);
    _ref.invalidate(featuredGalleryProvider);
  }
  
  /// Refresh all tutorial data
  void refreshTutorials() {
    _ref.invalidate(tutorialsProvider);
    _ref.invalidate(featuredTutorialsProvider);
  }
  
  /// Refresh all update data
  void refreshUpdates() {
    _ref.invalidate(updatesProvider);
    _ref.invalidate(pinnedUpdatesProvider);
  }
  
  /// Refresh all categories
  void refreshCategories() {
    _ref.invalidate(categoriesProvider);
  }
  
  /// Refresh all app data
  void refreshAll() {
    refreshGallery();
    refreshTutorials();
    refreshUpdates();
    refreshCategories();
    _ref.invalidate(dashboardStatsProvider);
    state = !state; // Trigger rebuild
  }
}