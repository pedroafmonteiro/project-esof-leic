import 'package:eco_tracker/models/device_model.dart';
import 'package:eco_tracker/viewmodels/device_view_model.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

// Mock classes
class MockDatabaseReference extends Mock implements DatabaseReference {}
class MockDatabaseEvent extends Mock implements DatabaseEvent {}
class MockFirebaseApp extends Mock implements FirebaseApp {}
class MockFirebaseAuth extends Mock with MockFirebaseAuthMixin {
  User? _currentUser;

  @override
  User? get currentUser => _currentUser;

  set currentUser(User? user) {
    _currentUser = user;
  }
}

mixin MockFirebaseAuthMixin {}

// Mock class for User
class MockUser extends Mock implements User {
  @override
  String get uid => 'testUserId'; // Mock the uid getter
}

void main() {
  // Ensure the Flutter binding is initialized before anything else
  TestWidgetsFlutterBinding.ensureInitialized();

  late DeviceViewModel deviceViewModel;
  late MockDatabaseReference mockDatabaseRef;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MockFirebaseApp mockApp;

  setUp(() {
    // Mock Firebase initialization
    mockApp = MockFirebaseApp();
    when(() => Firebase.initializeApp()).thenAnswer((_) async => mockApp);

    // Initialize mock objects
    mockDatabaseRef = MockDatabaseReference();
    mockUser = MockUser();
    when(() => mockUser.uid).thenReturn('testUserId'); // Mock user.uid directly
    mockAuth = MockFirebaseAuth();
    when(() => mockAuth.currentUser).thenReturn(mockUser); // Mock user
    deviceViewModel = DeviceViewModel();

    // Mock Firebase database reference's onValue method
    final mockEvent = MockDatabaseEvent();
    when(() => mockEvent.snapshot.value).thenReturn({
      'device1': {
        'id': 'device1',
        'model': 'EcoSensor',
        'manufacturer': 'EcoTech',
        'category': 'Sensor',
        'powerConsumption': 5,
      },
      'device2': {
        'id': 'device2',
        'model': 'SmartPlug',
        'manufacturer': 'EcoTech',
        'category': 'Plug',
        'powerConsumption': 10,
      },
    });
    when(() => mockDatabaseRef.onValue).thenAnswer((_) => Stream.value(mockEvent));

    // Mock push and set methods for adding devices
    final mockPush = MockDatabaseReference();
    when(() => mockDatabaseRef.push()).thenReturn(mockPush);
    when(() => mockPush.set(any())).thenAnswer((_) async {});
  });

  group('DeviceViewModel Tests', () {
    test('should load devices from Firebase database', () async {
      // Wait for stream updates to propagate
      await Future.delayed(Duration(milliseconds: 100));

      expect(deviceViewModel.devices.length, 2);
      expect(deviceViewModel.devices[0].id, 'device1');
      expect(deviceViewModel.devices[1].id, 'device2');
    });

    test('should add a device to Firebase database', () async {
      final newDevice = Device(
        model: 'EcoThermostat',
        manufacturer: 'EcoTech',
        category: 'Thermostat',
        powerConsumption: 15,
      );

      // Define and mock the database reference
      final mockDatabaseRef = MockDatabaseReference();
      registerFallbackValue({});
      
      // Mock push and set methods for the database reference
      final mockPush = MockDatabaseReference();
      when(() => mockDatabaseRef.push()).thenReturn(mockPush);
      when(() => mockPush.set(any())).thenAnswer((_) async {});

      await deviceViewModel.addDevice(newDevice);
      verify(() => mockPush.set(any())).called(1);
    });
  });
}
