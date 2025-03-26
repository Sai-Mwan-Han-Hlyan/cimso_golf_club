import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'booking_model.dart';
import 'booking_service.dart';
import 'package:cimso_golf_booking/providers/theme_provider.dart';
import 'package:google_fonts/google_fonts.dart'; // Added for consistency with BookingPage

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
  late String _selectedCourse;

  // Available time slots based on course type
  final List<String> availableTimes9H = [
    '11:00 AM', '11:45 AM', '1:30 PM', '2:15 PM', '3:30 PM', '4:15 PM'
  ];

  final List<String> availableTimes18H = [
    '8:00 AM', '9:30 AM', '11:00 AM', '12:30 PM', '2:00 PM', '3:30 PM', '5:00 PM'
  ];

  List<String> _availableTimes = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.booking.date;
    _selectedTime = widget.booking.time;
    _selectedCourse = widget.booking.courseName;
    _updateAvailableTimes();
  }

  void _updateAvailableTimes() {
    setState(() {
      _availableTimes = _selectedCourse.contains('9H') ? availableTimes9H : availableTimes18H;
    });
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

              // New time selection UI based on BookingPage
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                      spreadRadius: isDark ? 1 : 0,
                    )
                  ],
                  border: isDark ? Border.all(color: borderColor) : null,
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.access_time, color: accentColor, size: 16),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('EEEE, MMMM d').format(_selectedDate),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_availableTimes.length} available',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _availableTimes.map((time) {
                        final isSelected = time == _selectedTime;
                        final timeOfDay = _getTimeOfDay(time);
                        final isEarlyMorning = timeOfDay == 'Morning' && time.contains('AM') && !time.contains('11');
                        final isEvening = timeOfDay == 'Evening';

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedTime = time;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? accentColor
                                  : isDark
                                  ? Colors.grey[800]
                                  : Colors.grey.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: isSelected ? [
                                BoxShadow(
                                  color: accentColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ] : null,
                              border: isSelected
                                  ? null
                                  : Border.all(
                                color: isDark ? Colors.grey[700]! : Colors.grey.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  time,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    color: isSelected ? Colors.white : textColor,
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // Tag indicating time of day
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withOpacity(0.2)
                                        : _getTimeOfDayColor(timeOfDay, isDark),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    timeOfDay,
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : _getTimeOfDayTextColor(timeOfDay),
                                    ),
                                  ),
                                ),

                                if (isEarlyMorning && !isSelected)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 10,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          'Early bird',
                                          style: GoogleFonts.poppins(
                                            fontSize: 9,
                                            color: Colors.amber,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                if (isEvening && !isSelected)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.wb_twilight,
                                          color: Colors.orangeAccent,
                                          size: 10,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          'Sunset',
                                          style: GoogleFonts.poppins(
                                            fontSize: 9,
                                            color: Colors.orangeAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
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

  // Helper methods for time selection
  String _getTimeOfDay(String time) {
    if (time.contains('AM')) {
      return 'Morning';
    } else if (time.contains('PM')) {
      final hourStr = time.split(':')[0];
      final hour = int.tryParse(hourStr) ?? 0;
      if (hour < 5) {
        return 'Afternoon';
      } else {
        return 'Evening';
      }
    }
    return 'Afternoon';
  }

  Color _getTimeOfDayColor(String timeOfDay, bool isDark) {
    switch (timeOfDay) {
      case 'Morning':
        return Colors.blue.withOpacity(0.1);
      case 'Afternoon':
        return Colors.orange.withOpacity(0.1);
      case 'Evening':
        return Colors.purple.withOpacity(0.1);
      default:
        return isDark ? Colors.grey[800]! : Colors.grey.withOpacity(0.1);
    }
  }

  Color _getTimeOfDayTextColor(String timeOfDay) {
    switch (timeOfDay) {
      case 'Morning':
        return Colors.blue;
      case 'Afternoon':
        return Colors.orange;
      case 'Evening':
        return Colors.purple;
      default:
        return Colors.grey;
    }
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