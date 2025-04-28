import 'package:eco_tracker/models/device_usage_model.dart';
import 'package:eco_tracker/services/usage_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatisticsViewModel extends ChangeNotifier {
  final UsageService _usageService = UsageService();

  DailyUsageSummary? _dailyUsage;
  bool _isLoadingDaily = false;
  String? _dailyError;

  WeeklyUsageSummary? _weeklyUsage;
  bool _isLoadingWeekly = false;
  String? _weeklyError;

  MonthlyUsageSummary? _monthlyUsage;
  bool _isLoadingMonthly = false;
  String? _monthlyError;

  YearlyUsageSummary? _yearlyUsage;
  bool _isLoadingYearly = false;
  String? _yearlyError;

  DailyUsageSummary? get dailyUsage => _dailyUsage;
  bool get isLoadingDaily => _isLoadingDaily;
  String? get dailyError => _dailyError;

  WeeklyUsageSummary? get weeklyUsage => _weeklyUsage;
  bool get isLoadingWeekly => _isLoadingWeekly;
  String? get weeklyError => _weeklyError;

  MonthlyUsageSummary? get monthlyUsage => _monthlyUsage;
  bool get isLoadingMonthly => _isLoadingMonthly;
  String? get monthlyError => _monthlyError;

  YearlyUsageSummary? get yearlyUsage => _yearlyUsage;
  bool get isLoadingYearly => _isLoadingYearly;
  String? get yearlyError => _yearlyError;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  int _selectedWeekNumber = 0;
  int _selectedWeekYear = DateTime.now().year;

  int get selectedWeekNumber => _selectedWeekNumber;
  int get selectedWeekYear => _selectedWeekYear;

  int _selectedMonth = DateTime.now().month;
  int _selectedMonthYear = DateTime.now().year;

  int get selectedMonth => _selectedMonth;
  int get selectedMonthYear => _selectedMonthYear;

  int _selectedYear = DateTime.now().year;
  int get selectedYear => _selectedYear;

  StatisticsViewModel() {
    initializeData();
  }

  void initializeData() {
    loadDailyUsage();
    calculateSelectedWeek();
    loadWeeklyUsage();
    loadMonthlyUsage();
    loadYearlyUsage();
  }

  void calculateSelectedWeek() {
    int dayOfWeek = _selectedDate.weekday;

    DateTime firstDayOfWeek =
        _selectedDate.subtract(Duration(days: dayOfWeek - 1));

    if (firstDayOfWeek.year < _selectedDate.year) {
      DateTime jan4 = DateTime(_selectedDate.year, 1, 4);
      int jan4WeekDay = jan4.weekday;
      DateTime firstWeekStart = jan4.subtract(Duration(days: jan4WeekDay - 1));

      _selectedWeekNumber =
          1 + firstDayOfWeek.difference(firstWeekStart).inDays ~/ 7;
      _selectedWeekYear = _selectedDate.year;
    } else {
      DateTime jan4 = DateTime(firstDayOfWeek.year, 1, 4);
      int jan4WeekDay = jan4.weekday;
      DateTime firstWeekStart = jan4.subtract(Duration(days: jan4WeekDay - 1));

      _selectedWeekNumber =
          1 + firstDayOfWeek.difference(firstWeekStart).inDays ~/ 7;
      _selectedWeekYear = firstDayOfWeek.year;
    }

    if (_selectedWeekNumber < 1) {
      _selectedWeekNumber = 52 + _selectedWeekNumber;
      _selectedWeekYear--;
    } else if (_selectedWeekNumber > 52) {
      _selectedWeekNumber = 1;
      _selectedWeekYear++;
    }
  }

  Future<void> loadDailyUsage() async {
    _isLoadingDaily = true;
    _dailyError = null;
    notifyListeners();

    try {
      _dailyUsage = await _usageService.calculateDailyUsage(_selectedDate);
    } catch (e) {
      _dailyError = 'Failed to load daily usage: $e';
    } finally {
      _isLoadingDaily = false;
      notifyListeners();
    }
  }

  Future<void> loadWeeklyUsage() async {
    _isLoadingWeekly = true;
    _weeklyError = null;
    notifyListeners();

    try {
      _weeklyUsage = await _usageService.calculateWeeklyUsage(
        _selectedWeekYear,
        _selectedWeekNumber,
      );
    } catch (e) {
      _weeklyError = 'Failed to load weekly usage: $e';
    } finally {
      _isLoadingWeekly = false;
      notifyListeners();
    }
  }

  Future<void> loadMonthlyUsage() async {
    _isLoadingMonthly = true;
    _monthlyError = null;
    notifyListeners();

    try {
      _monthlyUsage = await _usageService.calculateMonthlyUsage(
        _selectedMonthYear,
        _selectedMonth,
      );
    } catch (e) {
      _monthlyError = 'Failed to load monthly usage: $e';
    } finally {
      _isLoadingMonthly = false;
      notifyListeners();
    }
  }

  Future<void> loadYearlyUsage() async {
    _isLoadingYearly = true;
    _yearlyError = null;
    notifyListeners();

    try {
      _yearlyUsage = await _usageService.calculateYearlyUsage(_selectedYear);
    } catch (e) {
      _yearlyError = 'Failed to load yearly usage: $e';
    } finally {
      _isLoadingYearly = false;
      notifyListeners();
    }
  }

  void changeSelectedDate(DateTime date) {
    _selectedDate = date;
    loadDailyUsage();

    calculateSelectedWeek();

    if (_selectedMonth != date.month || _selectedMonthYear != date.year) {
      _selectedMonth = date.month;
      _selectedMonthYear = date.year;
      loadMonthlyUsage();
    }

    if (_selectedYear != date.year) {
      _selectedYear = date.year;
      loadYearlyUsage();
    }

    loadWeeklyUsage();
  }

  void changeSelectedWeek(int weekNumber, int year) {
    _selectedWeekNumber = weekNumber;
    _selectedWeekYear = year;
    loadWeeklyUsage();
  }

  void changeSelectedMonth(int month, int year) {
    _selectedMonth = month;
    _selectedMonthYear = year;
    loadMonthlyUsage();
  }

  void changeSelectedYear(int year) {
    _selectedYear = year;
    loadYearlyUsage();
  }

  String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}
