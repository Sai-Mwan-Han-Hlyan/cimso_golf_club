import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'booking_model.dart';
import 'booking_service.dart';

class ReschedulePage extends StatefulWidget {
  final BookingModel booking;
  final Function(BookingModel) onRescheduleComplete;

  const ReschedulePage({
    Key? key,
    required this.booking,
    required this.onRescheduleComplete,
  }) : super(key: key);

  @override
  State<ReschedulePage> createState() => _ReschedulePageState();
}

class _ReschedulePageState extends State<ReschedulePage> {
  final BookingService _bookingService = BookingService();

  // State variables
  DateTime _selectedDate = DateTime.now();
  String _selectedTime = "10:00 AM";

  // Golf course available times (example)
  final List<String> _availableTimes = [
    "07:00 AM", "07:30 AM", "08:00 AM", "08:30 AM",
    "09:00 AM", "09:30 AM", "10:00 AM", "10:30 AM",
    "11:00 AM", "11:30 AM", "12:00 PM", "12:30 PM",
    "01:00 PM", "01:30 PM", "02:00 PM", "02:30 PM",
    "03:00 PM", "03:30 PM", "04:00 PM"
  ];

  @override
  void initState() {
    super.initState();
    // Initialize to current booking date + 1 day as default selection
    _selectedDate = widget.booking.date.add(const Duration(days: 1));
  }

  @override
  Widget build(BuildContext context) {
    final Color accentColor = const Color(0xFF4CAF50);
    final Color textColor = Colors.black87;
    final Color secondaryTextColor = Colors.black54;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Reschedule Booking',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          color: textColor,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current booking info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Booking',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: secondaryTextColor),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat("EEEE, MMMM d, yyyy").format(widget.booking.date),
                        style: TextStyle(color: textColor),
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
                        style: TextStyle(color: textColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // New date selection
            Text(
              'Select New Date',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onTap: () => _selectDate(context),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat("EEEE, MMMM d, yyyy").format(_selectedDate),
                        style: TextStyle(color: textColor),
                      ),
                      Icon(Icons.calendar_today, color: accentColor),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // New time selection
            Text(
              'Select New Time',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _availableTimes.length,
                itemBuilder: (context, index) {
                  final time = _availableTimes[index];
                  final isSelected = time == _selectedTime;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedTime = time;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? accentColor.withOpacity(0.1) : null,
                        borderRadius: BorderRadius.circular(4),
                        border: isSelected
                            ? Border.all(color: accentColor)
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: isSelected ? accentColor : secondaryTextColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            time,
                            style: TextStyle(
                              color: isSelected ? accentColor : textColor,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                          const Spacer(),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: accentColor,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            // Important notes
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        'Important Notes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Rescheduling is free if done 24 hours before tee time\n• A fee may apply for last-minute changes\n• Your payment status will remain the same',
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Confirm button
            ElevatedButton(
              onPressed: () => _confirmReschedule(),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: accentColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Confirm Reschedule'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    // Calculate date limits
    final DateTime now = DateTime.now();
    final DateTime minDate = now;
    final DateTime maxDate = now.add(const Duration(days: 90)); // 3 months ahead

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isAfter(minDate) ? _selectedDate : minDate,
      firstDate: minDate,
      lastDate: maxDate,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4CAF50), // accent color
              onPrimary: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4CAF50),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _confirmReschedule() async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Create updated booking
      final updatedBooking = BookingModel(
        courseName: widget.booking.courseName,
        date: _selectedDate,
        time: _selectedTime,
        players: widget.booking.players,
        carts: widget.booking.carts,
        isUpcoming: true,
        amountPaid: widget.booking.amountPaid,
      );

      // Update booking in service
      await _bookingService.updateBooking(widget.booking, updatedBooking);

      // Remove loading indicator
      if (context.mounted) Navigator.pop(context);

      // Show success dialog
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: const Color(0xFF4CAF50)),
                const SizedBox(width: 8),
                const Text('Booking Rescheduled'),
              ],
            ),
            content: const Text(
              'Your booking has been successfully rescheduled. You will receive a confirmation email shortly.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Return to booking details with updated booking
                  widget.onRescheduleComplete(updatedBooking);
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Remove loading indicator
      if (context.mounted) Navigator.pop(context);

      // Show error dialog
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 8),
                const Text('Error'),
              ],
            ),
            content: Text(
              'Failed to reschedule booking: ${e.toString()}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
}