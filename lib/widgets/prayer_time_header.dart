import 'package:flutter/material.dart';
import 'package:prayer_time/widgets/mosque_image.dart';
import 'package:intl/intl.dart';

class PrayerTimeHeader extends StatelessWidget {
  final String city;
  final String state;
  final String hijriDate;
  final DateTime gregorianDate;

  const PrayerTimeHeader({
    super.key,
    required this.city,
    required this.state,
    required this.hijriDate,
    required this.gregorianDate,
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
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  hijriDate.isEmpty || hijriDate == 'Calculating Hijri date...'
                      ? 'Calculating Hijri date...'
                      : hijriDate,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}