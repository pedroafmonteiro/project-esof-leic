import 'package:eco_tracker/views/common/common_graph.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WeeklyGraph extends StatelessWidget {
  const WeeklyGraph({super.key});

  @override
  Widget build(BuildContext context) {
    const List<FlSpot> spots = [
      FlSpot(1, 11.2),
      FlSpot(2, 10.8),
      FlSpot(3, 12.5),
      FlSpot(4, 14.7),
      FlSpot(5, 16.2),
      FlSpot(6, 15.3),
      FlSpot(7, 17.1),
    ];

    return CommonGraph(
      spots: spots,
      minX: 1,
      maxX: 7,
      interval: 1,
      getTitlesWidget: (value, meta) {
        final day = value.toInt();
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
}
