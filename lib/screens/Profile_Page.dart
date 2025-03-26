import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cimso_golf_booking/providers/theme_provider.dart';

class ProfilePage extends StatefulWidget {
  // Updated callback to include all profile fields
  final Function(String, String, String, String?, DateTime?, File?) onProfileUpdate;
  final String initialName;
  final String initialEmail;
  final String? initialPhone;
  final String? initialGender;
  final DateTime? initialDob;
  final File? initialImage;

  const ProfilePage({
    Key? key,
    required this.onProfileUpdate,
    required this.initialName,
    required this.initialEmail,
    this.initialPhone,
    this.initialGender,
    this.initialDob,
    this.initialImage,
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  String? gender;
  DateTime? selectedDate;
  String selectedCountryCode = 'TH +66'; // Changed default to Thailand with shorter text
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonAnimation;
  bool _isEditMode = false;
  late Animation<double> _fadeAnimation;

  // Variables for image handling
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

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

  // Revised list of country codes with shorter text to prevent overflow
  final List<String> countryCodes = [
    'TH +66',  // Thailand
    'US +1',   // USA
    'UK +44',  // United Kingdom
    'CA +1',   // Canada
    'AU +61',  // Australia
    'DE +49',  // Germany
    'FR +33',  // France
    'IT +39',  // Italy
    'ES +34',  // Spain
    'BR +55',  // Brazil
    'MX +52',  // Mexico
    'IN +91',  // India
    'CN +86',  // China
    'JP +81',  // Japan
    'KR +82',  // South Korea
    'RU +7',   // Russia
    'SG +65',  // Singapore
    'MY +60',  // Malaysia
    'NZ +64',  // New Zealand
    'ZA +27',  // South Africa
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the passed values
    nameController = TextEditingController(text: widget.initialName);
    emailController = TextEditingController(text: widget.initialEmail);
    phoneController = TextEditingController(text: widget.initialPhone ?? '');
    gender = widget.initialGender;
    selectedDate = widget.initialDob;
    _imageFile = widget.initialImage;

    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _buttonAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });

    if (_isEditMode) {
      _buttonAnimationController.forward();
    } else {
      _buttonAnimationController.reverse();
    }
  }

