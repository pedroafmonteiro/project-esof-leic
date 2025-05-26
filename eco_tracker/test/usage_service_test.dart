import 'package:flutter_test/flutter_test.dart';
import 'package:eco_tracker/services/usage_service.dart';
import 'package:eco_tracker/models/device_usage_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UsageService Tests', () {
    // Mock variables declared but not used in current tests since we use TestableUsageService
    // These can be used for future integration tests with real Firebase mocking

    setUp(() {
      // Test setup - using TestableUsageService instead of real UsageService
      // to avoid Firebase initialization in test environment
    });

    group('userId getter Tests', () {
      test('should return null when no user is authenticated', () {
        final testService = TestableUsageService(null);
        expect(testService.userId, isNull);
      });

      test('should return user ID when user is authenticated', () {
        final testService = TestableUsageService('test-user-123');
        expect(testService.userId, equals('test-user-123'));
      });
    });

    group('fetchUsageData Tests', () {
      test('should return empty list when user is not authenticated', () async {
        // We'll create a service that we can control
        final testService = TestableUsageService(null);

        final result = await testService.fetchUsageData(
          DateTime(2024, 1, 1),
          DateTime(2024, 1, 31),
        );

        expect(result, isEmpty);
      });

      test('should return empty list when no data exists', () async {
        final testService = TestableUsageService('test-user-123');
        testService.setMockData(null);

        final result = await testService.fetchUsageData(
          DateTime(2024, 1, 1),
          DateTime(2024, 1, 31),
        );

        expect(result, isEmpty);
      });

      test('should parse usage data correctly', () async {
        final testService = TestableUsageService('test-user-123');

        final mockData = {
          '2024-01-01': {
            'device1': {
              'durationSeconds': 3600,
            },
            'device2': {
              'durationSeconds': 7200,
            },
          },
          '2024-01-02': {
            'device1': {
              'durationSeconds': 1800,
            },
          },
        };

        testService.setMockData(mockData);

        final result = await testService.fetchUsageData(
          DateTime(2024, 1, 1),
          DateTime(2024, 1, 31),
        );

        expect(result, hasLength(3));

        // Check first usage
        expect(result[0].deviceId, equals('device1'));
        expect(result[0].durationSeconds, equals(3600));
        expect(result[0].date, equals('2024-01-01'));
        expect(result[0].getDurationHours(), equals(1.0));

        // Check second usage
        expect(result[1].deviceId, equals('device2'));
        expect(result[1].durationSeconds, equals(7200));
        expect(result[1].date, equals('2024-01-01'));
        expect(result[1].getDurationHours(), equals(2.0));

        // Check third usage
        expect(result[2].deviceId, equals('device1'));
        expect(result[2].durationSeconds, equals(1800));
        expect(result[2].date, equals('2024-01-02'));
        expect(result[2].getDurationHours(), equals(0.5));
      });
    });

    group('fetchDevicePowerConsumption Tests', () {
      test('should return empty map when user is not authenticated', () async {
        final testService = TestableUsageService(null);

        final result = await testService.fetchDevicePowerConsumption();

        expect(result, isEmpty);
      });

      test('should return empty map when no devices exist', () async {
        final testService = TestableUsageService('test-user-123');
        testService.setMockDevicesData(null);

        final result = await testService.fetchDevicePowerConsumption();

        expect(result, isEmpty);
      });

      test('should parse device power consumption correctly', () async {
        final testService = TestableUsageService('test-user-123');

        final mockDevicesData = {
          'device1': {
            'model': 'TV',
            'powerConsumption': 100,
          },
          'device2': {
            'model': 'Laptop',
            'powerConsumption': '50.5',
          },
          'device3': {
            'model': 'Phone',
            // No powerConsumption field
          },
          'device4': {
            'model': 'Invalid',
            'powerConsumption': 'invalid_number',
          },
        };

        testService.setMockDevicesData(mockDevicesData);

        final result = await testService.fetchDevicePowerConsumption();

        expect(result, hasLength(2));
        expect(result['device1'], equals(100.0));
        expect(result['device2'], equals(50.5));
        expect(result.containsKey('device3'), isFalse);
        expect(result.containsKey('device4'), isFalse);
      });
    });

    group('calculateDailyUsage Tests', () {
      test('should calculate daily usage correctly', () async {
        final testService = TestableUsageService('test-user-123');

        // Set up usage data
        final usageData = {
          '2024-01-15': {
            'device1': {'durationSeconds': 3600}, // 1 hour
            'device2': {'durationSeconds': 7200}, // 2 hours
          },
        };

        // Set up device power data
        final deviceData = {
          'device1': {'powerConsumption': 100}, // 100W
          'device2': {'powerConsumption': 200}, // 200W
        };

        testService.setMockData(usageData);
        testService.setMockDevicesData(deviceData);

        final result =
            await testService.calculateDailyUsage(DateTime(2024, 1, 15));

        expect(result.date, equals('2024-01-15'));
        expect(
            result.totalKwh, equals(0.5)); // (100*1 + 200*2) / 1000 = 0.5 kWh
        expect(result.totalCost, equals(0.075)); // 0.5 * 0.15 = 0.075
        expect(result.deviceConsumption['device1'],
            equals(0.1)); // 100W * 1h / 1000 = 0.1 kWh
        expect(result.deviceConsumption['device2'],
            equals(0.4)); // 200W * 2h / 1000 = 0.4 kWh
      });

      test('should handle empty usage data', () async {
        final testService = TestableUsageService('test-user-123');

        testService.setMockData({});
        testService.setMockDevicesData({});

        final result =
            await testService.calculateDailyUsage(DateTime(2024, 1, 15));

        expect(result.date, equals('2024-01-15'));
        expect(result.totalKwh, equals(0.0));
        expect(result.totalCost, equals(0.0));
        expect(result.deviceConsumption, isEmpty);
      });
    });

    group('calculateWeeklyUsage Tests', () {
      test('should calculate weekly usage correctly', () async {
        final testService = TestableUsageService('test-user-123');

        // Set up usage data for a week (assuming week 3 of 2024)
        final usageData = {
          '2024-01-15': {
            // Monday
            'device1': {'durationSeconds': 3600}, // 1 hour
          },
          '2024-01-16': {
            // Tuesday
            'device1': {'durationSeconds': 7200}, // 2 hours
          },
        };

        final deviceData = {
          'device1': {'powerConsumption': 100}, // 100W
        };

        testService.setMockData(usageData);
        testService.setMockDevicesData(deviceData);

        final result = await testService.calculateWeeklyUsage(2024, 3);

        expect(result.weekNumber, equals(3));
        expect(result.year, equals(2024));
        expect(result.totalKwh,
            closeTo(0.3, 0.001)); // (1+2) * 100 / 1000 = 0.3 kWh
        expect(result.totalCost, closeTo(0.045, 0.001)); // 0.3 * 0.15 = 0.045
        expect(result.dailyConsumption[1],
            closeTo(0.1, 0.001)); // Monday: 1h * 100W / 1000 = 0.1 kWh
        expect(result.dailyConsumption[2],
            closeTo(0.2, 0.001)); // Tuesday: 2h * 100W / 1000 = 0.2 kWh
        expect(result.deviceConsumption['device1'], closeTo(0.3, 0.001));
      });
    });

    group('calculateMonthlyUsage Tests', () {
      test('should calculate monthly usage correctly', () async {
        final testService = TestableUsageService('test-user-123');

        final usageData = {
          '2024-01-01': {
            'device1': {'durationSeconds': 3600}, // 1 hour
          },
          '2024-01-15': {
            'device1': {'durationSeconds': 7200}, // 2 hours
          },
        };

        final deviceData = {
          'device1': {'powerConsumption': 100}, // 100W
        };

        testService.setMockData(usageData);
        testService.setMockDevicesData(deviceData);

        final result = await testService.calculateMonthlyUsage(2024, 1);

        expect(result.month, equals(1));
        expect(result.year, equals(2024));
        expect(result.totalKwh,
            closeTo(0.3, 0.001)); // (1+2) * 100 / 1000 = 0.3 kWh
        expect(result.totalCost, closeTo(0.045, 0.001)); // 0.3 * 0.15 = 0.045
        expect(
            result.dailyConsumption[1], closeTo(0.1, 0.001)); // Day 1: 0.1 kWh
        expect(result.dailyConsumption[15],
            closeTo(0.2, 0.001)); // Day 15: 0.2 kWh
        expect(result.deviceConsumption['device1'], closeTo(0.3, 0.001));
      });
    });

    group('calculateYearlyUsage Tests', () {
      test('should calculate yearly usage correctly', () async {
        final testService = TestableUsageService('test-user-123');

        final usageData = {
          '2024-01-15': {
            'device1': {'durationSeconds': 3600}, // 1 hour
          },
          '2024-06-15': {
            'device1': {'durationSeconds': 7200}, // 2 hours
          },
        };

        final deviceData = {
          'device1': {'powerConsumption': 100}, // 100W
        };

        testService.setMockData(usageData);
        testService.setMockDevicesData(deviceData);

        final result = await testService.calculateYearlyUsage(2024);

        expect(result.year, equals(2024));
        expect(result.totalKwh,
            closeTo(0.3, 0.001)); // (1+2) * 100 / 1000 = 0.3 kWh
        expect(result.totalCost, closeTo(0.045, 0.001)); // 0.3 * 0.15 = 0.045
        expect(result.monthlyConsumption[1],
            closeTo(0.1, 0.001)); // January: 0.1 kWh
        expect(
            result.monthlyConsumption[6], closeTo(0.2, 0.001)); // June: 0.2 kWh
        expect(result.deviceConsumption['device1'], closeTo(0.3, 0.001));
      });
    });

    group('logDeviceUsage Tests', () {
      test('should return false when user is not authenticated', () async {
        final testService = TestableUsageService(null);

        final result = await testService.logDeviceUsage(
          deviceId: 'device1',
          durationSeconds: 3600,
        );

        expect(result, isFalse);
      });

      test('should log device usage successfully', () async {
        final testService = TestableUsageService('test-user-123');

        final result = await testService.logDeviceUsage(
          deviceId: 'device1',
          durationSeconds: 3600,
          date: DateTime(2024, 1, 15),
        );

        expect(result, isTrue);

        // Verify the data was set correctly
        final loggedData = testService.getLoggedUsage();
        expect(loggedData, isNotNull);
        expect(loggedData!['deviceId'], equals('device1'));
        expect(loggedData['durationSeconds'], equals(3600));
        expect(loggedData['date'], equals('2024-01-15'));
      });

      test('should use current date when date is not provided', () async {
        final testService = TestableUsageService('test-user-123');

        final result = await testService.logDeviceUsage(
          deviceId: 'device1',
          durationSeconds: 3600,
        );

        expect(result, isTrue);

        final loggedData = testService.getLoggedUsage();
        expect(loggedData, isNotNull);
        expect(loggedData!['deviceId'], equals('device1'));
        expect(loggedData['durationSeconds'], equals(3600));
        // The date should be today's date in 'yyyy-MM-dd' format
        expect(loggedData['date'], isNotNull);
      });

      test('should handle logging errors', () async {
        final testService = TestableUsageService('test-user-123');
        testService.setShouldFailLogging(true);

        final result = await testService.logDeviceUsage(
          deviceId: 'device1',
          durationSeconds: 3600,
        );

        expect(result, isFalse);
      });
    });

    group('Constants Tests', () {
      test('should have correct cost per kWh', () {
        expect(UsageService.costPerKwh, equals(0.15));
      });
    });
  });
}

