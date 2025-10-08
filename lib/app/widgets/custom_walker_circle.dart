import 'dart:math';
import 'package:flutter/material.dart';

class CustomWalkerCircle extends StatelessWidget {
  final double size;
  final double lineAngle; // rotasi dalam radian (animasi)
  final int numMarkers;
  final List<Color> arcColors; // warna busur (atas->kanan->bawah->kiri)

  const CustomWalkerCircle({
    Key? key,
    this.size = 400,
    this.lineAngle = 0,
    this.numMarkers = 12,
    this.arcColors = const [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
    ],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _WalkerPainter(
        lineAngle: lineAngle,
        numMarkers: numMarkers,
        arcColors: arcColors,
      ),
    );
  }
}

class _WalkerPainter extends CustomPainter {
  final double lineAngle;
  final int numMarkers;
  final List<Color> arcColors;

  _WalkerPainter({
    required this.lineAngle,
    required this.numMarkers,
    required this.arcColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Outer double circle
    final outerCirclePaint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius, outerCirclePaint);
    canvas.drawCircle(center, radius - 15, outerCirclePaint..strokeWidth = 2);

    // Inner circles
    final innerCirclePaint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius * 0.3, innerCirclePaint);
    canvas.drawCircle(center, radius * 0.33, innerCirclePaint);

    // Markers (tick) around circle
    final markerPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;
    for (int i = 0; i < numMarkers; i++) {
      final angle = i * 2 * pi / numMarkers;
      final p1 = Offset(
        center.dx + (radius + 8) * cos(angle),
        center.dy + (radius + 8) * sin(angle),
      );
      final p2 = Offset(
        center.dx + (radius - 6) * cos(angle),
        center.dy + (radius - 6) * sin(angle),
      );
      canvas.drawLine(p1, p2, markerPaint);
    }

    // Draw colored arcs (busur indikator) di lingkaran luar, BERPUTAR!
    final arcStroke = 5.0;
    final arcRadius = radius - arcStroke / 0.6;
    final arcSweep = pi / 2; // 90 derajat (quarter)
    for (int i = 0; i < 4; i++) {
      final arcPaint = Paint()
        ..color = arcColors[i % arcColors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = arcStroke
        ..strokeCap = StrokeCap.round;
      // Mulai dari -pi/2 (atas), lalu searah jarum jam, OFFSET by lineAngle
      final startAngle = -pi / 2 + i * arcSweep + lineAngle;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: arcRadius),
        startAngle,
        arcSweep,
        false,
        arcPaint,
      );
    }

    // Cross lines (horizontal & vertical, blue), BERPUTAR!
    final crossPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4;

    // HANYA satu plus! (bukan double plus)
    // Garis utama (lineAngle)
    final lineEnd1 = Offset(
      center.dx + radius * cos(lineAngle),
      center.dy + radius * sin(lineAngle),
    );
    final lineStart1 = Offset(
      center.dx - radius * cos(lineAngle),
      center.dy - radius * sin(lineAngle),
    );
    canvas.drawLine(lineStart1, lineEnd1, crossPaint);

    // Garis tegak lurus (lineAngle + 90deg)
    final angle2 = lineAngle + pi / 2;
    final lineEnd2 = Offset(
      center.dx + radius * cos(angle2),
      center.dy + radius * sin(angle2),
    );
    final lineStart2 = Offset(
      center.dx - radius * cos(angle2),
      center.dy - radius * sin(angle2),
    );
    canvas.drawLine(lineStart2, lineEnd2, crossPaint);

    // Bulatan biru di 4 ujung plus, BERPUTAR!
    final plusRadius = 12.0;
    final indicatorPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    // Atas (lineAngle -pi/2)
    final offsetTop = Offset(
      center.dx + radius * cos(lineAngle - pi / 2),
      center.dy + radius * sin(lineAngle - pi / 2),
    );
    // Kanan (lineAngle)
    final offsetRight = Offset(
      center.dx + radius * cos(lineAngle),
      center.dy + radius * sin(lineAngle),
    );
    // Bawah (lineAngle +pi/2)
    final offsetBottom = Offset(
      center.dx + radius * cos(lineAngle + pi / 2),
      center.dy + radius * sin(lineAngle + pi / 2),
    );
    // Kiri (lineAngle +pi)
    final offsetLeft = Offset(
      center.dx + radius * cos(lineAngle + pi),
      center.dy + radius * sin(lineAngle + pi),
    );
    canvas.drawCircle(offsetTop, plusRadius, indicatorPaint);
    canvas.drawCircle(offsetRight, plusRadius, indicatorPaint);
    canvas.drawCircle(offsetBottom, plusRadius, indicatorPaint);
    canvas.drawCircle(offsetLeft, plusRadius, indicatorPaint);
  }

  @override
  bool shouldRepaint(covariant _WalkerPainter oldDelegate) =>
      oldDelegate.lineAngle != lineAngle ||
      oldDelegate.numMarkers != numMarkers ||
      oldDelegate.arcColors != arcColors;
}
