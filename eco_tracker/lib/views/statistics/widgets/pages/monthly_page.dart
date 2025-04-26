import 'package:eco_tracker/models/graph_data_model.dart';
import 'package:eco_tracker/viewmodels/statistics_view_model.dart';
import 'package:eco_tracker/views/statistics/widgets/graphs/monthly_graph.dart';
import 'package:eco_tracker/views/statistics/widgets/statistics_card.dart';
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
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$monthName ${viewModel.selectedMonthYear}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: () => _selectMonth(context, viewModel),
              ),
            ],
          ),
        ),
        StatisticsCard(
          data: chartData.totalConsumption,
          title: 'Monthly Usage',
          extension: 'kWh',
        ),
        const SizedBox(height: 8),
        StatisticsCard(
          data: chartData.totalCost,
          title: 'Monthly Cost',
          extension: '€',
        ),
        const SizedBox(height: 8),
        MonthlyGraph(chartData: chartData),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();

                    int newMonth = currentMonth - 1;
                    int newYear = currentYear;

                    if (newMonth < 1) {
                      newMonth = 12;
                      newYear--;
                    }

                    viewModel.changeSelectedMonth(newMonth, newYear);
                  },
                  child: const Text('Previous Month'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();

                    int newMonth = currentMonth + 1;
                    int newYear = currentYear;

                    if (newMonth > 12) {
                      newMonth = 1;
                      newYear++;
                    }

                    viewModel.changeSelectedMonth(newMonth, newYear);
                  },
                  child: const Text('Next Month'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
