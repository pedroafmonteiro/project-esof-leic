import 'package:flutter_test/flutter_test.dart';
import 'package:eco_tracker/models/device_model.dart';

void main() {
  group('Device Model Test', () {
    test('toJson should return a valid map', () {
      final device = Device(
          id: '1',
          model: 'Model A',
          manufacturer: 'Manufacturer A',
          category: 'Category A',
          powerConsumption: 100);

      expect(device.id, '1');
      expect(device.model, 'Model A');
      expect(device.manufacturer, 'Manufacturer A');
      expect(device.category, 'Category A');
      expect(device.powerConsumption, 100);
    });

    test('fromJson should return a valid Device object', () {
      final json = {
        'id': '1',
        'model': 'Model A',
        'manufacturer': 'Manufacturer A',
        'category': 'Category A',
        'powerConsumption': 100,
      };

      final device = Device.fromJson(json);

      expect(device.id, '1');
      expect(device.model, 'Model A');
      expect(device.manufacturer, 'Manufacturer A');
      expect(device.category, 'Category A');
      expect(device.powerConsumption, 100);
    });

    test('copyWith should return a new Device object with updated values', () {
      final device = Device(
          id: '1',
          model: 'Model A',
          manufacturer: 'Manufacturer A',
          category: 'Category A',
          powerConsumption: 100);
      final updatedDevice = device.copyWith(model: 'Updated Model');

      expect(updatedDevice.id, '1');
      expect(updatedDevice.model, 'Updated Model');
      expect(updatedDevice.manufacturer, 'Manufacturer A');
      expect(updatedDevice.category, 'Category A');
      expect(updatedDevice.powerConsumption, 100);
    });
  });
}
