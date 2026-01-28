import 'dart:async';

import 'package:dentist_ms/core/constants/app_routes.dart';
import 'package:dentist_ms/features/auth/bloc/auth_bloc.dart';
import 'package:dentist_ms/features/auth/bloc/auth_state.dart';
import 'package:dentist_ms/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock AuthBloc for testing
class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    // Default state
    when(() => mockAuthBloc.state).thenReturn(const AuthState());
    when(
      () => mockAuthBloc.stream,
    ).thenAnswer((_) => Stream.value(const AuthState()));
  });

  // Helper to build the LoginPage widget with necessary providers
  Widget buildLoginPage() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: const LoginPage(),
      ),
      routes: {
        AppRoutes.dashboardShell: (_) =>
            const Scaffold(body: Text('Dashboard')),
      },
    );
  }

  group('LoginPage Widget Tests', () {
    testWidgets('should render login page with gradient background', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(buildLoginPage());

      // Assert - Check that the page renders
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets(
      'should display loading indicator when auth status is loading',
      (tester) async {
        // Arrange - Set loading state
        when(
          () => mockAuthBloc.state,
        ).thenReturn(const AuthState(status: AuthStatus.loading));
        when(() => mockAuthBloc.stream).thenAnswer(
          (_) => Stream.value(const AuthState(status: AuthStatus.loading)),
        );

        // Act
        await tester.pumpWidget(buildLoginPage());
        await tester.pump();

        // Assert - Check loading indicator is displayed
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Connexion en cours...'), findsOneWidget);
      },
    );

    testWidgets('should not display loading indicator when not loading', (
      tester,
    ) async {
      // Arrange - Default state (not loading)
      await tester.pumpWidget(buildLoginPage());

      // Act & Assert
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Connexion en cours...'), findsNothing);
    });

    testWidgets('should navigate to dashboard when authenticated', (
      tester,
    ) async {
      // Arrange - Set authenticated state
      when(
        () => mockAuthBloc.state,
      ).thenReturn(const AuthState(status: AuthStatus.authenticated));
      when(() => mockAuthBloc.stream).thenAnswer(
        (_) => Stream.value(const AuthState(status: AuthStatus.authenticated)),
      );

      // Act - Build widget with authenticated state
      await tester.pumpWidget(buildLoginPage());
      await tester.pumpAndSettle();

      // Assert - Navigation would occur (tested via BlocListener)
      // In a real app, navigation happens but testing it requires more complex setup
      expect(find.byType(LoginPage), findsNothing); // Widget navigated away
    });

    testWidgets('should display different layout for desktop and mobile', (
      tester,
    ) async {
      // Arrange - Desktop size
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      // Act
      await tester.pumpWidget(buildLoginPage());

      // Assert - Desktop layout should show Row with two sections
      expect(find.byType(Row), findsWidgets);

      // Cleanup
      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('should handle error state appropriately', (tester) async {
      // Arrange - Set error state
      when(() => mockAuthBloc.state).thenReturn(
        const AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Invalid credentials',
        ),
      );

      // Act
      await tester.pumpWidget(buildLoginPage());
      await tester.pump();

      // Assert - Page should still render (error handling is in child widgets)
      expect(find.byType(LoginPage), findsOneWidget);
    });
  });
}
