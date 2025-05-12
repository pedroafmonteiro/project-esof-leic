import 'package:flutter_test/flutter_test.dart';
import 'package:eco_tracker/services/tips_service.dart';
import 'package:flutter/services.dart';
import 'package:mockito/mockito.dart';

class MockAssetBundle extends Mock implements AssetBundle {}

void main() {
  late TipsService tipsService;
  late MockAssetBundle mockAssetBundle;

  setUp(() {
    mockAssetBundle = MockAssetBundle();
    tipsService = TipsService();
  });

  group('TipsService', () {
    test('loadTips returns list of tips from JSON', () async {
      // Arrange
      const jsonResponse = '''
      [
        "Tip 1",
        "Tip 2",
        "Tip 3"
      ]
      ''';
      when(mockAssetBundle.loadString('assets/tips.json'))
          .thenAnswer((_) async => jsonResponse);

      // Act
      final result = await tipsService.loadTips();

      // Assert
      expect(result, isA<List<String>>());
      expect(result.length, 3);
      expect(result, contains('Tip 1'));
      expect(result, contains('Tip 2'));
      expect(result, contains('Tip 3'));
    });

    test('loadTips throws when asset not found', () async {
      // Arrange
      when(mockAssetBundle.loadString('assets/tips.json'))
          .thenThrow(Exception('Asset not found'));

      // Arrange
      const jsonResponse = '''
      [
        "Tip 1",
        "Tip 2",
        "Tip 3",
        "Tip 4",
        "Tip 5",
        "Tip 6",
        "Tip 7"
      ]
      ''';
      when(mockAssetBundle.loadString('assets/tips.json'))
          .thenAnswer((_) async => jsonResponse);

      // Act
      final tips = await tipsService.loadTips();
      final daysSinceEpoch =
          DateTime.now().difference(DateTime(1970, 1, 1)).inDays;
      final tipOfTheDay = tips[daysSinceEpoch % tips.length];

      // Assert
      expect(tips, isA<List<String>>());
      expect(tips.length, 7);
      expect(tipOfTheDay, isIn(tips));
    });
  });
}
