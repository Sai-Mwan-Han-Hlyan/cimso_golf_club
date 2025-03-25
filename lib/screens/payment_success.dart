import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'notification_manager.dart';
import 'dashboard.dart';
import'booking_model.dart';
import'mybooking.dart';
import'notification.dart';

class PaymentSuccessPage extends StatelessWidget {
  final String course;
  final String time;
  final DateTime date;
  final int players;
  final int carts;
  final double amountPaid;

  const PaymentSuccessPage({
    Key? key,
    required this.course,
    required this.time,
    required this.date,
    required this.players,
    required this.carts,
    required this.amountPaid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        _showNotificationPopup(context);
      });
    });

    return WillPopScope(
      // Prevent going back to payment screen
      onWillPop: () async {
        // Navigate to dashboard instead
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => Dashboard(title: 'Dashboard'),
          ),
              (route) => false,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Payment Successful',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
            onPressed: () {
              // Override back button to go to dashboard
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => Dashboard(title: 'Dashboard'),
                ),
                    (route) => false,
              );
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
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
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green[600],
                      size: 70,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Payment Successful!',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your tee time has been confirmed. See you on the green!',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 36),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          context,
                          Icons.golf_course_rounded,
                          'Course',
                          course,
                        ),
                        const Divider(height: 24),
                        _buildDetailRow(
                          context,
                          Icons.access_time_rounded,
                          'Time',
                          time,
                        ),
                        const Divider(height: 24),
                        _buildDetailRow(
                          context,
                          Icons.calendar_today_rounded,
                          'Date',
                          DateFormat('EEEE, MMMM d, yyyy').format(date),
                        ),
                        const Divider(height: 24),
                        _buildDetailRow(
                          context,
                          Icons.people_alt_rounded,
                          'Players',
                          '$players ${players == 1 ? 'player' : 'players'}',
                        ),
                        const Divider(height: 24),
                        _buildDetailRow(
                          context,
                          Icons.electric_car_rounded,
                          'Carts',
                          '$carts ${carts == 1 ? 'cart' : 'carts'}',
                        ),
                        const Divider(height: 24),
                        _buildDetailRow(
                          context,
                          Icons.payment_rounded,
                          'Amount Paid',
                          '฿ ${amountPaid.toStringAsFixed(2)}',
                          isHighlighted: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Add calendar functionality here
                          },
                          icon: const Icon(Icons.calendar_month_rounded),
                          label: Text(
                            'Add to Calendar',
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.green[700],
                            elevation: 0,
                            side: BorderSide(color: Colors.green[700]!),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Create a booking model from the payment details
                            final newBooking = BookingModel(
                              courseName: course,
                              date: date,
                              time: time,
                              players: players,
                              carts: carts,
                              isUpcoming: true,
                              amountPaid: amountPaid,
                            );

                            // Navigate to the MyBooking page with the new booking
                            // Clear the entire stack so we don't have payment pages in history
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyBooking(newBooking: newBooking),
                              ),
                                  (route) => false, // Remove all previous routes
                            );
                          },
                          icon: const Icon(Icons.check_rounded),
                          label: Text(
                            'Done',
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () {
                      // Add share receipt functionality here
                    },
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: Text(
                      'Share Receipt',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  void _showNotificationPopup(BuildContext context) {
    final newNotification = NotificationModel(
      title: 'Booking Complete!',
      message: 'Your tee time for $course at $time on ${DateFormat('EEEE, MMMM d').format(date)} has been confirmed.',
      icon: Icons.notifications_active,
      timestamp: DateTime.now(),
    );

    NotificationManager.addNotification(newNotification);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(newNotification.title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(newNotification.message, style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close pop-up and view notifications
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationScreen()),
              );
            },
            child: Text('View Notifications', style: GoogleFonts.poppins(color: Colors.green)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close pop-up without viewing notifications
            },
            child: Text('Close', style: GoogleFonts.poppins(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      BuildContext context,
      IconData icon,
      String label,
      String value, {
        bool isHighlighted = false,
      }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.green[700], size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w600,
                  color: isHighlighted ? Colors.green[700] : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
