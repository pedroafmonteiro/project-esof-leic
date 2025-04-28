import 'package:flutter/material.dart';
import 'package:eco_tracker/models/device_model.dart';
import 'package:eco_tracker/services/device_service.dart';

class MaintainerDevicesInfoView extends StatefulWidget {
  final String deviceId;
  final String companyId;

  const MaintainerDevicesInfoView({
    super.key,
    required this.deviceId,
    required this.companyId,
  });

  @override
  State<MaintainerDevicesInfoView> createState() =>
      _MaintainerDevicesInfoViewState();
}

class _MaintainerDevicesInfoViewState extends State<MaintainerDevicesInfoView> {
  late Future<Map<String, dynamic>> _deviceInfoFuture;
  final DeviceService _deviceService = DeviceService();

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  void _loadDeviceInfo() {
    _deviceInfoFuture = _deviceService.getCompanyDeviceStatistics(
      widget.companyId,
      widget.deviceId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Statistics'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _deviceInfoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading device statistics: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No statistics available for this device',
                textAlign: TextAlign.center,
              ),
            );
          }

          final deviceStats = snapshot.data!;
          final device = deviceStats['device'] as Device;
          final userCount = deviceStats['userCount'] as int;
          final totalUsage = deviceStats['totalUsage'] as double;
          final avgUsagePerUser = userCount > 0 ? totalUsage / userCount : 0.0;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${device.manufacturer} ${device.model}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text('Category: ${device.category}'),
                        Text('Power Consumption: ${device.powerConsumption} W'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Usage Statistics',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        _buildStatRow(
                          context,
                          'Total Users',
                          '$userCount',
                          Icons.people,
                        ),
                        const SizedBox(height: 12),
                        _buildStatRow(
                          context,
                          'Total Usage',
                          '${totalUsage.toStringAsFixed(2)} kWh',
                          Icons.power,
                        ),
                        const SizedBox(height: 12),
                        _buildStatRow(
                          context,
                          'Average Usage per User',
                          '${avgUsagePerUser.toStringAsFixed(2)} kWh',
                          Icons.person,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _showEditDeviceSheet(context, device);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Device'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        _showDeleteConfirmation(context, device);
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete Device'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
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
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16.0,
          right: 16.0,
          top: 16.0,
        ),
        child: Form(
          key: formKey,
          child: Wrap(
            runSpacing: 8.0,
            children: [
              Text(
                'Edit Company Device',
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
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final updatedDevice = device.copyWith(
                        model: modelController.text,
                        manufacturer: manufacturerController.text,
                        category: categoryController.text,
                        powerConsumption:
                            int.parse(powerConsumptionController.text),
                      );

                      await _deviceService.updateCompanyDevice(
                        widget.companyId,
                        updatedDevice,
                      );

                      if (mounted) {
                        Navigator.pop(context);
                        setState(() {
                          _loadDeviceInfo();
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

  void _showDeleteConfirmation(BuildContext context, Device device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          'Are you sure you want to delete ${device.manufacturer} ${device.model}?\n\n'
          'This will remove the device from the company catalog and cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deviceService.deleteCompanyDevice(
                widget.companyId,
                device.id!,
              );
              if (mounted) {
                Navigator.pop(context);
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
