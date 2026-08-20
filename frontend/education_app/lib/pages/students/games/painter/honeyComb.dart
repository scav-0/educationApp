import 'dart:math';

import 'package:education_app/pages/students/games/painter/hexTile.dart';
import 'package:flutter/material.dart';

class HoneycombGrid extends StatelessWidget {
  final List<List<int>> numbers;
  final List<List<bool>> playerGrid;
  final Function(int col, int row) onTap;
  final double sideLength;

  const HoneycombGrid({
    super.key,
    required this.numbers,
    required this.playerGrid,
    required this.onTap,
    this.sideLength = 40,
  });

  double get hexH => sqrt(3) * sideLength;

  double get totalWidth {
  final cols = numbers[0].length;
  final rows = numbers.length;

  return 2 * sideLength +
      (cols + rows - 2) * 1.5 * sideLength;
}

 double get totalHeight {
  final cols = numbers[0].length;
  final rows = numbers.length;

  return hexH + (cols + rows - 2) * 0.5 * hexH + hexH + sideLength * 0.5;
}

  double get yOffset {
  return (numbers.length - 1) * 0.5 * hexH + hexH / 2;
}

  Offset centerOf(int col, int row) {
  final double x = sideLength + (col + row) * 1.5 * sideLength;
  final double y = 
      yOffset + (col - row) * 0.5 * hexH+5;

  return Offset(x, y);
}

  @override
  Widget build(BuildContext context) {
    return 
      GestureDetector(
        onTapDown: (details) {
          // find which hex was tapped by checking distance to each center
          final rows = numbers.length;
          final cols = numbers[0].length;
          int? tappedCol, tappedRow;
          double minDist = double.infinity;

          for (int row = 0; row < rows; row++) {
            for (int col = 0; col < cols; col++) {
              final center = centerOf(col, row);
              final dist = (details.localPosition - center).distance;
              if (dist < minDist) {
                minDist = dist;
                tappedCol = col;
                tappedRow = row;
              }
            }
          }

          // only register tap if within hex bounds
          if (minDist < hexH / 2 && tappedCol != null && tappedRow != null) {
            onTap(tappedCol!, tappedRow!);
          }
        },

        child: SizedBox(
          width: totalWidth,
          height: totalHeight,
          child: CustomPaint(
            painter: HoneycombPainter(
              numbers: numbers,
              playerGrid: playerGrid,
              sideLength: sideLength,
            ),
          ),
        ),
      );
  }
}
