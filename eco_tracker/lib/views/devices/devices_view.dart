import 'package:eco_tracker/models/device_model.dart';
import 'package:eco_tracker/views/common/general_bottom_sheet.dart';
import 'package:eco_tracker/views/common/general_page.dart';
import 'package:eco_tracker/viewmodels/device_view_model.dart';
import 'package:eco_tracker/views/maintainer/maintainer_devices_info_view.dart';
import 'package:eco_tracker/views/maintainer/maintainer_devices_view.dart';
import 'package:eco_tracker/services/authentication_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DevicesView extends GeneralPage {
  DevicesView({super.key})
      : super(title: "Devices", hasFAB: true, fabIcon: Icon(Icons.add));

  @override
  Future<void> onRefresh(BuildContext context) {
    return Provider.of<DeviceViewModel>(context, listen: false).loadDevices();
  }

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
      builder: (context) => GeneralBottomSheet(
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
                    onPressed: () async {
                      final selectedDevice = await showModalBottomSheet<Device>(
                        context: context,
                        builder: (context) {
                          return Consumer<DeviceViewModel>(
                            builder: (context, viewModel, child) {
                              if (viewModel.devices.isEmpty) {
                                return Center(child: Text('No devices available.'));
                              }
                              return ListView.builder(
                                itemCount: viewModel.devices.length,
                                itemBuilder: (context, index) {
                                  final device = viewModel.devices[index];
                                  return ListTile(
                                    title: Text(device.model),
                                    subtitle: Text('${device.manufacturer} - ${device.category}'),
                                    trailing: Text('${device.powerConsumption} W'),
                                    onTap: () {
                                      Navigator.pop(context, device);
                                    },
                                  );
                                },
                              );
                            },
                          );
                        },
                      );

                      if (selectedDevice != null) {
                        modelController.text = selectedDevice.model;
                        manufacturerController.text = selectedDevice.manufacturer;
                        categoryController.text = selectedDevice.category;
                        powerConsumptionController.text = selectedDevice.powerConsumption.toString();
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        Theme.of(context).colorScheme.secondary,
                      ),
                      foregroundColor: WidgetStateProperty.all(
                        Theme.of(context).colorScheme.onSecondary,
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
              Text(
                'Edit device',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              TextFormField(
                controller: modelController,
                decoration: InputDecoration(
                  hintText: 'Model',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Field cannot be empty.' : null,
              ),
              TextFormField(
                controller: manufacturerController,
                decoration: InputDecoration(
                  hintText: 'Manufacturer',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Field cannot be empty.' : null,
              ),
              TextFormField(
                controller: categoryController,
                decoration: InputDecoration(
                  hintText: 'Category',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Field cannot be empty.' : null,
              ),
              TextFormField(
                controller: powerConsumptionController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Power consumption (Wattage)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Field cannot be empty.' : null,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
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
                      final updatedDevice = device.copyWith(
                        model: modelController.text,
                        manufacturer: manufacturerController.text,
                        category: categoryController.text,
                        powerConsumption: int.parse(powerConsumptionController.text),
                      );
                      Provider.of<DeviceViewModel>(
                        context,
                        listen: false,
                      ).updateDevice(updatedDevice);
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final isMaintainer = Provider.of<AuthenticationService>(context).isMaintainer;

    return Column(
      children: [
        if (isMaintainer) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MaintainerDevicesView()));
              },
              icon: Icon(Icons.admin_panel_settings),
              label: Text("Maintainer Panel"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MaintainerDevicesInfoView()));
              },
              icon: Icon(Icons.info_outline),
              label: Text("Maintainer Info"),
            ),
          ),
        ],
        Expanded(
          child: Consumer<DeviceViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return Center(child: CircularProgressIndicator());
              } else if (viewModel.devices.isNotEmpty) {
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
                              icon: Icon(Icons.edit_rounded),
                              onPressed: () {
                                _showEditDeviceSheet(context, device);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_rounded),
                              onPressed: () {
                                Provider.of<DeviceViewModel>(context, listen: false).removeDevice(device.id!);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
              return CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    child: Center(child: Text("You haven't added any devices yet.")),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
