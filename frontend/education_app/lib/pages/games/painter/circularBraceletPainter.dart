import 'package:flutter/material.dart';
import 'dart:math';
import 'package:education_app/utils/int_to_colour.dart';


class  CircularBraceletPainter extends CustomPainter {
  final List<int> beadColors;
  final int offset = 5; //gap between beads and edge of square?
  final int randomNo;

  CircularBraceletPainter({required this.beadColors, required this.randomNo});
  

  @override
  void paint(Canvas canvas, Size size) {
    final n = beadColors.length;//Number of beads
    final center = Offset(size.width / 2, size.height/2);
    //Find Radius of big circle - size.shortest side gives you larger of width and height
    final bigRadius = (size.shortestSide/2) - beadRadius - offset;

    //draw potential cord (and check it works ahahaha)
    final cordPaint = Paint()..color = Colors.brown..strokeWidth=3..style=PaintingStyle.stroke;
    canvas.drawCircle(center, bigRadius, cordPaint);

    // draw beads
    int direction;
    if(randomNo%2==0){
        direction = -1;
    }else{
      direction = 1;
    }
    for(int i = 0; i<n; i++){
      

      final theta = (pi/2)+((direction*2*i*pi)/n);
      
      //x co-ord = center x + Rcos(theta)
      final beadX = center.dx + (bigRadius*cos(theta));
      //y co-ord = center y + Rsin theta
      final beadY = center.dy + (bigRadius*sin(theta));
      final beadCenter = Offset(beadX, beadY);


      int index = (randomNo+i)%n;
      canvas.drawCircle(beadCenter, beadRadius, Paint()..color = toBeadColours(beadColors)[index]);
      canvas.drawCircle(beadCenter, beadRadius, Paint()..color= Colors.black..style=PaintingStyle.stroke..strokeWidth=1.5);
    }
  }
  
  @override
  bool shouldRepaint(covariant CircularBraceletPainter old) {
    return old.beadColors!=beadColors;
  }

  

  
}