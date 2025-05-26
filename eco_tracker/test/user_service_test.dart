import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:eco_tracker/services/user_service.dart';

import 'user_service_test.mocks.dart';

@GenerateMocks([
  FirebaseAuth,
  FirebaseDatabase,
  User,
  DatabaseReference,
  DataSnapshot,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UserService Tests', () {
    late UserService userService;
    late MockFirebaseAuth mockAuth;
    late MockFirebaseDatabase mockDatabase;
    late MockUser mockUser;
    late MockDatabaseReference mockDatabaseRef;
    late MockDatabaseReference mockUserRef;
    late MockDatabaseReference mockRoleRef;
    late MockDatabaseReference mockCompanyRef;
    late MockDataSnapshot mockSnapshot;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockDatabase = MockFirebaseDatabase();
      mockUser = MockUser();
      mockDatabaseRef = MockDatabaseReference();
      mockUserRef = MockDatabaseReference();
      mockRoleRef = MockDatabaseReference();
      mockCompanyRef = MockDatabaseReference();
      mockSnapshot = MockDataSnapshot();

      // Create UserService with mocked dependencies
      userService = UserService(auth: mockAuth, database: mockDatabase);
    });

    group('getUserRole Tests', () {
      test('should throw exception when user is not authenticated', () async {
        when(mockAuth.currentUser).thenReturn(null);

        expect(
          () async => await userService.getUserRole(),
          throwsA(isA<Exception>()),
        );
      });

      test('should return default role "user" when role does not exist',
          () async {
        const userId = 'test-user-123';

        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn(userId);
        when(mockDatabase.ref()).thenReturn(mockDatabaseRef);
        when(mockDatabaseRef.child(userId)).thenReturn(mockUserRef);
        when(mockUserRef.child('role')).thenReturn(mockRoleRef);
        when(mockRoleRef.get()).thenAnswer((_) async => mockSnapshot);
        when(mockSnapshot.exists).thenReturn(false);

        final result = await userService.getUserRole();

        expect(result, equals('user'));
        verify(mockRoleRef.get()).called(1);
      });

      test('should return role when it exists in database', () async {
        const userId = 'test-user-123';
        const userRole = 'maintainer';

        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn(userId);
        when(mockDatabase.ref()).thenReturn(mockDatabaseRef);
        when(mockDatabaseRef.child(userId)).thenReturn(mockUserRef);
        when(mockUserRef.child('role')).thenReturn(mockRoleRef);
        when(mockRoleRef.get()).thenAnswer((_) async => mockSnapshot);
        when(mockSnapshot.exists).thenReturn(true);
        when(mockSnapshot.value).thenReturn(userRole);

        final result = await userService.getUserRole();

        expect(result, equals(userRole));
        verify(mockRoleRef.get()).called(1);
      });
    });

    group('isMaintainer Tests', () {
      test('should return true when user role is maintainer', () async {
        const userId = 'test-user-123';

        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn(userId);
        when(mockDatabase.ref()).thenReturn(mockDatabaseRef);
        when(mockDatabaseRef.child(userId)).thenReturn(mockUserRef);
        when(mockUserRef.child('role')).thenReturn(mockRoleRef);
        when(mockRoleRef.get()).thenAnswer((_) async => mockSnapshot);
        when(mockSnapshot.exists).thenReturn(true);
        when(mockSnapshot.value).thenReturn('maintainer');

        final result = await userService.isMaintainer();

        expect(result, isTrue);
      });

      test('should return false when user role is not maintainer', () async {
        const userId = 'test-user-123';

        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn(userId);
        when(mockDatabase.ref()).thenReturn(mockDatabaseRef);
        when(mockDatabaseRef.child(userId)).thenReturn(mockUserRef);
        when(mockUserRef.child('role')).thenReturn(mockRoleRef);
        when(mockRoleRef.get()).thenAnswer((_) async => mockSnapshot);
        when(mockSnapshot.exists).thenReturn(true);
        when(mockSnapshot.value).thenReturn('user');

        final result = await userService.isMaintainer();

        expect(result, isFalse);
      });

      test('should return false when getUserRole throws exception', () async {
        when(mockAuth.currentUser).thenReturn(null);

        final result = await userService.isMaintainer();

        expect(result, isFalse);
      });

      test('should return false when role does not exist (defaults to user)',
          () async {
        const userId = 'test-user-123';

        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn(userId);
        when(mockDatabase.ref()).thenReturn(mockDatabaseRef);
        when(mockDatabaseRef.child(userId)).thenReturn(mockUserRef);
        when(mockUserRef.child('role')).thenReturn(mockRoleRef);
        when(mockRoleRef.get()).thenAnswer((_) async => mockSnapshot);
        when(mockSnapshot.exists).thenReturn(false);

        final result = await userService.isMaintainer();

        expect(result, isFalse);
      });
    });

    group('getUserCompany Tests', () {
      test('should throw exception when user is not authenticated', () async {
        when(mockAuth.currentUser).thenReturn(null);

        expect(
          () async => await userService.getUserCompany(),
          throwsA(isA<Exception>()),
        );
      });

      test('should return empty string when company does not exist', () async {
        const userId = 'test-user-123';

        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn(userId);
        when(mockDatabase.ref()).thenReturn(mockDatabaseRef);
        when(mockDatabaseRef.child(userId)).thenReturn(mockUserRef);
        when(mockUserRef.child('company')).thenReturn(mockCompanyRef);
        when(mockCompanyRef.get()).thenAnswer((_) async => mockSnapshot);
        when(mockSnapshot.exists).thenReturn(false);

        final result = await userService.getUserCompany();

        expect(result, equals(''));
        verify(mockCompanyRef.get()).called(1);
      });

      test('should return company when it exists in database', () async {
        const userId = 'test-user-123';
        const company = 'TechCorp Inc.';

        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn(userId);
        when(mockDatabase.ref()).thenReturn(mockDatabaseRef);
        when(mockDatabaseRef.child(userId)).thenReturn(mockUserRef);
        when(mockUserRef.child('company')).thenReturn(mockCompanyRef);
        when(mockCompanyRef.get()).thenAnswer((_) async => mockSnapshot);
        when(mockSnapshot.exists).thenReturn(true);
        when(mockSnapshot.value).thenReturn(company);

        final result = await userService.getUserCompany();

        expect(result, equals(company));
        verify(mockCompanyRef.get()).called(1);
      });
    });

    group('getUserInfo Tests', () {
      test('should throw exception when user is not authenticated', () async {
        when(mockAuth.currentUser).thenReturn(null);

        expect(
          () async => await userService.getUserInfo(),
          throwsA(isA<Exception>()),
        );
      });

      test('should return default user info when user data does not exist',
          () async {
        const userId = 'test-user-123';
        const userEmail = 'test@example.com';
        const displayName = 'Test User';

        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn(userId);
        when(mockUser.email).thenReturn(userEmail);
        when(mockUser.displayName).thenReturn(displayName);
        when(mockDatabase.ref()).thenReturn(mockDatabaseRef);
        when(mockDatabaseRef.child(userId)).thenReturn(mockUserRef);
        when(mockUserRef.get()).thenAnswer((_) async => mockSnapshot);
        when(mockSnapshot.exists).thenReturn(false);

        final result = await userService.getUserInfo();

        expect(result['role'], equals('user'));
        expect(result['company'], equals(''));
        expect(result['email'], equals(userEmail));
        expect(result['displayName'], equals(displayName));
      });

      test(
          'should return default values when user email and displayName are null',
          () async {
        const userId = 'test-user-123';

        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn(userId);
        when(mockUser.email).thenReturn(null);
        when(mockUser.displayName).thenReturn(null);
        when(mockDatabase.ref()).thenReturn(mockDatabaseRef);
        when(mockDatabaseRef.child(userId)).thenReturn(mockUserRef);
        when(mockUserRef.get()).thenAnswer((_) async => mockSnapshot);
        when(mockSnapshot.exists).thenReturn(false);

        final result = await userService.getUserInfo();

        expect(result['role'], equals('user'));
        expect(result['company'], equals(''));
        expect(result['email'], equals(''));
        expect(result['displayName'], equals(''));
      });

      test('should return complete user info when all data exists', () async {
        const userId = 'test-user-123';
        const userEmail = 'test@example.com';
        const displayName = 'Test User';
        const userRole = 'maintainer';
        const company = 'TechCorp Inc.';

        final userData = {
          'role': userRole,
          'company': company,
          'extraField': 'should be ignored',
        };

        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn(userId);
        when(mockUser.email).thenReturn(userEmail);
        when(mockUser.displayName).thenReturn(displayName);
        when(mockDatabase.ref()).thenReturn(mockDatabaseRef);
        when(mockDatabaseRef.child(userId)).thenReturn(mockUserRef);
        when(mockUserRef.get()).thenAnswer((_) async => mockSnapshot);
        when(mockSnapshot.exists).thenReturn(true);
        when(mockSnapshot.value).thenReturn(userData);

        final result = await userService.getUserInfo();

        expect(result['role'], equals(userRole));
        expect(result['company'], equals(company));
        expect(result['email'], equals(userEmail));
        expect(result['displayName'], equals(displayName));
        expect(result.containsKey('extraField'), isFalse);
      });

      test('should handle partial user data with missing fields', () async {
        const userId = 'test-user-123';
        const userEmail = 'test@example.com';
        const displayName = 'Test User';

        final userData = {
          'role': 'maintainer',
          // company field is missing
        };

        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn(userId);
        when(mockUser.email).thenReturn(userEmail);
        when(mockUser.displayName).thenReturn(displayName);
        when(mockDatabase.ref()).thenReturn(mockDatabaseRef);
        when(mockDatabaseRef.child(userId)).thenReturn(mockUserRef);
        when(mockUserRef.get()).thenAnswer((_) async => mockSnapshot);
        when(mockSnapshot.exists).thenReturn(true);
        when(mockSnapshot.value).thenReturn(userData);

        final result = await userService.getUserInfo();

        expect(result['role'], equals('maintainer'));
        expect(result['company'], equals(''));
        expect(result['email'], equals(userEmail));
        expect(result['displayName'], equals(displayName));
      });

      test('should handle user data with only company field', () async {
        const userId = 'test-user-123';
        const userEmail = 'test@example.com';
        const displayName = 'Test User';

        final userData = {
          'company': 'TechCorp Inc.',
          // role field is missing
        };

        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn(userId);
        when(mockUser.email).thenReturn(userEmail);
        when(mockUser.displayName).thenReturn(displayName);
        when(mockDatabase.ref()).thenReturn(mockDatabaseRef);
        when(mockDatabaseRef.child(userId)).thenReturn(mockUserRef);
        when(mockUserRef.get()).thenAnswer((_) async => mockSnapshot);
        when(mockSnapshot.exists).thenReturn(true);
        when(mockSnapshot.value).thenReturn(userData);

        final result = await userService.getUserInfo();

        expect(result['role'], equals('user'));
        expect(result['company'], equals('TechCorp Inc.'));
        expect(result['email'], equals(userEmail));
        expect(result['displayName'], equals(displayName));
      });
    });
  });
}
