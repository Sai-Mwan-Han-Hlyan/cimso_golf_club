import 'dart:math';

class BookingModel {
  final String id; // Added unique ID field
  final String courseName;
  final DateTime date;
  final String time;
  final int players;
  final int? carts;
  bool isUpcoming;
  final double? amountPaid;

  BookingModel({
    String? id, // Made ID optional with auto-generation
    required this.courseName,
    required this.date,
    required this.time,
    required this.players,
    this.carts,
    required this.isUpcoming,
    this.amountPaid,
  }) : id = id ?? _generateId(); // Auto-generate ID if not provided

  // Method to generate a unique ID
  static String _generateId() {
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return DateTime.now().millisecondsSinceEpoch.toString() +
        List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
  }

  // Convert BookingModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseName': courseName,
      'date': date.toIso8601String(),
      'time': time,
      'players': players,
      'carts': carts,
      'isUpcoming': isUpcoming,
      'amountPaid': amountPaid,
    };
  }

  // Create BookingModel from JSON map
  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      courseName: json['courseName'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      players: json['players'],
      carts: json['carts'],
      isUpcoming: json['isUpcoming'],
      amountPaid: json['amountPaid'],
    );
  }

  // Create a copy of this booking with modified fields
  BookingModel copyWith({
    String? id,
    String? courseName,
    DateTime? date,
    String? time,
    int? players,
    int? carts,
    bool? isUpcoming,
    double? amountPaid,
  }) {
    return BookingModel(
      id: id ?? this.id,
      courseName: courseName ?? this.courseName,
      date: date ?? this.date,
      time: time ?? this.time,
      players: players ?? this.players,
      carts: carts ?? this.carts,
      isUpcoming: isUpcoming ?? this.isUpcoming,
      amountPaid: amountPaid ?? this.amountPaid,
    );
  }

  // Check if bookings match by core attributes (for finding duplicates)
  bool matchesBooking(BookingModel other) {
    return courseName == other.courseName &&
        date.year == other.date.year &&
        date.month == other.date.month &&
        date.day == other.date.day &&
        time == other.time &&
        players == other.players;
  }

  @override
  String toString() {
    return 'Booking{id: $id, course: $courseName, date: ${date.toIso8601String()}, time: $time}';
  }
}