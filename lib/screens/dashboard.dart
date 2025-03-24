import 'package:flutter/material.dart';
import 'package:cimso_golf_booking/screens/booking.dart';
import 'package:cimso_golf_booking/screens/mybooking.dart';

import 'package:cimso_golf_booking/screens/Profile_Page.dart';
import 'package:cimso_golf_booking/screens//GolfCourseDetailPage.dart';

// Main Dashboard Class
class Dashboard extends StatefulWidget {
  final String title;



  const Dashboard({Key? key, required this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DashboardState();
  }
}

class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _buttonAnimation;

  // User profile data
  String userName = 'William Dexter';
  String userEmail = 'willdex234@gmail.com';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _buttonAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      // Navigate to MyBooking page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyBooking()),
      );
    } else if (index == 2) {
      // Navigate to Profile page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(
            onProfileUpdate: (name, email) {
              setState(() {
                userName = name;
                userEmail = email;
              });
            },
            initialName: userName,
            initialEmail: userEmail,
          ),
        ),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // Simplified and minimalist color scheme
  final Color primaryColor = Colors.black;
  final Color accentColor = const Color(0xFF4CAF50); // A subtle green
  final Color backgroundColor = Colors.white;
  final Color surfaceColor = const Color(0xFFF9F9F9); // Very light gray
  final Color textColor = Colors.black87;
  final Color secondaryTextColor = Colors.black54;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildMinimalistAppBar(),
      drawer: _buildMinimalistDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section with minimalist design - now uses dynamic userName
              Text(
                'Welcome, $userName',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 32),

              // Animated search bar
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: _isSearching ? surfaceColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isSearching ? Colors.transparent : Colors.black12,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onTap: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                  onSubmitted: (_) {
                    setState(() {
                      _isSearching = false;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search golf courses',
                    hintStyle: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: secondaryTextColor,
                      size: 20,
                    ),
                    suffixIcon: _isSearching
                        ? IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _isSearching = false;
                        });
                      },
                    )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Section header with minimalist style
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Available Courses',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: accentColor,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Minimalist golf course cards
              Expanded(
                child: ListView(
                  children: [
                    _buildMinimalistCourseCard(
                      'CIMSO Golf Club',
                      '54 Benar Ed, Beachoro',
                      rating: 4.8,
                      distance: '3.2 mi',
                    ),
                    _buildMinimalistCourseCard(
                      'Geo J Park Golf Course',
                      '4 Foe Ed, Joroeme',
                      rating: 4.5,
                      distance: '5.7 mi',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildMinimalistBottomNav(),
    );
  }

  AppBar _buildMinimalistAppBar() {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      title: const Text(''),
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, size: 20),
          color: textColor,
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, size: 20),
          color: textColor,
          onPressed: () {},
        ),
        // Added profile avatar in app bar for quick profile access
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(
                    onProfileUpdate: (name, email) {
                      setState(() {
                        userName = name;
                        userEmail = email;
                      });
                    },
                    initialName: userName,
                    initialEmail: userEmail,
                  ),
                ),
              );
            },
            child: CircleAvatar(
              radius: 16,
              backgroundColor: accentColor.withOpacity(0.2),
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'W',
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMinimalistDrawer() {
    return Drawer(
      backgroundColor: backgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 120,
            padding: const EdgeInsets.all(24),
            alignment: Alignment.bottomLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildDrawerItem(Icons.dashboard_outlined, 'Dashboard', isSelected: _selectedIndex == 0, onTap: () {
            Navigator.pop(context);
            setState(() {
              _selectedIndex = 0;
            });
          }),
          _buildDrawerItem(Icons.person_outline, 'Profile', onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(
                  onProfileUpdate: (name, email) {
                    setState(() {
                      userName = name;
                      userEmail = email;
                    });
                  },
                  initialName: userName,
                  initialEmail: userEmail,
                ),
              ),
            );
          }),
          _buildDrawerItem(Icons.calendar_today_outlined, 'My Bookings', onTap: () {
            Navigator.pop(context); // Close drawer
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyBooking()),
            );
          }),
          _buildDrawerItem(Icons.notifications_outlined, 'Notifications'),
          _buildDrawerItem(Icons.credit_card_outlined, 'Payment Methods'),
          const Divider(height: 1),
          _buildDrawerItem(Icons.settings_outlined, 'Settings'),
          _buildDrawerItem(Icons.help_outline, 'Help & Support'),
          _buildDrawerItem(Icons.logout_outlined, 'Log Out'),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, {bool isSelected = false, VoidCallback? onTap}) {
    return ListTile(
      dense: true,
      leading: Icon(
        icon,
        size: 20,
        color: isSelected ? accentColor : secondaryTextColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? accentColor : textColor,
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
      ),
      selected: isSelected,
      selectedTileColor: isSelected ? accentColor.withOpacity(0.08) : null,
      onTap: onTap ?? () {},
    );
  }

  Widget _buildMinimalistCourseCard(String name, String location, {required double rating, required String distance}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course image - minimalist style
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Center(
              child: Icon(
                Icons.golf_course,
                size: 32,
                color: accentColor.withOpacity(0.3),
              ),
            ),
          ),

          // Course details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star, color: accentColor, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            rating.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: secondaryTextColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          location,
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      distance,
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInteractiveButton(
                        text: 'Details',
                        isOutlined: true,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GolfCourseDetailPage(
                                courseName: name,
                                location: location,
                                rating: rating,
                                reviewCount: 15, // You can set a default or add this to your card data
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInteractiveButton(
                        text: 'Book Now',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const BookingPage()),
                          );
                        },
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

  Widget _buildInteractiveButton({
    required String text,
    required VoidCallback onPressed,
    bool isOutlined = false,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTapDown: (_) => _animationController.forward(),
          onTapUp: (_) => _animationController.reverse(),
          onTapCancel: () => _animationController.reverse(),
          onTap: onPressed,
          child: AnimatedBuilder(
            animation: _buttonAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _buttonAnimation.value,
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: isOutlined ? Colors.transparent : accentColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isOutlined ? Colors.black12 : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      text,
                      style: TextStyle(
                        color: isOutlined ? textColor : Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMinimalistBottomNav() {
    return Container(
      height: 60,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_outlined, 'Home', 0),
          _buildNavItem(Icons.calendar_today_outlined, 'Bookings', 1),
          _buildNavItem(Icons.person_outline, 'Profile', 2),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? accentColor : secondaryTextColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? accentColor : secondaryTextColor,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}