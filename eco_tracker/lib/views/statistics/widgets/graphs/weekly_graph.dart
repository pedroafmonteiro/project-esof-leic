import 'package:eco_tracker/models/graph_data_model.dart';
import 'package:eco_tracker/views/common/common_graph.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WeeklyGraph extends StatelessWidget {
  const WeeklyGraph({super.key, required this.chartData});

  final WeeklyChartData chartData;

  @override
  Widget build(BuildContext context) {
    final spots = _createFlSpots(chartData);

    return CommonGraph(
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
    );
  }

  List<FlSpot> _createFlSpots(WeeklyChartData data) {
    List<FlSpot> spots = [];
    for (int i = 0; i < data.points.length; i++) {
      spots.add(FlSpot(i + 1, data.points[i].value));
    }
    return spots;
  }
}
