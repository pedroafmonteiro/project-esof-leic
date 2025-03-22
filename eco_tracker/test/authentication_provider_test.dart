import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:eco_tracker/providers/authentication_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomMockGoogleSignInAccount extends MockGoogleSignInAccount {
  @override
  Future<GoogleSignInAuthentication> get authentication async {
    return MockGoogleSignInAuthentication();
  }
}

class CustomMockGoogleSignIn extends MockGoogleSignIn {
  final CustomMockGoogleSignInAccount _mockAccount = CustomMockGoogleSignInAccount();

  @override
  Future<CustomMockGoogleSignInAccount> signIn() async => _mockAccount;

  @override
  Future<CustomMockGoogleSignInAccount?> signOut() async => null; 
}

void main() {
  group('AuthenticationProvider Tests', () {
    late AuthenticationProvider authProvider;
    late MockFirebaseAuth mockAuth;
    late CustomMockGoogleSignIn mockGoogleSignIn; 
    late MockUser mockUser;

    setUp(() async {
      SharedPreferences.setMockInitialValues({}); 
      mockUser = MockUser(
        isAnonymous: false,
        uid: 'some-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        photoURL: 'https://example.com/avatar.png',
      );

      mockAuth = MockFirebaseAuth(mockUser: mockUser); 
      mockGoogleSignIn = CustomMockGoogleSignIn(); 

      authProvider = AuthenticationProvider(
        firebaseAuth: mockAuth,
        googleSignIn: mockGoogleSignIn,
      );
    });

    test('signIn should authenticate user and update currentUser', () async {
      final googleSignInAccount = await mockGoogleSignIn.signIn();
      expect(googleSignInAccount, isNotNull);

      final googleAuth = await googleSignInAccount.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await mockAuth.signInWithCredential(credential);
      final user = userCredential.user;

      expect(user, isNotNull);
      expect(user!.email, mockUser.email); 
    });

    test('signOut should clear currentUser and cached avatar', () async {
      await authProvider.signOut();

      expect(authProvider.currentUser, isNull);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('userAvatar'), isNull);
    });

    test('getUserAvatar should return cached avatar if available', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userAvatar', 'https://example.com/avatar.png');

      final avatar = await authProvider.getUserAvatar();
      expect(avatar, 'https://example.com/avatar.png');
    });
  });
}
