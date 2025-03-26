import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'checkout.dart';
import 'tee_time_service.dart';
import 'package:cimso_golf_booking/providers/theme_provider.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> with SingleTickerProviderStateMixin {
  int selectedPlayers = 1;
  int selectedCarts = 1;
  String selectedCourse = '9H course';
  String selectedTime = '';
  DateTime selectedDate = DateTime.now();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Service instances
  final TeeTimeService _teeTimeService = TeeTimeService();

  // Color constants
  final Map<String, Color> _lightThemeColors = {
    'primary': const Color(0xFF1B5E20),      // Forest Green
    'primaryLight': const Color(0xFF43A047), // Light Green
    'secondary': const Color(0xFF2E7D32),    // Medium Green
    'accent': const Color(0xFF00BFA5),       // Teal Accent
    'background': const Color(0xFFF9F9F9),   // Off-White
    'card': Colors.white,
    'textPrimary': const Color(0xFF212121),  // Near Black
    'textSecondary': const Color(0xFF757575),// Medium Gray
    'success': const Color(0xFF66BB6A),      // Light Green
    'error': const Color(0xFFE57373),        // Light Red
  };

  final Map<String, Color> _darkThemeColors = {
    'primary': const Color(0xFF2E7D32),      // Medium Green
    'primaryLight': const Color(0xFF388E3C), // Medium-Light Green
    'secondary': const Color(0xFF1B5E20),    // Forest Green
    'accent': const Color(0xFF00BFA5),       // Teal Accent
    'background': const Color(0xFF121212),   // Dark Gray
    'card': const Color(0xFF1E1E1E),         // Medium-Dark Gray
    'textPrimary': const Color(0xFFECEFF1),  // Off-White
    'textSecondary': const Color(0xFFB0BEC5),// Light Gray
    'success': const Color(0xFF4CAF50),      // Green
    'error': const Color(0xFFEF5350),        // Red
  };

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

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn)
    );

    _animationController.forward();

    allTimes = availableTimes9H;
    _initializeBookingPage();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeBookingPage() async {
    await _teeTimeService.init();
    _updateAvailableTimes();
  }

  void _updateAvailableTimes() {
    allTimes = selectedCourse == '9H course' ? availableTimes9H : availableTimes18H;

    setState(() {
      availableTimes = _teeTimeService.getAvailableTimes(
          selectedDate,
          selectedCourse,
          allTimes
      );

      if (selectedTime.isEmpty || !availableTimes.contains(selectedTime)) {
        selectedTime = availableTimes.isNotEmpty ? availableTimes.first : '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Theme colors based on mode
    final colors = isDark ? _darkThemeColors : _lightThemeColors;

    // Shadow settings based on theme
    final BoxShadow cardShadow = BoxShadow(
      color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.08),
      blurRadius: 15,
      offset: const Offset(0, 5),
      spreadRadius: isDark ? 1 : 0,
    );

    // Border based on theme
    final Border? cardBorder = isDark
        ? Border.all(color: Colors.grey[800]!, width: 1)
        : null;

    return Scaffold(
      backgroundColor: colors['background'],
      extendBodyBehindAppBar: true, // Allow content to go behind app bar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: AnimatedOpacity(
          opacity: _animationController.value,
          duration: const Duration(milliseconds: 500),
          child: Text(
            'Book a Tee Time',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.info_outline, color: Colors.white, size: 18),
            ),
            onPressed: () {
              // Show course info
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course header with image
              SizedBox(
                height: 280,
                width: double.infinity,
                child: Stack(
                  children: [
                    // Background Image with overlay
                    Positioned.fill(
                      child: ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.8),
                            ],
                            stops: const [0.5, 1.0],
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.srcOver,
                        child: isDark
                            ? ColorFiltered(
                          colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.3),
                              BlendMode.darken
                          ),
                          child: Image.asset(
                            'assets/Golf-Course.png',
                            fit: BoxFit.cover,
                          ),
                        )
                            : Image.asset(
                          'assets/Golf-Course.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // Content overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Logo/Badge
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: colors['primary'],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.golf_course, color: Colors.white, size: 16),
                                      const SizedBox(width: 6),
                                      Text(
                                        'PREMIUM',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Club name with larger font
                            Text(
                              'CiMSO Golf Club',
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),

                            const SizedBox(height: 4),

                            // Location with icon
                            Row(
                              children: [
                                Icon(Icons.location_on, color: Colors.white.withOpacity(0.8), size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Golf Avenue, Bangkok',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Info row
                            Row(
                              children: [
                                _buildInfoPill(
                                  Icons.access_time,
                                  'Open until 10:00 PM',
                                  colors['primary']!.withOpacity(0.9),
                                ),
                                const SizedBox(width: 10),
                                _buildInfoPill(
                                  Icons.star,
                                  '4.8',
                                  colors['accent']!.withOpacity(0.9),
                                  iconColor: Colors.amber,
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
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // Step indicator with enhanced design
                    _buildEnhancedStepIndicator(colors, isDark),

                    const SizedBox(height: 30),

                    // Date selection with section title design
                    _buildSectionTitle('Select Date', colors),
                    const SizedBox(height: 12),
                    _buildEnhancedDateSelector(colors, cardShadow, cardBorder, isDark),

                    const SizedBox(height: 30),

                    // Course selection
                    _buildSectionTitle('Select Course', colors),
                    const SizedBox(height: 12),
                    _buildEnhancedCourseSelection(colors, cardShadow, cardBorder, isDark),

                    const SizedBox(height: 30),

                    // Time selection
                    _buildSectionTitle('Available Tee Times', colors),
                    const SizedBox(height: 12),
                    _buildEnhancedTimeSelection(colors, cardShadow, cardBorder, isDark),

                    const SizedBox(height: 30),

                    // Players and carts with enhanced design
                    _buildEnhancedSelectionCard(colors, cardShadow, cardBorder, isDark),

                    const SizedBox(height: 30),

                    // Summary section with better styling
                    _buildEnhancedSummaryCard(colors, cardShadow, cardBorder, isDark),

                    const SizedBox(height: 30),

                    // Enhanced call-to-action button
                    _buildEnhancedActionButton(colors, isDark),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoPill(IconData icon, String text, Color color, {Color? iconColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor ?? Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Map<String, Color> colors) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: colors['primary'],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colors['textPrimary'],
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedStepIndicator(Map<String, Color> colors, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: colors['card'],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: isDark ? Border.all(color: Colors.grey[800]!, width: 1) : null,
      ),
      child: Row(
        children: [
          _buildStepItem(1, true, "Book", colors),
          Expanded(
            child: _buildStepConnector(true, colors),
          ),
          _buildStepItem(2, false, "Checkout", colors),
          Expanded(
            child: _buildStepConnector(false, colors),
          ),
          _buildStepItem(3, false, "Pay", colors),
        ],
      ),
    );
  }

  Widget _buildStepItem(int step, bool isActive, String label, Map<String, Color> colors) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive ? colors['primary'] : colors['primary']!.withOpacity(0.15),
            shape: BoxShape.circle,
            boxShadow: isActive ? [
              BoxShadow(
                color: colors['primary']!.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ] : null,
          ),
          child: Center(
            child: isActive
                ? Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
              step.toString(),
              style: GoogleFonts.poppins(
                color: isActive ? Colors.white : colors['primary'],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: isActive ? colors['primary'] : colors['textSecondary'],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(bool isActive, Map<String, Color> colors) {
    return Container(
      height: 2,
      decoration: BoxDecoration(
        gradient: isActive ? LinearGradient(
          colors: [colors['primary']!, colors['primary']!.withOpacity(0.3)],
        ) : null,
        color: isActive ? null : colors['primary']!.withOpacity(0.15),
      ),
    );
  }

  Widget _buildEnhancedDateSelector(
      Map<String, Color> colors,
      BoxShadow shadow,
      Border? border,
      bool isDark
      ) {
    return Container(
      decoration: BoxDecoration(
        color: colors['card'],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [shadow],
        border: border,
      ),
      child: Column(
        children: [
          // Month selector with improved design
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors['primary']!.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.calendar_month, color: colors['primary'], size: 18),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('MMMM yyyy').format(selectedDate),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors['textPrimary'],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colors['primary']!.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.date_range, color: colors['primary'], size: 16),
                  ),
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
                              primary: colors['primary']!,
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
          ),

          // Date chips with improved visuals
          Container(
            height: 90,
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 14, // Show 2 weeks of dates
              itemBuilder: (context, index) {
                final date = DateTime.now().add(Duration(days: index));
                final isSelected = DateUtils.isSameDay(date, selectedDate);
                final isToday = DateUtils.isSameDay(date, DateTime.now());

                return Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedDate = date;
                      });
                      _updateAvailableTimes();
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 65,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors['primary']
                            : isToday
                            ? colors['primaryLight']!.withOpacity(0.1)
                            : isDark
                            ? Colors.grey[800]
                            : Colors.grey.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: colors['primary']!.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ] : null,
                        border: isToday && !isSelected
                            ? Border.all(color: colors['primaryLight']!, width: 1)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('E').format(date),
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: isSelected
                                  ? Colors.white.withOpacity(0.8)
                                  : colors['textSecondary'],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            DateFormat('d').format(date),
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : colors['textPrimary'],
                            ),
                          ),
                          if (isToday && !isSelected)
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              width: 20,
                              height: 3,
                              decoration: BoxDecoration(
                                color: colors['primaryLight'],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedCourseSelection(
      Map<String, Color> colors,
      BoxShadow shadow,
      Border? border,
      bool isDark
      ) {
    return Row(
      children: [
        Expanded(
          child: _buildEnhancedCourseOption(
              '9H course',
              'Par 36',
              '฿ 1,500',
              'Ideal for beginners',
              colors,
              shadow,
              border,
              isDark
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildEnhancedCourseOption(
              '18H course',
              'Par 72',
              '฿ 2,500',
              'Championship course',
              colors,
              shadow,
              border,
              isDark
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedCourseOption(
      String course,
      String par,
      String price,
      String description,
      Map<String, Color> colors,
      BoxShadow shadow,
      Border? border,
      bool isDark
      ) {
    final isSelected = selectedCourse == course;

    return InkWell(
      onTap: () {
        setState(() {
          selectedCourse = course;
        });
        _updateAvailableTimes();
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors['card'],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? colors['primary']!
                : isDark
                ? Colors.grey[700]!
                : Colors.grey.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: colors['primary']!.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ] : [shadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors['primary']!.withOpacity(0.1)
                        : isDark
                        ? Colors.grey[800]
                        : Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.golf_course,
                    color: isSelected
                        ? colors['primary']
                        : isDark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    course,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors['textPrimary'],
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colors['primary'],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              par,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: colors['textSecondary'],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: colors['textSecondary'],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? colors['primary']!.withOpacity(0.1)
                    : isDark
                    ? Colors.grey[800]
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                price,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? colors['primary'] : colors['textSecondary'],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedTimeSelection(
      Map<String, Color> colors,
      BoxShadow shadow,
      Border? border,
      bool isDark
      ) {
    if (availableTimes.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: colors['card'],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [shadow],
          border: border,
        ),
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.event_busy, color: colors['error'], size: 48),
              const SizedBox(height: 16),
              Text(
                'No available tee times',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors['textPrimary'],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Please select a different date or course',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: colors['textSecondary'],
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
        color: colors['card'],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [shadow],
        border: border,
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
                    color: colors['primary']!.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.access_time, color: colors['primary'], size: 16),
                ),
                const SizedBox(width: 12),
                Text(
                  DateFormat('EEEE, MMMM d').format(selectedDate),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colors['textPrimary'],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors['success']!.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${availableTimes.length} available',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colors['success'],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: availableTimes.map((time) {
              final isSelected = selectedTime == time;
              final timeOfDay = _getTimeOfDay(time);
              final isEarlyMorning = timeOfDay == 'Morning' && time.contains('AM') && !time.contains('11');
              final isEvening = timeOfDay == 'Evening';

              return InkWell(
                onTap: () {
                  setState(() {
                    selectedTime = time;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors['primary']
                        : isDark
                        ? Colors.grey[800]
                        : Colors.grey.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: colors['primary']!.withOpacity(0.3),
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
                          color: isSelected ? Colors.white : colors['textPrimary'],
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Tag indicating time of day
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withOpacity(0.2)
                              : _getTimeOfDayColor(timeOfDay, colors, isDark),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          timeOfDay,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : _getTimeOfDayTextColor(timeOfDay, colors, isDark),
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
    );
  }

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

  Color _getTimeOfDayColor(String timeOfDay, Map<String, Color> colors, bool isDark) {
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

  Color _getTimeOfDayTextColor(String timeOfDay, Map<String, Color> colors, bool isDark) {
    switch (timeOfDay) {
      case 'Morning':
        return Colors.blue;
      case 'Afternoon':
        return Colors.orange;
      case 'Evening':
        return Colors.purple;
      default:
        return colors['textSecondary']!;
    }
  }

  Widget _buildEnhancedSelectionCard(
      Map<String, Color> colors,
      BoxShadow shadow,
      Border? border,
      bool isDark
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors['card'],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [shadow],
        border: border,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors['primary']!.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.group, color: colors['primary'], size: 16),
              ),
              const SizedBox(width: 12),
              Text(
                'Party Details',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors['textPrimary'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildEnhancedSelectionRow(
            'Players',
            Icons.person,
            selectedPlayers,
                (value) {
              setState(() {
                selectedPlayers = value;
              });
            },
            colors,
            isDark,
          ),
          Divider(
            height: 32,
            color: isDark ? Colors.grey[800] : Colors.grey.withOpacity(0.2),
            thickness: 1,
          ),
          _buildEnhancedSelectionRow(
            'Golf Carts',
            Icons.directions_car,
            selectedCarts,
                (value) {
              setState(() {
                selectedCarts = value;
              });
            },
            colors,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSelectionRow(
      String label,
      IconData icon,
      int value,
      Function(int) onChanged,
      Map<String, Color> colors,
      bool isDark,
      ) {
    return Row(
      children: [
        Icon(icon, color: colors['textSecondary'], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: colors['textPrimary'],
                ),
              ),
              Text(
                label == 'Players'
                    ? 'Number of golfers in your group'
                    : 'Number of carts needed',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: colors['textSecondary'],
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Material(
                color: Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: InkWell(
                  onTap: value > 1 ? () => onChanged(value - 1) : null,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.remove,
                      size: 18,
                      color: value > 1
                          ? colors['primary']
                          : isDark
                          ? Colors.grey[600]
                          : Colors.grey[400],
                    ),
                  ),
                ),
              ),
              Container(
                width: 40,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.white,
                  border: Border.symmetric(
                    vertical: BorderSide(
                      color: isDark
                          ? Colors.grey[600]!
                          : Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors['textPrimary'],
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                child: InkWell(
                  onTap: () => onChanged(value + 1),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.add,
                      size: 18,
                      color: colors['primary'],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedSummaryCard(
      Map<String, Color> colors,
      BoxShadow shadow,
      Border? border,
      bool isDark
      ) {
    // Calculate estimated prices
    final double coursePrice = selectedCourse == '9H course' ? 1500 : 2500;
    final double playerFee = selectedPlayers * 1500;
    final double cartFee = selectedCarts * 1400;
    final double tax = 300;
    final double total = coursePrice + playerFee + cartFee + tax;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors['card'],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [shadow],
        border: border,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors['primary']!.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.receipt_long, color: colors['primary'], size: 16),
              ),
              const SizedBox(width: 12),
              Text(
                'Booking Summary',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors['textPrimary'],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Booking details
          _buildSummaryItem(
            'Date',
            DateFormat('EEEE, MMMM d, yyyy').format(selectedDate),
            Icons.calendar_today_outlined,
            colors,
          ),
          _buildSummaryItem(
            'Time',
            selectedTime,
            Icons.access_time,
            colors,
          ),
          _buildSummaryItem(
            'Course',
            selectedCourse,
            Icons.golf_course,
            colors,
          ),
          _buildSummaryItem(
            'Players',
            '$selectedPlayers',
            Icons.person,
            colors,
          ),
          _buildSummaryItem(
            'Carts',
            '$selectedCarts',
            Icons.directions_car,
            colors,
          ),

          const SizedBox(height: 20),

          // Price details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                _buildPriceRow('Course Fee', '฿ ${coursePrice.toStringAsFixed(0)}', colors),
                _buildPriceRow('Player Fee (${selectedPlayers}x)', '฿ ${playerFee.toStringAsFixed(0)}', colors),
                _buildPriceRow('Cart Fee (${selectedCarts}x)', '฿ ${cartFee.toStringAsFixed(0)}', colors),
                _buildPriceRow('Tax', '฿ ${tax.toStringAsFixed(0)}', colors),
                Divider(height: 24, color: isDark ? Colors.grey[700] : Colors.grey.withOpacity(0.2)),
                _buildPriceRow(
                  'Total',
                  '฿ ${total.toStringAsFixed(0)}',
                  colors,
                  isTotal: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      String label,
      String value,
      IconData icon,
      Map<String, Color> colors
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors['primary']!.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: colors['primary']),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: colors['textSecondary'],
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colors['textPrimary'],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
      String label,
      String value,
      Map<String, Color> colors,
      {bool isTotal = false}
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: isTotal ? 15 : 13,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              color: isTotal ? colors['textPrimary'] : colors['textSecondary'],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isTotal ? 15 : 13,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              color: isTotal ? colors['primary'] : colors['textPrimary'],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedActionButton(Map<String, Color> colors, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: selectedTime.isNotEmpty ? [
          BoxShadow(
            color: colors['primary']!.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
        ] : null,
      ),
      child: ElevatedButton(
        onPressed: selectedTime.isEmpty ? null : () {
          // Calculate the price for the selected course
          double coursePrice = selectedCourse == '9H course' ? 1500 : 2500;
          double playerPrice = selectedPlayers * 1500;
          double cartPrice = selectedCarts * 1400;
          double taxFee = 300;
          double totalPrice = coursePrice + playerPrice + cartPrice + taxFee;

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
          backgroundColor: colors['primary'],
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          disabledBackgroundColor: isDark ? Colors.grey[800] : Colors.grey.shade300,
          disabledForegroundColor: isDark ? Colors.grey[600] : Colors.grey[400],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Continue to Checkout',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}