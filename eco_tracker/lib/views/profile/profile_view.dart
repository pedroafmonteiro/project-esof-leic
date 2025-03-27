import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key, required this.avatarUrl});

  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Hero(
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
          ),
        ],
      ),
    );
  }
}
