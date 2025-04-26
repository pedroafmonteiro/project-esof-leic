import 'package:animations/animations.dart';
import 'package:eco_tracker/viewmodels/statistics_view_model.dart';
import 'package:eco_tracker/views/common/general_page.dart';
import 'package:eco_tracker/views/statistics/widgets/graphs/monthly_graph.dart';
import 'package:eco_tracker/views/statistics/widgets/graphs/weekly_graph.dart';
import 'package:eco_tracker/views/statistics/widgets/graphs/yearly_graph.dart';
import 'package:eco_tracker/views/statistics/widgets/statistics_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StatisticsView extends StatefulWidget {
  const StatisticsView({super.key});

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return StatisticsPage(
      selectedIndex: _selectedIndex,
      onFilterChanged: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }
}

class StatisticsPage extends GeneralPage {
  final int selectedIndex;
  final void Function(int) onFilterChanged;

  const StatisticsPage({
    super.key,
    required this.selectedIndex,
    required this.onFilterChanged,
  }) : super(title: "Statistics", hasFAB: false);

  @override
  Widget buildBody(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FilterChip(
              label: const Text("Daily"),
              selected: selectedIndex == 0,
              showCheckmark: false,
              onSelected: (value) {
                if (value) {
                  onFilterChanged(0);
                }
              },
            ),
            FilterChip(
              label: const Text("Weekly"),
              selected: selectedIndex == 1,
              showCheckmark: false,
              onSelected: (value) {
                if (value) {
                  onFilterChanged(1);
                }
              },
            ),
            FilterChip(
              label: const Text("Monthly"),
              selected: selectedIndex == 2,
              showCheckmark: false,
              onSelected: (value) {
                if (value) {
                  onFilterChanged(2);
                }
              },
            ),
            FilterChip(
              label: const Text("Yearly"),
              selected: selectedIndex == 3,
              showCheckmark: false,
              onSelected: (value) {
                if (value) {
                  onFilterChanged(3);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: PageTransitionSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation, secondaryAnimation) =>
                SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              child: child,
            ),
            child: _getPageForIndex(selectedIndex, context),
          ),
        ),
      ],
    );
  }

  Widget _getPageForIndex(int index, BuildContext context) {
    switch (index) {
      case 0:
        return _buildDailyPage(context);
      case 1:
        return const WeeklyGraph();
      case 2:
        return const MonthlyGraph();
      case 3:
        return const YearlyGraph();
      default:
        return _buildDailyPage(context);
    }
  }

  Widget _buildDailyPage(BuildContext context) {
    final viewModel = Provider.of<StatisticsViewModel>(context);
    final dailyUsage = viewModel.dailyUsage;

    if (viewModel.isLoadingDaily) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.dailyError != null) {
      return Center(
        child: Text(
          'Error loading data: ${viewModel.dailyError}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
        ),
      );
    }

    final double usageKwh = dailyUsage?.totalKwh ?? 0;
    final double costEuros = dailyUsage?.totalCost ?? 0;

    return Column(
      key: const ValueKey<int>(0),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('MMM dd, yyyy').format(viewModel.selectedDate),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context, viewModel),
              ),
            ],
          ),
        ),
        StatisticsCard(
          data: usageKwh,
          title: 'Estimated Usage',
          extension: 'kWh',
        ),
        const SizedBox(height: 8.0),
        StatisticsCard(
          data: costEuros,
          title: 'Estimated Cost',
          extension: '€',
        ),
        if (dailyUsage != null && dailyUsage.deviceConsumption.isNotEmpty)
          Expanded(
            child: _buildTopConsumers(context, dailyUsage.deviceConsumption),
          ),
        if (dailyUsage == null || dailyUsage.deviceConsumption.isEmpty)
          const Expanded(
            child: Center(
              child: Text(
                'No usage data recorded for this day.\nTry selecting another date or log device usage.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTopConsumers(
    BuildContext context,
    Map<String, double> deviceConsumption,
  ) {
    final sortedDevices = deviceConsumption.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
          child: Text(
            'Top Energy Consumers',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: sortedDevices.length,
            itemBuilder: (context, index) {
              final entry = sortedDevices[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: ListTile(
                  leading: const Icon(
                      Icons.devices), // TODO: Use device-specific icon
                  title: FutureBuilder<String>(
                    future: _getDeviceName(entry.key),
                    builder: (context, snapshot) {
                      return Text(snapshot.data ?? 'Device ${index + 1}');
                    },
                  ),
                  subtitle: Text('${entry.value.toStringAsFixed(2)} kWh'),
                  trailing: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '#${index + 1}',
                        style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<String> _getDeviceName(String deviceId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return deviceId;
  }

  Future<void> _selectDate(
    BuildContext context,
    StatisticsViewModel viewModel,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: viewModel.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != viewModel.selectedDate) {
      viewModel.changeSelectedDate(picked);
    }
  }
}
