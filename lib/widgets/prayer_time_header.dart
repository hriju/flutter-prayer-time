import 'package:flutter/material.dart';
import 'package:prayer_time/widgets/mosque_image.dart';

class PrayerTimeHeader extends StatelessWidget {
  final String city;
  final String state;
  final String hijriDate;

  const PrayerTimeHeader({
    super.key,
    required this.city,
    required this.state,
    required this.hijriDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const MosqueImage(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                '$city, $state',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                hijriDate,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}