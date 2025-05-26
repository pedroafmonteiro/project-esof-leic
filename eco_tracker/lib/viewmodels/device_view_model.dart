import 'dart:async';

import 'package:eco_tracker/models/device_model.dart';
import 'package:eco_tracker/services/device_service.dart';
import 'package:flutter/material.dart';

class DeviceViewModel extends ChangeNotifier {
  final List<Device> _devices = [];
  final DeviceService _deviceService;
  bool isLoading = false;

  List<Device> get devices => _devices;

  DeviceViewModel({DeviceService? deviceService})
      : _deviceService = deviceService ?? DeviceService() {
    loadDevices().catchError((error) {
      // Log error but don't rethrow to avoid breaking constructor
      // The error will be handled when loadDevices is called explicitly
      print('Error loading devices in constructor: $error');
    });
  }

  Future<void> loadDevices() async {
    isLoading = true;
    notifyListeners();

    try {
      final devices = await _deviceService.loadDevices();
      _devices.clear();
      _devices.addAll(devices);
    } catch (e) {
      // Handle error
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addDevice(Device device) async {
    try {
      await _deviceService.addDevice(device);
      await loadDevices();
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  Future<void> updateDevice(Device updatedDevice) async {
    try {
      await _deviceService.updateDevice(updatedDevice);

      final index = _devices.indexWhere(
        (device) => device.id == updatedDevice.id,
      );
      if (index != -1) {
        _devices[index] = updatedDevice;
        notifyListeners();
      }
      await loadDevices();
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  Future<void> removeDevice(String deviceId) async {
    try {
      await _deviceService.deleteDevice(deviceId);
      _devices.removeWhere((device) => device.id == deviceId);
      notifyListeners();
    } catch (e) {
      // Handle error appropriately
      rethrow;
    }
  }
}
