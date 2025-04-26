import 'package:eco_tracker/models/graph_data_model.dart';
import 'package:eco_tracker/viewmodels/statistics_view_model.dart';
import 'package:eco_tracker/views/common/common_graph.dart';
import 'package:eco_tracker/views/statistics/widgets/statistics_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MonthlyGraph extends StatelessWidget {
  const MonthlyGraph({super.key});

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
        viewModel.selectedMonthYear,);

    final spots = _createFlSpots(chartData);

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
        const SizedBox(height: 16),
        Expanded(
          child: CommonGraph(
            spots: spots,
            minX: 1,
            maxX: chartData.daysInMonth.toDouble(),
            interval: _calculateInterval(chartData.daysInMonth),
            getTitlesWidget: (value, meta) {
              final day = value.toInt();

              if (chartData.daysInMonth > 15) {
                if (day % 5 != 0 && day != 1 && day != chartData.daysInMonth) {
                  return const SizedBox.shrink();
                }
              }

              return SideTitleWidget(
                meta: meta,
                fitInside: SideTitleFitInsideData.fromTitleMeta(
                  meta,
                  distanceFromEdge: 0,
                ),
                child: Text(
                  day.toString(),
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

  List<FlSpot> _createFlSpots(MonthlyChartData data) {
    List<FlSpot> spots = [];
    for (int i = 0; i < data.points.length; i++) {
      spots.add(FlSpot(i + 1, data.points[i].value));
    }
    return spots;
  }

  double _calculateInterval(int daysInMonth) {
    if (daysInMonth <= 15) return 1;
    if (daysInMonth <= 20) return 2;
    return 5;
  }

  Future<void> _selectMonth(
      BuildContext context, StatisticsViewModel viewModel,) async {
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