  Future<void> _selectDate(BuildContext context, Map<String, Color> colors, bool isDark) async {
    if (!_isEditMode) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1925),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: colors['primary']!,
              onPrimary: Colors.white,
              onSurface: colors['textPrimary']!,
            ),
            dialogBackgroundColor: colors['card'],
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _saveProfile() {
    // Update the parent widget with all profile values
    widget.onProfileUpdate(
      nameController.text,
      emailController.text,
      phoneController.text,
      gender,
      selectedDate,
      _imageFile,
    );

    // Get the theme colors
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    final colors = isDark ? _darkThemeColors : _lightThemeColors;

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Profile updated successfully',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: colors['success'],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
      ),
    );

    // Exit edit mode
    setState(() {
      _isEditMode = false;
    });
  }

  // New image handling methods
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      // Get the theme colors
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      final isDark = themeProvider.isDarkMode;
      final colors = isDark ? _darkThemeColors : _lightThemeColors;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Error picking image: $e',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: colors['error'],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(10),
        ),
      );
    }
  }

  void _removeImage() {
    setState(() {
      _imageFile = null;
    });
  }

  void _showChangePhotoOptions() {
    // Get theme information
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    final colors = isDark ? _darkThemeColors : _lightThemeColors;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colors['card'],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
            border: isDark ? Border.all(color: Colors.grey[800]!, width: 1) : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: colors['textSecondary']!.withOpacity(0.3),
                ),
              ),
              Text(
                'Change Profile Photo',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors['textPrimary'],
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _photoOptionButton(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                    colors: colors,
                  ),
                  _photoOptionButton(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                    colors: colors,
                  ),
                  _photoOptionButton(
                    icon: Icons.delete_outline,
                    label: 'Remove',
                    isDestructive: true,
                    onTap: () {
                      Navigator.pop(context);
                      _removeImage();
                    },
                    colors: colors,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: colors['textSecondary'],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _photoOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
    required Map<String, Color> colors,
  }) {
    final buttonColor = isDestructive ? colors['error']! : colors['primary']!;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: buttonColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: buttonColor,
              size: 32,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: isDestructive ? colors['error'] : colors['textPrimary'],
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
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

    return Scaffold(
      backgroundColor: colors['background'],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        actions: [
          if (!_isEditMode)
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 18),
              ),
              onPressed: _toggleEditMode,
              tooltip: 'Edit Profile',
            )
          else
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 18),
              ),
              onPressed: _toggleEditMode,
              tooltip: 'Cancel Editing',
            ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section with profile image
            Stack(
              children: [
                // Background header
                Container(
                  height: 240,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colors['primary'],
                    boxShadow: [
                      BoxShadow(
                        color: colors['primary']!.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
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
                        'assets/',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 240,
                      ),
                    )
                        : Image.asset(
                      'assets/',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 240,
                    ),
                  ),
                ),

                // Profile content
                Column(
                  children: [
                    // Empty space for app bar
                    const SizedBox(height: 100),

                    // Avatar
                    Center(
                      child: GestureDetector(
                        onTap: _isEditMode ? _showChangePhotoOptions : null,
                        child: Stack(
                          children: [
                            // Profile image
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colors['card'],
                                border: Border.all(
                                  color: colors['card']!,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                image: _imageFile != null
                                    ? DecorationImage(
                                  image: FileImage(_imageFile!),
                                  fit: BoxFit.cover,
                                )
                                    : null,
                              ),
                              child: _imageFile == null
                                  ? Center(
                                child: Text(
                                  nameController.text.isNotEmpty
                                      ? nameController.text[0].toUpperCase()
                                      : 'U',
                                  style: GoogleFonts.poppins(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: colors['primary'],
                                  ),
                                ),
                              )
                                  : null,
                            ),

                            // Edit icon
                            if (_isEditMode)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: colors['primary'],
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: colors['card']!,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Name and Email
                    if (!_isEditMode)
                      Column(
                        children: [
                          Text(
                            nameController.text,
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            emailController.text,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),

                    const SizedBox(height: 50),

                    // Profile details
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Personal info card
                          _buildProfileCard(
                            title: 'Personal Information',
                            icon: Icons.person_outline,
                            children: [
                              // Name field (edit mode)
                              if (_isEditMode)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildInputField(
                                    label: 'Name',
                                    controller: nameController,
                                    icon: Icons.person,
                                    colors: colors,
                                  ),
                                ),

                              // Email field (edit mode)
                              if (_isEditMode)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildInputField(
                                    label: 'Email',
                                    controller: emailController,
                                    icon: Icons.email,
                                    keyboardType: TextInputType.emailAddress,
                                    enabled: false, // Email usually can't be changed
                                    colors: colors,
                                  ),
                                ),

                              // Phone number (view mode)
                              if (!_isEditMode)
                                _buildInfoRow(
                                  icon: Icons.phone,
                                  label: 'Phone',
                                  value: phoneController.text.isNotEmpty
                                      ? phoneController.text
                                      : 'Not set',
                                  hasValue: phoneController.text.isNotEmpty,
                                  colors: colors,
                                ),

                              // Phone field (edit mode)
                              if (_isEditMode)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildPhoneField(colors, isDark),
                                ),

                              // Date of birth (view mode)
                              if (!_isEditMode)
                                _buildInfoRow(
                                  icon: Icons.calendar_today,
                                  label: 'Date of Birth',
                                  value: selectedDate != null
                                      ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                                      : 'Not set',
                                  hasValue: selectedDate != null,
                                  colors: colors,
                                ),

                              // Date of birth (edit mode)
                              if (_isEditMode)
                                _buildDateField(colors, isDark),

                              // Gender (view mode)
                              if (!_isEditMode)
                                _buildInfoRow(
                                  icon: Icons.person_outline,
                                  label: 'Gender',
                                  value: gender ?? 'Not specified',
                                  hasValue: gender != null,
                                  colors: colors,
                                ),

                              // Gender selector (edit mode)
                              if (_isEditMode)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildGenderSelector(colors),
                                ),
                            ],
                            colors: colors,
                            cardShadow: cardShadow,
                            cardBorder: cardBorder,
                          ),

                          const SizedBox(height: 30),

                          // Save button (only in edit mode)
                          if (_isEditMode)
                            _buildSaveButton(colors),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required Map<String, Color> colors,
    required BoxShadow cardShadow,
    required Border? cardBorder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors['textPrimary'],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              icon,
              color: colors['primary'],
              size: 20,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: colors['card'],
            borderRadius: BorderRadius.circular(16),
            boxShadow: [cardShadow],
            border: cardBorder,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool hasValue,
    required Map<String, Color> colors,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors['primary']!.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: colors['primary'],
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
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
                    fontSize: 15,
                    fontWeight: hasValue ? FontWeight.w500 : FontWeight.w400,
                    color: hasValue ? colors['textPrimary'] : colors['textSecondary'],
                    fontStyle: hasValue ? FontStyle.normal : FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
    required Map<String, Color> colors,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: enabled
                ? colors['primary']!.withOpacity(0.1)
                : colors['textSecondary']!.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: enabled ? colors['primary'] : colors['textSecondary'],
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: enabled ? colors['textPrimary'] : colors['textSecondary'],
            ),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: GoogleFonts.poppins(
                fontSize: 12,
                color: colors['textSecondary'],
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: colors['textSecondary']!.withOpacity(0.3),
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: colors['primary']!,
                  width: 2,
                ),
              ),
              disabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: colors['textSecondary']!.withOpacity(0.1),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField(Map<String, Color> colors, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors['primary']!.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.phone,
            color: colors['primary'],
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Country code dropdown - FIXED WIDTH TO PREVENT OVERFLOW
              Container(
                width: 80, // Fixed width to prevent overflow
                margin: const EdgeInsets.only(right: 8),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCountryCode,
                    isExpanded: true,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: colors['textSecondary'],
                      size: 18,
                    ),
                    elevation: 16,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: colors['textPrimary'],
                    ),
                    dropdownColor: colors['card'],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedCountryCode = newValue;
                        });
                      }
                    },
                    items: countryCodes.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: colors['textPrimary'],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Phone number input
              Expanded(
                child: TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: colors['textPrimary'],
                  ),
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 12,
                      color: colors['textSecondary'],
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: colors['textSecondary']!.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: colors['primary']!,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(Map<String, Color> colors, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors['primary']!.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.calendar_today,
              color: colors['primary'],
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: InkWell(
              onTap: () => _selectDate(context, colors, isDark),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date of Birth',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: colors['textSecondary'],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedDate != null
                              ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                              : 'Select date',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: selectedDate != null
                                ? colors['textPrimary']
                                : colors['textSecondary'],
                            fontStyle: selectedDate != null
                                ? FontStyle.normal
                                : FontStyle.italic,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: colors['primary'],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 1,
                    color: colors['textSecondary']!.withOpacity(0.3),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSelector(Map<String, Color> colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors['primary']!.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.person_outline,
                color: colors['primary'],
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Gender',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: colors['textSecondary'],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Wrap with row to prevent overflow
        Row(
          children: [
            // Using Expanded with flex for proper spacing
            Expanded(
              flex: 1,
              child: _buildGenderOption('Male', colors),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: _buildGenderOption('Female', colors),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: _buildGenderOption('Other', colors),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(String value, Map<String, Color> colors) {
    final isSelected = gender == value;

    return InkWell(
      onTap: () {
        setState(() {
          gender = value;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colors['primary'] : colors['card'],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? colors['primary']! : colors['textSecondary']!.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? Colors.white : colors['textPrimary'],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(Map<String, Color> colors) {
    return Container(
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
        onPressed: _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors['primary'],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.save, size: 20),
            const SizedBox(width: 8),
            Text(
              'Save Changes',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}