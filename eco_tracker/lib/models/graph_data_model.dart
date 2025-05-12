class ChartPoint {
  final String label;
  final double value;

  ChartPoint({required this.label, required this.value});
}

class WeeklyChartData {
  final List<ChartPoint> points;
  final double maxValue;
  final double totalConsumption;
  final double totalCost;

  WeeklyChartData({
    required this.points,
    required this.maxValue,
    required this.totalConsumption,
    required this.totalCost,
  });

  factory WeeklyChartData.fromWeeklySummary(
      Map<int, double> dailyData, double energyCost) {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    List<ChartPoint> points = [];
    double maxVal = 0;
    double total = 0;

    for (int i = 1; i <= 7; i++) {
      final value = dailyData[i] ?? 0.0;
      total += value;
      if (value > maxVal) maxVal = value;

      points.add(
        ChartPoint(
          label: dayNames[i - 1],
          value: value,
        ),
      );
    }

    return WeeklyChartData(
      points: points,
      maxValue: maxVal > 0 ? maxVal : 1.0,
      totalConsumption: total,
      totalCost: total * energyCost,
    );
  }
}

class MonthlyChartData {
  final List<ChartPoint> points;
  final double maxValue;
  final double totalConsumption;
  final double totalCost;
  final int daysInMonth;

  MonthlyChartData({
    required this.points,
    required this.maxValue,
    required this.totalConsumption,
    required this.totalCost,
    required this.daysInMonth,
  });

  factory MonthlyChartData.fromMonthlySummary(
    Map<int, double> dailyData,
    int month,
    int year,
    double energyCost,
  ) {
    final daysInMonth = DateTime(year, month + 1, 0).day;

    List<ChartPoint> points = [];
    double maxVal = 0;
    double total = 0;

    for (int i = 1; i <= daysInMonth; i++) {
      final value = dailyData[i] ?? 0.0;
      total += value;
      if (value > maxVal) maxVal = value;

      points.add(
        ChartPoint(
          label: i.toString(),
          value: value,
        ),
      );
    }

    return MonthlyChartData(
      points: points,
      maxValue: maxVal > 0 ? maxVal : 1.0,
      totalConsumption: total,
      totalCost: total * energyCost,
      daysInMonth: daysInMonth,
    );
  }
}

class YearlyChartData {
  final List<ChartPoint> points;
  final double maxValue;
  final double totalConsumption;
  final double totalCost;

  YearlyChartData({
    required this.points,
    required this.maxValue,
    required this.totalConsumption,
    required this.totalCost,
  });

  factory YearlyChartData.fromYearlySummary(
      Map<int, double> monthlyData, double energyCost) {
    final monthNames = [
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

    List<ChartPoint> points = [];
    double maxVal = 0;
    double total = 0;

    for (int i = 1; i <= 12; i++) {
      final value = monthlyData[i] ?? 0.0;
      total += value;
      if (value > maxVal) maxVal = value;

      points.add(
        ChartPoint(
          label: monthNames[i - 1],
          value: value,
        ),
      );
    }

    return YearlyChartData(
      points: points,
      maxValue: maxVal > 0 ? maxVal : 1.0,
      totalConsumption: total,
      totalCost: total * energyCost,
    );
  }
}
