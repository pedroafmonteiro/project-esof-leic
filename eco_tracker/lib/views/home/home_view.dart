import 'package:eco_tracker/views/common/general_page.dart';
import 'package:eco_tracker/views/common/general_bottom_sheet.dart';
import 'package:eco_tracker/views/common/general_popup_menu.dart';
import 'package:flutter/material.dart';
import 'package:eco_tracker/services/tips_service.dart';

class HomeView extends GeneralPage {

  HomeView({super.key}) : super(title: 'Home', hasFAB: true, fabIcon: Icon(Icons.bolt));
  final TipsService tipsService = TipsService(); 

  @override
  Widget buildBody(BuildContext context) {
    return FutureBuilder<String>(
      future: tipsService.getTodaysTip(), // Call inside buildBody instead of constructor
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return Card(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            child: ListTile(
              title: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text('Tip of the Day', style: Theme.of(context).textTheme.headlineSmall),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(snapshot.data!, style: Theme.of(context).textTheme.labelLarge, textAlign: TextAlign.center),
              ),
            ),
          );
        } else {
          return Center(child: Text('No tip available'));
        }
      },
    );
  }
  @override
  void fabFunction(BuildContext context) {
    final hoursController = TextEditingController();
    final minutesController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    // Variable to store the selected device

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => GeneralBottomSheet(
            child: Form(
              key: formKey,
              child: Wrap(
                runSpacing: 8.0,
                children: [
                  Text(
                    'Log Usage',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  GestureDetector(
                    onTap: () async {
                      // Get the position for popup menu
                      final RenderBox button = context.findRenderObject() as RenderBox;
                      final Offset position = button.localToGlobal(Offset.zero);
                      
                      // Show popup menu and get result
                      final DeviceItem? result = await DevicePopupMenu.show(
                        context: context,
                        position: position,
                      );
                      
                      // Handle the selected device
                      if (result != null) {
                        // Update UI to show selected device
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(backgroundColor: Theme.of(context).colorScheme.onSurface, content: Text('Selected device: ${result.name}')),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest, 
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: Text('Choose device', style: Theme.of(context).textTheme.titleLarge),
                    ),      
                  ),
                  Row(  
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: hoursController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Hours',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Field cannot be empty.';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: minutesController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Minutes',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Field cannot be empty.';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            Theme.of(context).colorScheme.primary,
                          ),
                          foregroundColor: WidgetStateProperty.all(
                            Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        onPressed: () {
                          null;
                        },
                        child: Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
