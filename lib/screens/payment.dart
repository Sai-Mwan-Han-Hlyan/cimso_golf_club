import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'payment_success.dart';
import 'loading_screen.dart';
import 'package:cimso_golf_booking/providers/theme_provider.dart';

// Custom input formatter for credit card number with spaces
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all non-digits
    String value = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Trim to max 16 digits
    if (value.length > 16) {
      value = value.substring(0, 16);
    }

    // Add spaces after every 4 digits
    StringBuffer result = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      if (i > 0 && i % 4 == 0) {
        result.write(' ');
      }
      result.write(value[i]);
    }

    return TextEditingValue(
      text: result.toString(),
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}

// Custom input formatter for expiration date (MM/YY)
class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all non-digits
    String value = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Trim to max 4 digits
    if (value.length > 4) {
      value = value.substring(0, 4);
    }

    // Format as MM/YY
    StringBuffer result = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      if (i == 2 && value.length > 2) {
        result.write('/');
      }
      result.write(value[i]);
    }

    return TextEditingValue(
      text: result.toString(),
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}

class PaymentPage extends StatefulWidget {
  final String course;
  final String time;
  final DateTime date;
  final int players;
  final int carts;

  const PaymentPage({
    super.key,
    required this.course,
    required this.time,
    required this.date,
    required this.players,
    required this.carts,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> with SingleTickerProviderStateMixin {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardholderNameController = TextEditingController();
  final TextEditingController _expirationDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscureCVV = true;
  String? _cardType;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    'visa': const Color(0xFF1A1F71),         // Visa Blue
    'mastercard': const Color(0xFFEB001B),   // Mastercard Red
    'amex': const Color(0xFF2E77BC),         // Amex Blue
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
    'visa': const Color(0xFF5B6BBF),         // Visa Blue (lighter for dark mode)
    'mastercard': const Color(0xFFFF5252),   // Mastercard Red (lighter for dark mode)
    'amex': const Color(0xFF64B5F6),         // Amex Blue (lighter for dark mode)
  };

  @override
  void initState() {
    super.initState();
    _cardNumberController.addListener(_updateCardType);

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn)
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _cardNumberController.removeListener(_updateCardType);
    _cardNumberController.dispose();
    _cardholderNameController.dispose();
    _expirationDateController.dispose();
    _cvvController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _updateCardType() {
    final cardNumber = _cardNumberController.text.replaceAll(' ', '');

    if (cardNumber.isEmpty) {
      setState(() {
        _cardType = null;
      });
      return;
    }

    if (cardNumber.startsWith('4')) {
      setState(() {
        _cardType = 'visa';
      });
    } else if (cardNumber.startsWith('5')) {
      setState(() {
        _cardType = 'mastercard';
      });
    } else if (cardNumber.startsWith('3')) {
      setState(() {
        _cardType = 'amex';
      });
    } else {
      setState(() {
        _cardType = null;
      });
    }
  }

  Widget _getCardTypeIcon(Map<String, Color> colors) {
    if (_cardType == null) {
      return const SizedBox(width: 48, height: 30);
    }

    Color cardColor;
    Widget cardIcon;

    switch (_cardType) {
      case 'visa':
        cardColor = colors['visa']!;
        cardIcon = const Text(
          'VISA',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        );
        break;
      case 'mastercard':
        cardColor = colors['mastercard']!;
        cardIcon = const Text(
          'MC',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        );
        break;
      case 'amex':
        cardColor = colors['amex']!;
        cardIcon = const Text(
          'AMEX',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        );
        break;
      default:
        return const SizedBox(width: 48, height: 30);
    }

    return Container(
      width: 48,
      height: 30,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(child: cardIcon),
    );
  }

  bool _isValidCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }

    // Remove spaces
    final cardNumber = value.replaceAll(' ', '');

    // Check if it's numeric and has correct length
    if (!RegExp(r'^[0-9]{13,19}$').hasMatch(cardNumber)) {
      return false;
    }

    // Luhn algorithm (checksum)
    int sum = 0;
    bool alternate = false;
    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cardNumber[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }

      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  bool _isValidExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }

