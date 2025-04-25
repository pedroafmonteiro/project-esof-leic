import 'package:animations/animations.dart';
import 'package:eco_tracker/views/common/general_page.dart';
import 'package:eco_tracker/views/statistics/widgets/graphs/monthly_graph.dart';
import 'package:eco_tracker/views/statistics/widgets/graphs/weekly_graph.dart';
import 'package:eco_tracker/views/statistics/widgets/graphs/yearly_graph.dart';
import 'package:eco_tracker/views/statistics/widgets/statistics_card.dart';
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
          child: PageTransitionSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder:
                (child, animation, secondaryAnimation) => SharedAxisTransition(
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
        return _buildDailyPage(context);
      case 1:
        return _buildWeeklyPage();
      case 2:
        return _buildMonthlyPage();
      case 3:
        return _buildYearlyPage();
      default:
        return _buildDailyPage(context);
    }
  }

  Widget _buildDailyPage(BuildContext context) {
    const double dailyUsage = 24.7;
    const double costPerKwh = 0.15;
    /* final List<Map<String, dynamic>> topDevices = [
      {'name': 'Air Conditioner', 'consumption': 8.5, 'icon': Icons.ac_unit},
      {
        'name': 'Washing Machine',
        'consumption': 5.2,
        'icon': Icons.local_laundry_service,
      },
      {'name': 'Refrigerator', 'consumption': 4.8, 'icon': Icons.kitchen},
      {'name': 'TV', 'consumption': 3.1, 'icon': Icons.tv},
      {'name': 'Computer', 'consumption': 2.6, 'icon': Icons.computer},
      {'name': 'Lights', 'consumption': 0.5, 'icon': Icons.lightbulb_outline},
    ]; */

    return Column(
      key: const ValueKey<int>(0),
      children: [
        StatisticsCard(
          data: dailyUsage,
          title: 'Estimated Usage',
          extension: 'kWh',
        ),

        SizedBox(height: 8.0),

        StatisticsCard(
          data: dailyUsage * costPerKwh,
          title: 'Estimated Cost',
          extension: '€',
        ),

        /* Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Top Energy Consumers',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: topDevices.length,
            itemBuilder: (context, index) {
              final device = topDevices[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: ListTile(
                  leading: Icon(
                    device['icon'],
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(device['name']),
                  subtitle: Text('${device['consumption']} kWh'),
                  trailing: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '#${index + 1}',
                        style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ), */
      ],
    );
  }

  Widget _buildWeeklyPage() {
    return Column(key: ValueKey<int>(1), children: [WeeklyGraph()]);
  }

  Widget _buildMonthlyPage() {
    return Column(key: ValueKey<int>(2), children: [MonthlyGraph()]);
  }

  Widget _buildYearlyPage() {
    return Column(key: ValueKey<int>(3), children: [YearlyGraph()]);
  }
}
