import 'package:flutter/material.dart';
import 'package:cimso_golf_booking/screens/dashboard.dart';
import 'package:cimso_golf_booking/screens/create_account.dart';
import 'package:cimso_golf_booking/screens/login.dart';
import 'package:cimso_golf_booking/screens/booking.dart';
import 'package:cimso_golf_booking/screens/splash_screen.dart'; // Import the new splash screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // This hides the debug banner
      title: 'Golf Booking App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      initialRoute: '/', // Changed to root for splash screen
      routes: {
        '/': (context) => const SplashScreen(), // Add splash screen as root route
        '/booking': (context) => const BookingPage(),
        '/login': (context) => const Login(),
        '/create_account': (context) => const CreateAccount(),
        '/dashboard': (context) => const Dashboard(title: 'Dashboard'),
      },
    );
  }
}