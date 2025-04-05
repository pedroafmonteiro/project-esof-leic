import 'package:eco_tracker/models/device_model.dart';
import 'package:eco_tracker/views/common/general_bottom_sheet.dart';
import 'package:eco_tracker/views/common/general_page.dart';
import 'package:eco_tracker/viewmodels/device_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DevicesView extends GeneralPage {
  DevicesView({super.key})
    : super(title: "Devices", hasFAB: true, fabIcon: Icon(Icons.add));

  @override
  void fabFunction(BuildContext context) {
    final modelController = TextEditingController();
    final manufacturerController = TextEditingController();
    final categoryController = TextEditingController();
    final powerConsumptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => GeneralBottomSheet(
            child: Form(
              key: formKey,
              child: Wrap(
                runSpacing: 8.0,
                children: [
                  Text(
                    'Add device',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  TextFormField(
                    controller: modelController,
                    decoration: InputDecoration(
                      hintText: 'Model',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Field cannot be empty.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: manufacturerController,
                    decoration: InputDecoration(
                      hintText: 'Manufacturer',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Field cannot be empty.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: categoryController,
                    decoration: InputDecoration(
                      hintText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Field cannot be empty.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: powerConsumptionController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Power consumption (Wattage)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Field cannot be empty.';
                      }
                      return null;
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: null,
                        style: ButtonStyle(
                          padding: WidgetStateProperty.all(
                            EdgeInsets.only(left: 0.0),
                          ),
                          backgroundColor: WidgetStateProperty.all(
                            Colors.transparent,
                          ),
                        ),
                        child: Text('Select from list'),
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            Theme.of(context).colorScheme.primary,
                          ),
                          foregroundColor: WidgetStateProperty.all(
                            Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final device = Device(
                              model: modelController.text,
                              manufacturer: manufacturerController.text,
                              category: categoryController.text,
                              powerConsumption: int.parse(
                                powerConsumptionController.text,
                              ),
                            );
                            Provider.of<DeviceViewModel>(
                              context,
                              listen: false,
                            ).addDevice(device);
                            Navigator.pop(context);
                          }
                        },
                        child: Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
   void _showEditDeviceSheet(BuildContext context, Device device) {
      final modelController = TextEditingController(text: device.model);
      final manufacturerController = TextEditingController(text: device.manufacturer);
      final categoryController = TextEditingController(text: device.category);
      final powerConsumptionController = TextEditingController(text: device.powerConsumption.toString());
      final formKey = GlobalKey<FormState>();

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => GeneralBottomSheet(
          child: Form(
            key: formKey,
            child: Wrap(
              runSpacing: 8.0,
              children: [
                Text('Edit device', style: Theme.of(context).textTheme.headlineSmall),
                TextFormField(
                  controller: modelController,
                  decoration: InputDecoration(hintText: 'Model'),
                  validator: (value) => value == null || value.isEmpty ? 'Field cannot be empty.' : null,
                ),
                TextFormField(
                  controller: manufacturerController,
                  decoration: InputDecoration(hintText: 'Manufacturer'),
                  validator: (value) => value == null || value.isEmpty ? 'Field cannot be empty.' : null,
                ),
                TextFormField(
                  controller: categoryController,
                  decoration: InputDecoration(hintText: 'Category'),
                  validator: (value) => value == null || value.isEmpty ? 'Field cannot be empty.' : null,
                ),
                TextFormField(
                  controller: powerConsumptionController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(hintText: 'Power consumption (Wattage)'),
                  validator: (value) => value == null || value.isEmpty ? 'Field cannot be empty.' : null,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final updatedDevice = device.copyWith(
                        model: modelController.text,
                        manufacturer: manufacturerController.text,
                        category: categoryController.text,
                        powerConsumption: int.parse(powerConsumptionController.text),
                      );
                      Provider.of<DeviceViewModel>(context, listen: false)
                          .updateDevice(updatedDevice);
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      );
    }

  @override
  Widget buildBody(BuildContext context) {
    return Consumer<DeviceViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.devices.isNotEmpty) {
          return ListView.builder(
            itemCount: viewModel.devices.length,
            itemBuilder: (context, index) {
              final device = viewModel.devices[index];
              return Card(
                child: ListTile(
                  title: Text(device.model),
                  subtitle: Text('${device.manufacturer} - ${device.category}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showEditDeviceSheet(context, device);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          Provider.of<DeviceViewModel>(context, listen: false)
                              .removeDevice(device.id!);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
        return Center(child: Text("You haven't added any devices."));
      },
    );
  }
}
