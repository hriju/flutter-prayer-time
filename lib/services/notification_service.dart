import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:intl/intl.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Skip initialization for web platform
    if (kIsWeb) {
      debugPrint('Notifications are not supported on web platform');
      return;
    }

    // Initialize timezone data
    tz_data.initializeTimeZones();
    
    // Set local timezone (you might want to get this dynamically)
    tz.setLocalLocation(tz.getLocation('America/Chicago')); // For Plano, Texas
    
    // Initialize notification settings for Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // Initialize notification settings for iOS
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {
        // Handle iOS foreground notification
      },
    );
    
    // Combine platform-specific settings
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    // Initialize the plugin
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
        debugPrint('Notification tapped: ${response.payload}');
      },
    );
    
    // Request permission (for iOS)
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
    
    // Request permission (for Android 13+)
    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestPermission();
    }
  }
  
  // Schedule notifications for all prayer times
  Future<void> schedulePrayerTimeNotifications(Map<String, dynamic> prayerTimes) async {
    // Skip notifications for web platform
    if (kIsWeb) {
      debugPrint('Notifications are not supported on web platform');
      return;
    }

    // Cancel any existing notifications
    await cancelAllNotifications();
    
    // Get current date
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    
    // Schedule notification for each prayer time
    _schedulePrayerNotification('fajr', prayerTimes['fajr'], 1);
    _schedulePrayerNotification('dhuhr', prayerTimes['dhuhr'], 2);
    _schedulePrayerNotification('asr', prayerTimes['asr'], 3);
    _schedulePrayerNotification('maghrib', prayerTimes['maghrib'], 4);
    _schedulePrayerNotification('isha', prayerTimes['isha'], 5);
    
    debugPrint('Prayer time notifications scheduled for $today');
  }
  
  // Schedule a notification for a specific prayer time
  Future<void> _schedulePrayerNotification(String prayerName, String timeString, int id) async {
    // Skip notifications for web platform
    if (kIsWeb) {
      return;
    }

    try {
      // Parse the prayer time (format: "06:32 AM")
      final timeFormat = DateFormat('hh:mm a');
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Remove any extra spaces in the time string
      final cleanTimeString = timeString.replaceAll(RegExp(r'\s+'), ' ');
      
      // Parse the time
      final time = timeFormat.parse(cleanTimeString);
      
      // Create a DateTime for the prayer time today
      final prayerDateTime = DateTime(
        today.year,
        today.month,
        today.day,
        time.hour,
        time.minute,
      );
      
      // Format prayer name for display
      final formattedPrayerName = prayerName.substring(0, 1).toUpperCase() + prayerName.substring(1);
      
      // Only schedule if the prayer time is in the future
      if (prayerDateTime.isAfter(now)) {
        // Convert to TZDateTime
        final scheduledTime = tz.TZDateTime.from(prayerDateTime, tz.local);
        
        // Android notification details
        const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
          'prayer_times_channel',
          'Prayer Times',
          channelDescription: 'Notifications for prayer times',
          importance: Importance.max,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('adhan'),
          playSound: true,
        );
        
        // iOS notification details
        const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
          sound: 'adhan.aiff',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );
        
        // Combined notification details
        const NotificationDetails notificationDetails = NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        );
        
        // Schedule the notification
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          'Prayer Time',
          'It\'s time for $formattedPrayerName prayer',
          scheduledTime,
          notificationDetails,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
        
        debugPrint('Scheduled notification for $formattedPrayerName at $timeString');
      } else {
        debugPrint('$formattedPrayerName time has already passed for today');
      }
    } catch (e) {
      debugPrint('Error scheduling notification for $prayerName: $e');
    }
  }
  
  // Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    // Skip notifications for web platform
    if (kIsWeb) {
      return;
    }

    await flutterLocalNotificationsPlugin.cancelAll();
    debugPrint('All notifications cancelled');
  }
} 