import 'package:eco_tracker/views/common/common_graph.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class YearlyGraph extends StatelessWidget {
  const YearlyGraph({super.key});

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
      FlSpot(8, 14.3),
      FlSpot(9, 11.9),
      FlSpot(10, 18.1),
      FlSpot(11, 15.8),
      FlSpot(12, 12.6),
    ];

    return CommonGraph(
      spots: spots,
      minX: 1,
      maxX: 12,
      interval: 2.5,
      getTitlesWidget: (value, meta) {
        final month = value.toInt();
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
    );
  }
}
