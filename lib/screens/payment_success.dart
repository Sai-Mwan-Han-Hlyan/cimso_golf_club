import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'notification_manager.dart';
import 'dashboard.dart';
import 'booking_model.dart';
import 'mybooking.dart';
import 'notification.dart';
import 'package:cimso_golf_booking/providers/theme_provider.dart';

class PaymentSuccessPage extends StatefulWidget {
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
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

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
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.0, 0.5, curve: Curves.elasticOut)
        )
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.3, 0.8, curve: Curves.easeOut)
        )
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
        CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.3, 0.8, curve: Curves.easeOut)
        )
    );

    _animationController.forward();

    // Show notification after delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        _showNotificationPopup(context);
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
        backgroundColor: colors['background'],
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            ),
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
        body: Stack(
          children: [
            // Background image with gradient overlay
            Positioned.fill(
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colors['background']!.withOpacity(0.6),
                      colors['background']!,
                    ],
                    stops: const [0.3, 0.7],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.srcOver,
                child: isDark
                    ? ColorFiltered(
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.7),
                      BlendMode.darken
                  ),
                  child: Image.asset(
                    'assets/Golf-Course.png',
                    fit: BoxFit.cover,
                    opacity: const AlwaysStoppedAnimation(0.3),
                  ),
                )
                    : Image.asset(
                  'assets/Golf-Course.png',
                  fit: BoxFit.cover,
                  opacity: const AlwaysStoppedAnimation(0.2),
                ),
              ),
            ),

            // Content
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),

                      // Animated success check
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: _buildSuccessAnimation(colors),
                      ),

                      const SizedBox(height: 30),

                      // Animated success text
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(0, 0.5),
                            end: Offset.zero,
                          ).animate(_fadeAnimation),
                          child: Column(
                            children: [
                              Text(
                                'Payment Successful!',
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: colors['textPrimary'],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Your tee time has been confirmed. See you on the green!',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: colors['textSecondary'],
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Confirmation #${_generateConfirmationNumber()}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: colors['primary'],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Animated booking details card
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(_fadeAnimation),
                          child: _buildBookingDetailsCard(colors, cardShadow, cardBorder, isDark),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Animated action buttons
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(0, 0.2),
                            end: Offset.zero,
                          ).animate(_fadeAnimation),
                          child: _buildActionButtons(colors, cardShadow, cardBorder, isDark),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Share option
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildShareOption(colors),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessAnimation(Map<String, Color> colors) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: colors['success']!.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: colors['success'],
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colors['success']!.withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 80,
          ),
        ),
      ),
    );
  }

  Widget _buildBookingDetailsCard(
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
          // Card Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors['primary'],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.golf_course,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CiMSO Golf Club',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        widget.course,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.payments_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Paid',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Booking Details
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildDetailRow(
                  Icons.calendar_today,
                  'Date',
                  DateFormat('EEEE, MMMM d, yyyy').format(widget.date),
                  colors,
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  Icons.access_time,
                  'Time',
                  widget.time,
                  colors,
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  Icons.person,
                  'Players',
                  '${widget.players} ${widget.players == 1 ? 'player' : 'players'}',
                  colors,
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  Icons.directions_car,
                  'Carts',
                  '${widget.carts} ${widget.carts == 1 ? 'cart' : 'carts'}',
                  colors,
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  Icons.payments,
                  'Amount Paid',
                  '฿ ${widget.amountPaid.toStringAsFixed(2)}',
                  colors,
                  isHighlighted: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      IconData icon,
      String label,
      String value,
      Map<String, Color> colors,
      {bool isHighlighted = false}
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isHighlighted
                ? colors['primary']!.withOpacity(0.15)
                : colors['primary']!.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isHighlighted ? colors['primary'] : colors['primary']!.withOpacity(0.8),
            size: 18,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: colors['textSecondary'],
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: isHighlighted ? 17 : 15,
                  fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w600,
                  color: isHighlighted ? colors['primary'] : colors['textPrimary'],
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
      Map<String, Color> colors,
      BoxShadow shadow,
      Border? border,
      bool isDark
      ) {
    return Column(
      children: [
        // Calendar button
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: colors['card'],
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
            border: isDark ? Border.all(color: Colors.grey[800]!, width: 1) : null,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                // Add calendar functionality
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      color: colors['primary'],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Add to Calendar',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: colors['primary'],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Done button
        Container(
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
            onPressed: () {
              // Create a booking model from the payment details
              final newBooking = BookingModel(
                courseName: widget.course,
                date: widget.date,
                time: widget.time,
                players: widget.players,
                carts: widget.carts,
                isUpcoming: true,
                amountPaid: widget.amountPaid,
              );

              // Navigate to the MyBooking page with the new booking
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => MyBooking(newBooking: newBooking),
                ),
                    (route) => false, // Remove all previous routes
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
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'View My Bookings',
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
        ),
      ],
    );
  }

  Widget _buildShareOption(Map<String, Color> colors) {
    return TextButton.icon(
      onPressed: () {
        // Add share receipt functionality
      },
      icon: Icon(Icons.share_rounded, size: 18, color: colors['textSecondary']),
      label: Text(
        'Share Receipt',
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colors['textSecondary'],
        ),
      ),
    );
  }

  void _showNotificationPopup(BuildContext context) {
    // Get theme information
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    final colors = isDark ? _darkThemeColors : _lightThemeColors;

    final newNotification = NotificationModel(
      title: 'Booking Complete!',
      message: 'Your tee time for ${widget.course} at ${widget.time} on ${DateFormat('EEE, MMM d').format(widget.date)} has been confirmed.',
      icon: Icons.notifications_active,
      timestamp: DateTime.now(),
    );

    NotificationManager.addNotification(newNotification);

    showDialog(
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
              child: Icon(
                Icons.notifications_active,
                color: colors['primary'],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                newNotification.title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: colors['textPrimary'],
                ),
              ),
            ),
          ],
        ),
        content: Text(
          newNotification.message,
          style: GoogleFonts.poppins(
            color: colors['textSecondary'],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red[400],
            ),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors['primary'],
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'View Notifications',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  // Generate a random confirmation number
  String _generateConfirmationNumber() {
    final now = DateTime.now();
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final random = (1000 + now.millisecond + now.second * 37) % 9000 + 1000;
    return '$dateStr-$random';
  }
}