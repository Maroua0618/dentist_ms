/// Test Helpers and Utilities for Widget Testing
/// 
/// This file provides common utilities, mocks, and helper functions
/// used across all widget tests in the dentist management system.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper class for creating test widgets with Material wrapper
class WidgetTestHelper {
  /// Wraps a widget with MaterialApp for testing
  static Widget wrapWithMaterialApp(Widget child, {ThemeData? theme}) {
    return MaterialApp(
      theme: theme,
      home: child,
    );
  }

  /// Wraps a widget with MaterialApp and Scaffold for testing
  static Widget wrapWithScaffold(Widget child, {ThemeData? theme}) {
    return MaterialApp(
      theme: theme,
      home: Scaffold(
        body: child,
      ),
    );
  }

  /// Creates a Material app with routing for navigation tests
  static Widget wrapWithRoutes(
    Widget home,
    Map<String, WidgetBuilder> routes,
  ) {
    return MaterialApp(
      home: home,
      routes: routes,
    );
  }
}

/// Helper for finding widgets with retry logic
class FinderHelper {
  /// Finds a widget by key with optional retry
  static Future<Finder> findByKeyWithRetry(
    WidgetTester tester,
    Key key, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(milliseconds: 100),
  }) async {
    for (int i = 0; i < maxRetries; i++) {
      await tester.pump();
      final finder = find.byKey(key);
      if (finder.evaluate().isNotEmpty) {
        return finder;
      }
      await Future.delayed(retryDelay);
    }
    return find.byKey(key);
  }

  /// Finds text widget ignoring case
  static Finder findTextIgnoreCase(String text) {
    return find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data?.toLowerCase() == text.toLowerCase(),
    );
  }
}

/// Helper for common test interactions
class InteractionHelper {
  /// Taps a button and waits for animations
  static Future<void> tapAndSettle(
    WidgetTester tester,
    Finder finder,
  ) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// Enters text and waits for updates
  static Future<void> enterTextAndSettle(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }

  /// Scrolls until a widget is visible
  static Future<void> scrollUntilVisible(
    WidgetTester tester,
    Finder item,
    Finder scrollable, {
    double delta = 300.0,
  }) async {
    await tester.scrollUntilVisible(
      item,
      delta,
      scrollable: scrollable,
    );
  }
}

/// Helper for verifying widget properties
class VerificationHelper {
  /// Verifies text style properties
  static void verifyTextStyle(
    WidgetTester tester,
    String text, {
    FontWeight? fontWeight,
    double? fontSize,
    Color? color,
  }) {
    final textWidget = tester.widget<Text>(find.text(text));
    if (fontWeight != null) {
      expect(textWidget.style?.fontWeight, fontWeight);
    }
    if (fontSize != null) {
      expect(textWidget.style?.fontSize, fontSize);
    }
    if (color != null) {
      expect(textWidget.style?.color, color);
    }
  }

  /// Verifies icon properties
  static void verifyIcon(
    WidgetTester tester,
    IconData iconData, {
    Color? color,
    double? size,
  }) {
    final iconWidget = tester.widget<Icon>(find.byIcon(iconData));
    if (color != null) {
      expect(iconWidget.color, color);
    }
    if (size != null) {
      expect(iconWidget.size, size);
    }
  }

  /// Verifies widget exists in tree
  static void verifyWidgetExists(Type widgetType, {int count = 1}) {
    expect(find.byType(widgetType), findsNWidgets(count));
  }
}

/// Mock data generators for tests
class MockDataGenerator {
  /// Generates a mock patient map
  static Map<String, dynamic> mockPatient({
    int id = 1,
    String firstName = 'John',
    String lastName = 'Doe',
    String email = 'john.doe@example.com',
    String phone = '555-0100',
    String status = 'active',
  }) {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone1': phone,
      'status': status,
      'gender': 'male',
      'date_of_birth': '1990-01-01',
    };
  }

  /// Generates a mock appointment map
  static Map<String, dynamic> mockAppointment({
    int id = 1,
    int patientId = 1,
    int doctorId = 1,
    String date = '2024-01-15',
    String time = '10:00',
    String status = 'confirmed',
  }) {
    return {
      'id': id,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'appointment_date': date,
      'appointment_time': time,
      'status': status,
      'notes': 'Test appointment',
    };
  }

  /// Generates a mock invoice map
  static Map<String, dynamic> mockInvoice({
    int id = 1,
    String invoiceNumber = 'INV-001',
    int patientId = 1,
    double amount = 250.00,
    String status = 'paid',
  }) {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'patient_id': patientId,
      'total_amount': amount,
      'status': status,
      'invoice_date': '2024-01-15',
    };
  }

  /// Generates a mock treatment map
  static Map<String, dynamic> mockTreatment({
    int id = 1,
    String name = 'Dental Cleaning',
    String category = 'Preventive',
    double basePrice = 100.00,
  }) {
    return {
      'id': id,
      'name': name,
      'category': category,
      'base_price': basePrice,
      'duration': 30,
      'description': 'Professional teeth cleaning',
    };
  }
}

/// Custom matchers for widget testing
class CustomMatchers {
  /// Matcher for verifying widget visibility
  static Matcher isVisible() {
    return _IsVisibleMatcher();
  }

  /// Matcher for verifying widget is enabled
  static Matcher isEnabled() {
    return _IsEnabledMatcher();
  }
}

class _IsVisibleMatcher extends Matcher {
  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! Finder) return false;
    return item.evaluate().isNotEmpty;
  }

  @override
  Description describe(Description description) {
    return description.add('widget is visible');
  }
}

class _IsEnabledMatcher extends Matcher {
  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! Widget) return false;
    if (item is ElevatedButton) {
      return item.onPressed != null;
    }
    if (item is TextButton) {
      return item.onPressed != null;
    }
    if (item is IconButton) {
      return item.onPressed != null;
    }
    return false;
  }

  @override
  Description describe(Description description) {
    return description.add('widget is enabled');
  }
}

/// Screen size presets for responsive testing
class TestScreenSizes {
  static const Size mobile = Size(375, 667); // iPhone SE
  static const Size tablet = Size(768, 1024); // iPad
  static const Size desktop = Size(1920, 1080); // Full HD
  static const Size smallDesktop = Size(1366, 768); // Laptop
}

/// Helper to set screen size for testing
class ScreenSizeHelper {
  /// Sets the screen size for testing responsive layouts
  static void setScreenSize(
    WidgetTester tester,
    Size size, {
    double devicePixelRatio = 1.0,
  }) {
    tester.view.physicalSize = size * devicePixelRatio;
    tester.view.devicePixelRatio = devicePixelRatio;
  }

  /// Resets screen size to default
  static void resetScreenSize(WidgetTester tester) {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  }
}
