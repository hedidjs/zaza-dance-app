import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/supabase_service.dart';
import '../../shared/models/category_model.dart';
import '../../shared/models/gallery_model.dart';
import '../../shared/models/tutorial_model.dart';
import '../../shared/models/update_model.dart';
import '../../shared/data/mock_data.dart';

/// Whether to use real Supabase data (true) or mock data (false)
/// Change this to switch between data sources
const bool _useRealData = true;

// MARK: - Services
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

// MARK: - Categories
final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  if (_useRealData) {
    final supabaseService = ref.read(supabaseServiceProvider);
    return await supabaseService.getCategories();
  } else {
    // Return mock categories - convert from mock data format
    return MockData.categories.map((category) => CategoryModel(
      id: category['id'] as String,
      nameHe: category['name'] as String,
      descriptionHe: category['description'] as String?,
      color: category['color'] as String? ?? '#FF00FF',
      sortOrder: category['order'] as int? ?? 0,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    )).toList();
  }
});

// MARK: - Gallery
final galleryItemsProvider = FutureProvider<List<GalleryModel>>((ref) async {
  if (_useRealData) {
    final supabaseService = ref.read(supabaseServiceProvider);
    return await supabaseService.getGalleryItems();
  } else {
    // Return mock gallery items
    return MockData.galleryItems.map((item) => GalleryModel(
      id: item.id,
      titleHe: item.title,
      descriptionHe: item.description,
      mediaUrl: item.imageUrl ?? item.videoUrl ?? '',
      thumbnailUrl: item.thumbnailUrl,
      mediaType: item.videoUrl != null ? MediaType.video : MediaType.image,
      tags: item.tags,
      isFeatured: item.isPopular,
      likesCount: item.likes,
      viewsCount: item.views,
      sortOrder: 0,
      isActive: true,
      createdAt: item.createdAt,
      updatedAt: item.createdAt,
    )).toList();
  }
});

final featuredGalleryProvider = FutureProvider<List<GalleryModel>>((ref) async {
  if (_useRealData) {
    final supabaseService = ref.read(supabaseServiceProvider);
    return await supabaseService.getFeaturedGalleryItems();
  } else {
    final allItems = await ref.read(galleryItemsProvider.future);
    return allItems.where((item) => item.isFeatured).toList();
  }
});

// MARK: - Tutorials
final tutorialsProvider = FutureProvider<List<TutorialModel>>((ref) async {
  if (_useRealData) {
    final supabaseService = ref.read(supabaseServiceProvider);
    return await supabaseService.getTutorials();
  } else {
    // Return mock tutorials
    return MockData.tutorials.map((tutorial) => TutorialModel(
      id: tutorial.id,
      titleHe: tutorial.title,
      descriptionHe: tutorial.description,
      videoUrl: tutorial.videoUrl ?? '',
      thumbnailUrl: tutorial.thumbnailUrl,
      durationSeconds: tutorial.duration,
      difficultyLevel: DifficultyLevel.fromString(tutorial.difficultyLevel.value),
      instructorName: tutorial.instructorName,
      tags: [],
      isFeatured: false,
      likesCount: tutorial.likeCount,
      viewsCount: tutorial.viewCount,
      downloadsCount: 0,
      sortOrder: 0,
      isActive: true,
      createdAt: tutorial.createdAt,
      updatedAt: tutorial.updatedAt ?? tutorial.createdAt,
    )).toList();
  }
});

final featuredTutorialsProvider = FutureProvider<List<TutorialModel>>((ref) async {
  if (_useRealData) {
    final supabaseService = ref.read(supabaseServiceProvider);
    return await supabaseService.getFeaturedTutorials();
  } else {
    final allTutorials = await ref.read(tutorialsProvider.future);
    return allTutorials.take(3).toList(); // Take first 3 as featured
  }
});

// MARK: - Updates
final updatesProvider = FutureProvider<List<UpdateModel>>((ref) async {
  if (_useRealData) {
    final supabaseService = ref.read(supabaseServiceProvider);
    return await supabaseService.getUpdates();
  } else {
    // Return mock updates
    return MockData.updates.map((update) => UpdateModel(
      id: update.id,
      titleHe: update.title,
      contentHe: update.content,
      excerptHe: update.excerpt,
      imageUrl: update.imageUrl,
      updateType: UpdateType.fromString(update.updateType.value),
      isPinned: update.isPinned,
      isFeatured: false,
      authorName: update.author,
      likesCount: update.likeCount,
      commentsCount: update.commentCount,
      sharesCount: 0,
      tags: [],
      publishDate: update.createdAt,
      isActive: true,
      createdAt: update.createdAt,
      updatedAt: update.updatedAt ?? update.createdAt,
    )).toList();
  }
});

