import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationProvider with ChangeNotifier {
  GoogleSignInAccount? _currentUser;
  String? _cachedAvatarUrl;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  GoogleSignInAccount? get currentUser => _currentUser;

  AuthenticationProvider() {
    _loadCachedAvatar();

    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _currentUser = _googleSignIn.currentUser;
      } else {
        _currentUser = null;
        _cachedAvatarUrl = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadCachedAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    _cachedAvatarUrl = prefs.getString('userAvatar');
    notifyListeners();
  }

  Future<void> signIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      _cachedAvatarUrl = googleUser.photoUrl;
      _saveUserAvatar(_cachedAvatarUrl);

      _currentUser = googleUser;
      notifyListeners();
    } catch (error) {
      // Handle error
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    _currentUser = null;
    _cachedAvatarUrl = null;
    _removeUserAvatar();
    notifyListeners();
  }

  Future<void> _saveUserAvatar(String? photoURL) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userAvatar', photoURL ?? '');
  }

  Future<void> _removeUserAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userAvatar');
  }

  Future<String?> getUserAvatar() async {
    if (_cachedAvatarUrl != null) {
      return _cachedAvatarUrl;
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userAvatar');
  }
}
