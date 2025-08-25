import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/models/user_model.dart';
import '../services/auth_service.dart';
import '../constants/app_constants.dart';

/// Provider for authentication service
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Provider for current user
final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, AsyncValue<UserModel?>>((ref) {
  return CurrentUserNotifier(ref.read(authServiceProvider));
});

/// Alias for auth provider
final authProvider = currentUserProvider;

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
        debugPrint('CurrentUserNotifier: Error loading user: $error');
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
        // Force immediate user load after successful registration
        await _loadCurrentUser();
      } else {
        state = const AsyncValue.data(null);
      }

      return result;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('CurrentUserNotifier: Error during registration: $error');
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
        // Force immediate user load after successful sign in
        await _loadCurrentUser();
      } else {
        state = const AsyncValue.data(null);
      }

      return result;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('CurrentUserNotifier: Error during sign in: $error');
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
        debugPrint('CurrentUserNotifier: Error during sign out: $error');
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
    String? avatarUrl,
  }) async {
    try {
      final result = await _authService.updateProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
        address: address,
        avatarUrl: avatarUrl,
      );

      if (result.isSuccess) {
        // Reload user data to reflect changes
        await _loadCurrentUser();
      }

      return result;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('CurrentUserNotifier: Error updating profile: $error');
      }
      return AuthResult.error('Profile update failed. Please try again.');
    }
  }

  /// Update user profile with display name and bio
  Future<AuthResult> updateUserProfile({
    String? displayName,
    String? phoneNumber,
    String? address,
    String? avatarUrl,
    String? bio,
  }) async {
    try {
      final result = await _authService.updateProfile(
        fullName: displayName,
        phoneNumber: phoneNumber,
        address: address,
        avatarUrl: avatarUrl,
        bio: bio,
      );

      if (result.isSuccess) {
        // Reload user data to reflect changes
        await _loadCurrentUser();
      }

      return result;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('CurrentUserNotifier: Error updating profile: $error');
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
    data: (user) {
      if (user == null) return false;
      // Special check for hedidjs@gmail.com
      if (user.email == 'hedidjs@gmail.com') return true;
      return user.isAdmin;
    },
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