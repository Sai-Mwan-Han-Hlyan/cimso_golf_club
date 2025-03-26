import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'payment.dart';
import 'reception.dart';
import 'loading_screen.dart';
import 'tee_time_service.dart';
import 'booking_service.dart';
import 'booking_model.dart';
import 'package:cimso_golf_booking/providers/theme_provider.dart';

class CheckoutScreen extends StatefulWidget {
  final String course;
  final String time;
  final DateTime date;
  final int players;
  final int carts;
  final double price;

  const CheckoutScreen({
    super.key,
    required this.course,
    required this.time,
    required this.date,
    required this.players,
    required this.carts,
    required this.price,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> with SingleTickerProviderStateMixin {
  bool isCreditCardSelected = true;
  bool _isProcessing = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Initialize services
  final TeeTimeService _teeTimeService = TeeTimeService();
  final BookingService _bookingService = BookingService();

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Error handling method
  void _showErrorSnackBar(String message) {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    final colors = isDark ? _darkThemeColors : _lightThemeColors;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: colors['error'],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Confirmation dialog
  Future<bool> _showConfirmationDialog() async {
    // Get theme information
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    final colors = isDark ? _darkThemeColors : _lightThemeColors;

    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors['card'],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isDark
              ? BorderSide(color: Colors.grey[800]!, width: 1)
              : BorderSide.none,
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors['primary']!.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.golf_course, color: colors['primary'], size: 20),
            ),
            SizedBox(width: 12),
            Text(
              'Confirm Booking',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: colors['textPrimary'],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to ${isCreditCardSelected ? 'proceed to payment' : 'confirm this booking'}?',
              style: GoogleFonts.poppins(
                color: colors['textSecondary'],
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800]!.withOpacity(0.3) : Colors.grey[100]!,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: colors['accent'],
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      isCreditCardSelected
                          ? 'You will be redirected to our secure payment gateway'
                          : 'Payment will be collected at the reception desk',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: colors['textSecondary'],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: colors['textSecondary'],
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors['primary'],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text(
              'Confirm',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  // Price calculation method
  Map<String, int> _calculatePrices() {
    int playerPrice = widget.players * 1500;
    int cartPrice = widget.carts * 1400;
    int coursePrice = widget.course == '9H course' ? 1500 : 2500;
    int taxFee = 300;
    int totalPrice = playerPrice + cartPrice + coursePrice + taxFee;

    return {
      'playerPrice': playerPrice,
      'cartPrice': cartPrice,
      'coursePrice': coursePrice,
      'taxFee': taxFee,
      'totalPrice': totalPrice,
    };
  }

  // Main payment and booking handler
  Future<void> _handlePaymentSelection() async {
    // Prevent multiple submissions
    if (_isProcessing) return;

    // Show confirmation dialog
    bool confirmed = await _showConfirmationDialog();
    if (!confirmed) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Check tee time availability
      await _teeTimeService.init();
      bool isAvailable = _teeTimeService.isTimeAvailable(
          widget.date,
          widget.course,
          widget.time
      );

      if (!isAvailable) {
        _showErrorSnackBar('Sorry, this tee time is no longer available.');
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      // Calculate prices
      final prices = _calculatePrices();

      // Reserve the tee time
      await _teeTimeService.bookTeeTime(
          widget.date,
          widget.course,
          widget.time
      );

      // Create booking record
      final booking = BookingModel(
        courseName: widget.course,
        date: widget.date,
        time: widget.time,
        players: widget.players,
        carts: widget.carts,
        isUpcoming: true,
        amountPaid: isCreditCardSelected ? prices['totalPrice']!.toDouble() : null,
      );

      // Add booking to service
      await _bookingService.addBooking(booking);

      // Navigate to appropriate next screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => isCreditCardSelected
              ? PaymentPage(
            course: widget.course,
            time: widget.time,
            date: widget.date,
            players: widget.players,
            carts: widget.carts,
          )
              : ReceptionPage(
            course: widget.course,
            time: widget.time,
            date: widget.date,
            players: widget.players,
            carts: widget.carts,
          ),
        ),
      );
    } catch (e) {
      // Handle any unexpected errors
      _showErrorSnackBar('An error occurred: ${e.toString()}');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get theme information
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

    final prices = _calculatePrices();

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
            'Checkout',
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
      ),
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enhanced Header with course image and overlay
                  SizedBox(
                    height: 260,
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

                        // Step indicator overlay
                        Positioned(
                          top: 100,
                          left: 0,
                          right: 0,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _buildEnhancedStepIndicator(colors, isDark),
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
                                // Club name with larger font
                                Text(
                                  'CiMSO Golf Club',
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.1,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Info row with date and time
                                Row(
                                  children: [
                                    _buildInfoPill(
                                      Icons.calendar_today,
                                      DateFormat('EEE, MMM d').format(widget.date),
                                      colors['primary']!.withOpacity(0.9),
                                    ),
                                    const SizedBox(width: 10),
                                    _buildInfoPill(
                                      Icons.access_time,
                                      widget.time,
                                      colors['accent']!.withOpacity(0.9),
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

                  // Booking Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),

                        // Payment Method section
                        _buildSectionTitle('Payment Method', colors),
                        const SizedBox(height: 16),
                        _buildEnhancedPaymentSelection(colors, cardShadow, cardBorder, isDark),

                        const SizedBox(height: 30),

                        // Summary Section
                        _buildSectionTitle('Booking Summary', colors),
                        const SizedBox(height: 16),
                        _buildEnhancedSummaryCard(colors, cardShadow, cardBorder, isDark, prices),

                        const SizedBox(height: 30),

                        // Policy Information
                        _buildPolicyInfoCard(colors, cardShadow, cardBorder, isDark),

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

          // Processing overlay
          if (_isProcessing)
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    width: MediaQuery.of(context).size.width * 0.85,
                    decoration: BoxDecoration(
                      color: colors['card'],
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                      border: cardBorder,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            color: colors['primary'],
                            strokeWidth: 3,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Processing Your Booking',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colors['textPrimary'],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please wait while we confirm your tee time',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: colors['textSecondary'],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoPill(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
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
          _buildStepItem(1, false, "Book", colors, isDark),
          Expanded(
            child: _buildStepConnector(true, colors),
          ),
          _buildStepItem(2, true, "Checkout", colors, isDark),
          Expanded(
            child: _buildStepConnector(false, colors),
          ),
          _buildStepItem(3, false, "Pay", colors, isDark),
        ],
      ),
    );
  }

  Widget _buildStepItem(int step, bool isActive, String label, Map<String, Color> colors, bool isDark) {
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
          colors: [colors['primary']!, colors['primary']!],
        ) : null,
        color: isActive ? null : colors['primary']!.withOpacity(0.15),
      ),
    );
  }

  Widget _buildEnhancedPaymentSelection(
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select how you want to pay',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: colors['textSecondary'],
            ),
          ),
          const SizedBox(height: 16),

          // Credit Card Option
          _buildPaymentOption(
            'Credit Card',
            'Pay online securely',
            'Immediate confirmation',
            Icons.credit_card,
            isCreditCardSelected,
                () {
              setState(() {
                isCreditCardSelected = true;
              });
            },
            colors,
            isDark,
          ),

          const SizedBox(height: 12),

          // Pay at Reception Option
          _buildPaymentOption(
            'Pay at Reception',
            'Cash or card on arrival',
            'No prepayment needed',
            Icons.payments_outlined,
            !isCreditCardSelected,
                () {
              setState(() {
                isCreditCardSelected = false;
              });
            },
            colors,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
      String title,
      String subtitle,
      String benefit,
      IconData icon,
      bool isSelected,
      VoidCallback onTap,
      Map<String, Color> colors,
      bool isDark,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? colors['primary']!.withOpacity(0.1)
              : isDark
              ? Colors.grey[800]!.withOpacity(0.3)
              : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colors['primary']!
                : isDark
                ? Colors.grey[700]!
                : Colors.grey.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? colors['primary']
                    : isDark
                    ? Colors.grey[700]
                    : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : isDark
                    ? Colors.grey[400]
                    : colors['textSecondary'],
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? colors['primary']
                          : colors['textPrimary'],
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: colors['textSecondary'],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: isSelected
                            ? colors['primary']
                            : colors['success'],
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        benefit,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isSelected
                              ? colors['primary']
                              : colors['success'],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? colors['primary']
                    : isDark
                    ? Colors.grey[800]
                    : Colors.grey.withOpacity(0.1),
                border: isSelected
                    ? null
                    : Border.all(
                  color: isDark
                      ? Colors.grey[600]!
                      : Colors.grey.withOpacity(0.3),
                ),
              ),
              child: isSelected
                  ? Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedSummaryCard(
      Map<String, Color> colors,
      BoxShadow shadow,
      Border? border,
      bool isDark,
      Map<String, int> prices
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
          // Booking details
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.golf_course,
                      color: colors['primary'],
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.course,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors['textPrimary'],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors['success']!.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Tee Time',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: colors['success'],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Players and carts info
                Row(
                  children: [
                    _buildBookingInfoItem(
                      Icons.person,
                      '${widget.players} ${widget.players > 1 ? 'Players' : 'Player'}',
                      colors,
                    ),
                    const SizedBox(width: 16),
                    _buildBookingInfoItem(
                      Icons.directions_car,
                      '${widget.carts} ${widget.carts > 1 ? 'Carts' : 'Cart'}',
                      colors,
                    ),
                  ],
                ),
              ],
            ),
          ),

          Divider(height: 1, color: isDark ? Colors.grey[800] : Colors.grey.withOpacity(0.1)),

          // Price breakdown
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildPriceRow('Players (${widget.players}x)', '฿${prices['playerPrice']}', colors),
                _buildPriceRow('Golf Carts (${widget.carts}x)', '฿${prices['cartPrice']}', colors),
                _buildPriceRow('Course Fee', '฿${prices['coursePrice']}', colors),
                _buildPriceRow('Tax & Service Fee', '฿${prices['taxFee']}', colors),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Divider(
                    color: isDark ? Colors.grey[800] : Colors.grey.withOpacity(0.2),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colors['textPrimary'],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors['primary']!.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '฿${prices['totalPrice']}',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: colors['primary'],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingInfoItem(IconData icon, String text, Map<String, Color> colors) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors['primary']!.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: colors['primary'],
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: colors['textPrimary'],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, Map<String, Color> colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: colors['textSecondary'],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colors['textPrimary'],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyInfoCard(
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
              Icon(
                Icons.info_outline,
                color: colors['accent'],
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Booking Policies',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors['textPrimary'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPolicyItem(
            'Cancellation',
            'Free cancellation up to 24 hours before tee time',
            colors,
          ),
          const SizedBox(height: 8),
          _buildPolicyItem(
            'Check-in',
            'Please arrive 30 minutes before your tee time',
            colors,
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyItem(String title, String description, Map<String, Color> colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle,
          color: colors['success'],
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colors['textPrimary'],
                ),
              ),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: colors['textSecondary'],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedActionButton(Map<String, Color> colors, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors['primary']!.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _handlePaymentSelection,
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
              isCreditCardSelected ? 'Proceed to Payment' : 'Confirm Booking',
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