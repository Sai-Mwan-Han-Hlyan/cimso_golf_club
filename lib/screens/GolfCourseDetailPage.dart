import 'package:flutter/material.dart';
import 'package:cimso_golf_booking/screens/booking.dart';

class GolfCourseDetailPage extends StatelessWidget {
  final String courseName;
  final String location;
  final double rating;
  final int reviewCount;
  final bool hasNineHole; // Added to support 9-hole option

  GolfCourseDetailPage({
    required this.courseName,
    required this.location,
    required this.rating,
    required this.reviewCount,
    this.hasNineHole = true, // Default to true to support both options
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          // Modern sliver app bar with transparent background
          SliverAppBar(
            expandedHeight: 240.0,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            stretch: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.3),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.3),
                  child: IconButton(
                    icon: Icon(Icons.favorite_border, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.3),
                  child: IconButton(
                    icon: Icon(Icons.share, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // High-quality image
                  Image.network(
                    'https://via.placeholder.com/1200x800/008000/FFFFFF?text=Golf+Course',
                    fit: BoxFit.cover,
                  ),
                  // Gradient overlay for better text readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                        stops: [0.6, 1.0],
                      ),
                    ),
                  ),
                  // Course name and location in the bottom area
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          courseName,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.white70, size: 16),
                            SizedBox(width: 4),
                            Text(
                              location,
                              style: TextStyle(color: Colors.white70, fontSize: 14),
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

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24),

                  // Rating and review count in clean, minimal design
                  Row(
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < rating.floor()
                                ? Icons.star
                                : (index < rating ? Icons.star_half : Icons.star_border),
                            color: Colors.amber,
                            size: 20,
                          );
                        }),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '$rating ($reviewCount)',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 28),

                  // Course options section - just displaying info about available options
                  Text(
                    'Course Options',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCourseInfoCard(
                          title: '18 Holes',
                          subtitle: 'Championship Course',
                          details: ['Par 72', '6,800 yards', 'Full Experience'],
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: hasNineHole ? _buildCourseInfoCard(
                          title: '9 Holes',
                          subtitle: 'Quick Play',
                          details: ['Par 36', '3,400 yards', 'Front Nine'],
                        ) : Container(),
                      ),
                    ],
                  ),

                  SizedBox(height: 28),

                  // Brief about section
                  Text(
                    'About',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'This beautifully designed course offers challenges for golfers of all skill levels with meticulously maintained fairways and stunning water features throughout its layout.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: 28),

                  // Key features section with minimalist icons
                  Text(
                    'Features',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildFeatureChip(Icons.golf_course, 'Pro Shop'),
                      _buildFeatureChip(Icons.sports_golf, 'Driving Range'),
                      _buildFeatureChip(Icons.restaurant, 'Restaurant'),
                      _buildFeatureChip(Icons.local_bar, 'Bar'),
                      _buildFeatureChip(Icons.directions_car, 'Golf Carts'),
                      _buildFeatureChip(Icons.school, 'Lessons'),
                    ],
                  ),

                  SizedBox(height: 28),

                  // Course specs section
                  Text(
                    'Course Specifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildSpecRow('Greens', 'Bent Grass'),
                  _buildSpecRow('Fairways', 'Bermuda'),
                  _buildSpecRow('Difficulty', 'Intermediate'),
                  _buildSpecRow('Terrain', 'Rolling Hills'),

                  SizedBox(height: 28),

                  // Top reviews
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reviews',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'See All',
                          style: TextStyle(color: Colors.green[700]),
                        ),
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  _buildMinimalistReview(
                      name: 'John S.',
                      rating: 5.0,
                      comment: 'Excellent course conditions and challenging layout. Will definitely play here again.',
                      timeAgo: '2 days ago'
                  ),
                  _buildMinimalistReview(
                      name: 'Sarah J.',
                      rating: 4.5,
                      comment: 'Great value and friendly staff. The 9-hole option is perfect for a quick round.',
                      timeAgo: '1 week ago'
                  ),

                  SizedBox(height: 28),

                  // Map preview
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[100],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Map placeholder
                          Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Icon(Icons.map, size: 40, color: Colors.grey[400]),
                            ),
                          ),
                          // Location pin
                          Center(
                            child: Icon(Icons.location_on, color: Colors.green[700], size: 30),
                          ),
                          // Get directions button
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: Icon(Icons.directions, size: 18),
                              label: Text('Directions'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.green[700],
                                elevation: 1,
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 80), // Extra space at bottom for the floating button
                ],
              ),
            ),
          ),
        ],
      ),
      // Modern floating action button for booking
      floatingActionButton: Container(
        width: double.infinity,
        height: 60,
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BookingPage()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Book Tee Time',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // Updated method that just displays course information without selection indication
  Widget _buildCourseInfoCard({
    required String title,
    required String subtitle,
    required List<String> details,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 8),
          ...details.map((detail) => Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              '• $detail',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.green[700], size: 16),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          SizedBox(width: 4),
          Expanded(
            child: Text(
              '· $value',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalistReview({
    required String name,
    required double rating,
    required String comment,
    required String timeAgo,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                timeAgo,
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < rating.floor()
                    ? Icons.star
                    : (index < rating ? Icons.star_half : Icons.star_border),
                color: Colors.amber,
                size: 14,
              );
            }),
          ),
          SizedBox(height: 8),
          Text(
            comment,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}