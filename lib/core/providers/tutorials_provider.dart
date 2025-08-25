import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/tutorial_model.dart';
import '../services/database_service.dart';

/// Provider for tutorial service operations
final tutorialsProvider = StateNotifierProvider<TutorialsNotifier, AsyncValue<List<TutorialModel>>>(
  (ref) => TutorialsNotifier(),
);

/// Provider for featured tutorials
final featuredTutorialsProvider = FutureProvider<List<TutorialModel>>((ref) async {
  return await DatabaseService.getTutorials(
    isFeatured: true,
    orderBy: 'created_at',
    ascending: false,
    limit: 5,
  );
});

/// Provider for tutorials by difficulty
final tutorialsByDifficultyProvider = FutureProvider.family<List<TutorialModel>, DifficultyLevel>(
  (ref, difficulty) async {
    return await DatabaseService.getTutorials(
      difficulty: difficulty,
      orderBy: 'created_at',
      ascending: false,
    );
  },
);

/// Provider for tutorial search
final tutorialSearchProvider = StateNotifierProvider<TutorialSearchNotifier, AsyncValue<List<TutorialModel>>>(
  (ref) => TutorialSearchNotifier(),
);

/// Notifier for managing tutorials state
class TutorialsNotifier extends StateNotifier<AsyncValue<List<TutorialModel>>> {
  TutorialsNotifier() : super(const AsyncValue.loading()) {
    loadTutorials();
  }

  /// Load all tutorials
  Future<void> loadTutorials({
    DifficultyLevel? difficulty,
    String? category,
    String? searchQuery,
    bool? isFeatured,
  }) async {
    try {
      state = const AsyncValue.loading();
      
      final tutorials = await DatabaseService.getTutorials(
        difficulty: difficulty,
        category: category,
        searchQuery: searchQuery,
        isFeatured: isFeatured,
        orderBy: 'created_at',
        ascending: false,
      );

      state = AsyncValue.data(tutorials);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Create new tutorial
  Future<TutorialModel?> createTutorial({
    required String titleHe,
    String? titleEn,
    String? descriptionHe,
    String? descriptionEn,
    required String videoUrl,
    String? thumbnailUrl,
    required DifficultyLevel difficultyLevel,
    required int durationMinutes,
    String? instructorId,
    String? category,
    String? danceStyle,
    bool isFeatured = false,
    List<String>? tags,
  }) async {
    try {
      // Validate Hebrew title and required fields
      if (titleHe.trim().isEmpty) {
        throw Exception('כותרת בעברית היא חובה');
      }
      if (durationMinutes <= 0) {
        throw Exception('משך השיעור חייב להיות חיובי');
      }
      
      final newTutorial = await DatabaseService.createTutorial(
        titleHe: titleHe.trim(),
        titleEn: titleEn?.trim(),
        descriptionHe: descriptionHe?.trim(),
        descriptionEn: descriptionEn?.trim(),
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
        difficultyLevel: difficultyLevel,
        durationMinutes: durationMinutes,
        instructorId: instructorId,
        category: category,
        danceStyle: danceStyle,
        isFeatured: isFeatured,
        tags: tags,
      );

      // Reload tutorials to include the new one
      await loadTutorials();
      
      return newTutorial;
    } catch (error) {
      // Update state with error for UI feedback
      state = AsyncValue.error(error, StackTrace.current);
      return null;
    }
  }

  /// Update existing tutorial
  Future<TutorialModel?> updateTutorial({
    required String tutorialId,
    String? titleHe,
    String? titleEn,
    String? descriptionHe,
    String? descriptionEn,
    String? videoUrl,
    String? thumbnailUrl,
    DifficultyLevel? difficultyLevel,
    int? durationMinutes,
    String? instructorId,
    String? category,
    String? danceStyle,
    bool? isFeatured,
    bool? isPublished,
    List<String>? tags,
  }) async {
    try {
      final updatedTutorial = await DatabaseService.updateTutorial(
        tutorialId: tutorialId,
        titleHe: titleHe,
        titleEn: titleEn,
        descriptionHe: descriptionHe,
        descriptionEn: descriptionEn,
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
        difficultyLevel: difficultyLevel,
        durationMinutes: durationMinutes,
        instructorId: instructorId,
        category: category,
        danceStyle: danceStyle,
        isFeatured: isFeatured,
        isPublished: isPublished,
        tags: tags,
      );

      // Reload tutorials to reflect changes
      await loadTutorials();
      
      return updatedTutorial;
    } catch (error) {
      return null;
    }
  }

  /// Delete tutorial
  Future<bool> deleteTutorial(String tutorialId) async {
    try {
      await DatabaseService.deleteTutorial(tutorialId);
      
      // Reload tutorials to reflect changes
      await loadTutorials();
      
      return true;
    } catch (error) {
      return false;
    }
  }

  /// Increment tutorial view count
  Future<void> incrementViews(String tutorialId) async {
    try {
      await DatabaseService.incrementTutorialViews(tutorialId);
    } catch (error) {
      // Ignore view count errors
    }
  }

  /// Refresh tutorials
  Future<void> refresh() async {
    await loadTutorials();
  }
}

/// Notifier for tutorial search functionality
class TutorialSearchNotifier extends StateNotifier<AsyncValue<List<TutorialModel>>> {
  TutorialSearchNotifier() : super(const AsyncValue.data([]));

  /// Search tutorials by query (supports Hebrew and English)
  Future<void> searchTutorials(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    try {
      state = const AsyncValue.loading();
      
      // Search in both Hebrew and English fields
      final tutorials = await DatabaseService.getTutorials(
        searchQuery: trimmedQuery,
        orderBy: 'created_at',
        ascending: false,
      );

      state = AsyncValue.data(tutorials);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Clear search results
  void clearSearch() {
    state = const AsyncValue.data([]);
  }
}