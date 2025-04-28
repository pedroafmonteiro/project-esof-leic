import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:eco_tracker/models/device_model.dart';

class DeviceService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Device>> loadDevices() async {
    final user = _auth.currentUser;
    if (user == null) {
      return [];
    }

    final devicesRef = _database.ref().child(user.uid).child('devices');
    final snapshot = await devicesRef.get();

    if (!snapshot.exists) {
      return [];
    }

    final devicesMap = Map<String, dynamic>.from(snapshot.value as Map);
    return devicesMap.entries.map((entry) {
      final Map<String, dynamic> deviceData =
          Map<String, dynamic>.from(entry.value as Map);
      return Device.fromMap(deviceData, entry.key);
    }).toList();
  }

  Future<Device?> getDeviceById(String deviceId) async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }

    final deviceRef =
        _database.ref().child(user.uid).child('devices').child(deviceId);
    final snapshot = await deviceRef.get();

    if (!snapshot.exists) {
      return null;
    }

    final deviceData = Map<String, dynamic>.from(snapshot.value as Map);
    return Device.fromMap(deviceData, deviceId);
  }

  Future<void> addDevice(Device device) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final devicesRef = _database.ref().child(user.uid).child('devices').push();
    await devicesRef.set(device.toMap());
  }

  Future<void> updateDevice(Device device) async {
    final user = _auth.currentUser;
    if (user == null || device.id == null) {
      throw Exception('User not authenticated or device ID is null');
    }

    final deviceRef =
        _database.ref().child(user.uid).child('devices').child(device.id!);
    await deviceRef.update(device.toMap());
  }

  Future<void> deleteDevice(String deviceId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final deviceRef =
        _database.ref().child(user.uid).child('devices').child(deviceId);
    await deviceRef.remove();
  }

  Future<List<Device>> getCompanyDevices(String companyId) async {
    if (companyId.isEmpty) {
      return [];
    }

    final companiesRef =
        _database.ref().child('companies').child(companyId).child('devices');
    final snapshot = await companiesRef.get();

    if (!snapshot.exists) {
      return [];
    }

    final devicesMap = Map<String, dynamic>.from(snapshot.value as Map);
    return devicesMap.entries.map((entry) {
      final Map<String, dynamic> deviceData =
          Map<String, dynamic>.from(entry.value as Map);
      return Device.fromMap(deviceData, entry.key);
    }).toList();
  }

  Future<Device?> getCompanyDeviceById(
    String companyId,
    String deviceId,
  ) async {
    if (companyId.isEmpty) {
      return null;
    }

    final deviceRef = _database
        .ref()
        .child('companies')
        .child(companyId)
        .child('devices')
        .child(deviceId);
    final snapshot = await deviceRef.get();

    if (!snapshot.exists) {
      return null;
    }

    final deviceData = Map<String, dynamic>.from(snapshot.value as Map);
    return Device.fromMap(deviceData, deviceId);
  }

  Future<void> addCompanyDevice(String companyId, Device device) async {
    if (companyId.isEmpty) {
      throw Exception('Company ID is empty');
    }

    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final userRoleRef = _database.ref().child(user.uid).child('role');
    final userRole = await userRoleRef.get();

    if (!userRole.exists || userRole.value != 'maintainer') {
      throw Exception('Only maintainers can add company devices');
    }

    final userCompanyRef = _database.ref().child(user.uid).child('company');
    final userCompany = await userCompanyRef.get();

    if (!userCompany.exists || userCompany.value != companyId) {
      throw Exception('User is not authorized for this company');
    }

    final deviceRef = _database
        .ref()
        .child('companies')
        .child(companyId)
        .child('devices')
        .push();
    await deviceRef.set(device.toMap());
  }

  Future<void> updateCompanyDevice(String companyId, Device device) async {
    if (companyId.isEmpty || device.id == null) {
      throw Exception('Company ID is empty or device ID is null');
    }

    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final userRoleRef = _database.ref().child(user.uid).child('role');
    final userRole = await userRoleRef.get();

    if (!userRole.exists || userRole.value != 'maintainer') {
      throw Exception('Only maintainers can update company devices');
    }

    final userCompanyRef = _database.ref().child(user.uid).child('company');
    final userCompany = await userCompanyRef.get();

    if (!userCompany.exists || userCompany.value != companyId) {
      throw Exception('User is not authorized for this company');
    }

    final deviceRef = _database
        .ref()
        .child('companies')
        .child(companyId)
        .child('devices')
        .child(device.id!);
    await deviceRef.update(device.toMap());
  }

  Future<void> deleteCompanyDevice(String companyId, String deviceId) async {
    if (companyId.isEmpty) {
      throw Exception('Company ID is empty');
    }

    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final userRoleRef = _database.ref().child(user.uid).child('role');
    final userRole = await userRoleRef.get();

    if (!userRole.exists || userRole.value != 'maintainer') {
      throw Exception('Only maintainers can delete company devices');
    }

    final userCompanyRef = _database.ref().child(user.uid).child('company');
    final userCompany = await userCompanyRef.get();

    if (!userCompany.exists || userCompany.value != companyId) {
      throw Exception('User is not authorized for this company');
    }

    final deviceRef = _database
        .ref()
        .child('companies')
        .child(companyId)
        .child('devices')
        .child(deviceId);
    await deviceRef.remove();
  }

  Future<Map<String, dynamic>> getCompanyDeviceStatistics(
    String companyId,
    String deviceId,
  ) async {
    if (companyId.isEmpty || deviceId.isEmpty) {
      throw Exception('Company ID or device ID is empty');
    }

    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final userRoleRef = _database.ref().child(user.uid).child('role');
    final userRole = await userRoleRef.get();

    if (!userRole.exists || userRole.value != 'maintainer') {
      throw Exception('Only maintainers can view company device statistics');
    }

    final userCompanyRef = _database.ref().child(user.uid).child('company');
    final userCompany = await userCompanyRef.get();

    if (!userCompany.exists || userCompany.value != companyId) {
      throw Exception('User is not authorized for this company');
    }

    final device = await getCompanyDeviceById(companyId, deviceId);
    if (device == null) {
      throw Exception('Device not found');
    }

    final usersRef = _database.ref();
    final usersSnapshot = await usersRef.get();

    if (!usersSnapshot.exists) {
      return {
        'device': device,
        'userCount': 0,
        'totalUsage': 0.0,
      };
    }

    int userCount = 0;
    double totalUsage = 0.0;

    final usersMap = Map<String, dynamic>.from(usersSnapshot.value as Map);

    for (final userEntry in usersMap.entries) {
      final userData = Map<String, dynamic>.from(userEntry.value as Map);

      if (userData.containsKey('devices')) {
        final userDevices =
            Map<String, dynamic>.from(userData['devices'] as Map);

        for (final deviceEntry in userDevices.entries) {
          final userDevice =
              Map<String, dynamic>.from(deviceEntry.value as Map);

          if (userDevice['model'] == device.model &&
              userDevice['manufacturer'] == device.manufacturer) {
            userCount++;

            if (userData.containsKey('usage')) {
              final usage = Map<String, dynamic>.from(userData['usage'] as Map);

              for (final dateEntry in usage.entries) {
                final dateUsage =
                    Map<String, dynamic>.from(dateEntry.value as Map);

                for (final usageDeviceEntry in dateUsage.entries) {
                  final usageDevice =
                      Map<String, dynamic>.from(usageDeviceEntry.value as Map);

                  if (usageDeviceEntry.key == deviceEntry.key &&
                      usageDevice.containsKey('durationSeconds')) {
                    final durationHours =
                        (usageDevice['durationSeconds'] as int) / 3600;
                    final energyConsumptionWh =
                        durationHours * device.powerConsumption;

                    // Convert Wh to kWh
                    totalUsage += energyConsumptionWh / 1000;
                  }
                }
              }
            }

            break;
          }
        }
      }
    }

    return {
      'device': device,
      'userCount': userCount,
      'totalUsage': totalUsage,
    };
  }

  Future<List<Device>> getAllCompanyDevices() async {
    final List<Device> allCompanyDevices = [];

    final companiesRef = _database.ref().child('companies');
    final snapshot = await companiesRef.get();

    if (!snapshot.exists) {
      return [];
    }

    final companiesMap = Map<String, dynamic>.from(snapshot.value as Map);

    for (final companyEntry in companiesMap.entries) {
      final companyId = companyEntry.key;
      final companyData = Map<String, dynamic>.from(companyEntry.value as Map);

      if (companyData.containsKey('devices')) {
        final devicesMap =
            Map<String, dynamic>.from(companyData['devices'] as Map);

        for (final deviceEntry in devicesMap.entries) {
          final deviceId = deviceEntry.key;
          final deviceData =
              Map<String, dynamic>.from(deviceEntry.value as Map);

          final device = Device.fromMap(deviceData, deviceId);
          allCompanyDevices.add(
            device.copyWith(
              manufacturer: "${device.manufacturer} ($companyId)",
            ),
          );
        }
      }
    }

    return allCompanyDevices;
  }
}
