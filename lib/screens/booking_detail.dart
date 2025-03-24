import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math'; // For calculating time difference
import 'booking_model.dart';
import 'booking_service.dart';
import 'payment.dart'; // Assuming there is a payment page

class BookingDetailPage extends StatefulWidget {
  final BookingModel booking;
  final bool fromPaymentSuccess; // Flag to indicate if coming from payment success

  const BookingDetailPage({
    Key? key,
    required this.booking,
    this.fromPaymentSuccess = false,
  }) : super(key: key);

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  final BookingService _bookingService = BookingService();

  // Colors
  final Color accentColor = const Color(0xFF4CAF50);
  final Color backgroundColor = Colors.white;
  final Color surfaceColor = const Color(0xFFF9F9F9);
  final Color textColor = Colors.black87;
  final Color secondaryTextColor = Colors.black54;
  final Color errorColor = Colors.red;
  final Color warningColor = Colors.orange;

  // State variables
  late bool _isPaid;
  late bool _canCancel;
  late bool _requiresAdvancePayment;

  @override
  void initState() {
    super.initState();
    _initializeBookingState();
  }

  void _initializeBookingState() {
    // Check if booking is paid based on amountPaid or fromPaymentSuccess flag
    _isPaid = widget.booking.amountPaid != null || widget.fromPaymentSuccess;

    // Determine if booking can be cancelled (more than 24 hours before tee time)
    final now = DateTime.now();
    final bookingDateTime = _combineDateTime(widget.booking.date, widget.booking.time);
    final difference = bookingDateTime.difference(now);
    _canCancel = difference.inHours > 24;

    // Determine if advance payment is required (unpaid booking)
    _requiresAdvancePayment = !_isPaid;
  }

