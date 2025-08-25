import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/supabase_service.dart';
import '../../shared/models/category_model.dart';
import '../../shared/models/gallery_model.dart';
import '../../shared/models/tutorial_model.dart';
import '../../shared/models/update_model.dart';

// MARK: - Services
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

// MARK: - Categories
final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final supabaseService = ref.read(supabaseServiceProvider);
  return await supabaseService.getCategories();
});

// MARK: - Gallery
final galleryItemsProvider = FutureProvider<List<GalleryModel>>((ref) async {
  final supabaseService = ref.read(supabaseServiceProvider);
  return await supabaseService.getGalleryItems();
});

final featuredGalleryProvider = FutureProvider<List<GalleryModel>>((ref) async {
  final supabaseService = ref.read(supabaseServiceProvider);
  return await supabaseService.getFeaturedGalleryItems();
});

// MARK: - Tutorials
final tutorialsProvider = FutureProvider<List<TutorialModel>>((ref) async {
  final supabaseService = ref.read(supabaseServiceProvider);
  return await supabaseService.getTutorials();
});

final featuredTutorialsProvider = FutureProvider<List<TutorialModel>>((ref) async {
  final supabaseService = ref.read(supabaseServiceProvider);
  return await supabaseService.getFeaturedTutorials();
});

// MARK: - Updates
final updatesProvider = FutureProvider<List<UpdateModel>>((ref) async {
  final supabaseService = ref.read(supabaseServiceProvider);
  return await supabaseService.getUpdates();
});

final pinnedUpdatesProvider = FutureProvider<List<UpdateModel>>((ref) async {
  final supabaseService = ref.read(supabaseServiceProvider);
  return await supabaseService.getPinnedUpdates();
});

// MARK: - Search Providers
final gallerySearchProvider = FutureProvider.family<List<GalleryModel>, String>((ref, query) async {
  final supabaseService = ref.read(supabaseServiceProvider);
  return await supabaseService.searchGalleryItems(query);
});

final tutorialsSearchProvider = FutureProvider.family<List<TutorialModel>, String>((ref, query) async {
  final supabaseService = ref.read(supabaseServiceProvider);
  return await supabaseService.searchTutorials(query);
});

final updatesSearchProvider = FutureProvider.family<List<UpdateModel>, String>((ref, query) async {
  final supabaseService = ref.read(supabaseServiceProvider);
  return await supabaseService.searchUpdates(query);
});

// MARK: - Interaction Providers
class InteractionNotifier extends StateNotifier<Map<String, bool>> {
  InteractionNotifier(this._supabaseService) : super({});
  
  final SupabaseService _supabaseService;

  Future<void> toggleLike(String contentType, String contentId) async {
    final currentState = state[contentId] ?? false;
    
    // Optimistic update
    state = {
      ...state,
      contentId: !currentState,
    };
    
    try {
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
      
      // Revert on failure
      if (!success) {
        state = {
          ...state,
          contentId: currentState,
        };
      }
    } catch (error) {
      // Revert on error
      state = {
        ...state,
        contentId: currentState,
      };
    }
  }
  
  Future<void> trackView(String contentType, String contentId) async {
    try {
      await _supabaseService.trackInteraction(
        contentType: contentType,
        contentId: contentId,
        interactionType: 'view',
      );
    } catch (error) {
      // Ignore view tracking errors silently
    }
  }
  
  Future<void> trackDownload(String tutorialId) async {
    try {
      await _supabaseService.downloadTutorial(tutorialId);
    } catch (error) {
      // Ignore download tracking errors silently
    }
  }
}

final interactionProvider = StateNotifierProvider<InteractionNotifier, Map<String, bool>>((ref) {
  final supabaseService = ref.read(supabaseServiceProvider);
  return InteractionNotifier(supabaseService);
});

// MARK: - Filtered Providers
final galleryByCategoryProvider = FutureProvider.family<List<GalleryModel>, String?>((ref, categoryId) async {
  final supabaseService = ref.read(supabaseServiceProvider);
  return await supabaseService.getGalleryItems(categoryId: categoryId);
});

final tutorialsByDifficultyProvider = FutureProvider.family<List<TutorialModel>, String?>((ref, difficulty) async {
  final supabaseService = ref.read(supabaseServiceProvider);
  return await supabaseService.getTutorials(difficultyLevel: difficulty);
});

final updatesByTypeProvider = FutureProvider.family<List<UpdateModel>, String?>((ref, updateType) async {
  final supabaseService = ref.read(supabaseServiceProvider);
  return await supabaseService.getUpdates(updateType: updateType);
});