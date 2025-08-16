import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/user_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../services/profile_service.dart';

/// Provider for profile service
final profileServiceProvider = Provider<ProfileService>((ref) => ProfileService());

/// Provider for user statistics
final userStatsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
  final profileService = ref.read(profileServiceProvider);
  return await profileService.getUserStats(userId);
});

/// Provider for user preferences
final userPreferencesProvider = StateNotifierProvider.family<UserPreferencesNotifier, AsyncValue<Map<String, dynamic>>, String>((ref, userId) {
  return UserPreferencesNotifier(ref.read(profileServiceProvider), userId);
});

/// Provider for profile editing state
final profileEditingProvider = StateNotifierProvider<ProfileEditingNotifier, ProfileEditingState>((ref) {
  return ProfileEditingNotifier(ref.read(profileServiceProvider), ref);
});

/// State for profile editing
class ProfileEditingState {
  final bool isLoading;
  final bool isEditing;
  final String? error;
  final UserModel? updatedUser;

  const ProfileEditingState({
    this.isLoading = false,
    this.isEditing = false,
    this.error,
    this.updatedUser,
  });

  ProfileEditingState copyWith({
    bool? isLoading,
    bool? isEditing,
    String? error,
    UserModel? updatedUser,
  }) {
    return ProfileEditingState(
      isLoading: isLoading ?? this.isLoading,
      isEditing: isEditing ?? this.isEditing,
      error: error,
      updatedUser: updatedUser ?? this.updatedUser,
    );
  }
}

/// Notifier for managing user preferences
class UserPreferencesNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final ProfileService _profileService;
  final String _userId;

  UserPreferencesNotifier(this._profileService, this._userId) : super(const AsyncValue.loading()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      state = const AsyncValue.loading();
      final preferences = await _profileService.getUserPreferences(_userId);
      state = AsyncValue.data(preferences);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print('UserPreferencesNotifier: Error loading preferences: $error');
      }
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updatePreference(String key, dynamic value) async {
    final currentState = state;
    if (currentState is! AsyncData) return;

    try {
      final updatedPreferences = Map<String, dynamic>.from(currentState.value ?? {});
      updatedPreferences[key] = value;
      
      // Optimistically update state
      state = AsyncValue.data(updatedPreferences);
      
      // Update in backend
      await _profileService.updateUserPreferences(_userId, {key: value});
    } catch (error) {
      if (kDebugMode) {
        print('UserPreferencesNotifier: Error updating preference: $error');
      }
      // Revert on error
      state = currentState;
      rethrow;
    }
  }

  Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    final currentState = state;
    if (currentState is! AsyncData) return;

    try {
      final updatedPreferences = Map<String, dynamic>.from(currentState.value ?? {});
      updatedPreferences.addAll(preferences);
      
      // Optimistically update state
      state = AsyncValue.data(updatedPreferences);
      
      // Update in backend
      await _profileService.updateUserPreferences(_userId, preferences);
    } catch (error) {
      if (kDebugMode) {
        print('UserPreferencesNotifier: Error updating preferences: $error');
      }
      // Revert on error
      state = currentState;
      rethrow;
    }
  }

  Future<void> refreshPreferences() async {
    await _loadPreferences();
  }
}

/// Notifier for managing profile editing state
class ProfileEditingNotifier extends StateNotifier<ProfileEditingState> {
  final ProfileService _profileService;
  final Ref _ref;

  ProfileEditingNotifier(this._profileService, this._ref) : super(const ProfileEditingState());

  void startEditing() {
    state = state.copyWith(isEditing: true, error: null);
  }

  void cancelEditing() {
    state = state.copyWith(isEditing: false, error: null);
  }

  Future<bool> updateProfile({
    required String userId,
    String? fullName,
    String? phoneNumber,
    String? address,
    DateTime? birthDate,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final updatedUser = await _profileService.updateProfile(
        userId: userId,
        fullName: fullName,
        phoneNumber: phoneNumber,
        address: address,
        birthDate: birthDate,
      );

      // Update the current user in auth provider
      await _ref.read(currentUserProvider.notifier).refreshUser();

      state = state.copyWith(
        isLoading: false,
        isEditing: false,
        updatedUser: updatedUser,
      );

      return true;
    } catch (error) {
      if (kDebugMode) {
        print('ProfileEditingNotifier: Error updating profile: $error');
      }
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      return false;
    }
  }

  Future<bool> updateProfileImage(String userId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final imageUrl = await _profileService.updateProfileImage(userId);
      
      if (imageUrl != null) {
        final updatedUser = await _profileService.updateProfile(
          userId: userId,
          profileImageUrl: imageUrl,
        );

        // Update the current user in auth provider
        await _ref.read(currentUserProvider.notifier).refreshUser();

        state = state.copyWith(
          isLoading: false,
          updatedUser: updatedUser,
        );

        return true;
      } else {
        state = state.copyWith(isLoading: false);
        return false;
      }
    } catch (error) {
      if (kDebugMode) {
        print('ProfileEditingNotifier: Error updating profile image: $error');
      }
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      return false;
    }
  }

  Future<bool> changePassword(String newPassword) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _profileService.changePassword(newPassword);

      state = state.copyWith(isLoading: false);
      return true;
    } catch (error) {
      if (kDebugMode) {
        print('ProfileEditingNotifier: Error changing password: $error');
      }
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Helper providers for common profile operations
final currentUserStatsProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(currentUserProvider);
  return user.when(
    data: (user) async {
      if (user != null) {
        final stats = await ref.read(userStatsProvider(user.id).future);
        return stats;
      }
      return null;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

final currentUserPreferencesProvider = Provider<AsyncValue<Map<String, dynamic>>?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user.when(
    data: (user) {
      if (user != null) {
        return ref.watch(userPreferencesProvider(user.id));
      }
      return null;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});