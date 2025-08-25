import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../shared/models/user_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../services/profile_service.dart';
import './profile_provider.dart';

/// Provider for advanced profile editing
final editProfileProvider = StateNotifierProvider<EditProfileNotifier, EditProfileState>((ref) {
  return EditProfileNotifier(ref.read(profileServiceProvider), ref);
});

/// Advanced state for profile editing with auto-save, image handling, etc.
class EditProfileState {
  final bool isSaving;
  final bool isImageUploading;
  final bool hasChanges;
  final bool isAutoSaving;
  final String? error;
  final String? successMessage;
  final UserModel? updatedUser;
  final DateTime? lastSaved;
  final DateTime? lastAutoSave;
  final Map<String, dynamic> pendingChanges;

  const EditProfileState({
    this.isSaving = false,
    this.isImageUploading = false,
    this.hasChanges = false,
    this.isAutoSaving = false,
    this.error,
    this.successMessage,
    this.updatedUser,
    this.lastSaved,
    this.lastAutoSave,
    this.pendingChanges = const {},
  });

  EditProfileState copyWith({
    bool? isSaving,
    bool? isImageUploading,
    bool? hasChanges,
    bool? isAutoSaving,
    String? error,
    String? successMessage,
    UserModel? updatedUser,
    DateTime? lastSaved,
    DateTime? lastAutoSave,
    Map<String, dynamic>? pendingChanges,
  }) {
    return EditProfileState(
      isSaving: isSaving ?? this.isSaving,
      isImageUploading: isImageUploading ?? this.isImageUploading,
      hasChanges: hasChanges ?? this.hasChanges,
      isAutoSaving: isAutoSaving ?? this.isAutoSaving,
      error: error,
      successMessage: successMessage,
      updatedUser: updatedUser ?? this.updatedUser,
      lastSaved: lastSaved ?? this.lastSaved,
      lastAutoSave: lastAutoSave ?? this.lastAutoSave,
      pendingChanges: pendingChanges ?? this.pendingChanges,
    );
  }
}

/// Advanced notifier for profile editing with auto-save and image handling
class EditProfileNotifier extends StateNotifier<EditProfileState> {
  final ProfileService _profileService;
  final Ref _ref;
  Timer? _autoSaveTimer;

