import 'dart:math';
import 'package:flutter/material.dart';

class PieChartWidget extends StatelessWidget {
  final Map<String, double> data; // values 0..1 that sum to ~1
  const PieChartWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = [Colors.blue, Colors.green, Colors.orange];
    return Column(
      children: [
        Expanded(
          child: CustomPaint(
            size: Size.infinite,
            painter: _PiePainter(
              values: data.values.toList(),
              colors: colors.take(data.length).toList(),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: data.keys.toList().asMap().entries.map((e) {
            final idx = e.key;
            final k = e.value;
            final percent = (data[k]! * 100).round();
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  color: colors[idx % colors.length],
                ),
                const SizedBox(width: 6),
                Text('$k $percent%'),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _PiePainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  _PiePainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final radius = min(size.width, size.height) / 2 * 0.9;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()..style = PaintingStyle.fill;
    double startAngle = -pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = (values[i].isFinite ? values[i] : 0.0) * 2 * pi;
      paint.color = colors[i % colors.length];
      canvas.drawArc(rect, startAngle, sweep, true, paint);
      startAngle += sweep;
    }
    // inner circle for donut
    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius * 0.5, innerPaint);
    // optional center text
    final tp = TextPainter(
      text: TextSpan(
        text: 'БЖУ',
        style: TextStyle(color: Colors.black, fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _PiePainter oldDelegate) {
    return oldDelegate.values != values;
  }
}
