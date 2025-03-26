import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cimso_golf_booking/screens/booking.dart';
import 'package:provider/provider.dart';
import 'package:cimso_golf_booking/providers/theme_provider.dart';

class GolfCourseDetailPage extends StatefulWidget {
  final String courseName;
  final String location;
  final double rating;
  final int reviewCount;
  final bool hasNineHole; // Added to support 9-hole option

  const GolfCourseDetailPage({
    Key? key,
    required this.courseName,
    required this.location,
    required this.rating,
    required this.reviewCount,
    this.hasNineHole = true, // Default to true to support both options
  }) : super(key: key);

  @override
  State<GolfCourseDetailPage> createState() => _GolfCourseDetailPageState();
}

class _GolfCourseDetailPageState extends State<GolfCourseDetailPage> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  double _scrollOffset = 0.0;
  bool _isFavorite = false;

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
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut)
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
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

    // Calculate opacity for app bar title based on scroll position
    final double titleOpacity = _scrollOffset > 150 ? 1.0 : 0.0;

    return Scaffold(
      backgroundColor: colors['background'],
      extendBodyBehindAppBar: true,
      // Custom app bar that transitions based on scroll
      appBar: AppBar(
        backgroundColor: _scrollOffset > 150
            ? colors['primary']
            : Colors.transparent,
        elevation: _scrollOffset > 150 ? 4 : 0,
        centerTitle: true,
        title: AnimatedOpacity(
          opacity: titleOpacity,
          duration: const Duration(milliseconds: 200),
          child: Text(
            widget.courseName,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _scrollOffset > 150
                  ? Colors.transparent
                  : Colors.black.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _scrollOffset > 150
                    ? Colors.transparent
                    : Colors.black.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : Colors.white,
                size: 18,
              ),
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _scrollOffset > 150
                    ? Colors.transparent
                    : Colors.black.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.share, color: Colors.white, size: 18),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // Main scrollable content
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header image
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 300,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Course image with gradient overlay
                        ShaderMask(
                          shaderCallback: (rect) {
                            return LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.8),
                              ],
                              stops: const [0.5, 1.0],
                            ).createShader(rect);
                          },
                          blendMode: BlendMode.srcOver,
                          child: Image.asset(
                            'assets/Golf-Course.png',
                            fit: BoxFit.cover,
                          ),
                        ),

                        // Course name and location overlay
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.courseName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.location_on, color: Colors.white, size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            widget.location,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.star, color: Colors.amber, size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${widget.rating} (${widget.reviewCount})',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
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
                ),

                // Rating stars above content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Row(
                      children: List.generate(5, (index) {
                        final bool isHalf = index == widget.rating.floor() && widget.rating % 1 != 0;
                        final bool isFull = index < widget.rating.floor();

                        return Icon(
                          isFull ? Icons.star : (isHalf ? Icons.star_half : Icons.star_border),
                          color: Colors.amber,
                          size: 20,
                        );
                      }),
                    ),
                  ),
                ),

                // Course options section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Course Options', colors),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildCourseOptionCard(
                                title: '18 Holes',
                                price: '฿ 2,500',
                                subtitle: 'Championship Course',
                                details: ['Par 72', '6,800 yards', 'Full Experience'],
                                colors: colors,
                                cardShadow: cardShadow,
                                cardBorder: cardBorder,
                              ),
                            ),
                            if (widget.hasNineHole) ...[
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildCourseOptionCard(
                                  title: '9 Holes',
                                  price: '฿ 1,500',
                                  subtitle: 'Quick Play',
                                  details: ['Par 36', '3,400 yards', 'Front Nine'],
                                  colors: colors,
                                  cardShadow: cardShadow,
                                  cardBorder: cardBorder,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // About section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('About', colors),
                        const SizedBox(height: 16),
                        Text(
                          'This beautifully designed course offers challenges for golfers of all skill levels with meticulously maintained fairways and stunning water features throughout its layout.',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: colors['textSecondary'],
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Features section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Amenities & Features', colors),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _buildFeatureChip('Pro Shop', Icons.golf_course, colors),
                            _buildFeatureChip('Driving Range', Icons.sports_golf, colors),
                            _buildFeatureChip('Restaurant', Icons.restaurant, colors),
                            _buildFeatureChip('Bar', Icons.local_bar, colors),
                            _buildFeatureChip('Golf Carts', Icons.directions_car, colors),
                            _buildFeatureChip('Lessons', Icons.school, colors),
                            _buildFeatureChip('Locker Rooms', Icons.luggage, colors),
                            _buildFeatureChip('Club Rentals', Icons.sports_golf, colors),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Course specifications section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Course Specifications', colors),
                        const SizedBox(height: 16),

                        Container(
                          decoration: BoxDecoration(
                            color: colors['card'],
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [cardShadow],
                            border: cardBorder,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _buildSpecificationRow('Greens', 'Bent Grass', Icons.grass, colors),
                                const SizedBox(height: 16),
                                _buildSpecificationRow('Fairways', 'Bermuda', Icons.grain, colors),
                                const SizedBox(height: 16),
                                _buildSpecificationRow('Difficulty', 'Intermediate', Icons.trending_up, colors),
                                const SizedBox(height: 16),
                                _buildSpecificationRow('Terrain', 'Rolling Hills', Icons.landscape, colors),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Reviews section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSectionTitle('Reviews', colors),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                foregroundColor: colors['primary'],
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'See All',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_forward, size: 16),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildReviewCard(
                          name: 'John S.',
                          avatar: 'J',
                          rating: 5.0,
                          comment: 'Excellent course conditions and challenging layout. Will definitely play here again.',
                          timeAgo: '2 days ago',
                          colors: colors,
                          cardShadow: cardShadow,
                          cardBorder: cardBorder,
                        ),
                        const SizedBox(height: 16),
                        _buildReviewCard(
                          name: 'Sarah J.',
                          avatar: 'S',
                          rating: 4.5,
                          comment: 'Great value and friendly staff. The 9-hole option is perfect for a quick round.',
                          timeAgo: '1 week ago',
                          colors: colors,
                          cardShadow: cardShadow,
                          cardBorder: cardBorder,
                        ),
                      ],
                    ),
                  ),
                ),

                // Map section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Location', colors),
                        const SizedBox(height: 16),
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            color: colors['card'],
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [cardShadow],
                            border: cardBorder,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              children: [
                                // Map placeholder
                                Container(
                                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                                  width: double.infinity,
                                  height: double.infinity,
                                  child: Center(
                                    child: Icon(
                                      Icons.map,
                                      size: 48,
                                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                                    ),
                                  ),
                                ),

                                // Location pin
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: colors['primary'],
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: colors['primary']!.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),

                                // Directions button
                                Positioned(
                                  bottom: 16,
                                  right: 16,
                                  child: ElevatedButton.icon(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colors['card'],
                                      foregroundColor: colors['primary'],
                                      elevation: 2,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    icon: const Icon(Icons.directions, size: 16),
                                    label: Text(
                                      'Directions',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
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

                // Extra space at bottom for the floating button
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            ),

            // Floating booking button at bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: colors['card'],
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.5)
                          : Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                  border: isDark
                      ? Border(top: BorderSide(color: Colors.grey[800]!, width: 1))
                      : null,
                ),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BookingPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors['primary'],
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Book Tee Time',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.golf_course, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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

  Widget _buildCourseOptionCard({
    required String title,
    required String price,
    required String subtitle,
    required List<String> details,
    required Map<String, Color> colors,
    required BoxShadow cardShadow,
    required Border? cardBorder,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors['card'],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [cardShadow],
        border: cardBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors['textPrimary'],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors['primary']!.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    price,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colors['primary'],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: colors['textSecondary'],
              ),
            ),
            const SizedBox(height: 12),
            ...details.map((detail) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 14,
                    color: colors['success'],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      detail,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: colors['textSecondary'],
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(String label, IconData icon, Map<String, Color> colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors['primary']!.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: colors['primary'],
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: colors['textPrimary'],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationRow(String label, String value, IconData icon, Map<String, Color> colors) {
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
            size: 16,
            color: colors['primary'],
          ),
        ),
        const SizedBox(width: 12),
        Column(
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
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colors['textPrimary'],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewCard({
    required String name,
    required String avatar,
    required double rating,
    required String comment,
    required String timeAgo,
    required Map<String, Color> colors,
    required BoxShadow cardShadow,
    required Border? cardBorder,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors['card'],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [cardShadow],
        border: cardBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors['primary']!.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      avatar,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors['primary'],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name and time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colors['textPrimary'],
                        ),
                      ),
                      Text(
                        timeAgo,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: colors['textSecondary'],
                        ),
                      ),
                    ],
                  ),
                ),

                // Rating
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.amber.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Review comment
            Text(
              comment,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: colors['textSecondary'],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}