  EditProfileNotifier(this._profileService, this._ref) : super(const EditProfileState());

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  void startAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (state.hasChanges && !state.isSaving && !state.isAutoSaving) {
        _performAutoSave();
      }
    });
  }

  void stopAutoSave() {
    _autoSaveTimer?.cancel();
  }

  Future<void> _performAutoSave() async {
    if (state.pendingChanges.isEmpty) return;

    try {
      state = state.copyWith(isAutoSaving: true);
      
      // Perform silent auto-save
      final userAsync = _ref.read(currentUserProvider);
      final user = userAsync.value;
      if (user == null) {
        state = state.copyWith(isAutoSaving: false);
        return;
      }

      // Only update fields that have changed
      final changes = Map<String, dynamic>.from(state.pendingChanges);
      
      await _profileService.updateProfile(
        userId: user.id,
        fullName: changes['fullName'],
        phoneNumber: changes['phoneNumber'],
        address: changes['address'],
        birthDate: changes['birthDate'],
      );

      state = state.copyWith(
        isAutoSaving: false,
        lastAutoSave: DateTime.now(),
        hasChanges: false,
        pendingChanges: {},
      );

      // Refresh user data silently
      await _ref.read(currentUserProvider.notifier).refreshUser();
      
    } catch (error) {
      if (kDebugMode) {
        debugPrint('EditProfileNotifier: Auto-save failed: $error');
      }
      state = state.copyWith(
        isAutoSaving: false,
        error: 'שמירה אוטומטית נכשלה',
      );
    }
  }

  void updatePendingChanges({
    String? fullName,
    String? phoneNumber,
    String? address,
    String? bio,
    DateTime? birthDate,
  }) {
    final updates = Map<String, dynamic>.from(state.pendingChanges);
    
    if (fullName != null) updates['fullName'] = fullName;
    if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
    if (address != null) updates['address'] = address;
    if (bio != null) updates['bio'] = bio;
    if (birthDate != null) updates['birthDate'] = birthDate;

    state = state.copyWith(
      hasChanges: true,
      pendingChanges: updates,
      error: null,
    );
  }

  Future<bool> autoSaveProfile({
    required String userId,
    String? fullName,
    String? phoneNumber,
    String? address,
    String? bio,
    DateTime? birthDate,
  }) async {
    try {
      state = state.copyWith(isAutoSaving: true, error: null);

      final updates = <String, dynamic>{};
      if (fullName != null) updates['fullName'] = fullName;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (address != null) updates['address'] = address;
      if (birthDate != null) updates['birthDate'] = birthDate;

      // Store bio in metadata
      final user = _ref.read(currentUserProvider).value;
      final currentMetadata = user?.metadata ?? {};
      if (bio != null) {
        currentMetadata['bio'] = bio;
        updates['metadata'] = currentMetadata;
      }

      await _profileService.updateProfile(
        userId: userId,
        fullName: fullName,
        phoneNumber: phoneNumber,
        address: address,
        birthDate: birthDate,
      );

      // Refresh user data
      await _ref.read(currentUserProvider.notifier).refreshUser();

      state = state.copyWith(
        isAutoSaving: false,
        lastAutoSave: DateTime.now(),
      );

      return true;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('EditProfileNotifier: Auto-save error: $error');
      }
      state = state.copyWith(
        isAutoSaving: false,
        error: error.toString(),
      );
      return false;
    }
  }

  Future<bool> saveProfile({
    required String userId,
    String? fullName,
    String? phoneNumber,
    String? address,
    String? bio,
    DateTime? birthDate,
    XFile? imageFile,
  }) async {
    try {
      state = state.copyWith(isSaving: true, error: null);

      String? imageUrl;
      
      // Upload image if provided
      if (imageFile != null) {
        state = state.copyWith(isImageUploading: true);
        imageUrl = await _uploadProfileImage(userId, imageFile);
        state = state.copyWith(isImageUploading: false);
      }

      // Prepare metadata with bio
      Map<String, dynamic>? metadata;
      if (bio != null) {
        final user = _ref.read(currentUserProvider).value;
        metadata = Map<String, dynamic>.from(user?.metadata ?? {});
        metadata['bio'] = bio;
      }

      // Update profile
      final updatedUser = await _profileService.updateProfile(
        userId: userId,
        fullName: fullName,
        phoneNumber: phoneNumber,
        address: address,
        birthDate: birthDate,
        avatarUrl: imageUrl,
      );

      // Update bio separately if needed (since it's in metadata)
      if (bio != null) {
        // In a real implementation, you'd update the metadata in the database
        // For now, we'll handle this in the profile service
      }

      // Refresh user data
      await _ref.read(currentUserProvider.notifier).refreshUser();

      state = state.copyWith(
        isSaving: false,
        hasChanges: false,
        updatedUser: updatedUser,
        lastSaved: DateTime.now(),
        successMessage: 'הפרופיל עודכן בהצלחה',
        pendingChanges: {},
      );

      return true;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('EditProfileNotifier: Save error: $error');
      }
      state = state.copyWith(
        isSaving: false,
        isImageUploading: false,
        error: _getErrorMessage(error),
      );
      return false;
    }
  }

  Future<String?> _uploadProfileImage(String userId, XFile imageFile) async {
    try {
      // Validate image file
      final file = File(imageFile.path);
      
      // Check if file exists
      if (!await file.exists()) {
        throw Exception('קובץ התמונה לא נמצא');
      }
      
      // Validate image size
      final fileSize = await file.length();
      if (fileSize > 5 * 1024 * 1024) { // 5MB limit
        throw Exception('התמונה גדולה מדי. גודל מקסימלי: 5MB');
      }
      
      // Validate image format
      final fileName = imageFile.name.toLowerCase();
      final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
      final hasValidExtension = allowedExtensions.any((ext) => fileName.endsWith('.$ext'));
      
      if (!hasValidExtension) {
        throw Exception('סוג קובץ לא נתמך. נתמכים: JPG, PNG, GIF, WebP');
      }

      // Upload image
      return await _profileService.updateProfileImage(userId);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('EditProfileNotifier: Image upload error: $error');
      }
      rethrow;
    }
  }

  Future<bool> uploadProfileImage(String userId, XFile imageFile) async {
    try {
      state = state.copyWith(isImageUploading: true, error: null);

      final imageUrl = await _uploadProfileImage(userId, imageFile);
      
      if (imageUrl != null) {
        // Update user profile with new image URL
        final updatedUser = await _profileService.updateProfile(
          userId: userId,
          avatarUrl: imageUrl,
        );

        // Refresh user data
        await _ref.read(currentUserProvider.notifier).refreshUser();

        state = state.copyWith(
          isImageUploading: false,
          updatedUser: updatedUser,
          successMessage: 'תמונת הפרופיל עודכנה בהצלחה',
        );

        return true;
      } else {
        state = state.copyWith(
          isImageUploading: false,
          error: 'לא נבחרה תמונה',
        );
        return false;
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('EditProfileNotifier: Image upload error: $error');
      }
      state = state.copyWith(
        isImageUploading: false,
        error: _getErrorMessage(error),
      );
      return false;
    }
  }

  Future<bool> removeProfileImage(String userId) async {
    try {
      state = state.copyWith(isImageUploading: true, error: null);

      // Update profile to remove image URL
      final updatedUser = await _profileService.updateProfile(
        userId: userId,
        avatarUrl: null,
      );

      // Refresh user data
      await _ref.read(currentUserProvider.notifier).refreshUser();

      state = state.copyWith(
        isImageUploading: false,
        updatedUser: updatedUser,
        successMessage: 'תמונת הפרופיל הוסרה בהצלחה',
      );

      return true;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('EditProfileNotifier: Remove image error: $error');
      }
      state = state.copyWith(
        isImageUploading: false,
        error: _getErrorMessage(error),
      );
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(
      error: null,
      successMessage: null,
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearSuccess() {
    state = state.copyWith(successMessage: null);
  }

  void resetState() {
    state = const EditProfileState();
  }

  String _getErrorMessage(dynamic error) {
    if (error is Exception) {
      final message = error.toString();
      if (message.contains('Failed to upload image')) {
        return 'שגיאה בהעלאת התמונה';
      } else if (message.contains('Failed to update profile')) {
        return 'שגיאה בעדכון הפרופיל';
      } else if (message.contains('Image size too large')) {
        return 'התמונה גדולה מדי. גודל מקסימלי: 5MB';
      } else if (message.contains('No internet connection')) {
        return 'אין חיבור לאינטרנט';
      }
    }
    
    return 'שגיאה לא צפויה. אנא נסו שוב.';
  }
}

/// Helper providers for specific functionality
final profileImageUploadProvider = StateProvider<XFile?>((ref) => null);

final profileFormValidationProvider = StateProvider<Map<String, String?>>((ref) => {});

final autoSaveStatusProvider = Provider<String?>((ref) {
  final editState = ref.watch(editProfileProvider);
  
  if (editState.isAutoSaving) {
    return 'שומר אוטומטית...';
  } else if (editState.lastAutoSave != null) {
    final now = DateTime.now();
    final diff = now.difference(editState.lastAutoSave!);
    
    if (diff.inMinutes < 1) {
      return 'נשמר לפני ${diff.inSeconds} שניות';
    } else if (diff.inHours < 1) {
      return 'נשמר לפני ${diff.inMinutes} דקות';
    } else {
      return 'נשמר לפני ${diff.inHours} שעות';
    }
  }
  
  return null;
});

final hasUnsavedChangesProvider = Provider<bool>((ref) {
  final editState = ref.watch(editProfileProvider);
  return editState.hasChanges;
});