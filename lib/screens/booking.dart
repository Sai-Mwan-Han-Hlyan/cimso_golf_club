import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'checkout.dart';
import 'tee_time_service.dart'; // Import the service

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  int selectedPlayers = 1;
  int selectedCarts = 1;
  String selectedCourse = '9H course';
  String selectedTime = '';
  DateTime selectedDate = DateTime.now();

  // Service instances
  final TeeTimeService _teeTimeService = TeeTimeService();

  // Modern color scheme to match dashboard
  final Color primaryColor = const Color(0xFF2E7D32);
  final Color secondaryColor = const Color(0xFFAED581);
  final Color backgroundColor = const Color(0xFFF5F5F5);
  final Color textPrimaryColor = const Color(0xFF212121);
  final Color textSecondaryColor = const Color(0xFF757575);
  final Color cardColor = Colors.white;
  final Color accentColor = const Color(0xFF42A5F5); // Blue accent for selections

  List<String> availableTimes9H = [
    '11:00 AM', '11:45 AM', '1:30 PM', '2:15 PM', '3:30 PM', '4:15 PM'
  ];

  List<String> availableTimes18H = [
    '8:00 AM', '9:30 AM', '11:00 AM', '12:30 PM', '2:00 PM', '3:30 PM', '5:00 PM'
  ];

  List<String> allTimes = [];
  List<String> availableTimes = [];

  @override
  void initState() {
    super.initState();
    allTimes = availableTimes9H;
    _initializeBookingPage();
  }

  Future<void> _initializeBookingPage() async {
    // Initialize the tee time service
    await _teeTimeService.init();

    // Load available times
    _updateAvailableTimes();
  }

  void _updateAvailableTimes() {
    // Get all possible times based on course selection
    allTimes = selectedCourse == '9H course' ? availableTimes9H : availableTimes18H;

    // Filter times based on availability
    setState(() {
      availableTimes = _teeTimeService.getAvailableTimes(
          selectedDate,
          selectedCourse,
          allTimes
      );

      // If no time is selected or the selected time is not available, select the first available time
      if (selectedTime.isEmpty || !availableTimes.contains(selectedTime)) {
        selectedTime = availableTimes.isNotEmpty ? availableTimes.first : '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Book a Tee Time',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: textPrimaryColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: primaryColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: primaryColor, size: 20),
            onPressed: () {
              // Show course info
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course header with image
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/Golf-Course.png'),
                  fit: BoxFit.cover,
                ),
                color: secondaryColor.withOpacity(0.3), // This will show if image fails to load
              ),
              child: Stack(
                children: [
                  // Gradient overlay and text content
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CiMSO Golf Club',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.access_time, color: Colors.white70, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'Open until 10:00 PM',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.star, color: Colors.amber, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      '4.8',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Booking form
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step indicator
                  Row(
                    children: [
                      _buildStepIndicator(1, true, "Book"),
                      Expanded(
                        child: Container(
                          height: 2,
                          color: Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      _buildStepIndicator(2, false, "Checkout"),
                      Expanded(
                        child: Container(
                          height: 2,
                          color: Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      _buildStepIndicator(3, false, "Pay"),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Date selection
                  Text(
                    'Select Date',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDateSelector(),

                  const SizedBox(height: 24),

                  // Course selection
                  Text(
                    'Select Course',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildCourseSelection(),

                  const SizedBox(height: 24),

                  // Time selection
                  Text(
                    'Available Tee Times',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTimeSelection(),

                  const SizedBox(height: 24),

                  // Players and carts
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildModernSelectionRow(
                          'Players',
                          selectedPlayers,
                              (value) {
                            setState(() {
                              selectedPlayers = value;
                            });
                          },
                          Icons.person,
                        ),
                        const Divider(height: 24),
                        _buildModernSelectionRow(
                          'Golf Carts',
                          selectedCarts,
                              (value) {
                            setState(() {
                              selectedCarts = value;
                            });
                          },
                          Icons.directions_car,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Summary section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Booking Summary',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryRow(
                          'Date',
                          DateFormat('EEEE, MMMM d, yyyy').format(selectedDate),
                          Icons.calendar_today_outlined,
                        ),
                        _buildSummaryRow(
                          'Time',
                          selectedTime,
                          Icons.access_time,
                        ),
                        _buildSummaryRow(
                          'Course',
                          selectedCourse,
                          Icons.golf_course,
                        ),
                        _buildSummaryRow(
                          'Players',
                          selectedPlayers.toString(),
                          Icons.person,
                        ),
                        _buildSummaryRow(
                          'Carts',
                          selectedCarts.toString(),
                          Icons.directions_car,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Next button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedTime.isEmpty ? null : () {
                        // Calculate the price for the selected course
                        double coursePrice =
                        selectedCourse == '9H course' ? 1500 : 2500;
                        double playerPrice = selectedPlayers * 1500;
                        double cartPrice = selectedCarts * 1400;
                        double taxFee = 300;
                        double totalPrice =
                            playerPrice + cartPrice + coursePrice + taxFee;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutScreen(
                              course: selectedCourse,
                              time: selectedTime,
                              date: selectedDate,
                              players: selectedPlayers,
                              carts: selectedCarts,
                              price: totalPrice,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        // Disable the button if no time is selected
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: Text(
                        'Continue to Checkout',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, bool isActive, String label) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isActive ? primaryColor : Colors.grey.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: GoogleFonts.poppins(
                color: isActive ? Colors.white : textSecondaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: isActive ? primaryColor : textSecondaryColor,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: textSecondaryColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: textSecondaryColor,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(selectedDate),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textPrimaryColor,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.calendar_today_outlined, color: primaryColor),
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: primaryColor,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null && picked != selectedDate) {
                          setState(() {
                            selectedDate = picked;
                          });
                          _updateAvailableTimes();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Date chips row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
            child: Row(
              children: List.generate(7, (index) {
                final date = DateTime.now().add(Duration(days: index));
                final isSelected = DateUtils.isSameDay(date, selectedDate);

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedDate = date;
                      });
                      _updateAvailableTimes();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 60,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            DateFormat('E').format(date),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: isSelected ? Colors.white70 : textSecondaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('d').format(date),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : textPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSelectionRow(String label, int selectedValue, Function(int) onChanged, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: textSecondaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: textPrimaryColor,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 18),
                color: selectedValue > 1 ? primaryColor : Colors.grey,
                onPressed: selectedValue > 1 ? () => onChanged(selectedValue - 1) : null,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$selectedValue',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textPrimaryColor,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 18),
                color: primaryColor,
                onPressed: () => onChanged(selectedValue + 1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCourseSelection() {
    return Row(
      children: [
        Expanded(
          child: _courseOption('9H course', Icons.golf_course, '฿ 1,500'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _courseOption('18H course', Icons.golf_course, '฿ 2,500'),
        ),
      ],
    );
  }

  Widget _courseOption(String course, IconData icon, String price) {
    final isSelected = selectedCourse == course;

    return InkWell(
      onTap: () {
        setState(() {
          selectedCourse = course;
        });
        _updateAvailableTimes();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: primaryColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ] : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? primaryColor : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              course,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textPrimaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              price,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isSelected ? primaryColor : textSecondaryColor,
              ),
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Icon(
                  Icons.check_circle,
                  color: primaryColor,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelection() {
    if (availableTimes.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.event_busy, color: Colors.red[300], size: 40),
              const SizedBox(height: 12),
              Text(
                'No available tee times for this selection',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: availableTimes.map((time) {
          final isSelected = selectedTime == time;

          return InkWell(
            onTap: () {
              setState(() {
                selectedTime = time;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                time,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  color: isSelected ? Colors.white : textPrimaryColor,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}