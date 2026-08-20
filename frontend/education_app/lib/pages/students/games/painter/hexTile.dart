import 'dart:math';
import 'package:flutter/material.dart';

class HoneycombPainter extends CustomPainter {
  final List<List<int>> numbers;
  final List<List<bool>> playerGrid;
  final double sideLength;

  HoneycombPainter({
    required this.numbers,
    required this.playerGrid,
    required this.sideLength,
  });

  double get hexH => sqrt(3) * sideLength;

  double get yOffset {
  return (numbers.length - 1) * 0.5 * hexH + hexH / 2;
}

  Offset centerOf(int col, int row) {
  final double x = sideLength + (col + row) * 1.5 * sideLength;
  final double y = 
      yOffset + (col - row) * 0.5 * hexH+5;

  return Offset(x, y);
}
  void drawHex(Canvas canvas, Offset center, Color color) {
    final path = Path();
    final cx = center.dx;
    final cy = center.dy;

    path.moveTo(cx - sideLength * 0.5, cy - hexH / 2);
    path.lineTo(cx + sideLength * 0.5, cy - hexH / 2);
    path.lineTo(cx + sideLength, cy);
    path.lineTo(cx + sideLength * 0.5, cy + hexH / 2);
    path.lineTo(cx - sideLength * 0.5, cy + hexH / 2);
    path.lineTo(cx - sideLength, cy);
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.black,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final rows = numbers.length;
    final cols = numbers[0].length;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final center = centerOf(col, row);
        final color = playerGrid[row][col]
            ? Colors.amber
            : Colors.grey.shade300;
        drawHex(canvas, center, color);

        final tp = TextPainter(
          text: TextSpan(
            text: '${numbers[row][col]}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(HoneycombPainter old) => true;
}
