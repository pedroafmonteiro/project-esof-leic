import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eco_tracker/services/exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationService with ChangeNotifier {
  GoogleSignInAccount? _currentUser;
  String? _cachedAvatarUrl;
  final GoogleSignIn _googleSignIn;
  final FirebaseAuth _auth;

  GoogleSignInAccount? get currentUser => _currentUser;
  String? get cachedAvatarUrl => _cachedAvatarUrl;
  String? get displayName => _auth.currentUser?.displayName;
  String? get email => _auth.currentUser?.email;

  AuthenticationService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn() {
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

    if (_cachedAvatarUrl != null) {
      CachedNetworkImageProvider(
        _cachedAvatarUrl!,
      ).resolve(const ImageConfiguration());
    }

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

      final userImageUrl = googleUser.photoUrl?.replaceAll("s96-c", "s512-c");
      _cachedAvatarUrl = userImageUrl;
      _saveUserAvatar(_cachedAvatarUrl);
      if (_cachedAvatarUrl != null) {
        CachedNetworkImageProvider(
          _cachedAvatarUrl!,
        ).resolve(const ImageConfiguration());
      }

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

  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      await user.delete();

      _currentUser = null;
      _cachedAvatarUrl = null;
      _removeUserAvatar();

      notifyListeners();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw ReauthenticationRequiredException(
          'Please sign in again before deleting your account for security reasons.',
        );
      } else {
        throw Exception('Failed to delete account: ${e.message}');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<bool> reauthenticateWithPassword(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return false;
      }

      if (user.email != null) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
        return true;
      }

      return false;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'wrong-password':
          errorMessage = 'Incorrect password.';
          break;
        case 'user-mismatch':
          errorMessage = 'Credentials don\'t match the current user.';
          break;
        default:
          errorMessage = 'Reauthentication failed: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Reauthentication failed: ${e.toString()}');
    }
  }

  Future<bool> reauthenticateWithGoogle() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return false;
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await user.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      throw Exception('Google reauthentication failed: ${e.toString()}');
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      notifyListeners();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'user-disabled':
          errorMessage = 'This user account has been disabled.';
          break;
        default:
          errorMessage = 'An error occurred. Please try again later.';
      }
      throw Exception(errorMessage);
    }
  }

  Future<UserCredential?> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      notifyListeners();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'An account already exists for this email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'weak-password':
          errorMessage = 'The password is too weak.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled.';
          break;
        default:
          errorMessage = 'An error occurred during registration.';
      }
      throw Exception(errorMessage);
    }
  }

  Future<bool> isEmailAlreadyRegistered(String email) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: 'temporaryPassword123!',
      );
      await _auth.currentUser?.delete();
      await _auth.signOut();

      return false;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        default:
          errorMessage = 'An error occurred. Please try again later.';
      }
      throw Exception(errorMessage);
    }
  }
}
