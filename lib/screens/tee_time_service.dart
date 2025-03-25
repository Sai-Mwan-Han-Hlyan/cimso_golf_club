import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'booking_model.dart';

class TeeTimeService {
  // Singleton pattern
  static final TeeTimeService _instance = TeeTimeService._internal();
  factory TeeTimeService() => _instance;
  TeeTimeService._internal();

  // Key for storing booked tee times
  static const String _bookedTimesKey = 'booked_tee_times';

  // In-memory cache of booked times
  // Format: Map<String, Map<String, List<String>>>
  // {date: {course: [time1, time2, ...]}}
  Map<String, Map<String, List<String>>> _bookedTimes = {};

  // Initialization flag
  bool _initialized = false;

  // Initialize and load booked times
  Future<void> init() async {
    if (_initialized) return;

    await loadBookedTimes();
    _initialized = true;
  }

  // Format date to string key
  String _formatDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Load booked times from SharedPreferences
  Future<void> loadBookedTimes() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final jsonString = prefs.getString(_bookedTimesKey);
      if (jsonString != null) {
        final jsonData = jsonDecode(jsonString);

        // Convert JSON back to our data structure
        _bookedTimes = {};
        jsonData.forEach((date, courses) {
          _bookedTimes[date] = {};
          courses.forEach((course, times) {
            _bookedTimes[date]![course] = List<String>.from(times);
          });
        });
      } else {
        _bookedTimes = {};
      }
    } catch (e) {
      print('Error loading booked tee times: $e');
      _bookedTimes = {};
    }
  }

  // Save booked times to SharedPreferences
  Future<void> saveBookedTimes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_bookedTimes);
      await prefs.setString(_bookedTimesKey, jsonString);
    } catch (e) {
      print('Error saving booked tee times: $e');
    }
  }

  // Book a tee time
  Future<void> bookTeeTime(DateTime date, String course, String time) async {
    await init(); // Ensure service is initialized

    final dateKey = _formatDateKey(date);

    // Initialize nested maps if they don't exist
    _bookedTimes[dateKey] ??= {};
    _bookedTimes[dateKey]![course] ??= [];

    // Add the time if not already booked
    if (!_bookedTimes[dateKey]![course]!.contains(time)) {
      _bookedTimes[dateKey]![course]!.add(time);
      await saveBookedTimes();
    }
  }

  // Cancel a tee time booking
  Future<void> cancelTeeTime(DateTime date, String course, String time) async {
    await init(); // Ensure service is initialized

    final dateKey = _formatDateKey(date);

    // Remove the time if it exists
    if (_bookedTimes.containsKey(dateKey) &&
        _bookedTimes[dateKey]!.containsKey(course) &&
        _bookedTimes[dateKey]![course]!.contains(time)) {

      _bookedTimes[dateKey]![course]!.remove(time);

      // Clean up empty entries
      if (_bookedTimes[dateKey]![course]!.isEmpty) {
        _bookedTimes[dateKey]!.remove(course);

        if (_bookedTimes[dateKey]!.isEmpty) {
          _bookedTimes.remove(dateKey);
        }
      }

      await saveBookedTimes();
    }
  }

  // Update a booking's tee time
  Future<void> updateTeeTime(
      DateTime oldDate, String oldCourse, String oldTime,
      DateTime newDate, String newCourse, String newTime
      ) async {
    await init(); // Ensure service is initialized

    // Only proceed if the times are actually different
    if (oldDate == newDate && oldCourse == newCourse && oldTime == newTime) {
      return;
    }

    // Cancel the old booking and book the new time
    await cancelTeeTime(oldDate, oldCourse, oldTime);
    await bookTeeTime(newDate, newCourse, newTime);
  }

  // Get available tee times for a specific date and course
  List<String> getAvailableTimes(
      DateTime date,
      String course,
      List<String> allTimes
      ) {
    final dateKey = _formatDateKey(date);

    // If no bookings for this date or course, all times are available
    if (!_bookedTimes.containsKey(dateKey) ||
        !_bookedTimes[dateKey]!.containsKey(course)) {
      return List.from(allTimes);
    }

    // Filter out booked times
    final bookedTimes = _bookedTimes[dateKey]![course]!;
    return allTimes.where((time) => !bookedTimes.contains(time)).toList();
  }

  // Check if a specific time is available
  bool isTimeAvailable(DateTime date, String course, String time) {
    final dateKey = _formatDateKey(date);

    // If no bookings for this date or course, the time is available
    if (!_bookedTimes.containsKey(dateKey) ||
        !_bookedTimes[dateKey]!.containsKey(course)) {
      return true;
    }

    // Check if the time is booked
    return !_bookedTimes[dateKey]![course]!.contains(time);
  }
}