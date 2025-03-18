import 'package:eco_tracker/view/common/general_page.dart';
import 'package:flutter/material.dart';

class DevicesView extends GeneralPage {
  DevicesView({super.key})
    : super(title: "Devices", hasFAB: true, fabIcon: Icon(Icons.add));

  @override
  Widget buildBody() {
    return Center(child: Text('To be implemented.'));
  }
}
