import 'package:eco_tracker/viewmodels/statistics_view_model.dart';
import 'package:eco_tracker/views/statistics/widgets/statistics_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
        ),
      );
    }

    final double usageKwh = dailyUsage?.totalKwh ?? 0;
    final double costEuros = dailyUsage?.totalCost ?? 0;

    return Column(
      key: const ValueKey<int>(0),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('MMM dd, yyyy').format(viewModel.selectedDate),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context, viewModel),
              ),
            ],
          ),
        ),
        StatisticsCard(
          data: usageKwh,
          title: 'Estimated Usage',
          extension: 'kWh',
        ),
        const SizedBox(height: 8.0),
        StatisticsCard(
          data: costEuros,
          title: 'Estimated Cost',
          extension: '€',
        ),
        /* if (dailyUsage != null && dailyUsage.deviceConsumption.isNotEmpty)
          Expanded(
            child: _buildTopConsumers(context, dailyUsage.deviceConsumption),
          ), */
        if (dailyUsage == null || dailyUsage.deviceConsumption.isEmpty)
          const Expanded(
            child: Center(
              child: Text(
                'No usage data recorded for this day.\nTry selecting another date or log device usage.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
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
}
