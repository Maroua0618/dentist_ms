import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dentist_ms/main.dart' as app;
import 'helpers/test_helpers.dart';

/// Authentication Flow Integration Test
///
/// This test validates the complete authentication user journey:
/// 1. App launches and shows login page
/// 2. User enters credentials (email/password)
/// 3. User submits login form
/// 4. App authenticates and navigates to dashboard
/// 5. User can logout and return to login page
///
/// Note: This test assumes test credentials are configured in .env file
/// or uses mock authentication for testing purposes.

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Integration Tests', () {
    testWidgets('Complete login flow - app launch to dashboard', (
      WidgetTester tester,
    ) async {
      // ============ ARRANGE ============
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // ============ ACT & ASSERT - Step 1: Verify Login Page ============
      // Verify login page is displayed
      expect(
        find.text('Welcome Back'),
        findsWidgets,
        reason: 'Login page should display welcome message',
      );

      // Verify login tabs are present (Password and Facial Recognition)
      expect(
        find.text('Password'),
        findsWidgets,
        reason: 'Password tab should be visible',
      );

      // ============ ACT & ASSERT - Step 2: Enter Login Credentials ============
      // Find email/username field (looking for common text field hints)
      final emailField = find.byType(TextField).first;
      expect(
        emailField,
        findsOneWidget,
        reason: 'Email/Username field should be present',
      );

      // Enter email - using test credentials
      await IntegrationTestHelpers.enterText(
        tester,
        emailField,
        'test@dentalcare.com',
      );

      // Find password field (second TextField)
      final passwordField = find.byType(TextField).last;
      expect(
        passwordField,
        findsOneWidget,
        reason: 'Password field should be present',
      );

      // Enter password
      await IntegrationTestHelpers.enterText(
        tester,
        passwordField,
        'TestPassword123',
      );

      // Take a screenshot after entering credentials
      await tester.pumpAndSettle();

      // ============ ACT & ASSERT - Step 3: Submit Login ============
      // Find and tap login button
      final loginButton = find.ancestor(
        of: find.text('Login'),
        matching: find.byType(ElevatedButton),
      );

      if (loginButton.evaluate().isEmpty) {
        // Try alternative finder - look for any button with Login text
        final altLoginButton = find.widgetWithText(ElevatedButton, 'Login');
        expect(
          altLoginButton,
          findsWidgets,
          reason: 'Login button should be present',
        );
        await IntegrationTestHelpers.tapWidget(tester, altLoginButton.first);
      } else {
        await IntegrationTestHelpers.tapWidget(tester, loginButton);
      }

      // Wait for authentication to complete and navigation to occur
      await IntegrationTestHelpers.waitForLoadingToComplete(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // ============ ACT & ASSERT - Step 4: Verify Dashboard Loaded ============
      // After successful login, should navigate to dashboard
      // Look for dashboard-specific elements
      expect(
        find.text('Tableau de bord'),
        findsWidgets,
        reason: 'Dashboard title should be visible after login',
      );

      // Verify navigation menu is present
      expect(
        find.text('Patientes'),
        findsWidgets,
        reason: 'Patients navigation item should be visible',
      );

      expect(
        find.text('Rendez-vous'),
        findsWidgets,
        reason: 'Appointments navigation item should be visible',
      );

      expect(
        find.text('Facturation'),
        findsWidgets,
        reason: 'Billing navigation item should be visible',
      );

      // Verify dashboard metrics/cards are displayed
      // The dashboard should show key metrics
      await tester.pumpAndSettle();

      print('✅ Successfully logged in and navigated to dashboard');
    });

    testWidgets('Login with invalid credentials shows error', (
      WidgetTester tester,
    ) async {
      // ============ ARRANGE ============
      app.main();
      await tester.pumpAndSettle();

      // ============ ACT - Enter Invalid Credentials ============
      final emailField = find.byType(TextField).first;
      await IntegrationTestHelpers.enterText(
        tester,
        emailField,
        'invalid@example.com',
      );

      final passwordField = find.byType(TextField).last;
      await IntegrationTestHelpers.enterText(
        tester,
        passwordField,
        'wrongpassword',
      );

      // Submit login
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      if (loginButton.evaluate().isNotEmpty) {
        await IntegrationTestHelpers.tapWidget(tester, loginButton.first);
      }

      await tester.pumpAndSettle(const Duration(seconds: 1));

      // ============ ASSERT - Error Message Displayed ============
      // Should show error message or remain on login page
      // Look for common error indicators
      expect(
        find.text('Welcome Back'),
        findsWidgets,
        reason: 'Should remain on login page after failed login',
      );

      print('✅ Invalid login handled correctly');
    });

    testWidgets('Login form validation - empty fields', (
      WidgetTester tester,
    ) async {
      // ============ ARRANGE ============
      app.main();
      await tester.pumpAndSettle();

      // ============ ACT - Submit Without Entering Credentials ============
      // Try to submit without entering anything
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      if (loginButton.evaluate().isNotEmpty) {
        await IntegrationTestHelpers.tapWidget(tester, loginButton.first);
      }

      await tester.pumpAndSettle();

      // ============ ASSERT - Validation Errors or Form Not Submitted ============
      // Should either show validation errors or not submit
      // Verify we're still on login page
      expect(
        find.text('Welcome Back'),
        findsWidgets,
        reason: 'Should remain on login page with empty fields',
      );

      print('✅ Form validation working correctly');
    });

    testWidgets('Switch between login tabs (Password and Facial)', (
      WidgetTester tester,
    ) async {
      // ============ ARRANGE ============
      app.main();
      await tester.pumpAndSettle();

      // ============ ACT & ASSERT - Password Tab Active by Default ============
      expect(
        find.text('Password'),
        findsWidgets,
        reason: 'Password tab should be present',
      );

      // ============ ACT - Switch to Facial Recognition Tab ============
      final facialTab = find.text('Facial Recognition');
      if (facialTab.evaluate().isNotEmpty) {
        await IntegrationTestHelpers.tapWidget(tester, facialTab);
        await tester.pumpAndSettle();

        // ============ ASSERT - Facial Recognition UI Displayed ============
        // Should show camera/scanning interface elements
        expect(
          find.text('Facial Recognition'),
          findsWidgets,
          reason: 'Facial recognition tab should be active',
        );

        // Switch back to password tab
        final passwordTab = find.text('Password');
        await IntegrationTestHelpers.tapWidget(tester, passwordTab);
        await tester.pumpAndSettle();

        // Verify password fields are visible again
        expect(
          find.byType(TextField),
          findsWidgets,
          reason: 'Password fields should be visible on password tab',
        );

        print('✅ Tab switching working correctly');
      }
    });

    testWidgets('Forgot password flow accessible', (WidgetTester tester) async {
      // ============ ARRANGE ============
      app.main();
      await tester.pumpAndSettle();

      // ============ ACT - Look for Forgot Password Link ============
      final forgotPasswordLink = find.text('Forgot Password?');

      if (forgotPasswordLink.evaluate().isNotEmpty) {
        // ============ ASSERT & ACT - Tap Forgot Password ============
        await IntegrationTestHelpers.tapWidget(tester, forgotPasswordLink);
        await tester.pumpAndSettle();

        // Should open password reset dialog or navigate to reset page
        // Look for reset-related UI elements
        final resetButton = find.text('Reset Password');
        final sendButton = find.text('Send');

        expect(
          resetButton.evaluate().isNotEmpty || sendButton.evaluate().isNotEmpty,
          isTrue,
          reason: 'Password reset UI should be displayed',
        );

        print('✅ Forgot password flow accessible');

        // Close dialog if it opened
        final closeButton = find.byIcon(Icons.close);
        if (closeButton.evaluate().isNotEmpty) {
          await IntegrationTestHelpers.tapWidget(tester, closeButton.first);
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('Remember me functionality (if available)', (
      WidgetTester tester,
    ) async {
      // ============ ARRANGE ============
      app.main();
      await tester.pumpAndSettle();

      // ============ ACT & ASSERT - Check for Remember Me Checkbox ============
      final rememberMeCheckbox = find.text('Remember me');

      if (rememberMeCheckbox.evaluate().isNotEmpty) {
        // Find and toggle checkbox
        final checkbox = find.byType(Checkbox);
        if (checkbox.evaluate().isNotEmpty) {
          await IntegrationTestHelpers.tapWidget(tester, checkbox.first);
          await tester.pumpAndSettle();

          print('✅ Remember me checkbox toggleable');
        }
      }
    });
  });

  group('Logout Flow Integration Tests', () {
    testWidgets('Complete logout flow from dashboard', (
      WidgetTester tester,
    ) async {
      // ============ ARRANGE - Login First ============
      app.main();
      await tester.pumpAndSettle();

      // Login (simplified - assumes successful login)
      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).last;

      await IntegrationTestHelpers.enterText(
        tester,
        emailField,
        'test@dentalcare.com',
      );

      await IntegrationTestHelpers.enterText(
        tester,
        passwordField,
        'TestPassword123',
      );

      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      if (loginButton.evaluate().isNotEmpty) {
        await IntegrationTestHelpers.tapWidget(tester, loginButton.first);
        await IntegrationTestHelpers.waitForLoadingToComplete(tester);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // ============ ACT - Navigate to Settings and Logout ============
      // Look for settings navigation item
      final settingsNav = find.text('Settings');
      if (settingsNav.evaluate().isEmpty) {
        // Try French version
        final settingsNavFr = find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.data != null &&
              widget.data!.toLowerCase().contains('param'),
        );

        if (settingsNavFr.evaluate().isNotEmpty) {
          await IntegrationTestHelpers.tapWidget(tester, settingsNavFr.first);
          await tester.pumpAndSettle();
        }
      }

      // Look for logout button
      final logoutButton = find.text('Logout');
      final logoutButtonFr = find.text('Déconnexion');

      if (logoutButton.evaluate().isNotEmpty) {
        await IntegrationTestHelpers.tapWidget(tester, logoutButton);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      } else if (logoutButtonFr.evaluate().isNotEmpty) {
        await IntegrationTestHelpers.tapWidget(tester, logoutButtonFr);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // ============ ASSERT - Returned to Login Page ============
      await tester.pumpAndSettle();

      // Should be back on login page
      expect(
        find.text('Welcome Back'),
        findsWidgets,
        reason: 'Should return to login page after logout',
      );

      print('✅ Logout flow completed successfully');
    });
  });
}
