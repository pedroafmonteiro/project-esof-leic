import 'package:eco_tracker/models/graph_data_model.dart';
import 'package:eco_tracker/viewmodels/statistics_view_model.dart';
import 'package:eco_tracker/views/common/common_graph.dart';
import 'package:eco_tracker/views/statistics/widgets/statistics_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class YearlyGraph extends StatelessWidget {
  const YearlyGraph({super.key});

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
    final spots = _createFlSpots(chartData);

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
        const SizedBox(height: 16),
        Expanded(
          child: CommonGraph(
            spots: spots,
            minX: 1,
            maxX: 12,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final month = value.toInt();
              if (month < 1 || month > 12) return const SizedBox.shrink();

              final months = [
                'Jan',
                'Feb',
                'Mar',
                'Apr',
                'May',
                'Jun',
                'Jul',
                'Aug',
                'Sep',
                'Oct',
                'Nov',
                'Dec',
              ];
              String label = months[month - 1];

              return SideTitleWidget(
                meta: meta,
                fitInside: SideTitleFitInsideData.fromTitleMeta(
                  meta,
                  distanceFromEdge: 0,
                ),
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 12,
                      ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<FlSpot> _createFlSpots(YearlyChartData data) {
    List<FlSpot> spots = [];
    for (int i = 0; i < data.points.length; i++) {
      spots.add(FlSpot(i + 1, data.points[i].value));
    }
    return spots;
  }

  Future<void> _selectYear(
      BuildContext context, StatisticsViewModel viewModel,) async {
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
