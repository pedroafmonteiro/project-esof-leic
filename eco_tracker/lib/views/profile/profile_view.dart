import 'package:cached_network_image/cached_network_image.dart';
import 'package:eco_tracker/services/authentication_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key, required this.avatarUrl});

  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          spacing: 8.0,
          children: [
            Hero(
              tag: "avatar",
              child: SizedBox(
                width: 200,
                height: 200,
                child:
                    avatarUrl != null
                        ? CircleAvatar(
                          radius: 100,
                          backgroundColor: Colors.transparent,
                          backgroundImage: CachedNetworkImageProvider(
                            avatarUrl!,
                          ),
                        )
                        : CircleAvatar(backgroundColor: Colors.transparent),
              ),
            ),
            Consumer<AuthenticationService>(
              builder: (context, provider, child) {
                final displayName = provider.displayName ?? 'User';
                return Text(
                  displayName,
                  style: Theme.of(context).textTheme.headlineSmall,
                );
              },
            ),
            Consumer<AuthenticationService>(
              builder: (context, provider, child) {
                final email = provider.email ?? 'Unknown email';
                return Text(
                  email,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
            Consumer<AuthenticationService>(
              builder: (context, provider, child) {
                return ElevatedButton(
                  onPressed: () {
                    provider.signOut();
                    Future.microtask(() {
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    });
                  },
                  child: Text("Sign out"),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
