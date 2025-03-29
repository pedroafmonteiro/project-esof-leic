import 'package:eco_tracker/views/common/general_page.dart';
import 'package:flutter/material.dart';
import 'package:eco_tracker/services/tips_service.dart';

class HomeView extends GeneralPage {
  HomeView({super.key})
      : dailyTip = getTodaysTip(), // Initialize dailyTip in the constructor
        super(title: 'Home', hasFAB: true, fabIcon: Icon(Icons.bolt));

  final Future<String> dailyTip; // Declare dailyTip as final

  @override
  Widget buildBody(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<String>(
          future: dailyTip, // Use the initialized Future
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
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
        )
      ],
    );
  }
}
