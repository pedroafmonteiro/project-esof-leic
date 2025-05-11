import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eco_tracker/services/authentication_service.dart';
import 'package:eco_tracker/views/profile/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

abstract class GeneralPage extends StatelessWidget {
  const GeneralPage({
    super.key,
    required this.title,
    required this.hasFAB,
    this.fabIcon,
    this.secondaryActions,
  });

  final String title;
  final bool hasFAB;
  final Icon? fabIcon;
  final List<Widget>? secondaryActions;

  void fabFunction(BuildContext context) {
    return;
  }

  Future<void> onRefresh(BuildContext context) {
    return Future.value();
  }

  Widget buildBody(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (secondaryActions != null) ...secondaryActions!,
          Consumer<AuthenticationService>(
            builder: (context, provider, child) {
              return IconButton(
                onPressed: () {
                  final avatarUrl = provider.cachedAvatarUrl;
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          ProfileView(avatarUrl: avatarUrl),
                      transitionsBuilder: (
                        context,
                        animation,
                        secondaryAnimation,
                        child,
                      ) {
                        return SharedAxisTransition(
                          animation: animation,
                          secondaryAnimation: secondaryAnimation,
                          transitionType: SharedAxisTransitionType.horizontal,
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  );
                },
                icon: Hero(
                  tag: "avatar",
                  child: SizedBox(
                      width: 40,
                      height: 40,
                      child: provider.cachedAvatarUrl != null
                          ? CircleAvatar(
                              backgroundColor: Colors.transparent,
                              backgroundImage: CachedNetworkImageProvider(
                                provider.cachedAvatarUrl!,
                              ),
                            )
                          : const CircleAvatar(
                              backgroundColor: Colors.transparent,
                              child: Icon(Icons.account_circle_outlined),
                            ),),
                ),
              );
            },
          ),
        ],
        actionsPadding: EdgeInsets.only(right: 8.0),
      ),
      floatingActionButton: hasFAB
          ? FloatingActionButton(
              onPressed: () => fabFunction(context),
              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              child: fabIcon,
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async {
          onRefresh(context);
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: buildBody(context),
        ),
      ),
    );
  }
}
