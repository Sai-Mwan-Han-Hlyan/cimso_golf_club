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

  // FIXED: Cancel a booking - move from upcoming to past with cancelled status
  Future<void> cancelBooking(BookingModel booking) async {
    // Ensure we're initialized
    await init();

    // Find the booking in upcoming bookings
    final index = _upcomingBookings.indexWhere(
            (b) => b.courseName == booking.courseName &&
            b.date.isAtSameMomentAs(booking.date) &&
            b.time == booking.time
    );

    if (index != -1) {
      // Remove from upcoming bookings
      final cancelledBooking = _upcomingBookings.removeAt(index);

      // Make a clone of the booking with isUpcoming = false
      // We'll set amountPaid to -1.0 as a special indicator that this booking was cancelled
      // This is a workaround since we don't have a dedicated status field
      final pastBooking = BookingModel(
        courseName: cancelledBooking.courseName,
        date: cancelledBooking.date,
        time: cancelledBooking.time,
        players: cancelledBooking.players,
        carts: cancelledBooking.carts,
        isUpcoming: false, // Mark it as not upcoming
        amountPaid: -1.0, // Special value to indicate cancellation
      );

      // Add to past bookings
      _pastBookings.insert(0, pastBooking);

      // Save changes to persistent storage
      await saveBookings();

      print("Booking cancelled and moved to past bookings");
      print("Upcoming bookings count: ${_upcomingBookings.length}");
      print("Past bookings count: ${_pastBookings.length}");
    } else {
      print("Booking not found in upcoming bookings");
    }
  }

  // Check if there are any bookings
  bool hasBookings() {
    return _upcomingBookings.isNotEmpty || _pastBookings.isNotEmpty;
  }

  // Improved updateBooking method with better error handling and logging
  Future<bool> updateBooking(BookingModel oldBooking, BookingModel updatedBooking) async {
    try {
      await init(); // Ensure service is initialized

      // Try to find the booking in upcoming bookings first
      int upcomingIndex = _upcomingBookings.indexWhere(
              (b) => b.courseName == oldBooking.courseName &&
              b.date.isAtSameMomentAs(oldBooking.date) &&
              b.time == oldBooking.time
      );

      if (upcomingIndex != -1) {
        // Found in upcoming bookings
        print("Updating upcoming booking at index $upcomingIndex");
        print("Old date/time: ${oldBooking.date} / ${oldBooking.time}");
        print("New date/time: ${updatedBooking.date} / ${updatedBooking.time}");

        _upcomingBookings[upcomingIndex] = updatedBooking;
        await saveBookings();
        return true;
      }

      // If not found in upcoming, check past bookings
      int pastIndex = _pastBookings.indexWhere(
              (b) => b.courseName == oldBooking.courseName &&
              b.date.isAtSameMomentAs(oldBooking.date) &&
              b.time == oldBooking.time
      );

      if (pastIndex != -1) {
        // Found in past bookings
        print("Updating past booking at index $pastIndex");
        _pastBookings[pastIndex] = updatedBooking;
        await saveBookings();
        return true;
      }

      // If we got here, the booking wasn't found
      print("Booking not found for update. Original date/time: ${oldBooking.date} / ${oldBooking.time}");
      return false;
    } catch (e) {
      print('Error updating booking: $e');
      return false;
    }
  }

  // Find booking by ID (if your BookingModel has an ID)
  // This is useful for finding a booking when the date/time has changed
  Future<BookingModel?> findBookingById(String id) async {
    await init();

    // Try to find in upcoming bookings
    for (var booking in _upcomingBookings) {
      if (booking.id == id) {
        return booking;
      }
    }

    // Try to find in past bookings
    for (var booking in _pastBookings) {
      if (booking.id == id) {
        return booking;
      }
    }

    // Not found
    return null;
  }
}