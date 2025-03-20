import 'package:eco_tracker/model/device_model.dart';
import 'package:flutter/material.dart';

class DeviceViewModel extends ChangeNotifier {
  final List<Device> _devices = [];

  List<Device> get devices => _devices;

  void addDevice(Device device) {
    _devices.add(device);
    notifyListeners();
  }
}
