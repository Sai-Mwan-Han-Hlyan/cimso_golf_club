
import 'package:flutter/material.dart';

class NotificationModel {
  final String title;
  final String message;
  final IconData icon;
  final DateTime timestamp;

  NotificationModel({
    required this.title,
    required this.message,
    required this.icon,
    required this.timestamp,
  });
}

class NotificationManager {
  static final List<NotificationModel> _notifications = [];

  static List<NotificationModel> get notifications => _notifications;

  static void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification); // Newest notifications appear first
  }
}