import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'payment.dart';
import 'reception.dart';
import 'loading_screen.dart';
import 'tee_time_service.dart';
import 'booking_service.dart';
import 'booking_model.dart';

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

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool isCreditCardSelected = true;
  bool _isProcessing = false;

  // Color scheme to match BookingPage
  final Color primaryColor = const Color(0xFF2E7D32);
  final Color secondaryColor = const Color(0xFFAED581);
  final Color backgroundColor = const Color(0xFFF5F5F5);
  final Color textPrimaryColor = const Color(0xFF212121);
  final Color textSecondaryColor = const Color(0xFF757575);
  final Color cardColor = Colors.white;
  final Color accentColor = const Color(0xFF42A5F5);

  // Initialize services
  final TeeTimeService _teeTimeService = TeeTimeService();
  final BookingService _bookingService = BookingService();

  // Error handling method
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Confirmation dialog
  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirm Booking',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: textPrimaryColor,
          ),
        ),
        content: Text(
          'Are you sure you want to ${isCreditCardSelected ? 'proceed to payment' : 'confirm this booking'}?',
          style: GoogleFonts.poppins(
            color: textSecondaryColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: textSecondaryColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
            ),
            child: Text(
              'Confirm',
              style: GoogleFonts.poppins(
                color: Colors.white,
              ),
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
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Checkout',
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
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
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
                    color: secondaryColor.withOpacity(0.3),
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
                                  _buildDateTimeChip(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Payment Method Selection
                      Text(
                        'Payment Method',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildPaymentSelection(),

                      const SizedBox(height: 24),

                      // Booking Summary
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
                            _buildSummaryDetails(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Proceed Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isProcessing ? null : _handlePaymentSelection,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isProcessing
                              ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                              : Text(
                            isCreditCardSelected
                                ? 'Proceed to Payment'
                                : 'Confirm Booking',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Additional overlay for processing state if needed
          if (_isProcessing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: primaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Processing your booking...',
                          style: GoogleFonts.poppins(
                            color: textPrimaryColor,
                            fontWeight: FontWeight.w500,
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

  Widget _buildDateTimeChip() {
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.white, size: 14),
              const SizedBox(width: 6),
              Text(
                DateFormat('EEE, MMM d').format(widget.date),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.access_time, color: Colors.white, size: 14),
              const SizedBox(width: 6),
              Text(
                widget.time,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSelection() {
    return Row(
      children: [
        Expanded(
          child: _paymentOption(
            Icons.credit_card,
            'Credit Card',
            isSelected: isCreditCardSelected,
            onTap: () {
              setState(() {
                isCreditCardSelected = true;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _paymentOption(
            Icons.receipt_long,
            'Reception',
            isSelected: !isCreditCardSelected,
            onTap: () {
              setState(() {
                isCreditCardSelected = false;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _paymentOption(IconData icon, String label, {required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: primaryColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : textSecondaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: isSelected ? Colors.white : textSecondaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryDetails() {
    final prices = _calculatePrices();

    return Column(
      children: [
        _buildSummaryRow('${widget.players}x Players', '฿ ${prices['playerPrice']}'),
        _buildSummaryRow('${widget.carts}x Golf Cart', '฿ ${prices['cartPrice']}'),
        _buildSummaryRow('${widget.course}', '฿ ${prices['coursePrice']}'),
        _buildSummaryRow('Tax & Fee', '฿ ${prices['taxFee']}'),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(),
        ),
        _buildSummaryRow('Total (baht)', '฿ ${prices['totalPrice']}', isTotal: true),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: textPrimaryColor,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              color: isTotal ? primaryColor : textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }
}