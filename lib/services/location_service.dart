import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' if (dart.library.io) 'dart:io' as html;

class LocationService {
  static const String _locationKey = 'user_location';
  static const String _coordinatesKey = 'user_coordinates';
  
  // Geocoding API endpoint (using OpenStreetMap Nominatim API)
  static const String _geocodingUrl = 'https://nominatim.openstreetmap.org/search';
  
  Future<Map<String, dynamic>?> getStoredLocation() async {
    try {
      if (kIsWeb) {
        // In web mode, try to get from localStorage first
        final locationJson = html.window.localStorage[_locationKey];
        if (locationJson != null) {
          print('Retrieved stored location from localStorage: $locationJson');
          return json.decode(locationJson);
        }
      }
      
      // Fallback to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final locationJson = prefs.getString(_locationKey);
      if (locationJson != null) {
        print('Retrieved stored location from SharedPreferences: $locationJson');
        return json.decode(locationJson);
      }
      
      print('No stored location found');
      return null;
    } catch (e) {
      print('Error getting stored location: $e');
      return null;
    }
  }
  
  Future<Map<String, dynamic>?> getStoredCoordinates() async {
    try {
      if (kIsWeb) {
        // In web mode, try to get from localStorage first
        final coordinatesJson = html.window.localStorage[_coordinatesKey];
        if (coordinatesJson != null) {
          print('Retrieved stored coordinates from localStorage: $coordinatesJson');
          return json.decode(coordinatesJson);
        }
      }
      
      // Fallback to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final coordinatesJson = prefs.getString(_coordinatesKey);
      if (coordinatesJson != null) {
        print('Retrieved stored coordinates from SharedPreferences: $coordinatesJson');
        return json.decode(coordinatesJson);
      }
      
      print('No stored coordinates found');
      return null;
    } catch (e) {
      print('Error getting stored coordinates: $e');
      return null;
    }
  }
  
  Future<void> storeLocation(String city, String state) async {
    try {
      final locationData = {
        'city': city,
        'state': state,
      };
      
      if (kIsWeb) {
        // In web mode, store in localStorage
        html.window.localStorage[_locationKey] = json.encode(locationData);
        print('Stored location in localStorage: $locationData');
      }
      
      // Also store in SharedPreferences as fallback
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_locationKey, json.encode(locationData));
      print('Stored location in SharedPreferences: $locationData');
    } catch (e) {
      print('Error storing location: $e');
    }
  }
  
  Future<void> storeCoordinates(double latitude, double longitude) async {
    try {
      final coordinatesData = {
        'latitude': latitude,
        'longitude': longitude,
      };
      
      if (kIsWeb) {
        // In web mode, store in localStorage
        html.window.localStorage[_coordinatesKey] = json.encode(coordinatesData);
        print('Stored coordinates in localStorage: $coordinatesData');
      }
      
      // Also store in SharedPreferences as fallback
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_coordinatesKey, json.encode(coordinatesData));
      print('Stored coordinates in SharedPreferences: $coordinatesData');
    } catch (e) {
      print('Error storing coordinates: $e');
    }
  }
  
  Future<Map<String, dynamic>?> getCoordinatesFromZipCode(String zipCode) async {
    try {
      print('Fetching coordinates for ZIP code: $zipCode');
      final response = await http.get(
        Uri.parse('$_geocodingUrl?postalcode=$zipCode&format=json&limit=1&countrycodes=us&addressdetails=1'),
        headers: {
          'User-Agent': 'PrayerTimeApp/1.0',
          'Accept': 'application/json',
        },
      );
      
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        if (results.isNotEmpty) {
          final result = results[0];
          print('Found location: ${result['display_name']}');
          
          // Extract city and state from address components
          final address = result['address'] as Map<String, dynamic>;
          String city = '';
          String state = '';
          
          // Try different address components for city
          if (address['city'] != null) {
            city = address['city'];
          } else if (address['town'] != null) {
            city = address['town'];
          } else if (address['village'] != null) {
            city = address['village'];
          } else if (address['suburb'] != null) {
            city = address['suburb'];
          }
          
          // Get state from address
          state = address['state'] ?? '';
          
          print('Extracted city: $city, state: $state');
          
          // Store the location and coordinates immediately
          if (city.isNotEmpty && state.isNotEmpty) {
            await storeLocation(city, state);
            await storeCoordinates(
              double.parse(result['lat']),
              double.parse(result['lon']),
            );
          }
          
          return {
            'latitude': double.parse(result['lat']),
            'longitude': double.parse(result['lon']),
            'city': city,
            'state': state,
          };
        } else {
          print('No results found for ZIP code: $zipCode');
        }
      } else {
        print('Error response: ${response.statusCode} - ${response.body}');
      }
      return null;
    } catch (e) {
      print('Error getting coordinates from zip code: $e');
      return null;
    }
  }
  
  Future<Map<String, dynamic>?> getCoordinatesFromCityState(String city, String state) async {
    try {
      print('Fetching coordinates for city: $city, state: $state');
      final query = '$city, $state, USA';
      final response = await http.get(
        Uri.parse('$_geocodingUrl?q=${Uri.encodeComponent(query)}&format=json&limit=1&addressdetails=1'),
        headers: {
          'User-Agent': 'PrayerTimeApp/1.0',
          'Accept': 'application/json',
        },
      );
      
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        if (results.isNotEmpty) {
          final result = results[0];
          print('Found location: ${result['display_name']}');
          
          // Extract city and state from address components
          final address = result['address'] as Map<String, dynamic>;
          String foundCity = '';
          String foundState = '';
          
          // Try different address components for city
          if (address['city'] != null) {
            foundCity = address['city'];
          } else if (address['town'] != null) {
            foundCity = address['town'];
          } else if (address['village'] != null) {
            foundCity = address['village'];
          } else if (address['suburb'] != null) {
            foundCity = address['suburb'];
          }
          
          // Get state from address
          foundState = address['state'] ?? '';
          
          print('Extracted city: $foundCity, state: $foundState');
          
          // Store the location and coordinates immediately
          if (foundCity.isNotEmpty && foundState.isNotEmpty) {
            await storeLocation(foundCity, foundState);
            await storeCoordinates(
              double.parse(result['lat']),
              double.parse(result['lon']),
            );
          }
          
          return {
            'latitude': double.parse(result['lat']),
            'longitude': double.parse(result['lon']),
            'city': foundCity.isNotEmpty ? foundCity : city,
            'state': foundState.isNotEmpty ? foundState : state,
          };
        } else {
          print('No results found for city: $city, state: $state');
        }
      } else {
        print('Error response: ${response.statusCode} - ${response.body}');
      }
      return null;
    } catch (e) {
      print('Error getting coordinates from city and state: $e');
      return null;
    }
  }
} 