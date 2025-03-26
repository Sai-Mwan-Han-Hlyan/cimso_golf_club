import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cimso_golf_booking/screens/dashboard.dart';
import 'package:cimso_golf_booking/screens/create_account.dart';
import 'package:cimso_golf_booking/screens/login.dart';
import 'package:cimso_golf_booking/screens/booking.dart';
import 'package:cimso_golf_booking/screens/splash_screen.dart';
import 'package:cimso_golf_booking/screens/settings_screen.dart'; // Add this import
import 'package:cimso_golf_booking/providers/theme_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // The Consumer will rebuild the MaterialApp whenever ThemeProvider changes
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        print('Building MaterialApp with theme: ${themeProvider.isDarkMode ? "Dark" : "Light"}');
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Golf Booking App',
          theme: themeProvider.isDarkMode ? ThemeProvider.darkTheme : ThemeProvider.lightTheme,
          darkTheme: ThemeProvider.darkTheme, // Explicitly set darkTheme
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light, // Explicitly set themeMode
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/booking': (context) => const BookingPage(),
            '/login': (context) => const Login(),
            '/create_account': (context) => const CreateAccount(),
            '/dashboard': (context) => const Dashboard(title: 'Dashboard'),
            '/settings': (context) => const SettingsScreen(),
          },
        );
      },
    );
  }
}