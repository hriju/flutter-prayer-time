import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Event {
  final String title;
  final DateTime date;
  final String time;
  final String location;

  const Event({
    required this.title,
    required this.date,
    required this.time,
    required this.location,
  });
}

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  List<Event> _getEventsForMonth(DateTime date) {
    // For now, return dummy data for April 2025
    if (date.month == 4 && date.year == 2025) {
      return [
        Event(
          title: 'The Fiqh of Worship',
          date: DateTime(2025, 4, 3),
          time: '6:00 PM',
          location: 'IACC - Plano Masjid',
        ),
        Event(
          title: '8 Week Intensive Nutrition Education & Weight Management Challenge',
          date: DateTime(2025, 4, 13),
          time: '7:30 AM',
          location: 'IACC SISTERS COMMITTEE PRESENTS',
        ),
        Event(
          title: 'The Heart of Worship',
          date: DateTime(2025, 4, 13),
          time: '3:00 PM',
          location: 'IACC - Plano Masjid',
        ),
        Event(
          title: 'Jumpstart Your AI Career',
          date: DateTime(2025, 4, 26),
          time: '2:30 PM',
          location: 'IACC - Plano Masjid',
        ),
      ];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final currentDate = DateTime.now();
    final events = _getEventsForMonth(currentDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          final formattedDate = DateFormat('EEEE, MMMM d').format(event.date);
          
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formattedDate,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 4),
                      Text(event.time),
                      const SizedBox(width: 16),
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(event.location),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 