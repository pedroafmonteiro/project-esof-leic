import 'package:eco_tracker/models/device_model.dart';
import 'package:eco_tracker/viewmodels/device_view_model.dart';
import 'package:eco_tracker/views/common/general_page.dart';
import 'package:eco_tracker/views/common/general_bottom_sheet.dart';
import 'package:eco_tracker/views/home/widgets/device_picker.dart';
import 'package:eco_tracker/services/usage_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eco_tracker/services/tips_service.dart';

class HomeView extends GeneralPage {
  HomeView({super.key})
      : super(title: 'Home', hasFAB: true, fabIcon: Icon(Icons.bolt));
  final TipsService tipsService = TipsService();
  final UsageService _usageService = UsageService();

  @override
  Widget buildBody(BuildContext context) {
    return FutureBuilder<String>(
      future: tipsService.getTodaysTip(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return Card(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            child: ListTile(
              title: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Tip of the Day',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  snapshot.data!,
                  style: Theme.of(context).textTheme.labelLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        } else {
          return Center(child: Text('No tip available'));
        }
      },
    );
  }

  @override
  void fabFunction(BuildContext context) {
    final hoursController = TextEditingController();
    final minutesController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Device? selectedDevice;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return GeneralBottomSheet(
              child: Form(
                key: formKey,
                child: Wrap(
                  runSpacing: 8.0,
                  children: [
                    Text(
                      selectedDevice != null
                          ? '${selectedDevice!.manufacturer} ${selectedDevice!.model}'
                          : 'Log Usage',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    GestureDetector(
                      onTap: () async {
                        final deviceViewModel = Provider.of<DeviceViewModel>(
                          context,
                          listen: false,
                        );
                        await deviceViewModel.loadDevices();

                        final Device? result =
                            await DevicePicker.showDeviceDialog(
                          context: context,
                          devices: deviceViewModel.devices,
                          selectedDevice: selectedDevice,
                        );

                        if (result != null) {
                          setState(() {
                            selectedDevice = result;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          selectedDevice != null
                              ? 'Change device'
                              : 'Choose device',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: hoursController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Hours',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Field cannot be empty.';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: minutesController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Minutes',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Field cannot be empty.';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              selectedDevice != null
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                            ),
                            foregroundColor: WidgetStateProperty.all(
                              selectedDevice != null
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                            ),
                          ),
                          onPressed: selectedDevice != null
                              ? () async {
                                  if (formKey.currentState!.validate()) {
                                    final hours =
                                        int.tryParse(hoursController.text) ?? 0;
                                    final minutes =
                                        int.tryParse(minutesController.text) ??
                                            0;

                                    final durationSeconds =
                                        (hours * 3600) + (minutes * 60);

                                    final success = selectedDevice!.id != null
                                        ? await _usageService.logDeviceUsage(
                                            deviceId: selectedDevice!.id!,
                                            durationSeconds: durationSeconds,
                                          )
                                        : false;

                                    final message = success
                                        ? 'Logged ${hours}h ${minutes}m for ${selectedDevice!.manufacturer} ${selectedDevice!.model}'
                                        : 'Failed to log usage. Please try again.';

                                    final backgroundColor = success
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.error;

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(message),
                                        backgroundColor: backgroundColor,
                                      ),
                                    );

                                    Navigator.pop(context);
                                  }
                                }
                              : null,
                          child: Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
