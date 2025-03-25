import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String username;
  final String email;
  final String password;
  final String? phone;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? profileImagePath; // Store the path to the image file

  User({
    required this.username,
    required this.email,
    required this.password,
    this.phone,
    this.gender,
    this.dateOfBirth,
    this.profileImagePath,
  });

  // Convert User object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'phone': phone,
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'profileImagePath': profileImagePath,
    };
  }

  // Create User object from JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      email: json['email'],
      password: json['password'],
      phone: json['phone'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      profileImagePath: json['profileImagePath'],
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

  // Update user profile
  static Future<bool> updateUserProfile({
    required String email,
    required String name,
    String? phone,
    String? gender,
    DateTime? dateOfBirth,
    File? profileImage,
  }) async {
    try {
      // Get all users
      final List<User> users = await getUsers();
      final prefs = await SharedPreferences.getInstance();

      // Find the user with the matching email
      final userIndex = users.indexWhere((user) => user.email == email);

      if (userIndex == -1) {
        return false; // User not found
      }

      // Get current user data
      final currentUser = users[userIndex];

      // Save profile image if provided
      String? profileImagePath = currentUser.profileImagePath;
      if (profileImage != null) {
        profileImagePath = await _saveProfileImage(email, profileImage);
      }

      // Create updated user object
      final updatedUser = User(
        username: name,
        email: email,
        password: currentUser.password,
        phone: phone,
        gender: gender,
        dateOfBirth: dateOfBirth,
        profileImagePath: profileImagePath,
      );

      // Update user in the list
      users[userIndex] = updatedUser;

      // Save updated users list
      final List<String> usersJsonList = users.map((user) => jsonEncode(user.toJson())).toList();
      await prefs.setStringList(_usersKey, usersJsonList);

      // If this is the current user, update current user as well
      final currentUserData = await getCurrentUser();
      if (currentUserData != null && currentUserData.email == email) {
        await setCurrentUser(updatedUser);
      }

      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  // Helper method to save profile image
  static Future<String> _saveProfileImage(String email, File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final fileName = 'profile_${email.replaceAll('@', '_at_')}.jpg';
      final savedImage = await imageFile.copy('$path/$fileName');
      return savedImage.path;
    } catch (e) {
      print('Error saving profile image: $e');
      throw e;
    }
  }

  // Load profile image from path
  static Future<File?> loadProfileImage(String? path) async {
    if (path == null) return null;

    final file = File(path);
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  static Future<bool> resetPassword(String email) async {
    try {
      final List<User> users = await getUsers();

      // Find user with matching email
      final userIndex = users.indexWhere((user) => user.email == email);

      if (userIndex == -1) {
        return false; // Email not found
      }

      // In a real app, you would send an email with a reset link here
      // For this implementation, we'll simulate a successful email send

      // Simulate a delay for the "email sending" process
      await Future.delayed(const Duration(seconds: 1));

      return true;
    } catch (e) {
      print('Error resetting password: $e');
      return false;
    }
  }
}