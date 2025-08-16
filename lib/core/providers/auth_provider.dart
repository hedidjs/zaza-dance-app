import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../constants/app_constants.dart';

/// Provider for authentication service
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Provider for current user
final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, AsyncValue<UserModel?>>((ref) {
  return CurrentUserNotifier(ref.read(authServiceProvider));
});

/// Provider for authentication state
final authStateProvider = StreamProvider<AuthState>((ref) {
  final authService = ref.read(authServiceProvider);
  return authService.authStateChanges;
});

/// Notifier for managing current user state
class CurrentUserNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthService _authService;
  StreamSubscription<AuthState>? _authSubscription;

  CurrentUserNotifier(this._authService) : super(const AsyncValue.loading()) {
    _initialize();
  }

  void _initialize() {
    // Listen to auth state changes
    _authSubscription = _authService.authStateChanges.listen((authState) {
      if (authState.event == AuthChangeEvent.signedIn) {
        _loadCurrentUser();
      } else if (authState.event == AuthChangeEvent.signedOut) {
        state = const AsyncValue.data(null);
      }
    });

    // Load current user if already authenticated
    if (_authService.isAuthenticated) {
      _loadCurrentUser();
    } else {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      state = const AsyncValue.loading();
      final user = await _authService.getCurrentUserProfile();
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print('CurrentUserNotifier: Error loading user: $error');
      }
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Register a new user
  Future<AuthResult> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    String? address,
    String? role,
  }) async {
    try {
      state = const AsyncValue.loading();
      
      final result = await _authService.registerWithEmail(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
        address: address,
        role: role ?? AppConstants.roleStudent,
      );

      if (result.isSuccess) {
        // User will be loaded automatically via auth state listener
      } else {
        state = const AsyncValue.data(null);
      }

      return result;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print('CurrentUserNotifier: Error during registration: $error');
      }
      state = AsyncValue.error(error, stackTrace);
      return AuthResult.error('Registration failed. Please try again.');
    }
  }

  /// Sign in with email and password
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      state = const AsyncValue.loading();
      
      final result = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      if (result.isSuccess) {
        // User will be loaded automatically via auth state listener
      } else {
        state = const AsyncValue.data(null);
      }

      return result;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print('CurrentUserNotifier: Error during sign in: $error');
      }
      state = AsyncValue.error(error, stackTrace);
      return AuthResult.error('Sign in failed. Please try again.');
    }
  }

  /// Sign out current user
  Future<AuthResult> signOut() async {
    try {
      final result = await _authService.signOut();
      
      if (result.isSuccess) {
        state = const AsyncValue.data(null);
      }

      return result;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print('CurrentUserNotifier: Error during sign out: $error');
      }
      state = AsyncValue.error(error, stackTrace);
      return AuthResult.error('Sign out failed. Please try again.');
    }
  }

  /// Reset password
  Future<AuthResult> resetPassword({required String email}) async {
    return await _authService.resetPassword(email: email);
  }

  /// Update user profile
  Future<AuthResult> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? address,
    String? profileImageUrl,
  }) async {
    try {
      final result = await _authService.updateProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
        address: address,
        profileImageUrl: profileImageUrl,
      );

      if (result.isSuccess) {
        // Reload user data to reflect changes
        await _loadCurrentUser();
      }

      return result;
    } catch (error) {
      if (kDebugMode) {
        print('CurrentUserNotifier: Error updating profile: $error');
      }
      return AuthResult.error('Profile update failed. Please try again.');
    }
  }

  /// Refresh current user data
  Future<void> refreshUser() async {
    await _loadCurrentUser();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

/// Helper providers for common user checks
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user.when(
    data: (user) => user?.isAdmin ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
});

final isInstructorProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user.when(
    data: (user) => user?.isInstructor ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
});

final canAccessAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user.when(
    data: (user) => user?.isAdmin == true || user?.isInstructor == true,
    loading: () => false,
    error: (_, __) => false,
  );
});