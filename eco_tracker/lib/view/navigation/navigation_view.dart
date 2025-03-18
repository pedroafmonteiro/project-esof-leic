import 'package:eco_tracker/view/devices/devices_view.dart';
import 'package:eco_tracker/view/home/home_view.dart';
import 'package:eco_tracker/view/statistics/statistics_view.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

class NavigationView extends StatefulWidget {
  const NavigationView({super.key});

  @override
  State<NavigationView> createState() => _NavigationViewState();
}

class _NavigationViewState extends State<NavigationView> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        destinations: [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.leaderboard_rounded),
            label: 'Statistics',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_laundry_service_rounded),
            label: 'Devices',
          ),
        ],
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
      ),
      body: PageTransitionSwitcher(
        duration: Duration(milliseconds: 300),
        transitionBuilder:
            (child, animation, secondaryAnimation) => SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              child: child,
            ),
        child: _getPage(currentPageIndex),
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return HomeView(key: ValueKey<int>(0));
      case 1:
        return StatisticsView(key: ValueKey<int>(1));
      case 2:
        return DevicesView(key: ValueKey<int>(2));
      default:
        return HomeView(key: ValueKey<int>(0));
    }
  }
}
