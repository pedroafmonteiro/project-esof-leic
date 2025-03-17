import 'package:flutter/material.dart';

abstract class GeneralPage extends StatelessWidget {
  const GeneralPage({super.key, required this.title});

  final String title;

  Widget buildBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(title)), body: buildBody());
  }
}
