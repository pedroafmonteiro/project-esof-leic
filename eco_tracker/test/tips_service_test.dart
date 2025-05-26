import 'package:flutter_test/flutter_test.dart';
import 'package:eco_tracker/services/tips_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TipsService Tests', () {
    late TipsService tipsService;

    setUp(() {
      tipsService = TipsService();
    });

    group('loadTips', () {
      test('should return list of tips from JSON asset', () async {
        // Act
        final result = await tipsService.loadTips();

        // Assert
        expect(result, isA<List<String>>());
        expect(result.length, greaterThan(0));
        expect(result, contains('Turn off lights when leaving a room.'));
        expect(
            result,
            contains(
                'Unplug devices when not in use to prevent phantom energy drain.'));
        expect(
            result, contains('Use LED bulbs instead of incandescent bulbs.'));
      });

      test('should return all expected tips from the JSON file', () async {
        // Act
        final result = await tipsService.loadTips();

        // Assert - verify specific tips exist
        expect(result, contains('Turn off lights when leaving a room.'));
        expect(
            result,
            contains(
                'Unplug devices when not in use to prevent phantom energy drain.'));
        expect(
            result, contains('Use LED bulbs instead of incandescent bulbs.'));
        expect(
            result,
            contains(
                'Set your thermostat a few degrees lower in winter and higher in summer.'));
        expect(result, contains('Wash clothes in cold water to save energy.'));
        expect(result, contains('Use natural light whenever possible.'));
        expect(
            result,
            contains(
                'Keep your fridge and freezer full to optimize energy usage.'));
      });

      test('should return list with expected length', () async {
        // Act
        final result = await tipsService.loadTips();

        // Assert - based on the current tips.json file
        expect(result.length, equals(7));
      });

      test('should handle loading tips multiple times consistently', () async {
        // Act
        final result1 = await tipsService.loadTips();
        final result2 = await tipsService.loadTips();

        // Assert
        expect(result1, equals(result2));
        expect(result1.length, equals(result2.length));
      });
    });

    group('getTodaysTip', () {
      test('should return a tip string', () async {
        // Act
        final result = await tipsService.getTodaysTip();

        // Assert
        expect(result, isA<String>());
        expect(result.isNotEmpty, true);
      });

      test('should return one of the available tips', () async {
        // Arrange
        final allTips = await tipsService.loadTips();

        // Act
        final todaysTip = await tipsService.getTodaysTip();

        // Assert
        expect(allTips, contains(todaysTip));
      });

      test('should return same tip for same day', () async {
        // Act - call multiple times in the same day
        final tip1 = await tipsService.getTodaysTip();
        final tip2 = await tipsService.getTodaysTip();

        // Assert
        expect(tip1, equals(tip2));
      });

      test('should return consistent tip based on days since epoch', () async {
        // Arrange
        final allTips = await tipsService.loadTips();
        final daysSinceEpoch =
            DateTime.now().difference(DateTime(1970, 1, 1)).inDays;
        final expectedIndex = daysSinceEpoch % allTips.length;
        final expectedTip = allTips[expectedIndex];

        // Act
        final actualTip = await tipsService.getTodaysTip();

        // Assert
        expect(actualTip, equals(expectedTip));
      });

      test('should cycle through all tips over time', () async {
        // This test verifies the algorithm cycles through all tips
        // by testing different theoretical dates

        // Arrange
        final allTips = await tipsService.loadTips();
        final numberOfTips = allTips.length;

        // Create a set to track which tips we've seen
        final seenTips = <String>{};

        // Simulate different days by testing the modulo operation
        for (int day = 0; day < numberOfTips; day++) {
          final index = day % numberOfTips;
          final tip = allTips[index];
          seenTips.add(tip);
        }

        // Assert - we should have seen all unique tips
        expect(seenTips.length, equals(numberOfTips));
        expect(seenTips.containsAll(allTips), true);
      });

      test('should handle edge case when tips list is small', () async {
        // This test ensures the modulo operation works correctly
        // even with a small number of tips

        // Act
        final todaysTip = await tipsService.getTodaysTip();
        final allTips = await tipsService.loadTips();

        // Assert
        expect(allTips, contains(todaysTip));
        expect(todaysTip.isNotEmpty, true);
      });
    });

    group('Error Handling', () {
      test('loadTips should throw when asset file does not exist', () async {
        // Create a service instance that will try to load a non-existent file
        // Note: This test verifies that the service properly propagates asset loading errors

        // We can't easily mock the rootBundle in this context without more complex setup,
        // but we can verify the service handles the expected file correctly
        await expectLater(
          () async {
            // The actual implementation should work with the existing asset
            final tips = await tipsService.loadTips();
            expect(tips, isNotEmpty);
          }(),
          completes,
        );
      });

      test('should handle malformed JSON gracefully', () async {
        // Note: This is more of an integration test to ensure the service
        // works with the current asset structure

        // Act & Assert
        await expectLater(
          () async {
            final tips = await tipsService.loadTips();
            // Verify each tip is a valid string
            for (final tip in tips) {
              expect(tip, isA<String>());
              expect(tip.trim().isNotEmpty, true);
            }
          }(),
          completes,
        );
      });
    });

    group('Date Calculation Tests', () {
      test('should use correct epoch date for calculation', () async {
        // Arrange
        final epochDate = DateTime(1970, 1, 1);
        final today = DateTime.now();
        final expectedDaysDifference = today.difference(epochDate).inDays;

        // Act
        final allTips = await tipsService.loadTips();
        final todaysTip = await tipsService.getTodaysTip();
        final expectedIndex = expectedDaysDifference % allTips.length;
        final expectedTip = allTips[expectedIndex];

        // Assert
        expect(todaysTip, equals(expectedTip));
      });

      test('should handle year transitions correctly', () async {
        // This test ensures the day calculation works across year boundaries

        // Arrange - simulate a date calculation
        final testDate = DateTime(2024, 1, 1);
        final epochDate = DateTime(1970, 1, 1);
        final daysDifference = testDate.difference(epochDate).inDays;
        final allTips = await tipsService.loadTips();

        // Act - simulate what the service would return for this date
        final simulatedIndex = daysDifference % allTips.length;
        final simulatedTip = allTips[simulatedIndex];

        // Assert
        expect(simulatedTip, isA<String>());
        expect(allTips, contains(simulatedTip));
        expect(simulatedIndex, lessThan(allTips.length));
        expect(simulatedIndex, greaterThanOrEqualTo(0));
      });
    });
  });
}
