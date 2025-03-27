import 'package:eco_tracker/views/common/general_page.dart';
import 'package:flutter/material.dart';

class HomeView extends GeneralPage {
  HomeView({super.key})
    : super(title: 'Home', hasFAB: true, fabIcon: Icon(Icons.bolt));

  @override
  Widget buildBody(BuildContext context) {
    return Center(child: Text('To be implemented.'));
  }
}
