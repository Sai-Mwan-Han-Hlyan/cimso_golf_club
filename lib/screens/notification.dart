// notification.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'notification_manager.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notifications = NotificationManager.notifications;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: notifications.isEmpty
          ? Center(
        child: Text(
          'No notifications yet',
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Card(
            child: ListTile(
              leading: Icon(notification.icon, color: Colors.green),
              title: Text(notification.title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              subtitle: Text(notification.message, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54)),
              trailing: Text(
                '${notification.timestamp.hour}:${notification.timestamp.minute}',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }
}