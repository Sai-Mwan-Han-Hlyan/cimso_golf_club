import 'package:flutter/material.dart';
import 'package:cimso_golf_booking/screens/dashboard.dart';
import 'package:cimso_golf_booking/screens/create_account.dart';
import 'package:cimso_golf_booking/screens/login.dart';
import 'package:cimso_golf_booking/screens/booking.dart';

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
      initialRoute: '/login', // Start at login, change if needed
      routes: {
        '/booking': (context) => const BookingPage(),
        '/login': (context) => const Login(),
        '/create_account': (context) => const CreateAccount(),
        '/dashboard': (context) => const Dashboard(title: 'Dashboard'),
      },
    );
  }
}