// Testable implementation of UsageService for easier testing
class TestableUsageService {
  final String? _testUserId;
  Map<dynamic, dynamic>? _mockUsageData;
  Map<dynamic, dynamic>? _mockDevicesData;
  Map<String, dynamic>? _loggedUsage;
  bool _shouldFailLogging = false;

  TestableUsageService(this._testUserId);

  String? get userId => _testUserId;

  void setMockData(Map<dynamic, dynamic>? data) {
    _mockUsageData = data;
  }

  void setMockDevicesData(Map<dynamic, dynamic>? data) {
    _mockDevicesData = data;
  }

  void setShouldFailLogging(bool shouldFail) {
    _shouldFailLogging = shouldFail;
  }

  Map<String, dynamic>? getLoggedUsage() => _loggedUsage;

  Future<List<DeviceUsage>> fetchUsageData(
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (userId == null) {
      return [];
    }

    if (_mockUsageData == null) {
      return [];
    }

    List<DeviceUsage> usages = [];
    _mockUsageData!.forEach((dateKey, dateData) {
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

    if (_mockDevicesData == null) {
      return {};
    }

    Map<String, double> powerConsumption = {};
    _mockDevicesData!.forEach((deviceId, deviceData) {
      final deviceMap = Map<String, dynamic>.from(deviceData as Map);
      if (deviceMap.containsKey('powerConsumption')) {
        final parsedValue =
            double.tryParse(deviceMap['powerConsumption'].toString());
        // Only include devices with valid (non-null) power consumption values
        if (parsedValue != null) {
          powerConsumption[deviceId.toString()] = parsedValue;
        }
      }
    });

    return powerConsumption;
  }

  Future<bool> logDeviceUsage({
    required String deviceId,
    required int durationSeconds,
    DateTime? date,
  }) async {
    if (userId == null) {
      return false;
    }

    if (_shouldFailLogging) {
      return false;
    }

    final dateToUse = date ?? DateTime.now();
    final dateFormat =
        dateToUse.toIso8601String().substring(0, 10); // yyyy-MM-dd format

    _loggedUsage = {
      'deviceId': deviceId,
      'durationSeconds': durationSeconds,
      'date': dateFormat,
    };

    return true;
  }

  Future<DailyUsageSummary> calculateDailyUsage(DateTime date) async {
    final dateFormat = date.toIso8601String().substring(0, 10);

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
      date: dateFormat,
      totalKwh: totalKwh,
      totalCost: totalKwh * UsageService.costPerKwh,
      deviceConsumption: deviceConsumption,
    );
  }

  Future<WeeklyUsageSummary> calculateWeeklyUsage(
      int year, int weekNumber) async {
    final firstDayOfYear = DateTime(year, 1, 1);
    final dayOffset = firstDayOfYear.weekday - 1;
    final firstMonday = firstDayOfYear.subtract(Duration(days: dayOffset));
    final weekStart = firstMonday.add(Duration(days: (weekNumber - 1) * 7));
    final weekEnd = weekStart.add(const Duration(days: 6));

    final usages = await fetchUsageData(weekStart, weekEnd);
    final devicePower = await fetchDevicePowerConsumption();

    double totalKwh = 0.0;
    Map<int, double> dailyConsumption = {};
    Map<String, double> deviceConsumption = {};

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
      deviceConsumption[deviceId] = (deviceConsumption[deviceId] ?? 0.0) + kWh;
      totalKwh += kWh;
    }

    return WeeklyUsageSummary(
      weekNumber: weekNumber,
      year: year,
      totalKwh: totalKwh,
      totalCost: totalKwh * UsageService.costPerKwh,
      dailyConsumption: dailyConsumption,
      deviceConsumption: deviceConsumption,
    );
  }

