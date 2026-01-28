import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Mock Supabase Client for integration tests
///
/// This provides a test-safe mock of Supabase that doesn't make real network calls.
/// Use this to simulate authentication and database operations.
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockAuthResponse extends Mock implements AuthResponse {}

class MockUser extends Mock implements User {}

class MockSession extends Mock implements Session {}

class MockPostgrestQueryBuilder extends Mock implements PostgrestQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder {}

class MockPostgrestBuilder extends Mock implements PostgrestBuilder {}

/// Test Data Factory
///
/// Generates realistic test data for integration tests
class TestDataFactory {
  // ============ Patient Test Data ============

  static Map<String, dynamic> createTestPatient({
    String? id,
    String name = 'Test Patient',
    String email = 'test.patient@example.com',
    String phone = '+1234567890',
    String address = '123 Test Street',
    String gender = 'Male',
    String bloodType = 'O+',
    DateTime? dateOfBirth,
    String allergies = 'None',
    String insuranceProvider = 'Test Insurance',
  }) {
    return {
      'id': id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'gender': gender,
      'blood_type': bloodType,
      'date_of_birth': (dateOfBirth ?? DateTime(1990, 1, 1)).toIso8601String(),
      'allergies': allergies,
      'insurance_provider': insuranceProvider,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  static List<Map<String, dynamic>> createTestPatients(int count) {
    return List.generate(
      count,
      (index) => createTestPatient(
        name: 'Patient ${index + 1}',
        email: 'patient${index + 1}@example.com',
      ),
    );
  }

  // ============ Appointment Test Data ============

  static Map<String, dynamic> createTestAppointment({
    String? id,
    String? patientId,
    String patientName = 'Test Patient',
    String doctorName = 'Dr. Smith',
    DateTime? date,
    String time = '10:00 AM',
    String treatment = 'Cleaning',
    String status = 'scheduled',
    String notes = 'Regular checkup',
  }) {
    return {
      'id': id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'patient_id': patientId ?? '1',
      'patient_name': patientName,
      'doctor_name': doctorName,
      'date': (date ?? DateTime.now().add(const Duration(days: 1)))
          .toIso8601String(),
      'time': time,
      'treatment': treatment,
      'status': status,
      'notes': notes,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  static List<Map<String, dynamic>> createTestAppointments(int count) {
    return List.generate(
      count,
      (index) => createTestAppointment(
        patientName: 'Patient ${index + 1}',
        date: DateTime.now().add(Duration(days: index + 1)),
      ),
    );
  }

  // ============ Invoice/Billing Test Data ============

  static Map<String, dynamic> createTestInvoice({
    String? id,
    String? patientId,
    String patientName = 'Test Patient',
    String treatment = 'Cleaning',
    double amount = 150.0,
    DateTime? date,
    String status = 'pending',
    String notes = 'Regular service',
  }) {
    return {
      'id': id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'patient_id': patientId ?? '1',
      'patient_name': patientName,
      'treatment': treatment,
      'amount': amount,
      'date': (date ?? DateTime.now()).toIso8601String(),
      'status': status,
      'notes': notes,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  static Map<String, dynamic> createTestPayment({
    String? id,
    String? invoiceId,
    double amount = 150.0,
    String method = 'Cash',
    DateTime? date,
    String notes = 'Payment received',
  }) {
    return {
      'id': id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'invoice_id': invoiceId ?? '1',
      'amount': amount,
      'method': method,
      'date': (date ?? DateTime.now()).toIso8601String(),
      'notes': notes,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  // ============ User/Auth Test Data ============

  static Map<String, dynamic> createTestUser({
    String id = 'test-user-id',
    String email = 'test@example.com',
    String role = 'doctor',
  }) {
    return {
      'id': id,
      'email': email,
      'role': role,
      'user_metadata': {'name': 'Test User'},
    };
  }
}

/// Test Helpers for Integration Tests
class IntegrationTestHelpers {
  /// Login to the app with test credentials
  static Future<void> loginToApp(
    WidgetTester tester, {
    String email = 'test@dentalcare.com',
    String password = 'TestPassword123',
  }) async {
    // Wait for login screen to fully load
    await waitForWidget(
      tester,
      find.byType(TextField),
      timeout: const Duration(seconds: 10),
    );

    // Find email field by hint text or fallback to index
    final emailField = find.widgetWithText(TextField, 'dr. smith@dentalai.com');
    final allFields = find.byType(TextField);

    if (allFields.evaluate().length >= 2) {
      await enterText(tester, allFields.at(0), email);
      await enterText(tester, allFields.at(1), password);
    } else {
      throw Exception('Could not find email and password fields');
    }

    // Find and tap login button (French: "Se connecter")
    await Future.delayed(const Duration(milliseconds: 500));
    final loginButton = find.text('Se connecter');
    if (loginButton.evaluate().isNotEmpty) {
      await tester.tap(loginButton.first);
      await tester.pumpAndSettle();
    } else {
      // Fallback: try to find button by type
      final button = find.byType(ElevatedButton);
      if (button.evaluate().isNotEmpty) {
        await tester.tap(button.first);
        await tester.pumpAndSettle();
      }
    }

    // Wait for navigation to complete
    await waitForLoadingToComplete(tester);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  /// Navigate to appointments screen
  static Future<void> navigateToAppointments(WidgetTester tester) async {
    await Future.delayed(const Duration(seconds: 1));

    // Try to find appointments navigation button/tab
    final appointmentsButton = find.text('Rendez-vous');
    final appointmentsIcon = find.byIcon(Icons.calendar_today);

    if (appointmentsButton.evaluate().isNotEmpty) {
      await tester.tap(appointmentsButton.first);
      await tester.pumpAndSettle();
    } else if (appointmentsIcon.evaluate().isNotEmpty) {
      await tester.tap(appointmentsIcon.first);
      await tester.pumpAndSettle();
    } else {
      print('⚠️ Could not find appointments navigation button');
    }

    await Future.delayed(const Duration(seconds: 1));
  }

  /// Navigate to patients screen
  static Future<void> navigateToPatients(WidgetTester tester) async {
    await Future.delayed(const Duration(seconds: 1));

    // Try to find patients navigation button/tab
    final patientsButton = find.text('Patientes');
    final patientsIcon = find.byIcon(Icons.people);

    if (patientsButton.evaluate().isNotEmpty) {
      await tester.tap(patientsButton.first);
      await tester.pumpAndSettle();
    } else if (patientsIcon.evaluate().isNotEmpty) {
      await tester.tap(patientsIcon.first);
      await tester.pumpAndSettle();
    } else {
      print('⚠️ Could not find patients navigation button');
    }

    await Future.delayed(const Duration(seconds: 1));
  }

  /// Navigate to billing screen
  static Future<void> navigateToBilling(WidgetTester tester) async {
    await Future.delayed(const Duration(seconds: 1));

    // Try to find billing navigation button/tab
    final billingButton = find.text('Facturation');
    final billingIcon = find.byIcon(Icons.receipt);

    if (billingButton.evaluate().isNotEmpty) {
      await tester.tap(billingButton.first);
      await tester.pumpAndSettle();
    } else if (billingIcon.evaluate().isNotEmpty) {
      await tester.tap(billingIcon.first);
      await tester.pumpAndSettle();
    } else {
      print('⚠️ Could not find billing navigation button');
    }

    await Future.delayed(const Duration(seconds: 1));
  }

  /// Wait for a widget to appear with timeout
  static Future<void> waitForWidget(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final endTime = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(endTime)) {
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      if (finder.evaluate().isNotEmpty) {
        return;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
    throw Exception('Widget not found within timeout: $finder');
  }

  /// Enter text into a field with proper settling
  static Future<void> enterText(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    // Wait for the widget to appear
    await waitForWidget(tester, finder);

    // Ensure it's visible and tap it
    if (finder.evaluate().isNotEmpty) {
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pumpAndSettle();
      await tester.enterText(finder, text);
      await tester.pumpAndSettle();
    } else {
      throw Exception('Widget not found: $finder');
    }
  }

  /// Tap a widget with proper settling
  static Future<void> tapWidget(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// Scroll until a widget is visible
  static Future<void> scrollUntilVisible(
    WidgetTester tester,
    Finder finder,
    Finder scrollable, {
    double delta = 100,
    int maxScrolls = 50,
  }) async {
    for (int i = 0; i < maxScrolls; i++) {
      if (finder.evaluate().isNotEmpty) {
        return;
      }
      await tester.drag(scrollable, Offset(0, -delta));
      await tester.pumpAndSettle();
    }
    throw Exception('Widget not found after scrolling: $finder');
  }

  /// Wait for loading to complete
  static Future<void> waitForLoadingToComplete(
    WidgetTester tester, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final endTime = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(endTime)) {
      await tester.pumpAndSettle(const Duration(milliseconds: 100));

      // Check for common loading indicators
      final circularProgress = find.byType(CircularProgressIndicator);
      final linearProgress = find.byType(LinearProgressIndicator);

      if (circularProgress.evaluate().isEmpty &&
          linearProgress.evaluate().isEmpty) {
        return;
      }

      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Select a dropdown item
  static Future<void> selectDropdownItem(
    WidgetTester tester,
    Finder dropdownFinder,
    String itemText,
  ) async {
    await tapWidget(tester, dropdownFinder);
    await tester.pumpAndSettle();

    final itemFinder = find.text(itemText).last;
    await tapWidget(tester, itemFinder);
  }

  /// Pick a date from date picker
  static Future<void> pickDate(
    WidgetTester tester,
    Finder dateFieldFinder,
    DateTime date,
  ) async {
    await tapWidget(tester, dateFieldFinder);
    await tester.pumpAndSettle();

    // Tap OK button on date picker
    final okButton = find.text('OK');
    if (okButton.evaluate().isNotEmpty) {
      await tapWidget(tester, okButton);
    }
  }

  /// Verify text exists
  static void verifyTextExists(String text) {
    expect(find.text(text), findsOneWidget);
  }

  /// Verify widget exists
  static void verifyWidgetExists(Finder finder) {
    expect(finder, findsOneWidget);
  }

  /// Verify multiple widgets exist
  static void verifyWidgetsExist(Finder finder, int count) {
    expect(finder, findsNWidgets(count));
  }
}
