import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'payment_success.dart';
import 'loading_screen.dart';

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

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardholderNameController = TextEditingController();
  final TextEditingController _expirationDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscureCVV = true;
  String? _cardType;

  @override
  void initState() {
    super.initState();
    _cardNumberController.addListener(_updateCardType);
  }

  @override
  void dispose() {
    _cardNumberController.removeListener(_updateCardType);
    _cardNumberController.dispose();
    _cardholderNameController.dispose();
    _expirationDateController.dispose();
    _cvvController.dispose();
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

  Widget _getCardTypeIcon() {
    if (_cardType == null) {
      return const SizedBox(width: 32, height: 32);
    }

    return Image.asset(
      'assets/$_cardType.png',
      width: 32,
      height: 32,
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Payment',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Payment Details'),
                  const SizedBox(height: 16),
                  _buildPaymentForm(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Order Summary'),
                  const SizedBox(height: 16),
                  _buildSummary(),
                  const SizedBox(height: 40),
                  _buildPaymentButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CiMSO Golf Club',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_formatDate(widget.date)}',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.time,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/Golf-Course.png',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentForm() {
    return Column(
      children: [
        _buildCardNumberInput(),
        const SizedBox(height: 16),
        _buildCardholderNameInput(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildExpirationDateInput(),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: _buildCVVInput(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardNumberInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _cardNumberController,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          CardNumberInputFormatter(),
          LengthLimitingTextInputFormatter(19), // 16 digits + 3 spaces
        ],
        decoration: InputDecoration(
          labelText: 'Card Number',
          labelStyle: GoogleFonts.poppins(
            color: Colors.black54,
            fontSize: 14,
          ),
          hintText: '•••• •••• •••• ••••',
          hintStyle: GoogleFonts.poppins(color: Colors.black38),
          prefixIcon: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.credit_card, color: Color(0xFF2E7D32)),
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _getCardTypeIcon(),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
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
    );
  }

  Widget _buildCardholderNameInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _cardholderNameController,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: 'Cardholder Name',
          labelStyle: GoogleFonts.poppins(
            color: Colors.black54,
            fontSize: 14,
          ),
          hintText: 'Name as it appears on the card',
          hintStyle: GoogleFonts.poppins(color: Colors.black38),
          prefixIcon: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.person, color: Color(0xFF1565C0)),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
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
    );
  }

  Widget _buildExpirationDateInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _expirationDateController,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          ExpiryDateInputFormatter(),
          LengthLimitingTextInputFormatter(5), // MM/YY
        ],
        decoration: InputDecoration(
          labelText: 'Expiry Date',
          labelStyle: GoogleFonts.poppins(
            color: Colors.black54,
            fontSize: 14,
          ),
          hintText: 'MM/YY',
          hintStyle: GoogleFonts.poppins(color: Colors.black38),
          prefixIcon: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.calendar_today, color: Color(0xFF5E35B1)),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
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
    );
  }

  Widget _buildCVVInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _cvvController,
        obscureText: _obscureCVV,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(_cardType == 'amex' ? 4 : 3),
        ],
        decoration: InputDecoration(
          labelText: 'CVV',
          labelStyle: GoogleFonts.poppins(
            color: Colors.black54,
            fontSize: 14,
          ),
          hintText: _cardType == 'amex' ? '••••' : '•••',
          hintStyle: GoogleFonts.poppins(color: Colors.black38),
          prefixIcon: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.lock, color: Color(0xFFD32F2F)),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureCVV ? Icons.visibility_off : Icons.visibility,
              color: Colors.black45,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _obscureCVV = !_obscureCVV;
              });
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
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
    );
  }

  Widget _buildSummary() {
    int playerPrice = widget.players * 1500;
    int cartPrice = widget.carts * 1400;
    int coursePrice = 1500;
    int taxFee = 300;
    int totalPrice = playerPrice + cartPrice + coursePrice + taxFee;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSummaryRow('Course: ${widget.course}', '฿ $coursePrice'),
            _buildSummaryDivider(),
            _buildSummaryRow('${widget.players}x Players', '฿ $playerPrice'),
            _buildSummaryDivider(),
            _buildSummaryRow('${widget.carts}x Golf Cart', '฿ $cartPrice'),
            _buildSummaryDivider(),
            _buildSummaryRow('Tax & Fee', '฿ $taxFee'),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(
                color: Colors.grey.withOpacity(0.2),
                thickness: 1.5,
              ),
            ),
            _buildSummaryRow('Total', '฿ $totalPrice',
              isTotal: true,
              valueColor: const Color(0xFF2E7D32),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(
        color: Colors.grey.withOpacity(0.1),
        thickness: 1,
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: isTotal ? 17 : 15,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
              color: isTotal ? Colors.black87 : Colors.black54,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isTotal ? 18 : 15,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              color: valueColor ?? (isTotal ? Colors.black87 : Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton() {
    return SizedBox(
      width: double.infinity,
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

              int playerPrice = widget.players * 1500;
              int cartPrice = widget.carts * 1400;
              int coursePrice = 1500;
              int taxFee = 300;
              int totalPrice = playerPrice + cartPrice + coursePrice + taxFee;

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
                content: Text(
                  "Please fill in all fields correctly",
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                backgroundColor: Colors.red[700],
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
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 2,
        ),
        child: Text(
          'Complete Payment',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }
}