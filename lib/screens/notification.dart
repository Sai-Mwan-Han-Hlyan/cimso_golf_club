import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'notification_manager.dart';
import 'package:cimso_golf_booking/providers/theme_provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get theme information
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Define theme-aware colors
    final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final Color textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;
    final Color secondaryTextColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black54;
    final Color tertiaryTextColor = isDark ? Colors.grey[500]! : Colors.grey;
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color cardColor = isDark ? Color(0xFF1E1E1E) : Colors.white;

    final notifications = NotificationManager.notifications;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: notifications.isEmpty
          ? Center(
        child: Text(
          'No notifications yet',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: secondaryTextColor,
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Card(
            color: cardColor,
            elevation: isDark ? 1 : 2,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: isDark
                  ? BorderSide(color: Colors.grey[800]!, width: 1)
                  : BorderSide.none,
            ),
            child: ListTile(
              leading: Icon(notification.icon, color: primaryColor),
              title: Text(
                notification.title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              subtitle: Text(
                notification.message,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: secondaryTextColor,
                ),
              ),
              trailing: Text(
                '${notification.timestamp.hour}:${notification.timestamp.minute.toString().padLeft(2, '0')}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: tertiaryTextColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}