  // Helper to combine date and time string into DateTime
  DateTime _combineDateTime(DateTime date, String timeString) {
    // Parse the time string (assuming format like "10:30 AM")
    final timeParts = timeString.split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1].split(' ')[0]);
    final isPM = timeString.toLowerCase().contains('pm');

    if (isPM && hour < 12) hour += 12;
    if (!isPM && hour == 12) hour = 0;

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  @override
  Widget build(BuildContext context) {
    final bool isUpcoming = widget.booking.isUpcoming;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'Booking Details',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          color: textColor,
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (isUpcoming)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: textColor),
              onSelected: (value) {
                if (value == 'cancel') {
                  _isPaid ? _showRefundDialog(context) : _showCancelDialog(context);
                } else if (value == 'reschedule') {
                  _showRescheduleDialog();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'reschedule',
                  child: Text('Reschedule'),
                ),
                PopupMenuItem<String>(
                  value: 'cancel',
                  child: Text(
                      _isPaid ? 'Request Refund' : 'Cancel Booking',
                      style: TextStyle(color: errorColor)
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              color: _getStatusBannerColor(),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(),
                    color: _getStatusIconColor(),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _getStatusText(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: _getStatusIconColor(),
                    ),
                  ),
                ],
              ),
            ),

            // Course header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.booking.courseName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: secondaryTextColor),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat("EEEE, MMMM d, yyyy").format(widget.booking.date),
                        style: TextStyle(
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: secondaryTextColor),
                      const SizedBox(width: 8),
                      Text(
                        widget.booking.time,
                        style: TextStyle(
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Booking details
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildDetailItem('Players', '${widget.booking.players} ${widget.booking.players == 1 ? 'Player' : 'Players'}'),

                  if (widget.booking.carts != null)
                    _buildDetailItem('Carts', '${widget.booking.carts} ${widget.booking.carts == 1 ? 'Cart' : 'Carts'}'),

                  if (widget.booking.amountPaid != null)
                    _buildDetailItem(
                      'Amount Paid',
                      '฿ ${widget.booking.amountPaid!.toStringAsFixed(2)}',
                      highlight: true,
                    ),

                  if (_isPaid)
                    _buildDetailItem(
                      'Payment Status',
                      'Paid',
                      highlight: true,
                    )
                  else
                    _buildDetailItem(
                      'Payment Status',
                      'Unpaid',
                      highlight: false,
                      warningColor: true,
                    ),

                  const SizedBox(height: 8),

                  _buildDetailItem(
                    'Booking Status',
                    isUpcoming ? 'Confirmed' : 'Completed',
                    highlight: isUpcoming,
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Payment reminder for unpaid bookings
            if (isUpcoming && !_isPaid)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: warningColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: warningColor),
                          const SizedBox(width: 8),
                          Text(
                            'Payment Required',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: warningColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please complete payment at least 20 minutes before your tee time. You can pay now or at the reception desk.',
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Additional info
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Additional Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Please arrive at least 15 minutes before your tee time. Check-in at the pro shop upon arrival.',
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryTextColor,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Cancellations less than 24 hours before tee time may be subject to a cancellation fee.',
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryTextColor,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Actions for upcoming bookings
            if (isUpcoming)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // Add to calendar functionality here
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Add to Calendar'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: accentColor,
                        backgroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: accentColor),
                        ),
                      ),
                    ),

                    if (!_isPaid) ...[
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => _navigateToPayment(),
                        icon: const Icon(Icons.payment),
                        label: const Text('Complete Payment'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: accentColor,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => _showRescheduleDialog(),
                      icon: const Icon(Icons.edit_calendar),
                      label: const Text('Reschedule'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: accentColor,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: _canCancel
                          ? () => _isPaid
                          ? _showRefundDialog(context)
                          : _showCancelDialog(context)
                          : null,
                      icon: Icon(_isPaid ? Icons.money : Icons.cancel_outlined,
                          color: _canCancel ? errorColor : Colors.grey),
                      label: Text(
                        _isPaid ? 'Request Refund' : 'Cancel Booking',
                        style: TextStyle(
                          color: _canCancel ? errorColor : Colors.grey,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),

                    if (!_canCancel)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Cancellation is only available more than 24 hours before tee time',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryTextColor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Helper methods for status styling
  Color _getStatusBannerColor() {
    if (!widget.booking.isUpcoming) return surfaceColor;
    if (!_isPaid) return warningColor.withOpacity(0.1);
    return accentColor.withOpacity(0.1);
  }

  IconData _getStatusIcon() {
    if (!widget.booking.isUpcoming) return Icons.event_busy;
    if (!_isPaid) return Icons.pending_actions;
    return Icons.event_available;
  }

  Color _getStatusIconColor() {
    if (!widget.booking.isUpcoming) return secondaryTextColor;
    if (!_isPaid) return warningColor;
    return accentColor;
  }

  String _getStatusText() {
    if (!widget.booking.isUpcoming) return 'Past Booking';
    if (!_isPaid) return 'Payment Required';
    return 'Confirmed Booking';
  }

  Widget _buildDetailItem(String label, String value, {bool highlight = false, bool warningColor = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: secondaryTextColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: highlight || warningColor ? FontWeight.w600 : FontWeight.w400,
              color: warningColor
                  ? this.warningColor
                  : (highlight ? accentColor : textColor),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPayment() {
    // Navigate to payment page with booking details
    // This is a placeholder - you would need to implement the actual payment page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          booking: widget.booking,
          onPaymentComplete: (amountPaid) async {
            // Create a new booking with payment info and update in service
            final updatedBooking = BookingModel(
              courseName: widget.booking.courseName,
              date: widget.booking.date,
              time: widget.booking.time,
              players: widget.booking.players,
              carts: widget.booking.carts,
              isUpcoming: widget.booking.isUpcoming,
              amountPaid: amountPaid,
            );

            // Update the booking in the service
            await _bookingService.updateBooking(widget.booking, updatedBooking);

            // Update state to reflect payment
            setState(() {
              _isPaid = true;
            });
          },
        ),
      ),
    );
  }

  void _showRescheduleDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Reschedule functionality coming soon'),
        backgroundColor: accentColor,
      ),
    );
  }

  Future<void> _showCancelDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _bookingService.cancelBooking(widget.booking);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled successfully'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate booking was cancelled
      }
    }
  }

  Future<void> _showRefundDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Refund'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to cancel this booking and request a refund?'),
            const SizedBox(height: 16),
            Text(
              'Amount to be refunded: ฿ ${widget.booking.amountPaid?.toStringAsFixed(2) ?? "0.00"}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Note: Refund processing may take 3-5 business days.',
              style: TextStyle(
                fontSize: 12,
                color: secondaryTextColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes, Refund', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _bookingService.cancelBooking(widget.booking);

      if (mounted) {
        // Show refund confirmation dialog
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: accentColor),
                const SizedBox(width: 8),
                const Text('Refund Initiated'),
              ],
            ),
            content: const Text(
              'Your refund request has been processed. The booking has been cancelled, and your refund will be processed within 3-5 business days.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK', style: TextStyle(color: accentColor)),
              ),
            ],
          ),
        );

        Navigator.pop(context, true); // Return true to indicate booking was cancelled
      }
    }
  }
}

// Placeholder for the PaymentPage class
class PaymentPage extends StatelessWidget {
  final BookingModel booking;
  final Function(double) onPaymentComplete;

  const PaymentPage({
    Key? key,
    required this.booking,
    required this.onPaymentComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate the amount to pay based on players and carts
    // This is a placeholder - you would implement actual payment logic
    final double baseRate = 1500.0; // Example base rate per player
    final double cartRate = 500.0; // Example rate per cart
    final double totalAmount = (baseRate * booking.players) +
        ((booking.carts ?? 0) * cartRate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Total Amount: ฿${totalAmount.toStringAsFixed(2)}'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // This is where you would implement the actual payment processing
                // For now, we'll just simulate a successful payment
                onPaymentComplete(totalAmount);

                // Show success and navigate back
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment completed successfully!'))
                );
                Navigator.pop(context);
              },
              child: const Text('Process Payment'),
            ),
          ],
        ),
      ),
    );
  }
}