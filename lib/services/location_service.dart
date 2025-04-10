import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static const String _locationKey = 'user_location';
  static const String _coordinatesKey = 'user_coordinates';
  
  // Geocoding API endpoint (using OpenStreetMap Nominatim API)
  static const String _geocodingUrl = 'https://nominatim.openstreetmap.org/search';
  
  Future<Map<String, String>> getStoredLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final locationJson = prefs.getString(_locationKey);
    if (locationJson != null) {
      return Map<String, String>.from(json.decode(locationJson));
    }
    return {
      'city': 'Mecca',
      'state': 'Makkah Province',
      'zipCode': ''
    };
  }
  
  Future<Map<String, double>> getStoredCoordinates() async {
    final prefs = await SharedPreferences.getInstance();
    final coordinatesJson = prefs.getString(_coordinatesKey);
    if (coordinatesJson != null) {
      final Map<String, dynamic> data = json.decode(coordinatesJson);
      return {
        'latitude': data['latitude'].toDouble(),
        'longitude': data['longitude'].toDouble(),
      };
    }
    return {
      'latitude': 21.422487,
      'longitude': 39.826206
    };
  }
  
  Future<void> saveLocation(Map<String, String> locationData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_locationKey, json.encode(locationData));
  }
  
  Future<void> saveCoordinates(Map<String, double> coordinatesData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_coordinatesKey, json.encode(coordinatesData));
  }
  
  Future<Map<String, double>?> getCoordinatesFromZipCode(String zipCode) async {
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
          
          // Store the location and coordinates
          if (city.isNotEmpty && state.isNotEmpty) {
            await saveLocation({
              'city': city,
              'state': state,
              'zipCode': zipCode,
            });
            
            final coordinates = {
              'latitude': double.parse(result['lat']),
              'longitude': double.parse(result['lon']),
            };
            await saveCoordinates(coordinates);
            return coordinates;
          }
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
  
  Future<Map<String, double>?> getCoordinatesFromCityState(String city, String state) async {
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
          
          // Store the location and coordinates
          if (foundCity.isNotEmpty && foundState.isNotEmpty) {
            await saveLocation({
              'city': foundCity,
              'state': foundState,
              'zipCode': '',
            });
            
            final coordinates = {
              'latitude': double.parse(result['lat']),
              'longitude': double.parse(result['lon']),
            };
            await saveCoordinates(coordinates);
            return coordinates;
          }
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