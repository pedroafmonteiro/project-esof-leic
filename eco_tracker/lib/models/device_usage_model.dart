class DeviceUsage {
  final String deviceId;
  final int durationSeconds;
  final String date;

  DeviceUsage({
    required this.deviceId,
    required this.durationSeconds,
    required this.date,
  });

  factory DeviceUsage.fromMap(
    Map<String, dynamic> map,
    String deviceId,
    String date,
  ) {
    return DeviceUsage(
      deviceId: deviceId,
      durationSeconds: map['durationSeconds'] as int,
      date: date,
    );
  }

  double getDurationHours() {
    return durationSeconds / 3600;
  }
}

class DailyUsageSummary {
  final String date;
  final double totalKwh;
  final double totalCost;
  final Map<String, double> deviceConsumption;

  DailyUsageSummary({
    required this.date,
    required this.totalKwh,
    required this.totalCost,
    required this.deviceConsumption,
  });
}

class WeeklyUsageSummary {
  final int weekNumber;
  final int year;
  final double totalKwh;
  final double totalCost;
  final Map<int, double> dailyConsumption;
  final Map<String, double> deviceConsumption;

  WeeklyUsageSummary({
    required this.weekNumber,
    required this.year,
    required this.totalKwh,
    required this.totalCost,
    required this.dailyConsumption,
    required this.deviceConsumption,
  });
}

class MonthlyUsageSummary {
  final int month;
  final int year;
  final double totalKwh;
  final double totalCost;
  final Map<int, double> dailyConsumption;
  final Map<String, double> deviceConsumption;

  MonthlyUsageSummary({
    required this.month,
    required this.year,
    required this.totalKwh,
    required this.totalCost,
    required this.dailyConsumption,
    required this.deviceConsumption,
  });
}

class YearlyUsageSummary {
  final int year;
  final double totalKwh;
  final double totalCost;
  final Map<int, double> monthlyConsumption;
  final Map<String, double> deviceConsumption;

  YearlyUsageSummary({
    required this.year,
    required this.totalKwh,
    required this.totalCost,
    required this.monthlyConsumption,
    required this.deviceConsumption,
  });
}
