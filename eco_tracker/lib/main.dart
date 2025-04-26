import 'package:eco_tracker/firebase_options.dart';
import 'package:eco_tracker/services/authentication_service.dart';
import 'package:eco_tracker/services/settings_service.dart';
import 'package:eco_tracker/viewmodels/statistics_view_model.dart';
import 'package:eco_tracker/views/login/login_view.dart';
import 'package:eco_tracker/views/navigation/navigation_view.dart';
import 'package:eco_tracker/viewmodels/device_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await SettingsManager.preloadSettings();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthenticationService(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsService(),
        ),
        ChangeNotifierProvider(
          create: (_) => DeviceViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => StatisticsViewModel(),
        ),
      ],
      child: const MainApp(),
    ),
  );

  _setSystemUI();
}

void _setSystemUI() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(systemNavigationBarColor: Colors.transparent),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthenticationService>(
      context,
      listen: false,
    );
    final settingsService = Provider.of<SettingsService>(context);

    authService.getUserAvatar();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.light,
          seedColor: Colors.green,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: Colors.green,
        ),
      ),
      themeMode: settingsService.darkMode ? ThemeMode.dark : ThemeMode.light,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.connectionState == ConnectionState.none) {
            return CircularProgressIndicator();
          } else if (snapshot.hasData) {
            return NavigationView();
          } else {
            return LoginView();
          }
        },
      ),
    );
  }
}
