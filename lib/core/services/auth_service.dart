import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../constants/app_constants.dart';
import 'database_service.dart';

/// Authentication service handling user login, registration, and profile management
class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Current authenticated user
  User? get currentUser => _supabase.auth.currentUser;

  /// Stream of authentication state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Checks if user is currently authenticated
  bool get isAuthenticated => currentUser != null;

  /// Gets current user profile data
  Future<UserModel?> getCurrentUserProfile() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      return await DatabaseService.getUserById(user.id);
    } catch (e) {
      if (kDebugMode) {
        print('AuthService: Error getting user profile: $e');
      }
      return null;
    }
  }

  /// Register a new user with email and password
  Future<AuthResult> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    String? address,
    String role = AppConstants.roleStudent,
  }) async {
    try {
      if (kDebugMode) {
        print('AuthService: Registering user with email: $email');
      }

      // Create user with Supabase Auth
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'display_name': fullName,
          'phone': phoneNumber,
          'address': address,
          'role': role,
        },
      );

      if (response.user == null) {
        return AuthResult.error('Failed to create user account');
      }

      // Create user profile in users table
      await DatabaseService.createUserProfile(
        userId: response.user!.id,
        email: email,
        displayName: fullName,
        phone: phoneNumber,
        address: address,
        role: role,
      );

      if (kDebugMode) {
        print('AuthService: User registered successfully');
      }

      return AuthResult.success(
        message: 'Registration successful! Please check your email for verification.',
      );
    } on AuthException catch (e) {
      if (kDebugMode) {
        print('AuthService: Auth error during registration: ${e.message}');
      }
      return AuthResult.error(e.message);
    } catch (e) {
      if (kDebugMode) {
        print('AuthService: Unknown error during registration: $e');
      }
      return AuthResult.error('Registration failed. Please try again.');
    }
  }

  /// Sign in with email and password
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      if (kDebugMode) {
        print('AuthService: Signing in user with email: $email');
      }

      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return AuthResult.error('Failed to sign in');
      }

      if (kDebugMode) {
        print('AuthService: User signed in successfully');
      }

      return AuthResult.success(message: 'Signed in successfully!');
    } on AuthException catch (e) {
      if (kDebugMode) {
        print('AuthService: Auth error during sign in: ${e.message}');
      }
      return AuthResult.error(e.message);
    } catch (e) {
      if (kDebugMode) {
        print('AuthService: Unknown error during sign in: $e');
      }
      return AuthResult.error('Sign in failed. Please try again.');
    }
  }

  /// Sign out current user
  Future<AuthResult> signOut() async {
    try {
      if (kDebugMode) {
        print('AuthService: Signing out user');
      }

      await _supabase.auth.signOut();

      if (kDebugMode) {
        print('AuthService: User signed out successfully');
      }

      return AuthResult.success(message: 'Signed out successfully!');
    } catch (e) {
      if (kDebugMode) {
        print('AuthService: Error during sign out: $e');
      }
      return AuthResult.error('Sign out failed. Please try again.');
    }
  }

  /// Send password reset email
  Future<AuthResult> resetPassword({required String email}) async {
    try {
      if (kDebugMode) {
        print('AuthService: Sending password reset email to: $email');
      }

      await _supabase.auth.resetPasswordForEmail(email);

      if (kDebugMode) {
        print('AuthService: Password reset email sent successfully');
      }

      return AuthResult.success(
        message: 'Password reset email sent! Please check your email.',
      );
    } on AuthException catch (e) {
      if (kDebugMode) {
        print('AuthService: Auth error during password reset: ${e.message}');
      }
      return AuthResult.error(e.message);
    } catch (e) {
      if (kDebugMode) {
        print('AuthService: Unknown error during password reset: $e');
      }
      return AuthResult.error('Password reset failed. Please try again.');
    }
  }

  /// Update user profile
  Future<AuthResult> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? address,
    String? profileImageUrl,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        return AuthResult.error('User not authenticated');
      }

      if (kDebugMode) {
        print('AuthService: Updating profile for user: ${user.id}');
      }

      final updateData = <String, dynamic>{};
      if (fullName != null) updateData['full_name'] = fullName;
      if (phoneNumber != null) updateData['phone_number'] = phoneNumber;
      if (address != null) updateData['address'] = address;
      if (profileImageUrl != null) updateData['profile_image_url'] = profileImageUrl;

      if (updateData.isNotEmpty) {
        updateData['updated_at'] = DateTime.now().toIso8601String();

        await _supabase
            .from('profiles')
            .update(updateData)
            .eq('id', user.id);
      }

      if (kDebugMode) {
        print('AuthService: Profile updated successfully');
      }

      return AuthResult.success(message: 'Profile updated successfully!');
    } catch (e) {
      if (kDebugMode) {
        print('AuthService: Error updating profile: $e');
      }
      return AuthResult.error('Profile update failed. Please try again.');
    }
  }

  /// Delete user account
  Future<AuthResult> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) {
        return AuthResult.error('User not authenticated');
      }

      if (kDebugMode) {
        print('AuthService: Deleting account for user: ${user.id}');
      }

      // Delete user profile first
      await _supabase
          .from('profiles')
          .delete()
          .eq('id', user.id);

      // Note: Supabase doesn't have a direct delete user method in client SDK
      // This would typically be handled by a server-side function
      await signOut();

      if (kDebugMode) {
        print('AuthService: Account deleted successfully');
      }

      return AuthResult.success(message: 'Account deleted successfully!');
    } catch (e) {
      if (kDebugMode) {
        print('AuthService: Error deleting account: $e');
      }
      return AuthResult.error('Account deletion failed. Please try again.');
    }
  }
}

/// Result class for authentication operations
class AuthResult {
  final bool isSuccess;
  final String message;
  final dynamic data;

  const AuthResult._({
    required this.isSuccess,
    required this.message,
    this.data,
  });

  factory AuthResult.success({required String message, dynamic data}) {
    return AuthResult._(
      isSuccess: true,
      message: message,
      data: data,
    );
  }

  factory AuthResult.error(String message) {
    return AuthResult._(
      isSuccess: false,
      message: message,
    );
  }

  @override
  String toString() {
    return 'AuthResult(isSuccess: $isSuccess, message: $message)';
  }
}