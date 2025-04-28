import 'package:eco_tracker/models/graph_data_model.dart';
import 'package:eco_tracker/views/common/common_graph.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class YearlyGraph extends StatelessWidget {
  const YearlyGraph({super.key, required this.chartData});

  final YearlyChartData chartData;

  @override
  Widget build(BuildContext context) {
    final spots = _createFlSpots(chartData);

    return CommonGraph(
      spots: spots,
      minX: 1,
      maxX: 12,
      interval: 3,
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
    );
  }

  List<FlSpot> _createFlSpots(YearlyChartData data) {
    List<FlSpot> spots = [];
    for (int i = 0; i < data.points.length; i++) {
      spots.add(FlSpot(i + 1, data.points[i].value));
    }
    return spots;
  }
}
