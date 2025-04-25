import 'package:animations/animations.dart';
import 'package:eco_tracker/views/common/general_page.dart';
import 'package:eco_tracker/views/statistics/widgets/monthly_graph.dart';
import 'package:eco_tracker/views/statistics/widgets/weekly_graph.dart';
import 'package:eco_tracker/views/statistics/widgets/yearly_graph.dart';
import 'package:flutter/material.dart';

class StatisticsView extends StatefulWidget {
  const StatisticsView({super.key});

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return StatisticsPage(
      selectedIndex: _selectedIndex,
      onFilterChanged: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }
}

class StatisticsPage extends GeneralPage {
  final int selectedIndex;
  final void Function(int) onFilterChanged;

  const StatisticsPage({
    super.key,
    required this.selectedIndex,
    required this.onFilterChanged,
  }) : super(title: "Statistics", hasFAB: false);

  @override
  Widget buildBody(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FilterChip(
              label: const Text("Daily"),
              selected: selectedIndex == 0,
              showCheckmark: false,
              onSelected: (value) {
                if (value) {
                  onFilterChanged(0);
                }
              },
            ),
            FilterChip(
              label: const Text("Weekly"),
              selected: selectedIndex == 1,
              showCheckmark: false,
              onSelected: (value) {
                if (value) {
                  onFilterChanged(1);
                }
              },
            ),
            FilterChip(
              label: const Text("Monthly"),
              selected: selectedIndex == 2,
              showCheckmark: false,
              onSelected: (value) {
                if (value) {
                  onFilterChanged(2);
                }
              },
            ),
            FilterChip(
              label: const Text("Yearly"),
              selected: selectedIndex == 3,
              showCheckmark: false,
              onSelected: (value) {
                if (value) {
                  onFilterChanged(3);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: PageTransitionSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder:
                  (child, animation, secondaryAnimation) =>
                      SharedAxisTransition(
                        animation: animation,
                        secondaryAnimation: secondaryAnimation,
                        transitionType: SharedAxisTransitionType.horizontal,
                        child: child,
                      ),
              child: _getPageForIndex(selectedIndex),
            ),
          ),
        ),
      ],
    );
  }

  Widget _getPageForIndex(int index) {
    switch (index) {
      case 0:
        return _buildDailyPage();
      case 1:
        return _buildWeeklyPage();
      case 2:
        return _buildMonthlyPage();
      case 3:
        return _buildYearlyPage();
      default:
        return _buildDailyPage();
    }
  }

  Widget _buildDailyPage() {
    return Container(
      alignment: Alignment.center,
      key: ValueKey<int>(0),
      width: double.infinity,
      height: 350,
      child: Text('Coming soon'),
    );
  }

  Widget _buildWeeklyPage() {
    return SizedBox(
      key: ValueKey<int>(1),
      width: double.infinity,
      child: WeeklyGraph(),
    );
  }

  Widget _buildMonthlyPage() {
    return SizedBox(
      key: ValueKey<int>(2),
      width: double.infinity,
      child: MonthlyGraph(),
    );
  }

  Widget _buildYearlyPage() {
    return SizedBox(
      key: ValueKey<int>(3),
      width: double.infinity,
      child: YearlyGraph(),
    );
  }
}
