import 'package:flutter/material.dart';

class MacroRowWidget extends StatelessWidget {
  final String label;
  final double grams;
  final double percentOfMacros;
  final double targetPercent;
  const MacroRowWidget({
    required this.label,
    required this.grams,
    required this.percentOfMacros,
    required this.targetPercent,
  });

  @override
  Widget build(BuildContext context) {
    final actualPercent = (percentOfMacros * 100).round();
    final diff = percentOfMacros - targetPercent;
    Color c;
    IconData icon;
    if (diff.abs() < 0.05) {
      c = Colors.green;
      icon = Icons.check;
    } else if (diff > 0) {
      c = Colors.red;
      icon = Icons.arrow_upward;
    } else {
      c = Colors.orange;
      icon = Icons.arrow_downward;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text('${grams.toStringAsFixed(0)} g'),
          const SizedBox(width: 8),
          Text('$actualPercent%'),
          const SizedBox(width: 8),
          Icon(icon, size: 16, color: c),
        ],
      ),
    );
  }
}