final pinnedUpdatesProvider = FutureProvider<List<UpdateModel>>((ref) async {
  if (_useRealData) {
    final supabaseService = ref.read(supabaseServiceProvider);
    return await supabaseService.getPinnedUpdates();
  } else {
    final allUpdates = await ref.read(updatesProvider.future);
    return allUpdates.where((update) => update.isPinned).toList();
  }
});

// MARK: - Search Providers
final gallerySearchProvider = FutureProvider.family<List<GalleryModel>, String>((ref, query) async {
  if (_useRealData) {
    final supabaseService = ref.read(supabaseServiceProvider);
    return await supabaseService.searchGalleryItems(query);
  } else {
    final allItems = await ref.read(galleryItemsProvider.future);
    return allItems.where((item) => 
      item.titleHe.toLowerCase().contains(query.toLowerCase()) ||
      (item.descriptionHe?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();
  }
});

final tutorialsSearchProvider = FutureProvider.family<List<TutorialModel>, String>((ref, query) async {
  if (_useRealData) {
    final supabaseService = ref.read(supabaseServiceProvider);
    return await supabaseService.searchTutorials(query);
  } else {
    final allTutorials = await ref.read(tutorialsProvider.future);
    return allTutorials.where((tutorial) => 
      tutorial.titleHe.toLowerCase().contains(query.toLowerCase()) ||
      (tutorial.descriptionHe?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
      (tutorial.instructorName?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();
  }
});

final updatesSearchProvider = FutureProvider.family<List<UpdateModel>, String>((ref, query) async {
  if (_useRealData) {
    final supabaseService = ref.read(supabaseServiceProvider);
    return await supabaseService.searchUpdates(query);
  } else {
    final allUpdates = await ref.read(updatesProvider.future);
    return allUpdates.where((update) => 
      update.titleHe.toLowerCase().contains(query.toLowerCase()) ||
      update.contentHe.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
});

// MARK: - Interaction Providers
class InteractionNotifier extends StateNotifier<Map<String, bool>> {
  InteractionNotifier(this._supabaseService) : super({});
  
  final SupabaseService _supabaseService;

  Future<void> toggleLike(String contentType, String contentId) async {
    final currentState = state[contentId] ?? false;
    
    if (_useRealData) {
      bool success;
      if (currentState) {
        success = await _supabaseService.removeInteraction(
          contentType: contentType,
          contentId: contentId,
          interactionType: 'like',
        );
      } else {
        success = await _supabaseService.trackInteraction(
          contentType: contentType,
          contentId: contentId,
          interactionType: 'like',
        );
      }
      
      if (success) {
        state = {
          ...state,
          contentId: !currentState,
        };
      }
    } else {
      // Mock behavior - just toggle the state
      state = {
        ...state,
        contentId: !currentState,
      };
    }
  }
  
  Future<void> trackView(String contentType, String contentId) async {
    if (_useRealData) {
      await _supabaseService.trackInteraction(
        contentType: contentType,
        contentId: contentId,
        interactionType: 'view',
      );
    }
    // For mock data, we don't need to do anything special for views
  }
  
  Future<void> trackDownload(String tutorialId) async {
    if (_useRealData) {
      await _supabaseService.downloadTutorial(tutorialId);
    }
    // For mock data, we don't need to do anything special for downloads
  }
}

final interactionProvider = StateNotifierProvider<InteractionNotifier, Map<String, bool>>((ref) {
  final supabaseService = ref.read(supabaseServiceProvider);
  return InteractionNotifier(supabaseService);
});

// MARK: - Filtered Providers
final galleryByCategoryProvider = FutureProvider.family<List<GalleryModel>, String?>((ref, categoryId) async {
  if (_useRealData && categoryId != null) {
    final supabaseService = ref.read(supabaseServiceProvider);
    return await supabaseService.getGalleryItems(categoryId: categoryId);
  } else {
    final allItems = await ref.read(galleryItemsProvider.future);
    if (categoryId == null) return allItems;
    return allItems.where((item) => item.categoryId == categoryId).toList();
  }
});

final tutorialsByDifficultyProvider = FutureProvider.family<List<TutorialModel>, String?>((ref, difficulty) async {
  if (_useRealData && difficulty != null) {
    final supabaseService = ref.read(supabaseServiceProvider);
    return await supabaseService.getTutorials(difficultyLevel: difficulty);
  } else {
    final allTutorials = await ref.read(tutorialsProvider.future);
    if (difficulty == null) return allTutorials;
    return allTutorials.where((tutorial) => tutorial.difficultyLevel?.value == difficulty).toList();
  }
});

final updatesByTypeProvider = FutureProvider.family<List<UpdateModel>, String?>((ref, updateType) async {
  if (_useRealData && updateType != null) {
    final supabaseService = ref.read(supabaseServiceProvider);
    return await supabaseService.getUpdates(updateType: updateType);
  } else {
    final allUpdates = await ref.read(updatesProvider.future);
    if (updateType == null) return allUpdates;
    return allUpdates.where((update) => update.updateType.value == updateType).toList();
  }
});