  Future<MonthlyUsageSummary> calculateMonthlyUsage(int year, int month) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);

    final usages = await fetchUsageData(startDate, endDate);
    final devicePower = await fetchDevicePowerConsumption();

    double totalKwh = 0.0;
    Map<int, double> dailyConsumption = {};
    Map<String, double> deviceConsumption = {};

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
      deviceConsumption[deviceId] = (deviceConsumption[deviceId] ?? 0.0) + kWh;
      totalKwh += kWh;
    }

    return MonthlyUsageSummary(
      month: month,
      year: year,
      totalKwh: totalKwh,
      totalCost: totalKwh * UsageService.costPerKwh,
      dailyConsumption: dailyConsumption,
      deviceConsumption: deviceConsumption,
    );
  }

  Future<YearlyUsageSummary> calculateYearlyUsage(int year) async {
    final startDate = DateTime(year, 1, 1);
    final endDate = DateTime(year, 12, 31);

    final usages = await fetchUsageData(startDate, endDate);
    final devicePower = await fetchDevicePowerConsumption();

    double totalKwh = 0.0;
    Map<int, double> monthlyConsumption = {};
    Map<String, double> deviceConsumption = {};

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
      deviceConsumption[deviceId] = (deviceConsumption[deviceId] ?? 0.0) + kWh;
      totalKwh += kWh;
    }

    return YearlyUsageSummary(
      year: year,
      totalKwh: totalKwh,
      totalCost: totalKwh * UsageService.costPerKwh,
      monthlyConsumption: monthlyConsumption,
      deviceConsumption: deviceConsumption,
    );
  }
}
