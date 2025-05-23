import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/admin_news_screen.dart';
import 'screens/settings_screen.dart';
import 'services/preferences_service.dart';

final ValueNotifier<bool> themeNotifier = ValueNotifier(false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final PreferencesService prefs = PreferencesService();
  final bool isDark = await prefs.isDarkMode();
  themeNotifier.value = isDark;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (context, isDarkMode, _) {
        return MaterialApp(
          title: 'corseapp',
          theme: ThemeData(
            primarySwatch: Colors.red,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.red, brightness: Brightness.light, secondary: Colors.redAccent),
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.red, brightness: Brightness.dark, surface: Color(0xFF222222), secondary: Colors.redAccent),
          ),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '/',
          routes: {
            '/': (context) => const HomeScreen(),
            '/admin': (context) => const AdminLoginScreen(),
            '/admin/news': (context) => const AdminNewsScreen(),
            '/settings': (context) => SettingsScreen(onThemeChanged: (isDark) {
              themeNotifier.value = isDark;
            }),
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
