import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:eco_tracker/views/home/home_view.dart';
import 'package:eco_tracker/services/tips_service.dart';

// Create a mock TipsService
class MockTipsService extends Mock implements TipsService {}

void main() {
  late MockTipsService mockTipsService;

  setUp(() {
    mockTipsService = MockTipsService();
  });

  // Helper function to create the widget with mocked dependencies
  Widget createHomeViewUnderTest() {
    return MaterialApp(
      home: HomeView(),
    );
  }

  group('HomeView - Tip of the Day', () {
    testWidgets('shows loading indicator while waiting for tip',
        (tester) async {
      // Arrange - delay the response to test loading state
      when(mockTipsService.getTodaysTip()).thenAnswer(
        (_) => Future.delayed(const Duration(seconds: 1), () => 'Test tip'),
      );

      // Act
      await tester.pumpWidget(createHomeViewUnderTest());
      await tester.pump(); // initial build

      // Assert - loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Tip of the Day'), findsNothing);

      // Complete the future
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('displays tip card when data is loaded', (tester) async {
      // Arrange
      const testTip = 'Turn off lights when leaving a room.';
      when(mockTipsService.getTodaysTip()).thenAnswer((_) async => testTip);

      // Act
      await tester.pumpWidget(createHomeViewUnderTest());
      await tester.pumpAndSettle(); // wait for future to complete

      // Assert
      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Tip of the Day'), findsOneWidget);
      expect(find.text(testTip), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('displays error message when tip loading fails',
        (tester) async {
      // Arrange
      when(mockTipsService.getTodaysTip())
          .thenThrow(Exception('Failed to load'));

      // Act
      await tester.pumpWidget(createHomeViewUnderTest());
      await tester.pump(); // initial build
      await tester.pump(); // error state

      // Assert
      expect(find.text('Error: Exception: Failed to load'), findsOneWidget);
      expect(find.byType(Card), findsNothing);
    });

    testWidgets('displays "No tip available" when data is null',
        (tester) async {
      // Arrange
      when(mockTipsService.getTodaysTip())
          .thenAnswer((_) async => 'No tips available');

      // Act
      await tester.pumpWidget(createHomeViewUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No tip available'), findsOneWidget);
      expect(find.byType(Card), findsNothing);
    });

    testWidgets('card has correct styling', (tester) async {
      // Arrange
      const testTip = 'Test tip';
      when(mockTipsService.getTodaysTip()).thenAnswer((_) async => testTip);

      // Act
      await tester.pumpWidget(createHomeViewUnderTest());
      await tester.pumpAndSettle();

      // Assert
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.margin, equals(const EdgeInsets.all(16)));

      // Verify the card uses the correct theme color
      final colorScheme =
          Theme.of(tester.element(find.byType(Card))).colorScheme;
      expect(card.color, equals(colorScheme.tertiaryContainer));
    });
  });

  group('HomeView - GeneralPage Integration', () {
    testWidgets('inherits GeneralPage properties correctly', (tester) async {
      // Arrange
      when(mockTipsService.getTodaysTip()).thenAnswer((_) async => 'Test tip');

      // Act
      await tester.pumpWidget(createHomeViewUnderTest());
      await tester.pumpAndSettle();

      // Assert
      // Verify title from GeneralPage
      expect(find.text('Home'), findsOneWidget);

      // Verify FAB from GeneralPage
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.bolt), findsOneWidget);
    });
  });
}
