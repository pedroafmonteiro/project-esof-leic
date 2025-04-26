import 'package:eco_tracker/models/graph_data_model.dart';
import 'package:eco_tracker/viewmodels/statistics_view_model.dart';
import 'package:eco_tracker/views/common/common_graph.dart';
import 'package:eco_tracker/views/statistics/widgets/statistics_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WeeklyGraph extends StatelessWidget {
  const WeeklyGraph({super.key});

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
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
        ),
      );
    }

    if (weeklyUsage == null) {
      return const Center(child: Text('No data available for this week.'));
    }

    final chartData =
        WeeklyChartData.fromWeeklySummary(weeklyUsage.dailyConsumption);
    final spots = _createFlSpots(chartData);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Week ${viewModel.selectedWeekNumber}, ${viewModel.selectedWeekYear}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: () => _selectWeek(context, viewModel),
              ),
            ],
          ),
        ),
        StatisticsCard(
          data: chartData.totalConsumption,
          title: 'Weekly Usage',
          extension: 'kWh',
        ),
        const SizedBox(height: 8),
        StatisticsCard(
          data: chartData.totalCost,
          title: 'Weekly Cost',
          extension: '€',
        ),
        const SizedBox(height: 16),
        Expanded(
          child: CommonGraph(
            spots: spots,
            minX: 1,
            maxX: 7,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final day = value.toInt();
              if (day < 1 || day > 7) return const SizedBox.shrink();

              final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
              String label = days[day - 1];

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

  List<FlSpot> _createFlSpots(WeeklyChartData data) {
    List<FlSpot> spots = [];
    for (int i = 0; i < data.points.length; i++) {
      spots.add(FlSpot(i + 1, data.points[i].value));
    }
    return spots;
  }

  Future<void> _selectWeek(
      BuildContext context, StatisticsViewModel viewModel,) async {

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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();

                    int newWeek = currentWeek - 1;
                    int newYear = currentYear;

                    if (newWeek < 1) {
                      newWeek = 52;
                      newYear--;
                    }

                    viewModel.changeSelectedWeek(newWeek, newYear);
                  },
                  child: const Text('Previous Week'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();

                    int newWeek = currentWeek + 1;
                    int newYear = currentYear;

                    if (newWeek > 52) {
                      newWeek = 1;
                      newYear++;
                    }

                    viewModel.changeSelectedWeek(newWeek, newYear);
                  },
                  child: const Text('Next Week'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
