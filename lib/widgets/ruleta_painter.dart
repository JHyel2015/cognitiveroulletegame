import 'dart:math';
import 'dart:ui';
import 'dart:ui' as Ui;
import 'package:flutter/material.dart';

class RuletaPainter extends CustomPainter {
  final double angle;
  int segments;
  final List<Color> colors;
  final List<Image> images;

  RuletaPainter(this.angle, this.segments, this.colors, this.images);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    final segmentPaint = Paint()
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke;

    segments = colors.isEmpty
        ? (images.isEmpty ? segments : images.length)
        : colors.length;

    final sweepAngle = 2 * pi / segments;

    for (int i = 0; i < segments; i++) {
      segmentPaint.color =
          colors.isEmpty ? (i.isEven ? Colors.red : Colors.black) : colors[i];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        angle + i * sweepAngle,
        sweepAngle,
        false,
        segmentPaint,
      );

      final textSpan = TextSpan(
        text: (i + 1).toString(),
        style: TextStyle(
          color: Colors.black,
          fontSize: 14,
        ),
      );

      // final Ui.Image image = images[i] as Ui.Image;
      // final imageSize = radius / 2;

      textPainter.text = textSpan;
      textPainter.layout();

      final x =
          center.dx + radius / 2 * cos(angle + i * sweepAngle + sweepAngle / 2);
      final y =
          center.dy + radius / 2 * sin(angle + i * sweepAngle + sweepAngle / 2);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle + i * sweepAngle + sweepAngle / 2);
      textPainter.paint(
          canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      // canvas.translate(center.dx, center.dy);
      // canvas.rotate(i * sweepAngle + sweepAngle / 2);
      // canvas.translate(0, -radius + imageSize / 2);
      // canvas.drawImageRect(
      //   image,
      //   Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      //   Rect.fromCenter(
      //       center: Offset(0, 0), width: imageSize, height: imageSize),
      //   Paint(),
      // );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
