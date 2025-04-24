import 'package:eco_tracker/views/common/general_page.dart';
import 'package:flutter/material.dart';

class StatisticsView extends StatefulWidget {
  const StatisticsView({super.key});

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  String selectedFilter = "Daily";

  @override
  Widget build(BuildContext context) {
    return StatisticsPage(
      selectedFilter: selectedFilter,
      onFilterChanged: (filter) {
        setState(() {
          selectedFilter = filter;
        });
      },
    );
  }
}

class StatisticsPage extends GeneralPage {
  final String selectedFilter;
  final void Function(String) onFilterChanged;

  const StatisticsPage({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  }) : super(title: "Statistics", hasFAB: false);

  @override
  Widget buildBody(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FilterChip(
              label: const Text("Daily"),
              selected: selectedFilter == "Daily",
              showCheckmark: false,
              onSelected: (value) {
                if (value) {
                  onFilterChanged("Daily");
                }
              },
            ),
            FilterChip(
              label: const Text("Weekly"),
              selected: selectedFilter == "Weekly",
              showCheckmark: false,
              onSelected: (value) {
                if (value) {
                  onFilterChanged("Weekly");
                }
              },
            ),
            FilterChip(
              label: const Text("Monthly"),
              selected: selectedFilter == "Monthly",
              showCheckmark: false,
              onSelected: (value) {
                if (value) {
                  onFilterChanged("Monthly");
                }
              },
            ),
            FilterChip(
              label: const Text("Yearly"),
              selected: selectedFilter == "Yearly",
              showCheckmark: false,
              onSelected: (value) {
                if (value) {
                  onFilterChanged("Yearly");
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
