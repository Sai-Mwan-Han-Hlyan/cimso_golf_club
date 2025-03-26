import 'package:flutter/material.dart';
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
  String selectedCountryCode = 'TH +66 (Thailand)'; // Changed default to Thailand
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonAnimation;
  bool _isEditMode = false;

  // Variables for image handling
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Revised list of country codes with unique identifiers
  final List<String> countryCodes = [
    'TH +66 (Thailand)',
    'US +1',
    'UK +44',
    'CA +1 ',
    'AU +61',
    'DE +49',
    'FR +33',
    'IT +39',
    'ES +34',
    'BR +55',
    'MX +52',
    'IN +91',
    'CN +86',
    'JP +81',
    'KR +82',
    'RU +7',
    'SG +65',
    'MY +60',
    'NZ +64',
    'ZA +27',
    'NG +234',
    'KE +254',
    'EG +20',
    'TR +90',
    'AE +971',
    'SA +966',
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
  }

  Future<void> _selectDate(BuildContext context, Color accentColor, bool isDark) async {
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
              primary: accentColor,
              onPrimary: Colors.white,
              onSurface: isDark ? Colors.white : Colors.black,
            ),
            dialogBackgroundColor: isDark ? Color(0xFF1E1E1E) : Colors.white,
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

    // Get the accent color for the snackbar
    final accentColor = Theme.of(context).colorScheme.primary;

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile updated successfully'),
        backgroundColor: accentColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
    final accentColor = Theme.of(context).colorScheme.primary;
    final Color bottomSheetColor = isDark ? Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color dividerColor = isDark ? Colors.grey[700]! : Colors.grey.shade300;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: bottomSheetColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                  color: dividerColor,
                ),
              ),
              Text(
                'Change Profile Photo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
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
                    color: accentColor,
                    textColor: textColor,
                  ),
                  _photoOptionButton(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                    color: accentColor,
                    textColor: textColor,
                  ),
                  _photoOptionButton(
                    icon: Icons.delete_outline,
                    label: 'Remove',
                    isDestructive: true,
                    onTap: () {
                      Navigator.pop(context);
                      _removeImage();
                    },
                    textColor: textColor,
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
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey[400] : Colors.black54,
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
    Color? color,
    required Color textColor,
  }) {
    final buttonColor = isDestructive ? Colors.red : (color ?? Theme.of(context).colorScheme.primary);

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
            style: TextStyle(
              color: isDestructive ? Colors.red : textColor,
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

    // Define theme-aware colors
    final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final Color textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;
    final Color secondaryTextColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black54;
    final Color accentColor = Theme.of(context).colorScheme.primary;
    final Color cardColor = isDark ? Color(0xFF1E1E1E) : Colors.white;
    final Color surfaceColor = isDark ? Colors.grey[800]! : const Color(0xFFF9F9F9);
    final Color dividerColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    final Color emptyValueColor = isDark ? Colors.grey[600]! : Colors.grey[400]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Profile' : 'Profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: isDark ? Colors.white : Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: accentColor,
        elevation: 0,
        actions: [
          if (!_isEditMode)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: _toggleEditMode,
              tooltip: 'Edit Profile',
            )
          else
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: _toggleEditMode,
              tooltip: 'Cancel Editing',
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile header with photo
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Header background
                  Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: accentColor,
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(isDark ? 0.5 : 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                  ),

                  // Profile image - positioned to overflow the header
                  Positioned(
                    bottom: -60,
                    child: GestureDetector(
                      onTap: _isEditMode ? _showChangePhotoOptions : null,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: backgroundColor, width: 5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 65,
                          backgroundColor: backgroundColor,
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!) as ImageProvider
                              : null,
                          child: _imageFile == null
                              ? Text(
                            nameController.text.isNotEmpty
                                ? nameController.text[0].toUpperCase()
                                : 'U',
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          )
                              : null,
                        ),
                      ),
                    ),
                  ),

                  // Edit camera icon
                  if (_isEditMode)
                    Positioned(
                      bottom: -20,
                      right: MediaQuery.of(context).size.width / 2 - 80,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: backgroundColor, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),

              // Spacing to account for overlapping profile image
              const SizedBox(height: 70),

              // Profile form content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Name display when not in edit mode
                    if (!_isEditMode)
                      Column(
                        children: [
                          Text(
                            nameController.text,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            emailController.text,
                            style: TextStyle(
                              fontSize: 14,
                              color: secondaryTextColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),

                    // Information Sections
                    _buildProfileSection(
                      title: 'Personal Information',
                      icon: Icons.person_outline,
                      children: [
                        if (_isEditMode)
                          _buildEditField(
                            label: 'Name',
                            controller: nameController,
                            icon: Icons.person,
                            textColor: textColor,
                            secondaryTextColor: secondaryTextColor,
                            accentColor: accentColor,
                            dividerColor: dividerColor,
                          ),

                        if (_isEditMode)
                          _buildEditField(
                            label: 'Email',
                            controller: emailController,
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            enabled: false, // Email usually can't be changed
                            textColor: textColor,
                            secondaryTextColor: secondaryTextColor,
                            accentColor: accentColor,
                            dividerColor: dividerColor,
                          ),

                        if (!_isEditMode)
                          _buildInfoRow(
                            icon: Icons.phone,
                            title: 'Phone',
                            value: phoneController.text.isNotEmpty
                                ? '${phoneController.text} ($selectedCountryCode)'
                                : 'Not set',
                            isEmpty: phoneController.text.isEmpty,
                            secondaryTextColor: secondaryTextColor,
                            textColor: textColor,
                            emptyValueColor: emptyValueColor,
                          ),

                        if (_isEditMode)
                          _buildPhoneField(
                            textColor: textColor,
                            secondaryTextColor: secondaryTextColor,
                            accentColor: accentColor,
                            dividerColor: dividerColor,
                            isDark: isDark,
                          ),

                        _buildInfoRow(
                          icon: Icons.calendar_today,
                          title: 'Date of Birth',
                          value: selectedDate != null
                              ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                              : 'Not set',
                          isEmpty: selectedDate == null,
                          onTap: _isEditMode ? () => _selectDate(context, accentColor, isDark) : null,
                          accentColor: accentColor,
                          secondaryTextColor: secondaryTextColor,
                          textColor: textColor,
                          emptyValueColor: emptyValueColor,
                        ),

                        if (_isEditMode)
                          const SizedBox(height: 10),

                        if (_isEditMode)
                          _buildGenderSelector(
                            accentColor: accentColor,
                            secondaryTextColor: secondaryTextColor,
                            textColor: textColor,
                            dividerColor: dividerColor,
                          ),

                        if (!_isEditMode)
                          _buildInfoRow(
                            icon: Icons.person_outline,
                            title: 'Gender',
                            value: gender ?? 'Not specified',
                            isEmpty: gender == null,
                            secondaryTextColor: secondaryTextColor,
                            textColor: textColor,
                            emptyValueColor: emptyValueColor,
                          ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Save button (only in edit mode)
                    if (_isEditMode)
                      _buildSaveButton(accentColor: accentColor),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    // Get theme-aware colors
    final accentColor = Theme.of(context).colorScheme.primary;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final cardColor = isDark ? Color(0xFF1E1E1E) : Colors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: accentColor,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
              border: isDark ? Border.all(color: Colors.grey[800]!, width: 1) : null,
            ),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    bool isEmpty = false,
    VoidCallback? onTap,
    Color? accentColor,
    required Color secondaryTextColor,
    required Color textColor,
    required Color emptyValueColor,
  }) {
    // Get accent color if not provided
    accentColor = accentColor ?? Theme.of(context).colorScheme.primary;

    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: secondaryTextColor,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isEmpty ? emptyValueColor : textColor,
                  fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (onTap != null)
            Icon(
              Icons.edit,
              size: 18,
              color: accentColor,
            ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: row,
      );
    }

    return row;
  }

  Widget _buildEditField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
    required Color textColor,
    required Color secondaryTextColor,
    required Color accentColor,
    required Color dividerColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: secondaryTextColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              keyboardType: keyboardType,
              style: TextStyle(
                fontSize: 16,
                color: enabled ? textColor : Colors.grey,
              ),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(
                  fontSize: 14,
                  color: secondaryTextColor,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: dividerColor,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: accentColor,
                    width: 2,
                  ),
                ),
                disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: dividerColor.withOpacity(0.5),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton({required Color accentColor}) {
    return GestureDetector(
      onTapDown: (_) => _buttonAnimationController.forward(),
      onTapUp: (_) => _buttonAnimationController.reverse(),
      onTapCancel: () => _buttonAnimationController.reverse(),
      onTap: _saveProfile,
      child: AnimatedBuilder(
        animation: _buttonAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _buttonAnimation.value,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Save Changes',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhoneField({
    required Color textColor,
    required Color secondaryTextColor,
    required Color accentColor,
    required Color dividerColor,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(
            Icons.phone,
            size: 20,
            color: secondaryTextColor,
          ),
          const SizedBox(width: 12),
          Container(
            width: 110,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: dividerColor,
                ),
              ),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                canvasColor: isDark ? Color(0xFF1E1E1E) : Colors.white,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCountryCode,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, size: 20),
                  iconSize: 18,
                  elevation: 16,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                  ),
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
                        style: TextStyle(fontSize: 14, color: textColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              style: TextStyle(
                fontSize: 16,
                color: textColor,
              ),
              decoration: InputDecoration(
                labelText: 'Phone Number',
                labelStyle: TextStyle(
                  fontSize: 14,
                  color: secondaryTextColor,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: dividerColor,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: accentColor,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSelector({
    required Color accentColor,
    required Color secondaryTextColor,
    required Color textColor,
    required Color dividerColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 20,
                color: secondaryTextColor,
              ),
              const SizedBox(width: 12),
              Text(
                'Gender',
                style: TextStyle(
                  fontSize: 14,
                  color: secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _genderOption('Male', accentColor, textColor),
              _genderOption('Female', accentColor, textColor),
              _genderOption('Other', accentColor, textColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _genderOption(String value, Color accentColor, Color textColor) {
    final isSelected = gender == value;
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final borderColor = isDark ? Colors.grey[700]! : Colors.grey.shade300;

    return GestureDetector(
      onTap: () {
        setState(() {
          gender = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : Colors.transparent,
          border: Border.all(
            color: isSelected ? accentColor : borderColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          value,
          style: TextStyle(
            color: isSelected ? Colors.white : textColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}