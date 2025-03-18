import 'package:flutter/material.dart';
import 'package:prayer_time/services/prayer_times_service.dart';
import 'package:prayer_time/widgets/prayer_time_header.dart';
import 'package:prayer_time/widgets/prayer_times_list.dart';
import 'package:prayer_time/widgets/valid_until_note.dart';
import 'package:prayer_time/providers/madhab_provider.dart';
import 'package:prayer_time/services/hijri_date_service.dart';
import 'package:prayer_time/widgets/mosque_image.dart';
import 'package:provider/provider.dart';
import 'package:prayer_time/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerTimesPage extends StatefulWidget {
  const PrayerTimesPage({super.key});

  @override
  PrayerTimesPageState createState() => PrayerTimesPageState();
}

class PrayerTimesPageState extends State<PrayerTimesPage> {
  final PrayerTimesService _prayerTimesService = PrayerTimesService();
  final HijriDateService _hijriDateService = HijriDateService();
  final NotificationService _notificationService = NotificationService();
  Map<String, dynamic>? _prayerTimes;
  String? _hijriDate;
  bool _notificationsEnabled = true;
  final List<String> _shafiFilter = [
    "fajr",
    "sunrise",
    "dhuhr",
    "asr",
    "maghrib",
    "isha"
  ];
  final List<String> _hanafiFilter = [
    "fajr",
    "sunrise",
    "dhuhr",
    "hanafiAsr",
    "maghrib",
    "isha"
  ];

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
    _calculateHijriDate();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    
    setState(() {
      _notificationsEnabled = value;
    });
    
    if (value) {
      // Re-schedule notifications if enabled
      if (_prayerTimes != null) {
        await _notificationService.schedulePrayerTimeNotifications(_prayerTimes!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prayer time notifications enabled'),
            backgroundColor: Colors.teal,
          ),
        );
      }
    } else {
      // Cancel all notifications if disabled
      await _notificationService.cancelAllNotifications();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prayer time notifications disabled'),
          backgroundColor: Colors.grey,
        ),
      );
    }
  }

  Future<void> _loadPrayerTimes() async {
    try {
      final data = await _prayerTimesService.fetchCurrentPrayerTimes();
      setState(() {
        _prayerTimes = data;
      });
    } catch (e) {
      debugPrint('Failed to fetch prayer times: $e');
    }
  }

  Future<void> _calculateHijriDate() async {
    try {
      final hijriDate = await _hijriDateService.calculateHijriDate(DateTime.now());
      setState(() {
        _hijriDate = hijriDate;
      });
    } catch (e) {
      debugPrint('Failed to calculate Hijri date: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final madhabProvider = Provider.of<MadhabProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: _prayerTimes == null
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.teal,
              ),
            )
          : SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 220,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    floating: true,
                    pinned: false,
                    flexibleSpace: FlexibleSpaceBar(
                      background: MosqueImage(
                        height: 220,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      elevation: 4,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            PrayerTimeHeader(
                              date: _prayerTimes!['date'],
                              hijriDate: _hijriDate ?? 'Calculating...',
                              city: 'Plano, Texas',
                              madhab: madhabProvider.madhab!,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      elevation: 2,
                      shadowColor: Colors.black12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SwitchListTile(
                        title: const Text(
                          'Prayer Time Notifications',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          _notificationsEnabled 
                              ? 'You will receive notifications for prayer times' 
                              : 'Notifications are disabled',
                        ),
                        value: _notificationsEnabled,
                        onChanged: _toggleNotifications,
                        activeColor: Colors.teal,
                        secondary: Icon(
                          _notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
                          color: _notificationsEnabled ? Colors.teal : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.teal),
                          const SizedBox(width: 8),
                          Text(
                            'Today\'s Prayer Schedule',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final filteredKeys = madhabProvider.madhab == 'Shafi\'i'
                              ? _shafiFilter
                              : _hanafiFilter;
                          
                          if (index >= filteredKeys.length) return null;
                          
                          final prayerName = filteredKeys[index];
                          final prayerTime = _prayerTimes![prayerName];
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            elevation: 2,
                            shadowColor: Colors.black12,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getPrayerColor(prayerName),
                                child: Icon(
                                  _getPrayerIcon(prayerName),
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                _getPrayerTitle(prayerName),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              trailing: Text(
                                prayerTime,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.teal.shade700,
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: (madhabProvider.madhab == 'Shafi\'i'
                                ? _shafiFilter
                                : _hanafiFilter)
                            .length,
                      ),
                    ),
                  ),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
                ],
              ),
            ),
    );
  }
  
  Color _getPrayerColor(String prayerName) {
    switch (prayerName) {
      case 'fajr':
        return Colors.indigo;
      case 'sunrise':
        return Colors.orange;
      case 'dhuhr':
        return Colors.amber.shade800;
      case 'asr':
      case 'hanafiAsr':
        return Colors.teal;
      case 'maghrib':
        return Colors.deepPurple;
      case 'isha':
        return Colors.blueGrey.shade800;
      default:
        return Colors.teal;
    }
  }
  
  IconData _getPrayerIcon(String prayerName) {
    switch (prayerName) {
      case 'fajr':
        return Icons.wb_twilight;
      case 'sunrise':
        return Icons.wb_sunny;
      case 'dhuhr':
        return Icons.sunny;
      case 'asr':
      case 'hanafiAsr':
        return Icons.sunny_snowing;
      case 'maghrib':
        return Icons.nightlight;
      case 'isha':
        return Icons.nightlight_round;
      default:
        return Icons.access_time;
    }
  }
  
  String _getPrayerTitle(String prayerName) {
    switch (prayerName) {
      case 'fajr':
        return 'Fajr';
      case 'sunrise':
        return 'Sunrise';
      case 'dhuhr':
        return 'Dhuhr';
      case 'asr':
        return 'Asr';
      case 'hanafiAsr':
        return 'Asr (Hanafi)';
      case 'maghrib':
        return 'Maghrib';
      case 'isha':
        return 'Isha';
      default:
        return prayerName;
    }
  }
}
