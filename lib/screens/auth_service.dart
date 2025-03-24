import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String username;
  final String email;
  final String password;

  User({
    required this.username,
    required this.email,
    required this.password,
  });

  // Convert User object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
    };
  }

  // Create User object from JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      email: json['email'],
      password: json['password'],
    );
  }
}

class AuthService {
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'current_user';

  // Register a new user
  static Future<bool> register(String username, String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing users
      final List<User> users = await getUsers();

      // Check if email already exists
      if (users.any((user) => user.email == email)) {
        return false; // Email already registered
      }

      // Add new user
      users.add(User(
        username: username,
        email: email,
        password: password,
      ));

      // Save updated users list
      final List<String> usersJsonList = users.map((user) => jsonEncode(user.toJson())).toList();
      await prefs.setStringList(_usersKey, usersJsonList);

      // Set current user
      await setCurrentUser(User(
        username: username,
        email: email,
        password: password,
      ));

      return true;
    } catch (e) {
      print('Error registering user: $e');
      return false;
    }
  }

  // Login user
  static Future<bool> login(String email, String password) async {
    try {
      final List<User> users = await getUsers();

      // Find user with matching email and password
      final userIndex = users.indexWhere(
              (user) => user.email == email && user.password == password
      );

      if (userIndex != -1) {
        // User found, set as current user
        await setCurrentUser(users[userIndex]);
        return true;
      }

      return false; // Invalid credentials
    } catch (e) {
      print('Error logging in: $e');
      return false;
    }
  }

  // Logout user
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserKey);
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  // Get current logged in user
  static Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userJson = prefs.getString(_currentUserKey);

      if (userJson == null) {
        return null;
      }

      return User.fromJson(jsonDecode(userJson));
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Set current user
  static Future<void> setCurrentUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
    } catch (e) {
      print('Error setting current user: $e');
    }
  }

  // Get all registered users
  static Future<List<User>> getUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? usersJsonList = prefs.getStringList(_usersKey);

      if (usersJsonList == null || usersJsonList.isEmpty) {
        return [];
      }

      return usersJsonList.map((userJson) =>
          User.fromJson(jsonDecode(userJson))
      ).toList();
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }
}