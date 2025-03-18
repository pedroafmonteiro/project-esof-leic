import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationProvider with ChangeNotifier {
  GoogleSignInAccount? _currentUser;
  GoogleUserCircleAvatar? _avatar;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  GoogleSignInAccount? get currentUser => _currentUser;
  GoogleUserCircleAvatar? get avatar => _avatar;

  AuthenticationProvider() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _currentUser = _googleSignIn.currentUser;
        _avatar = _currentUser != null ? GoogleUserCircleAvatar(identity: _currentUser!) : null;
      } else {
        _currentUser = null;
        _avatar = null;
      }
      notifyListeners();
    });
  }

  Future<void> signIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      _currentUser = googleUser;
      _avatar = GoogleUserCircleAvatar(identity: googleUser);
      notifyListeners();
    } catch (error) {
      // Handle error
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    _currentUser = null;
    _avatar = null;
    notifyListeners();
  }
}