import 'package:flutter/material.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:cimso_golf_booking/screens/booking.dart';
import 'package:cimso_golf_booking/screens/mybooking.dart';
import 'package:cimso_golf_booking/screens/Profile_Page.dart';
import 'package:cimso_golf_booking/screens/GolfCourseDetailPage.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'dashboard_sidebar.dart';
import 'dashboard_bottombar.dart';
import 'notification.dart';
import 'package:cimso_golf_booking/providers/theme_provider.dart';

// Model for golf courses
class GolfCourse {
  final String name;
  final String location;
  final double rating;
  final String distance;
  final String imagePath;

  GolfCourse({
    required this.name,
    required this.location,
    required this.rating,
    required this.distance,
    this.imagePath = 'assets/Golf-Course.png',
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
  late ScrollController _scrollController;
  double _scrollOffset = 0.0;

  // User profile data
  String userName = 'William Dexter';
  String userEmail = 'willdex234@gmail.com';
  String userPhone = '';
  String? userGender;
  DateTime? userDob;
  File? userProfileImage;

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

  // List of all golf courses
  final List<GolfCourse> _allCourses = [
    GolfCourse(
      name: 'CIMSO Golf Club',
      location: '54 Benar Rd, Bangkok',
      rating: 4.8,
      distance: '3.2 mi',
      imagePath: 'assets/Golf-Course.png',
    ),
    GolfCourse(
      name: 'Geo J Park Golf Course',
      location: '4 Foe Ed, Joroeme',
      rating: 4.5,
      distance: '5.7 mi',
      imagePath: 'assets/Golf-Course-2.png',
    ),
    GolfCourse(
      name: 'Royal Bangkok Golf Club',
      location: '120 Siam Rd, Bangkok',
      rating: 4.7,
      distance: '7.3 mi',
      imagePath: 'assets/Golf-Course-3.jpg',
    ),
    GolfCourse(
      name: 'Phuket Islands Golf',
      location: '88 Beach Ave, Phuket',
      rating: 4.9,
      distance: '12.5 mi',
      imagePath: 'assets/Golf-Course-4.jpg',
    ),
  ];

  // List of filtered courses that will be displayed
  late List<GolfCourse> _filteredCourses;

  // List of featured golf courses
  late List<GolfCourse> _featuredCourses;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _buttonAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Initialize filtered courses with all courses
    _filteredCourses = List.from(_allCourses);

    // Initialize featured courses (using the first two for this example)
    _featuredCourses = _allCourses.take(2).toList();

    // Add listener to search controller
    _searchController.addListener(_performSearch);

    // Load user data when the dashboard initializes
    _loadUserData();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
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

  // Load user data from AuthService
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
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
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

  @override
  Widget build(BuildContext context) {
    // Get the ThemeProvider and check the current theme mode
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

    // Get status bar height to ensure proper spacing
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: colors['background'],
      extendBodyBehindAppBar: false,
      appBar: _buildEnhancedAppBar(colors, isDark),
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
        accentColor: colors['primary']!,
        textColor: colors['textPrimary']!,
        secondaryTextColor: colors['textSecondary']!,
      ),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Welcome header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
              decoration: BoxDecoration(
                color: colors['primary'],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome message
                  Text(
                    'Welcome,',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    userName,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),

                  const SizedBox(height: 20),

                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: colors['card'],
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
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
                      style: GoogleFonts.poppins(
                        color: colors['textPrimary'],
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search golf courses',
                        hintStyle: GoogleFonts.poppins(
                          color: colors['textSecondary']!.withOpacity(0.5),
                          fontSize: 15,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: colors['primary'],
                          size: 20,
                        ),
                        suffixIcon: _isSearching && _searchController.text.isNotEmpty
                            ? IconButton(
                          icon: Icon(
                              Icons.close,
                              size: 18,
                              color: colors['textSecondary']
                          ),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _performSearch();
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
                ],
              ),
            ),
          ),

          // Featured courses section
          SliverToBoxAdapter(
            child: _searchController.text.isEmpty
                ? _buildFeaturedSection(colors, cardShadow, cardBorder, isDark)
                : const SizedBox.shrink(),
          ),

          // Available courses section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
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
                        _searchController.text.isEmpty
                            ? 'Nearby Golf Courses'
                            : 'Search Results',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colors['textPrimary'],
                        ),
                      ),
                    ],
                  ),
                  if (_searchController.text.isEmpty)
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: colors['primary'],
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'View All',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Course list with enhanced design
          SliverPadding(
            padding: const EdgeInsets.all(24.0),
            sliver: _filteredCourses.isEmpty
                ? SliverToBoxAdapter(
              child: _buildEmptyState(colors, isDark),
            )
                : SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final course = _filteredCourses[index];
                  return _buildEnhancedCourseCard(
                      course,
                      colors,
                      cardShadow,
                      cardBorder,
                      isDark
                  );
                },
                childCount: _filteredCourses.length,
              ),
            ),
          ),

          // Bottom padding for better scrolling
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
      bottomNavigationBar: DashboardBottomBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        accentColor: colors['primary']!,
        backgroundColor: colors['card']!,
        secondaryTextColor: colors['textSecondary']!,
      ),
    );
  }

  AppBar _buildEnhancedAppBar(Map<String, Color> colors, bool isDark) {
    return AppBar(
      backgroundColor: colors['primary'],
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 70,
      title: AnimatedOpacity(
        opacity: _scrollOffset > 60 ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Text(
          'CiMSO Golf',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      centerTitle: false,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.menu, color: Colors.white, size: 18),
          ),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      actions: [
        // Notifications button
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 18),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationScreen()),
            );
          },
        ),

        // User profile button
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: _navigateToProfilePage,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: userProfileImage != null
                    ? Colors.transparent
                    : Colors.white.withOpacity(0.2),
                backgroundImage: userProfileImage != null
                    ? FileImage(userProfileImage!)
                    : null,
                child: userProfileImage == null
                    ? Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'W',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                )
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedSection(
      Map<String, Color> colors,
      BoxShadow shadow,
      Border? border,
      bool isDark
      ) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 30, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: colors['accent'],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Featured Courses',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colors['textPrimary'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _featuredCourses.length,
              itemBuilder: (context, index) {
                final course = _featuredCourses[index];
                return _buildFeaturedCourseCard(
                    course,
                    colors,
                    shadow,
                    border,
                    isDark
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCourseCard(
      GolfCourse course,
      Map<String, Color> colors,
      BoxShadow shadow,
      Border? border,
      bool isDark
      ) {
    return Container(
      width: 220,
      height: 200, // Reduced height to prevent overflow
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: colors['card'],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [shadow],
        border: border,
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GolfCourseDetailPage(
                courseName: course.name,
                location: course.location,
                rating: course.rating,
                reviewCount: 15,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Container(
                height: 110, // Slightly reduced height
                decoration: BoxDecoration(
                  color: colors['primary']!.withOpacity(0.1),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        course.imagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8, // Reduced from 12
                      right: 8, // Reduced from 12
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // Slightly smaller padding
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 12, // Smaller icon
                            ),
                            const SizedBox(width: 2), // Reduced spacing
                            Text(
                              course.rating.toString(),
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 10, // Smaller font
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Course details - using Expanded to ensure it fits the remaining space
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10), // Reduced padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.name,
                      style: GoogleFonts.poppins(
                        fontSize: 14, // Smaller font
                        fontWeight: FontWeight.w600,
                        color: colors['textPrimary'],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2), // Reduced spacing
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: colors['textSecondary'],
                          size: 12, // Smaller icon
                        ),
                        const SizedBox(width: 2), // Reduced spacing
                        Expanded(
                          child: Text(
                            course.location,
                            style: GoogleFonts.poppins(
                              fontSize: 10, // Smaller font
                              color: colors['textSecondary'],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(), // Push the bottom row to the bottom
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // Smaller padding
                          decoration: BoxDecoration(
                            color: colors['primary']!.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Book Now',
                            style: GoogleFonts.poppins(
                              fontSize: 10, // Smaller font
                              fontWeight: FontWeight.w500,
                              color: colors['primary'],
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.directions_car,
                          color: colors['textSecondary'],
                          size: 12, // Smaller icon
                        ),
                        const SizedBox(width: 2), // Reduced spacing
                        Text(
                          course.distance,
                          style: GoogleFonts.poppins(
                            fontSize: 10, // Smaller font
                            color: colors['textSecondary'],
                          ),
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
    );
  }

  Widget _buildEnhancedCourseCard(
      GolfCourse course,
      Map<String, Color> colors,
      BoxShadow shadow,
      Border? border,
      bool isDark
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors['card'],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [shadow],
        border: border,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GolfCourseDetailPage(
                  courseName: course.name,
                  location: course.location,
                  rating: course.rating,
                  reviewCount: 15,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Course image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: colors['primary']!.withOpacity(0.1),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            course.imagePath,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            color: Colors.black.withOpacity(0.6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 12,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  course.rating.toString(),
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Course details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colors['textPrimary'],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: colors['textSecondary'],
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              course.location,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: colors['textSecondary'],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            course.distance,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: colors['textSecondary'],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildActionButton(
                            'Details',
                            Icons.info_outline,
                            colors['accent']!,
                            colors,
                                () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GolfCourseDetailPage(
                                    courseName: course.name,
                                    location: course.location,
                                    rating: course.rating,
                                    reviewCount: 15,
                                  ),
                                ),
                              );
                            },
                            isDark,
                          ),
                          const SizedBox(width: 12),
                          _buildActionButton(
                            'Book',
                            Icons.golf_course,
                            colors['primary']!,
                            colors,
                                () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const BookingPage(),
                                ),
                              );
                            },
                            isDark,
                            isPrimary: true,
                          ),
                        ],
                      ),
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

  Widget _buildActionButton(
      String text,
      IconData icon,
      Color color,
      Map<String, Color> colors,
      VoidCallback onPressed,
      bool isDark,
      {bool isPrimary = false}
      ) {
    return Expanded(
      child: Material(
        color: isPrimary
            ? color
            : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: isPrimary
                      ? Colors.white
                      : color,
                ),
                const SizedBox(width: 4),
                Text(
                  text,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isPrimary
                        ? Colors.white
                        : color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(Map<String, Color> colors, bool isDark) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: colors['card'],
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: Colors.grey[800]!, width: 1) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: colors['textSecondary']!.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No golf courses found',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: colors['textSecondary'],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: colors['textSecondary']!.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}