import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eco_tracker/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsService Tests', () {
    late SettingsService settingsService;

    setUp(() {
      // Reset SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    group('Initialization Tests', () {
      test('should initialize with default values when no preferences exist',
          () async {
        SharedPreferences.setMockInitialValues({});
        settingsService = SettingsService();

        // Wait for async initialization to complete
        await Future.delayed(Duration(milliseconds: 100));

        expect(settingsService.darkMode, false);
        expect(settingsService.materialYou, false);
        expect(settingsService.accentColor.value, Colors.green.value);
        expect(settingsService.energyCost, 0.15);
      });

      test('should initialize with stored preferences when they exist',
          () async {
        SharedPreferences.setMockInitialValues({
          'darkMode': true,
          'materialYou': true,
          'accentColor': Colors.blue.value,
          'energyCost': 0.25,
        });
        settingsService = SettingsService();

        // Wait for async initialization to complete
        await Future.delayed(Duration(milliseconds: 100));

        expect(settingsService.darkMode, true);
        expect(settingsService.materialYou, true);
        expect(settingsService.accentColor.value, Colors.blue.value);
        expect(settingsService.energyCost, 0.25);
      });
    });

    group('Dark Mode Tests', () {
      setUp(() {
        SharedPreferences.setMockInitialValues({});
        settingsService = SettingsService();
      });

      test('should not call notifyListeners when setting same value', () async {
        await settingsService.setDarkMode(false); // Set initial value

        bool listenerCalled = false;
        settingsService.addListener(() {
          listenerCalled = true;
        });

        await settingsService.setDarkMode(false); // Set same value

        expect(listenerCalled, false);
      });
    });

    group('Material You Tests', () {
      setUp(() {
        SharedPreferences.setMockInitialValues({});
        settingsService = SettingsService();
      });

      test('should not call notifyListeners when setting same value', () async {
        await settingsService.setMaterialYou(false); // Set initial value

        bool listenerCalled = false;
        settingsService.addListener(() {
          listenerCalled = true;
        });

        await settingsService.setMaterialYou(false); // Set same value

        expect(listenerCalled, false);
      });
    });



    group('Static Methods Tests', () {
      test('findClosestPredefinedColor should return correct color for red hue',
          () {
        Color testColor = HSLColor.fromAHSL(1.0, 10, 1.0, 0.5).toColor();
        Color result = SettingsService.findClosestPredefinedColor(testColor);
        expect(result.value, Colors.red.value);
      });

      test(
          'findClosestPredefinedColor should return correct color for orange hue',
          () {
        Color testColor = HSLColor.fromAHSL(1.0, 45, 1.0, 0.5).toColor();
        Color result = SettingsService.findClosestPredefinedColor(testColor);
        expect(result.value, Colors.orange.value);
      });

      test(
          'findClosestPredefinedColor should return correct color for yellow hue',
          () {
        Color testColor = HSLColor.fromAHSL(1.0, 80, 1.0, 0.5).toColor();
        Color result = SettingsService.findClosestPredefinedColor(testColor);
        expect(result.value, Colors.yellow.value);
      });

      test(
          'findClosestPredefinedColor should return correct color for green hue',
          () {
        Color testColor = HSLColor.fromAHSL(1.0, 130, 1.0, 0.5).toColor();
        Color result = SettingsService.findClosestPredefinedColor(testColor);
        expect(result.value, Colors.green.value);
      });

      test(
          'findClosestPredefinedColor should return correct color for cyan hue',
          () {
        Color testColor = HSLColor.fromAHSL(1.0, 180, 1.0, 0.5).toColor();
        Color result = SettingsService.findClosestPredefinedColor(testColor);
        expect(result.value, Colors.cyan.value);
      });

      test(
          'findClosestPredefinedColor should return correct color for blue hue',
          () {
        Color testColor = HSLColor.fromAHSL(1.0, 220, 1.0, 0.5).toColor();
        Color result = SettingsService.findClosestPredefinedColor(testColor);
        expect(result.value, Colors.blue.value);
      });

      test(
          'findClosestPredefinedColor should return correct color for purple hue',
          () {
        Color testColor = HSLColor.fromAHSL(1.0, 270, 1.0, 0.5).toColor();
        Color result = SettingsService.findClosestPredefinedColor(testColor);
        expect(result.value, Colors.purple.value);
      });

      test(
          'findClosestPredefinedColor should return correct color for pink hue',
          () {
        Color testColor = HSLColor.fromAHSL(1.0, 320, 1.0, 0.5).toColor();
        Color result = SettingsService.findClosestPredefinedColor(testColor);
        expect(result.value, Colors.pink.value);
      });

      test('findClosestPredefinedColor should handle edge case at 0 degrees',
          () {
        Color testColor = HSLColor.fromAHSL(1.0, 0, 1.0, 0.5).toColor();
        Color result = SettingsService.findClosestPredefinedColor(testColor);
        expect(result.value, Colors.red.value);
      });
    });

    group('PredefinedColor Tests', () {
      test('predefinedColors should contain all expected colors', () {
        expect(SettingsService.predefinedColors.length, 8);

        final colorNames =
            SettingsService.predefinedColors.map((c) => c.name).toList();
        expect(colorNames, contains('Red'));
        expect(colorNames, contains('Orange'));
        expect(colorNames, contains('Yellow'));
        expect(colorNames, contains('Green'));
        expect(colorNames, contains('Cyan'));
        expect(colorNames, contains('Blue'));
        expect(colorNames, contains('Purple'));
        expect(colorNames, contains('Pink'));
      });

      test('PredefinedColor should create instances correctly', () {
        const color = PredefinedColor(name: 'Test', color: Colors.red);

        expect(color.name, 'Test');
        expect(color.color.value, Colors.red.value);
      });
    });

    group('SettingsManager Tests', () {
      test('should return default values when not initialized', () {
        expect(SettingsManager.darkMode, false);
        expect(SettingsManager.materialYou, false);
        expect(SettingsManager.accentColor.value, Colors.green.value);
        expect(SettingsManager.energyCost, 0.15);
      });
    });

    group('Integration Tests', () {
      setUp(() {
        SharedPreferences.setMockInitialValues({});
        settingsService = SettingsService();
      });

      test('should maintain state consistency after multiple changes',
          () async {
        // Make multiple changes
        await settingsService.setDarkMode(true);
        await settingsService.setMaterialYou(false);
        await settingsService.setAccentColor(Colors.purple);
        await settingsService.setEnergyCost(0.20);

        // Change some back
        await settingsService.setDarkMode(false);
        await settingsService.setAccentColor(Colors.orange);

        expect(settingsService.darkMode, false);
        expect(settingsService.materialYou, false);
        expect(settingsService.accentColor.value, Colors.orange.value);
        expect(settingsService.energyCost, 0.20);
      });
    });
  });
}
