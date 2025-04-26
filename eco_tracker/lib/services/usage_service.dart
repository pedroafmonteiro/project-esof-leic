import 'package:eco_tracker/models/device_usage_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class UsageService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const double costPerKwh = 0.15;

  String? get userId => _auth.currentUser?.uid;

  Future<List<DeviceUsage>> fetchUsageData(
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (userId == null) {
      return [];
    }

    final dateFormat = DateFormat('yyyy-MM-dd');
    final start = dateFormat.format(startDate);
    final end = dateFormat.format(endDate);

    final usagePath = '/$userId/usage';
    final usageRef = _database.ref(usagePath);

    final usageQuery = usageRef.orderByKey().startAt(start).endAt(end);
    final snapshot = await usageQuery.get();

    if (!snapshot.exists) {
      return [];
    }

    List<DeviceUsage> usages = [];

    final usageData = snapshot.value as Map<dynamic, dynamic>;
    usageData.forEach((dateKey, dateData) {
      final date = dateKey.toString();
      final deviceUsages = dateData as Map<dynamic, dynamic>;

      deviceUsages.forEach((deviceId, deviceData) {
        final usageMap = Map<String, dynamic>.from(deviceData as Map);
        usages.add(DeviceUsage.fromMap(usageMap, deviceId.toString(), date));
      });
    });

    return usages;
  }

  Future<Map<String, double>> fetchDevicePowerConsumption() async {
    if (userId == null) {
      return {};
    }

    final devicesPath = '/$userId/devices';
    final devicesRef = _database.ref(devicesPath);

    final snapshot = await devicesRef.get();

    if (!snapshot.exists) {
      return {};
    }

    Map<String, double> powerConsumption = {};

    final devicesData = snapshot.value as Map<dynamic, dynamic>;
    devicesData.forEach((deviceId, deviceData) {
      final deviceMap = Map<String, dynamic>.from(deviceData as Map);
      if (deviceMap.containsKey('powerConsumption')) {
        powerConsumption[deviceId.toString()] =
            double.tryParse(deviceMap['powerConsumption'].toString()) ?? 0.0;
      }
    });

    return powerConsumption;
  }

  Future<DailyUsageSummary> calculateDailyUsage(DateTime date) async {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final dateString = dateFormat.format(date);

    final usages = await fetchUsageData(date, date);
    final devicePower = await fetchDevicePowerConsumption();

    double totalKwh = 0.0;
    Map<String, double> deviceConsumption = {};

    for (var usage in usages) {
      final deviceId = usage.deviceId;
      final powerRating = devicePower[deviceId] ?? 0.0;
      final hours = usage.getDurationHours();
      final kWh = powerRating * hours / 1000;

      deviceConsumption[deviceId] = (deviceConsumption[deviceId] ?? 0.0) + kWh;
      totalKwh += kWh;
    }

    return DailyUsageSummary(
      date: dateString,
      totalKwh: totalKwh,
      totalCost: totalKwh * costPerKwh,
      deviceConsumption: deviceConsumption,
    );
  }

  Future<WeeklyUsageSummary> calculateWeeklyUsage(
    int year,
    int weekNumber,
  ) async {
    final firstDayOfYear = DateTime(year, 1, 1);
    final dayOffset = firstDayOfYear.weekday - 1;
    final firstMonday = firstDayOfYear.subtract(Duration(days: dayOffset));
    final weekStart = firstMonday.add(Duration(days: (weekNumber - 1) * 7));
    final weekEnd = weekStart.add(const Duration(days: 6));

    final usages = await fetchUsageData(weekStart, weekEnd);
    final devicePower = await fetchDevicePowerConsumption();

    double totalKwh = 0.0;
    Map<int, double> dailyConsumption = {};

    for (int i = 1; i <= 7; i++) {
      dailyConsumption[i] = 0.0;
    }

    for (var usage in usages) {
      final deviceId = usage.deviceId;
      final powerRating = devicePower[deviceId] ?? 0.0;
      final hours = usage.getDurationHours();
      final kWh = powerRating * hours / 1000;

      final usageDate = DateTime.parse(usage.date);
      final dayOfWeek = usageDate.weekday;

      dailyConsumption[dayOfWeek] = (dailyConsumption[dayOfWeek] ?? 0.0) + kWh;
      totalKwh += kWh;
    }

    return WeeklyUsageSummary(
      weekNumber: weekNumber,
      year: year,
      totalKwh: totalKwh,
      totalCost: totalKwh * costPerKwh,
      dailyConsumption: dailyConsumption,
    );
  }

  Future<MonthlyUsageSummary> calculateMonthlyUsage(int year, int month) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);

    final usages = await fetchUsageData(startDate, endDate);
    final devicePower = await fetchDevicePowerConsumption();

    double totalKwh = 0.0;
    Map<int, double> dailyConsumption = {};

    for (int i = 1; i <= endDate.day; i++) {
      dailyConsumption[i] = 0.0;
    }

    for (var usage in usages) {
      final deviceId = usage.deviceId;
      final powerRating = devicePower[deviceId] ?? 0.0;
      final hours = usage.getDurationHours();
      final kWh = powerRating * hours / 1000;

      final usageDate = DateTime.parse(usage.date);
      final dayOfMonth = usageDate.day;

      dailyConsumption[dayOfMonth] =
          (dailyConsumption[dayOfMonth] ?? 0.0) + kWh;
      totalKwh += kWh;
    }

    return MonthlyUsageSummary(
      month: month,
      year: year,
      totalKwh: totalKwh,
      totalCost: totalKwh * costPerKwh,
      dailyConsumption: dailyConsumption,
    );
  }

  Future<YearlyUsageSummary> calculateYearlyUsage(int year) async {
    final startDate = DateTime(year, 1, 1);
    final endDate = DateTime(year, 12, 31);

    final usages = await fetchUsageData(startDate, endDate);
    final devicePower = await fetchDevicePowerConsumption();

    double totalKwh = 0.0;
    Map<int, double> monthlyConsumption = {};

    for (int i = 1; i <= 12; i++) {
      monthlyConsumption[i] = 0.0;
    }

    for (var usage in usages) {
      final deviceId = usage.deviceId;
      final powerRating = devicePower[deviceId] ?? 0.0;
      final hours = usage.getDurationHours();
      final kWh = powerRating * hours / 1000;

      final usageDate = DateTime.parse(usage.date);
      final month = usageDate.month;

      monthlyConsumption[month] = (monthlyConsumption[month] ?? 0.0) + kWh;
      totalKwh += kWh;
    }

    return YearlyUsageSummary(
      year: year,
      totalKwh: totalKwh,
      totalCost: totalKwh * costPerKwh,
      monthlyConsumption: monthlyConsumption,
    );
  }
}
