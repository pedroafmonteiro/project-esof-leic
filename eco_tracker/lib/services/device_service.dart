import 'package:eco_tracker/models/device_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class DeviceService {
  late DatabaseReference _databaseReference;

  DeviceService({DatabaseReference? databaseReference}) {
    _databaseReference = databaseReference ?? FirebaseDatabase.instance.ref();
    _initialize();
  }

  Future<void> _initialize() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _databaseReference = _databaseReference.child(user.uid).child('devices');
    }
  }

  Future<List<Device>> loadDevices() async {
    final devices = <Device>[];
    final event = await _databaseReference.once();
    final data = event.snapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      data.forEach((key, value) {
        final deviceData = Map<String, dynamic>.from(value);
        if (deviceData['id'] == null) {
          deviceData['id'] = key;
        }
        devices.add(Device.fromJson(deviceData));
      });
    }

    return devices;
  }

  Future<void> addDevice(Device device) async {
    final newDeviceRef = _databaseReference.push();
    final deviceId = newDeviceRef.key!;
    final deviceWithId = device.copyWith(id: deviceId);
    await newDeviceRef.set(deviceWithId.toJson());
  }

  Future<void> updateDevice(Device device) async {
    if (device.id == null) {
      throw Exception('Cannot update device without an ID');
    }
    await _databaseReference.child(device.id!).set(device.toJson());
  }

  Future<void> deleteDevice(String deviceId) async {
    await _databaseReference.child(deviceId).remove();
  }

  Future<Device> getDeviceById(String deviceId) async {
    final event = await _databaseReference.child(deviceId).once();
    if (event.snapshot.exists) {
      return Device.fromJson(Map<String, dynamic>.from(event.snapshot.value as Map));
    } else {
      throw Exception('Device not found');
    }
  }
}
