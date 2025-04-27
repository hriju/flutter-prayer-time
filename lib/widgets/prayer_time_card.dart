import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PrayerTimeCard extends StatelessWidget {
  final String title;
  final String time;
  final String iqamahTime;

  const PrayerTimeCard({
    super.key,
    required this.title,
    required this.time,
    required this.iqamahTime,
  });

  IconData _getIconForPrayer(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return LucideIcons.sunrise;
      case 'sunrise':
        return LucideIcons.sun;
      case 'dhuhr':
        return LucideIcons.sun;
      case 'asr':
        return LucideIcons.sun;
      case 'maghrib':
        return LucideIcons.sunset;
      case 'isha':
        return LucideIcons.moon;
      default:
        return LucideIcons.clock;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              _getIconForPrayer(title),
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Iqamah: $iqamahTime',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}