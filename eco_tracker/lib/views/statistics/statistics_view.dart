import 'package:animations/animations.dart';
import 'package:eco_tracker/viewmodels/statistics_view_model.dart';
import 'package:eco_tracker/views/common/general_page.dart';
import 'package:eco_tracker/views/statistics/widgets/pages/daily_page.dart';
import 'package:eco_tracker/views/statistics/widgets/pages/monthly_page.dart';
import 'package:eco_tracker/views/statistics/widgets/pages/weekly_page.dart';
import 'package:eco_tracker/views/statistics/widgets/pages/yearly_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatisticsView extends StatefulWidget {
  static StatisticsViewState? _currentState;

  static void navigateToTab(int index) {
    _currentState?.setSelectedIndex(index);
  }

  const StatisticsView({super.key});

  @override
  State<StatisticsView> createState() => StatisticsViewState();
}

class StatisticsViewState extends State<StatisticsView> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    StatisticsView._currentState = this;
  }

  @override
  void dispose() {
    if (StatisticsView._currentState == this) {
      StatisticsView._currentState = null;
    }
    super.dispose();
  }

  void setSelectedIndex(int index) {
    if (index >= 0 && index <= 3) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

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
  Future<void> onRefresh(BuildContext context) async {
    return Provider.of<StatisticsViewModel>(context, listen: false)
        .initializeData();
  }

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
        Expanded(
          child: PageTransitionSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation, secondaryAnimation) =>
                SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              child: child,
            ),
            child: _getPageForIndex(selectedIndex, context),
          ),
        ),
      ],
    );
  }

  Widget _getPageForIndex(int index, BuildContext context) {
    switch (index) {
      case 0:
        return DailyView(
          key: const ValueKey<int>(0),
        );
      case 1:
        return WeeklyView(
          key: const ValueKey<int>(1),
        );
      case 2:
        return MonthlyView(
          key: const ValueKey<int>(2),
        );
      case 3:
        return YearlyView(
          key: const ValueKey<int>(3),
        );
      default:
        return DailyView(
          key: const ValueKey<int>(0),
        );
    }
  }
}
