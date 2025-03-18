import 'package:eco_tracker/providers/authentication_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuthenticationProvider>(context);
    final user = provider.currentUser;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (user == null)
            Center(
              child: ElevatedButton(
                onPressed: provider.signIn,
                child: Text('Sign in with Google'),
              ),
            ),
          if (user != null) ...[
            provider.avatar ?? Container(),
            Text(user.email),
          ],
        ],
      ),
    );
  }
}
