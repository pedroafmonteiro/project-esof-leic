import 'package:eco_tracker/providers/authentication_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

abstract class GeneralPage extends StatelessWidget {
  const GeneralPage({
    super.key,
    required this.title,
    required this.hasFAB,
    this.fabIcon,
  });

  final String title;
  final bool hasFAB;
  final Icon? fabIcon;

  Widget buildBody();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuthenticationProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            onPressed: null,
            icon: provider.avatar ?? Icon(Icons.account_circle),
          ),
        ],
      ),
      floatingActionButton:
          hasFAB
              ? FloatingActionButton(
                onPressed: null,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                child: fabIcon,
              )
              : null,
      body: buildBody(),
    );
  }
}
