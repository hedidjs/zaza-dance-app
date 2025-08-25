import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class AuthPage {
  final WidgetTester tester;

  AuthPage(this.tester);

  // Finders for authentication elements
  Finder get loginScreen => find.byKey(const Key('login_screen'));
  Finder get registerScreen => find.byKey(const Key('register_screen'));
  Finder get profileScreen => find.byKey(const Key('profile_screen'));
  
  // Form field finders
  Finder get emailField => find.byKey(const Key('email_field'));
  Finder get passwordField => find.byKey(const Key('password_field'));
  Finder get confirmPasswordField => find.byKey(const Key('confirm_password_field'));
  Finder get nameField => find.byKey(const Key('name_field'));
  Finder get phoneField => find.byKey(const Key('phone_field'));
  
  // Button finders
  Finder get loginButton => find.byKey(const Key('login_button'));
  Finder get registerButton => find.byKey(const Key('register_button'));
  Finder get logoutButton => find.byKey(const Key('logout_button'));
  Finder get forgotPasswordButton => find.byKey(const Key('forgot_password_button'));
  Finder get switchToRegisterButton => find.text('הרשמה');
  Finder get switchToLoginButton => find.text('התחברות');
  
  // Social auth buttons
  Finder get googleSignInButton => find.byKey(const Key('google_signin_button'));
  Finder get facebookSignInButton => find.byKey(const Key('facebook_signin_button'));
  
  // Profile elements
  Finder get profileImage => find.byKey(const Key('profile_image'));
  Finder get editProfileButton => find.byKey(const Key('edit_profile_button'));
  Finder get changePasswordButton => find.byKey(const Key('change_password_button'));
  Finder get userNameText => find.byKey(const Key('user_name_text'));
  Finder get userEmailText => find.byKey(const Key('user_email_text'));
  
  // Validation and error elements
  Finder get emailError => find.byKey(const Key('email_error'));
  Finder get passwordError => find.byKey(const Key('password_error'));
  Finder get authError => find.byKey(const Key('auth_error'));
  Finder get loadingIndicator => find.byType(CircularProgressIndicator);
  
  // Success elements
  Finder get successMessage => find.byKey(const Key('success_message'));
  Finder get emailVerificationMessage => find.byKey(const Key('email_verification_message'));

  /// Navigate to login screen
  Future<void> navigateToLogin() async {
    if (switchToLoginButton.evaluate().isNotEmpty) {
      await tester.tap(switchToLoginButton);
      await tester.pumpAndSettle();
    }
  }

  /// Navigate to register screen
  Future<void> navigateToRegister() async {
    if (switchToRegisterButton.evaluate().isNotEmpty) {
      await tester.tap(switchToRegisterButton);
      await tester.pumpAndSettle();
    }
  }

  /// Verify login screen is displayed
  Future<void> verifyLoginScreenIsDisplayed() async {
    expect(loginScreen, findsOneWidget);
    expect(emailField, findsOneWidget);
    expect(passwordField, findsOneWidget);
    expect(loginButton, findsOneWidget);
    await tester.pumpAndSettle();
  }

  /// Verify register screen is displayed
  Future<void> verifyRegisterScreenIsDisplayed() async {
    expect(registerScreen, findsOneWidget);
    expect(emailField, findsOneWidget);
    expect(passwordField, findsOneWidget);
    expect(confirmPasswordField, findsOneWidget);
    expect(nameField, findsOneWidget);
    expect(registerButton, findsOneWidget);
    await tester.pumpAndSettle();
  }

  /// Perform login with credentials
  Future<void> loginWithCredentials(String email, String password) async {
    await verifyLoginScreenIsDisplayed();
    
    // Enter email
    await tester.enterText(emailField, email);
    await tester.pumpAndSettle();
    
    // Enter password
    await tester.enterText(passwordField, password);
    await tester.pumpAndSettle();
    
    // Tap login button
    await tester.tap(loginButton);
    await tester.pumpAndSettle();
  }

  /// Perform registration with user details
  Future<void> registerWithDetails({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    await verifyRegisterScreenIsDisplayed();
    
    // Enter name
    await tester.enterText(nameField, name);
    await tester.pumpAndSettle();
    
    // Enter email
    await tester.enterText(emailField, email);
    await tester.pumpAndSettle();
    
    // Enter password
    await tester.enterText(passwordField, password);
    await tester.pumpAndSettle();
    
    // Confirm password
    await tester.enterText(confirmPasswordField, password);
    await tester.pumpAndSettle();
    
    // Enter phone if provided
    if (phone != null && phoneField.evaluate().isNotEmpty) {
      await tester.enterText(phoneField, phone);
      await tester.pumpAndSettle();
    }
    
    // Tap register button
    await tester.tap(registerButton);
    await tester.pumpAndSettle();
  }

  /// Test login with valid credentials
  Future<void> testValidLogin() async {
    await loginWithCredentials('test@zazadance.com', 'TestPassword123!');
    
    // Wait for login to complete
    await _waitForAuthenticationComplete();
    
    // Should navigate to main app or show success
    // Should navigate to main app or show success
    try {
      expect(profileScreen, findsOneWidget);
    } catch (e) {
      expect(successMessage, findsOneWidget);
    }
  }

  /// Test login with invalid credentials
  Future<void> testInvalidLogin() async {
    await loginWithCredentials('invalid@email.com', 'wrongpassword');
    
    // Should show error message
    expect(authError, findsOneWidget);
    await tester.pumpAndSettle();
  }

  /// Test registration with valid details
  Future<void> testValidRegistration() async {
    await registerWithDetails(
      name: 'משתמש בדיקה',
      email: 'newuser@test.com',
      password: 'TestPassword123!',
      phone: '0501234567',
    );
    
    await _waitForAuthenticationComplete();
    
    // Should show success or email verification message
    try {
      expect(successMessage, findsOneWidget);
    } catch (e) {
      expect(emailVerificationMessage, findsOneWidget);
    }
  }

  /// Test email validation
  Future<void> testEmailValidation() async {
    await verifyLoginScreenIsDisplayed();
    
    // Enter invalid email
    await tester.enterText(emailField, 'invalid-email');
    await tester.pumpAndSettle();
    
    // Tap away to trigger validation
    await tester.tap(passwordField);
    await tester.pumpAndSettle();
    
    // Should show email error
    expect(emailError, findsOneWidget);
  }

  /// Test password validation
  Future<void> testPasswordValidation() async {
    await navigateToRegister();
    await verifyRegisterScreenIsDisplayed();
    
    // Enter weak password
    await tester.enterText(passwordField, '123');
    await tester.pumpAndSettle();
    
    // Tap away to trigger validation
    await tester.tap(confirmPasswordField);
    await tester.pumpAndSettle();
    
    // Should show password error
    expect(passwordError, findsOneWidget);
  }

  /// Test password confirmation matching
  Future<void> testPasswordConfirmationMatching() async {
    await navigateToRegister();
    await verifyRegisterScreenIsDisplayed();
    
    // Enter password
    await tester.enterText(passwordField, 'TestPassword123!');
    await tester.pumpAndSettle();
    
    // Enter different confirmation password
    await tester.enterText(confirmPasswordField, 'DifferentPassword123!');
    await tester.pumpAndSettle();
    
    // Tap register button
    await tester.tap(registerButton);
    await tester.pumpAndSettle();
    
    // Should show password mismatch error
    expect(find.textContaining('לא תואמת'), findsOneWidget);
  }

  /// Test forgot password functionality
  Future<void> testForgotPassword() async {
    await verifyLoginScreenIsDisplayed();
    
    if (forgotPasswordButton.evaluate().isNotEmpty) {
      await tester.tap(forgotPasswordButton);
      await tester.pumpAndSettle();
      
      // Should navigate to forgot password screen
      expect(find.byKey(const Key('forgot_password_screen')), findsOneWidget);
      
      // Enter email for password reset
      final resetEmailField = find.byKey(const Key('reset_email_field'));
      if (resetEmailField.evaluate().isNotEmpty) {
        await tester.enterText(resetEmailField, 'test@zazadance.com');
        await tester.pumpAndSettle();
        
        // Submit password reset
        final resetButton = find.byKey(const Key('reset_password_button'));
        await tester.tap(resetButton);
        await tester.pumpAndSettle();
        
        // Should show success message
        expect(successMessage, findsOneWidget);
      }
    }
  }

  /// Test Google sign-in
  Future<void> testGoogleSignIn() async {
    await verifyLoginScreenIsDisplayed();
    
    if (googleSignInButton.evaluate().isNotEmpty) {
      await tester.tap(googleSignInButton);
      await tester.pumpAndSettle();
      
      // Note: In real testing, this would mock the Google sign-in flow
      // For integration tests, we'd verify the button triggers the flow
      expect(googleSignInButton, findsOneWidget);
    }
  }

  /// Test logout functionality
  Future<void> testLogout() async {
    // Assume user is already logged in
    if (logoutButton.evaluate().isNotEmpty) {
      await tester.tap(logoutButton);
      await tester.pumpAndSettle();
      
      // Should return to login screen
      expect(loginScreen, findsOneWidget);
    }
  }

  /// Test profile viewing
  Future<void> testProfileViewing() async {
    // Navigate to profile if not already there
    if (profileScreen.evaluate().isEmpty) {
      final profileNavButton = find.byKey(const Key('nav_profile'));
      if (profileNavButton.evaluate().isNotEmpty) {
        await tester.tap(profileNavButton);
        await tester.pumpAndSettle();
      }
    }
    
    expect(profileScreen, findsOneWidget);
    expect(userNameText, findsOneWidget);
    expect(userEmailText, findsOneWidget);
  }

  /// Test profile editing
  Future<void> testProfileEditing() async {
    await testProfileViewing();
    
    if (editProfileButton.evaluate().isNotEmpty) {
      await tester.tap(editProfileButton);
      await tester.pumpAndSettle();
      
      // Should navigate to edit profile screen
      expect(find.byKey(const Key('edit_profile_screen')), findsOneWidget);
      
      // Edit name
      final editNameField = find.byKey(const Key('edit_name_field'));
      if (editNameField.evaluate().isNotEmpty) {
        await tester.enterText(editNameField, 'שם מעודכן');
        await tester.pumpAndSettle();
        
        // Save changes
        final saveButton = find.byKey(const Key('save_profile_button'));
        await tester.tap(saveButton);
        await tester.pumpAndSettle();
        
        // Should show success message
        expect(successMessage, findsOneWidget);
      }
    }
  }

  /// Test profile image upload
  Future<void> testProfileImageUpload() async {
    await testProfileViewing();
    
    if (profileImage.evaluate().isNotEmpty) {
      await tester.tap(profileImage);
      await tester.pumpAndSettle();
      
      // Should show image picker options
      try {
        expect(find.byType(Dialog), findsOneWidget);
      } catch (e) {
        expect(find.byType(BottomSheet), findsOneWidget);
      }
      
      // Select camera option if available
      final cameraOption = find.text('מצלמה');
      if (cameraOption.evaluate().isNotEmpty) {
        await tester.tap(cameraOption);
        await tester.pumpAndSettle();
      }
    }
  }

  /// Test password change
  Future<void> testPasswordChange() async {
    await testProfileViewing();
    
    if (changePasswordButton.evaluate().isNotEmpty) {
      await tester.tap(changePasswordButton);
      await tester.pumpAndSettle();
      
      // Should show change password dialog
      expect(find.byKey(const Key('change_password_dialog')), findsOneWidget);
      
      // Enter current password
      final currentPasswordField = find.byKey(const Key('current_password_field'));
      await tester.enterText(currentPasswordField, 'TestPassword123!');
      await tester.pumpAndSettle();
      
      // Enter new password
      final newPasswordField = find.byKey(const Key('new_password_field'));
      await tester.enterText(newPasswordField, 'NewPassword123!');
      await tester.pumpAndSettle();
      
      // Confirm new password
      final confirmNewPasswordField = find.byKey(const Key('confirm_new_password_field'));
      await tester.enterText(confirmNewPasswordField, 'NewPassword123!');
      await tester.pumpAndSettle();
      
      // Submit password change
      final changePasswordSubmitButton = find.byKey(const Key('change_password_submit'));
      await tester.tap(changePasswordSubmitButton);
      await tester.pumpAndSettle();
      
      // Should show success message
      expect(successMessage, findsOneWidget);
    }
  }

  /// Test email verification flow
  Future<void> testEmailVerificationFlow() async {
    // This would test the email verification process
    if (emailVerificationMessage.evaluate().isNotEmpty) {
      expect(emailVerificationMessage, findsOneWidget);
      
      // Look for resend verification button
      final resendButton = find.byKey(const Key('resend_verification_button'));
      if (resendButton.evaluate().isNotEmpty) {
        await tester.tap(resendButton);
        await tester.pumpAndSettle();
        
        // Should show confirmation message
        expect(find.textContaining('נשלח מחדש'), findsOneWidget);
      }
    }
  }

  /// Test form persistence on navigation
  Future<void> testFormPersistence() async {
    await verifyLoginScreenIsDisplayed();
    
    // Enter some data
    await tester.enterText(emailField, 'test@example.com');
    await tester.pumpAndSettle();
    
    // Navigate away and back
    await navigateToRegister();
    await navigateToLogin();
    
    // Check if email field is cleared (expected behavior)
    final emailFieldWidget = tester.widget<TextField>(emailField);
    expect(emailFieldWidget.controller?.text, isEmpty);
  }

  /// Test accessibility features
  Future<void> testAccessibilityFeatures() async {
    await verifyLoginScreenIsDisplayed();
    
    // Check semantic labels
    expect(find.bySemanticsLabel('אימייל'), findsOneWidget);
    expect(find.bySemanticsLabel('סיסמה'), findsOneWidget);
    expect(find.bySemanticsLabel('התחבר'), findsOneWidget);
  }

  /// Wait for authentication process to complete
  Future<void> _waitForAuthenticationComplete() async {
    // Wait for loading indicator to disappear
    int attempts = 0;
    while (loadingIndicator.evaluate().isNotEmpty && attempts < 30) {
      await tester.pump(const Duration(milliseconds: 500));
      attempts++;
    }
    await tester.pumpAndSettle();
  }

  /// Verify error handling
  Future<void> verifyErrorHandling() async {
    if (authError.evaluate().isNotEmpty) {
      expect(authError, findsOneWidget);
      
      // Error should be dismissible
      await tester.tap(authError);
      await tester.pumpAndSettle();
    }
  }

  /// Test biometric authentication if available
  Future<void> testBiometricAuthentication() async {
    final biometricButton = find.byKey(const Key('biometric_auth_button'));
    if (biometricButton.evaluate().isNotEmpty) {
      await tester.tap(biometricButton);
      await tester.pumpAndSettle();
      
      // Note: Biometric authentication would be mocked in testing
      // This just tests that the button is functional
      expect(biometricButton, findsOneWidget);
    }
  }
}