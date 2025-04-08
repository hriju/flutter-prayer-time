import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prayer_time/services/location_service.dart';
import 'package:flutter/foundation.dart';

class PrayerTimesService {
  // Cache keys
  static const String _cachedDateKey = 'cached_date';
  static const String _cachedPrayerTimesKey = 'cached_prayer_times';
  
  // Services
  final LocationService _locationService = LocationService();
  
  Future<Map<String, dynamic>?> fetchPrayerTimesForDate(DateTime date) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      print('Fetching prayer times for date: $dateStr');
      
      // Get stored coordinates
      final coordinates = await _locationService.getStoredCoordinates();
      if (coordinates == null) {
        throw Exception('Location not set. Please set your location first.');
      }
      
      final latitude = coordinates['latitude'];
      final longitude = coordinates['longitude'];
      
      // First, fetch the Hijri date
      final hijriUrl = Uri.parse('https://api.aladhan.com/v1/gToH/$dateStr');
      print('Fetching Hijri date from: $hijriUrl');
      
      final hijriResponse = await http.get(
        hijriUrl,
        headers: {
          'Accept': 'application/json',
        },
      );
      
      print('Hijri API Response Status: ${hijriResponse.statusCode}');
      print('Hijri API Response Body: ${hijriResponse.body}');
      
      String hijriDateStr = '';
      if (hijriResponse.statusCode == 200) {
        final hijriData = json.decode(hijriResponse.body);
        print('Parsed Hijri Data: $hijriData');
        
        if (hijriData['code'] == 200 && hijriData['data'] != null) {
          final hijri = hijriData['data']['hijri'];
          print('Hijri Object: $hijri');
          
          if (hijri != null) {
            final day = hijri['day'].toString().padLeft(2, '0');
            final month = hijri['month']['en'];
            final year = hijri['year'];
            hijriDateStr = '$day $month $year';
            print('Successfully calculated Hijri date for $dateStr: $hijriDateStr');
          } else {
            print('Hijri data is null in API response');
          }
        } else {
          print('API returned error code: ${hijriData['code']} or data is null');
        }
      } else {
        print('Hijri API request failed with status: ${hijriResponse.statusCode}');
      }
      
      // Fetch Shafi'i (standard) prayer times
      final shafiUrl = Uri.parse(
        'https://api.aladhan.com/v1/timings/$dateStr?latitude=$latitude&longitude=$longitude&method=2&school=0&adjustment=0'
      );
      
      // Fetch Hanafi prayer times
      final hanafiUrl = Uri.parse(
        'https://api.aladhan.com/v1/timings/$dateStr?latitude=$latitude&longitude=$longitude&method=2&school=1&adjustment=0'
      );
      
      final shafiResponse = await http.get(shafiUrl);
      final hanafiResponse = await http.get(hanafiUrl);
      
      if (shafiResponse.statusCode == 200 && hanafiResponse.statusCode == 200) {
        final shafiData = json.decode(shafiResponse.body);
        final hanafiData = json.decode(hanafiResponse.body);
        
        final shafiTimings = shafiData['data']['timings'];
        final hanafiTimings = hanafiData['data']['timings'];
        
        // Get stored location for display
        final location = await _locationService.getStoredLocation();
        final city = location?['city'] ?? 'Unknown Location';
        final state = location?['state'] ?? '';
        
        final prayerTimes = {
          'date': dateStr,
          'fajr': _formatTime(shafiTimings['Fajr']),
          'sunrise': _formatTime(shafiTimings['Sunrise']),
          'dhuhr': _formatTime(shafiTimings['Dhuhr']),
          'asr': _formatTime(shafiTimings['Asr']),
          'hanafiAsr': _formatTime(hanafiTimings['Asr']),
          'maghrib': _formatTime(shafiTimings['Maghrib']),
          'isha': _formatTime(shafiTimings['Isha']),
          'city': city,
          'state': state,
          'hijriDate': hijriDateStr,
        };
        
        print('Returning prayer times with Hijri date: $hijriDateStr');
        return prayerTimes;
      } else {
        throw Exception('Failed to load prayer times: ${shafiResponse.statusCode}, ${hanafiResponse.statusCode}');
      }
    } catch (e) {
      print('Error fetching prayer times: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchCurrentPrayerTimes() async {
    return fetchPrayerTimesForDate(DateTime.now());
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
}