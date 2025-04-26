import 'package:flutter/material.dart';

class TopConsumers extends StatelessWidget {
  const TopConsumers({super.key, required this.deviceConsumption});

  final Map<String, double> deviceConsumption;

  @override
  Widget build(BuildContext context) {
    final sortedDevices = deviceConsumption.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
          child: Text(
            'Top Energy Consumers',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: sortedDevices.length,
            itemBuilder: (context, index) {
              final entry = sortedDevices[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: ListTile(
                  title: FutureBuilder<String>(
                    future: _getDeviceName(entry.key),
                    builder: (context, snapshot) {
                      return Text(snapshot.data ?? 'Device ${index + 1}');
                    },
                  ),
                  subtitle: Text('${entry.value.toStringAsFixed(2)} kWh'),
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
        ),
      ],
    );
  }

  Future<String> _getDeviceName(String deviceId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return deviceId;
  }
}
