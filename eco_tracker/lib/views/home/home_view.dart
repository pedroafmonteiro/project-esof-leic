import 'package:eco_tracker/views/common/general_page.dart';
import 'package:flutter/material.dart';
import 'package:eco_tracker/services/tips_service.dart';

class HomeView extends GeneralPage {
  final TipsService tipsService;

  HomeView({super.key, required this.tipsService})
      : super(title: 'Home', hasFAB: true, fabIcon: Icon(Icons.bolt));

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
            margin: EdgeInsets.all(16),
            child: ListTile(
              title: Text('Tip of the Day', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(snapshot.data!, style: TextStyle(fontSize: 16)),
            ),
          );
        } else {
          return Center(child: Text('No tip available'));
        }
      },
    );
  }
}
