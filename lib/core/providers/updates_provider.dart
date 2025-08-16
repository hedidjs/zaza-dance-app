import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/update_model.dart';
import '../services/database_service.dart';

/// Provider for updates service operations
final updatesProvider = StateNotifierProvider<UpdatesNotifier, AsyncValue<List<UpdateModel>>>(
  (ref) => UpdatesNotifier(),
);

/// Provider for pinned updates
final pinnedUpdatesProvider = FutureProvider<List<UpdateModel>>((ref) async {
  return await DatabaseService.getUpdates(
    isPinned: true,
    orderBy: 'created_at',
    ascending: false,
  );
});

/// Provider for updates by type
final updatesByTypeProvider = FutureProvider.family<List<UpdateModel>, String>(
  (ref, updateType) async {
    return await DatabaseService.getUpdates(
      updateType: updateType,
      orderBy: 'created_at',
      ascending: false,
    );
  },
);

/// Provider for recent updates
final recentUpdatesProvider = FutureProvider<List<UpdateModel>>((ref) async {
  return await DatabaseService.getUpdates(
    orderBy: 'created_at',
    ascending: false,
    limit: 10,
  );
});

/// Notifier for managing updates state
class UpdatesNotifier extends StateNotifier<AsyncValue<List<UpdateModel>>> {
  UpdatesNotifier() : super(const AsyncValue.loading()) {
    loadUpdates();
  }

  /// Load all updates
  Future<void> loadUpdates({
    String? updateType,
    String? searchQuery,
    bool? isActive,
    bool? isPinned,
  }) async {
    try {
      state = const AsyncValue.loading();
      
      final updates = await DatabaseService.getUpdates(
        updateType: updateType,
        searchQuery: searchQuery,
        isActive: isActive,
        isPinned: isPinned,
        orderBy: 'created_at',
        ascending: false,
      );

      state = AsyncValue.data(updates);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Create new update
  Future<UpdateModel?> createUpdate({
    required String titleHe,
    required String contentHe,
    String? summaryHe,
    required String updateType,
    String? authorId,
    bool isActive = true,
    bool isPinned = false,
    int priority = 1,
    String? imageUrl,
    DateTime? publishAt,
    DateTime? expiresAt,
    List<String>? tags,
  }) async {
    try {
      final newUpdate = await DatabaseService.createUpdate(
        titleHe: titleHe,
        contentHe: contentHe,
        summaryHe: summaryHe,
        updateType: updateType,
        authorId: authorId,
        isActive: isActive,
        isPinned: isPinned,
        priority: priority,
        imageUrl: imageUrl,
        publishAt: publishAt,
        expiresAt: expiresAt,
        tags: tags,
      );

      // Reload updates to include the new one
      await loadUpdates();
      
      return newUpdate;
    } catch (error) {
      return null;
    }
  }

  /// Increment update view count
  Future<void> incrementViews(String updateId) async {
    try {
      await DatabaseService.incrementUpdateViews(updateId);
    } catch (error) {
      // Ignore view count errors
    }
  }

  /// Refresh updates
  Future<void> refresh() async {
    await loadUpdates();
  }
}