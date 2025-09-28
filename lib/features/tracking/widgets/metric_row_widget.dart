import 'package:flutter/material.dart';
import 'package:keto_calculator/features/tracking/models/models.dart';

class MetricRowWidget extends StatelessWidget {
  final String label;
  final String value;
  final StatusLevel status;
  const MetricRowWidget({
    required this.label,
    required this.value,
    required this.status,
  });
  @override
  Widget build(BuildContext context) {
    Color c;
    switch (status) {
      case StatusLevel.under:
        c = Colors.orange;
        break;
      case StatusLevel.over:
        c = Colors.red;
        break;
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
            Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Icon(Icons.circle, size: 12, color: c),
          ],
        ),
      ],
    );
  }
}
