import 'package:education_app/utils/screen_size.dart';
import 'package:flutter/material.dart';

class myButton extends StatelessWidget{
  final Function()? onTap;

  const myButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(25),
        margin: EdgeInsets.symmetric(horizontal: 0.2*screenWidth(context)),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            "Sign In",
            style: TextStyle(color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold)
            ),
            ),
            
      ),
    );
  }
}