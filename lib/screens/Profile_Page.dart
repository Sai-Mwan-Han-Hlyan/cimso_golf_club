import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  final Function(String, String) onProfileUpdate;
  final String initialName;
  final String initialEmail;

  const ProfilePage({
    Key? key,
    required this.onProfileUpdate,
    required this.initialName,
    required this.initialEmail,
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  String? gender; // Changed to null
  DateTime? selectedDate; // Changed to null
  String selectedCountryCode = 'US +1';
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonAnimation;
  bool _isEditMode = false;

  // Variables for image handling
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Revised list of country codes with unique identifiers
  final List<String> countryCodes = [
    'US +1',
    'UK +44',
    'CA +1 (Canada)',
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
    'TH +66',
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
    phoneController = TextEditingController(text: ''); // Set to empty

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

  Future<void> _selectDate(BuildContext context) async {
    if (!_isEditMode) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1925),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.indigo,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
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
    // Update the parent widget with new values
    widget.onProfileUpdate(nameController.text, emailController.text);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully'),
        backgroundColor: Colors.indigo,
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Change Profile Photo',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
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
                  ),
                  _photoOptionButton(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                  _photoOptionButton(
                    icon: Icons.delete_outline,
                    label: 'Remove',
                    isDestructive: true,
                    onTap: () {
                      Navigator.pop(context);
                      _removeImage();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ),
              ),
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
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isDestructive ? Colors.red.withOpacity(0.1) : Colors.indigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: isDestructive ? Colors.red : Colors.indigo,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isDestructive ? Colors.red : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Profile' : 'Profile',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_isEditMode)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _toggleEditMode,
              tooltip: 'Edit Profile',
            )
          else
            IconButton(
              icon: const Icon(Icons.close),
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
              // Profile header section with photo and name
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.indigo,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _isEditMode ? _showChangePhotoOptions : null,
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.white,
                                // Use the image file if available, otherwise show the initial
                                backgroundImage: _imageFile != null
                                    ? FileImage(_imageFile!) as ImageProvider
                                    : null,
                                child: _imageFile == null
                                    ? Text(
                                  nameController.text.isNotEmpty
                                      ? nameController.text[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    fontSize: 50,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo,
                                  ),
                                )
                                    : null,
                              ),
                            ),
                            if (_isEditMode)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.indigo,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 6,
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
                      ),
                    ],
                  ),
                ),
              ),

              // Profile content
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Info Section
                    _profileSection(
                      title: 'Basic Information',
                      children: [
                        _infoItem(
                          icon: Icons.person,
                          label: 'Name',
                          controller: nameController,
                          isEditable: _isEditMode,
                        ),
                        _infoItem(
                          icon: Icons.email,
                          label: 'Email',
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          isEditable: _isEditMode,
                        ),
                        _infoItem(
                          icon: Icons.phone,
                          label: 'Phone',
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          prefixWidget: _isEditMode ? _buildCountryCodeDropdown() : null,
                          suffix: !_isEditMode && phoneController.text.isNotEmpty ? ' ($selectedCountryCode)' : '',
                          isEditable: _isEditMode,
                          placeholder: 'Add phone number',
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Additional Info Section
                    _profileSection(
                      title: 'Additional Information',
                      children: [
                        _infoItemWithCustomContent(
                          icon: Icons.calendar_today,
                          label: 'Date of Birth',
                          content: selectedDate != null
                              ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                              : 'Not set',
                          placeholder: 'Add date of birth',
                          onTap: () => _selectDate(context),
                          isEditable: _isEditMode,
                        ),
                        _infoItemWithCustomContent(
                          icon: Icons.person_outline,
                          label: 'Gender',
                          content: gender ?? 'Not specified',
                          placeholder: 'Select gender',
                          customEditWidget: _isEditMode ? _buildGenderSelector() : null,
                          isEditable: _isEditMode,
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Save button (only in edit mode)
                    if (_isEditMode)
                      GestureDetector(
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
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: Colors.indigo,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.indigo.withOpacity(0.3),
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
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountryCodeDropdown() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 100),
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCountryCode,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, size: 18),
          iconSize: 18,
          elevation: 16,
          style: const TextStyle(color: Colors.black87, fontSize: 14),
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
              child: Text(value, style: const TextStyle(fontSize: 12)),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          _genderOption('Male'),
          const SizedBox(width: 12),
          _genderOption('Female'),
          const SizedBox(width: 12),
          _genderOption('Other'),
        ],
      ),
    );
  }

  Widget _genderOption(String value) {
    final isSelected = gender == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          gender = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.indigo : Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.indigo : Colors.grey.shade300,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          value,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _profileSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoItem({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    Widget? prefixWidget,
    String suffix = '',
    bool isEditable = false,
    String placeholder = 'Not set',
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.indigo),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          isEditable
              ? Row(
            children: [
              if (prefixWidget != null) prefixWidget,
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: placeholder,
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.indigo, width: 2),
                    ),
                  ),
                ),
              ),
            ],
          )
              : Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: controller.text.isEmpty
                ? Text(
              placeholder,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.grey[400],
                fontStyle: FontStyle.italic,
              ),
            )
                : Text(
              controller.text + suffix,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItemWithCustomContent({
    required IconData icon,
    required String label,
    required String content,
    String placeholder = 'Not set',
    VoidCallback? onTap,
    Widget? customEditWidget,
    bool isEditable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.indigo),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (customEditWidget != null && isEditable)
            customEditWidget
          else if (isEditable)
            InkWell(
              onTap: onTap,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      content == "Not set" ? placeholder : content,
                      style: TextStyle(
                        fontSize: 16,
                        color: content == "Not set" ? Colors.grey[400] : Colors.black87,
                        fontStyle: content == "Not set" ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                    if (onTap != null)
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: content == "Not set" || content == "Not specified"
                  ? Text(
                placeholder,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[400],
                  fontStyle: FontStyle.italic,
                ),
              )
                  : Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}