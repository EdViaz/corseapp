import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/admin_news_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/preferences_service.dart';

final ValueNotifier<bool> themeNotifier = ValueNotifier(false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final PreferencesService prefs = PreferencesService();
  final bool welcomeShown = await prefs.isWelcomeShown();
  runApp(MyApp(welcomeShown: welcomeShown));
}

class MyApp extends StatelessWidget {
  final bool welcomeShown;
  const MyApp({super.key, required this.welcomeShown});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (context, isDarkMode, _) {
        return MaterialApp(
          title: 'corseapp',
          theme: ThemeData(
            primarySwatch: Colors.red,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.red,
              brightness: Brightness.light,
              secondary: Colors.redAccent,
            ),
            brightness: Brightness.light,
            fontFamily: 'Montserrat', // Font moderno
            cardTheme: CardThemeData(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              shadowColor: Colors.red.withOpacity(0.15),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 4,
              centerTitle: true,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                elevation: 3,
                backgroundColor: Colors.red,
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: Colors.red,
              unselectedItemColor: Colors.black54,
              elevation: 16,
              type: BottomNavigationBarType.fixed,
              showUnselectedLabels: true,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.red,
              brightness: Brightness.dark,
              surface: Color(0xFF222222),
              secondary: Colors.redAccent,
            ),
            fontFamily: 'Montserrat',
            cardTheme: CardThemeData(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              shadowColor: Colors.red.withOpacity(0.15),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 4,
              centerTitle: true,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                elevation: 3,
                backgroundColor: Colors.red,
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color(0xFF222222),
              selectedItemColor: Colors.redAccent,
              unselectedItemColor: Colors.white70,
              elevation: 16,
              type: BottomNavigationBarType.fixed,
              showUnselectedLabels: true,
            ),
          ),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: welcomeShown ? '/' : '/welcome',
          routes: {
            '/': (context) => const HomeScreen(),
            '/welcome':
                (context) => WelcomeScreen(
                  onContinue: () async {
                    await PreferencesService().setWelcomeShown(true);
                    Navigator.of(context).pushReplacementNamed('/');
                  },
                ),
            '/admin': (context) => const AdminLoginScreen(),
            '/admin/news': (context) => const AdminNewsScreen(),
            '/settings':
                (context) => SettingsScreen(
                  onThemeChanged: (isDark) {
                    themeNotifier.value = isDark;
                  },
                ),
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
