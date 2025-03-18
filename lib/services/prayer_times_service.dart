import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prayer_time/services/notification_service.dart';

class PrayerTimesService {
  // Comment out Firebase collection reference
  // final CollectionReference _prayerTimesCollection = FirebaseFirestore.instance.collection('prayerTimes');
  
  // Cache keys
  static const String _cachedDateKey = 'cached_date';
  static const String _cachedPrayerTimesKey = 'cached_prayer_times';
  static const String _cachedHanafiAsrKey = 'cached_hanafi_asr';
  
  // Notification service
  final NotificationService _notificationService = NotificationService();
  
  Future<Map<String, dynamic>?> fetchCurrentPrayerTimes() async {
    try {
      // Get current date
      final now = DateTime.now();
      final today = DateFormat('yyyy-MM-dd').format(now);
      
      // First, try to get cached data for today
      final cachedData = await _getCachedPrayerTimes(today);
      if (cachedData != null) {
        print('Using cached prayer times for $today');
        return cachedData;
      }
      
      // If no cached data for today, fetch from API
      print('Fetching prayer times from API for $today');
      
      // Plano, Texas coordinates
      final latitude = 33.0198;
      final longitude = -96.6989;
      
      // Fetch Shafi'i (standard) prayer times
      final shafiUrl = Uri.parse(
        'https://api.aladhan.com/v1/timings/$today?latitude=$latitude&longitude=$longitude&method=2&school=0'
      );
      
      // Fetch Hanafi prayer times
      final hanafiUrl = Uri.parse(
        'https://api.aladhan.com/v1/timings/$today?latitude=$latitude&longitude=$longitude&method=2&school=1'
      );
      
      final shafiResponse = await http.get(shafiUrl);
      final hanafiResponse = await http.get(hanafiUrl);
      
      if (shafiResponse.statusCode == 200 && hanafiResponse.statusCode == 200) {
        final shafiData = json.decode(shafiResponse.body);
        final hanafiData = json.decode(hanafiResponse.body);
        
        final shafiTimings = shafiData['data']['timings'];
        final hanafiTimings = hanafiData['data']['timings'];
        
        final prayerTimes = {
          'date': today,
          'startDate': today,
          'endDate': DateFormat('yyyy-MM-dd').format(DateTime(now.year, 12, 31)),
          'fajr': _formatTime(shafiTimings['Fajr']),
          'sunrise': _formatTime(shafiTimings['Sunrise']),
          'dhuhr': _formatTime(shafiTimings['Dhuhr']),
          'asr': _formatTime(shafiTimings['Asr']),
          'hanafiAsr': _formatTime(hanafiTimings['Asr']),
          'maghrib': _formatTime(shafiTimings['Maghrib']),
          'isha': _formatTime(shafiTimings['Isha']),
        };
        
        // Cache the fetched data
        await _cachePrayerTimes(today, prayerTimes);
        
        // Schedule notifications for prayer times
        await _notificationService.schedulePrayerTimeNotifications(prayerTimes);
        
        return prayerTimes;
      } else {
        throw Exception('Failed to load prayer times: ${shafiResponse.statusCode}, ${hanafiResponse.statusCode}');
      }
    } catch (e) {
      print('Error fetching prayer times: $e');
      
      // Try to get the most recent cached data if available
      final cachedData = await _getMostRecentCachedPrayerTimes();
      if (cachedData != null) {
        print('Using most recent cached prayer times');
        
        // Schedule notifications for cached prayer times
        await _notificationService.schedulePrayerTimeNotifications(cachedData);
        
        return cachedData;
      }
      
      // If no cached data at all, use hardcoded fallback
      print('Using hardcoded fallback prayer times');
      final now = DateTime.now();
      final today = DateFormat('yyyy-MM-dd').format(now);
      final endOfYear = DateFormat('yyyy-MM-dd').format(DateTime(now.year, 12, 31));
      
      final fallbackTimes = {
        'date': today,
        'startDate': today,
        'endDate': endOfYear,
        'fajr': '06:32 AM',
        'sunrise': '07:39 AM',
        'dhuhr': '13:15 PM',
        'asr': '16:45 PM',
        'hanafiAsr': '17:15 PM',
        'maghrib': '19:30 PM',
        'isha': '20:45 PM'
      };
      
      // Schedule notifications for fallback prayer times
      await _notificationService.schedulePrayerTimeNotifications(fallbackTimes);
      
      return fallbackTimes;
    }
  }
  
  // Helper method to format time from 24-hour to 12-hour format
  String _formatTime(String time24) {
    try {
      // Parse the 24-hour time
      final timeParts = time24.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      
      // Create a DateTime object to use DateFormat
      final dateTime = DateTime(2023, 1, 1, hour, minute);
      
      // Format to 12-hour time with AM/PM (hh:mm a)
      return DateFormat('hh:mm a').format(dateTime);
    } catch (e) {
      print('Error formatting time: $e');
      return time24;
    }
  }
  
  // Cache prayer times for a specific date
  Future<void> _cachePrayerTimes(String date, Map<String, dynamic> prayerTimes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Store the date
      await prefs.setString(_cachedDateKey, date);
      
      // Store the prayer times as JSON
      await prefs.setString(_cachedPrayerTimesKey, json.encode(prayerTimes));
      
      print('Prayer times cached successfully for $date');
    } catch (e) {
      print('Error caching prayer times: $e');
    }
  }
  
  // Get cached prayer times for a specific date
  Future<Map<String, dynamic>?> _getCachedPrayerTimes(String date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if we have cached data for this date
      final cachedDate = prefs.getString(_cachedDateKey);
      if (cachedDate != date) {
        return null; // No cached data for this date
      }
      
      // Get the cached prayer times
      final cachedPrayerTimesJson = prefs.getString(_cachedPrayerTimesKey);
      if (cachedPrayerTimesJson == null) {
        return null;
      }
      
      // Parse the JSON
      return json.decode(cachedPrayerTimesJson) as Map<String, dynamic>;
    } catch (e) {
      print('Error getting cached prayer times: $e');
      return null;
    }
  }
  
  // Get the most recent cached prayer times (regardless of date)
  Future<Map<String, dynamic>?> _getMostRecentCachedPrayerTimes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get the cached prayer times
      final cachedPrayerTimesJson = prefs.getString(_cachedPrayerTimesKey);
      if (cachedPrayerTimesJson == null) {
        return null;
      }
      
      // Parse the JSON
      final cachedPrayerTimes = json.decode(cachedPrayerTimesJson) as Map<String, dynamic>;
      
      // Update the date to today
      final now = DateTime.now();
      final today = DateFormat('yyyy-MM-dd').format(now);
      cachedPrayerTimes['date'] = today;
      cachedPrayerTimes['startDate'] = today;
      
      return cachedPrayerTimes;
    } catch (e) {
      print('Error getting most recent cached prayer times: $e');
      return null;
    }
  }
}