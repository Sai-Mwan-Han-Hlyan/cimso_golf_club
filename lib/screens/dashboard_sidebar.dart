import 'package:flutter/material.dart';
// Update this import path to match your project structure
import 'auth_service.dart';

class DashboardSidebar extends StatelessWidget {
  final String userName;
  final String userEmail;
  final int selectedIndex;
  final VoidCallback onProfileTap;
  final VoidCallback onDashboardTap;
  final VoidCallback onBookingsTap;
  final Color accentColor;
  final Color textColor;
  final Color secondaryTextColor;

  const DashboardSidebar({
    Key? key,
    required this.userName,
    required this.userEmail,
    required this.selectedIndex,
    required this.onProfileTap,
    required this.onDashboardTap,
    required this.onBookingsTap,
    required this.accentColor,
    required this.textColor,
    required this.secondaryTextColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
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
          _buildDrawerItem(
              Icons.dashboard_outlined,
              'Dashboard',
              isSelected: selectedIndex == 0,
              onTap: onDashboardTap
          ),
          _buildDrawerItem(
              Icons.person_outline,
              'Profile',
              isSelected: selectedIndex == 1,
              onTap: onProfileTap
          ),
          _buildDrawerItem(
              Icons.calendar_today_outlined,
              'My Bookings',
              isSelected: selectedIndex == 2,
              onTap: onBookingsTap
          ),
          _buildDrawerItem(Icons.notifications_outlined, 'Notifications'),
          _buildDrawerItem(Icons.credit_card_outlined, 'Payment Methods'),
          const Divider(height: 1),
          _buildDrawerItem(Icons.settings_outlined, 'Settings'),
          _buildDrawerItem(Icons.help_outline, 'Help & Support'),
          _buildDrawerItem(
              Icons.logout_outlined,
              'Log Out',
              onTap: () => _handleLogout(context)
          ),
        ],
      ),
    );
  }

  // Logout handler function
  Future<void> _handleLogout(BuildContext context) async {
    // Show a confirmation dialog
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Logout'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        );
      },
    );

    // If user confirmed logout
    if (shouldLogout == true) {
      Navigator.pop(context); // Close the drawer

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Perform logout
      await AuthService.logout();

      // Close loading indicator
      Navigator.of(context).pop();

      // Navigate to login screen and clear all previous routes
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
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
}