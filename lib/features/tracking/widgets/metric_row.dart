import 'package:flutter/material.dart';
import 'package:keto_calculator/features/tracking/models/models.dart';

class MetricRow extends StatelessWidget {
  const MetricRow({
    required this.label,
    required this.value,
    required this.status,
    super.key,
  });
  final String label;
  final String value;
  final StatusLevel status;
  @override
  Widget build(BuildContext context) {
    Color c;
    switch (status) {
      case StatusLevel.under:
        c = Colors.orange;
      case StatusLevel.over:
        c = Colors.red;
      case StatusLevel.ok:
      default:
        c = Colors.green;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Row(
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Icon(Icons.circle, size: 12, color: c),
          ],
        ),
      ],
    );
  }
}
