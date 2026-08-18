import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:education_app/pages/students/home_page.dart';
import 'package:education_app/pages/students/leaderboard.dart';

class MyBottomNavBar extends StatelessWidget {
  const MyBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.green,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'Leaderboard'),
      ],
      onTap: (index) {
        if (index == 0) Get.to(() => HomePage());
        if (index == 1) Get.to(() => LeaderboardPage());
      },
    );
  }
}