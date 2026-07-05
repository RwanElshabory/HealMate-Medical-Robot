import 'package:flutter/material.dart';
import 'core/network/api_client.dart';
import 'screens/splash_screen.dart';
import 'screens/select_role_screen.dart';
import 'screens/welcome_screen.dart';
import 'models/user_role.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient.init();
  runApp(const HealMateApp());
}

class HealMateApp extends StatelessWidget {
  const HealMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF00A8FF),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00A8FF),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF4F8FF),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFF00A8FF),
              width: 1.5,
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/select-role': (_) => const SelectRoleScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/welcome') {
          final role = settings.arguments as UserRole? ?? UserRole.doctor;
          return MaterialPageRoute(
            builder: (_) => WelcomeScreen(role: role),
          );
        }
        return null;
      },
    );
  }
}