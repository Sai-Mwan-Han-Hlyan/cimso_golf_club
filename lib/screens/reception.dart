import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'booking_model.dart';
import 'mybooking.dart';

class ReceptionPage extends StatelessWidget {
  final String course;
  final String time;
  final DateTime date;
  final int players;
  final int carts;

  const ReceptionPage({
    Key? key,
    required this.course,
    required this.time,
    required this.date,
    required this.players,
    required this.carts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Confirmation',
          style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_circle_rounded, color: Colors.green[700], size: 70),
                ),
                const SizedBox(height: 24),
                Text(
                  'Booking Confirmed',
                  style: GoogleFonts.urbanist(fontSize: 24, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your tee time has been successfully booked',
                  style: GoogleFonts.urbanist(
                    fontSize: 15,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        spreadRadius: 0,
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.withOpacity(0.08)),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(context, 'Course', course),
                      const Divider(height: 24),
                      _buildDetailRow(context, 'Date', DateFormat('EEEE, MMM d, yyyy').format(date)),
                      const Divider(height: 24),
                      _buildDetailRow(context, 'Time', time),
                      const Divider(height: 24),
                      _buildDetailRow(context, 'Players', '$players'),
                      const Divider(height: 24),
                      _buildDetailRow(context, 'Carts', '$carts'),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Done button that creates a booking and navigates to MyBooking
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Create a booking model from the reception details
                      final newBooking = BookingModel(
                        courseName: course,
                        date: date,
                        time: time,
                        players: players,
                        carts: carts,
                        isUpcoming: true,
                      );

                      // Navigate to MyBooking and pass the new booking
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyBooking(newBooking: newBooking),
                        ),
                            (route) => route.isFirst, // Keep only the first route (Dashboard)
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Done',
                      style: GoogleFonts.urbanist(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.urbanist(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.urbanist(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}