import 'package:flutter/material.dart';
import 'package:prayer_time/pages/prayer_times_page.dart';
import 'package:prayer_time/services/notification_service.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize notification service with error handling
    try {
      await NotificationService().initialize();
    } catch (e) {
      print('Warning: Failed to initialize notifications: $e');
      // Continue without notifications
    }
    
    runApp(const MyApp());
  } catch (e) {
    print('Fatal error during app initialization: $e');
    // You might want to show an error screen here
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error initializing app: $e'),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prayer Times',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const PrayerTimesPage(),
    );
  }
}
