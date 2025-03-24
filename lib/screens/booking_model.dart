// booking_model.dart
class BookingModel {
  final String courseName;
  final DateTime date;
  final String time;
  final int players;
  final int? carts;
  final bool isUpcoming;
  final double? amountPaid;

  BookingModel({
    required this.courseName,
    required this.date,
    required this.time,
    required this.players,
    this.carts,
    required this.isUpcoming,
    this.amountPaid,
  });
}