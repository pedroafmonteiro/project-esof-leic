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
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          Consumer<AuthenticationProvider>(
            builder: (context, provider, child) {
              return IconButton(
                onPressed: null,
                icon: FutureBuilder<String?>(
                  future: provider.getUserAvatar(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Icon(Icons.account_circle_outlined);
                    }
                    if (snapshot.hasData && snapshot.data != null) {
                      return CircleAvatar(
                        backgroundColor: Colors.transparent,
                        backgroundImage: NetworkImage(snapshot.data!),
                      );
                    }
                    return const Icon(Icons.account_circle_outlined);
                  },
                ),
              );
            },
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
