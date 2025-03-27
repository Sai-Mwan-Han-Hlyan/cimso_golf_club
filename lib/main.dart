import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cimso_golf_booking/screens/dashboard.dart';
import 'package:cimso_golf_booking/screens/create_account.dart';
import 'package:cimso_golf_booking/screens/login.dart';
import 'package:cimso_golf_booking/screens/booking.dart';
import 'package:cimso_golf_booking/screens/splash_screen.dart';
import 'package:cimso_golf_booking/screens/settings_screen.dart';
import 'package:cimso_golf_booking/providers/theme_provider.dart';
import 'package:cimso_golf_booking/providers/language_provider.dart';
import 'package:cimso_golf_booking/l10n/app_localizations.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Golf Booking App',
          theme: themeProvider.isDarkMode ? ThemeProvider.darkTheme : ThemeProvider.lightTheme,
          darkTheme: ThemeProvider.darkTheme,
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          locale: languageProvider.locale,
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('th', 'TH'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
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