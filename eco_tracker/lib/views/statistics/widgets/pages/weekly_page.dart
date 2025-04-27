import 'package:eco_tracker/models/graph_data_model.dart';
import 'package:eco_tracker/viewmodels/statistics_view_model.dart';
import 'package:eco_tracker/views/statistics/widgets/graphs/weekly_graph.dart';
import 'package:eco_tracker/views/statistics/widgets/statistics_card.dart';
import 'package:eco_tracker/views/statistics/widgets/top_consumers.dart'; // Import for TopConsumers widget
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WeeklyView extends StatelessWidget {
  const WeeklyView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<StatisticsViewModel>(context);
    final weeklyUsage = viewModel.weeklyUsage;

    if (viewModel.isLoadingWeekly) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.weeklyError != null) {
      return Center(
        child: Text(
          'Error loading data: ${viewModel.weeklyError}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    if (weeklyUsage == null) {
      return const Center(child: Text('No data available for this week.'));
    }

    final chartData =
        WeeklyChartData.fromWeeklySummary(weeklyUsage.dailyConsumption);

    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Column(
            spacing: 8.0,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => _selectWeek(context, viewModel),
                  child: Text(
                    'Week ${viewModel.selectedWeekNumber}, ${viewModel.selectedWeekYear}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ),
              StatisticsCard(
                data: chartData.totalConsumption,
                title: 'Weekly Usage',
                extension: 'kWh',
              ),
              StatisticsCard(
                data: chartData.totalCost,
                title: 'Weekly Cost',
                extension: '€',
              ),
              if (weeklyUsage.deviceConsumption.isNotEmpty) ...[
                WeeklyGraph(chartData: chartData),
                TopConsumers(
                  deviceConsumption: weeklyUsage.deviceConsumption,
                ),
              ],
              if (weeklyUsage.deviceConsumption.isEmpty)
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: const Center(
                    child: Text(
                      'No device usage data recorded for this week.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectWeek(
    BuildContext context,
    StatisticsViewModel viewModel,
  ) async {
    final currentYear = viewModel.selectedWeekYear;
    final currentWeek = viewModel.selectedWeekNumber;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Week'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Week $currentWeek, $currentYear'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    int newWeek = currentWeek - 1;
                    int newYear = currentYear;

                    if (newWeek < 1) {
                      newWeek = 52;
                      newYear--;
                    }

                    viewModel.changeSelectedWeek(newWeek, newYear);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Previous'),
                ),
                ElevatedButton(
                  onPressed: () {
                    int newWeek = currentWeek + 1;
                    int newYear = currentYear;

                    if (newWeek > 52) {
                      newWeek = 1;
                      newYear++;
                    }

                    viewModel.changeSelectedWeek(newWeek, newYear);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
