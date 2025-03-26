import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'booking_model.dart';
import 'booking_service.dart';
import 'package:cimso_golf_booking/providers/theme_provider.dart';

class ReschedulePage extends StatefulWidget {
  final BookingModel booking;
  final Function(BookingModel) onRescheduleComplete;

  const ReschedulePage({
    Key? key,
    required this.booking,
    required this.onRescheduleComplete,
  }) : super(key: key);

  @override
  _ReschedulePageState createState() => _ReschedulePageState();
}

class _ReschedulePageState extends State<ReschedulePage> {
  final BookingService _bookingService = BookingService();
  late DateTime _selectedDate;
  late String _selectedTime;
  bool _isLoading = false;

  // Available time slots (these would typically come from an API)
  final List<String> _availableTimes = [
    '07:00 AM',
    '07:30 AM',
    '08:00 AM',
    '08:30 AM',
    '09:00 AM',
    '09:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '12:00 PM',
    '12:30 PM',
    '01:00 PM',
    '01:30 PM',
    '02:00 PM',
    '02:30 PM',
    '03:00 PM',
    '03:30 PM',
    '04:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.booking.date;
    _selectedTime = widget.booking.time;
  }

  @override
  Widget build(BuildContext context) {
    // Get theme information
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Define theme-aware colors
    final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final Color textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;
    final Color secondaryTextColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black54;
    final Color accentColor = Theme.of(context).colorScheme.primary;
    final Color surfaceColor = isDark ? Colors.grey[800]! : const Color(0xFFF9F9F9);
    final Color cardColor = isDark ? Color(0xFF1E1E1E) : Colors.white;
    final Color borderColor = isDark ? Colors.grey[700]! : Colors.grey.shade300;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'Reschedule Booking',
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: accentColor))
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current booking info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(8),
                  border: isDark ? Border.all(color: borderColor) : null,
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
                        Icon(Icons.golf_course, size: 16, color: secondaryTextColor),
                        const SizedBox(width: 8),
                        Text(
                          widget.booking.courseName,
                          style: TextStyle(
                            fontSize: 14,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: secondaryTextColor),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat("EEEE, MMMM d, yyyy").format(widget.booking.date),
                          style: TextStyle(
                            fontSize: 14,
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
                            fontSize: 14,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Select new date
              Text(
                'Select New Date',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _selectDate(context, accentColor, textColor),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat("EEEE, MMMM d, yyyy").format(_selectedDate),
                        style: TextStyle(
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                      Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: accentColor,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Select new time
              Text(
                'Select New Time',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _availableTimes.length,
                itemBuilder: (context, index) {
                  final time = _availableTimes[index];
                  final isSelected = time == _selectedTime;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTime = time;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? accentColor : surfaceColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? accentColor : borderColor,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          time,
                          style: TextStyle(
                            color: isSelected ? Colors.white : textColor,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _saveReschedule(),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, Color accentColor, Color textColor) async {
    // Get today's date for the minimum selectable date
    final DateTime now = DateTime.now();

    // Calculate the maximum selectable date (e.g., 30 days from now)
    final DateTime maxDate = now.add(const Duration(days: 30));

    // Get theme information for the date picker
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now,
      lastDate: maxDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: accentColor,
              onPrimary: Colors.white,
              onSurface: textColor,
            ),
            dialogBackgroundColor: isDark ? Color(0xFF1E1E1E) : Colors.white,
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

  Future<void> _saveReschedule() async {
    // Check if anything has changed
    if (_selectedDate == widget.booking.date && _selectedTime == widget.booking.time) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No changes were made to the booking.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create a new booking with the updated date and time
      final updatedBooking = BookingModel(
        courseName: widget.booking.courseName,
        date: _selectedDate,
        time: _selectedTime,
        players: widget.booking.players,
        carts: widget.booking.carts,
        isUpcoming: widget.booking.isUpcoming,
        amountPaid: widget.booking.amountPaid,
      );

      // Update the booking in the service
      final success = await _bookingService.updateBooking(widget.booking, updatedBooking);

      if (success) {
        // Call the callback function to inform the parent about the successful reschedule
        widget.onRescheduleComplete(updatedBooking);

        // Return to the previous screen with the updated booking information
        Navigator.pop(context, {
          'updatedBooking': updatedBooking,
        });
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to reschedule the booking. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}