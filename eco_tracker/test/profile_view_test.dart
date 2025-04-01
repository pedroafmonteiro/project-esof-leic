// filepath: /home/pedromonteiro/University/2º Ano/2º Semestre/ESOF/Projeto/eco_tracker/test/profile_view_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:eco_tracker/services/authentication_service.dart';
import 'package:eco_tracker/views/profile/profile_view.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([MockSpec<AuthenticationService>()])
import 'profile_view_test.mocks.dart';

void main() {
  group('ProfileView Widget Tests', () {
    late MockAuthenticationService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthenticationService();
      when(mockAuthService.displayName).thenReturn('Test User');
      when(mockAuthService.email).thenReturn('test@example.com');
    });

    testWidgets('renders correctly with avatar', (WidgetTester tester) async {
      const String testAvatarUrl = 'https://example.com/avatar.png';

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthenticationService>.value(
            value: mockAuthService,
            child: const ProfileView(avatarUrl: testAvatarUrl),
          ),
        ),
      );

      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Energy cost at your location'), findsOneWidget);
      expect(find.text('(€ per kWh)'), findsOneWidget);
      expect(find.text('Dark mode'), findsOneWidget);
      expect(find.text('Sign out'), findsOneWidget);

      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('renders correctly without avatar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthenticationService>.value(
            value: mockAuthService,
            child: const ProfileView(avatarUrl: null),
          ),
        ),
      );

      expect(find.text('Test User'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('signs out when sign out button is pressed', (
      WidgetTester tester,
    ) async {
      when(mockAuthService.signOut()).thenAnswer((_) async => {});

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthenticationService>.value(
            value: mockAuthService,
            child: const ProfileView(avatarUrl: null),
          ),
        ),
      );

      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();

      verify(mockAuthService.signOut()).called(1);
    });

    testWidgets('energy cost field shows default value', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthenticationService>.value(
            value: mockAuthService,
            child: const ProfileView(avatarUrl: null),
          ),
        ),
      );

      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      final TextField widget = tester.widget(textField);
      expect(widget.controller!.text, '0.15');
    });

    testWidgets('dark mode switch is initially off', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: ChangeNotifierProvider<AuthenticationService>.value(
            value: mockAuthService,
            child: const ProfileView(avatarUrl: null),
          ),
        ),
      );

      final switchWidget = find.byType(Switch);
      expect(switchWidget, findsOneWidget);

      final Switch widget = tester.widget(switchWidget);
      expect(widget.value, false);
    });
  });
}
