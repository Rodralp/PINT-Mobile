import 'package:flutter/foundation.dart';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme/softinsa_theme.dart';
import 'screens/app_shell_screen.dart';
import 'screens/login_screen.dart';
import 'screens/preferences_screen.dart';
import 'screens/register_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
    if (details.stack != null) {
      debugPrint(details.stack.toString());
    }
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught error: $error');
    debugPrint(stack.toString());
    return true;
  };
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: SoftinsaColors.blue,
          brightness: Brightness.light,
        ).copyWith(
          primary: SoftinsaColors.blue,
          secondary: SoftinsaColors.blueDark,
          surface: SoftinsaColors.surface,
        ),
        scaffoldBackgroundColor: SoftinsaColors.surfaceAlt,
        textTheme: GoogleFonts.interTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: SoftinsaColors.ink,
          elevation: 0,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: SoftinsaColors.surface,
          hintStyle: const TextStyle(color: Color(0xFF9AA6B2)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: SoftinsaColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: SoftinsaColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: SoftinsaColors.blue, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(64, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
        ),
        cardTheme: CardThemeData(
          color: SoftinsaColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: SoftinsaColors.border),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: SoftinsaColors.surface,
          indicatorColor: const Color(0xFFEAF2FF),
          labelTextStyle: WidgetStatePropertyAll(
            GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
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