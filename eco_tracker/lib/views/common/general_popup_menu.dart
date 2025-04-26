import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:eco_tracker/viewmodels/device_view_model.dart';

class DeviceItem {
  final String id;
  final String name;
  final String? manufacturer;
  final String? category;

  DeviceItem({
    required this.id, 
    required this.name,
    this.manufacturer,
    this.category,
  });
}

class DevicePopupMenu {
  static Future<DeviceItem?> show({
    required BuildContext context,
    required Offset position,
  }) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    
    return await showMenu<DeviceItem>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(position, position),
        Rect.fromPoints(Offset.zero, overlay.size.bottomRight(Offset.zero)),
      ),
      items: await _buildMenuItems(context),
    );
  }
  
  static Future<List<PopupMenuEntry<DeviceItem>>> _buildMenuItems(BuildContext context) async {
    try {
      // Show loading indicator first
      List<PopupMenuEntry<DeviceItem>> menuItems = [
        const PopupMenuItem<DeviceItem>(
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
          const PopupMenuItem<DeviceItem>(
            enabled: false,
            child: Text('You must be logged in to view devices'),
          ),
        ];
      }
      
      // Get devices from the DeviceViewModel instead of accessing Firebase directly
      final deviceViewModel = Provider.of<DeviceViewModel>(context, listen: false);
      await deviceViewModel.loadDevices(); // Ensure the latest data is loaded
      
      // Create menu items from the devices - only displaying the device name
      if (deviceViewModel.devices.isNotEmpty) {
        menuItems = deviceViewModel.devices.map((device) {
          return PopupMenuItem<DeviceItem>(
            value: DeviceItem(
              id: device.id ?? '',
              name: device.model,
              manufacturer: device.manufacturer,
              category: device.category,
            ),
            child: Text(device.model), // Just display the device name
          );
        }).toList();
      } else {
        // If no devices were found in the view model
        menuItems = [
          PopupMenuItem<DeviceItem>(
            enabled: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('No devices available'),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the menu
                    Navigator.pushNamed(context, '/devices'); // Navigate to devices page
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
        PopupMenuItem<DeviceItem>(
          enabled: false,
          child: Text('Error: ${e.toString()}', style: const TextStyle(color: Colors.red)),
        ),
      ];
    }
  }
}
