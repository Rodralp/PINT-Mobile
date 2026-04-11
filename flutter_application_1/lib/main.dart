import 'package:flutter/material.dart';
import 'screens/app_shell_screen.dart';
import 'screens/login_screen.dart';
import 'screens/preferences_screen.dart';
import 'screens/register_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/preferences': (context) => const PreferencesScreen(),
        '/app': (context) => const AppShellScreen(),
      },
    );
  }
}