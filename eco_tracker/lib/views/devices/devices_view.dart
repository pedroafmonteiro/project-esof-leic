import 'package:eco_tracker/models/device_model.dart';
import 'package:eco_tracker/services/device_service.dart';
import 'package:eco_tracker/services/user_service.dart';
import 'package:eco_tracker/views/common/general_bottom_sheet.dart';
import 'package:eco_tracker/views/common/general_page.dart';
import 'package:eco_tracker/viewmodels/device_view_model.dart';
import 'package:eco_tracker/views/maintainer/maintainer_devices_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DevicesView extends GeneralPage {
  DevicesView({super.key})
      : super(
          title: "Devices",
          hasFAB: true,
          fabIcon: Icon(Icons.add),
          secondaryActions: [
            Builder(
              builder: (context) {
                return FutureBuilder<bool>(
                  future: UserService().isMaintainer(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!) {
                      return IconButton(
                        icon: const Icon(Icons.domain_add_rounded),
                        tooltip: "Maintainer Panel",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const MaintainerDevicesView(),
                            ),
                          );
                        },
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                );
              },
            ),
          ],
        );

  @override
  Future<void> onRefresh(BuildContext context) async {
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
                decoration: const InputDecoration(
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
                decoration: const InputDecoration(
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
                decoration: const InputDecoration(
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
                decoration: const InputDecoration(
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
                      final deviceService = DeviceService();
                      final companyDevices =
                          await deviceService.getAllCompanyDevices();

                      final selectedDevice = await showModalBottomSheet<Device>(
                        context: context,
                        builder: (context) {
                          if (companyDevices.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('No company devices available.'),
                              ),
                            );
                          }

                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  'Company Devices Catalog',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: companyDevices.length,
                                  itemBuilder: (context, index) {
                                    final device = companyDevices[index];
                                    return ListTile(
                                      title: Text(device.model),
                                      subtitle: Text(
                                        '${device.manufacturer} - ${device.category}',
                                      ),
                                      trailing:
                                          Text('${device.powerConsumption} W'),
                                      onTap: () {
                                        Navigator.pop(context, device);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      );

                      if (selectedDevice != null) {
                        final String manufacturer =
                            selectedDevice.manufacturer.contains(' (')
                                ? selectedDevice.manufacturer.substring(
                                    0,
                                    selectedDevice.manufacturer.indexOf(' ('),
                                  )
                                : selectedDevice.manufacturer;

                        modelController.text = selectedDevice.model;
                        manufacturerController.text = manufacturer;
                        categoryController.text = selectedDevice.category;
                        powerConsumptionController.text =
                            selectedDevice.powerConsumption.toString();
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
                    child: const Text('Select from companies'),
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
                    child: const Text('Save'),
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
    final manufacturerController =
        TextEditingController(text: device.manufacturer);
    final categoryController = TextEditingController(text: device.category);
    final powerConsumptionController =
        TextEditingController(text: device.powerConsumption.toString());
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
                decoration: const InputDecoration(
                  hintText: 'Model',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Field cannot be empty.'
                    : null,
              ),
              TextFormField(
                controller: manufacturerController,
                decoration: const InputDecoration(
                  hintText: 'Manufacturer',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Field cannot be empty.'
                    : null,
              ),
              TextFormField(
                controller: categoryController,
                decoration: const InputDecoration(
                  hintText: 'Category',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Field cannot be empty.'
                    : null,
              ),
              TextFormField(
                controller: powerConsumptionController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Power consumption (Wattage)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Field cannot be empty.'
                    : null,
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
                        powerConsumption:
                            int.parse(powerConsumptionController.text),
                      );
                      Provider.of<DeviceViewModel>(
                        context,
                        listen: false,
                      ).updateDevice(updatedDevice);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'),
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
    return Consumer<DeviceViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (viewModel.devices.isNotEmpty) {
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 8.0),
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
                        icon: const Icon(Icons.edit_rounded),
                        onPressed: () {
                          _showEditDeviceSheet(context, device);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_rounded),
                        onPressed: () {
                          Provider.of<DeviceViewModel>(
                            context,
                            listen: false,
                          ).removeDevice(device.id!);
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
            const SliverFillRemaining(
              child: Center(
                child: Text("You haven't added any devices yet."),
              ),
            ),
          ],
        );
      },
    );
  }
}
