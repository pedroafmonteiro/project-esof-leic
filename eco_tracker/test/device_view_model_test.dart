import 'package:eco_tracker/models/device_model.dart';
import 'package:eco_tracker/services/device_service.dart';
import 'package:eco_tracker/viewmodels/device_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock Device Service
class MockDeviceService extends Mock implements DeviceService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DeviceViewModel deviceViewModel;
  late MockDeviceService mockDeviceService;

  setUp(() {
    mockDeviceService = MockDeviceService();
    deviceViewModel = DeviceViewModel(deviceService: mockDeviceService);
  });

  group('DeviceViewModel Tests', () {
    test('should load devices from device service', () async {
      // Setup mock behavior
      final devices = [
        Device(
          id: 'device1',
          model: 'EcoSensor',
          manufacturer: 'EcoTech',
          category: 'Sensor',
          powerConsumption: 5,
        ),
        Device(
          id: 'device2',
          model: 'SmartPlug',
          manufacturer: 'EcoTech',
          category: 'Plug',
          powerConsumption: 10,
        ),
      ];

      when(() => mockDeviceService.loadDevices())
          .thenAnswer((_) async => devices);

      // Call the method under test
      await deviceViewModel.loadDevices();

      // Verify results
      verify(() => mockDeviceService.loadDevices()).called(1);
      expect(deviceViewModel.devices.length, 2);
      expect(deviceViewModel.devices[0].id, 'device1');
      expect(deviceViewModel.devices[1].id, 'device2');
    });

    test('should add a device using device service', () async {
      final newDevice = Device(
        model: 'EcoThermostat',
        manufacturer: 'EcoTech',
        category: 'Thermostat',
        powerConsumption: 15,
      );

      // Setup mock behavior
      when(() => mockDeviceService.addDevice(newDevice))
          .thenAnswer((_) async {});

      when(() => mockDeviceService.loadDevices())
          .thenAnswer((_) async => [newDevice]);

      // Call the method under test
      await deviceViewModel.addDevice(newDevice);

      // Verify the service method was called
      verify(() => mockDeviceService.addDevice(newDevice)).called(1);
      verify(() => mockDeviceService.loadDevices()).called(1);
    });

    test('should delete a device using device service', () async {
      const deviceId = 'device1';

      // Setup mock behavior
      when(() => mockDeviceService.deleteDevice(deviceId))
          .thenAnswer((_) async {});

      // Initial state with devices
      deviceViewModel = DeviceViewModel(deviceService: mockDeviceService);
      deviceViewModel.devices.addAll([
        Device(
          id: 'device1',
          model: 'EcoSensor',
          manufacturer: 'EcoTech',
          category: 'Sensor',
          powerConsumption: 5,
        ),
      ]);

      // Call the method under test
      await deviceViewModel.removeDevice(deviceId);

      // Verify service method was called
      verify(() => mockDeviceService.deleteDevice(deviceId)).called(1);
      expect(deviceViewModel.devices.isEmpty, true);
    });

    test('should update a device using device service', () async {
      final updatedDevice = Device(
        id: 'device1',
        model: 'Updated EcoSensor',
        manufacturer: 'EcoTech',
        category: 'Sensor',
        powerConsumption: 6,
      );

      // Setup mock behavior
      when(() => mockDeviceService.updateDevice(updatedDevice))
          .thenAnswer((_) async {});

      when(() => mockDeviceService.loadDevices())
          .thenAnswer((_) async => [updatedDevice]);

      // Initial state
      deviceViewModel.devices.add(Device(
        id: 'device1',
        model: 'EcoSensor',
        manufacturer: 'EcoTech',
        category: 'Sensor',
        powerConsumption: 5,
      ),);

      // Call the method under test
      await deviceViewModel.updateDevice(updatedDevice);

      // Verify service method was called
      verify(() => mockDeviceService.updateDevice(updatedDevice)).called(1);
      verify(() => mockDeviceService.loadDevices()).called(1);
    });
  });
}
