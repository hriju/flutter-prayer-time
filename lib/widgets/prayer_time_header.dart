import 'package:flutter/material.dart';
import 'package:prayer_time/providers/madhab_provider.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PrayerTimeHeader extends StatelessWidget {
  final String date;
  final String hijriDate;
  final String city;
  final String madhab;

  const PrayerTimeHeader({
    super.key, 
    required this.date, 
    required this.hijriDate, 
    required this.city, 
    required this.madhab
  });

  @override
  Widget build(BuildContext context) {
    final madhabProvider = Provider.of<MadhabProvider>(context);
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, color: Colors.teal.shade700, size: 20),
            const SizedBox(width: 4),
            Text(
              city,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            date,
            style: theme.textTheme.bodyLarge!.copyWith(
              color: Colors.teal.shade800,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          hijriDate,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Calculation Method:',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.teal.shade300, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    madhab,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.teal.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () async => madhabProvider.setMadhab(
                      madhab == 'Shafi\'i' ? 'Hanafi' : 'Shafi\'i'
                    ),
                    child: Icon(
                      Icons.swap_horiz,
                      size: 16,
                      color: Colors.teal.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}