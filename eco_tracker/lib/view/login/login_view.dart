import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

GoogleSignIn _googleSignIn = GoogleSignIn();

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    super.initState();

    _googleSignIn.onCurrentUserChanged.listen((
      GoogleSignInAccount? account,
    ) async {
      setState(() {
        _currentUser = account;
      });
    });
    {}
  }

  Future<void> _handleSignIn() async {
    try {
      _googleSignIn.signIn();
    } catch (error) {
      // print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_currentUser == null)
            Center(
              child: ElevatedButton(
                onPressed: _handleSignIn,
                child: Text('Sign in with Google'),
              ),
            ),
          if (_currentUser != null)
            GoogleUserCircleAvatar(identity: _currentUser!),
          Text(_currentUser!.email),
        ],
      ),
    );
  }
}
