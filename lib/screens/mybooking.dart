import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'booking_model.dart';
import 'dashboard.dart';

class MyBooking extends StatefulWidget {
  final BookingModel? newBooking; // Optional parameter to receive new booking data

  const MyBooking({
    Key? key,
    this.newBooking,
  }) : super(key: key);

  @override
  State<MyBooking> createState() => _MyBookingState();
}

class _MyBookingState extends State<MyBooking> {
  int _selectedIndex = 0;
  List<BookingModel> upcomingBookings = [];
  List<BookingModel> pastBookings = [];

  // Simplified and minimalist color scheme
  final Color primaryColor = Colors.black;
  final Color accentColor = const Color(0xFF4CAF50); // A subtle green
  final Color backgroundColor = Colors.white;
  final Color surfaceColor = const Color(0xFFF9F9F9); // Very light gray
  final Color textColor = Colors.black87;
  final Color secondaryTextColor = Colors.black54;

  @override
  void initState() {
    super.initState();

    // Add new booking if it exists
    if (widget.newBooking != null) {
      // We do this in a microtask to ensure it happens after the initial build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          upcomingBookings.insert(0, widget.newBooking!);
        });

        // Show a success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking added successfully!'),
            backgroundColor: accentColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      });
    }
  }

  // Handle back navigation safely
  // Update this method in your MyBooking class (from paste.txt)
  void _handleBackNavigation(BuildContext context) {
    // Check if we can pop the current route
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      // If we can't pop (we're at the root), navigate to Dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => Dashboard(
              title: 'Dashboard', )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text(
          'My Bookings',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          color: textColor,
          onPressed: () => _handleBackNavigation(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, size: 20),
            color: textColor,
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _bookingTab("Upcoming", 0),
                const SizedBox(width: 32),
                _bookingTab("Past", 1),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _selectedIndex == 0
                ? upcomingBookings.isEmpty
                ? _emptyState("No upcoming bookings")
                : _upcomingBookings()
                : pastBookings.isEmpty
                ? _emptyState("No past bookings")
                : _pastBookings(),
          ),
        ],
      ),
      bottomNavigationBar: _buildMinimalistBottomNav(),
    );
  }

  Widget _emptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookingTab(String title, int index) {
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              color: isSelected ? accentColor : secondaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          if (isSelected)
            Container(
              height: 2,
              width: 24,
              color: accentColor,
            ),
        ],
      ),
    );
  }

  Widget _upcomingBookings() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: upcomingBookings.length,
      itemBuilder: (context, index) {
        final booking = upcomingBookings[index];
        return _bookingCard(
          booking.courseName,
          DateFormat("MMMM d, yyyy").format(booking.date),
          booking.time,
          "${booking.players} ${booking.players == 1 ? 'Player' : 'Players'}",
          booking.carts != null ? "${booking.carts} ${booking.carts == 1 ? 'Cart' : 'Carts'}" : null,
          true,
          booking.amountPaid,
        );
      },
    );
  }

  Widget _pastBookings() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: pastBookings.length,
      itemBuilder: (context, index) {
        final booking = pastBookings[index];
        return _bookingCard(
          booking.courseName,
          DateFormat("MMMM d, yyyy").format(booking.date),
          booking.time,
          "${booking.players} ${booking.players == 1 ? 'Player' : 'Players'}",
          booking.carts != null ? "${booking.carts} ${booking.carts == 1 ? 'Cart' : 'Carts'}" : null,
          false,
          booking.amountPaid,
        );
      },
    );
  }

  Widget _bookingCard(
      String course,
      String date,
      String time,
      String players,
      String? carts,
      bool isUpcoming,
      double? amountPaid,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUpcoming ? accentColor.withOpacity(0.1) : surfaceColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.golf_course_rounded,
                      size: 18,
                      color: isUpcoming ? accentColor : secondaryTextColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      course,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isUpcoming ? textColor : secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isUpcoming
                        ? accentColor.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isUpcoming ? 'Upcoming' : 'Completed',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isUpcoming ? accentColor : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _detailRow(Icons.calendar_today_outlined, 'Date', date),
                const SizedBox(height: 12),
                _detailRow(Icons.access_time_rounded, 'Time', time),
                const SizedBox(height: 12),
                _detailRow(Icons.person_outline_rounded, 'Players', players),
                if (carts != null) ...[
                  const SizedBox(height: 12),
                  _detailRow(Icons.electric_car_outlined, 'Carts', carts),
                ],
                if (amountPaid != null) ...[
                  const SizedBox(height: 12),
                  _detailRow(
                    Icons.payment_outlined,
                    'Amount Paid',
                    '฿ ${amountPaid.toStringAsFixed(2)}',
                    highlight: true,
                  ),
                ],
              ],
            ),
          ),
          if (isUpcoming)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      // Implement cancel/reschedule functionality
                    },
                    icon: const Icon(Icons.schedule, size: 18),
                    label: const Text('Reschedule'),
                    style: TextButton.styleFrom(
                      foregroundColor: secondaryTextColor,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // Implement cancel booking functionality
                    },
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Cancel'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red[400],
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, {bool highlight = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: highlight ? accentColor : secondaryTextColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryTextColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
                  color: highlight ? accentColor : textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMinimalistBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _bottomNavItem(Icons.home_outlined, 'Home', false),
            _bottomNavItem(Icons.search_outlined, 'Explore', false),
            _bottomNavItem(Icons.event_note_outlined, 'Bookings', true),
            _bottomNavItem(Icons.person_outline_rounded, 'Profile', false),
          ],
        ),
      ),
    );
  }

  Widget _bottomNavItem(IconData icon, String label, bool isSelected) {
    return InkWell(
      onTap: () {
        // Navigation logic would go here
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? accentColor : secondaryTextColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                color: isSelected ? accentColor : secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}