import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prayer_time/services/prayer_times_service.dart';
import 'package:prayer_time/services/location_service.dart';
import 'package:prayer_time/services/notification_service.dart';
import 'package:prayer_time/widgets/prayer_time_header.dart';
import 'package:prayer_time/widgets/prayer_time_card.dart';
import 'package:prayer_time/pages/location_settings_page.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:prayer_time/pages/calculation_method_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerTimesPage extends StatefulWidget {
  const PrayerTimesPage({super.key});

  @override
  PrayerTimesPageState createState() => PrayerTimesPageState();
}

class PrayerTimesPageState extends State<PrayerTimesPage> with WidgetsBindingObserver {
  final PrayerTimesService _prayerTimesService = PrayerTimesService();
  final LocationService _locationService = LocationService();
  final NotificationService _notificationService = NotificationService();
  
  Map<String, dynamic>? _prayerTimes;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  String? _error;
  Timer? _refreshTimer;
  bool _isHanafi = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize services with error handling
    Future.microtask(() async {
      try {
        await _loadJuristicMethod();
        await _loadPrayerTimes();
        _startRefreshTimer();
      } catch (e) {
        print('Error during initialization: $e');
        setState(() {
          _error = 'Error initializing app: $e';
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App came back to foreground, update the date and prayer times
      final now = DateTime.now();
      if (_selectedDate.year != now.year || 
          _selectedDate.month != now.month || 
          _selectedDate.day != now.day) {
        setState(() {
          _selectedDate = now;
        });
        _loadPrayerTimes();
      }
    }
  }

  void _startRefreshTimer() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final now = DateTime.now();
      if (_selectedDate.year == now.year && 
          _selectedDate.month == now.month && 
          _selectedDate.day == now.day) {
        // Only reload if we're on today's date
        _loadPrayerTimes();
      }
    });
  }

  Future<void> _loadPrayerTimes() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final prayerTimes = await _prayerTimesService.fetchPrayerTimesForDate(_selectedDate);
      print('Received prayer times: $prayerTimes');
      
      if (prayerTimes == null || prayerTimes.isEmpty) {
        setState(() {
          _error = 'Failed to load prayer times. Please try again.';
          _isLoading = false;
        });
        return;
      }

      // Validate required fields
      if (!prayerTimes.containsKey('city') || !prayerTimes.containsKey('state')) {
        setState(() {
          _error = 'Invalid prayer times data received.';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _prayerTimes = prayerTimes;
        _isLoading = false;
      });
      
      print('Updated prayer times with Hijri date: ${_prayerTimes?['hijriDate']}');
    } catch (e, stackTrace) {
      print('Error loading prayer times: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _error = 'An error occurred: ${e.toString()}';
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

  Future<void> _openLocationSettings() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationSettingsPage(),
      ),
    );

    if (result == true) {
      // Location was updated, reload prayer times
      _loadPrayerTimes();
    }
  }

  Future<void> _loadJuristicMethod() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isHanafi = prefs.getInt('juristic_method') == 1;
    });
  }

  Future<void> _toggleJuristicMethod() async {
    final prefs = await SharedPreferences.getInstance();
    final newMethod = !_isHanafi ? 1 : 0;
    await prefs.setInt('juristic_method', newMethod);
    setState(() {
      _isHanafi = !_isHanafi;
    });
    _loadPrayerTimes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Times'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CalculationMethodPage(),
                ),
              );
              // Reload prayer times when returning from settings
              _loadPrayerTimes();
            },
            tooltip: 'Calculation Method',
          ),
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: _openLocationSettings,
            tooltip: 'Set Location',
          ),
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
          IconButton(
            icon: Icon(_isHanafi ? Icons.mosque : Icons.mosque_outlined),
            onPressed: _toggleJuristicMethod,
            tooltip: _isHanafi ? 'Hanafi Method' : 'Shafi\'i/Maliki/Hanbali Method',
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
                      gregorianDate: _selectedDate,
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
