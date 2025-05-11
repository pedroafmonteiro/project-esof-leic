import 'package:cached_network_image/cached_network_image.dart';
import 'package:eco_tracker/services/authentication_service.dart';
import 'package:eco_tracker/services/exceptions.dart';
import 'package:eco_tracker/services/settings_service.dart';
import 'package:eco_tracker/widgets/reauthentication_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key, required this.avatarUrl});

  final String? avatarUrl;

  // Predefined color options
  static const List<ColorOption> colorOptions = [
    ColorOption(name: 'Red', color: Colors.red),
    ColorOption(name: 'Orange', color: Colors.orange),
    ColorOption(name: 'Yellow', color: Colors.yellow),
    ColorOption(name: 'Green', color: Colors.green),
    ColorOption(name: 'Cyan', color: Colors.cyan),
    ColorOption(name: 'Blue', color: Colors.blue),
    ColorOption(name: 'Purple', color: Colors.purple),
    ColorOption(name: 'Pink', color: Colors.pink),
  ];

  @override
  Widget build(BuildContext context) {
    final settingsService = Provider.of<SettingsService>(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(forceMaterialTransparency: true),
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8.0,
            children: [
              Center(
                child: Hero(
                  tag: "avatar",
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        avatarUrl != null
                            ? BoxShadow(
                                color: Colors.black26,
                                blurRadius: 20.0,
                                spreadRadius: 0.0,
                                offset: Offset(0, 2),
                              )
                            : const BoxShadow(color: Colors.transparent),
                      ],
                    ),
                    child: SizedBox(
                        width: 200,
                        height: 200,
                        child: avatarUrl != null
                            ? CircleAvatar(
                                radius: 100,
                                backgroundColor: Colors.transparent,
                                backgroundImage: CachedNetworkImageProvider(
                                  avatarUrl!,
                                ),
                              )
                            : const CircleAvatar(
                                backgroundColor: Colors.transparent,
                                child: Icon(
                                  Icons.account_circle_outlined,
                                  size: 200,
                                ),
                              )),
                  ),
                ),
              ),
              Center(
                child: Consumer<AuthenticationService>(
                  builder: (context, provider, child) {
                    final displayName = provider.displayName ?? 'User';
                    return Text(
                      displayName,
                      style: Theme.of(context).textTheme.headlineSmall,
                    );
                  },
                ),
              ),
              Center(
                child: Consumer<AuthenticationService>(
                  builder: (context, provider, child) {
                    final email = provider.email ?? 'Unknown email';
                    return Text(
                      email,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                "Settings",
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "Dark mode",
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Spacer(),
                        Switch(
                          value: settingsService.darkMode,
                          onChanged: (value) {
                            settingsService.setDarkMode(value);
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      children: [
                        Text(
                          "Material You",
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Spacer(),
                        Switch(
                          value: settingsService.materialYou,
                          onChanged: (value) {
                            settingsService.setMaterialYou(value);
                          },
                        ),
                      ],
                    ),
                    if (!settingsService.materialYou) ...[
                      SizedBox(height: 16.0),
                      Row(
                        children: [
                          Text(
                            "Accent color",
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: () {
                              // Show color selection dialog
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Select accent color'),
                                    content: Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      alignment: WrapAlignment.center,
                                      children: SettingsService.predefinedColors
                                          .map((option) {
                                        return GestureDetector(
                                          onTap: () {
                                            settingsService
                                                .setAccentColor(option.color);
                                            Navigator.of(context).pop();
                                          },
                                          child: Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: option.color,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: settingsService
                                                            .accentColor ==
                                                        option.color
                                                    ? Colors.white
                                                    : Colors.transparent,
                                                width: 2,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  blurRadius: 5,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child:
                                                settingsService.accentColor ==
                                                        option.color
                                                    ? Icon(
                                                        Icons.check,
                                                        color: Colors.white,
                                                      )
                                                    : null,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Cancel'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: settingsService.accentColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 8.0),
              Center(
                child: Consumer<AuthenticationService>(
                  builder: (context, provider, child) {
                    return TextButton(
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
              ),
              Center(
                child: Consumer<AuthenticationService>(
                  builder: (context, provider, child) {
                    return TextButton(
                      onPressed: () {
                        // Show confirmation dialog before deleting account
                        showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: Text("Delete Account"),
                              content: Text(
                                  "Are you sure you want to permanently delete your account? This action cannot be undone."),
                              actions: [
                                TextButton(
                                  child: Text("Cancel"),
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text(
                                    "Delete",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  onPressed: () async {
                                    Navigator.of(dialogContext).pop();
                                    try {
                                      await provider.deleteAccount();
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        if (e
                                            is ReauthenticationRequiredException) {
                                          // Show the reauthentication dialog
                                          final isGoogleSignIn =
                                              provider.currentUser != null;
                                          final success =
                                              await showReauthenticationDialog(
                                                  context, isGoogleSignIn);

                                          // If reauthentication was successful, try deleting again
                                          if (success && context.mounted) {
                                            try {
                                              await provider.deleteAccount();
                                              if (context.mounted) {
                                                Navigator.pop(context);
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          "Failed to delete account: ${e.toString()}")),
                                                );
                                              }
                                            }
                                          }
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    "Failed to delete account: ${e.toString()}")),
                                          );
                                        }
                                      }
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: Text("Delete Account"),
                    );
                  },
                ),
              ),
              SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}

class ColorOption {
  final String name;
  final Color color;

  const ColorOption({required this.name, required this.color});
}
