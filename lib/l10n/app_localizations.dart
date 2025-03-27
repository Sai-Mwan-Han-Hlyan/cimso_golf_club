import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart'; // Added for SynchronousFuture

// AppLocalizations contains all the text translations for the app
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  // Helper method to get localized instance
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // Delegate for localizations
  static const LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();

  // Static translations map
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'dashboard': 'Dashboard',
      'profile': 'Profile',
      'bookings': 'My Bookings',
      'notifications': 'Notifications',
      'settings': 'Settings',
      'help': 'Help & Support',
      'logout': 'Log Out',
      'darkMode': 'Dark Mode',
      'language': 'Language',
      'welcome': 'Welcome,',
      'searchGolfCourses': 'Search golf courses',
      'availableCourses': 'Available Courses',
      'viewAll': 'View All',
      'details': 'Details',
      'bookNow': 'Book Now',
      'noGolfCoursesFound': 'No golf courses found',
      'payment': 'Payment',
      'complete': 'Complete',
      'pay': 'Pay',
      'book': 'Book',
      'checkout': 'Checkout',
      'addToCalendar': 'Add to Calendar',
      'done': 'Done',
      'shareReceipt': 'Share Receipt',
      'reschedule': 'Reschedule',
      'cancel': 'Cancel',
      'bookingDetails': 'Booking Details',
      'confirmed': 'Confirmed',
      'players': 'Players',
      'carts': 'Golf Carts',
      'date': 'Date',
      'time': 'Time',
      'course': 'Course',
      'selectDate': 'Select Date',
      'selectCourse': 'Select Course',
      'saveChanges': 'Save Changes',
      'thaiLanguage': 'Thai Language',
      'useThaiLanguage': 'Display text in Thai language',
      'english': 'English',
      'thai': 'ภาษาไทย',
      // Add more English translations as needed
    },
    'th': {
      'dashboard': 'แดชบอร์ด',
      'profile': 'โปรไฟล์',
      'bookings': 'การจองของฉัน',
      'notifications': 'การแจ้งเตือน',
      'settings': 'การตั้งค่า',
      'help': 'ช่วยเหลือและสนับสนุน',
      'logout': 'ออกจากระบบ',
      'darkMode': 'โหมดมืด',
      'language': 'ภาษา',
      'welcome': 'ยินดีต้อนรับ,',
      'searchGolfCourses': 'ค้นหาสนามกอล์ฟ',
      'availableCourses': 'สนามกอล์ฟที่มีอยู่',
      'viewAll': 'ดูทั้งหมด',
      'details': 'รายละเอียด',
      'bookNow': 'จองเลย',
      'noGolfCoursesFound': 'ไม่พบสนามกอล์ฟ',
      'payment': 'การชำระเงิน',
      'complete': 'เสร็จสิ้น',
      'pay': 'ชำระเงิน',
      'book': 'จอง',
      'checkout': 'ชำระเงิน',
      'addToCalendar': 'เพิ่มลงในปฏิทิน',
      'done': 'เสร็จสิ้น',
      'shareReceipt': 'แชร์ใบเสร็จ',
      'reschedule': 'เลื่อนการจอง',
      'cancel': 'ยกเลิก',
      'bookingDetails': 'รายละเอียดการจอง',
      'confirmed': 'ยืนยันแล้ว',
      'players': 'ผู้เล่น',
      'carts': 'รถกอล์ฟ',
      'date': 'วันที่',
      'time': 'เวลา',
      'course': 'สนาม',
      'selectDate': 'เลือกวันที่',
      'selectCourse': 'เลือกสนาม',
      'saveChanges': 'บันทึกการเปลี่ยนแปลง',
      'thaiLanguage': 'ภาษาไทย',
      'useThaiLanguage': 'แสดงข้อความเป็นภาษาไทย',
      'english': 'English',
      'thai': 'ภาษาไทย',
      // Add more Thai translations as needed
    },
  };

  // Method to get specific translation
  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

// Delegate class for loading localizations
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'th'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}