import 'package:flutter_test/flutter_test.dart';
import 'package:eco_tracker/models/device_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Device Model Tests', () {
    // Test data
    final testDevice = Device(
      id: 'device123',
      model: 'Test Device',
      manufacturer: 'Test Manufacturer',
      category: 'Test Category',
      powerConsumption: 100,
    );

    final testDeviceMap = {
      'model': 'Test Device',
      'manufacturer': 'Test Manufacturer',
      'category': 'Test Category',
      'powerConsumption': 100,
    };

    test('Device.fromMap creates device correctly', () {
      // Act
      final device = Device.fromMap(testDeviceMap, 'device123');

      // Assert
      expect(device.id, equals('device123'));
      expect(device.model, equals('Test Device'));
      expect(device.manufacturer, equals('Test Manufacturer'));
      expect(device.category, equals('Test Category'));
      expect(device.powerConsumption, equals(100));
    });

    test('Device.toMap returns correct map', () {
      // Act
      final map = testDevice.toMap();

      // Assert
      expect(map['model'], equals('Test Device'));
      expect(map['manufacturer'], equals('Test Manufacturer'));
      expect(map['category'], equals('Test Category'));
      expect(map['powerConsumption'], equals(100));
      expect(map.containsKey('id'), isFalse);
    });

    test('Device.toJson includes id field', () {
      // Act
      final json = testDevice.toJson();

      // Assert
      expect(json['id'], equals('device123'));
      expect(json['model'], equals('Test Device'));
      expect(json['manufacturer'], equals('Test Manufacturer'));
      expect(json['category'], equals('Test Category'));
      expect(json['powerConsumption'], equals(100));
    });

    test('Device.copyWith creates new device with updated fields', () {
      // Act
      final updatedDevice = testDevice.copyWith(
        model: 'Updated Device',
        powerConsumption: 200,
      );

      // Assert
      expect(updatedDevice.id, equals(testDevice.id));
      expect(updatedDevice.model, equals('Updated Device'));
      expect(updatedDevice.manufacturer, equals(testDevice.manufacturer));
      expect(updatedDevice.category, equals(testDevice.category));
      expect(updatedDevice.powerConsumption, equals(200));
    });

    test('Device.copyWith with null values preserves original', () {
      // Act
      final updatedDevice = testDevice.copyWith();

      // Assert
      expect(updatedDevice.id, equals(testDevice.id));
      expect(updatedDevice.model, equals(testDevice.model));
      expect(updatedDevice.manufacturer, equals(testDevice.manufacturer));
      expect(updatedDevice.category, equals(testDevice.category));
      expect(
          updatedDevice.powerConsumption, equals(testDevice.powerConsumption));
    });

    test('Device.fromMap handles missing fields gracefully', () {
      // Arrange
      final incompleteMap = {
        'model': 'Test Device',
      };

      // Act
      final device = Device.fromMap(incompleteMap, 'device123');

      // Assert
      expect(device.id, equals('device123'));
      expect(device.model, equals('Test Device'));
      expect(device.manufacturer, equals(''));
      expect(device.category, equals(''));
      expect(device.powerConsumption, equals(0));
    });

    test('Device.fromMap handles numeric powerConsumption correctly', () {
      // Arrange
      final mapWithDouble = {
        'model': 'Test Device',
        'manufacturer': 'Test Manufacturer',
        'category': 'Test Category',
        'powerConsumption': 100.5,
      };

      // Act
      final device = Device.fromMap(mapWithDouble, 'device123');

      // Assert
      expect(device.powerConsumption, equals(100));
    });

    test('Device.fromMap handles invalid powerConsumption type', () {
      // Arrange
      final mapWithInvalidPower = {
        'model': 'Test Device',
        'manufacturer': 'Test Manufacturer',
        'category': 'Test Category',
        'powerConsumption': 'invalid',
      };

      // Act
      final device = Device.fromMap(mapWithInvalidPower, 'device123');

      // Assert
      expect(device.powerConsumption, equals(0));
    });

    test('Device.fromJson creates device correctly', () {
      // Arrange
      final deviceJson = {
        'id': 'device123',
        'model': 'Test Device',
        'manufacturer': 'Test Manufacturer',
        'category': 'Test Category',
        'powerConsumption': 100,
      };

      // Act
      final device = Device.fromJson(deviceJson);

      // Assert
      expect(device.id, equals('device123'));
      expect(device.model, equals('Test Device'));
      expect(device.manufacturer, equals('Test Manufacturer'));
      expect(device.category, equals('Test Category'));
      expect(device.powerConsumption, equals(100));
    });

    test('Device.fromJson handles missing fields', () {
      // Arrange
      final deviceJson = <String, dynamic>{
        'model': 'Test Device',
      };

      // Act
      final device = Device.fromJson(deviceJson);

      // Assert
      expect(device.id, equals(''));
      expect(device.model, equals('Test Device'));
      expect(device.manufacturer, equals(''));
      expect(device.category, equals(''));
      expect(device.powerConsumption, equals(0));
    });

    test('Device.fromJson handles numeric powerConsumption as double', () {
      // Arrange
      final deviceJson = {
        'id': 'device123',
        'model': 'Test Device',
        'manufacturer': 'Test Manufacturer',
        'category': 'Test Category',
        'powerConsumption': 150.7,
      };

      // Act
      final device = Device.fromJson(deviceJson);

      // Assert
      expect(device.powerConsumption, equals(150));
    });

    test('Device handles null device ID gracefully', () {
      // Arrange
      final deviceWithoutId = Device(
        model: 'Test Device',
        manufacturer: 'Test Manufacturer',
        category: 'Test Category',
        powerConsumption: 100,
      );

      // Assert
      expect(deviceWithoutId.id, isNull);
      expect(deviceWithoutId.model, equals('Test Device'));
      expect(deviceWithoutId.manufacturer, equals('Test Manufacturer'));
      expect(deviceWithoutId.category, equals('Test Category'));
      expect(deviceWithoutId.powerConsumption, equals(100));
    });

    test('Device copyWith allows updating id', () {
      // Arrange
      final deviceWithoutId = Device(
        model: 'Test Device',
        manufacturer: 'Test Manufacturer',
        category: 'Test Category',
        powerConsumption: 100,
      );

      // Act
      final deviceWithId = deviceWithoutId.copyWith(id: 'newId123');

      // Assert
      expect(deviceWithId.id, equals('newId123'));
      expect(deviceWithId.model, equals('Test Device'));
    });

    test('Device handles empty string fields', () {
      // Arrange
      final deviceWithEmptyStrings = Device(
        id: 'device123',
        model: '',
        manufacturer: '',
        category: '',
        powerConsumption: 0,
      );

      // Assert
      expect(deviceWithEmptyStrings.model, equals(''));
      expect(deviceWithEmptyStrings.manufacturer, equals(''));
      expect(deviceWithEmptyStrings.category, equals(''));
      expect(deviceWithEmptyStrings.powerConsumption, equals(0));
    });

    test('Device toMap excludes id but toJson includes it', () {
      // Act
      final map = testDevice.toMap();
      final json = testDevice.toJson();

      // Assert
      expect(map.containsKey('id'), isFalse);
      expect(json.containsKey('id'), isTrue);
      expect(json['id'], equals('device123'));
    });
  });
}
