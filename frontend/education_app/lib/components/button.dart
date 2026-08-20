import 'package:education_app/utils/screen_size.dart';
import 'package:flutter/material.dart';

//Class for the sign in button
class myButton extends StatelessWidget{
  final Function()? onTap;
  final Color color;
  final String text;
  const myButton({super.key, required this.onTap, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(25),
        margin: EdgeInsets.symmetric(horizontal: 0.2*screenWidth(context)),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold)
            ),
            ),
            
      ),
    );
  }
}