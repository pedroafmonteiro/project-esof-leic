import 'dart:async';

import 'package:eco_tracker/models/device_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class DeviceViewModel extends ChangeNotifier {
  final List<Device> _devices = [];
  late DatabaseReference _databaseReference;
  bool isLoading = false;

  List<Device> get devices => _devices;

  DeviceViewModel({DatabaseReference? databaseReference}) {
    _databaseReference = databaseReference ?? FirebaseDatabase.instance.ref();
    _initialize();
  }

  Future<void> _initialize() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _databaseReference = _databaseReference.child(user.uid).child('devices');
      loadDevices();
    }
  }

  Future<void> addDevice(Device device) async {
    final newDeviceRef = _databaseReference.push();
    final deviceId = newDeviceRef.key!;
    final deviceWithId = device.copyWith(id: deviceId);
    await newDeviceRef.set(deviceWithId.toJson());
    loadDevices();
  }

  Future<void> loadDevices() async {
    isLoading = true;
    notifyListeners();

    try {
      final event = await _databaseReference.once();
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        _devices.clear();
        data.forEach((key, value) {
          final deviceData = Map<String, dynamic>.from(value);
          if (deviceData['id'] == null) {
            deviceData['id'] = key;
          }
          _devices.add(Device.fromJson(deviceData));
        });
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeDevice(String deviceId) async {
    await _databaseReference.child(deviceId).remove();
    _devices.removeWhere((device) => device.id == deviceId);
    loadDevices();
  }

  Future<void> updateDevice(Device updatedDevice) async {
    await _databaseReference
        .child(updatedDevice.id!)
        .set(updatedDevice.toJson());

    final index = _devices.indexWhere(
      (device) => device.id == updatedDevice.id,
    );
    if (index != -1) {
      _devices[index] = updatedDevice;
    }
    loadDevices();
  }
}
