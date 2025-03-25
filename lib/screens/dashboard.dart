import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cimso_golf_booking/screens/booking.dart';
import 'package:cimso_golf_booking/screens/mybooking.dart';
import 'package:cimso_golf_booking/screens/Profile_Page.dart';
import 'package:cimso_golf_booking/screens/GolfCourseDetailPage.dart';
// Update this import to point to your actual AuthService location
import 'auth_service.dart';
import 'dashboard_sidebar.dart';
import 'dashboard_bottombar.dart';
import 'notification.dart';

// Model for golf courses
class GolfCourse {
  final String name;
  final String location;
  final double rating;
  final String distance;

  GolfCourse({
    required this.name,
    required this.location,
    required this.rating,
    required this.distance,
  });
}

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

  // User profile data - expanded to include all profile fields
  String userName = 'William Dexter';
  String userEmail = 'willdex234@gmail.com';
  String userPhone = '';
  String? userGender;
  DateTime? userDob;
  File? userProfileImage;

  // List of all golf courses
  final List<GolfCourse> _allCourses = [
    GolfCourse(
      name: 'CIMSO Golf Club',
      location: '54 Benar Ed, Beachoro',
      rating: 4.8,
      distance: '3.2 mi',
    ),
    GolfCourse(
      name: 'Geo J Park Golf Course',
      location: '4 Foe Ed, Joroeme',
      rating: 4.5,
      distance: '5.7 mi',
    ),
    // Add more courses as needed
  ];

  // List of filtered courses that will be displayed
  late List<GolfCourse> _filteredCourses;

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

    // Initialize filtered courses with all courses
    _filteredCourses = List.from(_allCourses);

    // Add listener to search controller
    _searchController.addListener(_performSearch);

    // Load user data when the dashboard initializes
    _loadUserData();
  }

  // Search functionality
  void _performSearch() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        // If search is empty, show all courses
        _filteredCourses = List.from(_allCourses);
      } else {
        // Filter courses based on name or location containing the query
        _filteredCourses = _allCourses
            .where((course) =>
        course.name.toLowerCase().contains(query) ||
            course.location.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  // Load user data from AuthService - updated to load all profile data
  Future<void> _loadUserData() async {
    final currentUser = await AuthService.getCurrentUser();
    if (currentUser != null && mounted) {
      setState(() {
        userName = currentUser.username;
        userEmail = currentUser.email;
        userPhone = currentUser.phone ?? '';
        userGender = currentUser.gender;
        userDob = currentUser.dateOfBirth;

        // Load profile image if path exists
        if (currentUser.profileImagePath != null) {
          AuthService.loadProfileImage(currentUser.profileImagePath)
              .then((imageFile) {
            if (imageFile != null && mounted) {
              setState(() {
                userProfileImage = imageFile;
              });
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_performSearch);
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Method to navigate to profile page with proper callback
  void _navigateToProfilePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(
          onProfileUpdate: (name, email, phone, gender, dob, image) async {
            // Save the profile data to persistent storage
            final success = await AuthService.updateUserProfile(
              email: email,
              name: name,
              phone: phone,
              gender: gender,
              dateOfBirth: dob,
              profileImage: image,
            );

            if (success && mounted) {
              setState(() {
                userName = name;
                userEmail = email;
                userPhone = phone;
                userGender = gender;
                userDob = dob;
                userProfileImage = image;
              });
            }
          },
          initialName: userName,
          initialEmail: userEmail,
          initialPhone: userPhone,
          initialGender: userGender,
          initialDob: userDob,
          initialImage: userProfileImage,
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      // Navigate to MyBooking page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyBooking()),
      );
    } else if (index == 2) {
      // Navigate to Profile page with updated callback
      _navigateToProfilePage();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // Simplified and minimalist color scheme - defined here and passed to components
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
      drawer: DashboardSidebar(
        userName: userName,
        userEmail: userEmail,
        selectedIndex: _selectedIndex,
        onProfileTap: () {
          Navigator.pop(context); // Close the drawer
          _navigateToProfilePage();
        },
        onDashboardTap: () {
          Navigator.pop(context);
          setState(() {
            _selectedIndex = 0;
          });
        },
        onBookingsTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyBooking()),
          );
        },
        accentColor: accentColor,
        textColor: textColor,
        secondaryTextColor: secondaryTextColor,
      ),
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
                  onChanged: (_) => _performSearch(),
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
                          _performSearch(); // Update results when cleared
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

              // Minimalist golf course cards with search results
              Expanded(
                child: _filteredCourses.isEmpty
                    ? Center(
                  child: Text(
                    'No golf courses found',
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 16,
                    ),
                  ),
                )
                    : ListView.builder(
                  itemCount: _filteredCourses.length,
                  itemBuilder: (context, index) {
                    final course = _filteredCourses[index];
                    return _buildMinimalistCourseCard(
                      course.name,
                      course.location,
                      rating: course.rating,
                      distance: course.distance,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: DashboardBottomBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        accentColor: accentColor,
        backgroundColor: backgroundColor,
        secondaryTextColor: secondaryTextColor,
      ),
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
          icon: const Icon(Icons.notifications),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationScreen()),
            );
          },
        ),
        // Added profile avatar in app bar for quick profile access - updated with profile image
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: _navigateToProfilePage, // Updated to use centralized method
            child: CircleAvatar(
              radius: 16,
              backgroundColor: userProfileImage != null
                  ? Colors.transparent
                  : accentColor.withOpacity(0.2),
              backgroundImage: userProfileImage != null
                  ? FileImage(userProfileImage!)
                  : null,
              child: userProfileImage == null
                  ? Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'W',
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              )
                  : null,
            ),
          ),
        ),
      ],
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
}