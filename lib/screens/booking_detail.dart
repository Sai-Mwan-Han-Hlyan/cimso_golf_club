import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math'; // For calculating time difference
import 'booking_model.dart';
import 'booking_service.dart';
import 'payment.dart'; // Your existing payment page
import 'payment_success.dart'; // Your existing payment success page
import 'reschedule.dart'; // The reschedule page

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

    // If coming from payment success, update the booking
    if (widget.fromPaymentSuccess) {
      _updateBookingAfterPayment();
    }
  }

  // Method to update booking after payment success
  Future<void> _updateBookingAfterPayment() async {
    // Create a new booking with payment info
    final updatedBooking = BookingModel(
      courseName: widget.booking.courseName,
      date: widget.booking.date,
      time: widget.booking.time,
      players: widget.booking.players,
      carts: widget.booking.carts,
      isUpcoming: widget.booking.isUpcoming,
      amountPaid: widget.booking.amountPaid, // This should be set by the payment success page
    );

    // Update the booking in the service
    await _bookingService.updateBooking(widget.booking, updatedBooking);

    // Update state to reflect payment
    setState(() {
      _isPaid = true;
    });
  }

  void _initializeBookingState() {
    // Check if booking is cancelled (using our special indicator)
    final bool isCancelled = widget.booking.amountPaid == -1.0;

    // Check if booking is paid based on amountPaid or fromPaymentSuccess flag
    // For cancelled bookings, we'll consider them "paid" so they don't show payment buttons
    _isPaid = widget.booking.amountPaid != null || widget.fromPaymentSuccess || isCancelled;

    // Determine if booking can be cancelled (more than 24 hours before tee time)
    // For cancelled bookings, this should always be false
    if (isCancelled) {
      _canCancel = false;
    } else {
      final now = DateTime.now();
      final bookingDateTime = _combineDateTime(widget.booking.date, widget.booking.time);
      final difference = bookingDateTime.difference(now);
      _canCancel = difference.inHours > 24;
    }

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

  // Add a new helper method to check if the booking is cancelled
  bool _isBookingCancelled() {
    return widget.booking.amountPaid == -1.0;
  }

  // Fixed _buildDetailItem method without recursive calls
  Widget _buildDetailItem(String label, String value, {bool highlight = false, bool warningColor = false, bool isCancelled = false}) {
    // If this is a cancelled booking and we're displaying status
    if (_isBookingCancelled() && (label == 'Payment Status' || label == 'Booking Status')) {
      value = 'Cancelled';
      highlight = true;
      isCancelled = true;
    }

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
              fontWeight: highlight || warningColor || isCancelled ? FontWeight.w600 : FontWeight.w400,
              color: isCancelled
                  ? Colors.red  // Red color for cancelled status
                  : (warningColor
                  ? this.warningColor
                  : (highlight ? accentColor : textColor)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isUpcoming = widget.booking.isUpcoming;
    final bool isCancelled = _isBookingCancelled();

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
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              color: isCancelled ? Colors.red.withOpacity(0.1) : _getStatusBannerColor(),
              child: Row(
                children: [
                  Icon(
                    isCancelled ? Icons.cancel : _getStatusIcon(),
                    color: isCancelled ? Colors.red : _getStatusIconColor(),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isCancelled ? 'Cancelled Booking' : _getStatusText(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isCancelled ? Colors.red : _getStatusIconColor(),
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

                  if (widget.booking.amountPaid != null && widget.booking.amountPaid != -1.0)
                    _buildDetailItem(
                      'Amount Paid',
                      '฿ ${widget.booking.amountPaid!.toStringAsFixed(2)}',
                      highlight: true,
                    ),

                  // Payment Status - with special handling for cancelled bookings
                  _buildDetailItem(
                    'Payment Status',
                    isCancelled ? 'Cancelled' : (_isPaid ? 'Paid' : 'Unpaid'),
                    highlight: _isPaid,
                    warningColor: !_isPaid && !isCancelled,
                    isCancelled: isCancelled,
                  ),

                  const SizedBox(height: 8),

                  // Booking Status - with special handling for cancelled bookings
                  _buildDetailItem(
                    'Booking Status',
                    isCancelled ? 'Cancelled' : (isUpcoming ? 'Confirmed' : 'Completed'),
                    highlight: isUpcoming && !isCancelled,
                    isCancelled: isCancelled,
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Payment reminder for unpaid bookings (not shown for cancelled bookings)
            if (isUpcoming && !_isPaid && !isCancelled)
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

            // Actions for upcoming bookings - not shown for cancelled bookings
            if (isUpcoming && !isCancelled)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    if (!_isPaid) ...[
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
                      const SizedBox(height: 12),
                    ],

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
                      // Always allow interaction, handle conditions inside the handler
                      onPressed: () {
                        if (_isPaid) {
                          // Handle refund request
                          if (_canCancel) {
                            _showRefundDialog(context);
                          } else {
                            // Show explanation for late refund
                            _showLateCancellationDialog(
                                'Refund Not Available',
                                'Refunds are only available more than 24 hours before your tee time. Please contact customer service for assistance.'
                            );
                          }
                        } else {
                          // Handle booking cancellation
                          if (_canCancel) {
                            _showCancelDialog(context);
                          } else {
                            // Show explanation for late cancellation
                            _showLateCancellationDialog(
                                'Late Cancellation',
                                'Cancellations less than 24 hours before tee time may be subject to a cancellation fee. Do you wish to proceed?',
                                showProceedButton: true,
                                onProceed: () => _showCancelDialog(context)
                            );
                          }
                        }
                      },
                      icon: Icon(
                        _isPaid ? Icons.money : Icons.cancel_outlined,
                        color: _isPaid ? errorColor : Colors.red[700],
                      ),
                      label: Text(
                        _isPaid ? 'Request Refund' : 'Cancel Booking',
                        style: TextStyle(
                          color: _isPaid ? errorColor : Colors.red[700],
                        ),
                      ),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),

            // For cancelled bookings, show cancellation message
            if (isCancelled)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            'Booking Cancelled',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This booking has been cancelled and is no longer valid.',
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

  void _navigateToPayment() {
    // Navigate to payment page with booking details
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          course: widget.booking.courseName,
          date: widget.booking.date,
          time: widget.booking.time,
          players: widget.booking.players,
          carts: widget.booking.carts ?? 0,
        ),
      ),
    );
  }

  void _showRescheduleDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReschedulePage(
          booking: widget.booking,
          onRescheduleComplete: (updatedBooking) async {
            // Update state with the new booking information
            setState(() {
              // Update any necessary state variables
              _initializeBookingState();
            });

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Booking successfully rescheduled'),
                backgroundColor: accentColor,
              ),
            );
          },
        ),
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
      try {
        // Use the updated cancelBooking method which moves the booking to past bookings
        await _bookingService.cancelBooking(widget.booking);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking cancelled successfully'),
              backgroundColor: Colors.red,
            ),
          );

          // Return to previous screen with refresh signal and indication to switch tabs
          Navigator.pop(context, {
            'refreshBookings': true,
            'bookingCancelled': true,
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error cancelling booking: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
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
      try {
        // Use the updated cancelBooking method which moves the booking to past bookings
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

          // Return to previous screen with refresh signal and indication to switch tabs
          Navigator.pop(context, {
            'refreshBookings': true,
            'bookingCancelled': true,
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error processing refund: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showLateCancellationDialog(String title, String message, {bool showProceedButton = false, Function? onProceed}) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (showProceedButton && onProceed != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onProceed();
              },
              child: const Text('Proceed Anyway', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }
}