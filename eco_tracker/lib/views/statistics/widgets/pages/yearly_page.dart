import 'package:eco_tracker/models/graph_data_model.dart';
import 'package:eco_tracker/viewmodels/statistics_view_model.dart';
import 'package:eco_tracker/views/statistics/widgets/graphs/yearly_graph.dart';
import 'package:eco_tracker/views/statistics/widgets/statistics_card.dart';
import 'package:eco_tracker/views/statistics/widgets/top_consumers.dart';
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
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    if (yearlyUsage == null) {
      return const Center(child: Text('No data available for this year.'));
    }

    final chartData =
        YearlyChartData.fromYearlySummary(yearlyUsage.monthlyConsumption);

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
                  onPressed: () => _selectYear(context, viewModel),
                  child: Text(
                    'Year ${viewModel.selectedYear}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ),
              StatisticsCard(
                data: chartData.totalConsumption,
                title: 'Yearly Usage',
                extension: 'kWh',
              ),
              StatisticsCard(
                data: chartData.totalCost,
                title: 'Yearly Cost',
                extension: '€',
              ),
              if (yearlyUsage.deviceConsumption.isNotEmpty) ...[
                YearlyGraph(chartData: chartData),
                TopConsumers(
                  deviceConsumption: yearlyUsage.deviceConsumption,
                ),
              ],
              if (yearlyUsage.deviceConsumption.isEmpty)
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: const Center(
                    child: Text(
                      'No device usage data recorded for this year.',
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    viewModel.changeSelectedYear(currentYear - 1);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Previous'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    viewModel.changeSelectedYear(currentYear + 1);
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
