import 'package:eco_tracker/views/devices/devices_view.dart';
import 'package:eco_tracker/views/home/home_view.dart';
import 'package:eco_tracker/views/statistics/statistics_view.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

class NavigationView extends StatefulWidget {
  static final GlobalKey<NavigationViewState> navigatorKey =
      GlobalKey<NavigationViewState>();

  static void navigateTo(int index, {int? statisticsTabIndex}) {
    navigatorKey.currentState
        ?.changePage(index, statisticsTabIndex: statisticsTabIndex);
  }

  NavigationView({Key? key}) : super(key: navigatorKey);

  @override
  State<NavigationView> createState() => NavigationViewState();
}

class NavigationViewState extends State<NavigationView> {
  int currentPageIndex = 0;
  int? pendingStatisticsTabIndex;

  void changePage(int index, {int? statisticsTabIndex}) {
    if (index >= 0 && index <= 2) {
      setState(() {
        currentPageIndex = index;
        pendingStatisticsTabIndex = statisticsTabIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
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
        transitionBuilder: (child, animation, secondaryAnimation) =>
            SharedAxisTransition(
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
        final view = StatisticsView(key: ValueKey<int>(1));
        if (pendingStatisticsTabIndex != null) {
          Future.microtask(() {
            StatisticsView.navigateToTab(pendingStatisticsTabIndex!);
          });
        }
        return view;
      case 2:
        return DevicesView(key: ValueKey<int>(2));
      default:
        return HomeView(key: ValueKey<int>(0));
    }
  }
}
