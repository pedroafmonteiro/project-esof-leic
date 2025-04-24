import 'package:eco_tracker/views/common/common_graph.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MonthlyGraph extends StatelessWidget {
  const MonthlyGraph({super.key});

  @override
  Widget build(BuildContext context) {
    const List<FlSpot> spots = [
      FlSpot(1, 11.2),
      FlSpot(2, 24.5),
      FlSpot(3, 26.3),
      FlSpot(4, 17.9),
      FlSpot(5, 21.8),
      FlSpot(6, 15.7),
      FlSpot(7, 19.2),
      FlSpot(8, 22.4),
      FlSpot(9, 14.6),
      FlSpot(10, 28.1),
      FlSpot(11, 19.5),
      FlSpot(12, 16.2),
      FlSpot(13, 23.7),
      FlSpot(14, 20.9),
      FlSpot(15, 18.3),
      FlSpot(16, 25.1),
      FlSpot(17, 12.8),
      FlSpot(18, 27.3),
      FlSpot(19, 13.7),
      FlSpot(20, 22.2),
      FlSpot(21, 18.4),
      FlSpot(22, 15.9),
      FlSpot(23, 29.2),
      FlSpot(24, 16.8),
      FlSpot(25, 24.1),
      FlSpot(26, 19.7),
      FlSpot(27, 14.4),
      FlSpot(28, 23.6),
      FlSpot(29, 17.3),
      FlSpot(30, 26.5),
      FlSpot(31, 21.4),
    ];

    return CommonGraph(
      spots: spots,
      minX: 1,
      maxX: 31,
      interval: 8,
      getTitlesWidget: (value, meta) {
        final day = value.toInt().toString();
        return SideTitleWidget(
          meta: meta,
          fitInside: SideTitleFitInsideData.fromTitleMeta(
            meta,
            distanceFromEdge: 0,
          ),
          child: Text(
            day,
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
