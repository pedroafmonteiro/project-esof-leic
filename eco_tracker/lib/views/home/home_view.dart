import 'package:eco_tracker/views/common/general_page.dart';
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
              title: Text('Tip of the Day'),
              subtitle: Text(snapshot.data!),
            ),
          );
        } else {
          return Center(child: Text('No tip available'));
        }
      },
    );
  }
}
