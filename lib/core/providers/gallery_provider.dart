import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/gallery_model.dart';
import '../services/database_service.dart';

/// Provider for gallery service operations
final galleryProvider = StateNotifierProvider<GalleryNotifier, AsyncValue<List<GalleryModel>>>(
  (ref) => GalleryNotifier(),
);

/// Provider for featured gallery items
final featuredGalleryProvider = FutureProvider<List<GalleryModel>>((ref) async {
  return await DatabaseService.getGalleryItems(
    isFeatured: true,
    orderBy: 'created_at',
    ascending: false,
    limit: 10,
  );
});

/// Provider for gallery items by category
final galleryByCategoryProvider = FutureProvider.family<List<GalleryModel>, String>(
  (ref, category) async {
    return await DatabaseService.getGalleryItems(
      category: category,
      orderBy: 'created_at',
      ascending: false,
    );
  },
);

/// Provider for gallery search
final gallerySearchProvider = StateNotifierProvider<GallerySearchNotifier, AsyncValue<List<GalleryModel>>>(
  (ref) => GallerySearchNotifier(),
);

/// Notifier for managing gallery state
class GalleryNotifier extends StateNotifier<AsyncValue<List<GalleryModel>>> {
  GalleryNotifier() : super(const AsyncValue.loading()) {
    loadGalleryItems();
  }

  /// Load all gallery items
  Future<void> loadGalleryItems({
    String? category,
    String? mediaType,
    String? searchQuery,
    bool? isFeatured,
  }) async {
    try {
      state = const AsyncValue.loading();
      
      final galleryItems = await DatabaseService.getGalleryItems(
        category: category,
        mediaType: mediaType,
        searchQuery: searchQuery,
        isFeatured: isFeatured,
        orderBy: 'created_at',
        ascending: false,
      );

      state = AsyncValue.data(galleryItems);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Create new gallery item
  Future<GalleryModel?> createGalleryItem({
    required String titleHe,
    String? titleEn,
    String? descriptionHe,
    String? descriptionEn,
    required String mediaUrl,
    required String mediaType,
    required String category,
    String? thumbnailUrl,
    int? fileSize,
    int? durationSeconds,
    int? width,
    int? height,
    String? uploadedBy,
    bool isFeatured = false,
    List<String>? tags,
  }) async {
    try {
      // Validate Hebrew title is provided
      if (titleHe.trim().isEmpty) {
        throw Exception('כותרת בעברית היא חובה');
      }
      
      print('GalleryProvider: Creating gallery item with titleHe: $titleHe');
      
      final newGalleryItem = await DatabaseService.createGalleryItem(
        titleHe: titleHe.trim(),
        titleEn: titleEn?.trim(),
        descriptionHe: descriptionHe?.trim(),
        descriptionEn: descriptionEn?.trim(),
        mediaUrl: mediaUrl,
        mediaType: mediaType,
        category: category,
        thumbnailUrl: thumbnailUrl,
        fileSize: fileSize,
        durationSeconds: durationSeconds,
        width: width,
        height: height,
        uploadedBy: uploadedBy,
        isFeatured: isFeatured,
        tags: tags,
      );

      print('GalleryProvider: Gallery item created successfully: ${newGalleryItem.id}');

      // Reload gallery items to include the new one
      await loadGalleryItems();
      
      return newGalleryItem;
    } catch (error) {
      print('GalleryProvider: Error creating gallery item: $error');
      
      // Update state with error for UI feedback
      state = AsyncValue.error(error, StackTrace.current);
      return null;
    }
  }

  /// Increment gallery item view count
  Future<void> incrementViews(String galleryItemId) async {
    try {
      await DatabaseService.incrementGalleryViews(galleryItemId);
    } catch (error) {
      // Ignore view count errors
    }
  }

  /// Refresh gallery items
  Future<void> refresh() async {
    await loadGalleryItems();
  }
}

/// Notifier for gallery search functionality
class GallerySearchNotifier extends StateNotifier<AsyncValue<List<GalleryModel>>> {
  GallerySearchNotifier() : super(const AsyncValue.data([]));

  /// Search gallery items by query (supports Hebrew and English)
  Future<void> searchGalleryItems(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    try {
      state = const AsyncValue.loading();
      
      // Search in both Hebrew and English fields
      final galleryItems = await DatabaseService.getGalleryItems(
        searchQuery: trimmedQuery,
        orderBy: 'created_at',
        ascending: false,
      );

      state = AsyncValue.data(galleryItems);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Clear search results
  void clearSearch() {
    state = const AsyncValue.data([]);
  }
}