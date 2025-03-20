import 'package:eco_tracker/view/common/general_bottom_sheet.dart';
import 'package:eco_tracker/view/common/general_page.dart';
import 'package:flutter/material.dart';

class DevicesView extends GeneralPage {
  DevicesView({super.key})
    : super(title: "Devices", hasFAB: true, fabIcon: Icon(Icons.add));

  @override
  void fabFunction(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => GeneralBottomSheet(
            child: Wrap(
              runSpacing: 8.0,
              children: [
                Text(
                  'Add device',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Model',
                    border: OutlineInputBorder(),
                  ),
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Manufacturer',
                    border: OutlineInputBorder(),
                  ),
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Power consumption (Wattage)',
                    border: OutlineInputBorder(),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: null,
                      style: ButtonStyle(
                        padding: WidgetStateProperty.all(
                          EdgeInsets.only(left: 0.0),
                        ),
                        backgroundColor: WidgetStateProperty.all(
                          Colors.transparent,
                        ),
                      ),
                      child: Text('Select from list'),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          Theme.of(context).colorScheme.primary,
                        ),
                        foregroundColor: WidgetStateProperty.all(
                          Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      onPressed: () => showLicensePage(context: context),
                      child: Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget buildBody() {
    return Center(child: Text('To be implemented.'));
  }
}
