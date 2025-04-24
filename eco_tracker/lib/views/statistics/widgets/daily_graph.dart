import 'package:eco_tracker/views/common/common_graph.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DailyGraph extends StatelessWidget {
  const DailyGraph({super.key});

  @override
  Widget build(BuildContext context) {
    const List<FlSpot> spots = [
      FlSpot(0, 1.2),
      FlSpot(3, 0.8),
      FlSpot(6, 2.5),
      FlSpot(9, 4.7),
      FlSpot(12, 6.2),
      FlSpot(15, 5.3),
      FlSpot(18, 7.1),
      FlSpot(19, 15.4),
      FlSpot(21, 3.8),
      FlSpot(24, 2.1),
    ];

    return CommonGraph(
      spots: spots,
      minX: 0,
      maxX: 24,
      interval: 6,
      getTitlesWidget: (value, meta) {
        final hour = value.toInt();
        if (hour >= 0 && hour <= 24) {
          return SideTitleWidget(
            meta: meta,
            fitInside: SideTitleFitInsideData.fromTitleMeta(
              meta,
              distanceFromEdge: 0,
            ),
            child: Text(
              '${hour}h',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 12,
              ),
            ),
          );
        }
        return const Text('');
      },
    );
  }
}
