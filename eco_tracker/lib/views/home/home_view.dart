import 'package:eco_tracker/models/device_model.dart';
import 'package:eco_tracker/models/graph_data_model.dart';
import 'package:eco_tracker/services/device_service.dart';
import 'package:eco_tracker/viewmodels/device_view_model.dart';
import 'package:eco_tracker/viewmodels/statistics_view_model.dart';
import 'package:eco_tracker/views/common/general_page.dart';
import 'package:eco_tracker/views/common/general_bottom_sheet.dart';
import 'package:eco_tracker/views/home/widgets/device_picker.dart';
import 'package:eco_tracker/services/usage_service.dart';
import 'package:eco_tracker/views/navigation/navigation_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eco_tracker/services/tips_service.dart';

class HomeView extends GeneralPage {
  HomeView({super.key})
      : super(title: 'Home', hasFAB: true, fabIcon: Icon(Icons.bolt));
  final TipsService _tipsService = TipsService();
  final UsageService _usageService = UsageService();

  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Future<void> onRefresh(BuildContext context) async {
    return Provider.of<StatisticsViewModel>(context, listen: false)
        .initializeData();
  }

  Widget _buildUsageSummaryCard(BuildContext context, MonthlyChartData data) {
    final now = DateTime.now();
    return GestureDetector(
      onTap: () {
        NavigationView.navigateTo(1, statisticsTabIndex: 2);
      },
      child: Card(
        child: ListTile(
          title: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              '${_monthNames[now.month - 1]} ${now.year}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estimated Cost',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  Text(
                    '${data.totalCost.toStringAsFixed(2)} €',
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total Usage',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  Text(
                    '${data.totalConsumption.toStringAsFixed(2)} kWh',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ],
          ),
          contentPadding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
          ),
        ),
      ),
    );
  }

  Widget _buildTopThreeCard(BuildContext context, MonthlyChartData data) {
    final statisticsViewModel = Provider.of<StatisticsViewModel>(context);
    final monthlyUsage = statisticsViewModel.monthlyUsage;

    if (monthlyUsage == null || monthlyUsage.deviceConsumption.isEmpty) {
      return GestureDetector(
        onTap: () {
          NavigationView.navigateTo(1, statisticsTabIndex: 2);
        },
        child: Card(
          child: ListTile(
            title: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Top energy consumers',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            subtitle: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'No device usage data available',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
          ),
        ),
      );
    }

    final deviceConsumptionList = monthlyUsage.deviceConsumption.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topDevices = deviceConsumptionList.take(3).toList();

    return FutureBuilder<List<String>>(
      future: _getDeviceNames(topDevices.map((e) => e.key).toList()),
      builder: (context, snapshot) {
        List<String> deviceNames = [];

        if (snapshot.hasData) {
          deviceNames = snapshot.data!;
        } else {
          deviceNames = List.generate(
            topDevices.length,
            (index) => 'Device ${index + 1}',
          );
        }

        return GestureDetector(
          onTap: () {
            NavigationView.navigateTo(1, statisticsTabIndex: 2);
          },
          child: Card(
            child: ListTile(
              title: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Top energy consumers',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0; i < topDevices.length; i++)
                          Text(
                            deviceNames[i],
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (var device in topDevices)
                          Text(
                            '${device.value.toStringAsFixed(2)} kWh',
                            style: Theme.of(context).textTheme.labelLarge,
                            textAlign: TextAlign.right,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              contentPadding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: 16.0,
                top: 8.0,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<List<String>> _getDeviceNames(List<String> deviceIds) async {
    final deviceService = DeviceService();
    List<String> deviceNames = [];

    for (String id in deviceIds) {
      final device = await deviceService.getDeviceById(id);
      if (device != null) {
        deviceNames.add('${device.manufacturer} ${device.model}');
      } else {
        deviceNames.add('Unknown Device');
      }
    }

    return deviceNames;
  }

  Widget _buildTipOfTheDayCard(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: ListTile(
        title: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            'Tip of the Day',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                ),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: FutureBuilder<String>(
            future: _tipsService.getTodaysTip(),
            builder: (context, snapshot) {
              return Text(
                snapshot.hasData
                    ? snapshot.data!
                    : snapshot.hasError
                        ? 'Could not load tip. Pull to refresh.'
                        : 'No tip available',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                    ),
                textAlign: TextAlign.center,
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final statisticsViewModel = Provider.of<StatisticsViewModel>(context);

    if (statisticsViewModel.monthlyUsage == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final data = MonthlyChartData.fromMonthlySummary(
      statisticsViewModel.monthlyUsage!.dailyConsumption,
      statisticsViewModel.selectedMonth,
      statisticsViewModel.selectedMonthYear,
    );

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        _buildUsageSummaryCard(context, data),
        const SizedBox(height: 8.0),
        _buildTopThreeCard(context, data),
        const SizedBox(height: 8.0),
        _buildTipOfTheDayCard(context),
      ],
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
