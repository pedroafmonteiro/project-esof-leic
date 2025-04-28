import 'package:eco_tracker/models/graph_data_model.dart';
import 'package:eco_tracker/viewmodels/statistics_view_model.dart';
import 'package:eco_tracker/views/statistics/widgets/graphs/monthly_graph.dart';
import 'package:eco_tracker/views/statistics/widgets/statistics_card.dart';
import 'package:eco_tracker/views/statistics/widgets/top_consumers.dart'; // Import for TopConsumers widget
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MonthlyView extends StatelessWidget {
  const MonthlyView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<StatisticsViewModel>(context);
    final monthlyUsage = viewModel.monthlyUsage;

    if (viewModel.isLoadingMonthly) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.monthlyError != null) {
      return Center(
        child: Text(
          'Error loading data: ${viewModel.monthlyError}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    if (monthlyUsage == null) {
      return const Center(child: Text('No data available for this month.'));
    }

    final monthName = DateFormat('MMMM')
        .format(DateTime(viewModel.selectedMonthYear, viewModel.selectedMonth));

    final chartData = MonthlyChartData.fromMonthlySummary(
      monthlyUsage.dailyConsumption,
      viewModel.selectedMonth,
      viewModel.selectedMonthYear,
    );

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Column(
            spacing: 8.0,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => _selectMonth(context, viewModel),
                  child: Text(
                    '$monthName ${viewModel.selectedMonthYear}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ),
              StatisticsCard(
                data: chartData.totalConsumption,
                title: 'Monthly Usage',
                extension: 'kWh',
              ),
              StatisticsCard(
                data: chartData.totalCost,
                title: 'Monthly Cost',
                extension: '€',
              ),
              if (monthlyUsage.deviceConsumption.isNotEmpty) ...[
                MonthlyGraph(chartData: chartData),
                TopConsumers(
                  deviceConsumption: monthlyUsage.deviceConsumption,
                ),
              ],
              if (monthlyUsage.deviceConsumption.isEmpty)
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: const Center(
                    child: Text(
                      'No device usage data recorded for this month.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _selectMonth(
    BuildContext context,
    StatisticsViewModel viewModel,
  ) async {
    final currentMonth = viewModel.selectedMonth;
    final currentYear = viewModel.selectedMonthYear;

    final monthNames = [
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Month'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${monthNames[currentMonth - 1]} $currentYear'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    int newMonth = currentMonth - 1;
                    int newYear = currentYear;

                    if (newMonth < 1) {
                      newMonth = 12;
                      newYear--;
                    }

                    viewModel.changeSelectedMonth(newMonth, newYear);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Previous'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    int newMonth = currentMonth + 1;
                    int newYear = currentYear;

                    if (newMonth > 12) {
                      newMonth = 1;
                      newYear++;
                    }

                    viewModel.changeSelectedMonth(newMonth, newYear);
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
