class BookingModel {
  final String courseName;
  final DateTime date;
  final String time;
  final int players;
  final int? carts;
  bool isUpcoming;
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

  // Convert BookingModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
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
      courseName: json['courseName'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      players: json['players'],
      carts: json['carts'],
      isUpcoming: json['isUpcoming'],
      amountPaid: json['amountPaid'],
    );
  }
}