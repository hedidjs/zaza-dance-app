import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/models/user_model.dart';
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
        debugPrint('AuthService: Error getting user profile: $e');
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
        debugPrint('AuthService: Registering user with email: $email');
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
        debugPrint('AuthService: User registered successfully');
      }

      return AuthResult.success(
        message: 'Registration successful! Please check your email for verification.',
      );
    } on AuthException catch (e) {
      if (kDebugMode) {
        debugPrint('AuthService: Auth error during registration: ${e.message}');
      }
      return AuthResult.error(e.message);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthService: Unknown error during registration: $e');
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
        debugPrint('AuthService: Signing in user with email: $email');
      }

      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (kDebugMode) {
        debugPrint('AuthService: Auth response received - User: ${response.user?.id}');
        debugPrint('AuthService: Session: ${response.session?.accessToken != null ? "Valid" : "Invalid"}');
      }

      if (response.user == null) {
        if (kDebugMode) {
          debugPrint('AuthService: No user returned from sign in');
        }
        return AuthResult.error('Failed to sign in - Invalid credentials');
      }

      if (kDebugMode) {
        debugPrint('AuthService: User signed in successfully - ID: ${response.user!.id}');
        debugPrint('AuthService: User email: ${response.user!.email}');
        debugPrint('AuthService: Email confirmed: ${response.user!.emailConfirmedAt != null}');
      }

      return AuthResult.success(message: 'התחברות בוצעה בהצלחה!');
    } on AuthException catch (e) {
      if (kDebugMode) {
        debugPrint('AuthService: Auth error during sign in: ${e.message}');
        debugPrint('AuthService: Auth error statusCode: ${e.statusCode}');
      }
      
      String errorMessage = e.message;
      if (e.message.contains('Invalid login credentials')) {
        errorMessage = 'פרטי ההתחברות שגויים. אנא בדקו את האימייל והסיסמה.';
      } else if (e.message.contains('Email not confirmed')) {
        errorMessage = 'אנא אשרו את האימייל שלכם לפני ההתחברות.';
      } else if (e.message.contains('Too many requests')) {
        errorMessage = 'יותר מדי ניסיונות התחברות. אנא נסו שוב מאוחר יותר.';
      }
      
      return AuthResult.error(errorMessage);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthService: Unknown error during sign in: $e');
      }
      return AuthResult.error('התחברות נכשלה. אנא נסו שוב.');
    }
  }

  /// Sign out current user
  Future<AuthResult> signOut() async {
    try {
      if (kDebugMode) {
        debugPrint('AuthService: Signing out user');
      }

      await _supabase.auth.signOut();

      if (kDebugMode) {
        debugPrint('AuthService: User signed out successfully');
      }

      return AuthResult.success(message: 'Signed out successfully!');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthService: Error during sign out: $e');
      }
      return AuthResult.error('Sign out failed. Please try again.');
    }
  }

  /// Send password reset email
  Future<AuthResult> resetPassword({required String email}) async {
    try {
      if (kDebugMode) {
        debugPrint('AuthService: Sending password reset email to: $email');
      }

      await _supabase.auth.resetPasswordForEmail(email);

      if (kDebugMode) {
        debugPrint('AuthService: Password reset email sent successfully');
      }

      return AuthResult.success(
        message: 'Password reset email sent! Please check your email.',
      );
    } on AuthException catch (e) {
      if (kDebugMode) {
        debugPrint('AuthService: Auth error during password reset: ${e.message}');
      }
      return AuthResult.error(e.message);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthService: Unknown error during password reset: $e');
      }
      return AuthResult.error('Password reset failed. Please try again.');
    }
  }

  /// Update user profile
  Future<AuthResult> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? address,
    String? avatarUrl,
    String? bio,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        return AuthResult.error('User not authenticated');
      }

      if (kDebugMode) {
        debugPrint('AuthService: Updating profile for user: ${user.id}');
      }

      await DatabaseService.updateUserProfile(
        userId: user.id,
        displayName: fullName,
        phone: phoneNumber,
        address: address,
        avatarUrl: avatarUrl,
        bio: bio,
      );

      if (kDebugMode) {
        debugPrint('AuthService: Profile updated successfully');
      }

      return AuthResult.success(message: 'Profile updated successfully!');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthService: Error updating profile: $e');
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
        debugPrint('AuthService: Deleting account for user: ${user.id}');
      }

      // Mark user as inactive instead of deleting
      await DatabaseService.deleteUser(user.id);

      // Note: Supabase doesn't have a direct delete user method in client SDK
      // This would typically be handled by a server-side function
      await signOut();

      if (kDebugMode) {
        debugPrint('AuthService: Account deleted successfully');
      }

      return AuthResult.success(message: 'Account deleted successfully!');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthService: Error deleting account: $e');
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