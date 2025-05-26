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

  // Register fallback values for mocktail
  setUpAll(() {
    registerFallbackValue(Device(
      model: 'Test Model',
      manufacturer: 'Test Manufacturer',
      category: 'Test Category',
      powerConsumption: 100,
    ));
  });

  setUp(() {
    mockDeviceService = MockDeviceService();
  });

  group('DeviceViewModel Tests', () {
    group('Constructor and Initialization', () {
      test('should initialize with empty devices list and call loadDevices',
          () async {
        // Mock the loadDevices call that happens in constructor
        when(() => mockDeviceService.loadDevices()).thenAnswer((_) async => []);

        deviceViewModel = DeviceViewModel(deviceService: mockDeviceService);

        // Wait for async operations to complete
        await Future.delayed(Duration.zero);

        expect(deviceViewModel.devices, isEmpty);
        verify(() => mockDeviceService.loadDevices()).called(1);
      });

      test('should use default DeviceService when none provided', () {
        // This test verifies the default service is used when none is provided
        // Note: This test is skipped because it requires Firebase initialization
        // which is not available in unit tests without proper setup
        expect(() => DeviceViewModel(), throwsException);
      }, skip: 'Requires Firebase initialization');
    });

    group('loadDevices', () {
      test('should load devices from device service successfully', () async {
        final testDevices = [
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
            .thenAnswer((_) async => testDevices);

        deviceViewModel = DeviceViewModel(deviceService: mockDeviceService);

        // Call loadDevices again to test the method specifically
        await deviceViewModel.loadDevices();

        // Verify results
        verify(() => mockDeviceService.loadDevices())
            .called(2); // Constructor + explicit call
        expect(deviceViewModel.devices.length, 2);
        expect(deviceViewModel.devices[0].id, 'device1');
        expect(deviceViewModel.devices[1].id, 'device2');
        expect(deviceViewModel.isLoading, false);
      });

      test('should set loading state correctly during loadDevices', () async {
        bool loadingStateChanges = false;

        when(() => mockDeviceService.loadDevices()).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 10));
          return [];
        });

        deviceViewModel = DeviceViewModel(deviceService: mockDeviceService);

        // Listen to loading state changes
        deviceViewModel.addListener(() {
          if (deviceViewModel.isLoading) {
            loadingStateChanges = true;
          }
        });

        await deviceViewModel.loadDevices();

        expect(loadingStateChanges, true);
        expect(deviceViewModel.isLoading, false);
      });

      test('should handle errors when loading devices fails', () async {
        when(() => mockDeviceService.loadDevices())
            .thenThrow(Exception('Network error'));

        // Constructor should not throw even if loadDevices fails
        deviceViewModel = DeviceViewModel(deviceService: mockDeviceService);

        // Wait a bit for the async constructor call to complete
        await Future.delayed(Duration(milliseconds: 10));

        // Verify that calling loadDevices explicitly throws an exception
        expect(() => deviceViewModel.loadDevices(), throwsException);

        try {
          await deviceViewModel.loadDevices();
        } catch (e) {
          expect(deviceViewModel.isLoading, false);
        }
      });

      test('should clear existing devices before adding new ones', () async {
        // Initial devices
        when(() => mockDeviceService.loadDevices()).thenAnswer((_) async => [
              Device(
                id: 'device1',
                model: 'OldDevice',
                manufacturer: 'OldManufacturer',
                category: 'OldCategory',
                powerConsumption: 5,
              ),
            ]);

        deviceViewModel = DeviceViewModel(deviceService: mockDeviceService);
        await Future.delayed(Duration.zero);

        expect(deviceViewModel.devices.length, 1);
        expect(deviceViewModel.devices[0].model, 'OldDevice');

        // New devices load
        when(() => mockDeviceService.loadDevices()).thenAnswer((_) async => [
              Device(
                id: 'device2',
                model: 'NewDevice',
                manufacturer: 'NewManufacturer',
                category: 'NewCategory',
                powerConsumption: 10,
              ),
            ]);

        await deviceViewModel.loadDevices();

        expect(deviceViewModel.devices.length, 1);
        expect(deviceViewModel.devices[0].model, 'NewDevice');
      });
    });

    group('addDevice', () {
      setUp(() {
        when(() => mockDeviceService.loadDevices()).thenAnswer((_) async => []);
        deviceViewModel = DeviceViewModel(deviceService: mockDeviceService);
      });

      test('should add a device using device service successfully', () async {
        final newDevice = Device(
          model: 'EcoThermostat',
          manufacturer: 'EcoTech',
          category: 'Thermostat',
          powerConsumption: 15,
        );

        // Setup mock behavior
        when(() => mockDeviceService.addDevice(any())).thenAnswer((_) async {});

        when(() => mockDeviceService.loadDevices())
            .thenAnswer((_) async => [newDevice]);

        // Call the method under test
        await deviceViewModel.addDevice(newDevice);

        // Verify the service method was called
        verify(() => mockDeviceService.addDevice(newDevice)).called(1);
        verify(() => mockDeviceService.loadDevices())
            .called(2); // Constructor + after addDevice
      });

      test('should reload devices after adding a device', () async {
        final newDevice = Device(
          model: 'TestDevice',
          manufacturer: 'TestManufacturer',
          category: 'TestCategory',
          powerConsumption: 20,
        );

        when(() => mockDeviceService.addDevice(any())).thenAnswer((_) async {});

        // Mock loadDevices to return different values for sequential calls
        final deviceSequence = <List<Device>>[
          [],
          [newDevice]
        ];
        int callCount = 0;
        when(() => mockDeviceService.loadDevices()).thenAnswer((_) async {
          final result = deviceSequence[callCount % deviceSequence.length];
          callCount++;
          return result;
        });

        await deviceViewModel.addDevice(newDevice);

        // Verify loadDevices was called to refresh the list
        verify(() => mockDeviceService.loadDevices()).called(2);
      });

      test('should handle errors when adding device fails', () async {
        final newDevice = Device(
          model: 'FailDevice',
          manufacturer: 'FailManufacturer',
          category: 'FailCategory',
          powerConsumption: 25,
        );

        when(() => mockDeviceService.addDevice(any()))
            .thenThrow(Exception('Add device failed'));

        // Verify that the exception is rethrown
        expect(() => deviceViewModel.addDevice(newDevice), throwsException);
      });
    });

    group('updateDevice', () {
      setUp(() {
        when(() => mockDeviceService.loadDevices()).thenAnswer((_) async => []);
        deviceViewModel = DeviceViewModel(deviceService: mockDeviceService);
      });

      test('should update a device using device service successfully',
          () async {
        final originalDevice = Device(
          id: 'device1',
          model: 'EcoSensor',
          manufacturer: 'EcoTech',
          category: 'Sensor',
          powerConsumption: 5,
        );

        final updatedDevice = Device(
          id: 'device1',
          model: 'Updated EcoSensor',
          manufacturer: 'EcoTech',
          category: 'Sensor',
          powerConsumption: 6,
        );

        // Setup mock behavior
        when(() => mockDeviceService.updateDevice(any()))
            .thenAnswer((_) async {});

        when(() => mockDeviceService.loadDevices())
            .thenAnswer((_) async => [updatedDevice]);

        // Add the original device to the list
        deviceViewModel.devices.add(originalDevice);

        // Call the method under test
        await deviceViewModel.updateDevice(updatedDevice);

        // Verify service method was called
        verify(() => mockDeviceService.updateDevice(updatedDevice)).called(1);
        verify(() => mockDeviceService.loadDevices())
            .called(2); // Constructor + after updateDevice
      });

      test('should update local device list when device exists', () async {
        final originalDevice = Device(
          id: 'device1',
          model: 'EcoSensor',
          manufacturer: 'EcoTech',
          category: 'Sensor',
          powerConsumption: 5,
        );

        final updatedDevice = Device(
          id: 'device1',
          model: 'Updated EcoSensor',
          manufacturer: 'EcoTech',
          category: 'Sensor',
          powerConsumption: 6,
        );

        when(() => mockDeviceService.updateDevice(any()))
            .thenAnswer((_) async {});

        when(() => mockDeviceService.loadDevices())
            .thenAnswer((_) async => [updatedDevice]);

        // Add the original device to the list
        deviceViewModel.devices.add(originalDevice);

        bool notifierCalled = false;
        deviceViewModel.addListener(() {
          notifierCalled = true;
        });

        await deviceViewModel.updateDevice(updatedDevice);

        // Verify the device was updated in the local list
        expect(deviceViewModel.devices[0].model, 'Updated EcoSensor');
        expect(deviceViewModel.devices[0].powerConsumption, 6);
        expect(notifierCalled, true);
      });

      test(
          'should handle case when device to update does not exist in local list',
          () async {
        final updatedDevice = Device(
          id: 'nonexistent',
          model: 'NonExistent Device',
          manufacturer: 'NonExistent',
          category: 'NonExistent',
          powerConsumption: 100,
        );

        when(() => mockDeviceService.updateDevice(any()))
            .thenAnswer((_) async {});

        when(() => mockDeviceService.loadDevices())
            .thenAnswer((_) async => [updatedDevice]);

        // Call the method under test (no device in local list)
        await deviceViewModel.updateDevice(updatedDevice);

        // Should still call the service and reload devices
        verify(() => mockDeviceService.updateDevice(updatedDevice)).called(1);
        verify(() => mockDeviceService.loadDevices()).called(2);
      });

      test('should handle errors when updating device fails', () async {
        final updatedDevice = Device(
          id: 'device1',
          model: 'FailDevice',
          manufacturer: 'FailManufacturer',
          category: 'FailCategory',
          powerConsumption: 25,
        );

        when(() => mockDeviceService.updateDevice(any()))
            .thenThrow(Exception('Update device failed'));

        // Verify that the exception is rethrown
        expect(
            () => deviceViewModel.updateDevice(updatedDevice), throwsException);
      });
    });

    group('removeDevice', () {
      setUp(() {
        when(() => mockDeviceService.loadDevices()).thenAnswer((_) async => []);
        deviceViewModel = DeviceViewModel(deviceService: mockDeviceService);
      });

      test('should delete a device using device service successfully',
          () async {
        const deviceId = 'device1';

        // Setup mock behavior
        when(() => mockDeviceService.deleteDevice(deviceId))
            .thenAnswer((_) async {});

        // Add a device to the list
        deviceViewModel.devices.add(
          Device(
            id: 'device1',
            model: 'EcoSensor',
            manufacturer: 'EcoTech',
            category: 'Sensor',
            powerConsumption: 5,
          ),
        );

        // Call the method under test
        await deviceViewModel.removeDevice(deviceId);

        // Verify service method was called and device was removed from local list
        verify(() => mockDeviceService.deleteDevice(deviceId)).called(1);
        expect(deviceViewModel.devices.isEmpty, true);
      });

      test('should remove device from local list and notify listeners',
          () async {
        const deviceId = 'device1';

        when(() => mockDeviceService.deleteDevice(deviceId))
            .thenAnswer((_) async {});

        // Add a device to the list
        deviceViewModel.devices.addAll([
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
        ]);

        bool notifierCalled = false;
        deviceViewModel.addListener(() {
          notifierCalled = true;
        });

        await deviceViewModel.removeDevice(deviceId);

        // Verify the device was removed and listeners were notified
        expect(deviceViewModel.devices.length, 1);
        expect(deviceViewModel.devices[0].id, 'device2');
        expect(notifierCalled, true);
      });

      test('should handle case when device to remove does not exist', () async {
        const deviceId = 'nonexistent';

        when(() => mockDeviceService.deleteDevice(deviceId))
            .thenAnswer((_) async {});

        // Add a different device to the list
        deviceViewModel.devices.add(
          Device(
            id: 'device1',
            model: 'EcoSensor',
            manufacturer: 'EcoTech',
            category: 'Sensor',
            powerConsumption: 5,
          ),
        );

        await deviceViewModel.removeDevice(deviceId);

        // Should still call the service, but no device should be removed from local list
        verify(() => mockDeviceService.deleteDevice(deviceId)).called(1);
        expect(deviceViewModel.devices.length, 1);
      });

      test('should handle errors when deleting device fails', () async {
        const deviceId = 'device1';

        when(() => mockDeviceService.deleteDevice(deviceId))
            .thenThrow(Exception('Delete device failed'));

        // Verify that the exception is rethrown
        expect(() => deviceViewModel.removeDevice(deviceId), throwsException);
      });
    });

    group('ChangeNotifier behavior', () {
      setUp(() {
        when(() => mockDeviceService.loadDevices()).thenAnswer((_) async => []);
        deviceViewModel = DeviceViewModel(deviceService: mockDeviceService);
      });

      test('should notify listeners when loading state changes', () async {
        int notificationCount = 0;
        deviceViewModel.addListener(() {
          notificationCount++;
        });

        when(() => mockDeviceService.loadDevices()).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 10));
          return [];
        });

        await deviceViewModel.loadDevices();

        // Should notify when loading starts (true) and when loading ends (false)
        expect(notificationCount, greaterThanOrEqualTo(2));
      });

      test('should notify listeners when devices list changes', () async {
        int notificationCount = 0;
        deviceViewModel.addListener(() {
          notificationCount++;
        });

        when(() => mockDeviceService.deleteDevice('device1'))
            .thenAnswer((_) async {});

        deviceViewModel.devices.add(
          Device(
            id: 'device1',
            model: 'TestDevice',
            manufacturer: 'TestManufacturer',
            category: 'TestCategory',
            powerConsumption: 100,
          ),
        );

        final initialCount = notificationCount;

        await deviceViewModel.removeDevice('device1');

        // Should notify when device is removed
        expect(notificationCount, greaterThan(initialCount));
      });
    });

    group('Edge cases and error handling', () {
      setUp(() {
        when(() => mockDeviceService.loadDevices()).thenAnswer((_) async => []);
        deviceViewModel = DeviceViewModel(deviceService: mockDeviceService);
      });

      test('should handle null device ID in updateDevice', () async {
        final deviceWithoutId = Device(
          model: 'TestDevice',
          manufacturer: 'TestManufacturer',
          category: 'TestCategory',
          powerConsumption: 100,
        );

        when(() => mockDeviceService.updateDevice(any()))
            .thenAnswer((_) async {});

        when(() => mockDeviceService.loadDevices()).thenAnswer((_) async => []);

        // Should handle gracefully (not throw)
        await deviceViewModel.updateDevice(deviceWithoutId);

        verify(() => mockDeviceService.updateDevice(deviceWithoutId)).called(1);
      });

      test('should handle empty device list operations', () async {
        when(() => mockDeviceService.deleteDevice('nonexistent'))
            .thenAnswer((_) async {});

        // Should not throw when trying to remove from empty list
        await deviceViewModel.removeDevice('nonexistent');

        expect(deviceViewModel.devices.isEmpty, true);
      });

      test('should maintain loading state as false after successful operations',
          () async {
        when(() => mockDeviceService.addDevice(any())).thenAnswer((_) async {});

        when(() => mockDeviceService.loadDevices()).thenAnswer((_) async => []);

        final device = Device(
          model: 'TestDevice',
          manufacturer: 'TestManufacturer',
          category: 'TestCategory',
          powerConsumption: 100,
        );

        await deviceViewModel.addDevice(device);

        expect(deviceViewModel.isLoading, false);
      });
    });

    group('Integration scenarios', () {
      setUp(() {
        when(() => mockDeviceService.loadDevices()).thenAnswer((_) async => []);
        deviceViewModel = DeviceViewModel(deviceService: mockDeviceService);
      });

      test('should handle multiple operations in sequence', () async {
        final device1 = Device(
          id: 'device1',
          model: 'Device1',
          manufacturer: 'Manufacturer1',
          category: 'Category1',
          powerConsumption: 100,
        );

        final device2 = Device(
          id: 'device2',
          model: 'Device2',
          manufacturer: 'Manufacturer2',
          category: 'Category2',
          powerConsumption: 200,
        );

        final updatedDevice1 = device1.copyWith(powerConsumption: 150);

        // Mock all operations
        when(() => mockDeviceService.addDevice(any())).thenAnswer((_) async {});
        when(() => mockDeviceService.updateDevice(any()))
            .thenAnswer((_) async {});
        when(() => mockDeviceService.deleteDevice(any()))
            .thenAnswer((_) async {});

        // Mock loadDevices to return different values for sequential calls
        final devices = <List<Device>>[
          [device1],
          [device1, device2],
          [updatedDevice1, device2],
          [updatedDevice1]
        ];
        int callCount = 0;
        when(() => mockDeviceService.loadDevices()).thenAnswer((_) async {
          final result = devices[callCount % devices.length];
          callCount++;
          return result;
        });

        // Add device1
        await deviceViewModel.addDevice(device1);

        // Add device2
        await deviceViewModel.addDevice(device2);

        // Update device1
        await deviceViewModel.updateDevice(updatedDevice1);

        // Remove device2
        await deviceViewModel.removeDevice('device2');

        // Verify all operations were called
        verify(() => mockDeviceService.addDevice(device1)).called(1);
        verify(() => mockDeviceService.addDevice(device2)).called(1);
        verify(() => mockDeviceService.updateDevice(updatedDevice1)).called(1);
        verify(() => mockDeviceService.deleteDevice('device2')).called(1);

        // loadDevices should be called: constructor + 2 addDevice + 1 updateDevice = 4 times
        // (removeDevice doesn't call loadDevices, it updates local list directly)
        verify(() => mockDeviceService.loadDevices()).called(4);
      });
    });
  });
}
