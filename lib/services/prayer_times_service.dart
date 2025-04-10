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
  static const String _calculationMethodKey = 'calculation_method';
  static const String _juristicMethodKey = 'juristic_method';
  
  // Services
  final LocationService _locationService = LocationService();
  
  Future<int> _getCalculationMethod() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_calculationMethodKey) ?? 2; // Default to ISNA
  }

  Future<int> _getJuristicMethod() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_juristicMethodKey) ?? 0; // Default to Shafi'i
  }

  Future<Map<String, dynamic>> fetchPrayerTimesForDate(DateTime date) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      print('Fetching prayer times for date: $dateStr');
      
      // Get stored coordinates and methods
      final coordinates = await _locationService.getStoredCoordinates();
      final calculationMethod = await _getCalculationMethod();
      final juristicMethod = await _getJuristicMethod();
      print('Using coordinates: $coordinates');
      print('Using calculation method: $calculationMethod');
      print('Using juristic method: $juristicMethod');
      
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
            hijriDateStr = 'Calculating Hijri date...';
          }
        } else {
          print('API returned error code: ${hijriData['code']} or data is null');
          hijriDateStr = 'Calculating Hijri date...';
        }
      } else {
        print('Hijri API request failed with status: ${hijriResponse.statusCode}');
        // Calculate approximate Hijri date as fallback
        final gregorianDate = DateTime.parse(dateStr);
        final hijriDate = _convertToHijri(gregorianDate);
        final day = hijriDate['day']?.toString().padLeft(2, '0') ?? '01';
        final month = _getHijriMonthName(hijriDate['month'] ?? 1);
        final year = hijriDate['year']?.toString() ?? '1446';
        hijriDateStr = '$day $month $year';
      }
      
      // Fetch prayer times based on selected juristic method
      final prayerTimesUrl = Uri.parse(
        'https://api.aladhan.com/v1/timings/$dateStr?latitude=$latitude&longitude=$longitude&method=$calculationMethod&school=$juristicMethod&adjustment=0'
      );
      
      final prayerTimesResponse = await http.get(prayerTimesUrl);
      
      if (prayerTimesResponse.statusCode == 200) {
        final prayerTimesData = json.decode(prayerTimesResponse.body);
        final timings = prayerTimesData['data']['timings'];
        
        // Get stored location for display
        final location = await _locationService.getStoredLocation();
        final city = location['city'];
        final state = location['state'];
        
        final prayerTimes = {
          'date': dateStr,
          'fajr': _formatTime(timings['Fajr']),
          'sunrise': _formatTime(timings['Sunrise']),
          'dhuhr': _formatTime(timings['Dhuhr']),
          'asr': _formatTime(timings['Asr']),
          'maghrib': _formatTime(timings['Maghrib']),
          'isha': _formatTime(timings['Isha']),
          'city': city,
          'state': state,
          'hijriDate': hijriDateStr,
        };
        
        print('Returning prayer times with Hijri date: $hijriDateStr');
        return prayerTimes;
      } else {
        throw Exception('Failed to load prayer times: ${prayerTimesResponse.statusCode}');
      }
    } catch (e) {
      print('Error fetching prayer times: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchCurrentPrayerTimes() async {
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

  String _getHijriMonthName(int month) {
    const months = [
      'Muharram',
      'Safar',
      'Rabi al-Awwal',
      'Rabi al-Thani',
      'Jumada al-Awwal',
      'Jumada al-Thani',
      'Rajab',
      'Sha\'ban',
      'Ramadan',
      'Shawwal',
      'Dhu al-Qi\'dah',
      'Dhu al-Hijjah'
    ];
    return months[month - 1];
  }

  Map<String, int> _convertToHijri(DateTime gregorianDate) {
    // Base date: April 8, 2025 = Shawwal 10, 1446
    final baseGregorianDate = DateTime(2025, 4, 8);
    final baseHijriDate = {
      'year': 1446,
      'month': 10, // Shawwal
      'day': 10,
    };
    
    // Calculate the difference in days
    final differenceInDays = gregorianDate.difference(baseGregorianDate).inDays;
    
    // Calculate the new Hijri date
    int hijriDay = baseHijriDate['day']! + differenceInDays;
    int hijriMonth = baseHijriDate['month']!;
    int hijriYear = baseHijriDate['year']!;
    
    // Adjust for month overflow
    while (hijriDay > 30) { // Hijri months have 29 or 30 days
      hijriDay -= 30;
      hijriMonth++;
      if (hijriMonth > 12) {
        hijriMonth = 1;
        hijriYear++;
      }
    }
    
    // Adjust for negative days
    while (hijriDay < 1) {
      hijriMonth--;
      if (hijriMonth < 1) {
        hijriMonth = 12;
        hijriYear--;
      }
      hijriDay += 30;
    }
    
    return {
      'year': hijriYear,
      'month': hijriMonth,
      'day': hijriDay,
    };
  }
}