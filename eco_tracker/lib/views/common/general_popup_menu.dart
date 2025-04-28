import 'package:eco_tracker/models/device_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:eco_tracker/viewmodels/device_view_model.dart';

class DevicePopupMenu {
  static Future<Device?> show({
    required BuildContext context,
    required Offset position,
    PopupMenuItemSelected<Device>? onSelected,
  }) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final result = await showMenu<Device>(
      context: context,
      position: RelativeRect.fromLTRB(
        (overlay.size.width / 2) -
            100, // Center horizontally (half screen width minus half menu width)
        (overlay.size.height / 2) -
            100, // Center vertically (half screen height minus approximate half menu height)
        (overlay.size.width / 2) + 100, // Right position (matching left offset)
        (overlay.size.height / 2) +
            100, // Bottom position (matching top offset)
      ),
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: Theme.of(context).colorScheme.surface,
      constraints: BoxConstraints(
        minWidth: 200.0,
        maxWidth: 280.0,
      ),
      items: await _buildMenuItems(context),
    );

    // Call the callback if a device was selected
    if (result != null && onSelected != null) {
      onSelected(result);
    }

    return result;
  }

  static Future<List<PopupMenuEntry<Device>>> _buildMenuItems(
      BuildContext context) async {
    try {
      // Show loading indicator first
      List<PopupMenuEntry<Device>> menuItems = [
        const PopupMenuItem<Device>(
          enabled: false,
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        )
      ];

      // Make sure user is authenticated
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return [
          const PopupMenuItem<Device>(
            enabled: false,
            child: Text('You must be logged in to view devices'),
          ),
        ];
      }

      // Get devices from the DeviceViewModel instead of accessing Firebase directly
      final deviceViewModel =
          Provider.of<DeviceViewModel>(context, listen: false);
      await deviceViewModel.loadDevices(); // Ensure the latest data is loaded

      // Create menu items from the devices - only displaying the device name
      if (deviceViewModel.devices.isNotEmpty) {
        menuItems = deviceViewModel.devices.map((device) {
          return PopupMenuItem<Device>(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              width: double.infinity,
              alignment: Alignment.centerLeft,
              child: Text(
                device.model,
                style: TextStyle(),
              ),
            ),
          );
        }).toList();
      } else {
        // If no devices were found in the view model
        menuItems = [
          PopupMenuItem<Device>(
            enabled: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('No devices available'),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/devices');
                  },
                  child: const Text('Add a device'),
                ),
              ],
            ),
          ),
        ];
      }

      return menuItems;
    } catch (e) {
      print("Error fetching devices: $e");
      return [
        PopupMenuItem<Device>(
          enabled: false,
          child: Text('Error: ${e.toString()}',
              style: const TextStyle(color: Colors.red)),
        ),
      ];
    }
  }
}
