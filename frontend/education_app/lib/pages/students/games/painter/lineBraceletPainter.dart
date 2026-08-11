import 'package:flutter/material.dart';
import 'package:education_app/utils/int_to_colour.dart';

class LineBraceletPainter extends CustomPainter {
  final List<int> beadColors;
  final int offset = 5; //gap between beads and edge of square?
  final int lengthOfLine = 200;

  LineBraceletPainter({required this.beadColors});

  @override
  void paint(Canvas canvas, Size size) {
    final n = beadColors.length;//Number of beads
    final center = Offset(size.width / 2, size.height/2);
    final cordPaint = Paint()..color = Colors.brown..strokeWidth=3..style=PaintingStyle.stroke;
    double y = size.height/2;
    double x1 = center.dx -lengthOfLine/2;
    double x2 = center.dx +lengthOfLine/2;

    canvas.drawLine(Offset(x1,y), Offset(x2,y), cordPaint);

    double dist = lengthOfLine/n;

    for(int i =0; i<n;i++){
      double x = x1+beadRadius+(i*dist);
      
      final beadCenter = Offset(x,y);

      canvas.drawCircle(beadCenter, beadRadius, Paint()..color = toBeadColours(beadColors)[i]);
      canvas.drawCircle(beadCenter, beadRadius, Paint()..color= Colors.black..style=PaintingStyle.stroke..strokeWidth=1.5);
    }
  }

  @override
  bool shouldRepaint(covariant LineBraceletPainter old) {
    return beadColors!=old.beadColors;
  }
    
    
}