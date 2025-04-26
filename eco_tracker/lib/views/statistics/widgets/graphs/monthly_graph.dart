import 'package:eco_tracker/models/graph_data_model.dart';
import 'package:eco_tracker/views/common/common_graph.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MonthlyGraph extends StatelessWidget {
  const MonthlyGraph({super.key, required this.chartData});

  final MonthlyChartData chartData;

  @override
  Widget build(BuildContext context) {
    final spots = _createFlSpots(chartData);

    return CommonGraph(
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
}
