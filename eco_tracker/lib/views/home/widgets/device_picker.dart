import 'package:eco_tracker/models/device_model.dart';
import 'package:flutter/material.dart';

class DevicePicker {
  static Future<Device?> showDeviceDialog({
    required BuildContext context,
    required List<Device> devices,
    Device? selectedDevice,
  }) async {
    return await showDialog<Device>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select a Device'),
          content: devices.isEmpty
              ? SizedBox(
                  height: 100,
                  child: Center(child: const Text('No devices available')),
                )
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      final device = devices[index];
                      return ListTile(
                        title: Text('${device.manufacturer} ${device.model}'),
                        subtitle: Text(
                          '${device.category} - ${device.powerConsumption}W',
                        ),
                        selected: selectedDevice?.id == device.id,
                        onTap: () {
                          Navigator.of(context).pop(device);
                        },
                      );
                    },
                  ),
                ),
          actions: <Widget>[
            if (devices.isEmpty)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/devices');
                },
                child: const Text('Add a device'),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
