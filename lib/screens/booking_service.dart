import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'booking_model.dart';

class BookingService {
  static const String _upcomingBookingsKey = 'upcoming_bookings';
  static const String _pastBookingsKey = 'past_bookings';

  // Singleton pattern
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

  // In-memory cache of bookings
  List<BookingModel> _upcomingBookings = [];
  List<BookingModel> _pastBookings = [];

  // Initialization flag
  bool _initialized = false;

  // Initialize and load bookings from storage
  Future<void> init() async {
    if (_initialized) return;

    await loadBookings();
    _initialized = true;
  }

  // Load bookings from SharedPreferences
  Future<void> loadBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load upcoming bookings
      final upcomingJson = prefs.getStringList(_upcomingBookingsKey) ?? [];
      _upcomingBookings = upcomingJson
          .map((json) => BookingModel.fromJson(jsonDecode(json)))
          .toList();

      // Load past bookings
      final pastJson = prefs.getStringList(_pastBookingsKey) ?? [];
      _pastBookings = pastJson
          .map((json) => BookingModel.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('Error loading bookings: $e');
      // Initialize with empty lists if there's an error
      _upcomingBookings = [];
      _pastBookings = [];
    }
  }

  // Save bookings to SharedPreferences
  Future<void> saveBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save upcoming bookings
      final upcomingJson = _upcomingBookings
          .map((booking) => jsonEncode(booking.toJson()))
          .toList();
      await prefs.setStringList(_upcomingBookingsKey, upcomingJson);

      // Save past bookings
      final pastJson = _pastBookings
          .map((booking) => jsonEncode(booking.toJson()))
          .toList();
      await prefs.setStringList(_pastBookingsKey, pastJson);
    } catch (e) {
      print('Error saving bookings: $e');
    }
  }

  // Get all upcoming bookings
  List<BookingModel> getUpcomingBookings() {
    return List.from(_upcomingBookings);
  }

  // Get all past bookings
  List<BookingModel> getPastBookings() {
    return List.from(_pastBookings);
  }

  // Add a new booking
  Future<void> addBooking(BookingModel booking) async {
    _upcomingBookings.insert(0, booking);
    await saveBookings();
  }

  // Move a booking from upcoming to past
  Future<void> completeBooking(BookingModel booking) async {
    final index = _upcomingBookings.indexWhere(
            (b) => b.courseName == booking.courseName &&
            b.date.isAtSameMomentAs(booking.date) &&
            b.time == booking.time
    );

    if (index != -1) {
      final completedBooking = _upcomingBookings.removeAt(index);
      // Set as completed
      completedBooking.isUpcoming = false;
      _pastBookings.insert(0, completedBooking);
      await saveBookings();
    }
  }

  // Cancel a booking
  Future<void> cancelBooking(BookingModel booking) async {
    final index = _upcomingBookings.indexWhere(
            (b) => b.courseName == booking.courseName &&
            b.date.isAtSameMomentAs(booking.date) &&
            b.time == booking.time
    );

    if (index != -1) {
      _upcomingBookings.removeAt(index);
      await saveBookings();
    }
  }

  // Check if there are any bookings
  bool hasBookings() {
    return _upcomingBookings.isNotEmpty || _pastBookings.isNotEmpty;
  }

  // Add this method to your BookingService class
  Future<void> updateBooking(BookingModel oldBooking, BookingModel updatedBooking) async {
    await init(); // Ensure service is initialized

    // Find the index of the booking to update
    int upcomingIndex = _upcomingBookings.indexWhere(
            (b) => b.courseName == oldBooking.courseName &&
            b.date.isAtSameMomentAs(oldBooking.date) &&
            b.time == oldBooking.time
    );

    int pastIndex = _pastBookings.indexWhere(
            (b) => b.courseName == oldBooking.courseName &&
            b.date.isAtSameMomentAs(oldBooking.date) &&
            b.time == oldBooking.time
    );

    // Update in the appropriate list
    if (upcomingIndex != -1) {
      _upcomingBookings[upcomingIndex] = updatedBooking;
    } else if (pastIndex != -1) {
      _pastBookings[pastIndex] = updatedBooking;
    }

    // Save updated bookings to storage
    await saveBookings();
  }
}


