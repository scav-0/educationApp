import 'package:education_app/utils/teacher_colours.dart';
import 'package:flutter/material.dart';

Widget statCard({
  required String title,
  required String value,
}) {
  return Container(
    
    padding: const EdgeInsets.symmetric(
      vertical: 20,
      horizontal: 10,
    ),

    decoration: BoxDecoration(
      color: TeacherColours.primaryColor,
      borderRadius: BorderRadius.circular(15),
      boxShadow: const [
        BoxShadow(
          blurRadius: 6,
          offset: Offset(0, 3),
          color: Colors.black12,
        ),
      ],
    ),

    child: Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),

        const SizedBox(height: 8),

        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}