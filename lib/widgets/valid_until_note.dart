import 'package:flutter/material.dart';

class ValidUntilNote extends StatelessWidget {
  final String endDate;

  const ValidUntilNote({
    super.key,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.shade200, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            color: Colors.amber.shade800,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            'Valid until $endDate',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.amber.shade900,
            ),
          ),
        ],
      ),
    );
  }
}