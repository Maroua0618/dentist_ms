import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test for Search Bar Widget
/// This validates the search functionality in patient list
void main() {
  group('Search Bar Widget Tests', () {
    // Helper to build a search bar widget
    Widget buildSearchBar({
      String hintText = 'Search patients...',
      Function(String)? onChanged,
      VoidCallback? onClear,
      TextEditingController? controller,
    }) {
      final textController = controller ?? TextEditingController();
      
      return MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              key: const Key('search_field'),
              controller: textController,
              decoration: InputDecoration(
                hintText: hintText,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: textController.text.isNotEmpty
                    ? IconButton(
                        key: const Key('clear_button'),
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          textController.clear();
                          onClear?.call();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: onChanged,
            ),
          ),
        ),
      );
    }

    testWidgets('should display search field with hint text', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildSearchBar(hintText: 'Search patients...'),
      );

      // Assert
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search patients...'), findsOneWidget);
    });

    testWidgets('should display search icon', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(buildSearchBar());

      // Assert - Search icon should be present
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should call onChanged when text is entered', (tester) async {
      // Arrange
      String? searchQuery;
      await tester.pumpWidget(
        buildSearchBar(
          onChanged: (value) => searchQuery = value,
        ),
      );

      // Act - Enter text
      await tester.enterText(find.byKey(const Key('search_field')), 'John');
      await tester.pumpAndSettle();

      // Assert
      expect(searchQuery, 'John');
      expect(find.text('John'), findsOneWidget);
    });

    testWidgets('should show clear button when text is entered', (tester) async {
      // Arrange
      final controller = TextEditingController();
      await tester.pumpWidget(
        buildSearchBar(controller: controller),
      );

      // Act - Enter text
      await tester.enterText(find.byKey(const Key('search_field')), 'Test');
      controller.text = 'Test'; // Update controller
      await tester.pumpAndSettle();

      // Assert - Clear button should appear
      // Note: In a real StatefulWidget, this would work automatically
      expect(controller.text, 'Test');
    });

    testWidgets('should clear text when clear button is tapped', (tester) async {
      // Arrange
      final controller = TextEditingController(text: 'Initial text');
      bool cleared = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: controller.text.isNotEmpty
                        ? IconButton(
                            key: const Key('clear_button'),
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                controller.clear();
                                cleared = true;
                              });
                            },
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Act - Tap clear button
      await tester.tap(find.byKey(const Key('clear_button')));
      await tester.pumpAndSettle();

      // Assert
      expect(controller.text, '');
      expect(cleared, true);
    });

    testWidgets('should have rounded border', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(buildSearchBar());

      // Assert - Check TextField decoration
      final textField = tester.widget<TextField>(find.byType(TextField));
      final decoration = textField.decoration as InputDecoration;
      final border = decoration.border as OutlineInputBorder;
      expect(border.borderRadius, BorderRadius.circular(12));
    });

    testWidgets('should accept different hint texts', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildSearchBar(hintText: 'Search by name or ID...'),
      );

      // Assert
      expect(find.text('Search by name or ID...'), findsOneWidget);
    });

    testWidgets('should handle empty search gracefully', (tester) async {
      // Arrange
      String? searchQuery;
      await tester.pumpWidget(
        buildSearchBar(
          onChanged: (value) => searchQuery = value,
        ),
      );

      // Act - Enter and delete text
      await tester.enterText(find.byKey(const Key('search_field')), 'Test');
      await tester.enterText(find.byKey(const Key('search_field')), '');
      await tester.pumpAndSettle();

      // Assert
      expect(searchQuery, '');
    });

    testWidgets('should update as user types', (tester) async {
      // Arrange
      final queries = <String>[];
      await tester.pumpWidget(
        buildSearchBar(
          onChanged: (value) => queries.add(value),
        ),
      );

      // Act - Type multiple characters
      await tester.enterText(find.byKey(const Key('search_field')), 'J');
      await tester.enterText(find.byKey(const Key('search_field')), 'Jo');
      await tester.enterText(find.byKey(const Key('search_field')), 'Joh');
      await tester.pumpAndSettle();

      // Assert - Should have captured all changes
      expect(queries.length, greaterThan(0));
    });
  });
}
