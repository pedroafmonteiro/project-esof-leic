import 'package:eco_tracker/viewmodels/statistics_view_model.dart';
import 'package:eco_tracker/views/statistics/widgets/statistics_card.dart';
import 'package:eco_tracker/views/statistics/widgets/top_consumers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:eco_tracker/services/settings_service.dart';

class DailyView extends StatelessWidget {
  const DailyView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<StatisticsViewModel>(context);
    final dailyUsage = viewModel.dailyUsage;

    if (viewModel.isLoadingDaily) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.dailyError != null) {
      return Center(
        child: Text(
          'Error loading data: ${viewModel.dailyError}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
    return Consumer<SettingsService>(
      builder: (context, settingsService, _) {
        final double usageKwh = dailyUsage?.totalKwh ?? 0;
        final double costEuros = usageKwh * settingsService.energyCost;

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Column(
                spacing: 8.0,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => _selectDate(context, viewModel),
                      child: Text(
                        DateFormat('MMM dd, yyyy')
                            .format(viewModel.selectedDate),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  ),
                  StatisticsCard(
                    data: usageKwh,
                    title: 'Daily Usage',
                    extension: 'kWh',
                  ),
                  StatisticsCard(
                    data: costEuros,
                    title: 'Daily Cost',
                    extension: '€',
                  ),
                  if (dailyUsage != null &&
                      dailyUsage.deviceConsumption.isNotEmpty)
                    TopConsumers(
                      deviceConsumption: dailyUsage.deviceConsumption,
                    ),
                  if (dailyUsage == null ||
                      dailyUsage.deviceConsumption.isEmpty)
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: const Center(
                        child: Text(
                          'No device usage data recorded for this day.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

Future<void> _selectDate(
  BuildContext context,
  StatisticsViewModel viewModel,
) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: viewModel.selectedDate,
    firstDate: DateTime(2020),
    lastDate: DateTime.now(),
  );

  if (picked != null && picked != viewModel.selectedDate) {
    viewModel.changeSelectedDate(picked);
  }
}
