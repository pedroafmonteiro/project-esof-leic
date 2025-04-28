import 'package:eco_tracker/models/device_model.dart';
import 'package:eco_tracker/services/device_service.dart';
import 'package:eco_tracker/services/user_service.dart';
import 'package:eco_tracker/views/common/general_bottom_sheet.dart';
import 'package:eco_tracker/views/maintainer/maintainer_devices_info_view.dart';
import 'package:flutter/material.dart';

class MaintainerDevicesView extends StatefulWidget {
  const MaintainerDevicesView({super.key});

  @override
  State<MaintainerDevicesView> createState() => _MaintainerDevicesViewState();
}

class _MaintainerDevicesViewState extends State<MaintainerDevicesView> {
  final DeviceService _deviceService = DeviceService();
  final UserService _userService = UserService();
  Future<List<Device>> _devicesFuture = Future.value([]);
  late Future<String> _companyFuture;
  String? _companyId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _companyFuture = _userService.getUserCompany();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final company = await _userService.getUserCompany();
      _companyId = company;
      setState(() {
        _devicesFuture = _deviceService.getCompanyDevices(company);
      });
    } catch (e) {
      debugPrint('Error loading company devices: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAddDeviceSheet() {
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
                'Add Company Device',
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
                  onPressed: () async {
                    if (formKey.currentState!.validate() &&
                        _companyId != null) {
                      final device = Device(
                        model: modelController.text,
                        manufacturer: manufacturerController.text,
                        category: categoryController.text,
                        powerConsumption:
                            int.parse(powerConsumptionController.text),
                      );

                      await _deviceService.addCompanyDevice(
                        _companyId!,
                        device,
                      );

                      if (mounted) {
                        Navigator.pop(context);
                        setState(() {
                          _loadDevices();
                        });
                      }
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Devices'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDeviceSheet,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<String>(
        future: _companyFuture,
        builder: (context, companySnapshot) {
          if (companySnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (companySnapshot.hasError ||
              companySnapshot.data == null ||
              companySnapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'No company associated with your account',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Please contact your administrator to assign you to a company.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          _companyId = companySnapshot.data;

          return FutureBuilder<List<Device>>(
            future: _devicesFuture,
            builder: (context, snapshot) {
              if (_isLoading ||
                  snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading devices: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No devices in your company catalog',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _showAddDeviceSheet,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Device'),
                      ),
                    ],
                  ),
                );
              }

              final devices = snapshot.data!;

              return RefreshIndicator(
                onRefresh: _loadDevices,
                child: ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 8.0,
                      ),
                      child: ListTile(
                        title: Text(device.model),
                        subtitle:
                            Text('${device.manufacturer} - ${device.category}'),
                        trailing: Text('${device.powerConsumption} W'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MaintainerDevicesInfoView(
                                deviceId: device.id!,
                                companyId: _companyId!,
                              ),
                            ),
                          ).then((_) => _loadDevices());
                        },
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
