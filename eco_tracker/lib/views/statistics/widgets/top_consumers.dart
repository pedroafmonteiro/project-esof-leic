import 'package:eco_tracker/services/device_service.dart';
import 'package:flutter/material.dart';

class TopConsumers extends StatelessWidget {
  const TopConsumers({super.key, required this.deviceConsumption});

  final Map<String, double> deviceConsumption;

  @override
  Widget build(BuildContext context) {
    final sortedDevices = deviceConsumption.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
            child: Text(
              'Top Energy Consumers',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedDevices.length,
            itemBuilder: (context, index) {
              final entry = sortedDevices[index];
              return Card(
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
                      color: Theme.of(context).colorScheme.secondaryContainer,
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
        ],
      ),
    );
  }

  Future<String> _getDeviceName(String deviceId) async {
    final device = await DeviceService().getDeviceById(deviceId);
    return '${device.manufacturer} ${device.model}';
  }
}
