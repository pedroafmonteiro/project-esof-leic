import 'package:eco_tracker/models/graph_data_model.dart';
import 'package:eco_tracker/viewmodels/statistics_view_model.dart';
import 'package:eco_tracker/views/statistics/widgets/graphs/yearly_graph.dart';
import 'package:eco_tracker/views/statistics/widgets/statistics_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class YearlyView extends StatelessWidget {
  const YearlyView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<StatisticsViewModel>(context);
    final yearlyUsage = viewModel.yearlyUsage;

    if (viewModel.isLoadingYearly) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.yearlyError != null) {
      return Center(
        child: Text(
          'Error loading data: ${viewModel.yearlyError}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
        ),
      );
    }

    if (yearlyUsage == null) {
      return const Center(child: Text('No data available for this year.'));
    }

    final chartData =
        YearlyChartData.fromYearlySummary(yearlyUsage.monthlyConsumption);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Year ${viewModel.selectedYear}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: () => _selectYear(context, viewModel),
              ),
            ],
          ),
        ),
        StatisticsCard(
          data: chartData.totalConsumption,
          title: 'Yearly Usage',
          extension: 'kWh',
        ),
        const SizedBox(height: 8),
        StatisticsCard(
          data: chartData.totalCost,
          title: 'Yearly Cost',
          extension: '€',
        ),
        const SizedBox(height: 8),
        YearlyGraph(chartData: chartData),
      ],
    );
  }

  Future<void> _selectYear(
    BuildContext context,
    StatisticsViewModel viewModel,
  ) async {
    final currentYear = viewModel.selectedYear;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Year'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(currentYear.toString()),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    viewModel.changeSelectedYear(currentYear - 1);
                  },
                  child: const Text('Previous Year'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    viewModel.changeSelectedYear(currentYear + 1);
                  },
                  child: const Text('Next Year'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
