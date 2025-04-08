import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prayer_time/services/prayer_times_service.dart';
import 'package:prayer_time/services/location_service.dart';
import 'package:prayer_time/services/notification_service.dart';
import 'package:prayer_time/widgets/prayer_time_header.dart';
import 'package:prayer_time/widgets/prayer_time_card.dart';

class PrayerTimesPage extends StatefulWidget {
  const PrayerTimesPage({super.key});

  @override
  PrayerTimesPageState createState() => PrayerTimesPageState();
}

class PrayerTimesPageState extends State<PrayerTimesPage> {
  final PrayerTimesService _prayerTimesService = PrayerTimesService();
  final LocationService _locationService = LocationService();
  final NotificationService _notificationService = NotificationService();
  
  Map<String, dynamic>? _prayerTimes;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
  }

  Future<void> _loadPrayerTimes() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final coordinates = await _locationService.getStoredCoordinates();
      if (coordinates == null) {
        setState(() {
          _error = 'Location not set. Please set your location.';
          _isLoading = false;
        });
        return;
      }

      print('Loading prayer times for date: $_selectedDate');
      final prayerTimes = await _prayerTimesService.fetchPrayerTimesForDate(_selectedDate);
      print('Received prayer times: $prayerTimes');
      
      if (prayerTimes == null) {
        setState(() {
          _error = 'Failed to load prayer times. Please try again.';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _prayerTimes = prayerTimes;
        _isLoading = false;
      });
      
      print('Updated prayer times with Hijri date: ${_prayerTimes?['hijriDate']}');
    } catch (e) {
      print('Error loading prayer times: $e');
      setState(() {
        _error = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  void _navigateDate(int days) {
    print('Navigating date by $days days');
    print('Current date: $_selectedDate');
    print('Current Hijri date: ${_prayerTimes?['hijriDate']}');
    
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
      _prayerTimes = null; // Clear current times
      _isLoading = true; // Set loading state
    });
    
    print('New date: $_selectedDate');
    _loadPrayerTimes(); // Load new times
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Times'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () async {
              if (_prayerTimes != null) {
                for (var entry in _prayerTimes!.entries) {
                  if (entry.key != 'date' && entry.key != 'city' && entry.key != 'state' && entry.key != 'hijriDate') {
                    await _notificationService.schedulePrayerTimeNotification(
                      prayerName: entry.key,
                      prayerTime: DateFormat('hh:mm a').parse(entry.value),
                      location: '${_prayerTimes!['city']}, ${_prayerTimes!['state']}',
                    );
                  }
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notifications scheduled for all prayer times.')),
                );
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Column(
                  children: [
                    PrayerTimeHeader(
                      city: _prayerTimes?['city'] ?? 'Unknown Location',
                      state: _prayerTimes?['state'] ?? '',
                      hijriDate: _prayerTimes?['hijriDate'] ?? 'Calculating...',
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => _navigateDate(-1),
                          ),
                          Text(
                            DateFormat('EEEE, MMMM d').format(_selectedDate),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: () => _navigateDate(1),
                          ),
                        ],
                      ),
                    ),
                    if (_prayerTimes != null) ...[
                      PrayerTimeCard(
                        title: 'Fajr',
                        time: _prayerTimes!['fajr'] ?? 'N/A',
                      ),
                      PrayerTimeCard(
                        title: 'Sunrise',
                        time: _prayerTimes!['sunrise'] ?? 'N/A',
                      ),
                      PrayerTimeCard(
                        title: 'Dhuhr',
                        time: _prayerTimes!['dhuhr'] ?? 'N/A',
                      ),
                      PrayerTimeCard(
                        title: 'Asr',
                        time: _prayerTimes!['asr'] ?? 'N/A',
                      ),
                      PrayerTimeCard(
                        title: 'Maghrib',
                        time: _prayerTimes!['maghrib'] ?? 'N/A',
                      ),
                      PrayerTimeCard(
                        title: 'Isha',
                        time: _prayerTimes!['isha'] ?? 'N/A',
                      ),
                    ],
                  ],
                ),
    );
  }
}
