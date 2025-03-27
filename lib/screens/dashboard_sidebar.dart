import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Update these import paths to match your project structure
import 'auth_service.dart';
import 'notification.dart';  // Import notification screen
import 'package:cimso_golf_booking/providers/theme_provider.dart'; // Add this import
import 'package:cimso_golf_booking/screens/settings_screen.dart';
import 'package:cimso_golf_booking/l10n/app_localizations.dart';

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

  // In dashboard_sidebar.dart
// Inside the build method

  @override
  Widget build(BuildContext context) {
    // Get the LanguageProvider to access translations
    final localizations = AppLocalizations.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Adjust colors based on theme
    final Color effectiveTextColor = isDark ? Colors.white : textColor;
    final Color effectiveSecondaryTextColor = isDark ? Colors.white70 : secondaryTextColor;

    return Drawer(
      backgroundColor: Theme.of(context).drawerTheme.backgroundColor,
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                    color: effectiveTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: TextStyle(
                    fontSize: 12,
                    color: effectiveSecondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          _buildDrawerItem(
              Icons.dashboard_outlined,
              // Use translations
              localizations.translate('dashboard'),
              isSelected: selectedIndex == 0,
              onTap: onDashboardTap,
              effectiveTextColor: effectiveTextColor,
              effectiveSecondaryTextColor: effectiveSecondaryTextColor
          ),
          _buildDrawerItem(
              Icons.person_outline,
              // Use translations
              localizations.translate('profile'),
              isSelected: selectedIndex == 1,
              onTap: onProfileTap,
              effectiveTextColor: effectiveTextColor,
              effectiveSecondaryTextColor: effectiveSecondaryTextColor
          ),
          _buildDrawerItem(
              Icons.calendar_today_outlined,
              // Use translations
              localizations.translate('bookings'),
              isSelected: selectedIndex == 2,
              onTap: onBookingsTap,
              effectiveTextColor: effectiveTextColor,
              effectiveSecondaryTextColor: effectiveSecondaryTextColor
          ),
          _buildDrawerItem(
              Icons.notifications_outlined,
              // Use translations
              localizations.translate('notifications'),
              isSelected: selectedIndex == 3,
              onTap: () {
                // Close the drawer first
                Navigator.pop(context);
                // Navigate to notification screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationScreen()),
                );
              },
              effectiveTextColor: effectiveTextColor,
              effectiveSecondaryTextColor: effectiveSecondaryTextColor
          ),

          Divider(height: 1, color: Theme.of(context).dividerColor),
          _buildDrawerItem(
              Icons.settings_outlined,
              // Use translations
              localizations.translate('settings'),
              isSelected: selectedIndex == 4,
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // Navigate to the settings screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
              effectiveTextColor: effectiveTextColor,
              effectiveSecondaryTextColor: effectiveSecondaryTextColor
          ),
          _buildDrawerItem(
              Icons.help_outline,
              // Use translations
              localizations.translate('help'),
              effectiveTextColor: effectiveTextColor,
              effectiveSecondaryTextColor: effectiveSecondaryTextColor
          ),
          _buildDrawerItem(
              Icons.logout_outlined,
              // Use translations
              localizations.translate('logout'),
              onTap: () => _handleLogout(context),
              effectiveTextColor: effectiveTextColor,
              effectiveSecondaryTextColor: effectiveSecondaryTextColor
          ),
        ],
      ),
    );
  }

  // Settings dialog with dark mode toggle
  void _showSettingsDialog(BuildContext context, ThemeProvider themeProvider) {
    // Use StatefulBuilder to rebuild just the dialog when theme changes
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text(
                  'Settings',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SwitchListTile(
                      title: Text(
                        'Dark Mode',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        // Toggle theme and rebuild dialog
                        themeProvider.toggleTheme();
                        setState(() {}); // Rebuild dialog UI to reflect changes
                      },
                      activeColor: accentColor,
                      contentPadding: EdgeInsets.zero,
                    ),
                    // You can add more settings here
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                    style: TextButton.styleFrom(
                      foregroundColor: accentColor,
                    ),
                  ),
                ],
              );
            }
        );
      },
    );
  }

  // Logout handler function
  Future<void> _handleLogout(BuildContext context) async {
    // Show a confirmation dialog
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm Logout',
            style: TextStyle(
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          content: Text(
            'Are you sure you want to log out?',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
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

  Widget _buildDrawerItem(
      IconData icon,
      String title,
      {
        bool isSelected = false,
        VoidCallback? onTap,
        required Color effectiveTextColor,
        required Color effectiveSecondaryTextColor,
      }
      ) {
    return ListTile(
      dense: true,
      leading: Icon(
        icon,
        size: 20,
        color: isSelected ? accentColor : effectiveSecondaryTextColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? accentColor : effectiveTextColor,
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