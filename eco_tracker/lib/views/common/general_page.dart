import 'package:eco_tracker/services/authentication_service.dart';
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

  void fabFunction(BuildContext context) {
    return;
  }

  Widget buildBody(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(title),
        actions: [
          Consumer<AuthenticationService>(
            builder: (context, provider, child) {
              return IconButton(
                onPressed: null,
                icon: FutureBuilder<String?>(
                  future: provider.getUserAvatar(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        snapshot.connectionState == ConnectionState.none) {
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
        actionsPadding: EdgeInsets.only(right: 8.0),
      ),
      floatingActionButton:
          hasFAB
              ? FloatingActionButton(
                onPressed: () => fabFunction(context),
                backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                child: fabIcon,
              )
              : null,
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: buildBody(context),
      ),
    );
  }
}
