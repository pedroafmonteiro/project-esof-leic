import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CommonGraph extends StatelessWidget {
  final List<FlSpot> spots;
  final double minX;
  final double maxX;
  final Widget Function(double, TitleMeta) getTitlesWidget;
  final double interval;
  final String tooltipSuffix;

  const CommonGraph({
    super.key,
    required this.spots,
    required this.minX,
    required this.maxX,
    required this.getTitlesWidget,
    required this.interval,
    this.tooltipSuffix = 'kWh',
  });

  @override
  Widget build(BuildContext context) {
    double maxY = 10.0;
    if (spots.isNotEmpty) {
      double highestY =
          spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
      maxY = highestY * 1.1;
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      height: 350,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: getTitlesWidget,
                  interval: interval,
                ),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                tooltipRoundedRadius: 8,
                getTooltipColor: (touchedSpot) {
                  return Theme.of(context).colorScheme.primaryContainer;
                },
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((touchedSpot) {
                    final y = touchedSpot.y;
                    return LineTooltipItem(
                      '$y $tooltipSuffix',
                      Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                                fontSize: 12,
                              ) ??
                          const TextStyle(),
                    );
                  }).toList();
                },
              ),
            ),
            minX: minX,
            maxX: maxX,
            minY: 0,
            maxY: maxY,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: Theme.of(context).colorScheme.primary,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: Theme.of(context).colorScheme.primary.withAlpha(50),
                ),
              ),
            ],
          ),
          curve: Curves.linear,
          duration: const Duration(milliseconds: 150),
        ),
      ),
    );
  }
}