    // Check format
    if (!RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$').hasMatch(value)) {
      return false;
    }

    final parts = value.split('/');
    final month = int.parse(parts[0]);
    final year = int.parse('20${parts[1]}');

    // Create expiry date (last day of month)
    final now = DateTime.now();
    final expiryDate = DateTime(year, month + 1, 0);

    // Check if card is not expired
    return expiryDate.isAfter(now);
  }

  bool _isValidCVV(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }

    // For Amex, CVV should be 4 digits, for others 3 digits
    if (_cardType == 'amex') {
      return RegExp(r'^[0-9]{4}$').hasMatch(value);
    } else {
      return RegExp(r'^[0-9]{3}$').hasMatch(value);
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

    // Calculate prices for the summary
    int playerPrice = widget.players * 1500;
    int cartPrice = widget.carts * 1400;
    int coursePrice = widget.course == '9H course' ? 1500 : 2500;
    int taxFee = 300;
    int totalPrice = playerPrice + cartPrice + coursePrice + taxFee;

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
            'Payment',
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
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with course image
                _buildPaymentHeader(colors, isDark),

                // Content with card inputs and summary
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),

                      // Step indicator
                      _buildEnhancedStepIndicator(colors, isDark),

                      const SizedBox(height: 30),

                      // Card section
                      _buildSectionTitle('Card Details', colors),
                      const SizedBox(height: 16),
                      _buildCreditCardSection(colors, cardShadow, cardBorder, isDark),

                      const SizedBox(height: 30),

                      // Order summary section
                      _buildSectionTitle('Order Summary', colors),
                      const SizedBox(height: 16),
                      _buildOrderSummary(colors, cardShadow, cardBorder, isDark, totalPrice),

                      const SizedBox(height: 30),

                      // Security note
                      _buildSecurityNote(colors, cardShadow, cardBorder, isDark),

                      const SizedBox(height: 30),

                      // Payment button
                      _buildPaymentButton(colors, isDark, totalPrice),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentHeader(Map<String, Color> colors, bool isDark) {
    return SizedBox(
      height: 240,
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
          _buildStepItem(2, false, "Checkout", colors, isDark),
          Expanded(
            child: _buildStepConnector(true, colors),
          ),
          _buildStepItem(3, true, "Pay", colors, isDark),
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

  Widget _buildCreditCardSection(
      Map<String, Color> colors,
      BoxShadow shadow,
      Border? border,
      bool isDark
      ) {
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
          // Card Number field
          _buildCardNumberField(colors, isDark),
          const SizedBox(height: 16),

          // Cardholder Name field
          _buildCardholderNameField(colors, isDark),
          const SizedBox(height: 16),

          // Row with expiry date and CVV
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildExpiryDateField(colors, isDark),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: _buildCVVField(colors, isDark),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Accepted cards
          Row(
            children: [
              Text(
                'We accept:',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: colors['textSecondary'],
                ),
              ),
              const SizedBox(width: 8),
              _buildAcceptedCard('VISA', colors['visa']!, Colors.white),
              const SizedBox(width: 6),
              _buildAcceptedCard('MC', colors['mastercard']!, Colors.white),
              const SizedBox(width: 6),
              _buildAcceptedCard('AMEX', colors['amex']!, Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptedCard(String text, Color color, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildCardNumberField(Map<String, Color> colors, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Card Number',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colors['textPrimary'],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800]!.withOpacity(0.5) : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CardNumberInputFormatter(),
              LengthLimitingTextInputFormatter(19), // 16 digits + 3 spaces
            ],
            style: GoogleFonts.poppins(
              color: colors['textPrimary'],
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: '•••• •••• •••• ••••',
              hintStyle: GoogleFonts.poppins(
                color: colors['textSecondary']!.withOpacity(0.5),
                fontSize: 15,
              ),
              prefixIcon: Icon(
                Icons.credit_card,
                color: colors['primary'],
                size: 20,
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _getCardTypeIcon(colors),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your card number';
              }
              if (!_isValidCardNumber(value)) {
                return 'Invalid card number';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCardholderNameField(Map<String, Color> colors, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cardholder Name',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colors['textPrimary'],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800]!.withOpacity(0.5) : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: _cardholderNameController,
            textCapitalization: TextCapitalization.words,
            style: GoogleFonts.poppins(
              color: colors['textPrimary'],
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: 'Full name as shown on card',
              hintStyle: GoogleFonts.poppins(
                color: colors['textSecondary']!.withOpacity(0.5),
                fontSize: 15,
              ),
              prefixIcon: Icon(
                Icons.person,
                color: colors['accent'],
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              if (value.trim().split(' ').length < 2) {
                return 'Please enter your full name';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExpiryDateField(Map<String, Color> colors, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expiry Date',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colors['textPrimary'],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800]!.withOpacity(0.5) : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: _expirationDateController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              ExpiryDateInputFormatter(),
              LengthLimitingTextInputFormatter(5), // MM/YY
            ],
            style: GoogleFonts.poppins(
              color: colors['textPrimary'],
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: 'MM/YY',
              hintStyle: GoogleFonts.poppins(
                color: colors['textSecondary']!.withOpacity(0.5),
                fontSize: 15,
              ),
              prefixIcon: Icon(
                Icons.calendar_today,
                color: colors['secondary'],
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Required';
              }
              if (!_isValidExpiryDate(value)) {
                return 'Invalid date';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCVVField(Map<String, Color> colors, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CVV',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colors['textPrimary'],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800]!.withOpacity(0.5) : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: _cvvController,
            obscureText: _obscureCVV,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(_cardType == 'amex' ? 4 : 3),
            ],
            style: GoogleFonts.poppins(
              color: colors['textPrimary'],
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: _cardType == 'amex' ? '••••' : '•••',
              hintStyle: GoogleFonts.poppins(
                color: colors['textSecondary']!.withOpacity(0.5),
                fontSize: 15,
              ),
              prefixIcon: Icon(
                Icons.lock,
                color: colors['error'],
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureCVV ? Icons.visibility_off : Icons.visibility,
                  color: colors['textSecondary']!.withOpacity(0.5),
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscureCVV = !_obscureCVV;
                  });
                },
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Required';
              }
              if (!_isValidCVV(value)) {
                return 'Invalid CVV';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary(
      Map<String, Color> colors,
      BoxShadow shadow,
      Border? border,
      bool isDark,
      int totalPrice
      ) {
    int playerPrice = widget.players * 1500;
    int cartPrice = widget.carts * 1400;
    int coursePrice = widget.course == '9H course' ? 1500 : 2500;
    int taxFee = 300;

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
                _buildPriceRow('Players (${widget.players}x)', '฿$playerPrice', colors),
                _buildPriceRow('Golf Carts (${widget.carts}x)', '฿$cartPrice', colors),
                _buildPriceRow('Course Fee', '฿$coursePrice', colors),
                _buildPriceRow('Tax & Service Fee', '฿$taxFee', colors),

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
                        '฿$totalPrice',
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

  Widget _buildSecurityNote(
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors['primary']!.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.security,
              color: colors['primary'],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure Payment',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors['textPrimary'],
                  ),
                ),
                Text(
                  'Your payment information is encrypted and secure',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: colors['textSecondary'],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton(Map<String, Color> colors, bool isDark, int totalPrice) {
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
        onPressed: () {
          if (_formKey.currentState?.validate() ?? false) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return LoadingScreen();
              },
            );

            Future.delayed(const Duration(seconds: 2), () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentSuccessPage(
                    course: widget.course,
                    time: widget.time,
                    date: widget.date,
                    players: widget.players,
                    carts: widget.carts,
                    amountPaid: totalPrice.toDouble(),
                  ),
                ),
              );
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      "Please fill in all fields correctly",
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ],
                ),
                backgroundColor: colors['error'],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(12),
              ),
            );
          }
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
            Icon(Icons.lock, size: 18),
            const SizedBox(width: 8),
            Text(
              'Complete Payment',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}