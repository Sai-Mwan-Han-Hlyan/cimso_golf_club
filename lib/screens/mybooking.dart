import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'booking_model.dart';
import 'booking_service.dart';
import 'booking_detail.dart';
import 'dashboard.dart';

class MyBooking extends StatefulWidget {
  final BookingModel? newBooking; // Optional parameter to receive new booking data

  const MyBooking({
    super.key,
    this.newBooking,
  });

  @override
  State<MyBooking> createState() => _MyBookingState();
}

class _MyBookingState extends State<MyBooking> {
  int _selectedIndex = 0;
  List<BookingModel> upcomingBookings = [];
  List<BookingModel> pastBookings = [];
  bool _comeFromPaymentSuccess = false;
  final BookingService _bookingService = BookingService();
  bool _isLoading = true;

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
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
    });

    // Initialize the booking service
    await _bookingService.init();

    // Add new booking if it exists
    if (widget.newBooking != null) {
      _comeFromPaymentSuccess = true; // Set flag to indicate we came from payment success

      // Get existing bookings before adding new one
      List<BookingModel> existingBookings = _bookingService.getUpcomingBookings();

      // Check if booking already exists
      bool isDuplicate = existingBookings.any((booking) =>
      booking.courseName == widget.newBooking!.courseName &&
          booking.date.isAtSameMomentAs(widget.newBooking!.date) &&
          booking.time == widget.newBooking!.time
      );

      // Only add if not a duplicate
      if (!isDuplicate) {
        await _bookingService.addBooking(widget.newBooking!);

        // Show success notification
        WidgetsBinding.instance.addPostFrameCallback((_) {
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

    // Get updated bookings from service
    setState(() {
      upcomingBookings = _bookingService.getUpcomingBookings();
      pastBookings = _bookingService.getPastBookings();
      _isLoading = false;
    });
  }

  // Handle back navigation safely
  void _handleBackNavigation(BuildContext context) {
    // If we came from payment success, go directly to dashboard
    if (_comeFromPaymentSuccess) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => Dashboard(title: 'Dashboard'),
        ),
            (route) => false, // This will remove all previous routes
      );
    } else {
      // Standard back navigation
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        // If we can't pop (we're at the root), navigate to Dashboard
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => Dashboard(title: 'Dashboard'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Handle system back button press
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _handleBackNavigation(context);
      },
      child: Scaffold(
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
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: accentColor))
            : Column(
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
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: upcomingBookings.length,
      itemBuilder: (context, index) {
        final booking = upcomingBookings[index];
        return _buildConciseBookingCard(booking, true);
      },
    );
  }

  Widget _pastBookings() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: pastBookings.length,
      itemBuilder: (context, index) {
        final booking = pastBookings[index];
        return _buildConciseBookingCard(booking, false);
      },
    );
  }

  Widget _buildConciseBookingCard(BookingModel booking, bool isUpcoming) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isUpcoming
              ? accentColor.withAlpha(51) // 0.2 opacity equivalent
              : Colors.grey.withAlpha(51), // 0.2 opacity equivalent
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BookingDetailPage(booking: booking)
              )
          );

          // If booking was modified or cancelled, refresh the list
          if (result == true) {
            _loadBookings();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Left side: Date
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isUpcoming
                      ? accentColor.withAlpha(26) // 0.1 opacity equivalent
                      : surfaceColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat("d").format(booking.date),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isUpcoming ? accentColor : secondaryTextColor,
                      ),
                    ),
                    Text(
                      DateFormat("MMM").format(booking.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: isUpcoming ? accentColor : secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Middle: Course name and time
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.courseName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: secondaryTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            booking.time,
                            style: TextStyle(
                              fontSize: 14,
                              color: secondaryTextColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.person_outline,
                            size: 14,
                            color: secondaryTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${booking.players}",
                            style: TextStyle(
                              fontSize: 14,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Right: Status and arrow
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isUpcoming
                          ? accentColor.withAlpha(26) // 0.1 opacity equivalent
                          : Colors.grey.withAlpha(26), // 0.1 opacity equivalent
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isUpcoming ? 'Upcoming' : 'Past',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isUpcoming ? accentColor : Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: secondaryTextColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}